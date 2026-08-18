using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class Wallet : System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;

            if (!IsPostBack)
            {
                pnlWalletMessage.Visible = false;

                LoadWalletInformation();
                LoadTransactions();

                // Hide Fund Wallet for Freelancers - only Employers can fund
                string userType = Session["UserType"] as string ?? "";
                bool isEmployer = userType.Equals("Employer", StringComparison.OrdinalIgnoreCase);
                pnlFundWalletAction.Visible = isEmployer;
                pnlSummaryFundBtn.Visible = isEmployer;
            }
        }


        private void LoadWalletInformation()
        {
            int walletID = 0;
            if (Session["WalletID"] != null)
                walletID = Convert.ToInt32(Session["WalletID"]);

            decimal availableBalance = 0.00m;
            decimal pendingWithdrawals = 0.00m;
            decimal onHoldBalance = 0.00m;

            if (walletID > 0)
            {
                availableBalance =
                    DatabaseHelper.GetWalletBalance(walletID);

                Session["AvailableBalance"] =
                    availableBalance;

                // Load pending withdrawals from database
                string pendingQuery = @"
                    SELECT ISNULL(SUM(transactionAmount), 0)
                    FROM [Transaction]
                    WHERE walletID = @WalletID
                      AND transactionType = 'Withdrawal'
                      AND transactionStatus = 'Pending'";

                object pendingResult = DatabaseHelper.ExecuteScalar(
                    pendingQuery,
                    new System.Data.SqlClient.SqlParameter("@WalletID", walletID));

                if (pendingResult != null && pendingResult != System.DBNull.Value)
                    pendingWithdrawals = Convert.ToDecimal(pendingResult);

                Session["PendingWithdrawals"] = pendingWithdrawals;

                // Load on-hold (escrow) balance from database
                string holdQuery = @"
                    SELECT ISNULL(SUM(transactionAmount), 0)
                    FROM [Transaction]
                    WHERE walletID = @WalletID
                      AND transactionType = 'Escrow'
                      AND transactionStatus = 'Held'";

                object holdResult = DatabaseHelper.ExecuteScalar(
                    holdQuery,
                    new SqlParameter("@WalletID", walletID));

                if (holdResult != null && holdResult != System.DBNull.Value)
                    onHoldBalance = Convert.ToDecimal(holdResult);

                Session["OnHoldBalance"] = onHoldBalance;
            }

            decimal totalBalance =
                availableBalance +
                onHoldBalance +
                pendingWithdrawals;


            string availableText =
                FormatCurrency(availableBalance);

            string onHoldText =
                FormatCurrency(onHoldBalance);

            string pendingText =
                FormatCurrency(pendingWithdrawals);

            string totalText =
                FormatCurrency(totalBalance);


            lblCurrentWalletBalance.Text =
                availableText;

            lblAvailableBalance.Text =
                availableText;

            lblOnHoldBalance.Text =
                onHoldText;

            lblPendingWithdrawals.Text =
                pendingText;

            lblTotalBalance.Text =
                totalText;


            lblSummaryAvailable.Text =
                availableText;

            lblSummaryOnHold.Text =
                onHoldText;

            lblSummaryPending.Text =
                pendingText;

            lblSummaryTotal.Text =
                totalText;
        }


        private decimal GetSessionAmount(
            string sessionName)
        {
            object sessionValue =
                Session[sessionName];

            if (sessionValue == null)
            {
                return 0.00m;
            }

            decimal amount;

            bool validAmount =
                decimal.TryParse(
                    sessionValue.ToString(),
                    out amount
                );

            if (!validAmount)
            {
                return 0.00m;
            }

            return amount;
        }


        private string FormatCurrency(
            decimal amount)
        {
            return
                "R" +
                amount.ToString("N2");
        }


        private void LoadTransactions()
        {
            int walletID = 0;
            if (Session["WalletID"] != null)
                walletID = Convert.ToInt32(Session["WalletID"]);

            DataTable dbTransactions = new DataTable();

            if (walletID > 0)
            {
                dbTransactions =
                    DatabaseHelper.GetTransactionsByWallet(
                        walletID
                    );
            }

            // Map DB columns to display columns expected by the Repeater
            DataTable displayTable = new DataTable();
            displayTable.Columns.Add("TransactionId", typeof(string));
            displayTable.Columns.Add("TransactionDate", typeof(DateTime));
            displayTable.Columns.Add("Description", typeof(string));
            displayTable.Columns.Add("Type", typeof(string));
            displayTable.Columns.Add("Amount", typeof(decimal));
            displayTable.Columns.Add("Status", typeof(string));
            displayTable.Columns.Add("Reference", typeof(string));

            int count = 0;

            foreach (DataRow row in dbTransactions.Rows)
            {
                if (count >= 5) break;

                DataRow displayRow = displayTable.NewRow();

                displayRow["TransactionId"] =
                    Convert.ToString(row["transactionID"]);

                displayRow["TransactionDate"] =
                    Convert.ToDateTime(row["transactionDate"]);

                displayRow["Description"] =
                    Convert.ToString(row["itemDescription"]);

                displayRow["Type"] =
                    Convert.ToString(row["transactionType"]);

                displayRow["Amount"] =
                    Convert.ToDecimal(row["transactionAmount"]);

                displayRow["Status"] =
                    Convert.ToString(row["transactionStatus"]);

                displayRow["Reference"] =
                    Convert.ToString(row["reference"]);

                displayTable.Rows.Add(displayRow);
                count++;
            }

            rptTransactions.DataSource =
                displayTable;

            rptTransactions.DataBind();

            pnlNoTransactions.Visible =
                displayTable.Rows.Count == 0;

            btnViewAllTransactions.Visible =
                displayTable.Rows.Count > 0;

            btnViewAllTop.Visible =
                displayTable.Rows.Count > 0;
        }


        public string FormatTransactionAmount(
            decimal amount,
            string transactionType)
        {
            bool isCredit =
                string.Equals(
                    transactionType,
                    "Credit",
                    StringComparison.OrdinalIgnoreCase
                );

            string sign =
                isCredit
                    ? "+"
                    : "-";

            return
                sign +
                " R" +
                Math.Abs(amount).ToString("N2");
        }


        public string GetAmountClass(
            string transactionType)
        {
            if (string.Equals(
                transactionType,
                "Credit",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    "transaction-credit-amount";
            }

            return
                "transaction-debit-amount";
        }


        public string GetTransactionIcon(
            string transactionType)
        {
            if (string.Equals(
                transactionType,
                "Credit",
                StringComparison.OrdinalIgnoreCase))
            {
                return "↓";
            }

            if (string.Equals(
                transactionType,
                "Withdrawal",
                StringComparison.OrdinalIgnoreCase))
            {
                return "◷";
            }

            if (string.Equals(
                transactionType,
                "Refund",
                StringComparison.OrdinalIgnoreCase))
            {
                return "↻";
            }

            return "↑";
        }


        public string GetTransactionIconClass(
            string transactionType)
        {
            string baseClass =
                "transaction-icon ";

            if (string.Equals(
                transactionType,
                "Credit",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "credit-transaction";
            }

            if (string.Equals(
                transactionType,
                "Withdrawal",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "pending-transaction";
            }

            if (string.Equals(
                transactionType,
                "Refund",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "refund-transaction";
            }

            return
                baseClass +
                "debit-transaction";
        }


        public string GetTransactionTypeClass(
            string transactionType)
        {
            string baseClass =
                "transaction-type ";

            if (string.Equals(
                transactionType,
                "Credit",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "credit-type";
            }

            if (string.Equals(
                transactionType,
                "Withdrawal",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "withdrawal-type";
            }

            if (string.Equals(
                transactionType,
                "Refund",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "refund-type";
            }

            return
                baseClass +
                "debit-type";
        }


        public string GetStatusClass(
            string status)
        {
            string baseClass =
                "transaction-status ";

            if (string.Equals(
                status,
                "Completed",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "completed-status";
            }

            if (string.Equals(
                status,
                "Failed",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "failed-status";
            }

            return
                baseClass +
                "pending-status";
        }


        protected void btnFundWallet_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "FundWallet.aspx"
            );
        }


        protected void btnWithdrawFunds_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "WithdrawFunds.aspx"
            );
        }


        protected void btnViewTransactions_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "Transactions.aspx"
            );
        }


        protected void btnPayouts_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "Payouts.aspx"
            );
        }


        protected void btnDisputes_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "Disputes.aspx"
            );
        }


        protected void btnRefunds_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "Refunds.aspx"
            );
        }


        protected void rptTransactions_ItemCommand(
            object source,
            RepeaterCommandEventArgs e)
        {
            if (!string.Equals(
                e.CommandName,
                "ViewTransaction",
                StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            string transactionId =
                Convert.ToString(
                    e.CommandArgument
                );

            if (string.IsNullOrWhiteSpace(
                transactionId))
            {
                ShowMessage(
                    "The selected transaction is invalid.",
                    false
                );

                return;
            }

            Response.Redirect(
                "Transactions.aspx?txn=" +
                Server.UrlEncode(
                    transactionId
                )
            );
        }


        private void ShowMessage(
            string message,
            bool success)
        {
            pnlWalletMessage.Visible = true;

            lblWalletMessage.Text =
                message;

            pnlWalletMessage.CssClass =
                success
                    ? "wallet-message-panel wallet-success-message"
                    : "wallet-message-panel wallet-warning-message";
        }
    }
}
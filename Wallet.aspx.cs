using System;
using System.Data;
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
            }
        }


        private void LoadWalletInformation()
        {
            decimal availableBalance =
                GetSessionAmount("AvailableBalance");

            decimal onHoldBalance =
                GetSessionAmount("OnHoldBalance");

            decimal pendingWithdrawals =
                GetSessionAmount("PendingWithdrawals");

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
            DataTable allTransactions =
                TransactionStore.GetTransactions(
                    Session
                );

            DataView sortedView =
                allTransactions.DefaultView;

            sortedView.Sort =
                "TransactionDate DESC";

            DataTable recentTable =
                allTransactions.Clone();

            int count = 0;

            foreach (DataRowView rowView in sortedView)
            {
                if (count >= 5)
                {
                    break;
                }

                recentTable.ImportRow(
                    rowView.Row
                );

                count++;
            }

            rptTransactions.DataSource =
                recentTable;

            rptTransactions.DataBind();

            pnlNoTransactions.Visible =
                recentTable.Rows.Count == 0;

            btnViewAllTransactions.Visible =
                recentTable.Rows.Count > 0;

            btnViewAllTop.Visible =
                recentTable.Rows.Count > 0;
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
                "Transactions.aspx?type=Debit"
            );
        }


        protected void btnDisputes_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "Transactions.aspx"
            );
        }


        protected void btnRefunds_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "Transactions.aspx?type=Refund"
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
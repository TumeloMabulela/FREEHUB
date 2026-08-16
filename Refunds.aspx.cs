using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class Refunds : System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;

            if (!IsPostBack)
            {
                pnlMessage.Visible = false;

                LoadBalance();
                LoadSummary();
                LoadRecentRefunds();
            }
        }


        private void LoadBalance()
        {
            decimal availableBalance = 0.00m;

            int walletID = GetWalletID();

            if (walletID > 0)
            {
                availableBalance =
                    DatabaseHelper.GetWalletBalance(walletID);

                Session["AvailableBalance"] =
                    availableBalance;
            }

            lblCurrentBalance.Text =
                FormatCurrency(availableBalance);
        }


        private void LoadSummary()
        {
            int walletID = GetWalletID();

            decimal totalRefunded = 0.00m;
            decimal pendingRefunds = 0.00m;
            int completedCount = 0;

            if (walletID > 0)
            {
                // Total completed refunds
                string totalQuery = @"
                    SELECT ISNULL(SUM(transactionAmount), 0)
                    FROM [Transaction]
                    WHERE walletID = @WalletID
                      AND transactionType = 'Refund'
                      AND transactionStatus = 'Completed'";

                object totalResult = DatabaseHelper.ExecuteScalar(
                    totalQuery,
                    new SqlParameter("@WalletID", walletID));

                if (totalResult != null && totalResult != DBNull.Value)
                    totalRefunded = Convert.ToDecimal(totalResult);

                // Pending refunds
                string pendingQuery = @"
                    SELECT ISNULL(SUM(transactionAmount), 0)
                    FROM [Transaction]
                    WHERE walletID = @WalletID
                      AND transactionType = 'Refund'
                      AND transactionStatus = 'Pending'";

                object pendingResult = DatabaseHelper.ExecuteScalar(
                    pendingQuery,
                    new SqlParameter("@WalletID", walletID));

                if (pendingResult != null && pendingResult != DBNull.Value)
                    pendingRefunds = Convert.ToDecimal(pendingResult);

                // Completed count
                string countQuery = @"
                    SELECT COUNT(*)
                    FROM [Transaction]
                    WHERE walletID = @WalletID
                      AND transactionType = 'Refund'
                      AND transactionStatus = 'Completed'";

                object countResult = DatabaseHelper.ExecuteScalar(
                    countQuery,
                    new SqlParameter("@WalletID", walletID));

                if (countResult != null && countResult != DBNull.Value)
                    completedCount = Convert.ToInt32(countResult);
            }

            lblTotalRefunded.Text =
                FormatCurrency(totalRefunded);

            lblPendingRefunds.Text =
                FormatCurrency(pendingRefunds);

            lblCompletedCount.Text =
                completedCount.ToString();
        }


        private void LoadRecentRefunds()
        {
            int walletID = GetWalletID();

            DataTable refunds = new DataTable();
            refunds.Columns.Add("TransactionDate", typeof(DateTime));
            refunds.Columns.Add("Description", typeof(string));
            refunds.Columns.Add("Amount", typeof(decimal));
            refunds.Columns.Add("Status", typeof(string));

            if (walletID > 0)
            {
                string query = @"
                    SELECT TOP 5
                        transactionDate,
                        itemDescription,
                        transactionAmount,
                        transactionStatus
                    FROM [Transaction]
                    WHERE walletID = @WalletID
                      AND transactionType = 'Refund'
                    ORDER BY transactionDate DESC";

                DataTable dbRefunds = DatabaseHelper.ExecuteQuery(
                    query,
                    new SqlParameter("@WalletID", walletID));

                foreach (DataRow row in dbRefunds.Rows)
                {
                    DataRow displayRow = refunds.NewRow();

                    displayRow["TransactionDate"] =
                        Convert.ToDateTime(row["transactionDate"]);

                    displayRow["Description"] =
                        Convert.ToString(row["itemDescription"]);

                    displayRow["Amount"] =
                        Convert.ToDecimal(row["transactionAmount"]);

                    displayRow["Status"] =
                        Convert.ToString(row["transactionStatus"]);

                    refunds.Rows.Add(displayRow);
                }
            }

            rptRefunds.DataSource = refunds;
            rptRefunds.DataBind();

            pnlNoRefunds.Visible =
                refunds.Rows.Count == 0;

            btnViewAll.Visible =
                refunds.Rows.Count > 0;
        }


        protected void btnSubmitRefund_Click(
            object sender,
            EventArgs e)
        {
            string transactionRef =
                txtTransactionRef.Text.Trim();

            if (string.IsNullOrWhiteSpace(transactionRef))
            {
                ShowMessage(
                    "Please enter a transaction reference.",
                    false
                );
                return;
            }

            decimal refundAmount;

            bool amountIsValid =
                decimal.TryParse(
                    txtRefundAmount.Text.Trim(),
                    out refundAmount
                );

            if (!amountIsValid || refundAmount <= 0)
            {
                ShowMessage(
                    "Please enter a valid refund amount.",
                    false
                );
                return;
            }

            if (string.IsNullOrWhiteSpace(
                ddlReason.SelectedValue))
            {
                ShowMessage(
                    "Please select a reason for the refund.",
                    false
                );
                return;
            }

            string reason = ddlReason.SelectedValue;
            string details = txtDetails.Text.Trim();

            int walletID = GetWalletID();

            if (walletID == 0)
            {
                ShowMessage(
                    "Wallet not found. Please log in again.",
                    false
                );
                return;
            }

            // Verify the transaction reference exists for this wallet
            string verifyQuery = @"
                SELECT transactionID, transactionAmount, transactionType
                FROM [Transaction]
                WHERE walletID = @WalletID
                  AND reference = @Reference";

            DataTable verifyResult = DatabaseHelper.ExecuteQuery(
                verifyQuery,
                new SqlParameter("@WalletID", walletID),
                new SqlParameter("@Reference", transactionRef));

            if (verifyResult.Rows.Count == 0)
            {
                ShowMessage(
                    "Transaction reference not found. Please check and try again.",
                    false
                );
                return;
            }

            decimal originalAmount =
                Convert.ToDecimal(verifyResult.Rows[0]["transactionAmount"]);

            if (refundAmount > originalAmount)
            {
                ShowMessage(
                    "Refund amount cannot exceed the original transaction amount of " +
                    FormatCurrency(originalAmount) + ".",
                    false
                );
                return;
            }

            // Create the refund transaction as Pending
            string refundReference =
                TransactionStore.CreateReference("REF");

            string description =
                "Refund for " + transactionRef +
                " - " + reason;

            if (!string.IsNullOrWhiteSpace(details))
            {
                description += " (" + details + ")";
            }

            DatabaseHelper.AddTransaction(
                walletID,
                description,
                "Refund",
                refundAmount,
                "Pending",
                refundReference,
                "Wallet Credit"
            );

            // Keep in-memory transaction store in sync
            TransactionStore.AddTransaction(
                Session,
                "Refund Request",
                description,
                "Refund",
                refundAmount,
                "Pending",
                refundReference,
                "Wallet Credit"
            );

            // Create notification
            int currentUserId = Convert.ToInt32(Session["UserID"]);
            string notificationMsg =
                "Refund request of " +
                FormatCurrency(refundAmount) +
                " submitted for review.";

            NotificationHelper.CreateNotification(
                currentUserId,
                "Payment",
                notificationMsg
            );

            // Clear form
            txtTransactionRef.Text = "";
            txtRefundAmount.Text = "";
            ddlReason.SelectedIndex = 0;
            txtDetails.Text = "";

            // Reload data
            LoadSummary();
            LoadRecentRefunds();

            ShowMessage(
                "Refund request submitted successfully. " +
                FormatCurrency(refundAmount) +
                " is pending administrator approval. " +
                "Reference: " + refundReference,
                true
            );
        }


        protected void btnViewAll_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "Transactions.aspx?type=Refund"
            );
        }


        public string GetRefundStatusClass(
            string status)
        {
            if (string.Equals(
                status,
                "Completed",
                StringComparison.OrdinalIgnoreCase))
            {
                return "refunds-status refunds-status-completed";
            }

            if (string.Equals(
                status,
                "Failed",
                StringComparison.OrdinalIgnoreCase))
            {
                return "refunds-status refunds-status-failed";
            }

            return "refunds-status refunds-status-pending";
        }


        private int GetWalletID()
        {
            if (Session["WalletID"] != null)
                return Convert.ToInt32(Session["WalletID"]);

            return 0;
        }


        private string FormatCurrency(
            decimal amount)
        {
            return
                "R" +
                amount.ToString("N2");
        }


        private void ShowMessage(
            string message,
            bool success)
        {
            pnlMessage.Visible = true;

            lblMessage.Text = message;

            pnlMessage.CssClass =
                success
                    ? "refunds-message refunds-success"
                    : "refunds-message refunds-error";
        }
    }
}

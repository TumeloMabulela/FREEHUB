using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class Disputes : System.Web.UI.Page
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
                LoadRecentDisputes();
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
            int userID = GetUserID();

            int openCount = 0;
            int inReviewCount = 0;
            int resolvedCount = 0;

            if (userID > 0)
            {
                string openQuery = @"
                    SELECT COUNT(*)
                    FROM Dispute
                    WHERE userID = @UserID
                      AND status = 'Open'";

                object openResult = DatabaseHelper.ExecuteScalar(
                    openQuery,
                    new SqlParameter("@UserID", userID));

                if (openResult != null && openResult != DBNull.Value)
                    openCount = Convert.ToInt32(openResult);

                string reviewQuery = @"
                    SELECT COUNT(*)
                    FROM Dispute
                    WHERE userID = @UserID
                      AND status = 'In Review'";

                object reviewResult = DatabaseHelper.ExecuteScalar(
                    reviewQuery,
                    new SqlParameter("@UserID", userID));

                if (reviewResult != null && reviewResult != DBNull.Value)
                    inReviewCount = Convert.ToInt32(reviewResult);

                string resolvedQuery = @"
                    SELECT COUNT(*)
                    FROM Dispute
                    WHERE userID = @UserID
                      AND (status = 'Resolved' OR status = 'Closed')";

                object resolvedResult = DatabaseHelper.ExecuteScalar(
                    resolvedQuery,
                    new SqlParameter("@UserID", userID));

                if (resolvedResult != null && resolvedResult != DBNull.Value)
                    resolvedCount = Convert.ToInt32(resolvedResult);
            }

            lblOpenCount.Text = openCount.ToString();
            lblInReviewCount.Text = inReviewCount.ToString();
            lblResolvedCount.Text = resolvedCount.ToString();
        }


        private void LoadRecentDisputes()
        {
            int userID = GetUserID();

            DataTable disputes = new DataTable();
            disputes.Columns.Add("DateCreated", typeof(DateTime));
            disputes.Columns.Add("Reason", typeof(string));
            disputes.Columns.Add("Status", typeof(string));

            if (userID > 0)
            {
                string query = @"
                    SELECT TOP 5
                        dateCreated,
                        reason,
                        status
                    FROM Dispute
                    WHERE userID = @UserID
                    ORDER BY dateCreated DESC";

                DataTable dbDisputes = DatabaseHelper.ExecuteQuery(
                    query,
                    new SqlParameter("@UserID", userID));

                foreach (DataRow row in dbDisputes.Rows)
                {
                    DataRow displayRow = disputes.NewRow();

                    displayRow["DateCreated"] =
                        Convert.ToDateTime(row["dateCreated"]);

                    displayRow["Reason"] =
                        Convert.ToString(row["reason"]);

                    displayRow["Status"] =
                        Convert.ToString(row["status"]);

                    disputes.Rows.Add(displayRow);
                }
            }

            rptDisputes.DataSource = disputes;
            rptDisputes.DataBind();

            pnlNoDisputes.Visible =
                disputes.Rows.Count == 0;

            btnViewAll.Visible =
                disputes.Rows.Count > 0;
        }


        protected void btnSubmitDispute_Click(
            object sender,
            EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(
                ddlDisputeType.SelectedValue))
            {
                ShowMessage(
                    "Please select a dispute type.",
                    false
                );
                return;
            }

            string referenceId =
                txtReferenceId.Text.Trim();

            if (string.IsNullOrWhiteSpace(referenceId))
            {
                ShowMessage(
                    "Please enter a reference ID.",
                    false
                );
                return;
            }

            if (string.IsNullOrWhiteSpace(
                ddlReason.SelectedValue))
            {
                ShowMessage(
                    "Please select a reason for the dispute.",
                    false
                );
                return;
            }

            string description =
                txtDescription.Text.Trim();

            if (string.IsNullOrWhiteSpace(description))
            {
                ShowMessage(
                    "Please provide a description of the issue.",
                    false
                );
                return;
            }

            int userID = GetUserID();

            if (userID == 0)
            {
                ShowMessage(
                    "User not found. Please log in again.",
                    false
                );
                return;
            }

            string disputeType = ddlDisputeType.SelectedValue;
            string reason = ddlReason.SelectedValue;

            // Determine projectID and transactionID based on type
            int? projectID = null;
            int? transactionID = null;

            if (disputeType == "Transaction")
            {
                int txnId;
                if (int.TryParse(referenceId, out txnId))
                {
                    transactionID = txnId;
                }
            }
            else if (disputeType == "Project")
            {
                int projId;
                if (int.TryParse(referenceId, out projId))
                {
                    projectID = projId;
                }
            }

            // Insert dispute into database
            string insertQuery = @"
                INSERT INTO Dispute
                    (userID, projectID, transactionID, disputeDescription, reason, status)
                VALUES
                    (@UserID, @ProjectID, @TransactionID, @Description, @Reason, 'Open');
                SELECT SCOPE_IDENTITY();";

            object result = DatabaseHelper.ExecuteScalar(
                insertQuery,
                new SqlParameter("@UserID", userID),
                new SqlParameter("@ProjectID",
                    projectID.HasValue ? (object)projectID.Value : DBNull.Value),
                new SqlParameter("@TransactionID",
                    transactionID.HasValue ? (object)transactionID.Value : DBNull.Value),
                new SqlParameter("@Description", description),
                new SqlParameter("@Reason", reason));

            int disputeID = 0;
            if (result != null && result != DBNull.Value)
                disputeID = Convert.ToInt32(result);

            // Create notification
            string notificationMsg =
                "Dispute #" + disputeID +
                " submitted: " + reason + ".";

            NotificationHelper.CreateNotification(
                userID,
                "Dispute",
                notificationMsg
            );

            // Clear form
            ddlDisputeType.SelectedIndex = 0;
            txtReferenceId.Text = "";
            ddlReason.SelectedIndex = 0;
            txtDescription.Text = "";

            // Reload data
            LoadSummary();
            LoadRecentDisputes();

            ShowMessage(
                "Dispute submitted successfully. " +
                "Dispute #" + disputeID +
                " is now open and pending review by an administrator.",
                true
            );
        }


        protected void btnViewAll_Click(
            object sender,
            EventArgs e)
        {
            // Could redirect to a full disputes list page in the future
            // For now reload current page
            Response.Redirect("Disputes.aspx");
        }


        public string GetDisputeStatusClass(
            string status)
        {
            if (string.Equals(
                status,
                "Open",
                StringComparison.OrdinalIgnoreCase))
            {
                return "disputes-status disputes-status-open";
            }

            if (string.Equals(
                status,
                "In Review",
                StringComparison.OrdinalIgnoreCase))
            {
                return "disputes-status disputes-status-review";
            }

            if (string.Equals(
                status,
                "Resolved",
                StringComparison.OrdinalIgnoreCase))
            {
                return "disputes-status disputes-status-resolved";
            }

            if (string.Equals(
                status,
                "Closed",
                StringComparison.OrdinalIgnoreCase))
            {
                return "disputes-status disputes-status-resolved";
            }

            return "disputes-status disputes-status-open";
        }


        private int GetUserID()
        {
            if (Session["UserID"] != null)
                return Convert.ToInt32(Session["UserID"]);

            return 0;
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
                    ? "disputes-message disputes-success"
                    : "disputes-message disputes-error";
        }
    }
}

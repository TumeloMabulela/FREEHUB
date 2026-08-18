using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class Payouts : System.Web.UI.Page
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
                LoadPayoutHistory();
                LoadEscrowProjects();
            }
        }


        private void LoadBalance()
        {
            int walletID = GetWalletID();
            decimal balance = 0.00m;

            if (walletID > 0)
            {
                balance = DatabaseHelper.GetWalletBalance(walletID);
                Session["AvailableBalance"] = balance;
            }

            lblCurrentBalance.Text = FormatCurrency(balance);
        }


        private void LoadSummary()
        {
            int walletID = GetWalletID();

            decimal totalPaidOut = 0.00m;
            decimal inEscrow = 0.00m;
            int completedCount = 0;

            if (walletID > 0)
            {
                // Total paid out (Escrow transactions that are Released)
                string paidQuery = @"
                    SELECT ISNULL(SUM(transactionAmount), 0)
                    FROM [Transaction]
                    WHERE walletID = @WalletID
                      AND transactionType = 'Escrow'
                      AND transactionStatus = 'Released'";

                object paidResult = DatabaseHelper.ExecuteScalar(
                    paidQuery,
                    new SqlParameter("@WalletID", walletID));

                if (paidResult != null && paidResult != DBNull.Value)
                    totalPaidOut = Convert.ToDecimal(paidResult);

                // Currently in escrow (Held)
                string escrowQuery = @"
                    SELECT ISNULL(SUM(transactionAmount), 0)
                    FROM [Transaction]
                    WHERE walletID = @WalletID
                      AND transactionType = 'Escrow'
                      AND transactionStatus = 'Held'";

                object escrowResult = DatabaseHelper.ExecuteScalar(
                    escrowQuery,
                    new SqlParameter("@WalletID", walletID));

                if (escrowResult != null && escrowResult != DBNull.Value)
                    inEscrow = Convert.ToDecimal(escrowResult);

                // Completed payout count
                string countQuery = @"
                    SELECT COUNT(*)
                    FROM [Transaction]
                    WHERE walletID = @WalletID
                      AND transactionType = 'Escrow'
                      AND transactionStatus = 'Released'";

                object countResult = DatabaseHelper.ExecuteScalar(
                    countQuery,
                    new SqlParameter("@WalletID", walletID));

                if (countResult != null && countResult != DBNull.Value)
                    completedCount = Convert.ToInt32(countResult);
            }

            lblTotalPaidOut.Text = FormatCurrency(totalPaidOut);
            lblInEscrow.Text = FormatCurrency(inEscrow);
            lblCompletedCount.Text = completedCount.ToString();
        }


        private void LoadPayoutHistory()
        {
            int walletID = GetWalletID();

            DataTable payouts = new DataTable();
            payouts.Columns.Add("TransactionDate", typeof(DateTime));
            payouts.Columns.Add("Description", typeof(string));
            payouts.Columns.Add("Type", typeof(string));
            payouts.Columns.Add("Amount", typeof(decimal));
            payouts.Columns.Add("Status", typeof(string));
            payouts.Columns.Add("Reference", typeof(string));

            if (walletID > 0)
            {
                string query = @"
                    SELECT
                        transactionDate,
                        itemDescription,
                        transactionType,
                        transactionAmount,
                        transactionStatus,
                        reference
                    FROM [Transaction]
                    WHERE walletID = @WalletID
                      AND transactionType = 'Escrow'
                    ORDER BY transactionDate DESC";

                DataTable dbPayouts = DatabaseHelper.ExecuteQuery(
                    query,
                    new SqlParameter("@WalletID", walletID));

                foreach (DataRow row in dbPayouts.Rows)
                {
                    DataRow displayRow = payouts.NewRow();

                    displayRow["TransactionDate"] =
                        Convert.ToDateTime(row["transactionDate"]);

                    displayRow["Description"] =
                        Convert.ToString(row["itemDescription"]);

                    displayRow["Type"] =
                        Convert.ToString(row["transactionStatus"]) == "Held"
                            ? "Escrow Hold"
                            : "Payout Released";

                    displayRow["Amount"] =
                        Convert.ToDecimal(row["transactionAmount"]);

                    displayRow["Status"] =
                        Convert.ToString(row["transactionStatus"]);

                    displayRow["Reference"] =
                        Convert.ToString(row["reference"]);

                    payouts.Rows.Add(displayRow);
                }
            }

            rptPayouts.DataSource = payouts;
            rptPayouts.DataBind();

            pnlNoPayouts.Visible = payouts.Rows.Count == 0;

            lblPayoutCount.Text =
                payouts.Rows.Count + (payouts.Rows.Count == 1 ? " payout" : " payouts");
        }


        private void LoadEscrowProjects()
        {
            int userID = GetUserID();

            DataTable escrowProjects = new DataTable();
            escrowProjects.Columns.Add("ProjectID", typeof(int));
            escrowProjects.Columns.Add("Title", typeof(string));
            escrowProjects.Columns.Add("DateCreated", typeof(DateTime));
            escrowProjects.Columns.Add("Budget", typeof(decimal));
            escrowProjects.Columns.Add("FreelancerName", typeof(string));

            if (userID > 0)
            {
                // Get projects with accepted freelancer info
                string query = @"
                    SELECT p.projectID, p.title, p.dateCreated, p.budget,
                           (SELECT TOP 1 u.firstName + ' ' + u.lastName
                            FROM Proposal pr
                            INNER JOIN Freelancer f ON pr.freelancerID = f.freelancerID
                            INNER JOIN [User] u ON f.userID = u.userID
                            WHERE pr.projectID = p.projectID
                              AND pr.status = 'Accepted') AS freelancerName
                    FROM Project p
                    INNER JOIN Employer e ON p.employerID = e.employerID
                    WHERE e.userID = @UserID
                      AND p.projectStatus IN ('Open', 'In Progress')
                    ORDER BY p.dateCreated DESC";

                DataTable dbProjects = DatabaseHelper.ExecuteQuery(
                    query,
                    new SqlParameter("@UserID", userID));

                foreach (DataRow row in dbProjects.Rows)
                {
                    DataRow displayRow = escrowProjects.NewRow();

                    displayRow["ProjectID"] =
                        Convert.ToInt32(row["projectID"]);

                    displayRow["Title"] =
                        Convert.ToString(row["title"]);

                    displayRow["DateCreated"] =
                        Convert.ToDateTime(row["dateCreated"]);

                    displayRow["Budget"] =
                        Convert.ToDecimal(row["budget"]);

                    string flName = Convert.ToString(row["freelancerName"]);
                    displayRow["FreelancerName"] =
                        string.IsNullOrWhiteSpace(flName) ? "Not yet assigned" : flName;

                    escrowProjects.Rows.Add(displayRow);
                }
            }

            rptEscrowProjects.DataSource = escrowProjects;
            rptEscrowProjects.DataBind();

            pnlNoEscrow.Visible = escrowProjects.Rows.Count == 0;
        }


        protected void rptEscrowProjects_ItemCommand(
            object source,
            System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ReleaseFunds") return;

            int projectID = Convert.ToInt32(e.CommandArgument);
            int userID = GetUserID();
            int walletID = GetWalletID();

            if (walletID == 0 || userID == 0)
            {
                ShowMessage("Session expired. Please log in again.", false);
                return;
            }

            // Get project details
            DataRow project = DatabaseHelper.GetProjectById(projectID);
            if (project == null)
            {
                ShowMessage("Project not found.", false);
                return;
            }

            decimal budget = Convert.ToDecimal(project["budget"]);
            string projectTitle = Convert.ToString(project["title"]);

            // Verify this project belongs to the current employer
            int empId = Convert.ToInt32(project["employerID"]);
            string ownerQuery = "SELECT userID FROM Employer WHERE employerID = @EmpID";
            object ownerResult = DatabaseHelper.ExecuteScalar(ownerQuery,
                new SqlParameter("@EmpID", empId));

            if (ownerResult == null || Convert.ToInt32(ownerResult) != userID)
            {
                ShowMessage("You do not have permission to release funds for this project.", false);
                return;
            }

            // Calculate 10% platform fee
            decimal commissionRate = 0.10m;
            decimal commissionFee = Math.Round(budget * commissionRate, 2);
            decimal netPayout = budget - commissionFee;

            // 1. Mark project as Completed
            DatabaseHelper.ExecuteNonQuery(
                "UPDATE Project SET projectStatus = 'Completed' WHERE projectID = @ProjectID",
                new SqlParameter("@ProjectID", projectID));

            // 2. Mark the escrow transaction as Released
            string releaseEscrowQuery = @"
                UPDATE [Transaction]
                SET transactionStatus = 'Released'
                WHERE walletID = @WalletID
                  AND transactionType = 'Escrow'
                  AND transactionStatus = 'Held'
                  AND paymentMethod LIKE '%Project #' + CAST(@ProjectID AS VARCHAR) + '%'";

            DatabaseHelper.ExecuteNonQuery(releaseEscrowQuery,
                new SqlParameter("@WalletID", walletID),
                new SqlParameter("@ProjectID", projectID));

            // 3. Find the freelancer assigned to this project (accepted proposal)
            string freelancerQuery = @"
                SELECT f.userID
                FROM Proposal pr
                INNER JOIN Freelancer f ON pr.freelancerID = f.freelancerID
                WHERE pr.projectID = @ProjectID
                  AND pr.status = 'Accepted'";

            object freelancerResult = DatabaseHelper.ExecuteScalar(freelancerQuery,
                new SqlParameter("@ProjectID", projectID));

            if (freelancerResult != null && freelancerResult != DBNull.Value)
            {
                int freelancerUserId = Convert.ToInt32(freelancerResult);

                // 4. Pay the freelancer (90%)
                DataRow freelancerWallet = DatabaseHelper.GetWalletByUserId(freelancerUserId);
                if (freelancerWallet != null)
                {
                    int flWalletId = Convert.ToInt32(freelancerWallet["walletID"]);
                    decimal flCurrentBalance = Convert.ToDecimal(freelancerWallet["balance"]);
                    decimal flNewBalance = flCurrentBalance + netPayout;

                    DatabaseHelper.UpdateWalletBalance(flWalletId, flNewBalance);

                    string payRef = TransactionStore.CreateReference("PAY");
                    string payDescription = "Payout for project: " + projectTitle +
                        " (90% of R" + budget.ToString("N2") + ")";

                    DatabaseHelper.AddTransaction(
                        flWalletId,
                        payDescription,
                        "Credit",
                        netPayout,
                        "Completed",
                        payRef,
                        "Escrow Release");

                    // Notify freelancer
                    NotificationHelper.CreateNotification(
                        freelancerUserId,
                        "Payment",
                        "You received R" + netPayout.ToString("N2") +
                        " for project: " + projectTitle);
                }
            }

            // 5. Platform commission (10%) to admin wallet
            DataRow adminWallet = DatabaseHelper.GetWalletByUserId(1);
            if (adminWallet != null)
            {
                int adminWalletId = Convert.ToInt32(adminWallet["walletID"]);
                decimal adminBalance = Convert.ToDecimal(adminWallet["balance"]);
                decimal newAdminBalance = adminBalance + commissionFee;

                DatabaseHelper.UpdateWalletBalance(adminWalletId, newAdminBalance);

                string feeRef = TransactionStore.CreateReference("FEE");
                DatabaseHelper.AddTransaction(
                    adminWalletId,
                    "Platform fee from project: " + projectTitle,
                    "Credit",
                    commissionFee,
                    "Completed",
                    feeRef,
                    "Platform Fee");
            }

            // 6. Notify employer
            NotificationHelper.CreateNotification(
                userID,
                "Payment",
                "R" + budget.ToString("N2") + " released for project: " + projectTitle +
                ". Freelancer received R" + netPayout.ToString("N2") + ".");

            // Reload page data
            LoadBalance();
            LoadSummary();
            LoadPayoutHistory();
            LoadEscrowProjects();

            ShowMessage(
                "Funds released successfully! R" + netPayout.ToString("N2") +
                " paid to freelancer for \"" + projectTitle +
                "\". Platform fee: R" + commissionFee.ToString("N2") + ".",
                true);
        }


        public string GetTypeClass(string type)
        {
            if (type == "Escrow Hold")
                return "payouts-type-badge payouts-type-held";

            return "payouts-type-badge payouts-type-released";
        }


        public string GetAmountClass(string type)
        {
            if (type == "Escrow Hold")
                return "payouts-amount-held";

            return "payouts-amount-released";
        }


        public string FormatAmount(decimal amount, string type)
        {
            string sign = type == "Escrow Hold" ? "-" : "";
            return sign + " R" + amount.ToString("N2");
        }


        public string GetStatusClass(string status)
        {
            if (string.Equals(status, "Held",
                StringComparison.OrdinalIgnoreCase))
            {
                return "payouts-status payouts-status-held";
            }

            if (string.Equals(status, "Released",
                StringComparison.OrdinalIgnoreCase))
            {
                return "payouts-status payouts-status-released";
            }

            return "payouts-status payouts-status-held";
        }


        private int GetWalletID()
        {
            if (Session["WalletID"] != null)
                return Convert.ToInt32(Session["WalletID"]);
            return 0;
        }


        private int GetUserID()
        {
            if (Session["UserID"] != null)
                return Convert.ToInt32(Session["UserID"]);
            return 0;
        }


        private string FormatCurrency(decimal amount)
        {
            return "R" + amount.ToString("N2");
        }


        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = message;
            pnlMessage.CssClass = success
                ? "payouts-message payouts-success"
                : "payouts-message payouts-error";
        }
    }
}

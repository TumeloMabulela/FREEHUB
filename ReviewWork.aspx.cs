using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class ReviewWork : System.Web.UI.Page
    {
        private int ProjectId
        {
            get
            {
                int id = 0;
                int.TryParse(Request.QueryString["projectId"], out id);
                return id;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireRole(this, "Employer")) return;

            if (!IsPostBack)
            {
                LoadSubmissionDetails();
            }
        }

        private void LoadSubmissionDetails()
        {
            if (ProjectId <= 0)
            {
                ShowStatus("No project selected.", false);
                btnApproveWork.Enabled = false;
                return;
            }

            try
            {
                // Retrieve project, approved proposal, and latest submission message
                string query = @"
                    SELECT 
                        p.projectID, p.title, p.budget, p.projectStatus,
                        (uFl.firstName + ' ' + uFl.lastName) AS freelancerName,
                        uFl.userID AS freelancerUserID,
                        f.freelancerID,
                        m.content AS submissionContent
                    FROM dbo.Project p
                    INNER JOIN dbo.Proposal prop ON p.projectID = prop.projectID AND prop.status = 'Approved'
                    INNER JOIN dbo.Freelancer f ON prop.freelancerID = f.freelancerID
                    INNER JOIN dbo.[User] uFl ON f.userID = uFl.userID
                    LEFT JOIN dbo.Message m ON m.projectID = p.projectID AND m.senderID = uFl.userID
                    WHERE p.projectID = @ProjectID
                    ORDER BY m.timeStamp DESC";

                DataRow row = DatabaseHelper.GetDataRow(query, new SqlParameter("@ProjectID", ProjectId));

                if (row == null)
                {
                    ShowStatus("Project or submission details not found.", false);
                    btnApproveWork.Enabled = false;
                    return;
                }

                lblProjectTitle.Text = Convert.ToString(row["title"]);
                lblProjectBudget.Text = "R" + Convert.ToDecimal(row["budget"]).ToString("N2");
                lblFreelancerName.Text = Convert.ToString(row["freelancerName"]);
                lblSubmissionContent.Text = row["submissionContent"] != DBNull.Value
                    ? Convert.ToString(row["submissionContent"])
                    : "No submission notes provided.";

                ViewState["FreelancerUserID"] = Convert.ToInt32(row["freelancerUserID"]);
                ViewState["ProjectBudget"] = Convert.ToDecimal(row["budget"]);

                string status = Convert.ToString(row["projectStatus"]);
                if (status == "Completed")
                {
                    ShowStatus("This project has already been approved and completed.", true);
                    btnApproveWork.Enabled = false;
                    btnRequestRevision.Enabled = false;
                    pnlRating.Visible = false;
                }
            }
            catch (Exception ex)
            {
                ShowStatus("Error loading review details: " + ex.Message, false);
            }
        }

        protected void btnApproveWork_Click(object sender, EventArgs e)
        {
            int employerUserId = AuthHelper.GetCurrentUserId(this);
            int freelancerUserId = ViewState["FreelancerUserID"] != null ? Convert.ToInt32(ViewState["FreelancerUserID"]) : 0;
            decimal grossBudget = ViewState["ProjectBudget"] != null ? Convert.ToDecimal(ViewState["ProjectBudget"]) : 0;

            if (freelancerUserId == 0 || grossBudget <= 0)
            {
                ShowStatus("Invalid project or freelancer parameters.", false);
                return;
            }

            try
            {
                // 1. Calculate 10% Platform Commission Split
                decimal commissionRate = 0.10m; // 10%
                decimal commissionFee = Math.Round(grossBudget * commissionRate, 2);
                decimal netPayout = grossBudget - commissionFee;

                // 2. Mark Project as Completed
                string updateProjectQuery = "UPDATE dbo.Project SET projectStatus = 'Completed' WHERE projectID = @ProjectID";
                DatabaseHelper.ExecuteNonQuery(updateProjectQuery, new SqlParameter("@ProjectID", ProjectId));

                // 3. Deposit Net Amount (90%) into Freelancer's Wallet
                DataRow freelancerWallet = DatabaseHelper.GetWalletByUserId(freelancerUserId);
                if (freelancerWallet != null)
                {
                    int walletId = Convert.ToInt32(freelancerWallet["walletID"]);
                    decimal currentBalance = Convert.ToDecimal(freelancerWallet["balance"]);
                    decimal newBalance = currentBalance + netPayout;

                    // Update balance with NET payout
                    DatabaseHelper.UpdateWalletBalance(walletId, newBalance);

                    // Record Freelancer Credit Transaction (90%)
                    string freelancerRef = TransactionStore.CreateReference("PAY");
                    string payoutDescription = string.Format("Payout received for '{0}' (Gross: R{1:N2}, 10% Fee: -R{2:N2})",
                        lblProjectTitle.Text, grossBudget, commissionFee);

                    DatabaseHelper.AddTransaction(
                        walletId,
                        payoutDescription,
                        "Credit",
                        netPayout,
                        "Completed",
                        freelancerRef,
                        "Escrow Release");
                }

                // 4. Release Employer's Escrow Hold
                // Find the employer's wallet and mark escrow as released
                DataRow project = DatabaseHelper.GetProjectById(ProjectId);
                if (project != null)
                {
                    int empId = Convert.ToInt32(project["employerID"]);
                    string getEmpUserQuery = "SELECT userID FROM Employer WHERE employerID = @EmpID";
                    object empUserResult = DatabaseHelper.ExecuteScalar(getEmpUserQuery,
                        new SqlParameter("@EmpID", empId));

                    if (empUserResult != null && empUserResult != DBNull.Value)
                    {
                        int empUserId = Convert.ToInt32(empUserResult);
                        DataRow empWallet = DatabaseHelper.GetWalletByUserId(empUserId);
                        if (empWallet != null)
                        {
                            int empWalletId = Convert.ToInt32(empWallet["walletID"]);

                            // Mark the escrow transaction as Released
                            string releaseEscrowQuery = @"
                                UPDATE [Transaction]
                                SET transactionStatus = 'Released'
                                WHERE walletID = @WalletID
                                  AND transactionType = 'Escrow'
                                  AND transactionStatus = 'Held'
                                  AND paymentMethod LIKE '%Project #' + CAST(@ProjectID AS VARCHAR) + '%'";

                            DatabaseHelper.ExecuteNonQuery(releaseEscrowQuery,
                                new SqlParameter("@WalletID", empWalletId),
                                new SqlParameter("@ProjectID", ProjectId));
                        }
                    }
                }

                // 5. Record Admin / System Commission Entry (10%)
                DataRow adminWallet = DatabaseHelper.GetWalletByUserId(1); // Admin UserID = 1
                if (adminWallet != null)
                {
                    int adminWalletId = Convert.ToInt32(adminWallet["walletID"]);
                    decimal adminBalance = Convert.ToDecimal(adminWallet["balance"]);
                    decimal newAdminBalance = adminBalance + commissionFee;

                    DatabaseHelper.UpdateWalletBalance(adminWalletId, newAdminBalance);

                    string commissionRef = TransactionStore.CreateReference("FEE");
                    string feeDescription = string.Format("10% Platform Commission from Project #{0}: '{1}'", ProjectId, lblProjectTitle.Text);

                    DatabaseHelper.AddTransaction(
                        adminWalletId,
                        feeDescription,
                        "Credit",
                        commissionFee,
                        "Completed",
                        commissionRef,
                        "Platform Fee");
                }

                // 6. Save Rating for Freelancer
                int score = Convert.ToInt32(ddlRatingScore.SelectedValue);
                string comment = txtRatingComment.Text.Trim();

                string ratingQuery = @"
            INSERT INTO dbo.Rating (projectID, raterUserID, ratedUserID, score, ratingComment, ratingDate)
            VALUES (@ProjectID, @RaterID, @RatedID, @Score, @Comment, GETDATE())";

                DatabaseHelper.ExecuteNonQuery(ratingQuery,
                    new SqlParameter("@ProjectID", ProjectId),
                    new SqlParameter("@RaterID", employerUserId),
                    new SqlParameter("@RatedID", freelancerUserId),
                    new SqlParameter("@Score", score),
                    new SqlParameter("@Comment", string.IsNullOrEmpty(comment) ? (object)DBNull.Value : comment));

                // Recalculate average rating
                string updateAvgRatingQuery = @"
            UPDATE dbo.[User]
            SET ratingScore = (SELECT AVG(CAST(score AS DECIMAL(3,2))) FROM dbo.Rating WHERE ratedUserID = @FreelancerUserID)
            WHERE userID = @FreelancerUserID";
                DatabaseHelper.ExecuteNonQuery(updateAvgRatingQuery, new SqlParameter("@FreelancerUserID", freelancerUserId));

                // 6. Notify Freelancer
                string notificationText = string.Format(
                    "Your work for '{0}' was approved! R{1:N2} has been added to your wallet (R{2:N2} gross minus R{3:N2} platform fee).",
                    lblProjectTitle.Text, netPayout, grossBudget, commissionFee);

                NotificationHelper.CreateNotification(freelancerUserId, "Payment", notificationText);

                ShowStatus(string.Format("Project completed! R{0:N2} released to freelancer. Platform fee collected: R{1:N2}.", netPayout, commissionFee), true);
                btnApproveWork.Enabled = false;
                btnRequestRevision.Enabled = false;
                pnlRating.Visible = false;
            }
            catch (Exception ex)
            {
                ShowStatus("Error completing project: " + ex.Message, false);
            }
        }
        protected void btnRequestRevision_Click(object sender, EventArgs e)
        {
            try
            {
                // Set status back to 'In Progress' for revisions
                string query = "UPDATE dbo.Project SET projectStatus = 'In Progress' WHERE projectID = @ProjectID";
                DatabaseHelper.ExecuteNonQuery(query, new SqlParameter("@ProjectID", ProjectId));

                int freelancerUserId = Convert.ToInt32(ViewState["FreelancerUserID"]);
                string notificationText = string.Format("The employer has requested revisions on project '{0}'. Please check your messages.", lblProjectTitle.Text);
                NotificationHelper.CreateNotification(freelancerUserId, "Project", notificationText);

                ShowStatus("Revision request sent to the freelancer.", true);
                btnApproveWork.Enabled = false;
            }
            catch (Exception ex)
            {
                ShowStatus("Error requesting revision: " + ex.Message, false);
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("MyProjects.aspx");
        }

        private void ShowStatus(string message, bool success)
        {
            pnlStatus.Visible = true;
            lblStatus.Text = message;
            pnlStatus.BackColor = success ? System.Drawing.Color.FromArgb(234, 247, 237) : System.Drawing.Color.FromArgb(254, 226, 226);
            lblStatus.ForeColor = success ? System.Drawing.Color.FromArgb(39, 103, 56) : System.Drawing.Color.FromArgb(153, 27, 27);
        }
    }
}
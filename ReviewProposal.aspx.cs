using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class ReviewProposal : System.Web.UI.Page
    {
        private int ProposalId
        {
            get
            {
                int id = 0;
                int.TryParse(Request.QueryString["id"], out id);
                return id;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Freelancers can view their own proposals (read-only), Employers can approve/reject
            string userType = Session["UserType"] as string ?? "";
            bool isFreelancer = userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase);

            if (!IsPostBack)
            {
                pnlMessage.Visible = false;
                // Hide ALL action buttons for freelancers (read-only view)
                if (isFreelancer)
                {
                    pnlActions.Visible = false;
                }
                LoadProposal();
            }
        }

        private void LoadProposal()
        {
            if (ProposalId <= 0)
            {
                ShowMessage("No proposal selected.", false);
                pnlActions.Visible = false;
                return;
            }

            try
            {
                string query = @"SELECT pr.proposalID, pr.coverLetter, pr.proposedRate,
                                pr.estimatedCompletionTime, pr.status, pr.date,
                                u.firstName + ' ' + u.lastName AS freelancerName,
                                p.title AS projectTitle
                                FROM Proposal pr
                                INNER JOIN Freelancer f ON pr.freelancerID = f.freelancerID
                                INNER JOIN [User] u ON f.userID = u.userID
                                INNER JOIN Project p ON pr.projectID = p.projectID
                                WHERE pr.proposalID = @ProposalID";

                DataTable result = DatabaseHelper.ExecuteQuery(query,
                    new SqlParameter("@ProposalID", ProposalId));

                if (result.Rows.Count == 0)
                {
                    ShowMessage("Proposal not found.", false);
                    pnlActions.Visible = false;
                    return;
                }

                DataRow proposal = result.Rows[0];

                string freelancerName = Convert.ToString(proposal["freelancerName"]);
                lblFreelancerName.Text = freelancerName;
                lblFreelancerInitials.Text = GetInitials(freelancerName);
                lblProjectTitle.Text = Convert.ToString(proposal["projectTitle"]);
                lblRate.Text = "R" + Convert.ToDecimal(proposal["proposedRate"]).ToString("N0");
                lblTime.Text = Convert.ToString(proposal["estimatedCompletionTime"]);
                lblDate.Text = Convert.ToDateTime(proposal["date"]).ToString("dd MMM yyyy");
                lblCoverLetter.Text = Convert.ToString(proposal["coverLetter"]);
                lblStatus.Text = Convert.ToString(proposal["status"]);

                // Hide action buttons if already approved/rejected
                string status = Convert.ToString(proposal["status"]);
                if (status != "Pending")
                {
                    btnApproveProposal.Visible = false;
                    btnRejectProposal.Visible = false;
                }
                else
                {
                    WarnIfInsufficientFunds();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading proposal: " + ex.Message, false);
            }
        }

        // Warns the employer upfront and disables approval when the proposed rate
        // exceeds what their wallet can cover, so they aren't left guessing.
        private void WarnIfInsufficientFunds()
        {
            string userType = Session["UserType"] as string ?? "";
            if (!userType.Equals("Employer", StringComparison.OrdinalIgnoreCase))
                return;

            DataRow details = GetProposalFinancials();
            if (details == null) return;

            decimal proposedRate = 0m;
            if (details["proposedRate"] != DBNull.Value)
                proposedRate = Convert.ToDecimal(details["proposedRate"]);

            decimal projectBudget = 0m;
            if (details["projectBudget"] != DBNull.Value)
                projectBudget = Convert.ToDecimal(details["projectBudget"]);

            decimal availableBalance = 0m;
            DataRow wallet = DatabaseHelper.GetWalletByUserId(
                Convert.ToInt32(details["employerUserID"]));
            if (wallet != null && wallet["balance"] != DBNull.Value)
                availableBalance = Convert.ToDecimal(wallet["balance"]);

            decimal additionalRequired = proposedRate - projectBudget;
            if (additionalRequired < 0m) additionalRequired = 0m;

            if (additionalRequired > availableBalance)
            {
                ShowMessage(
                    "This proposal cannot be approved. The proposed rate of R" +
                    proposedRate.ToString("N2") + " exceeds your available funds. " +
                    "R" + projectBudget.ToString("N2") + " is already held in escrow for this project, " +
                    "so an additional R" + additionalRequired.ToString("N2") +
                    " is required but your wallet balance is only R" +
                    availableBalance.ToString("N2") + ". Please fund your wallet to approve it.",
                    false);
                btnApproveProposal.Enabled = false;
            }
        }

        // Fetches the financial context for this proposal: the freelancer's proposed
        // rate, the project budget already held in escrow, and the owning employer.
        private DataRow GetProposalFinancials()
        {
            string query = @"SELECT prop.proposalID, prop.proposedRate,
                                    p.projectID, p.title AS projectTitle,
                                    p.budget AS projectBudget,
                                    e.userID AS employerUserID
                             FROM Proposal prop
                             INNER JOIN Project p ON prop.projectID = p.projectID
                             INNER JOIN Employer e ON p.employerID = e.employerID
                             WHERE prop.proposalID = @ProposalID";

            return DatabaseHelper.GetDataRow(query,
                new SqlParameter("@ProposalID", ProposalId));
        }

        protected void btnApproveProposal_Click(object sender, EventArgs e)
        {
            try
            {
                DataRow details = GetProposalFinancials();
                if (details == null)
                {
                    ShowMessage("Proposal not found. It may have been removed.", false);
                    return;
                }

                int employerUserId = Convert.ToInt32(details["employerUserID"]);
                int projectId = Convert.ToInt32(details["projectID"]);
                string projectTitle = Convert.ToString(details["projectTitle"]);

                decimal proposedRate = 0m;
                if (details["proposedRate"] != DBNull.Value)
                    proposedRate = Convert.ToDecimal(details["proposedRate"]);

                decimal projectBudget = 0m;
                if (details["projectBudget"] != DBNull.Value)
                    projectBudget = Convert.ToDecimal(details["projectBudget"]);

                // Look up the employer's wallet. The project budget was already held in
                // escrow when the project was posted, so only the shortfall above that
                // still needs to be covered by the available balance.
                int walletID = 0;
                decimal availableBalance = 0m;
                DataRow wallet = DatabaseHelper.GetWalletByUserId(employerUserId);
                if (wallet != null)
                {
                    walletID = Convert.ToInt32(wallet["walletID"]);
                    if (wallet["balance"] != DBNull.Value)
                        availableBalance = Convert.ToDecimal(wallet["balance"]);
                }

                if (walletID == 0)
                {
                    ShowMessage("No wallet was found for your account. Cannot approve this proposal.", false);
                    return;
                }

                decimal additionalRequired = proposedRate - projectBudget;
                if (additionalRequired < 0m) additionalRequired = 0m;

                // Block approval when the proposed rate cannot be covered.
                if (additionalRequired > availableBalance)
                {
                    ShowMessage(
                        "Cannot approve this proposal. The freelancer proposed R" +
                        proposedRate.ToString("N2") + ", which is more than you can cover. " +
                        "R" + projectBudget.ToString("N2") + " is already held in escrow for this project, " +
                        "so an additional R" + additionalRequired.ToString("N2") +
                        " is required but your available wallet balance is only R" +
                        availableBalance.ToString("N2") + ". Please fund your wallet before approving.",
                        false);
                    return;
                }

                // Hold any amount above the original budget in escrow.
                if (additionalRequired > 0m)
                {
                    decimal newBalance = availableBalance - additionalRequired;
                    DatabaseHelper.UpdateWalletBalance(walletID, newBalance);

                    string escrowReference = TransactionStore.CreateReference("ESCROW");
                    DatabaseHelper.AddTransaction(
                        walletID,
                        "Additional funds held in escrow for approved proposal on project: " +
                            projectTitle + " (Project ID: " + projectId + ")",
                        "Escrow",
                        additionalRequired,
                        "Held",
                        escrowReference,
                        "Wallet");

                    Session["AvailableBalance"] = newBalance;
                }

                string query = @"UPDATE Proposal SET status = 'Approved' WHERE proposalID = @ID;
                                UPDATE Project SET projectStatus = 'In Progress'
                                WHERE projectID = (SELECT projectID FROM Proposal WHERE proposalID = @ID)";
                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@ID", ProposalId));

                string successMessage =
                    "Proposal approved! The project is now In Progress and the freelancer has been assigned.";
                if (additionalRequired > 0m)
                {
                    successMessage += " An additional R" + additionalRequired.ToString("N2") +
                        " has been removed from your wallet and held in escrow to cover the proposed rate.";
                }

                ShowMessage(successMessage, true);
                btnApproveProposal.Visible = false;
                btnRejectProposal.Visible = false;
                lblStatus.Text = "Approved";
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void btnRejectProposal_Click(object sender, EventArgs e)
        {
            try
            {
                string query = "UPDATE Proposal SET status = 'Rejected' WHERE proposalID = @ID";
                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@ID", ProposalId));

                ShowMessage("Proposal rejected. The freelancer has been notified.", true);
                btnApproveProposal.Visible = false;
                btnRejectProposal.Visible = false;
                lblStatus.Text = "Rejected";
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void btnRequestChanges_Click(object sender, EventArgs e)
        {
            ShowMessage("Change request noted. Please contact the freelancer to discuss the required changes.", true);
        }

        private string GetInitials(string name)
        {
            string initials = "";
            string[] parts = name.Split(' ');
            foreach (string part in parts)
            {
                if (part.Length > 0) initials += part[0];
            }
            return initials.ToUpper();
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            lblReviewMessage.Text = message;
            pnlMessage.CssClass = success ? "post-status post-success" : "post-status post-error";
        }
    }
}

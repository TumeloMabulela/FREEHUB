// ============================================================
// B700 - Review Proposal (Tumelo London Mabulela)
// FILE: ReviewProposal.aspx.cs
//
// PURPOSE: Allows an employer to read a proposal in full and
// decide to Approve or Reject it. Freelancers can also view
// this page in read-only mode to check their proposal status.
// Includes a pre-approval wallet balance check.
// ============================================================

using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class ReviewProposal : System.Web.UI.Page
    {
        // ============================================================
        // ProposalId (property)
        // Reads the proposal ID from the URL query string.
        // e.g. ReviewProposal.aspx?id=5 -> returns 5
        // Returns 0 if no valid ID is found.
        // ============================================================
        private int ProposalId
        {
            get
            {
                int id = 0;
                int.TryParse(Request.QueryString["id"], out id);
                return id;
            }
        }

        // ============================================================
        // PAGE LOAD
        // 1. Checks user is logged in
        // 2. Checks user role:
        //    - Freelancer gets READ-ONLY view (action buttons hidden)
        //    - Employer gets full Approve/Reject controls
        // 3. Calls LoadProposal() to fill in the proposal details
        // ============================================================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            string userType = Session["UserType"] as string ?? "";
            bool isFreelancer = userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase);

            if (!IsPostBack)
            {
                pnlMessage.Visible = false;

                // Freelancers can only VIEW - hide approve/reject buttons
                if (isFreelancer)
                {
                    pnlActions.Visible = false;
                }
                LoadProposal();
            }
        }

        // ============================================================
        // LoadProposal()
        // Fetches the full proposal from the database using ProposalId.
        // Joins Proposal + Freelancer + User + Project tables to get
        // all the info needed to display the review screen.
        // Also hides action buttons if proposal is already decided,
        // and calls WarnIfInsufficientFunds() for pending proposals.
        // ============================================================
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
                // Join across 4 tables to get all required proposal details
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

                // Fill in all the display labels
                string freelancerName = Convert.ToString(proposal["freelancerName"]);
                lblFreelancerName.Text = freelancerName;
                lblFreelancerInitials.Text = GetInitials(freelancerName); // e.g. "TM"
                lblProjectTitle.Text = TitleHelper.TitleCase(Convert.ToString(proposal["projectTitle"]));
                lblRate.Text = "R" + Convert.ToDecimal(proposal["proposedRate"]).ToString("N0");
                lblTime.Text = Convert.ToString(proposal["estimatedCompletionTime"]);
                lblDate.Text = Convert.ToDateTime(proposal["date"]).ToString("dd MMM yyyy");

                // HTML-encode the cover letter to prevent XSS attacks
                lblCoverLetter.Text = Server.HtmlEncode(Convert.ToString(proposal["coverLetter"]));
                lblStatus.Text = Convert.ToString(proposal["status"]);

                // If proposal is already decided, hide the action buttons
                string status = Convert.ToString(proposal["status"]);
                if (status != "Pending")
                {
                    btnApproveProposal.Visible = false;
                    btnRejectProposal.Visible = false;
                }
                else
                {
                    // Still pending - check if employer can afford to approve
                    WarnIfInsufficientFunds();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading proposal: " + ex.Message, false);
            }
        }

        // ============================================================
        // WarnIfInsufficientFunds()
        // Called BEFORE the employer tries to approve.
        // Checks if employer's wallet balance can cover the difference
        // between the proposed rate and the project budget already
        // held in escrow. If not enough funds:
        // - Shows a warning message to the employer
        // - Disables the Approve button so they can't proceed
        // ============================================================
        private void WarnIfInsufficientFunds()
        {
            string userType = Session["UserType"] as string ?? "";
            // Only run this check for employers
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

            // Get employer's current wallet balance
            decimal availableBalance = 0m;
            DataRow wallet = DatabaseHelper.GetWalletByUserId(
                Convert.ToInt32(details["employerUserID"]));
            if (wallet != null && wallet["balance"] != DBNull.Value)
                availableBalance = Convert.ToDecimal(wallet["balance"]);

            // Calculate how much MORE is needed above what's already in escrow
            decimal additionalRequired = proposedRate - projectBudget;
            if (additionalRequired < 0m) additionalRequired = 0m;

            if (additionalRequired > availableBalance)
            {
                // Not enough funds - warn and disable approve button
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

        // ============================================================
        // GetProposalFinancials()
        // Helper method that fetches the financial details needed
        // for the approval check: proposed rate, project budget,
        // project ID, and employer's user ID.
        // Used by both WarnIfInsufficientFunds() and btnApproveProposal_Click().
        // ============================================================
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

        // ============================================================
        // btnApproveProposal_Click() - B800 APPROVE PROPOSAL
        // Full approval sequence:
        // 1. Get proposal financial details
        // 2. Check employer's wallet balance
        // 3. Calculate shortfall (proposedRate - projectBudget)
        // 4. Block if insufficient funds
        // 5. Deduct shortfall from wallet and record escrow transaction
        // 6. Update Proposal status -> Approved
        // 7. Update Project status -> In Progress
        // 8. Open chat session between employer and freelancer
        // 9. Show success message, hide action buttons
        // ============================================================
        protected void btnApproveProposal_Click(object sender, EventArgs e)
        {
            try
            {
                // Get all financial context for this proposal
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

                // Get employer's wallet
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

                // How much extra is needed beyond the already-held project budget?
                decimal additionalRequired = proposedRate - projectBudget;
                if (additionalRequired < 0m) additionalRequired = 0m;

                // BLOCK if employer can't cover the shortfall
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

                // Deduct the additional amount from wallet and hold in escrow
                if (additionalRequired > 0m)
                {
                    decimal newBalance = availableBalance - additionalRequired;
                    DatabaseHelper.UpdateWalletBalance(walletID, newBalance);

                    // Record the escrow transaction in Transaction table
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

                    // Sync the session balance so dashboard shows correct amount
                    Session["AvailableBalance"] = newBalance;
                }

                // Update Proposal status to Approved AND Project status to In Progress
                string query = @"UPDATE Proposal SET status = 'Approved' WHERE proposalID = @ID;
                                UPDATE Project SET projectStatus = 'In Progress'
                                WHERE projectID = (SELECT projectID FROM Proposal WHERE proposalID = @ID)";
                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@ID", ProposalId));

                // Open or reopen the chat session between employer and freelancer
                ChatLifecycle.OnProposalApproved(projectId, employerUserId, projectTitle);

                // Build success message
                string successMessage =
                    "Proposal approved! The project is now In Progress and the freelancer has been assigned.";
                if (additionalRequired > 0m)
                {
                    successMessage += " An additional R" + additionalRequired.ToString("N2") +
                        " has been removed from your wallet and held in escrow to cover the proposed rate.";
                }

                ShowMessage(successMessage, true);

                // Hide buttons - decision is final
                btnApproveProposal.Visible = false;
                btnRejectProposal.Visible = false;
                lblStatus.Text = "Approved";
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        // ============================================================
        // btnRejectProposal_Click() - also used for B900
        // Quick reject directly from the Review screen.
        // Updates the Proposal status to 'Rejected' in the database.
        // Hides the action buttons after decision is made.
        // ============================================================
        protected void btnRejectProposal_Click(object sender, EventArgs e)
        {
            try
            {
                // Update Proposal status to Rejected
                string query = "UPDATE Proposal SET status = 'Rejected' WHERE proposalID = @ID";
                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@ID", ProposalId));

                ShowMessage("Proposal rejected. The freelancer has been notified.", true);

                // Hide buttons - decision is final
                btnApproveProposal.Visible = false;
                btnRejectProposal.Visible = false;
                lblStatus.Text = "Rejected";
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        // Placeholder for future "Request Changes" feature
        protected void btnRequestChanges_Click(object sender, EventArgs e)
        {
            ShowMessage("Change request noted. Please contact the freelancer to discuss the required changes.", true);
        }

        // ============================================================
        // GetInitials(string name)
        // Builds initials from a full name.
        // e.g. "John Smith" -> "JS"
        // e.g. "Thabo Mokoena" -> "TM"
        // ============================================================
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
            if (success) MessageHelper.Success(this, message);
            else MessageHelper.Error(this, message);
        }
    }
}

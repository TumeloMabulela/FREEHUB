// ============================================================
// B700 - Review Proposal / B800 - Approve Proposal
// FILE: ReviewProposal.aspx.cs (Tumelo London Mabulela)
// PURPOSE: Employer reads a proposal in full and can approve
// or reject it. Freelancers see a read-only view.
// ============================================================

using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class ReviewProposal : System.Web.UI.Page
    {
        // Reads the proposal ID from the URL e.g. ?id=5 -> returns 5
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
            // IF no user is logged in, redirect to login page
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            string userType = Session["UserType"] as string ?? "";
            bool isFreelancer = userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase);

            // IF this is the first load (not a button click postback)
            if (!IsPostBack)
            {
                pnlMessage.Visible = false;

                // IF the logged-in user is a Freelancer, hide the action buttons
                // Freelancers can only READ their proposal, not act on it
                if (isFreelancer)
                {
                    pnlActions.Visible = false;
                }

                LoadProposal();
            }
        }

        private void LoadProposal()
        {
            // IF no valid proposal ID was found in the URL, show an error
            if (ProposalId <= 0)
            {
                ShowMessage("No proposal selected.", false);
                pnlActions.Visible = false;
                return;
            }

            try
            {
                // Query joins Proposal + Freelancer + User + Project to get all details
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

                // IF no rows returned, the proposal doesn't exist
                if (result.Rows.Count == 0)
                {
                    ShowMessage("Proposal not found.", false);
                    pnlActions.Visible = false;
                    return;
                }

                DataRow proposal = result.Rows[0];

                // Fill in all the display labels with the proposal data
                string freelancerName = Convert.ToString(proposal["freelancerName"]);
                lblFreelancerName.Text = freelancerName;
                lblFreelancerInitials.Text = GetInitials(freelancerName);
                lblProjectTitle.Text = TitleHelper.TitleCase(Convert.ToString(proposal["projectTitle"]));
                lblRate.Text = "R" + Convert.ToDecimal(proposal["proposedRate"]).ToString("N0");
                lblTime.Text = Convert.ToString(proposal["estimatedCompletionTime"]);
                lblDate.Text = Convert.ToDateTime(proposal["date"]).ToString("dd MMM yyyy");

                // HTML-encode the cover letter to prevent XSS (script injection attacks)
                lblCoverLetter.Text = Server.HtmlEncode(Convert.ToString(proposal["coverLetter"]));
                lblStatus.Text = Convert.ToString(proposal["status"]);

                string status = Convert.ToString(proposal["status"]);

                // IF the proposal is already Approved or Rejected, hide the action buttons
                // because the decision has already been made and cannot be changed
                if (status != "Pending")
                {
                    btnApproveProposal.Visible = false;
                    btnRejectProposal.Visible = false;
                }
                else
                {
                    // IF the proposal is still Pending, check if employer can afford to approve
                    WarnIfInsufficientFunds();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading proposal: " + ex.Message, false);
            }
        }

        private void WarnIfInsufficientFunds()
        {
            string userType = Session["UserType"] as string ?? "";

            // IF the current user is not an employer, skip this check
            // (freelancers viewing their own proposal don't need the wallet check)
            if (!userType.Equals("Employer", StringComparison.OrdinalIgnoreCase))
                return;

            DataRow details = GetProposalFinancials();

            // IF financial details could not be retrieved, skip the check
            if (details == null) return;

            decimal proposedRate = 0m;
            // IF the proposed rate column has a value (not null), read it
            if (details["proposedRate"] != DBNull.Value)
                proposedRate = Convert.ToDecimal(details["proposedRate"]);

            decimal projectBudget = 0m;
            // IF the project budget column has a value, read it
            if (details["projectBudget"] != DBNull.Value)
                projectBudget = Convert.ToDecimal(details["projectBudget"]);

            decimal availableBalance = 0m;
            DataRow wallet = DatabaseHelper.GetWalletByUserId(
                Convert.ToInt32(details["employerUserID"]));

            // IF the wallet was found and has a balance value, read it
            if (wallet != null && wallet["balance"] != DBNull.Value)
                availableBalance = Convert.ToDecimal(wallet["balance"]);

            // Calculate how much MORE is needed beyond what's already held in escrow
            decimal additionalRequired = proposedRate - projectBudget;

            // IF the additional amount is negative (budget covers the rate), set it to zero
            if (additionalRequired < 0m) additionalRequired = 0m;

            // IF the employer cannot cover the additional amount, warn them and disable approve
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

                // Disable the approve button so they cannot proceed without funding
                btnApproveProposal.Enabled = false;
            }
        }

        private DataRow GetProposalFinancials()
        {
            // Returns: proposed rate, project budget already in escrow, project ID, employer user ID
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

                // IF the proposal details could not be found (deleted/removed)
                if (details == null)
                {
                    ShowMessage("Proposal not found. It may have been removed.", false);
                    return;
                }

                int employerUserId = Convert.ToInt32(details["employerUserID"]);
                int projectId = Convert.ToInt32(details["projectID"]);
                string projectTitle = Convert.ToString(details["projectTitle"]);

                decimal proposedRate = 0m;
                // IF proposed rate is not null, read it
                if (details["proposedRate"] != DBNull.Value)
                    proposedRate = Convert.ToDecimal(details["proposedRate"]);

                decimal projectBudget = 0m;
                // IF project budget is not null, read it
                if (details["projectBudget"] != DBNull.Value)
                    projectBudget = Convert.ToDecimal(details["projectBudget"]);

                // Get the employer's wallet details
                int walletID = 0;
                decimal availableBalance = 0m;
                DataRow wallet = DatabaseHelper.GetWalletByUserId(employerUserId);

                // IF a wallet record was found for this employer
                if (wallet != null)
                {
                    walletID = Convert.ToInt32(wallet["walletID"]);
                    // IF the balance column is not null, read it
                    if (wallet["balance"] != DBNull.Value)
                        availableBalance = Convert.ToDecimal(wallet["balance"]);
                }

                // IF no wallet was found at all, block the approval
                if (walletID == 0)
                {
                    ShowMessage("No wallet was found for your account. Cannot approve this proposal.", false);
                    return;
                }

                // Calculate additional funds needed (beyond what's already in escrow)
                decimal additionalRequired = proposedRate - projectBudget;

                // IF the difference is negative (proposed rate is less than budget), set it to zero
                if (additionalRequired < 0m) additionalRequired = 0m;

                // IF the employer does not have enough money to cover the shortfall, block approval
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

                // IF there is an additional amount to hold in escrow (rate > original budget)
                if (additionalRequired > 0m)
                {
                    decimal newBalance = availableBalance - additionalRequired;

                    // Deduct from wallet in the database
                    DatabaseHelper.UpdateWalletBalance(walletID, newBalance);

                    // Record the escrow transaction in the Transaction table
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

                    // Sync session balance so the dashboard shows the correct amount
                    Session["AvailableBalance"] = newBalance;
                }

                // Update Proposal status to Approved AND Project status to In Progress
                string query = @"UPDATE Proposal SET status = 'Approved' WHERE proposalID = @ID;
                                UPDATE Project SET projectStatus = 'In Progress'
                                WHERE projectID = (SELECT projectID FROM Proposal WHERE proposalID = @ID)";
                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@ID", ProposalId));

                // Open a chat session between the employer and freelancer for this project
                ChatLifecycle.OnProposalApproved(projectId, employerUserId, projectTitle);

                // Build success message - include escrow info IF additional funds were taken
                string successMessage =
                    "Proposal approved! The project is now In Progress and the freelancer has been assigned.";

                // IF extra funds were deducted, add that detail to the success message
                if (additionalRequired > 0m)
                {
                    successMessage += " An additional R" + additionalRequired.ToString("N2") +
                        " has been removed from your wallet and held in escrow to cover the proposed rate.";
                }

                ShowMessage(successMessage, true);

                // Hide the action buttons since the decision is now final
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
                // Update the proposal status to Rejected in the database
                string query = "UPDATE Proposal SET status = 'Rejected' WHERE proposalID = @ID";
                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@ID", ProposalId));

                ShowMessage("Proposal rejected. The freelancer has been notified.", true);

                // Hide action buttons - decision is final
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
                // IF this word has at least one character, take the first letter
                if (part.Length > 0) initials += part[0];
            }
            return initials.ToUpper();
        }

        private void ShowMessage(string message, bool success)
        {
            // IF success is true show green, IF false show red
            if (success) MessageHelper.Success(this, message);
            else MessageHelper.Error(this, message);
        }
    }
}

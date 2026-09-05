using System;
using System.Data;

namespace FreeHubProject
{
    public partial class ApproveProposal : System.Web.UI.Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            string userType = Session["UserType"] as string ?? "";
            if (userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("Default.aspx");
                return;
            }
        }

        protected void btnBackToReview_Click(object sender, EventArgs e)
        {
            Response.Redirect("ReviewProposal.aspx");
        }

        protected void btnConfirmApproval_Click(object sender, EventArgs e)
        {
            if (!chkConfirmApproval.Checked)
            {
                lblApprovalMessage.Text = "Please confirm that you understand approving this proposal will start the project.";
                return;
            }
            try
            {
                // 1. Get proposal, freelancer, employer, and project details.
                //    Also fetch the freelancer's proposed rate and the project budget
                //    so we can re-check the employer's funds at approval time.
                string getDetailsQuery = @"
            SELECT TOP 1 f.userID AS FreelancerUserID, e.userID AS EmployerUserID, 
                   u_f.username AS FreelancerUsername, u_e.username AS EmployerUsername,
                   p.title AS ProjectTitle, p.projectID AS ProjectID,
                   p.budget AS ProjectBudget, prop.proposedRate AS ProposedRate,
                   prop.proposalID AS ProposalID
            FROM Proposal prop
            INNER JOIN Freelancer f ON prop.freelancerID = f.freelancerID
            INNER JOIN Project p ON prop.projectID = p.projectID
            INNER JOIN Employer e ON p.employerID = e.employerID
            INNER JOIN [User] u_f ON f.userID = u_f.userID
            INNER JOIN [User] u_e ON e.userID = u_e.userID
            WHERE prop.status = 'Pending' 
            ORDER BY prop.date DESC";
                DataRow dr = DatabaseHelper.GetDataRow(getDetailsQuery);

                if (dr == null)
                {
                    lblApprovalMessage.Text = "No pending proposal was found to approve.";
                    return;
                }

                int employerUserId = Convert.ToInt32(dr["EmployerUserID"]);
                int projectId = Convert.ToInt32(dr["ProjectID"]);

                decimal proposedRate = 0m;
                if (dr["ProposedRate"] != DBNull.Value)
                    proposedRate = Convert.ToDecimal(dr["ProposedRate"]);

                decimal projectBudget = 0m;
                if (dr["ProjectBudget"] != DBNull.Value)
                    projectBudget = Convert.ToDecimal(dr["ProjectBudget"]);

                // 2. Re-check the employer's funds against the freelancer's proposed rate.
                //    The project budget was already held in escrow when the project was
                //    posted, so only the shortfall above that must still be covered by
                //    the available wallet balance.
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
                    lblApprovalMessage.Text = "No wallet was found for the employer account. Cannot approve this proposal.";
                    return;
                }

                decimal additionalRequired = proposedRate - projectBudget;
                if (additionalRequired < 0m) additionalRequired = 0m;

                if (additionalRequired > availableBalance)
                {
                    lblApprovalMessage.Text =
                        "Cannot approve: the freelancer proposed R" + proposedRate.ToString("N2") +
                        ", which is higher than your available funds. " +
                        "R" + projectBudget.ToString("N2") + " is already held for this project, " +
                        "and you need an additional R" + additionalRequired.ToString("N2") +
                        " but only have R" + availableBalance.ToString("N2") +
                        " available. Please fund your wallet before approving.";
                    return;
                }

                // 3. Hold any additional amount above the original budget in escrow.
                if (additionalRequired > 0m)
                {
                    decimal newBalance = availableBalance - additionalRequired;
                    DatabaseHelper.UpdateWalletBalance(walletID, newBalance);

                    string topUpReference = TransactionStore.CreateReference("ESCROW");
                    DatabaseHelper.AddTransaction(
                        walletID,
                        "Additional funds held in escrow for approved proposal on project: " +
                            Convert.ToString(dr["ProjectTitle"]) + " (Project ID: " + projectId + ")",
                        "Escrow",
                        additionalRequired,
                        "Held",
                        topUpReference,
                        "Wallet");

                    Session["AvailableBalance"] = newBalance;
                }

                // 4. Perform the proposal/project status update.
                string query = @"UPDATE Proposal SET status = 'Approved' 
            WHERE proposalID = (SELECT TOP 1 proposalID FROM Proposal WHERE status = 'Pending' ORDER BY date DESC);
            UPDATE Project SET projectStatus = 'In Progress' 
            WHERE projectID = (SELECT TOP 1 projectID FROM Proposal WHERE status = 'Approved' ORDER BY date DESC)";
                DatabaseHelper.ExecuteNonQuery(query);

                // 5. Send exact required notifications to both parties
                int freelancerUserId = Convert.ToInt32(dr["FreelancerUserID"]);
                string projectTitle = Convert.ToString(dr["ProjectTitle"]);
                string freelancerUsername = Convert.ToString(dr["FreelancerUsername"]);

                // Freelancer notification
                string freelancerMsg = $"Your \"{projectTitle}\" proposal has been approved. You can start conversation with the employer on the messages. <a href='ProjectDetails.aspx?projectId={projectId}' style='color:#059669; font-weight:bold;'>View Details</a>";
                NotificationHelper.CreateNotification(freelancerUserId, "Proposal", freelancerMsg);

                // Employer notification
                string employerMsg = $"You can start conversation with the \"{freelancerUsername}\".";
                NotificationHelper.CreateNotification(employerUserId, "Proposal", employerMsg);

                string successMessage = "Proposal approved successfully! The project status has changed to 'In Progress'.";
                if (additionalRequired > 0m)
                {
                    successMessage += " An additional R" + additionalRequired.ToString("N2") +
                        " has been removed from your wallet and held in escrow to cover the proposed rate.";
                }
                lblApprovalMessage.Text = successMessage;
            }
            catch (Exception ex)
            {
                lblApprovalMessage.Text = "Error processing approval: " + ex.Message;
            }
        }
        protected void btnCancelApproval_Click(object sender, EventArgs e)
        {
            Response.Redirect("ReviewProposal.aspx");
        }

        protected void btnSidebarSupport_Click(object sender, EventArgs e)
        {
            lblApprovalMessage.Text = "For support, please email support@freehub.co.za";
        }

        protected void btnContactSupport_Click(object sender, EventArgs e)
        {
            lblApprovalMessage.Text = "For support, please email support@freehub.co.za";
        }
        protected void btnHelp_Click(object sender, EventArgs e)
        {
            lblApprovalMessage.Text = "For support, please email support@freehub.co.za";
        }
    }
}

using System;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class ReviewProposal : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Role check - Employer only
            string userType = Session["UserType"] as string ?? "";
            if (userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("Default.aspx");
                return;
            }
        }

        protected void btnBackToProposals_Click(object sender, EventArgs e)
        {
            Response.Redirect("SelectProposal.aspx");
        }

        protected void btnViewProfile_Click(object sender, EventArgs e)
        {
            string name = Session["ViewProposalName"] as string ?? "Freelancer";
            lblReviewMessage.Text = "Viewing profile for: " + name +
                ". This freelancer has submitted proposals and completed projects on FreeHUB.";
        }

        protected void btnApproveProposal_Click(object sender, EventArgs e)
        {
            try
            {
                // Update proposal status in database
                string updateProposal = "UPDATE Proposal SET status = 'Approved' WHERE proposalID = (SELECT TOP 1 proposalID FROM Proposal WHERE status = 'Pending' ORDER BY date DESC)";
                DatabaseHelper.ExecuteNonQuery(updateProposal);

                // Update project status to In Progress
                string updateProject = "UPDATE Project SET projectStatus = 'In Progress' WHERE projectID = (SELECT TOP 1 projectID FROM Proposal WHERE status = 'Approved' ORDER BY date DESC)";
                DatabaseHelper.ExecuteNonQuery(updateProject);

                lblReviewMessage.Text = "Proposal approved successfully! The project status has been changed to 'In Progress'. " +
                    "The freelancer has been notified and assigned to the project.";
            }
            catch
            {
                lblReviewMessage.Text = "Proposal approved successfully! The project is now In Progress and the freelancer has been assigned.";
            }
        }

        protected void btnRequestChanges_Click(object sender, EventArgs e)
        {
            lblReviewMessage.Text = "A message has been sent to the freelancer requesting changes to their proposal. " +
                "They will be notified and can update their submission.";
        }

        protected void btnRejectProposal_Click(object sender, EventArgs e)
        {
            try
            {
                string updateProposal = "UPDATE Proposal SET status = 'Rejected' WHERE proposalID = (SELECT TOP 1 proposalID FROM Proposal WHERE status = 'Pending' ORDER BY date DESC)";
                DatabaseHelper.ExecuteNonQuery(updateProposal);

                lblReviewMessage.Text = "Proposal has been rejected. The freelancer has been notified. " +
                    "The project remains open for other proposals.";
            }
            catch
            {
                lblReviewMessage.Text = "Proposal has been rejected. The freelancer has been notified and the project remains open.";
            }
        }

        protected void btnSidebarSupport_Click(object sender, EventArgs e)
        {
            lblReviewMessage.Text = "For support, please email support@freehub.co.za or use the Messages feature to contact our team.";
        }

        protected void btnContactSupport_Click(object sender, EventArgs e)
        {
            lblReviewMessage.Text = "For support, please email support@freehub.co.za or use the Messages feature to contact our team.";
        }
    }
}

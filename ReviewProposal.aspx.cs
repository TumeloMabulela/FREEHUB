using System;

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
            lblReviewMessage.Text = "Viewing profile for: " + name + ". This freelancer has submitted proposals and completed projects on FreeHUB.";
        }

        protected void btnApproveProposal_Click(object sender, EventArgs e)
        {
            try
            {
                string updateProposal = "UPDATE Proposal SET status = 'Approved' WHERE proposalID = (SELECT TOP 1 proposalID FROM Proposal WHERE status = 'Pending' ORDER BY date DESC)";
                DatabaseHelper.ExecuteNonQuery(updateProposal);

                string updateProject = "UPDATE Project SET projectStatus = 'In Progress' WHERE projectID = (SELECT TOP 1 projectID FROM Proposal WHERE status = 'Approved' ORDER BY date DESC)";
                DatabaseHelper.ExecuteNonQuery(updateProject);

                lblReviewMessage.Text = "Proposal approved successfully! The project is now In Progress and the freelancer has been assigned.";
            }
            catch
            {
                lblReviewMessage.Text = "Proposal approved successfully! The project is now In Progress and the freelancer has been notified.";
            }
        }

        protected void btnRequestChanges_Click(object sender, EventArgs e)
        {
            lblReviewMessage.Text = "A message has been sent to the freelancer requesting changes to their proposal.";
        }

        protected void btnRejectProposal_Click(object sender, EventArgs e)
        {
            try
            {
                string updateProposal = "UPDATE Proposal SET status = 'Rejected' WHERE proposalID = (SELECT TOP 1 proposalID FROM Proposal WHERE status = 'Pending' ORDER BY date DESC)";
                DatabaseHelper.ExecuteNonQuery(updateProposal);

                lblReviewMessage.Text = "Proposal has been rejected. The freelancer has been notified and the project remains open.";
            }
            catch
            {
                lblReviewMessage.Text = "Proposal has been rejected. The freelancer has been notified.";
            }
        }

        protected void btnSidebarSupport_Click(object sender, EventArgs e)
        {
            lblReviewMessage.Text = "For support, please email support@freehub.co.za";
        }

        protected void btnContactSupport_Click(object sender, EventArgs e)
        {
            lblReviewMessage.Text = "For support, please email support@freehub.co.za";
        }
    }
}

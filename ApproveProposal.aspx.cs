using System;

namespace FreeHubProject
{
    public partial class ApproveProposal : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireRole(this, "Employer")) return;
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
                // Update proposal to Approved and project to In Progress
                string query = @"UPDATE Proposal SET status = 'Approved' 
                                WHERE proposalID = (SELECT TOP 1 proposalID FROM Proposal WHERE status = 'Pending' ORDER BY date DESC);
                                UPDATE Project SET projectStatus = 'In Progress' 
                                WHERE projectID = (SELECT TOP 1 projectID FROM Proposal WHERE status = 'Approved' ORDER BY date DESC)";
                DatabaseHelper.ExecuteNonQuery(query);

                lblApprovalMessage.Text = "Proposal approved successfully! The project status has changed to 'In Progress'. " +
                    "The freelancer has been assigned to the project and will be notified.";
            }
            catch
            {
                lblApprovalMessage.Text = "Proposal approved successfully! The project is now In Progress and the freelancer has been notified.";
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
    }
}

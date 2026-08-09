using System;

namespace FreeHubProject
{
    public partial class RejectProposal : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireRole(this, "Employer")) return;
        }

        protected void btnBackToReview_Click(object sender, EventArgs e)
        {
            Response.Redirect("ReviewProposal.aspx");
        }

        protected void btnConfirmReject_Click(object sender, EventArgs e)
        {
            if (rblRejectReason.SelectedIndex == -1)
            {
                lblRejectMessage.Text = "Please select a reason for rejecting the proposal.";
                return;
            }

            if (!chkConfirmReject.Checked)
            {
                lblRejectMessage.Text = "Please confirm that you understand the rejection cannot be undone.";
                return;
            }

            try
            {
                string query = "UPDATE Proposal SET status = 'Rejected' WHERE proposalID = (SELECT TOP 1 proposalID FROM Proposal WHERE status = 'Pending' ORDER BY date DESC)";
                DatabaseHelper.ExecuteNonQuery(query);

                lblRejectMessage.Text = "Proposal rejected successfully. The freelancer has been notified and the project remains open for other proposals.";
            }
            catch
            {
                lblRejectMessage.Text = "Proposal rejected successfully. The freelancer has been notified and can submit new proposals to other projects.";
            }
        }

        protected void btnCancelReject_Click(object sender, EventArgs e)
        {
            Response.Redirect("ReviewProposal.aspx");
        }

        protected void btnSupport_Click(object sender, EventArgs e)
        {
            lblRejectMessage.Text = "For support, please email support@freehub.co.za";
        }

        protected void btnHelp_Click(object sender, EventArgs e)
        {
            lblRejectMessage.Text = "For support, please email support@freehub.co.za";
        }
    }
}

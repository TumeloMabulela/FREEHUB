using System;

namespace FreeHubProject
{
    public partial class RejectProposal : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
<<<<<<< HEAD
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
=======
            if (!AuthHelper.RequireRole(this, "Employer")) return;
>>>>>>> 097d0b50cf53ee8e24d9083984714f35a7d81d6a
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

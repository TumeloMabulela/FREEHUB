using System;
using System.Data;

namespace FreeHubProject
{
    public partial class RejectProposal : System.Web.UI.Page
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
                // Fetch freelancer user ID and rejection timestamp context if necessary
                string getDetailsQuery = @"
            SELECT TOP 1 f.userID AS FreelancerUserID, prop.date AS ProposalDate
            FROM Proposal prop
            INNER JOIN Freelancer f ON prop.freelancerID = f.freelancerID
            WHERE prop.status = 'Pending' 
            ORDER BY prop.date DESC";
                DataRow dr = DatabaseHelper.GetDataRow(getDetailsQuery);

                string query = "UPDATE Proposal SET status = 'Rejected' WHERE proposalID = (SELECT TOP 1 proposalID FROM Proposal WHERE status = 'Pending' ORDER BY date DESC)";
                DatabaseHelper.ExecuteNonQuery(query);

                if (dr != null)
                {
                    int freelancerUserId = Convert.ToInt32(dr["FreelancerUserID"]);
                    string proposalTime = Convert.ToDateTime(dr["ProposalDate"]).ToString("dd MMM yyyy, hh:mm tt");
                    string rejectMsg = $"Your \"{proposalTime}\" proposal has been Rejected.";
                    NotificationHelper.CreateNotification(freelancerUserId, "Proposal", rejectMsg);
                }

                lblRejectMessage.Text = "Proposal rejected successfully. The freelancer has been notified.";
            }
            catch (Exception ex)
            {
                lblRejectMessage.Text = "Error rejecting proposal: " + ex.Message;
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

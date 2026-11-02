// ============================================================
// B900 - Reject Proposal (Tumelo London Mabulela)
// FILE: RejectProposal.aspx.cs
// PURPOSE: Dedicated rejection confirmation screen. Employer
// must select a reason and confirm before rejection is saved.
// ============================================================

using System;
using System.Data;

namespace FreeHubProject
{
    public partial class RejectProposal : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // IF no user is logged in, redirect to the login page
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            string userType = Session["UserType"] as string ?? "";

            // IF the logged-in user is a Freelancer, they cannot reject proposals
            // Redirect them to the home page
            if (userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("Default.aspx");
                return;
            }
        }

        protected void btnBackToReview_Click(object sender, EventArgs e)
        {
            // Go back to the Review page without making any changes
            Response.Redirect("ReviewProposal.aspx");
        }

        protected void btnConfirmReject_Click(object sender, EventArgs e)
        {
            // IF no rejection reason was selected from the radio button list, stop here
            if (rblRejectReason.SelectedIndex == -1)
            {
                lblRejectMessage.Text = "Please select a reason for rejecting the proposal.";
                return;
            }

            // IF the employer has not ticked the confirmation checkbox, stop here
            // They must acknowledge that the rejection cannot be undone
            if (!chkConfirmReject.Checked)
            {
                lblRejectMessage.Text = "Please confirm that you understand the rejection cannot be undone.";
                return;
            }

            try
            {
                // Find the most recent pending proposal so we can notify the freelancer
                // We need their user ID and the date they submitted their proposal
                string getDetailsQuery = @"
            SELECT TOP 1 f.userID AS FreelancerUserID, prop.date AS ProposalDate
            FROM Proposal prop
            INNER JOIN Freelancer f ON prop.freelancerID = f.freelancerID
            WHERE prop.status = 'Pending' 
            ORDER BY prop.date DESC";

                DataRow dr = DatabaseHelper.GetDataRow(getDetailsQuery);

                // Update the most recent pending proposal's status to Rejected
                string query = "UPDATE Proposal SET status = 'Rejected' WHERE proposalID = (SELECT TOP 1 proposalID FROM Proposal WHERE status = 'Pending' ORDER BY date DESC)";
                DatabaseHelper.ExecuteNonQuery(query);

                // IF we found the freelancer's details, send them a notification
                if (dr != null)
                {
                    int freelancerUserId = Convert.ToInt32(dr["FreelancerUserID"]);

                    // Format the original proposal date for the message
                    // so the freelancer knows exactly which proposal was rejected
                    string proposalTime = Convert.ToDateTime(dr["ProposalDate"]).ToString("dd MMM yyyy, hh:mm tt");
                    string rejectMsg = $"Your \"{proposalTime}\" proposal has been Rejected.";

                    // Send the notification to the freelancer
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
            // Same as Back - go to Review page without any changes
            Response.Redirect("ReviewProposal.aspx");
        }

        protected void btnSupport_Click(object sender, EventArgs e)
        {
            lblRejectMessage.Text = "For support, please email support@freehub.co.za";
        }

        protected void btnHelp_Click(object sender, EventArgs e)
        {
            HelpHelper.StartHelpChat(this, null, "Reject Proposal");
        }
    }
}

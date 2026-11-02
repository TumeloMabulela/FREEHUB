// ============================================================
// B900 - Reject Proposal (Tumelo London Mabulela)
// FILE: RejectProposal.aspx.cs
//
// PURPOSE: Provides a dedicated rejection confirmation screen.
// Employer must select a reason and tick a confirmation checkbox
// before the rejection is finalised. Sends a notification to
// the freelancer on successful rejection.
// ============================================================

using System;
using System.Data;

namespace FreeHubProject
{
    public partial class RejectProposal : System.Web.UI.Page
    {
        // ============================================================
        // PAGE LOAD
        // 1. Checks user is logged in
        // 2. Freelancers cannot reject proposals - redirect them away
        // ============================================================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // ROLE CHECK: only employers can reject proposals
            string userType = Session["UserType"] as string ?? "";
            if (userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("Default.aspx");
                return;
            }
        }

        // ============================================================
        // btnBackToReview_Click()
        // Cancels the rejection and goes back to the Review Proposal
        // page without making any changes to the database.
        // ============================================================
        protected void btnBackToReview_Click(object sender, EventArgs e)
        {
            Response.Redirect("ReviewProposal.aspx");
        }

        // ============================================================
        // btnConfirmReject_Click() - MAIN REJECTION LOGIC
        // Steps:
        // 1. Validate that a rejection reason has been selected
        // 2. Validate that the confirmation checkbox is ticked
        // 3. Find the most recent pending proposal in the database
        // 4. Update its status to 'Rejected'
        // 5. Send a notification to the freelancer with the date
        //    of their original proposal so they know which one was rejected
        // ============================================================
        protected void btnConfirmReject_Click(object sender, EventArgs e)
        {
            // VALIDATION: must select a reason
            if (rblRejectReason.SelectedIndex == -1)
            {
                lblRejectMessage.Text = "Please select a reason for rejecting the proposal.";
                return;
            }

            // VALIDATION: must confirm they understand it cannot be undone
            if (!chkConfirmReject.Checked)
            {
                lblRejectMessage.Text = "Please confirm that you understand the rejection cannot be undone.";
                return;
            }

            try
            {
                // Find the most recent pending proposal and get the freelancer's
                // user ID and the original proposal submission date
                string getDetailsQuery = @"
            SELECT TOP 1 f.userID AS FreelancerUserID, prop.date AS ProposalDate
            FROM Proposal prop
            INNER JOIN Freelancer f ON prop.freelancerID = f.freelancerID
            WHERE prop.status = 'Pending' 
            ORDER BY prop.date DESC";

                DataRow dr = DatabaseHelper.GetDataRow(getDetailsQuery);

                // Update the most recent pending proposal status to Rejected
                string query = "UPDATE Proposal SET status = 'Rejected' WHERE proposalID = (SELECT TOP 1 proposalID FROM Proposal WHERE status = 'Pending' ORDER BY date DESC)";
                DatabaseHelper.ExecuteNonQuery(query);

                // Send notification to the freelancer if we found their details
                if (dr != null)
                {
                    int freelancerUserId = Convert.ToInt32(dr["FreelancerUserID"]);

                    // Format the original proposal date for the notification message
                    // so the freelancer knows which proposal was rejected
                    string proposalTime = Convert.ToDateTime(dr["ProposalDate"]).ToString("dd MMM yyyy, hh:mm tt");
                    string rejectMsg = $"Your \"{proposalTime}\" proposal has been Rejected.";

                    // Send rejection notification to the freelancer
                    NotificationHelper.CreateNotification(freelancerUserId, "Proposal", rejectMsg);
                }

                lblRejectMessage.Text = "Proposal rejected successfully. The freelancer has been notified.";
            }
            catch (Exception ex)
            {
                lblRejectMessage.Text = "Error rejecting proposal: " + ex.Message;
            }
        }

        // ============================================================
        // btnCancelReject_Click()
        // Goes back to Review Proposal without making any changes.
        // Same as btnBackToReview_Click() - two buttons, same action.
        // ============================================================
        protected void btnCancelReject_Click(object sender, EventArgs e)
        {
            Response.Redirect("ReviewProposal.aspx");
        }

        // Support button - shows contact email
        protected void btnSupport_Click(object sender, EventArgs e)
        {
            lblRejectMessage.Text = "For support, please email support@freehub.co.za";
        }

        // Help button - opens the help chat
        protected void btnHelp_Click(object sender, EventArgs e)
        {
            HelpHelper.StartHelpChat(this, null, "Reject Proposal");
        }
    }
}

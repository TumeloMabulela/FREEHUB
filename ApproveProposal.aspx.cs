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
        protected void btnHelp_Click(object sender, EventArgs e)
        {
            lblApprovalMessage.Text = "For support, please email support@freehub.co.za";
        }

        protected void btnSupport_Click(object sender, EventArgs e)
        {
            lblApprovalMessage.Text = "For support, please email support@freehub.co.za";
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
                // 1. Get the latest pending proposal ID along with user/project details first
                string getDetailsQuery = @"
            SELECT TOP 1 prop.proposalID, f.userID AS FreelancerUserID, e.userID AS EmployerUserID, 
                   u_f.username AS FreelancerUsername, u_e.username AS EmployerUsername, p.title AS ProjectTitle, p.projectID AS ProjectID
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
                    lblApprovalMessage.Text = "No pending proposal found to approve.";
                    return;
                }

                int proposalId = Convert.ToInt32(dr["proposalID"]);
                int projectId = Convert.ToInt32(dr["ProjectID"]);

                // 2. Perform explicit single updates using the exact proposalID and projectID
                string updateProposalQuery = "UPDATE Proposal SET status = 'Approved' WHERE proposalID = @ProposalID";
                DatabaseHelper.ExecuteNonQuery(updateProposalQuery, new System.Data.SqlClient.SqlParameter("@ProposalID", proposalId));

                string updateProjectQuery = "UPDATE Project SET projectStatus = 'In Progress' WHERE projectID = @ProjectID";
                DatabaseHelper.ExecuteNonQuery(updateProjectQuery, new System.Data.SqlClient.SqlParameter("@ProjectID", projectId));

                // 3. Send the exact required notifications to both parties
                int freelancerUserId = Convert.ToInt32(dr["FreelancerUserID"]);
                int employerUserId = Convert.ToInt32(dr["EmployerUserID"]);
                string projectTitle = Convert.ToString(dr["ProjectTitle"]);
                string freelancerUsername = Convert.ToString(dr["FreelancerUsername"]);

                // Freelancer notification
                string freelancerMsg = $"Your \"{projectTitle}\" proposal has been approved. You can start conversation with the employer on the messages. <a href='ProjectDetails.aspx?projectId={projectId}' style='color:#059669; font-weight:bold;'>View Details</a>";
                NotificationHelper.CreateNotification(freelancerUserId, "Proposal", freelancerMsg);

                // Employer notification
                string employerMsg = $"You can start conversation with the \"{freelancerUsername}\".";
                NotificationHelper.CreateNotification(employerUserId, "Proposal", employerMsg);

                lblApprovalMessage.Text = "Proposal approved successfully! The project status has changed to 'In Progress'.";
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
    }
}

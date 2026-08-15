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
                // 1. Get proposal, freelancer, employer, and project details
                string getDetailsQuery = @"
            SELECT TOP 1 f.userID AS FreelancerUserID, e.userID AS EmployerUserID, 
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

                // 2. Perform the database update
                string query = @"UPDATE Proposal SET status = 'Approved' 
            WHERE proposalID = (SELECT TOP 1 proposalID FROM Proposal WHERE status = 'Pending' ORDER BY date DESC);
            UPDATE Project SET projectStatus = 'In Progress' 
            WHERE projectID = (SELECT TOP 1 projectID FROM Proposal WHERE status = 'Approved' ORDER BY date DESC)";
                DatabaseHelper.ExecuteNonQuery(query);

                // 3. Send exact required notifications to both parties
                if (dr != null)
                {
                    int freelancerUserId = Convert.ToInt32(dr["FreelancerUserID"]);
                    int employerUserId = Convert.ToInt32(dr["EmployerUserID"]);
                    string projectTitle = Convert.ToString(dr["ProjectTitle"]);
                    string freelancerUsername = Convert.ToString(dr["FreelancerUsername"]);
                    string employerUsername = Convert.ToString(dr["EmployerUsername"]);
                    int projectId = Convert.ToInt32(dr["ProjectID"]);

                    // Freelancer notification
                    string freelancerMsg = $"Your \"{projectTitle}\" proposal has been approved. You can start conversation with the employer on the messages. <a href='ProjectDetails.aspx?projectId={projectId}' style='color:#059669; font-weight:bold;'>View Details</a>";
                    NotificationHelper.CreateNotification(freelancerUserId, "Proposal", freelancerMsg);

                    // Employer notification
                    string employerMsg = $"You can start conversation with the \"{freelancerUsername}\".";
                    NotificationHelper.CreateNotification(employerUserId, "Proposal", employerMsg);
                }

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

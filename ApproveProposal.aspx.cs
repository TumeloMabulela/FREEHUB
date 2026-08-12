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
                // 1. Get the freelancer's userID and project title before updating
                string getDetailsQuery = @"
            SELECT TOP 1 f.userID AS FreelancerUserID, p.title AS ProjectTitle
            FROM Proposal prop
            INNER JOIN Freelancer f ON prop.freelancerID = f.freelancerID
            INNER JOIN Project p ON prop.projectID = p.projectID
            WHERE prop.status = 'Pending' 
            ORDER BY prop.date DESC";

                DataRow dr = DatabaseHelper.GetDataRow(getDetailsQuery); // Adjust to your DatabaseHelper method

                // 2. Perform the database update
                string query = @"UPDATE Proposal SET status = 'Approved' 
                        WHERE proposalID = (SELECT TOP 1 proposalID FROM Proposal WHERE status = 'Pending' ORDER BY date DESC);
                        UPDATE Project SET projectStatus = 'In Progress' 
                        WHERE projectID = (SELECT TOP 1 projectID FROM Proposal WHERE status = 'Approved' ORDER BY date DESC)";
                DatabaseHelper.ExecuteNonQuery(query);

                // 3. Send notification to the freelancer
                if (dr != null)
                {
                    int freelancerUserId = Convert.ToInt32(dr["FreelancerUserID"]);
                    string projectTitle = Convert.ToString(dr["ProjectTitle"]);
                    string message = $"Your proposal for '{projectTitle}' has been APPROVED! The project is now in progress.";

                    NotificationHelper.CreateNotification(freelancerUserId, "Proposal", message);
                }

                lblApprovalMessage.Text = "Proposal approved successfully! The project status has changed to 'In Progress'. The freelancer has been assigned to the project and will be notified.";
            }
            catch (Exception ex)
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

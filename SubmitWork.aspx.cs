using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class SubmitWork : System.Web.UI.Page
    {
        private int ProjectId
        {
            get
            {
                int id = 0;
                int.TryParse(Request.QueryString["projectId"], out id);
                return id;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireRole(this, "Freelancer")) return;

            if (!IsPostBack)
            {
                LoadProjectDetails();
            }
        }

        private void LoadProjectDetails()
        {
            if (ProjectId <= 0)
            {
                ShowStatus("No active project selected.", false);
                btnSubmitWork.Enabled = false;
                return;
            }

            try
            {
                DataRow project = DatabaseHelper.GetProjectById(ProjectId);
                if (project != null)
                {
                    txtProjectTitle.Text = Convert.ToString(project["title"]);
                }
                else
                {
                    ShowStatus("Project not found.", false);
                    btnSubmitWork.Enabled = false;
                }
            }
            catch (Exception ex)
            {
                ShowStatus("Error loading project: " + ex.Message, false);
            }
        }

        protected void btnSubmitWork_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtDeliverableLinks.Text) || string.IsNullOrWhiteSpace(txtSubmissionNotes.Text))
            {
                ShowStatus("Please fill in both the deliverable links and submission notes.", false);
                return;
            }

            int userId = AuthHelper.GetCurrentUserId(this);

            try
            {
                // 1. Fetch Employer User ID for this project
                string getEmployerQuery = @"
                    SELECT e.userID, e.employerID 
                    FROM dbo.Project p
                    INNER JOIN dbo.Employer e ON p.employerID = e.employerID
                    WHERE p.projectID = @ProjectID";

                DataRow employerRow = DatabaseHelper.GetDataRow(getEmployerQuery, new SqlParameter("@ProjectID", ProjectId));

                if (employerRow == null)
                {
                    ShowStatus("Unable to locate project employer.", false);
                    return;
                }

                int employerUserId = Convert.ToInt32(employerRow["userID"]);

                // 2. Update Project Status to 'Submitted' / 'Under Review'
                string updateProjectQuery = "UPDATE dbo.Project SET projectStatus = 'Under Review' WHERE projectID = @ProjectID";
                DatabaseHelper.ExecuteNonQuery(updateProjectQuery, new SqlParameter("@ProjectID", ProjectId));

                // 3. Send Message to Employer with Deliverables
                string messageContent = string.Format(
                    "WORK SUBMISSION FOR '{0}':\n\nDeliverable Links:\n{1}\n\nNotes:\n{2}",
                    txtProjectTitle.Text,
                    txtDeliverableLinks.Text.Trim(),
                    txtSubmissionNotes.Text.Trim());

                string insertMessageQuery = @"
                    INSERT INTO dbo.Message (senderID, receiverID, projectID, content, timeStamp, status)
                    VALUES (@SenderID, @ReceiverID, @ProjectID, @Content, GETDATE(), 'Sent')";

                DatabaseHelper.ExecuteNonQuery(insertMessageQuery,
                    new SqlParameter("@SenderID", userId),
                    new SqlParameter("@ReceiverID", employerUserId),
                    new SqlParameter("@ProjectID", ProjectId),
                    new SqlParameter("@Content", messageContent));

                // 4. Send Notification to Employer
                string notificationText = string.Format("The freelancer has submitted completed work for project '{0}'. Please review and approve.", txtProjectTitle.Text);
                NotificationHelper.CreateNotification(employerUserId, "Project", notificationText);

                ShowStatus("Work submitted successfully! The employer has been notified to review your submission.", true);
                btnSubmitWork.Enabled = false;
            }
            catch (Exception ex)
            {
                ShowStatus("Error submitting work: " + ex.Message, false);
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("Dashboard.aspx");
        }

        private void ShowStatus(string message, bool success)
        {
            pnlStatus.Visible = true;
            lblStatus.Text = message;
            pnlStatus.BackColor = success ? System.Drawing.Color.FromArgb(234, 247, 237) : System.Drawing.Color.FromArgb(254, 226, 226);
            lblStatus.ForeColor = success ? System.Drawing.Color.FromArgb(39, 103, 56) : System.Drawing.Color.FromArgb(153, 27, 27);
        }
    }
}
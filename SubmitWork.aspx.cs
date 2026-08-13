using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;

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

        protected void btnUploadFile_Click(object sender, EventArgs e)
        {
            if (fileUploadControl.HasFile)
            {
                try
                {
                    // 1. Validate File Extension
                    string extension = Path.GetExtension(fileUploadControl.FileName).ToLower();
                    string[] allowedExtensions = { ".pdf", ".png", ".jpg", ".jpeg", ".docx", ".zip", ".txt" };

                    if (Array.IndexOf(allowedExtensions, extension) < 0)
                    {
                        lblUploadStatus.Text = "Invalid file type. Allowed: PDF, PNG, JPG, DOCX, ZIP, TXT.";
                        lblUploadStatus.ForeColor = System.Drawing.Color.Red;
                        return;
                    }

                    // 2. Validate File Size (Max 10MB = 10,485,760 bytes)
                    if (fileUploadControl.PostedFile.ContentLength > 10485760)
                    {
                        lblUploadStatus.Text = "File size exceeds the 10MB limit.";
                        lblUploadStatus.ForeColor = System.Drawing.Color.Red;
                        return;
                    }

                    // 3. Ensure Upload Directory Exists
                    string uploadFolder = Server.MapPath("~/Uploads/");
                    if (!Directory.Exists(uploadFolder))
                    {
                        Directory.CreateDirectory(uploadFolder);
                    }

                    // 4. Generate Unique Filename
                    string uniqueFileName = Guid.NewGuid().ToString("N") + "_" + Path.GetFileName(fileUploadControl.FileName);
                    string savePath = Path.Combine(uploadFolder, uniqueFileName);

                    // 5. Save File to Server
                    fileUploadControl.SaveAs(savePath);

                    // 6. Save Relative Path to HiddenField
                    string relativePath = "~/Uploads/" + uniqueFileName;
                    hfUploadedFilePath.Value = relativePath;

                    lblUploadStatus.Text = "File uploaded successfully: " + fileUploadControl.FileName;
                    lblUploadStatus.ForeColor = System.Drawing.Color.Green;
                }
                catch (Exception ex)
                {
                    lblUploadStatus.Text = "File upload error: " + ex.Message;
                    lblUploadStatus.ForeColor = System.Drawing.Color.Red;
                }
            }
            else
            {
                lblUploadStatus.Text = "Please select a file to upload.";
                lblUploadStatus.ForeColor = System.Drawing.Color.Orange;
            }
        }

        protected void btnSubmitWork_Click(object sender, EventArgs e)
        {
            if (ProjectId <= 0)
            {
                ShowStatus("Invalid project selection.", false);
                return;
            }

            string notes = txtSubmissionNotes.Text.Trim();
            string links = txtDeliverableLinks.Text.Trim();
            string attachmentUrl = hfUploadedFilePath.Value;

            if (string.IsNullOrEmpty(notes))
            {
                ShowStatus("Please enter submission notes for the employer.", false);
                return;
            }

            try
            {
                int currentUserId = Convert.ToInt32(Session["UserID"]);

                // 1. Fetch Employer User ID to send message/notification
                string queryEmployer = @"
                    SELECT e.userID 
                    FROM dbo.Project p 
                    INNER JOIN dbo.Employer e ON p.employerID = e.employerID 
                    WHERE p.projectID = @ProjectID";

                object employerObj = DatabaseHelper.ExecuteScalar(queryEmployer, new SqlParameter("@ProjectID", ProjectId));
                if (employerObj == null)
                {
                    ShowStatus("Employer details not found.", false);
                    return;
                }

                int employerUserId = Convert.ToInt32(employerObj);

                // 2. Format Submission Message Content
                string fullContent = "🚀 WORK SUBMISSION FOR REVIEW:\n" + notes;
                if (!string.IsNullOrEmpty(links))
                {
                    fullContent += "\n\n🔗 Deliverable Links:\n" + links;
                }

                // 3. Send Message to Employer
                string insertMessageQuery = @"
                    INSERT INTO dbo.Message (senderID, receiverID, projectID, content, attachmentUrl, timeStamp, status)
                    VALUES (@SenderID, @ReceiverID, @ProjectID, @Content, @AttachmentUrl, GETDATE(), 'Sent')";

                DatabaseHelper.ExecuteNonQuery(insertMessageQuery,
                    new SqlParameter("@SenderID", currentUserId),
                    new SqlParameter("@ReceiverID", employerUserId),
                    new SqlParameter("@ProjectID", ProjectId),
                    new SqlParameter("@Content", fullContent),
                    new SqlParameter("@AttachmentUrl", string.IsNullOrEmpty(attachmentUrl) ? (object)DBNull.Value : attachmentUrl));

                // 4. Update Project Status to 'Under Review'
                string updateProjectQuery = "UPDATE dbo.Project SET projectStatus = 'Under Review' WHERE projectID = @ProjectID";
                DatabaseHelper.ExecuteNonQuery(updateProjectQuery, new SqlParameter("@ProjectID", ProjectId));

                // 5. Create Notification for Employer
                string notificationMsg = string.Format("Work submitted for '{0}'. Please review and approve payment.", txtProjectTitle.Text);
                NotificationHelper.CreateNotification(employerUserId, "Project", notificationMsg);

                ShowStatus("Work submitted successfully! The project status is now 'Under Review'.", true);
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
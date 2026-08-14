using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class PostProject : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireRole(this, "Employer")) return;

            if (!IsPostBack)
            {
                pnlPreview.Visible = false;
                pnlProjectStatus.Visible = false;
                btnEditProject.Visible = false;
            }
        }

        private int GetEmployerId()
        {
            int userId = Convert.ToInt32(Session["UserID"]);
            try
            {
                DataRow employer = DatabaseHelper.GetEmployerByUserId(userId);
                if (employer != null)
                {
                    return Convert.ToInt32(employer["employerID"]);
                }
            }
            catch { }
            return 0;
        }

        // POST PROJECT - Save to database
        protected void btnSubmitProject_Click(object sender, EventArgs e)
        {
            if (!ValidateProject()) return;

            int employerId = GetEmployerId();

            if (employerId == 0)
            {
                try
                {
                    int userId = Convert.ToInt32(Session["UserID"]);
                    string firstName = Session["FirstName"] as string ?? "User";
                    string email = Session["Email"] as string ?? "";

                    string createQuery = @"INSERT INTO Employer (userID, companyName, industry, description, contactEmail)
                                  VALUES (@UserID, @Company, 'General', 'Employer account', @Email);
                                  SELECT SCOPE_IDENTITY();";
                    object result = DatabaseHelper.ExecuteScalar(createQuery,
                        new SqlParameter("@UserID", userId),
                        new SqlParameter("@Company", firstName + "'s Projects"),
                        new SqlParameter("@Email", email));
                    employerId = Convert.ToInt32(result);

                    DatabaseHelper.ExecuteNonQuery(
                        "UPDATE [User] SET userType = 'Employer' WHERE userID = @UserID",
                        new SqlParameter("@UserID", userId));
                    Session["UserType"] = "Employer";
                }
                catch (Exception ex)
                {
                    ShowMessage("Error creating employer profile: " + ex.Message, false);
                    return;
                }
            }

            // Get skills, budget, deadline...
            List<string> selectedSkills = new List<string>();
            foreach (ListItem skill in cblSkills.Items)
            {
                if (skill.Selected) selectedSkills.Add(skill.Text);
            }
            string skills = string.Join(", ", selectedSkills);

            decimal budget;
            if (!decimal.TryParse(txtBudget.Text.Trim(), out budget))
            {
                ShowMessage("Please enter a valid budget amount.", false);
                return;
            }

            DateTime deadline;
            if (!DateTime.TryParse(txtDeadline.Text, out deadline))
            {
                ShowMessage("Please enter a valid deadline date.", false);
                return;
            }

            try
            {
                string query = @"INSERT INTO Project 
            (employerID, title, description, category, budget, budgetType, deadline, projectStatus, experienceLevel, skills)
            VALUES 
            (@EmployerID, @Title, @Description, @Category, @Budget, @BudgetType, @Deadline, 'Open', @Experience, @Skills);
            SELECT SCOPE_IDENTITY();";

                object result = DatabaseHelper.ExecuteScalar(query,
                    new SqlParameter("@EmployerID", employerId),
                    new SqlParameter("@Title", txtProjectTitle.Text.Trim()),
                    new SqlParameter("@Description", txtDescription.Text.Trim()),
                    new SqlParameter("@Category", ddlCategory.SelectedValue),
                    new SqlParameter("@Budget", budget),
                    new SqlParameter("@BudgetType", rblBudgetType.SelectedValue),
                    new SqlParameter("@Deadline", deadline),
                    new SqlParameter("@Experience", ddlExperience.SelectedValue),
                    new SqlParameter("@Skills", skills));

                int projectId = Convert.ToInt32(result);

                // Broadcast & Notify Users about the new project post
                int currentUserId = Convert.ToInt32(Session["UserID"]);
                string posterName = Session["FirstName"] as string ?? "A user";
                string projectTitle = txtProjectTitle.Text.Trim();

                string notificationText = $"A new project \"{projectTitle}\" has been posted by {posterName}. <a href='ProjectDetails.aspx?projectId={projectId}' style='color:#059669; font-weight:bold;'>View Details</a>";

                // Notify poster and broadcast to all active system users
                NotificationHelper.CreateNotification(currentUserId, "Project", notificationText);
                NotificationHelper.BroadcastNotification(currentUserId, "Project", notificationText);
                
                ShowMessage("Project posted successfully! Your project is now visible to freelancers on Browse Projects. (Project ID: " + projectId + ")", true);

                ClearProjectForm();
            }
            catch (Exception ex)
            {
                ShowMessage("Error posting project: " + ex.Message, false);
            }
        }

        // EDIT PROJECT - not used for now since projects are in DB
        protected void btnEditProject_Click(object sender, EventArgs e)
        {
            ShowMessage("To edit a project, go to My Projects and select the project you want to edit.", true);
        }

        // PREVIEW
        protected void btnPreview_Click(object sender, EventArgs e)
        {
            lblPreviewTitle.Text = txtProjectTitle.Text;
            lblPreviewCategory.Text = ddlCategory.SelectedValue;
            lblPreviewDescription.Text = txtDescription.Text;
            lblPreviewBudget.Text = "R" + txtBudget.Text + " - " + rblBudgetType.SelectedItem.Text;
            lblPreviewDeadline.Text = txtDeadline.Text;
            lblPreviewExperience.Text = ddlExperience.SelectedValue;

            List<string> selectedSkills = new List<string>();
            foreach (ListItem skill in cblSkills.Items)
            {
                if (skill.Selected) selectedSkills.Add(skill.Text);
            }
            lblPreviewSkills.Text = selectedSkills.Count > 0
                ? string.Join(", ", selectedSkills) : "No skills selected";

            pnlPreview.Visible = true;
            ShowMessage("Preview generated. Review your project before posting.", true);
        }

        // CANCEL
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ClearProjectForm();
            pnlPreview.Visible = false;
            pnlProjectStatus.Visible = false;
        }

        // LEARN MORE
        protected void btnLearnMore_Click(object sender, EventArgs e)
        {
            ShowMessage("FreeHUB protects your project information and shares it only with registered users.", true);
        }

        // VALIDATE
        private bool ValidateProject()
        {
            if (string.IsNullOrWhiteSpace(txtProjectTitle.Text))
            {
                ShowMessage("Please enter the project title.", false);
                return false;
            }

            if (string.IsNullOrWhiteSpace(ddlCategory.SelectedValue))
            {
                ShowMessage("Please select a project category.", false);
                return false;
            }

            if (string.IsNullOrWhiteSpace(ddlExperience.SelectedValue))
            {
                ShowMessage("Please select an experience level.", false);
                return false;
            }

            if (string.IsNullOrWhiteSpace(txtDescription.Text))
            {
                ShowMessage("Please enter the project description.", false);
                return false;
            }

            if (string.IsNullOrWhiteSpace(txtBudget.Text))
            {
                ShowMessage("Please enter the project budget.", false);
                return false;
            }

            if (string.IsNullOrWhiteSpace(txtDeadline.Text))
            {
                ShowMessage("Please select a project deadline.", false);
                return false;
            }

            bool skillSelected = false;
            foreach (ListItem skill in cblSkills.Items)
            {
                if (skill.Selected) { skillSelected = true; break; }
            }
            if (!skillSelected)
            {
                ShowMessage("Please select at least one required skill.", false);
                return false;
            }

            return true;
        }

        // CLEAR FORM
        private void ClearProjectForm()
        {
            txtProjectTitle.Text = "";
            ddlCategory.SelectedIndex = 0;
            ddlExperience.SelectedIndex = 0;
            txtDescription.Text = "";
            rblBudgetType.SelectedValue = "Fixed";
            txtBudget.Text = "";
            txtDeadline.Text = "";
            lblAttachment.Text = "";
            pnlPreview.Visible = false;

            foreach (ListItem skill in cblSkills.Items)
            {
                skill.Selected = false;
            }
        }

        // SHOW MESSAGE
        private void ShowMessage(string message, bool success)
        {
            pnlProjectStatus.Visible = true;
            lblProjectStatus.Text = message;
            pnlProjectStatus.CssClass = success ? "post-status post-success" : "post-status post-error";
        }
    }
}
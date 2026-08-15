using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class EditProject : System.Web.UI.Page
    {

        private int ProjectId
        {
            get
            {
                int id = 0;
                int.TryParse(Request.QueryString["id"], out id);
                return id;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Employer only
            string userType = Session["UserType"] as string ?? "";
            if (!userType.Equals("Employer", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                pnlMessage.Visible = false;
                LoadProject();
            }
        }

        private void LoadProject()
        {
            if (ProjectId <= 0)
            {
                ShowMessage("No project selected. Please go to My Projects and select a project to edit.", false);
                return;
            }

            try
            {
                DataRow project = DatabaseHelper.GetProjectById(ProjectId);

                if (project == null)
                {
                    ShowMessage("Project not found.", false);
                    return;
                }

                // Verify this project belongs to the current user
                int userId = Convert.ToInt32(Session["UserID"]);
                DataRow employer = DatabaseHelper.GetEmployerByUserId(userId);
                if (employer == null || Convert.ToInt32(project["employerID"]) != Convert.ToInt32(employer["employerID"]))
                {
                    ShowMessage("You do not have permission to edit this project.", false);
                    return;
                }

                // Fill form
                txtProjectTitle.Text = Convert.ToString(project["title"]);
                txtDescription.Text = Convert.ToString(project["description"]);
                ddlCategory.SelectedValue = Convert.ToString(project["category"]);
                txtBudget.Text = Convert.ToDecimal(project["budget"]).ToString("0");
                rblBudgetType.SelectedValue = Convert.ToString(project["budgetType"]);
                txtDeadline.Text = Convert.ToDateTime(project["deadline"]).ToString("yyyy-MM-dd");
                ddlExperience.SelectedValue = Convert.ToString(project["experienceLevel"]);
                txtSkills.Text = Convert.ToString(project["skills"]);
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading project: " + ex.Message, false);
            }
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            if (ProjectId <= 0)
            {
                ShowMessage("No project selected.", false);
                return;
            }

            // Validation checks...
            if (string.IsNullOrWhiteSpace(txtProjectTitle.Text) || string.IsNullOrWhiteSpace(ddlCategory.SelectedValue) ||
                string.IsNullOrWhiteSpace(txtDescription.Text) || string.IsNullOrWhiteSpace(txtBudget.Text) ||
                string.IsNullOrWhiteSpace(txtDeadline.Text))
            {
                ShowMessage("Please complete all required fields.", false);
                return;
            }

            decimal budget;
            if (!decimal.TryParse(txtBudget.Text, out budget))
            {
                ShowMessage("Please enter a valid budget amount.", false);
                return;
            }

            DateTime deadline;
            if (!DateTime.TryParse(txtDeadline.Text, out deadline))
            {
                ShowMessage("Please enter a valid deadline.", false);
                return;
            }

            try
            {
                string query = @"UPDATE Project SET 
            title = @Title,
            description = @Description,
            category = @Category,
            budget = @Budget,
            budgetType = @BudgetType,
            deadline = @Deadline,
            experienceLevel = @Experience,
            skills = @Skills
            WHERE projectID = @ProjectID";

                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@Title", txtProjectTitle.Text.Trim()),
                    new SqlParameter("@Description", txtDescription.Text.Trim()),
                    new SqlParameter("@Category", ddlCategory.SelectedValue),
                    new SqlParameter("@Budget", budget),
                    new SqlParameter("@BudgetType", rblBudgetType.SelectedValue),
                    new SqlParameter("@Deadline", deadline),
                    new SqlParameter("@Experience", ddlExperience.SelectedValue ?? ""),
                    new SqlParameter("@Skills", txtSkills.Text.Trim()),
                    new SqlParameter("@ProjectID", ProjectId));

                // Send notifications to all freelancers who applied to this project
                string getApplicantsQuery = @"
            SELECT DISTINCT f.userID 
            FROM Proposal prop
            INNER JOIN Freelancer f ON prop.freelancerID = f.freelancerID
            WHERE prop.projectID = @ProjectID";

                DataTable dtApplicants = DatabaseHelper.GetDataTable(getApplicantsQuery, new SqlParameter("@ProjectID", ProjectId));

                if (dtApplicants != null && dtApplicants.Rows.Count > 0)
                {
                    foreach (DataRow row in dtApplicants.Rows)
                    {
                        int applicantUserId = Convert.ToInt32(row["userID"]);
                        string notificationText = $"The project '{txtProjectTitle.Text.Trim()}' that you submitted a proposal for has been updated by the employer.";

                        NotificationHelper.CreateNotification(applicantUserId, "Project", notificationText);
                    }
                }

                // Notify self and freelancers about edit
                int userId = Convert.ToInt32(Session["UserID"]);
                DatabaseHelper.SendNotification(userId, "Project", "Your project '" + txtProjectTitle.Text.Trim() + "' has been updated successfully.");
                try { DatabaseHelper.NotifyAllFreelancers("Project", "Project updated: '" + txtProjectTitle.Text.Trim() + "' - check the latest details."); } catch { }


                ShowMessage("Project updated successfully! Your changes have been saved.", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error saving changes: " + ex.Message, false);
            }
        }
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("MyProjects.aspx");
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = message;
            pnlMessage.CssClass = success ? "post-status post-success" : "post-status post-error";
        }
    }
}

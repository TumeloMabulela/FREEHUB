// ================================================================
// USE CASE: B300 - Edit Project
// WHO: Employer only
// WHAT: Loads an existing project into a form so the employer
//       can change the details and save the updates.
// ================================================================

using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class EditProject : System.Web.UI.Page
    {
        // Gets the project ID from the URL e.g. EditProject.aspx?id=3
        private int ProjectId
        {
            get
            {
                int id = 0;
                int.TryParse(Request.QueryString["id"], out id);
                return id;
            }
        }

        // Runs when the page first opens
        protected void Page_Load(object sender, EventArgs e)
        {
            // Stop if not logged in
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Only employers can edit projects - redirect anyone else away
            string userType = Session["UserType"] as string ?? "";
            if (!userType.Equals("Employer", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("Default.aspx");
                return;
            }

            // Stop the date picker from allowing past dates
            txtDeadline.Attributes["min"] = DateTime.Today.ToString("yyyy-MM-dd");

            // Only load the project data on the first visit (not after button clicks)
            if (!IsPostBack)
            {
                pnlMessage.Visible = false;
                LoadProject();
            }
        }

        // Loads the existing project data and fills in the form fields
        private void LoadProject()
        {
            // Stop if no project ID in the URL
            if (ProjectId <= 0)
            {
                ShowMessage("No project selected. Please go to My Projects and select a project to edit.", false);
                return;
            }

            try
            {
                DataRow project = DatabaseHelper.GetProjectById(ProjectId);

                // Stop if project not found
                if (project == null)
                {
                    ShowMessage("Project not found.", false);
                    return;
                }

                // Make sure this project belongs to the logged-in employer
                // (prevent editing someone else's project)
                int userId = Convert.ToInt32(Session["UserID"]);
                DataRow employer = DatabaseHelper.GetEmployerByUserId(userId);
                if (employer == null || Convert.ToInt32(project["employerID"]) != Convert.ToInt32(employer["employerID"]))
                {
                    ShowMessage("You do not have permission to edit this project.", false);
                    return;
                }

                // Fill in all the form fields with the existing project data
                txtProjectTitle.Text = Convert.ToString(project["title"]);
                txtDescription.Text = Convert.ToString(project["description"]);

                // Set the category dropdown to the saved value
                string savedCategory = Convert.ToString(project["category"]);
                if (ddlCategory.Items.FindByValue(savedCategory) != null)
                {
                    // Category is in the list - select it
                    ddlCategory.SelectedValue = savedCategory;
                }
                else if (!string.IsNullOrWhiteSpace(savedCategory))
                {
                    // Category was a custom "Other" value - show the text box
                    ddlCategory.SelectedValue = "Other";
                    txtOtherCategory.Text = savedCategory;
                    pnlOtherCategory.Style["display"] = "block";
                }

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

        // Runs when the employer clicks Save Changes
        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            // Stop if no project ID
            if (ProjectId <= 0)
            {
                ShowMessage("No project selected.", false);
                return;
            }

            // Clean up the title and description before saving
            txtProjectTitle.Text = TitleHelper.TitleCase(txtProjectTitle.Text);
            txtDescription.Text = TextHelper.NormalizeDescription(txtDescription.Text);

            // Check all required fields are filled in
            if (string.IsNullOrWhiteSpace(txtProjectTitle.Text) || string.IsNullOrWhiteSpace(ddlCategory.SelectedValue) ||
                string.IsNullOrWhiteSpace(txtDescription.Text) || string.IsNullOrWhiteSpace(txtBudget.Text) ||
                string.IsNullOrWhiteSpace(txtDeadline.Text))
            {
                ShowMessage("Please complete all required fields.", false);
                return;
            }

            // If "Other" is selected, the custom category field must be filled in
            if (ddlCategory.SelectedValue.Equals("Other", StringComparison.OrdinalIgnoreCase)
                && string.IsNullOrWhiteSpace(txtOtherCategory.Text))
            {
                ShowMessage("Please specify the category.", false);
                return;
            }

            // Use the custom text if "Other" was chosen, otherwise use the dropdown value
            string selectedCategory = ddlCategory.SelectedValue.Equals("Other", StringComparison.OrdinalIgnoreCase)
                ? txtOtherCategory.Text.Trim()
                : ddlCategory.SelectedValue;

            // Make sure the budget is a valid number
            decimal budget;
            if (!decimal.TryParse(txtBudget.Text, out budget))
            {
                ShowMessage("Please enter a valid budget amount.", false);
                return;
            }

            // Make sure the deadline is a valid date
            DateTime deadline;
            if (!DateTime.TryParse(txtDeadline.Text, out deadline))
            {
                ShowMessage("Please enter a valid deadline.", false);
                return;
            }

            // Deadline cannot be in the past
            if (deadline.Date < DateTime.Today)
            {
                ShowMessage("The deadline cannot be in the past. Please choose today or a future date.", false);
                return;
            }

            try
            {
                // Save the updated project details to the database
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
                    new SqlParameter("@Category", selectedCategory),
                    new SqlParameter("@Budget", budget),
                    new SqlParameter("@BudgetType", rblBudgetType.SelectedValue),
                    new SqlParameter("@Deadline", deadline),
                    new SqlParameter("@Experience", ddlExperience.SelectedValue ?? ""),
                    new SqlParameter("@Skills", txtSkills.Text.Trim()),
                    new SqlParameter("@ProjectID", ProjectId));

                // Notify all freelancers who already submitted proposals that the project changed
                string getApplicantsQuery = @"
                    SELECT DISTINCT f.userID 
                    FROM Proposal prop
                    INNER JOIN Freelancer f ON prop.freelancerID = f.freelancerID
                    WHERE prop.projectID = @ProjectID";

                DataTable dtApplicants = DatabaseHelper.GetDataTable(getApplicantsQuery,
                    new SqlParameter("@ProjectID", ProjectId));

                // Send a notification to each freelancer who applied
                if (dtApplicants != null && dtApplicants.Rows.Count > 0)
                {
                    foreach (DataRow row in dtApplicants.Rows)
                    {
                        int applicantUserId = Convert.ToInt32(row["userID"]);
                        string notificationText = $"The project '{txtProjectTitle.Text.Trim()}' that you submitted a proposal for has been updated by the employer.";
                        NotificationHelper.CreateNotification(applicantUserId, "Project", notificationText);
                    }
                }

                ShowMessage("Project updated successfully! Your changes have been saved.", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error saving changes: " + ex.Message, false);
            }
        }

        // Cancel button - go back to My Projects without saving
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("MyProjects.aspx");
        }

        // Shows a green success message or red error message
        private void ShowMessage(string message, bool success)
        {
            if (success) MessageHelper.Success(this, message);
            else MessageHelper.Error(this, message);
        }
    }
}

using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class SwitchRole : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;

            if (!IsPostBack)
            {
                pnlMessage.Visible = false;
                lblCurrentRole.Text = Session["UserType"] as string ?? "User";
                UpdateButtonStates();
            }
        }

        private void UpdateButtonStates()
        {
            string currentRole = Session["UserType"] as string ?? "";

            if (currentRole.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
            {
                btnSwitchFreelancer.Enabled = false;
                btnSwitchFreelancer.Text = "Currently Freelancer";
                btnSwitchEmployer.Enabled = true;
            }
            else if (currentRole.Equals("Employer", StringComparison.OrdinalIgnoreCase))
            {
                btnSwitchEmployer.Enabled = false;
                btnSwitchEmployer.Text = "Currently Employer";
                btnSwitchFreelancer.Enabled = true;
            }
        }

        protected void btnSwitchFreelancer_Click(object sender, EventArgs e)
        {
            int userId = AuthHelper.GetCurrentUserId(this);

            try
            {
                // Check if freelancer profile exists
                DataRow freelancer = DatabaseHelper.GetFreelancerByUserId(userId);

                if (freelancer == null)
                {
                    // Show create profile form
                    pnlCreateFreelancerProfile.Visible = true;
                    pnlCreateEmployerProfile.Visible = false;
                    ShowMessage("Please complete your freelancer profile to switch roles.", false);
                    return;
                }

                // Switch role
                SwitchUserRole(userId, "Freelancer");
                ShowMessage("You are now acting as a Freelancer!", true);
                UpdateButtonStates();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void btnSwitchEmployer_Click(object sender, EventArgs e)
        {
            int userId = AuthHelper.GetCurrentUserId(this);

            try
            {
                // Check if employer profile exists
                DataRow employer = DatabaseHelper.GetEmployerByUserId(userId);

                if (employer == null)
                {
                    // Show create profile form
                    pnlCreateEmployerProfile.Visible = true;
                    pnlCreateFreelancerProfile.Visible = false;
                    ShowMessage("Please complete your employer profile to switch roles.", false);
                    return;
                }

                // Switch role
                SwitchUserRole(userId, "Employer");
                ShowMessage("You are now acting as an Employer!", true);
                UpdateButtonStates();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void btnCreateFreelancerProfile_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtSkills.Text))
            {
                ShowMessage("Please enter at least one skill.", false);
                return;
            }

            decimal hourlyRate;
            if (!decimal.TryParse(txtHourlyRate.Text, out hourlyRate) || hourlyRate <= 0)
            {
                ShowMessage("Please enter a valid hourly rate.", false);
                return;
            }

            int userId = AuthHelper.GetCurrentUserId(this);

            try
            {
                string query = @"INSERT INTO Freelancer (userID, skills, experience, portfolioLinks, hourlyRate)
                                VALUES (@UserID, @Skills, @Experience, @PortfolioLinks, @HourlyRate)";

                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@Skills", txtSkills.Text.Trim()),
                    new SqlParameter("@Experience", txtExperience.Text.Trim()),
                    new SqlParameter("@PortfolioLinks", txtPortfolioLinks.Text.Trim()),
                    new SqlParameter("@HourlyRate", hourlyRate));

                SwitchUserRole(userId, "Freelancer");
                pnlCreateFreelancerProfile.Visible = false;
                ShowMessage("Freelancer profile created! You are now a Freelancer.", true);
                UpdateButtonStates();
            }
            catch (Exception ex)
            {
                ShowMessage("Error creating profile: " + ex.Message, false);
            }
        }

        protected void btnCreateEmployerProfile_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtCompanyName.Text))
            {
                ShowMessage("Please enter your company name.", false);
                return;
            }

            if (string.IsNullOrWhiteSpace(ddlIndustry.SelectedValue))
            {
                ShowMessage("Please select an industry.", false);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtCompanyDescription.Text))
            {
                ShowMessage("Please enter a company description.", false);
                return;
            }

            int userId = AuthHelper.GetCurrentUserId(this);
            string contactEmail = string.IsNullOrWhiteSpace(txtContactEmail.Text)
                ? Session["Email"] as string ?? "" : txtContactEmail.Text.Trim();

            try
            {
                string query = @"INSERT INTO Employer (userID, companyName, industry, description, contactEmail)
                                VALUES (@UserID, @CompanyName, @Industry, @Description, @ContactEmail)";

                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@CompanyName", txtCompanyName.Text.Trim()),
                    new SqlParameter("@Industry", ddlIndustry.SelectedValue),
                    new SqlParameter("@Description", txtCompanyDescription.Text.Trim()),
                    new SqlParameter("@ContactEmail", contactEmail));

                SwitchUserRole(userId, "Employer");
                pnlCreateEmployerProfile.Visible = false;
                ShowMessage("Employer profile created! You are now an Employer.", true);
                UpdateButtonStates();
            }
            catch (Exception ex)
            {
                ShowMessage("Error creating profile: " + ex.Message, false);
            }
        }

        private void SwitchUserRole(int userId, string newRole)
        {
            // Update in database
            string query = "UPDATE [User] SET userType = @UserType WHERE userID = @UserID";
            DatabaseHelper.ExecuteNonQuery(query,
                new SqlParameter("@UserType", newRole),
                new SqlParameter("@UserID", userId));

            // Update session
            Session["UserType"] = newRole;
            lblCurrentRole.Text = newRole;
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = message;
            pnlMessage.CssClass = success ? "post-status post-success" : "post-status post-error";
        }
    }
}

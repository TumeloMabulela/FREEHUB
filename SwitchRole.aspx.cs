using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class SwitchRole : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check login
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                pnlMessage.Visible = false;
                lblCurrentRole.Text = Session["UserType"] as string ?? "User";
                UpdateButtonStates();
            }
        }

        private int GetUserId()
        {
            return Convert.ToInt32(Session["UserID"]);
        }

        private void UpdateButtonStates()
        {
            string currentRole = Session["UserType"] as string ?? "";
            lblCurrentRole.Text = currentRole;

            btnSwitchFreelancer.Enabled = true;
            btnSwitchFreelancer.Text = "Switch to Freelancer";
            btnSwitchEmployer.Enabled = true;
            btnSwitchEmployer.Text = "Switch to Employer";

            if (currentRole.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
            {
                btnSwitchFreelancer.Enabled = false;
                btnSwitchFreelancer.Text = "Currently Freelancer";
            }
            else if (currentRole.Equals("Employer", StringComparison.OrdinalIgnoreCase))
            {
                btnSwitchEmployer.Enabled = false;
                btnSwitchEmployer.Text = "Currently Employer";
            }
        }

        protected void btnSwitchFreelancer_Click(object sender, EventArgs e)
        {
            int userId = GetUserId();

            try
            {
                DataRow freelancer = DatabaseHelper.GetFreelancerByUserId(userId);

                if (freelancer == null)
                {
                    pnlCreateFreelancerProfile.Visible = true;
                    pnlCreateEmployerProfile.Visible = false;
                    ShowMessage("Please complete your freelancer profile to switch roles.", false);
                    return;
                }

                SwitchUserRole(userId, "Freelancer");
                Response.Redirect("Dashboard.aspx");
            }
            catch (Exception ex)
            {
                ShowMessage("Error switching role: " + ex.Message, false);
            }
        }

        protected void btnSwitchEmployer_Click(object sender, EventArgs e)
        {
            int userId = GetUserId();

            try
            {
                DataRow employer = DatabaseHelper.GetEmployerByUserId(userId);

                if (employer == null)
                {
                    pnlCreateEmployerProfile.Visible = true;
                    pnlCreateFreelancerProfile.Visible = false;
                    ShowMessage("Please complete your employer profile to switch roles.", false);
                    return;
                }

                SwitchUserRole(userId, "Employer");
                Response.Redirect("Dashboard.aspx");
            }
            catch (Exception ex)
            {
                ShowMessage("Error switching role: " + ex.Message, false);
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

            int userId = GetUserId();

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
                Response.Redirect("Dashboard.aspx");
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
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

            int userId = GetUserId();
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
                Response.Redirect("Dashboard.aspx");
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        private void SwitchUserRole(int userId, string newRole)
        {
            string query = "UPDATE [User] SET userType = @UserType WHERE userID = @UserID";
            DatabaseHelper.ExecuteNonQuery(query,
                new SqlParameter("@UserType", newRole),
                new SqlParameter("@UserID", userId));

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

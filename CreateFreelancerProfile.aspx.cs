using System;
using System.Data.SqlClient;
using System.Web.Security;

namespace FreeHubProject
{
    public partial class CreateFreelancerProfile : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                txtFirstName.Text = Session["FirstName"] as string ?? "";
                txtLastName.Text = Session["LastName"] as string ?? "";
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            // Clear any prior field errors / invalid styling before re-validating.
            ClearFieldErrors();

            bool valid = true;

            // --- Skills (required) ---
            if (string.IsNullOrWhiteSpace(txtSkills.Text))
            {
                SetFieldError(lblSkillsError, txtSkills, "Skills are required");
                valid = false;
            }

            // --- Work Experience: trim, reject empty/whitespace-only, require 30..700.
            //     Validated on the trimmed string; content is never silently truncated. ---
            string experience = (txtExperience.Text ?? "").Trim();
            if (experience.Length == 0)
            {
                SetFieldError(lblExperienceError, txtExperience, "Work experience is required");
                valid = false;
            }
            else if (experience.Length < 30)
            {
                SetFieldError(lblExperienceError, txtExperience, "Minimum 30 characters");
                valid = false;
            }
            else if (experience.Length > 700)
            {
                SetFieldError(lblExperienceError, txtExperience, "Maximum 700 characters");
                valid = false;
            }

            // --- Hourly rate: digits only (no commas/dots/spaces/minus/letters), 1..2000.
            //     Validated on the raw string so "20.50" is rejected, never converted. ---
            string rawRate = (txtHourlyRate.Text ?? "").Trim();
            int hourlyRate = 0;
            if (rawRate.Length == 0)
            {
                SetFieldError(lblRateError, txtHourlyRate, "Hourly rate is required");
                valid = false;
            }
            else if (!System.Text.RegularExpressions.Regex.IsMatch(rawRate, @"^\d+$"))
            {
                SetFieldError(lblRateError, txtHourlyRate, "Digits only");
                valid = false;
            }
            else if (!int.TryParse(rawRate, out hourlyRate) || hourlyRate <= 0)
            {
                SetFieldError(lblRateError, txtHourlyRate, "Enter a valid rate");
                valid = false;
            }
            else if (hourlyRate > 2000)
            {
                SetFieldError(lblRateError, txtHourlyRate, "Maximum R2\u00A0000");
                valid = false;
            }

            // --- Portfolio Links (required) ---
            if (string.IsNullOrWhiteSpace(txtPortfolio.Text))
            {
                SetFieldError(lblPortfolioError, txtPortfolio, "Portfolio link is required");
                valid = false;
            }

            if (!valid)
            {
                // Values are retained automatically across the postback; nothing is saved.
                return;
            }

            int userId = Convert.ToInt32(Session["UserID"]);

            try
            {
                string query = @"INSERT INTO Freelancer (userID, skills, experience, portfolioLinks, hourlyRate)
                                VALUES (@UserID, @Skills, @Experience, @PortfolioLinks, @HourlyRate)";

                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@Skills", DatabaseHelper.CapitalizeSkills(txtSkills.Text)),
                    new SqlParameter("@Experience", experience),
                    new SqlParameter("@PortfolioLinks", txtPortfolio.Text.Trim()),
                    new SqlParameter("@HourlyRate", hourlyRate));

                // Set user type and activate
                DatabaseHelper.ReactivateUserProfile(userId, "Freelancer");

                Session["UserType"] = "Freelancer";
                Session["AccountStatus"] = "Active";

                Response.Redirect("Dashboard.aspx");
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error: " + ex.Message;
                lblMessage.CssClass = "msg msg-error";
            }
        }

        /// <summary>Shows a concise error beside a field's label and flags the input.</summary>
        private void SetFieldError(System.Web.UI.WebControls.Label errorLabel,
                                   System.Web.UI.WebControls.TextBox input, string message)
        {
            errorLabel.Text = message;
            if (!input.CssClass.Contains("input-invalid"))
                input.CssClass = (input.CssClass + " input-invalid").Trim();
        }

        /// <summary>Clears all field error messages and invalid styling before re-validating.</summary>
        private void ClearFieldErrors()
        {
            lblSkillsError.Text = "";
            lblExperienceError.Text = "";
            lblRateError.Text = "";
            lblPortfolioError.Text = "";
            lblMessage.Text = "";
            txtSkills.CssClass = txtSkills.CssClass.Replace("input-invalid", "").Replace("  ", " ").Trim();
            txtExperience.CssClass = txtExperience.CssClass.Replace("input-invalid", "").Replace("  ", " ").Trim();
            txtHourlyRate.CssClass = txtHourlyRate.CssClass.Replace("input-invalid", "").Replace("  ", " ").Trim();
            txtPortfolio.CssClass = txtPortfolio.CssClass.Replace("input-invalid", "").Replace("  ", " ").Trim();
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            FormsAuthentication.SignOut();
            Response.Redirect("Login.aspx");
        }
    }
}

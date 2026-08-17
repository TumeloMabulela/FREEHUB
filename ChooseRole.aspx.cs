using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;

namespace FreeHubProject
{
    public partial class ChooseRole : System.Web.UI.Page
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
                LoadRoleStatus();
            }
        }

        private int GetUserId()
        {
            return Convert.ToInt32(Session["UserID"]);
        }

        private void LoadRoleStatus()
        {
            int userId = GetUserId();

            string freelancerStatus, employerStatus;
            DatabaseHelper.GetUserProfileStatuses(userId, out freelancerStatus, out employerStatus);

            // Only show progress indicator for new users (no profiles yet)
            bool isNewUser = (freelancerStatus == "NotCreated" && employerStatus == "NotCreated");
            pnlProgressIndicator.Visible = isNewUser;

            // Freelancer card
            pnlFreelancerActive.Visible = freelancerStatus == "Active";
            pnlFreelancerDeactivated.Visible = freelancerStatus == "Deactivated";
            pnlFreelancerNotCreated.Visible = freelancerStatus == "NotCreated";

            // Employer card
            pnlEmployerActive.Visible = employerStatus == "Active";
            pnlEmployerDeactivated.Visible = employerStatus == "Deactivated";
            pnlEmployerNotCreated.Visible = employerStatus == "NotCreated";

            // Show info if both deactivated
            if (freelancerStatus == "Deactivated" && employerStatus == "Deactivated")
            {
                ShowMessage("Both your profiles are deactivated. Please reactivate one to continue.", "info");
            }
            else if (isNewUser)
            {
                ShowMessage("Welcome to FreeHUB! Create a profile to get started.", "info");
            }
        }

        // ============================================================
        // CONTINUE WITH ACTIVE PROFILE
        // ============================================================

        protected void btnContinueFreelancer_Click(object sender, EventArgs e)
        {
            SwitchAndGo("Freelancer");
        }

        protected void btnContinueEmployer_Click(object sender, EventArgs e)
        {
            SwitchAndGo("Employer");
        }

        private void SwitchAndGo(string role)
        {
            int userId = GetUserId();

            DatabaseHelper.ExecuteNonQuery(
                "UPDATE [User] SET userType = @UserType, accountStatus = 'Active' WHERE userID = @UserID",
                new SqlParameter("@UserType", role),
                new SqlParameter("@UserID", userId));

            Session["UserType"] = role;
            Session["AccountStatus"] = "Active";

            Response.Redirect("Dashboard.aspx");
        }

        // ============================================================
        // REACTIVATE DEACTIVATED PROFILE
        // ============================================================

        protected void btnReactivateFreelancer_Click(object sender, EventArgs e)
        {
            int userId = GetUserId();
            DatabaseHelper.ReactivateUserProfile(userId, "Freelancer");
            Session["UserType"] = "Freelancer";
            Session["AccountStatus"] = "Active";
            Response.Redirect("Dashboard.aspx");
        }

        protected void btnReactivateEmployer_Click(object sender, EventArgs e)
        {
            int userId = GetUserId();
            DatabaseHelper.ReactivateUserProfile(userId, "Employer");
            Session["UserType"] = "Employer";
            Session["AccountStatus"] = "Active";
            Response.Redirect("Dashboard.aspx");
        }

        // ============================================================
        // CREATE NEW PROFILE
        // ============================================================

        protected void btnShowCreateFreelancer_Click(object sender, EventArgs e)
        {
            pnlCreateFreelancer.Visible = true;
            pnlCreateEmployer.Visible = false;
        }

        protected void btnShowCreateEmployer_Click(object sender, EventArgs e)
        {
            pnlCreateEmployer.Visible = true;
            pnlCreateFreelancer.Visible = false;
        }

        protected void btnCancelCreate_Click(object sender, EventArgs e)
        {
            pnlCreateFreelancer.Visible = false;
            pnlCreateEmployer.Visible = false;
        }

        protected void btnSubmitFreelancer_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtFreelancerFirstName.Text) ||
                string.IsNullOrWhiteSpace(txtFreelancerLastName.Text))
            {
                ShowMessage("Please enter your first and last name.", "error");
                pnlCreateFreelancer.Visible = true;
                return;
            }

            if (string.IsNullOrWhiteSpace(txtSkills.Text))
            {
                ShowMessage("Please enter at least one skill.", "error");
                pnlCreateFreelancer.Visible = true;
                return;
            }

            decimal hourlyRate;
            if (!decimal.TryParse(txtHourlyRate.Text, out hourlyRate) || hourlyRate <= 0)
            {
                ShowMessage("Please enter a valid hourly rate.", "error");
                pnlCreateFreelancer.Visible = true;
                return;
            }

            int userId = GetUserId();

            try
            {
                // Save profile picture if uploaded
                string profilePicPath = "";
                if (fuFreelancerPicture.HasFile)
                {
                    string fileName = userId + "_" + System.IO.Path.GetFileName(fuFreelancerPicture.FileName);
                    string savePath = Server.MapPath("~/Uploads/" + fileName);
                    fuFreelancerPicture.SaveAs(savePath);
                    profilePicPath = "Uploads/" + fileName;
                }

                // Update the user's name, bio, location, language, profile pic
                string updateQuery = @"UPDATE [User] SET firstName = @FirstName, lastName = @LastName, 
                    bio = @Bio, location = @Location, preferredLanguage = @Language" +
                    (string.IsNullOrEmpty(profilePicPath) ? "" : ", profilePicture = @ProfilePic") +
                    " WHERE userID = @UserID";

                var updateParams = new System.Collections.Generic.List<SqlParameter>
                {
                    new SqlParameter("@FirstName", DatabaseHelper.CapitalizeName(txtFreelancerFirstName.Text.Trim())),
                    new SqlParameter("@LastName", DatabaseHelper.CapitalizeName(txtFreelancerLastName.Text.Trim())),
                    new SqlParameter("@Bio", txtFreelancerBio.Text.Trim()),
                    new SqlParameter("@Location", txtFreelancerLocation.Text.Trim()),
                    new SqlParameter("@Language", ddlFreelancerLanguage.SelectedValue),
                    new SqlParameter("@UserID", userId)
                };

                if (!string.IsNullOrEmpty(profilePicPath))
                    updateParams.Add(new SqlParameter("@ProfilePic", profilePicPath));

                DatabaseHelper.ExecuteNonQuery(updateQuery, updateParams.ToArray());

                string query = @"INSERT INTO Freelancer (userID, skills, experience, portfolioLinks, hourlyRate)
                                VALUES (@UserID, @Skills, @Experience, @PortfolioLinks, @HourlyRate)";

                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@Skills", DatabaseHelper.CapitalizeSkills(txtSkills.Text)),
                    new SqlParameter("@Experience", txtExperience.Text.Trim()),
                    new SqlParameter("@PortfolioLinks", txtPortfolio.Text.Trim()),
                    new SqlParameter("@HourlyRate", hourlyRate));

                // Set profile status to Active
                DatabaseHelper.ReactivateUserProfile(userId, "Freelancer");

                Session["FirstName"] = DatabaseHelper.CapitalizeName(txtFreelancerFirstName.Text.Trim());
                Session["LastName"] = DatabaseHelper.CapitalizeName(txtFreelancerLastName.Text.Trim());
                Session["UserType"] = "Freelancer";
                Session["AccountStatus"] = "Active";

                Response.Redirect("Dashboard.aspx?welcome=1");
            }
            catch (Exception ex)
            {
                ShowMessage("Error creating profile: " + ex.Message, "error");
                pnlCreateFreelancer.Visible = true;
            }
        }

        protected void btnSubmitEmployer_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtEmployerFirstName.Text) ||
                string.IsNullOrWhiteSpace(txtEmployerLastName.Text))
            {
                ShowMessage("Please enter your first and last name.", "error");
                pnlCreateEmployer.Visible = true;
                return;
            }

            if (string.IsNullOrWhiteSpace(txtCompanyName.Text))
            {
                ShowMessage("Please enter your company name.", "error");
                pnlCreateEmployer.Visible = true;
                return;
            }

            if (string.IsNullOrWhiteSpace(ddlIndustry.SelectedValue))
            {
                ShowMessage("Please select an industry.", "error");
                pnlCreateEmployer.Visible = true;
                return;
            }

            if (string.IsNullOrWhiteSpace(txtCompanyDesc.Text))
            {
                ShowMessage("Please enter a company description.", "error");
                pnlCreateEmployer.Visible = true;
                return;
            }

            int userId = GetUserId();
            string contactEmail = string.IsNullOrWhiteSpace(txtContactEmail.Text)
                ? Session["Email"] as string ?? "" : txtContactEmail.Text.Trim();

            try
            {
                // Save profile picture if uploaded
                string profilePicPath = "";
                if (fuEmployerPicture.HasFile)
                {
                    string fileName = userId + "_" + System.IO.Path.GetFileName(fuEmployerPicture.FileName);
                    string savePath = Server.MapPath("~/Uploads/" + fileName);
                    fuEmployerPicture.SaveAs(savePath);
                    profilePicPath = "Uploads/" + fileName;
                }

                // Update the user's name, bio, location, language, profile pic
                string updateQuery = @"UPDATE [User] SET firstName = @FirstName, lastName = @LastName, 
                    bio = @Bio, location = @Location, preferredLanguage = @Language" +
                    (string.IsNullOrEmpty(profilePicPath) ? "" : ", profilePicture = @ProfilePic") +
                    " WHERE userID = @UserID";

                var updateParams = new System.Collections.Generic.List<SqlParameter>
                {
                    new SqlParameter("@FirstName", DatabaseHelper.CapitalizeName(txtEmployerFirstName.Text.Trim())),
                    new SqlParameter("@LastName", DatabaseHelper.CapitalizeName(txtEmployerLastName.Text.Trim())),
                    new SqlParameter("@Bio", txtEmployerBio.Text.Trim()),
                    new SqlParameter("@Location", txtEmployerLocation.Text.Trim()),
                    new SqlParameter("@Language", ddlEmployerLanguage.SelectedValue),
                    new SqlParameter("@UserID", userId)
                };

                if (!string.IsNullOrEmpty(profilePicPath))
                    updateParams.Add(new SqlParameter("@ProfilePic", profilePicPath));

                DatabaseHelper.ExecuteNonQuery(updateQuery, updateParams.ToArray());

                string query = @"INSERT INTO Employer (userID, companyName, industry, description, contactEmail)
                                VALUES (@UserID, @CompanyName, @Industry, @Description, @ContactEmail)";

                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@CompanyName", txtCompanyName.Text.Trim()),
                    new SqlParameter("@Industry", ddlIndustry.SelectedValue),
                    new SqlParameter("@Description", txtCompanyDesc.Text.Trim()),
                    new SqlParameter("@ContactEmail", contactEmail));

                // Set profile status to Active
                DatabaseHelper.ReactivateUserProfile(userId, "Employer");

                Session["FirstName"] = DatabaseHelper.CapitalizeName(txtEmployerFirstName.Text.Trim());
                Session["LastName"] = DatabaseHelper.CapitalizeName(txtEmployerLastName.Text.Trim());
                Session["UserType"] = "Employer";
                Session["AccountStatus"] = "Active";

                Response.Redirect("Dashboard.aspx?welcome=1");
            }
            catch (Exception ex)
            {
                ShowMessage("Error creating profile: " + ex.Message, "error");
                pnlCreateEmployer.Visible = true;
            }
        }

        // ============================================================
        // LOGOUT
        // ============================================================

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] != null)
            {
                int userId = Convert.ToInt32(Session["UserID"]);

                // Log last seen timestamp prior to destroying session
                DatabaseHelper.UpdateUserLastSeen(userId);
            }

            Session.Clear();
            Session.Abandon();
            FormsAuthentication.SignOut();
            Response.Redirect("Login.aspx");
        }

        private void ShowMessage(string message, string type)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = message;
            pnlMessage.CssClass = ""; // Reset
            lblMessage.CssClass = "";
        }
    }
}

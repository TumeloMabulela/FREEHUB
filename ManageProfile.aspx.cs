using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;

namespace FreeHubProject
{
    public partial class ManageProfile : System.Web.UI.Page
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
                pnlMessage.Visible = false;
                ShowTab("update");
                LoadProfileData();
            }
        }

        private int GetUserId()
        {
            return Convert.ToInt32(Session["UserID"]);
        }

        // ============================================================
        // TAB NAVIGATION
        // ============================================================

        protected void btnTabUpdate_Click(object sender, EventArgs e)
        {
            ShowTab("update");
            LoadProfileData();
        }

        protected void btnTabDeactivateProfile_Click(object sender, EventArgs e)
        {
            ShowTab("deactivateProfile");
        }

        protected void btnTabDeactivateAccount_Click(object sender, EventArgs e)
        {
            ShowTab("deactivateAccount");
        }

        private void ShowTab(string tab)
        {
            pnlUpdateProfile.Visible = tab == "update";
            pnlDeactivateProfile.Visible = tab == "deactivateProfile";
            pnlDeactivateAccount.Visible = tab == "deactivateAccount";

            btnTabUpdate.CssClass = tab == "update" ? "profile-tab active-tab" : "profile-tab";
            btnTabDeactivateProfile.CssClass = tab == "deactivateProfile" ? "profile-tab active-tab" : "profile-tab";
            btnTabDeactivateAccount.CssClass = tab == "deactivateAccount" ? "profile-tab active-tab" : "profile-tab";
        }

        // ============================================================
        // A500: UPDATE PROFILE
        // ============================================================

        private void LoadProfileData()
        {
            int userId = GetUserId();

            try
            {
                // Load user data
                DataRow user = DatabaseHelper.GetUserById(userId);
                if (user != null)
                {
                    txtFirstName.Text = Convert.ToString(user["firstName"]);
                    txtLastName.Text = Convert.ToString(user["lastName"]);
                    txtEmail.Text = Convert.ToString(user["email"]);
                    txtContactNumber.Text = Convert.ToString(user["contactNumber"]);
                }

                string userType = Session["UserType"] as string ?? "";

                // Load freelancer fields
                if (userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
                {
                    pnlFreelancerFields.Visible = true;
                    pnlEmployerFields.Visible = false;

                    DataRow freelancer = DatabaseHelper.GetFreelancerByUserId(userId);
                    if (freelancer != null)
                    {
                        txtUpdateSkills.Text = Convert.ToString(freelancer["skills"]);
                        txtUpdateExperience.Text = Convert.ToString(freelancer["experience"]);
                        txtUpdatePortfolio.Text = Convert.ToString(freelancer["portfolioLinks"]);
                        txtUpdateRate.Text = Convert.ToDecimal(freelancer["hourlyRate"]).ToString("0");
                    }
                }
                // Load employer fields
                else if (userType.Equals("Employer", StringComparison.OrdinalIgnoreCase))
                {
                    pnlFreelancerFields.Visible = false;
                    pnlEmployerFields.Visible = true;

                    DataRow employer = DatabaseHelper.GetEmployerByUserId(userId);
                    if (employer != null)
                    {
                        txtUpdateCompanyName.Text = Convert.ToString(employer["companyName"]);
                        ddlUpdateIndustry.SelectedValue = Convert.ToString(employer["industry"]);
                        txtUpdateDescription.Text = Convert.ToString(employer["description"]);
                    }
                }
                else
                {
                    pnlFreelancerFields.Visible = false;
                    pnlEmployerFields.Visible = false;
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading profile: " + ex.Message, false);
            }
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtFirstName.Text) ||
                string.IsNullOrWhiteSpace(txtLastName.Text))
            {
                ShowMessage("First name and last name are required.", false);
                return;
            }

            int userId = GetUserId();

            try
            {
                // Update user table
                string userQuery = @"UPDATE [User] SET firstName = @FirstName, lastName = @LastName,
                                    contactNumber = @ContactNumber WHERE userID = @UserID";

                DatabaseHelper.ExecuteNonQuery(userQuery,
                    new SqlParameter("@FirstName", txtFirstName.Text.Trim()),
                    new SqlParameter("@LastName", txtLastName.Text.Trim()),
                    new SqlParameter("@ContactNumber",
                        string.IsNullOrWhiteSpace(txtContactNumber.Text)
                            ? (object)DBNull.Value : txtContactNumber.Text.Trim()),
                    new SqlParameter("@UserID", userId));

                // Update session
                Session["FirstName"] = txtFirstName.Text.Trim();
                Session["LastName"] = txtLastName.Text.Trim();

                string userType = Session["UserType"] as string ?? "";

                // Update freelancer profile
                if (userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
                {
                    string flQuery = @"UPDATE Freelancer SET skills = @Skills, experience = @Experience,
                                      portfolioLinks = @Portfolio, hourlyRate = @Rate WHERE userID = @UserID";

                    decimal rate;
                    decimal.TryParse(txtUpdateRate.Text, out rate);

                    DatabaseHelper.ExecuteNonQuery(flQuery,
                        new SqlParameter("@Skills", txtUpdateSkills.Text.Trim()),
                        new SqlParameter("@Experience", txtUpdateExperience.Text.Trim()),
                        new SqlParameter("@Portfolio", txtUpdatePortfolio.Text.Trim()),
                        new SqlParameter("@Rate", rate),
                        new SqlParameter("@UserID", userId));
                }
                // Update employer profile
                else if (userType.Equals("Employer", StringComparison.OrdinalIgnoreCase))
                {
                    string emQuery = @"UPDATE Employer SET companyName = @Company, industry = @Industry,
                                      description = @Description WHERE userID = @UserID";

                    DatabaseHelper.ExecuteNonQuery(emQuery,
                        new SqlParameter("@Company", txtUpdateCompanyName.Text.Trim()),
                        new SqlParameter("@Industry", ddlUpdateIndustry.SelectedValue),
                        new SqlParameter("@Description", txtUpdateDescription.Text.Trim()),
                        new SqlParameter("@UserID", userId));
                }

                ShowMessage("Profile updated successfully!", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error saving profile: " + ex.Message, false);
            }
        }

        // ============================================================
        // A400: DEACTIVATE PROFILE
        // ============================================================

        protected void btnDeactivateProfile_Click(object sender, EventArgs e)
        {
            if (!chkConfirmDeactivateProfile.Checked)
            {
                ShowMessage("Please confirm that you understand the consequences.", false);
                return;
            }

            int userId = GetUserId();

            try
            {
                // Set account status to Inactive (profile hidden but account still exists)
                string query = "UPDATE [User] SET accountStatus = 'Inactive' WHERE userID = @UserID";
                DatabaseHelper.ExecuteNonQuery(query, new SqlParameter("@UserID", userId));

                Session["AccountStatus"] = "Inactive";
                ShowMessage("Profile deactivated successfully. Your profile is now hidden from other users. You can reactivate it anytime from your settings.", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        // ============================================================
        // A600: DEACTIVATE ACCOUNT
        // ============================================================

        protected void btnDeactivateAccount_Click(object sender, EventArgs e)
        {
            if (!chkConfirmDeactivateAccount.Checked)
            {
                ShowMessage("Please confirm that you understand the consequences.", false);
                return;
            }

            int userId = GetUserId();

            try
            {
                // Set account status to Suspended
                string query = "UPDATE [User] SET accountStatus = 'Suspended' WHERE userID = @UserID";
                DatabaseHelper.ExecuteNonQuery(query, new SqlParameter("@UserID", userId));

                // Log out the user
                Session.Clear();
                Session.Abandon();
                FormsAuthentication.SignOut();
                Response.Redirect("Login.aspx");
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = message;
            pnlMessage.CssClass = success ? "post-status post-success" : "post-status post-error";
        }
    }
}

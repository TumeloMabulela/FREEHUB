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

        private string GetUserType()
        {
            return Session["UserType"] as string ?? "User";
        }

        // ============================================================
        // TAB NAVIGATION
        // ============================================================

        protected void btnTabUpdate_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = false;
            ShowTab("update");
            LoadProfileData();
        }

        protected void btnTabDeactivateProfile_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = false;
            ShowTab("deactivateProfile");
            SetupDeactivateProfileTab();
        }

        protected void btnTabDeactivateAccount_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = false;
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
        // DEACTIVATE PROFILE TAB SETUP
        // ============================================================

        private void SetupDeactivateProfileTab()
        {
            string userType = GetUserType();
            int userId = GetUserId();
            string profileStatus = DatabaseHelper.GetProfileStatus(userId, userType);

            // Set role-specific headings
            litHeadingRole.Text = userType;
            litSubtitleRole.Text = userType;

            // Show role-specific warning panel
            pnlWarningFreelancer.Visible = userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase);
            pnlWarningEmployer.Visible = userType.Equals("Employer", StringComparison.OrdinalIgnoreCase);

            if (profileStatus == "Deactivated")
            {
                // Profile already deactivated - show reactivation
                pnlDeactivateReady.Visible = false;
                pnlReactivateProfile.Visible = true;
                litDeactivatedRole.Text = userType;
            }
            else
            {
                // Profile is active - show deactivation form
                pnlDeactivateReady.Visible = true;
                pnlReactivateProfile.Visible = false;
            }
        }

        // ============================================================
        // A500: UPDATE PROFILE
        // ============================================================

        private void LoadProfileData()
        {
            int userId = GetUserId();
            string userType = GetUserType();

            // Set "Currently logged in as" badge
            litLoggedInRole.Text = userType;

            try
            {
                DataRow user = DatabaseHelper.GetUserById(userId);
                if (user != null)
                {
                    txtFirstName.Text = Convert.ToString(user["firstName"]);
                    txtLastName.Text = Convert.ToString(user["lastName"]);
                    txtEmail.Text = Convert.ToString(user["email"]);
                    txtContactNumber.Text = Convert.ToString(user["contactNumber"]);
                }

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
                string userQuery = @"UPDATE [User] SET firstName = @FirstName, lastName = @LastName,
                                    contactNumber = @ContactNumber WHERE userID = @UserID";

                DatabaseHelper.ExecuteNonQuery(userQuery,
                    new SqlParameter("@FirstName", txtFirstName.Text.Trim()),
                    new SqlParameter("@LastName", txtLastName.Text.Trim()),
                    new SqlParameter("@ContactNumber",
                        string.IsNullOrWhiteSpace(txtContactNumber.Text)
                            ? (object)DBNull.Value : txtContactNumber.Text.Trim()),
                    new SqlParameter("@UserID", userId));

                Session["FirstName"] = txtFirstName.Text.Trim();
                Session["LastName"] = txtLastName.Text.Trim();

                string userType = GetUserType();

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

        protected void btnCancelDeactivate_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = false;
            ShowTab("update");
            LoadProfileData();
        }

        protected void btnShowDeactivateConfirm_Click(object sender, EventArgs e) { }

        protected void btnDeactivateProfile_Click(object sender, EventArgs e)
        {
            int userId = GetUserId();
            string currentRole = GetUserType();

            try
            {
                // Deactivate the profile in ProfileStatus table
                DatabaseHelper.DeactivateUserProfile(userId, currentRole);

                // Cancel open projects if employer
                if (currentRole.Equals("Employer", StringComparison.OrdinalIgnoreCase))
                {
                    DatabaseHelper.ExecuteNonQuery(
                        @"UPDATE Project SET projectStatus = 'Cancelled'
                          WHERE employerID IN (SELECT employerID FROM Employer WHERE userID = @UserID)
                            AND projectStatus = 'Open'",
                        new SqlParameter("@UserID", userId));
                }

                // Withdraw pending proposals if freelancer
                if (currentRole.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
                {
                    DatabaseHelper.ExecuteNonQuery(
                        @"UPDATE Proposal SET status = 'Withdrawn'
                          WHERE freelancerID IN (SELECT freelancerID FROM Freelancer WHERE userID = @UserID)
                            AND status = 'Pending'",
                        new SqlParameter("@UserID", userId));
                }

                // Update user account status
                DatabaseHelper.ExecuteNonQuery(
                    "UPDATE [User] SET accountStatus = 'Inactive' WHERE userID = @UserID",
                    new SqlParameter("@UserID", userId));

                Session["AccountStatus"] = "Inactive";

                // Check if there's another active profile to switch to
                string freelancerStatus, employerStatus;
                DatabaseHelper.GetUserProfileStatuses(userId, out freelancerStatus, out employerStatus);

                string otherRole = currentRole.Equals("Freelancer", StringComparison.OrdinalIgnoreCase)
                    ? "Employer" : "Freelancer";
                string otherStatus = currentRole.Equals("Freelancer", StringComparison.OrdinalIgnoreCase)
                    ? employerStatus : freelancerStatus;

                if (otherStatus == "Active")
                {
                    // Switch to other profile
                    DatabaseHelper.ExecuteNonQuery(
                        "UPDATE [User] SET userType = @UserType, accountStatus = 'Active' WHERE userID = @UserID",
                        new SqlParameter("@UserType", otherRole),
                        new SqlParameter("@UserID", userId));
                    Session["UserType"] = otherRole;
                    Session["AccountStatus"] = "Active";

                    ShowMessage("Your " + currentRole + " profile has been deactivated. Switched to " + otherRole + " profile.", true);
                    ClientScript.RegisterStartupScript(this.GetType(), "redirect",
                        "setTimeout(function() { window.location.href = 'Dashboard.aspx'; }, 2500);", true);
                }
                else
                {
                    // No other active profile - redirect to ChooseRole
                    ShowMessage("Your " + currentRole + " profile has been deactivated.", true);
                    ClientScript.RegisterStartupScript(this.GetType(), "redirect",
                        "setTimeout(function() { window.location.href = 'ChooseRole.aspx'; }, 2500);", true);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void btnReactivateProfile_Click(object sender, EventArgs e)
        {
            int userId = GetUserId();
            string userType = GetUserType();

            try
            {
                DatabaseHelper.ReactivateUserProfile(userId, userType);
                Session["AccountStatus"] = "Active";

                ShowMessage("Your " + userType + " profile has been reactivated successfully!", true);
                ClientScript.RegisterStartupScript(this.GetType(), "redirect",
                    "setTimeout(function() { window.location.href = 'Dashboard.aspx'; }, 2000);", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        // ============================================================
        // A600: DEACTIVATE ACCOUNT
        // ============================================================

        protected void btnCancelDelete_Click(object sender, EventArgs e)
        {
            pnlMessage.Visible = false;
            ShowTab("update");
            LoadProfileData();
        }

        protected void btnShowDeleteConfirm_Click(object sender, EventArgs e) { }

        protected void btnDeactivateAccount_Click(object sender, EventArgs e)
        {
            int userId = GetUserId();

            try
            {
                // Create DeletedAccount bin table if needed
                string createBinTable = @"
                    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DeletedAccount')
                    BEGIN
                        CREATE TABLE dbo.DeletedAccount (
                            deleteID INT IDENTITY(1,1) PRIMARY KEY,
                            userID INT NOT NULL,
                            firstName NVARCHAR(100),
                            lastName NVARCHAR(100),
                            email NVARCHAR(255),
                            username NVARCHAR(100),
                            userType NVARCHAR(20),
                            deletedDate DATETIME NOT NULL DEFAULT GETDATE(),
                            reason NVARCHAR(500) DEFAULT 'User requested account deletion',
                            projectCount INT DEFAULT 0,
                            proposalCount INT DEFAULT 0,
                            walletBalance DECIMAL(12,2) DEFAULT 0.00
                        )
                    END";
                DatabaseHelper.ExecuteNonQuery(createBinTable);

                DataRow user = DatabaseHelper.GetUserById(userId);
                string firstName = Convert.ToString(user["firstName"]);
                string lastName = Convert.ToString(user["lastName"]);
                string email = Convert.ToString(user["email"]);
                string username = Convert.ToString(user["username"]);
                string userType = Convert.ToString(user["userType"]);

                object projCount = DatabaseHelper.ExecuteScalar(
                    @"SELECT COUNT(*) FROM Project p INNER JOIN Employer e ON p.employerID = e.employerID WHERE e.userID = @UserID",
                    new SqlParameter("@UserID", userId));

                object propCount = DatabaseHelper.ExecuteScalar(
                    @"SELECT COUNT(*) FROM Proposal pr INNER JOIN Freelancer f ON pr.freelancerID = f.freelancerID WHERE f.userID = @UserID",
                    new SqlParameter("@UserID", userId));

                decimal walletBalance = 0;
                DataRow wallet = DatabaseHelper.GetWalletByUserId(userId);
                if (wallet != null)
                    walletBalance = Convert.ToDecimal(wallet["balance"]);

                string insertBin = @"INSERT INTO DeletedAccount (userID, firstName, lastName, email, username, userType, projectCount, proposalCount, walletBalance)
                    VALUES (@UserID, @FirstName, @LastName, @Email, @Username, @UserType, @ProjectCount, @ProposalCount, @WalletBalance)";

                DatabaseHelper.ExecuteNonQuery(insertBin,
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@FirstName", firstName),
                    new SqlParameter("@LastName", lastName),
                    new SqlParameter("@Email", email),
                    new SqlParameter("@Username", username),
                    new SqlParameter("@UserType", userType),
                    new SqlParameter("@ProjectCount", Convert.ToInt32(projCount ?? 0)),
                    new SqlParameter("@ProposalCount", Convert.ToInt32(propCount ?? 0)),
                    new SqlParameter("@WalletBalance", walletBalance));

                DatabaseHelper.ExecuteNonQuery("UPDATE [User] SET accountStatus = 'Deleted' WHERE userID = @UserID",
                    new SqlParameter("@UserID", userId));

                DatabaseHelper.ExecuteNonQuery(
                    @"UPDATE Project SET projectStatus = 'Cancelled' WHERE employerID IN (SELECT employerID FROM Employer WHERE userID = @UserID) AND projectStatus IN ('Open', 'In Progress')",
                    new SqlParameter("@UserID", userId));

                DatabaseHelper.ExecuteNonQuery(
                    @"UPDATE Proposal SET status = 'Withdrawn' WHERE freelancerID IN (SELECT freelancerID FROM Freelancer WHERE userID = @UserID) AND status = 'Pending'",
                    new SqlParameter("@UserID", userId));

                DatabaseHelper.ExecuteNonQuery("UPDATE Wallet SET walletStatus = 'Frozen' WHERE userID = @UserID",
                    new SqlParameter("@UserID", userId));

                Session.Clear();
                Session.Abandon();
                FormsAuthentication.SignOut();
                Response.Redirect("Login.aspx?deleted=1");
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

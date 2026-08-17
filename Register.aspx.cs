using System;

namespace FreeHubProject
{
    public partial class Register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            lblMessage.CssClass = "register-message error-message";

            if (string.IsNullOrWhiteSpace(txtFirstName.Text) ||
                string.IsNullOrWhiteSpace(txtLastName.Text) ||
                string.IsNullOrWhiteSpace(txtEmail.Text) ||
                string.IsNullOrWhiteSpace(txtPassword.Text) ||
                string.IsNullOrWhiteSpace(txtConfirmPassword.Text))
            {
                lblMessage.Text = "Please complete all the required fields.";
                return;
            }

            if (txtPassword.Text != txtConfirmPassword.Text)
            {
                lblMessage.Text = "The passwords do not match.";
                return;
            }

            if (txtPassword.Text.Length < 6)
            {
                lblMessage.Text = "Password must be at least 6 characters long.";
                return;
            }

            if (!chkTerms.Checked)
            {
                lblMessage.Text = "Please accept the Terms and Conditions.";
                return;
            }

            try
            {
                if (DatabaseHelper.EmailExists(txtEmail.Text.Trim()))
                {
                    lblMessage.Text = "An account with this email address already exists.";
                    return;
                }

                string email = DatabaseHelper.FormatEmail(txtEmail.Text);
                string username = email;
                string phone = txtPhone.Text.Trim();

                // Register with name but no role — user will choose role on first login
                int newUserID = DatabaseHelper.RegisterUser(
                    DatabaseHelper.CapitalizeName(txtFirstName.Text),
                    DatabaseHelper.CapitalizeName(txtLastName.Text),
                    email,
                    phone,
                    username,
                    txtPassword.Text,
                    "None"
                );

                if (newUserID > 0)
                {
                    // Generate and save verification token
                    string token = EmailHelper.GenerateToken();
                    DatabaseHelper.ExecuteNonQuery(
                        "UPDATE [User] SET verificationToken = @Token, emailVerified = 0 WHERE userID = @UserID",
                        new System.Data.SqlClient.SqlParameter("@Token", token),
                        new System.Data.SqlClient.SqlParameter("@UserID", newUserID));

                    // Send verification email
                    EmailHelper.SendVerificationEmail(email, token);

                    string welcomeMsg = "Welcome to FreeHUB! Your account has been created. Please verify your email and choose your role to get started.";
                    NotificationHelper.CreateNotification(newUserID, "System", welcomeMsg);

                    lblMessage.CssClass = "register-message success-message";
                    lblMessage.Text = "Account created! Please check your email to verify your account.";
                    ClientScript.RegisterStartupScript(this.GetType(), "redirect",
                        "setTimeout(function() { window.location.href = 'Login.aspx'; }, 3000);", true);
                }
                else
                {
                    lblMessage.Text = "An error occurred while creating your account. Please try again.";
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Database connection error: " + ex.Message;
            }
        }
    }
}

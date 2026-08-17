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

            if (string.IsNullOrWhiteSpace(txtEmail.Text) ||
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

                // Register with no name and no role — user will set these on first login
                int newUserID = DatabaseHelper.RegisterUser(
                    "",
                    "",
                    email,
                    "",
                    username,
                    txtPassword.Text,
                    "None"
                );

                if (newUserID > 0)
                {
                    string welcomeMsg = "Welcome to FreeHUB! Your account has been created. Please log in and choose your role to get started.";
                    NotificationHelper.CreateNotification(newUserID, "System", welcomeMsg);

                    lblMessage.CssClass = "register-message success-message";
                    lblMessage.Text = "Account created successfully! Redirecting to login...";
                    ClientScript.RegisterStartupScript(this.GetType(), "redirect",
                        "setTimeout(function() { window.location.href = 'Login.aspx'; }, 2000);", true);
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

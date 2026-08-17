using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class ForgotPassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnSendReset_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtEmail.Text))
            {
                ShowMessage("Please enter your email address.", "error");
                return;
            }

            try
            {
                string email = txtEmail.Text.Trim().ToLower();

                // Check if user exists
                DataTable dt = DatabaseHelper.GetDataTable(
                    "SELECT userID FROM [User] WHERE email = @Email",
                    new SqlParameter("@Email", email));

                if (dt.Rows.Count == 0)
                {
                    // Don't reveal that the email doesn't exist (security)
                    ShowMessage("If an account exists with this email, a reset link has been sent.", "success");
                    return;
                }

                int userId = Convert.ToInt32(dt.Rows[0]["userID"]);

                // Generate reset token with 1 hour expiry
                string token = EmailHelper.GenerateToken();
                DateTime expiry = DateTime.UtcNow.AddHours(1);

                DatabaseHelper.ExecuteNonQuery(
                    "UPDATE [User] SET resetToken = @Token, resetTokenExpiry = @Expiry WHERE userID = @UserID",
                    new SqlParameter("@Token", token),
                    new SqlParameter("@Expiry", expiry),
                    new SqlParameter("@UserID", userId));

                // Send reset email
                bool sent = EmailHelper.SendPasswordResetEmail(email, token);

                if (sent)
                {
                    ShowMessage("A password reset link has been sent to your email.", "success");
                }
                else
                {
                    ShowMessage("Unable to send email. Please try again later.", "error");
                }
            }
            catch (Exception)
            {
                ShowMessage("An error occurred. Please try again.", "error");
            }
        }

        private void ShowMessage(string message, string type)
        {
            lblMessage.Text = message;
            if (type == "success")
                lblMessage.ForeColor = System.Drawing.Color.FromArgb(22, 101, 52);
            else
                lblMessage.ForeColor = System.Drawing.Color.FromArgb(153, 27, 27);
        }
    }
}

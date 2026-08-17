using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            string token = Request.QueryString["token"];

            if (string.IsNullOrWhiteSpace(token))
            {
                ShowInvalid();
                return;
            }

            // Verify token is valid and not expired
            DataTable dt = DatabaseHelper.GetDataTable(
                "SELECT userID FROM [User] WHERE resetToken = @Token AND resetTokenExpiry > @Now",
                new SqlParameter("@Token", token),
                new SqlParameter("@Now", DateTime.UtcNow));

            if (dt.Rows.Count == 0)
            {
                ShowInvalid();
            }
        }

        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            string token = Request.QueryString["token"];

            if (string.IsNullOrWhiteSpace(token))
            {
                ShowInvalid();
                return;
            }

            if (string.IsNullOrWhiteSpace(txtNewPassword.Text) ||
                string.IsNullOrWhiteSpace(txtConfirmPassword.Text))
            {
                ShowMessage("Please fill in both password fields.", "error");
                return;
            }

            if (txtNewPassword.Text != txtConfirmPassword.Text)
            {
                ShowMessage("Passwords do not match.", "error");
                return;
            }

            if (txtNewPassword.Text.Length < 6)
            {
                ShowMessage("Password must be at least 6 characters.", "error");
                return;
            }

            try
            {
                // Verify token again
                DataTable dt = DatabaseHelper.GetDataTable(
                    "SELECT userID FROM [User] WHERE resetToken = @Token AND resetTokenExpiry > @Now",
                    new SqlParameter("@Token", token),
                    new SqlParameter("@Now", DateTime.UtcNow));

                if (dt.Rows.Count == 0)
                {
                    ShowInvalid();
                    return;
                }

                int userId = Convert.ToInt32(dt.Rows[0]["userID"]);
                string hashedPassword = DatabaseHelper.HashPassword(txtNewPassword.Text);

                // Update password and clear reset token
                DatabaseHelper.ExecuteNonQuery(
                    "UPDATE [User] SET password = @Password, resetToken = NULL, resetTokenExpiry = NULL WHERE userID = @UserID",
                    new SqlParameter("@Password", hashedPassword),
                    new SqlParameter("@UserID", userId));

                pnlReset.Visible = false;
                pnlSuccess.Visible = true;
            }
            catch (Exception)
            {
                ShowMessage("An error occurred. Please try again.", "error");
            }
        }

        private void ShowInvalid()
        {
            pnlReset.Visible = false;
            pnlInvalid.Visible = true;
        }

        private void ShowMessage(string message, string type)
        {
            lblMessage.Text = message;
            if (type == "error")
                lblMessage.ForeColor = System.Drawing.Color.FromArgb(153, 27, 27);
            else
                lblMessage.ForeColor = System.Drawing.Color.FromArgb(22, 101, 52);
        }
    }
}

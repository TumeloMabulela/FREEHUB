using System;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class VerifyEmail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            string token = Request.QueryString["token"];

            if (string.IsNullOrWhiteSpace(token))
            {
                ShowError("Invalid verification link.");
                return;
            }

            try
            {
                // Find user with this token
                var dt = DatabaseHelper.GetDataTable(
                    "SELECT userID FROM [User] WHERE verificationToken = @Token AND emailVerified = 0",
                    new SqlParameter("@Token", token));

                if (dt.Rows.Count == 0)
                {
                    ShowError("This link is invalid or has already been used.");
                    return;
                }

                int userId = Convert.ToInt32(dt.Rows[0]["userID"]);

                // Mark email as verified and clear token
                DatabaseHelper.ExecuteNonQuery(
                    "UPDATE [User] SET emailVerified = 1, verificationToken = NULL WHERE userID = @UserID",
                    new SqlParameter("@UserID", userId));

                pnlSuccess.Visible = true;
                pnlError.Visible = false;
            }
            catch (Exception)
            {
                ShowError("An error occurred during verification. Please try again.");
            }
        }

        private void ShowError(string message)
        {
            pnlSuccess.Visible = false;
            pnlError.Visible = true;
            lblError.Text = message;
        }
    }
}

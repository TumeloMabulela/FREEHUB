using System;
using System.Data.SqlClient;
using System.Web.UI;

namespace FreeHubProject
{
    public partial class Feedback : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            string category = (ddlCategory.SelectedValue ?? "").Trim();
            string message = (txtMessage.Text ?? "").Trim();

            // Server-side validation.
            if (string.IsNullOrEmpty(category))
            {
                ShowError("Please select a feedback category.");
                return;
            }
            if (message.Length < 10)
            {
                ShowError("Please enter your feedback (at least 10 characters).");
                return;
            }

            try
            {
                EnsureFeedbackTable();

                // Access control: only a logged-in user can submit, and the feedback is
                // stored against their authenticated account id (not a client-supplied id).
                int userId = AuthHelper.GetCurrentUserId(this);
                string insert = @"INSERT INTO dbo.Feedback (userID, category, message)
                                  VALUES (@UserID, @Category, @Message)";
                DatabaseHelper.ExecuteNonQuery(insert,
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@Category", category),
                    new SqlParameter("@Message", message));

                pnlForm.Visible = false;
                pnlError.Visible = false;
                pnlConfirm.Visible = true;
                lblConfirm.Text = "Thank you for your feedback! We appreciate you helping us improve FreeHUB.";
            }
            catch (Exception)
            {
                ShowError("Sorry, we couldn't submit your feedback right now. Please try again later.");
            }
        }

        private void ShowError(string msg)
        {
            MessageHelper.Error(this, msg);
        }

        /// <summary>Creates the Feedback table once if it doesn't already exist.</summary>
        private static void EnsureFeedbackTable()
        {
            string query = @"
                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Feedback')
                BEGIN
                    CREATE TABLE dbo.Feedback (
                        feedbackID  INT IDENTITY(1,1) PRIMARY KEY,
                        userID      INT NOT NULL,
                        category    NVARCHAR(100) NOT NULL,
                        message     NVARCHAR(MAX) NOT NULL,
                        dateCreated DATETIME NOT NULL DEFAULT GETDATE(),
                        CONSTRAINT FK_Feedback_User FOREIGN KEY (userID) REFERENCES dbo.[User](userID)
                    )
                END";
            DatabaseHelper.ExecuteNonQuery(query);
        }
    }
}

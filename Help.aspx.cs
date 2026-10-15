using System;
using System.Data.SqlClient;
using System.Web.UI;

namespace FreeHubProject
{
    public partial class Help : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            string topic = (ddlTopic.SelectedValue ?? "").Trim();
            string subject = (txtSubject.Text ?? "").Trim();
            string message = (txtMessage.Text ?? "").Trim();

            // Server-side validation.
            if (string.IsNullOrEmpty(topic))
            {
                ShowError("Please select a topic for your request.");
                return;
            }
            if (string.IsNullOrEmpty(subject))
            {
                ShowError("Please enter a subject.");
                return;
            }
            if (message.Length < 10)
            {
                ShowError("Please describe your issue (at least 10 characters).");
                return;
            }

            try
            {
                EnsureSupportTable();

                int userId = AuthHelper.GetCurrentUserId(this);
                string insert = @"INSERT INTO dbo.SupportRequest (userID, topic, subject, message, status)
                                  VALUES (@UserID, @Topic, @Subject, @Message, 'Open')";
                DatabaseHelper.ExecuteNonQuery(insert,
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@Topic", topic),
                    new SqlParameter("@Subject", subject),
                    new SqlParameter("@Message", message));

                // Confirmation + hide the form so it isn't resubmitted.
                pnlForm.Visible = false;
                pnlError.Visible = false;
                pnlConfirm.Visible = true;
                lblConfirm.Text = "Thank you. Your support request has been submitted and our team will review it.";
            }
            catch (Exception)
            {
                ShowError("Sorry, we couldn't submit your request right now. Please try again later.");
            }
        }

        private void ShowError(string msg)
        {
            MessageHelper.Error(this, msg);
        }

        /// <summary>Creates the SupportRequest table once if it doesn't already exist.</summary>
        private static void EnsureSupportTable()
        {
            string query = @"
                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SupportRequest')
                BEGIN
                    CREATE TABLE dbo.SupportRequest (
                        requestID   INT IDENTITY(1,1) PRIMARY KEY,
                        userID      INT NOT NULL,
                        topic       NVARCHAR(100) NOT NULL,
                        subject     NVARCHAR(150) NOT NULL,
                        message     NVARCHAR(MAX) NOT NULL,
                        status      NVARCHAR(20) NOT NULL DEFAULT 'Open',
                        dateCreated DATETIME NOT NULL DEFAULT GETDATE(),
                        CONSTRAINT FK_SupportRequest_User FOREIGN KEY (userID) REFERENCES dbo.[User](userID)
                    )
                END";
            DatabaseHelper.ExecuteNonQuery(query);
        }
    }
}

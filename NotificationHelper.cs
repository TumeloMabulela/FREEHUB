using System;
using System.Configuration;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public static class NotificationHelper
    {
        // Connection string loaded directly from Web.config
        private static readonly string _connStr = ConfigurationManager.ConnectionStrings["FreeHubDB"]?.ConnectionString;

        /// <summary>
        /// Creates and inserts an unread notification into FreeHubDB for a target user.
        /// </summary>
        /// <param name="recipientUserId">The userID of the account receiving the notification.</param>
        /// <param name="type">Type: Message, Project, Proposal, Payment, Welcome, System</param>
        /// <param name="content">The text detail displayed to the user.</param>
        public static void CreateNotification(int recipientUserId, string type, string content)
        {
            if (recipientUserId <= 0) return;

            string query = @"
                INSERT INTO dbo.Notification (userID, type, content, status, notificationTimestamp)
                VALUES (@UserID, @Type, @Content, 'Unread', GETDATE())";

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", recipientUserId);
                    cmd.Parameters.AddWithValue("@Type", type);
                    cmd.Parameters.AddWithValue("@Content", content);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }
    }
}
using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace FreeHubProject
{
    public static class NotificationHelper
    {
        private static readonly string _connStr = ConfigurationManager.ConnectionStrings["FreeHubDB"]?.ConnectionString;

        public static void CreateNotification(int userID, string notificationType, string message)
        {
            string query = @"
                INSERT INTO dbo.Notification (userID, type, content, status, notificationTimestamp)
                VALUES (@UserID, @Type, @Content, 'Unread', GETDATE())";

            DatabaseHelper.ExecuteNonQuery(query,
                new SqlParameter("@UserID", userID),
                new SqlParameter("@Type", string.IsNullOrEmpty(notificationType) ? "System" : notificationType),
                new SqlParameter("@Content", string.IsNullOrEmpty(message) ? "" : message));
        }

        public static void BroadcastNotification(int excludeUserID, string notificationType, string message)
        {
            string query = @"
                INSERT INTO dbo.Notification (userID, type, content, status, notificationTimestamp)
                SELECT userID, @Type, @Content, 'Unread', GETDATE()
                FROM dbo.[User]
                WHERE userID != @ExcludeUserID AND accountStatus = 'Active'";

            DatabaseHelper.ExecuteNonQuery(query,
                new SqlParameter("@Type", string.IsNullOrEmpty(notificationType) ? "System" : notificationType),
                new SqlParameter("@Content", string.IsNullOrEmpty(message) ? "" : message),
                new SqlParameter("@ExcludeUserID", excludeUserID));
        }

        public static void NotifyProjectStakeholders(int projectID, string notificationType, string message)
        {
            // 1. Fetch project title dynamically if needed for fallback messages
            string projectTitle = "Project";
            try
            {
                string titleQuery = "SELECT title FROM dbo.Project WHERE projectID = @ProjectID";
                object titleResult = DatabaseHelper.ExecuteScalar(titleQuery, new SqlParameter("@ProjectID", projectID));
                if (titleResult != null && titleResult != DBNull.Value)
                {
                    projectTitle = titleResult.ToString();
                }
            }
            catch { }

            // If message is generic, make it contextual using the fetched project title
            string finalMessage = message;
            if (string.IsNullOrEmpty(finalMessage))
            {
                finalMessage = $"Update regarding project \"{projectTitle}\".";
            }

            // 2. Identify all stakeholders (Employer + Freelancers with proposals/contracts)
            string query = @"
                SELECT DISTINCT u.userID 
                FROM dbo.[User] u
                WHERE u.userID IN (
                    SELECT e.userID FROM dbo.Project p INNER JOIN dbo.Employer e ON p.employerID = e.employerID WHERE p.projectID = @ProjectID
                    UNION
                    SELECT us.userID FROM dbo.Proposal pr INNER JOIN dbo.Freelancer f ON pr.freelancerID = f.freelancerID INNER JOIN dbo.[User] us ON f.userID = us.userID WHERE pr.projectID = @ProjectID
                )";

            DataTable dt = DatabaseHelper.ExecuteQuery(query, new SqlParameter("@ProjectID", projectID));

            foreach (DataRow row in dt.Rows)
            {
                int uid = Convert.ToInt32(row["userID"]);
                CreateNotification(uid, notificationType, finalMessage);
            }
        }
    }
}
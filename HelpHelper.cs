using System;

namespace FreeHubProject
{
    /// <summary>
    /// Routes "Help / Contact Support" actions into the admin support inbox.
    /// Pressing Help anywhere in the app sends the user's query as a chat
    /// message to the platform admin (User #1) and raises an admin notification,
    /// then the user is taken to their chat with the admin.
    /// </summary>
    public static class HelpHelper
    {
        /// <summary>
        /// Send a help/support message from a user to the admin inbox.
        /// Creates a Message (receiver = admin) and notifies the admin.
        /// Returns the new messageID (0 on failure).
        /// </summary>
        public static int SendHelpMessage(int fromUserId, string query, string context = null)
        {
            if (fromUserId <= 0) return 0;

            string body = string.IsNullOrWhiteSpace(query)
                ? "A user has requested help."
                : query.Trim();

            if (!string.IsNullOrWhiteSpace(context))
            {
                body = "[" + context.Trim() + "] " + body;
            }

            int messageId = DatabaseHelper.SendMessage(
                fromUserId,
                DatabaseHelper.AdminUserId,
                body);

            // Tell the admin there is a new support message.
            string senderName = GetUserDisplayName(fromUserId);
            NotificationHelper.CreateNotification(
                DatabaseHelper.AdminUserId,
                "Help",
                "New support message from " + senderName + ".");

            return messageId;
        }

        /// <summary>
        /// Open the current user's support chat with the admin. If a query is
        /// supplied it is sent first, then the user is redirected to their
        /// chat with the admin (StartChat deep-linked to the admin user).
        /// </summary>
        public static void StartHelpChat(System.Web.UI.Page page, string query = null, string context = null)
        {
            int userId = AuthHelper.GetCurrentUserId(page);
            if (userId <= 0)
            {
                page.Response.Redirect("Login.aspx");
                return;
            }

            // An admin pressing Help has nothing to escalate to; send to the inbox.
            if (AuthHelper.IsInRole(page, "Admin"))
            {
                page.Response.Redirect("AdminInbox.aspx");
                return;
            }

            if (!string.IsNullOrWhiteSpace(query))
            {
                SendHelpMessage(userId, query, context);
            }

            // Deep-link the user's chat to the admin so the conversation opens directly.
            page.Response.Redirect("StartChat.aspx?help=1&userId=" + DatabaseHelper.AdminUserId);
        }

        private static string GetUserDisplayName(int userId)
        {
            try
            {
                var row = DatabaseHelper.GetUserById(userId);
                if (row != null)
                {
                    string name = (Convert.ToString(row["firstName"]) + " " + Convert.ToString(row["lastName"])).Trim();
                    if (!string.IsNullOrWhiteSpace(name)) return name;
                }
            }
            catch { }
            return "a user";
        }
    }
}

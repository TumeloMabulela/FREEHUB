using System;
using System.Data.SqlClient;
using System.Web.Security;

namespace FreeHubProject
{
    public partial class Site1 : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SetupNavigation();

            if (Session["UserID"] != null)
            {
                int userId = Convert.ToInt32(Session["UserID"]);
                string firstName = Session["FirstName"] as string ?? "";
                string lastName = Session["LastName"] as string ?? "";
                string userType = Session["UserType"] as string ?? "Freelancer";

                if (!string.IsNullOrEmpty(firstName) && !string.IsNullOrEmpty(lastName))
                {
                    litFullName.Text = $"{firstName} {lastName}";
                    if (litInitials != null)
                    {
                        litInitials.Text = $"{firstName[0]}{lastName[0]}".ToUpper();
                    }
                }
                if (litUserRole != null)
                {
                    litUserRole.Text = userType;
                }

            }
        }

        /// <summary>
        /// Compute the nav badges (unread notifications and unread messages) in PreRender,
        /// AFTER content-page event handlers (e.g. opening a chat marks its messages Read).
        /// Computing these in Page_Load would show a stale count for one extra postback.
        /// </summary>
        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (Session["UserID"] == null) return;
            int userId = Convert.ToInt32(Session["UserID"]);

            // Unread notifications badge (bell).
            try
            {
                string unreadQuery = "SELECT COUNT(*) FROM dbo.Notification WHERE userID = @UserID AND (status = 'Unread' OR status IS NULL)";
                object unreadResult = DatabaseHelper.ExecuteScalar(unreadQuery, new SqlParameter("@UserID", userId));
                int unreadCount = unreadResult != null ? Convert.ToInt32(unreadResult) : 0;

                litUnreadDot.Text = unreadCount > 0
                    ? $"<span style='position: absolute; top: -6px; right: -8px; background-color: #ef4444; color: white; border-radius: 50%; padding: 2px 6px; font-size: 10px; font-weight: bold; line-height: 1;'>{unreadCount}</span>"
                    : "";
            }
            catch
            {
                litUnreadDot.Text = "";
            }

            // Unread messages badge (Messages nav link).
            try
            {
                string msgUnreadQuery = "SELECT COUNT(*) FROM dbo.Message WHERE receiverID = @UserID AND status != 'Read'";
                object msgResult = DatabaseHelper.ExecuteScalar(msgUnreadQuery, new SqlParameter("@UserID", userId));
                int unreadMsgCount = msgResult != null ? Convert.ToInt32(msgResult) : 0;

                litUnreadMessageBadge.Text = unreadMsgCount > 0
                    ? $"<span style='background-color: #ef4444; color: white; border-radius: 50%; padding: 1px 6px; font-size: 9px; font-weight: bold; margin-left: 6px; display: inline-block; line-height: 1.2;'>{unreadMsgCount}</span>"
                    : "";
            }
            catch
            {
                litUnreadMessageBadge.Text = "";
            }
        }

        private void SetupNavigation()
        {
            bool loggedIn = Session["UserID"] != null;
            string userType = Session["UserType"] as string ?? "";
            string accountStatus = Session["AccountStatus"] as string ?? "";

            // Redirect deactivated/inactive/new users away from main pages to ChooseRole
            if (loggedIn)
            {
                string currentPage = System.IO.Path.GetFileName(Request.Url.AbsolutePath).ToLower();
                bool isChooseRolePage = currentPage == "chooserole.aspx" || currentPage == "createfreelancerprofile.aspx" || currentPage == "createemployerprofile.aspx";

                if (!isChooseRolePage && (userType == "None" || string.IsNullOrWhiteSpace(userType) || accountStatus == "Deactivated" || accountStatus == "Inactive"))
                {
                    Response.Redirect("ChooseRole.aspx");
                    return;
                }
            }

            if (loggedIn)
            {
                pnlLoggedInNav.Visible = true;
                pnlGuestButtons.Visible = false;
                pnlUserButtons.Visible = true;

                // Show role-specific navigation
                pnlEmployerNav.Visible =
                    userType.Equals("Employer", StringComparison.OrdinalIgnoreCase);

                pnlFreelancerNav.Visible =
                    userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase);

                // Set user display info
                string firstName = Session["FirstName"] as string ?? "";
                string lastName = Session["LastName"] as string ?? "";

                litFullName.Text = (firstName + " " + lastName).Trim();

                string initials = "";
                if (firstName.Length > 0) initials += firstName[0];
                if (lastName.Length > 0) initials += lastName[0];
                litInitials.Text = initials.ToUpper();

                litUserRole.Text = userType;
            }
            else
            {
                pnlLoggedInNav.Visible = false;
                pnlEmployerNav.Visible = false;
                pnlFreelancerNav.Visible = false;
                pnlGuestButtons.Visible = true;
                pnlUserButtons.Visible = false;
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            FormsAuthentication.SignOut();
            Response.Redirect("Login.aspx");
        }
    }
}
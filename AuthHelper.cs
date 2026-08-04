using System;
using System.Web;

namespace FreeHubProject
{
    /// <summary>
    /// Provides authentication checks for protected pages.
    /// Call AuthHelper.RequireLogin(this) in Page_Load of any page that requires authentication.
    /// </summary>
    public static class AuthHelper
    {
        /// <summary>
        /// Redirects to Login.aspx if the user is not logged in.
        /// Returns true if user is logged in, false if redirected.
        /// </summary>
        public static bool RequireLogin(System.Web.UI.Page page)
        {
            if (page.Session["UserID"] == null)
            {
                page.Response.Redirect("Login.aspx?returnUrl=" +
                    HttpUtility.UrlEncode(page.Request.Url.PathAndQuery));
                return false;
            }
            return true;
        }

        /// <summary>
        /// Checks if the current user is logged in
        /// </summary>
        public static bool IsLoggedIn(System.Web.UI.Page page)
        {
            return page.Session["UserID"] != null;
        }

        /// <summary>
        /// Gets the current user's ID from session
        /// </summary>
        public static int GetCurrentUserId(System.Web.UI.Page page)
        {
            if (page.Session["UserID"] == null) return 0;
            return Convert.ToInt32(page.Session["UserID"]);
        }

        /// <summary>
        /// Gets the current user's type (Freelancer, Employer, Admin)
        /// </summary>
        public static string GetCurrentUserType(System.Web.UI.Page page)
        {
            return page.Session["UserType"] as string ?? "";
        }
    }
}

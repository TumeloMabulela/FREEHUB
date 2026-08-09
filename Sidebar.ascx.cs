using System;
using System.IO;

namespace FreeHubProject
{
    public partial class Sidebar : System.Web.UI.UserControl
    {
        /// <summary>
        /// Gets the current user's role from session for use in the markup.
        /// </summary>
        public string CurrentUserType
        {
            get
            {
                return Session["UserType"] as string ?? "";
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        /// <summary>
        /// Returns "active-sidebar-item" if the current page matches the given page name
        /// </summary>
        public string GetActiveClass(string pageName)
        {
            string currentPage = Path.GetFileNameWithoutExtension(
                Page.Request.Url.AbsolutePath);

            if (string.Equals(currentPage, pageName, StringComparison.OrdinalIgnoreCase))
            {
                return "active-sidebar-item";
            }

            // Highlight Wallet for wallet-related sub-pages
            if (string.Equals(pageName, "Wallet", StringComparison.OrdinalIgnoreCase))
            {
                if (string.Equals(currentPage, "Transactions", StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(currentPage, "FundWallet", StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(currentPage, "WithdrawFunds", StringComparison.OrdinalIgnoreCase))
                {
                    return "active-sidebar-item";
                }
            }

            return "";
        }
    }
}

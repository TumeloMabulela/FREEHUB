using System;
using System.IO;

namespace FreeHubProject
{
    public partial class Sidebar : System.Web.UI.UserControl
    {
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

            return "";
        }
    }
}

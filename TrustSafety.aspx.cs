using System;
using System.Web.UI;

namespace FreeHubProject
{
    public partial class TrustSafety : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // IF user is not logged in, stop executing this page
            if (!AuthHelper.RequireLogin(this)) return;
        }
    }
}

using System;
using System.Web.UI;

namespace FreeHubProject
{
    public partial class FAQs : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;
        }
    }
}

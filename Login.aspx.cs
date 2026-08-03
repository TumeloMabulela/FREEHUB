using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
        }


        protected void btnLogin_Click(
            object sender,
            EventArgs e)
        {
            lblLoginMessage.CssClass =
                "login-message login-error";


            if (
                string.IsNullOrWhiteSpace(
                    txtLoginEmail.Text
                ) ||
                string.IsNullOrWhiteSpace(
                    txtLoginPassword.Text
                )
            )
            {
                lblLoginMessage.Text =
                    "Please enter your email address and password.";

                return;
            }


            lblLoginMessage.CssClass =
                "login-message login-success";


            
        }
    }
}
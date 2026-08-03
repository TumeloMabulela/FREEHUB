using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class Register : System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
        }


        protected void btnRegister_Click(
            object sender,
            EventArgs e)
        {
            lblMessage.CssClass =
                "register-message error-message";


            if (
                string.IsNullOrWhiteSpace(
                    txtFirstName.Text
                ) ||
                string.IsNullOrWhiteSpace(
                    txtLastName.Text
                ) ||
                string.IsNullOrWhiteSpace(
                    txtEmail.Text
                ) ||
                string.IsNullOrWhiteSpace(
                    txtPassword.Text
                ) ||
                string.IsNullOrWhiteSpace(
                    txtConfirmPassword.Text
                )
            )
            {
                lblMessage.Text =
                    "Please complete all the required fields.";

                return;
            }


            if (
                txtPassword.Text !=
                txtConfirmPassword.Text
            )
            {
                lblMessage.Text =
                    "The passwords do not match.";

                return;
            }


            if (
                !chkTerms.Checked
            )
            {
                lblMessage.Text =
                    "Please accept the Terms and Conditions.";

                return;
            }


            lblMessage.CssClass =
                "register-message success-message";


            lblMessage.Text =
                "Account details accepted successfully. " +
                "The database connection will be added later.";
        }
    }
}
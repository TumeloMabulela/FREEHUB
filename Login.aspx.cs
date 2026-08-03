using System;
using System.Data;

namespace FreeHubProject
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Session["UserID"] != null)
            {
                Response.Redirect("Default.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            lblLoginMessage.CssClass = "login-message login-error";

            if (string.IsNullOrWhiteSpace(txtLoginEmail.Text) ||
                string.IsNullOrWhiteSpace(txtLoginPassword.Text))
            {
                lblLoginMessage.Text = "Please enter your email address and password.";
                return;
            }

            DataRow user = DatabaseHelper.AuthenticateUser(
                txtLoginEmail.Text.Trim(),
                txtLoginPassword.Text
            );

            if (user == null)
            {
                lblLoginMessage.Text = "Invalid email or password. Please try again.";
                return;
            }

            // Store user info in session
            Session["UserID"] = Convert.ToInt32(user["userID"]);
            Session["FirstName"] = Convert.ToString(user["firstName"]);
            Session["LastName"] = Convert.ToString(user["lastName"]);
            Session["Email"] = Convert.ToString(user["email"]);
            Session["Username"] = Convert.ToString(user["username"]);
            Session["UserType"] = Convert.ToString(user["userType"]);
            Session["AccountStatus"] = Convert.ToString(user["accountStatus"]);
            Session["RatingScore"] = user["ratingScore"] == DBNull.Value ? 0.0m : Convert.ToDecimal(user["ratingScore"]);

            // Load wallet balance
            DataRow wallet = DatabaseHelper.GetWalletByUserId(Convert.ToInt32(user["userID"]));
            if (wallet != null)
            {
                Session["WalletID"] = Convert.ToInt32(wallet["walletID"]);
                Session["AvailableBalance"] = Convert.ToDecimal(wallet["balance"]);
            }

            Response.Redirect("Default.aspx");
        }
    }
}

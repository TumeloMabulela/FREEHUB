using System;
using System.Data;
using System.Web.Security;

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

            try
            {
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
                Session["RatingScore"] = user["ratingScore"] == DBNull.Value
                    ? 0.0m : Convert.ToDecimal(user["ratingScore"]);

                // Load wallet balance
                DataRow wallet = DatabaseHelper.GetWalletByUserId(
                    Convert.ToInt32(user["userID"]));
                if (wallet != null)
                {
                    Session["WalletID"] = Convert.ToInt32(wallet["walletID"]);
                    Session["AvailableBalance"] = Convert.ToDecimal(wallet["balance"]);
                }

                // Create Forms Authentication ticket
                FormsAuthentication.SetAuthCookie(
                    Convert.ToString(user["email"]), false);

                // Determine where to redirect
                string userType = Convert.ToString(user["userType"]);
                string accountStatus = Convert.ToString(user["accountStatus"]);

                string returnUrl = Request.QueryString["ReturnUrl"];

                if (string.IsNullOrWhiteSpace(userType) || userType == "None")
                {
                    // New user — no profile created yet, must choose role
                    Response.Redirect("ChooseRole.aspx");
                }
                else if (accountStatus == "Deactivated" || accountStatus == "Inactive")
                {
                    // Account deactivated/inactive — send to ChooseRole to reactivate
                    Response.Redirect("ChooseRole.aspx");
                }
                else if (!string.IsNullOrWhiteSpace(returnUrl))
                {
                    Response.Redirect(returnUrl);
                }
                else
                {
                    Response.Redirect("Dashboard.aspx");
                }
            }
            catch (Exception ex)
            {
                lblLoginMessage.Text = "Database connection error: " + ex.Message;
            }
        }
    }
}

using System;
using System.Web.Security;

namespace FreeHubProject
{
    public partial class Site1 : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                SetupNavigation();
            }
        }

        private void SetupNavigation()
        {
            bool loggedIn = Session["UserID"] != null;
            string userType = Session["UserType"] as string ?? "";

            if (loggedIn)
            {
                pnlLoggedInNav.Visible = true;
                pnlGuestButtons.Visible = false;
                pnlUserButtons.Visible = true;

                // Show Post a Project for Employers
                pnlEmployerNav.Visible =
                    userType.Equals("Employer", StringComparison.OrdinalIgnoreCase);

                // Set user display info
                string firstName = Session["FirstName"] as string ?? "";
                string lastName = Session["LastName"] as string ?? "";

                litFullName.Text = (firstName + " " + lastName).Trim();

                string initials = "";
                if (firstName.Length > 0) initials += firstName[0];
                if (lastName.Length > 0) initials += lastName[0];
                litInitials.Text = initials.ToUpper();
            }
            else
            {
                pnlLoggedInNav.Visible = false;
                pnlEmployerNav.Visible = false;
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

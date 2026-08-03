using System;

namespace FreeHubProject
{
    public partial class Site1 : System.Web.UI.MasterPage
    {
        // Properties used in the master page markup
        public bool IsLoggedIn
        {
            get { return Session["UserID"] != null; }
        }

        public string UserType
        {
            get { return Session["UserType"] as string ?? ""; }
        }

        public string UserFullName
        {
            get
            {
                string first = Session["FirstName"] as string ?? "";
                string last = Session["LastName"] as string ?? "";
                return (first + " " + last).Trim();
            }
        }

        public string UserInitials
        {
            get
            {
                string first = Session["FirstName"] as string ?? "";
                string last = Session["LastName"] as string ?? "";
                string initials = "";
                if (first.Length > 0) initials += first[0];
                if (last.Length > 0) initials += last[0];
                return initials.ToUpper();
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}

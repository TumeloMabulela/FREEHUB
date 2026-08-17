using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class SwitchRole : System.Web.UI.Page
    {
        private string OtherRole
        {
            get { return ViewState["OtherRole"] as string ?? ""; }
            set { ViewState["OtherRole"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadSwitchView();
            }
        }

        private int GetUserId()
        {
            return Convert.ToInt32(Session["UserID"]);
        }

        private void LoadSwitchView()
        {
            string currentRole = Session["UserType"] as string ?? "Freelancer";
            string otherRole = currentRole == "Freelancer" ? "Employer" : "Freelancer";
            OtherRole = otherRole;

            // Current role display
            if (currentRole == "Freelancer")
            {
                litCurrentIcon.Text = "&#128187;";
                litCurrentRole.Text = "Freelancer";
                litCurrentDesc.Text = "You are finding work and submitting proposals.";
            }
            else
            {
                litCurrentIcon.Text = "&#127970;";
                litCurrentRole.Text = "Employer";
                litCurrentDesc.Text = "You are posting projects and hiring freelancers.";
            }

            // Other role display
            int userId = GetUserId();
            string otherStatus = DatabaseHelper.GetProfileStatus(userId, otherRole);

            if (otherRole == "Freelancer")
            {
                litOtherIcon.Text = "&#128187;";
                litOtherRole.Text = "Freelancer";
                litOtherDesc.Text = "Find work and submit proposals.";
            }
            else
            {
                litOtherIcon.Text = "&#127970;";
                litOtherRole.Text = "Employer";
                litOtherDesc.Text = "Post projects and hire freelancers.";
            }

            // Show status and set button text
            if (otherStatus == "Active")
            {
                litOtherStatus.Text = "";
                btnSwitch.Text = "Switch to " + otherRole;
            }
            else if (otherStatus == "Deactivated")
            {
                litOtherStatus.Text = "<br/><span class='status-deactivated'>&#9888; This profile is deactivated</span>";
                btnSwitch.Text = "Switch to " + otherRole;
            }
            else
            {
                litOtherStatus.Text = "<br/><span class='status-not-created'>&#43; Profile not yet created</span>";
                btnSwitch.Text = "Switch to " + otherRole;
            }
        }

        protected void btnSwitch_Click(object sender, EventArgs e)
        {
            int userId = GetUserId();
            string otherRole = OtherRole;
            string otherStatus = DatabaseHelper.GetProfileStatus(userId, otherRole);

            if (otherStatus == "Active")
            {
                // Direct switch
                SwitchUserRole(userId, otherRole);
                Response.Redirect("Dashboard.aspx");
            }
            else if (otherStatus == "Deactivated")
            {
                // Show confirmation modal for reactivation
                string script = "showSwitchModal('deactivated', '" + otherRole + "');";
                ClientScript.RegisterStartupScript(this.GetType(), "showModal", script, true);
            }
            else
            {
                // Not created — show confirmation modal for creation
                string script = "showSwitchModal('notcreated', '" + otherRole + "');";
                ClientScript.RegisterStartupScript(this.GetType(), "showModal", script, true);
            }
        }

        protected void btnConfirmReactivate_Click(object sender, EventArgs e)
        {
            int userId = GetUserId();
            string otherRole = OtherRole;

            DatabaseHelper.ReactivateUserProfile(userId, otherRole);
            SwitchUserRole(userId, otherRole);
            Response.Redirect("Dashboard.aspx");
        }

        protected void btnConfirmCreate_Click(object sender, EventArgs e)
        {
            // Redirect to ChooseRole where they can create the profile
            Response.Redirect("ChooseRole.aspx");
        }

        private void SwitchUserRole(int userId, string newRole)
        {
            DatabaseHelper.ExecuteNonQuery(
                "UPDATE [User] SET userType = @UserType, accountStatus = 'Active' WHERE userID = @UserID",
                new SqlParameter("@UserType", newRole),
                new SqlParameter("@UserID", userId));

            Session["UserType"] = newRole;
            Session["AccountStatus"] = "Active";
        }
    }
}

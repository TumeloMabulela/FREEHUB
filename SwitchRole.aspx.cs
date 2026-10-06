using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class SwitchRole : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // If BOTH profiles exist and are active, switch straight to the other one
                // without making the user choose. Otherwise, fall through to the normal
                // page (buttons + create/reactivate modals) exactly as before.
                if (TryAutoSwitch())
                {
                    return;
                }

                pnlMessage.Visible = false;
                lblCurrentRole.Text = Session["UserType"] as string ?? "User";
                UpdateButtonStates();
            }
        }

        /// <summary>
        /// When the user has both an active Freelancer and an active Employer profile,
        /// immediately switch to whichever one is NOT currently active and go to the
        /// dashboard. Returns true if an automatic switch happened (and a redirect was issued).
        /// </summary>
        private bool TryAutoSwitch()
        {
            int userId = GetUserId();
            string currentRole = Session["UserType"] as string ?? "";

            bool freelancerActive = DatabaseHelper.GetProfileStatus(userId, "Freelancer") == "Active";
            bool employerActive = DatabaseHelper.GetProfileStatus(userId, "Employer") == "Active";

            // Both profiles must be present and active for an automatic switch.
            if (!(freelancerActive && employerActive))
            {
                return false;
            }

            // Switch to the opposite of the current role.
            string targetRole = currentRole.Equals("Freelancer", StringComparison.OrdinalIgnoreCase)
                ? "Employer"
                : "Freelancer";

            SwitchUserRole(userId, targetRole);
            Response.Redirect("Dashboard.aspx");
            return true;
        }

        private int GetUserId()
        {
            return Convert.ToInt32(Session["UserID"]);
        }

        private void UpdateButtonStates()
        {
            string currentRole = Session["UserType"] as string ?? "";
            lblCurrentRole.Text = currentRole;

            btnSwitchFreelancer.Enabled = true;
            btnSwitchFreelancer.Text = "Switch to Freelancer";
            btnSwitchEmployer.Enabled = true;
            btnSwitchEmployer.Text = "Switch to Employer";

            if (currentRole.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
            {
                btnSwitchFreelancer.Enabled = false;
                btnSwitchFreelancer.Text = "Currently Freelancer";
            }
            else if (currentRole.Equals("Employer", StringComparison.OrdinalIgnoreCase))
            {
                btnSwitchEmployer.Enabled = false;
                btnSwitchEmployer.Text = "Currently Employer";
            }
        }

        protected void btnSwitchFreelancer_Click(object sender, EventArgs e)
        {
            int userId = GetUserId();

            try
            {
                DataRow freelancer = DatabaseHelper.GetFreelancerByUserId(userId);

                if (freelancer == null)
                {
                    // Profile not created — show modal asking to create
                    string script = "showSwitchModal('notcreated', 'Freelancer');";
                    ClientScript.RegisterStartupScript(this.GetType(), "notCreatedModal", script, true);
                    return;
                }

                string status = DatabaseHelper.GetProfileStatus(userId, "Freelancer");
                if (status == "Deactivated")
                {
                    // Profile deactivated — show modal asking to reactivate
                    string script = "showSwitchModal('deactivated', 'Freelancer');";
                    ClientScript.RegisterStartupScript(this.GetType(), "deactivatedModal", script, true);
                    return;
                }

                // Active profile — switch directly
                SwitchUserRole(userId, "Freelancer");
                Response.Redirect("Dashboard.aspx");
            }
            catch (Exception ex)
            {
                ShowMessage("Error switching role: " + ex.Message, false);
            }
        }

        protected void btnSwitchEmployer_Click(object sender, EventArgs e)
        {
            int userId = GetUserId();

            try
            {
                DataRow employer = DatabaseHelper.GetEmployerByUserId(userId);

                if (employer == null)
                {
                    // Profile not created — show modal asking to create
                    string script = "showSwitchModal('notcreated', 'Employer');";
                    ClientScript.RegisterStartupScript(this.GetType(), "notCreatedModal", script, true);
                    return;
                }

                string status = DatabaseHelper.GetProfileStatus(userId, "Employer");
                if (status == "Deactivated")
                {
                    // Profile deactivated — show modal asking to reactivate
                    string script = "showSwitchModal('deactivated', 'Employer');";
                    ClientScript.RegisterStartupScript(this.GetType(), "deactivatedModal", script, true);
                    return;
                }

                // Active profile — switch directly
                SwitchUserRole(userId, "Employer");
                Response.Redirect("Dashboard.aspx");
            }
            catch (Exception ex)
            {
                ShowMessage("Error switching role: " + ex.Message, false);
            }
        }

        // Hidden buttons for modal confirmations
        protected void btnConfirmCreateFreelancer_Click(object sender, EventArgs e)
        {
            Response.Redirect("ChooseRole.aspx");
        }

        protected void btnConfirmCreateEmployer_Click(object sender, EventArgs e)
        {
            Response.Redirect("ChooseRole.aspx");
        }

        protected void btnConfirmReactivateFreelancer_Click(object sender, EventArgs e)
        {
            Response.Redirect("ChooseRole.aspx");
        }

        protected void btnConfirmReactivateEmployer_Click(object sender, EventArgs e)
        {
            Response.Redirect("ChooseRole.aspx");
        }

        private void SwitchUserRole(int userId, string newRole)
        {
            string query = "UPDATE [User] SET userType = @UserType, accountStatus = 'Active' WHERE userID = @UserID";
            DatabaseHelper.ExecuteNonQuery(query,
                new SqlParameter("@UserType", newRole),
                new SqlParameter("@UserID", userId));

            Session["UserType"] = newRole;
            Session["AccountStatus"] = "Active";
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = message;
            pnlMessage.CssClass = success ? "post-status post-success" : "post-status post-error";
        }
    }
}

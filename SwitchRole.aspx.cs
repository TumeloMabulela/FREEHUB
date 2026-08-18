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
                pnlMessage.Visible = false;
                lblCurrentRole.Text = Session["UserType"] as string ?? "User";
                UpdateButtonStates();
            }
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

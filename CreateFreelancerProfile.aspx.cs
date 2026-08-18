using System;
using System.Data.SqlClient;
using System.Web.Security;

namespace FreeHubProject
{
    public partial class CreateFreelancerProfile : System.Web.UI.Page
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
                txtFirstName.Text = Session["FirstName"] as string ?? "";
                txtLastName.Text = Session["LastName"] as string ?? "";
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtSkills.Text))
            {
                lblMessage.Text = "Please enter at least one skill.";
                lblMessage.CssClass = "msg msg-error";
                return;
            }

            decimal hourlyRate;
            if (!decimal.TryParse(txtHourlyRate.Text, out hourlyRate) || hourlyRate <= 0)
            {
                lblMessage.Text = "Please enter a valid hourly rate.";
                lblMessage.CssClass = "msg msg-error";
                return;
            }

            int userId = Convert.ToInt32(Session["UserID"]);

            try
            {
                string query = @"INSERT INTO Freelancer (userID, skills, experience, portfolioLinks, hourlyRate)
                                VALUES (@UserID, @Skills, @Experience, @PortfolioLinks, @HourlyRate)";

                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@Skills", DatabaseHelper.CapitalizeSkills(txtSkills.Text)),
                    new SqlParameter("@Experience", txtExperience.Text.Trim()),
                    new SqlParameter("@PortfolioLinks", txtPortfolio.Text.Trim()),
                    new SqlParameter("@HourlyRate", hourlyRate));

                // Set user type and activate
                DatabaseHelper.ReactivateUserProfile(userId, "Freelancer");

                Session["UserType"] = "Freelancer";
                Session["AccountStatus"] = "Active";

                Response.Redirect("Dashboard.aspx");
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error: " + ex.Message;
                lblMessage.CssClass = "msg msg-error";
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

using System;
using System.Collections.Generic;
using System.Data.SqlClient;

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
            string firstName = Session["FirstName"] as string ?? "";
            string lastName = Session["LastName"] as string ?? "";

            try
            {
                // Save profile picture
                string profilePicPath = "";
                if (fuProfilePic.HasFile)
                {
                    string fileName = userId + "_" + System.IO.Path.GetFileName(fuProfilePic.FileName);
                    string savePath = Server.MapPath("~/Uploads/" + fileName);
                    fuProfilePic.SaveAs(savePath);
                    profilePicPath = "Uploads/" + fileName;
                }

                // Update user info
                string updateQuery = "UPDATE [User] SET firstName = @FirstName, lastName = @LastName, bio = @Bio, location = @Location, preferredLanguage = @Language" +
                    (string.IsNullOrEmpty(profilePicPath) ? "" : ", profilePicture = @ProfilePic") +
                    " WHERE userID = @UserID";

                var updateParams = new List<SqlParameter>
                {
                    new SqlParameter("@FirstName", DatabaseHelper.CapitalizeName(firstName)),
                    new SqlParameter("@LastName", DatabaseHelper.CapitalizeName(lastName)),
                    new SqlParameter("@Bio", txtBio.Text.Trim()),
                    new SqlParameter("@Location", txtLocation.Text.Trim()),
                    new SqlParameter("@Language", ddlLanguage.SelectedValue),
                    new SqlParameter("@UserID", userId)
                };

                if (!string.IsNullOrEmpty(profilePicPath))
                    updateParams.Add(new SqlParameter("@ProfilePic", profilePicPath));

                DatabaseHelper.ExecuteNonQuery(updateQuery, updateParams.ToArray());

                // Create freelancer profile
                string query = @"INSERT INTO Freelancer (userID, skills, experience, portfolioLinks, hourlyRate)
                                VALUES (@UserID, @Skills, @Experience, @PortfolioLinks, @HourlyRate)";

                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@Skills", DatabaseHelper.CapitalizeSkills(txtSkills.Text)),
                    new SqlParameter("@Experience", txtExperience.Text.Trim()),
                    new SqlParameter("@PortfolioLinks", txtPortfolio.Text.Trim()),
                    new SqlParameter("@HourlyRate", hourlyRate));

                DatabaseHelper.ReactivateUserProfile(userId, "Freelancer");

                Session["FirstName"] = DatabaseHelper.CapitalizeName(firstName);
                Session["LastName"] = DatabaseHelper.CapitalizeName(lastName);
                Session["UserType"] = "Freelancer";
                Session["AccountStatus"] = "Active";

                Response.Redirect("Dashboard.aspx?welcome=1");
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
            System.Web.Security.FormsAuthentication.SignOut();
            Response.Redirect("Login.aspx");
        }
    }
}

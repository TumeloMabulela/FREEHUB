using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class CreateEmployerProfile : System.Web.UI.Page
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
            if (string.IsNullOrWhiteSpace(txtCompanyName.Text))
            {
                lblMessage.Text = "Please enter your company name.";
                lblMessage.CssClass = "msg msg-error";
                return;
            }

            if (string.IsNullOrWhiteSpace(ddlIndustry.SelectedValue))
            {
                lblMessage.Text = "Please select an industry.";
                lblMessage.CssClass = "msg msg-error";
                return;
            }

            if (string.IsNullOrWhiteSpace(txtCompanyDesc.Text))
            {
                lblMessage.Text = "Please enter a company description.";
                lblMessage.CssClass = "msg msg-error";
                return;
            }

            int userId = Convert.ToInt32(Session["UserID"]);
            string firstName = Session["FirstName"] as string ?? "";
            string lastName = Session["LastName"] as string ?? "";
            string contactEmail = string.IsNullOrWhiteSpace(txtContactEmail.Text)
                ? Session["Email"] as string ?? "" : txtContactEmail.Text.Trim();

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

                // Create employer profile
                string query = @"INSERT INTO Employer (userID, companyName, industry, description, contactEmail)
                                VALUES (@UserID, @CompanyName, @Industry, @Description, @ContactEmail)";

                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@CompanyName", txtCompanyName.Text.Trim()),
                    new SqlParameter("@Industry", ddlIndustry.SelectedValue),
                    new SqlParameter("@Description", txtCompanyDesc.Text.Trim()),
                    new SqlParameter("@ContactEmail", contactEmail));

                DatabaseHelper.ReactivateUserProfile(userId, "Employer");

                Session["FirstName"] = DatabaseHelper.CapitalizeName(firstName);
                Session["LastName"] = DatabaseHelper.CapitalizeName(lastName);
                Session["UserType"] = "Employer";
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

using System;
using System.Data.SqlClient;
using System.Web.Security;

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
            string contactEmail = string.IsNullOrWhiteSpace(txtContactEmail.Text)
                ? Session["Email"] as string ?? "" : txtContactEmail.Text.Trim();

            try
            {
                string query = @"INSERT INTO Employer (userID, companyName, industry, description, contactEmail)
                                VALUES (@UserID, @CompanyName, @Industry, @Description, @ContactEmail)";

                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@CompanyName", txtCompanyName.Text.Trim()),
                    new SqlParameter("@Industry", ddlIndustry.SelectedValue),
                    new SqlParameter("@Description", txtCompanyDesc.Text.Trim()),
                    new SqlParameter("@ContactEmail", contactEmail));

                // Set user type and activate
                DatabaseHelper.ReactivateUserProfile(userId, "Employer");

                Session["UserType"] = "Employer";
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

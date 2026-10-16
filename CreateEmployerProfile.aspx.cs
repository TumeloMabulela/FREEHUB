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
            // Clear any prior field errors / invalid styling before re-validating.
            ClearFieldErrors();

            bool valid = true;

            // --- Company Name (required) ---
            if (string.IsNullOrWhiteSpace(txtCompanyName.Text))
            {
                SetFieldError(lblCompanyError, txtCompanyName, "Company name is required");
                valid = false;
            }

            // --- Industry (required) ---
            if (string.IsNullOrWhiteSpace(ddlIndustry.SelectedValue))
            {
                SetFieldError(lblIndustryError, ddlIndustry, "Select an industry");
                valid = false;
            }

            // --- Company Description: trim, reject empty/whitespace-only, require 30..700.
            //     Validated on the trimmed string; content is never silently truncated. ---
            string description = (txtCompanyDesc.Text ?? "").Trim();
            if (description.Length == 0)
            {
                SetFieldError(lblDescError, txtCompanyDesc, "Company description is required");
                valid = false;
            }
            else if (description.Length < 30)
            {
                SetFieldError(lblDescError, txtCompanyDesc, "Minimum 30 characters");
                valid = false;
            }
            else if (description.Length > 700)
            {
                SetFieldError(lblDescError, txtCompanyDesc, "Maximum 700 characters");
                valid = false;
            }

            // --- Contact Email (required + basic format) ---
            string contactEmailRaw = (txtContactEmail.Text ?? "").Trim();
            if (contactEmailRaw.Length == 0)
            {
                SetFieldError(lblContactEmailError, txtContactEmail, "Contact email is required");
                valid = false;
            }
            else if (!System.Text.RegularExpressions.Regex.IsMatch(contactEmailRaw,
                        @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                SetFieldError(lblContactEmailError, txtContactEmail, "Enter a valid email");
                valid = false;
            }

            if (!valid)
            {
                // Values are retained automatically across the postback; nothing is saved.
                return;
            }

            int userId = Convert.ToInt32(Session["UserID"]);
            string contactEmail = contactEmailRaw;

            try
            {
                string query = @"INSERT INTO Employer (userID, companyName, industry, description, contactEmail)
                                VALUES (@UserID, @CompanyName, @Industry, @Description, @ContactEmail)";

                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@CompanyName", txtCompanyName.Text.Trim()),
                    new SqlParameter("@Industry", ddlIndustry.SelectedValue),
                    new SqlParameter("@Description", description),
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

        /// <summary>Shows a concise error beside a field's label and flags the input.</summary>
        private void SetFieldError(System.Web.UI.WebControls.Label errorLabel,
                                   System.Web.UI.WebControls.WebControl input, string message)
        {
            errorLabel.Text = message;
            if (!input.CssClass.Contains("input-invalid"))
                input.CssClass = (input.CssClass + " input-invalid").Trim();
        }

        /// <summary>Clears all field error messages and invalid styling before re-validating.</summary>
        private void ClearFieldErrors()
        {
            lblCompanyError.Text = "";
            lblIndustryError.Text = "";
            lblDescError.Text = "";
            lblContactEmailError.Text = "";
            lblMessage.Text = "";
            txtCompanyName.CssClass = txtCompanyName.CssClass.Replace("input-invalid", "").Replace("  ", " ").Trim();
            ddlIndustry.CssClass = ddlIndustry.CssClass.Replace("input-invalid", "").Replace("  ", " ").Trim();
            txtCompanyDesc.CssClass = txtCompanyDesc.CssClass.Replace("input-invalid", "").Replace("  ", " ").Trim();
            txtContactEmail.CssClass = txtContactEmail.CssClass.Replace("input-invalid", "").Replace("  ", " ").Trim();
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

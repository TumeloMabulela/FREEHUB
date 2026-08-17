using System;
using System.Data;

namespace FreeHubProject
{
    public partial class ViewProfile : System.Web.UI.Page
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
                LoadProfile();
            }
        }

        private void LoadProfile()
        {
            string userIdStr = Request.QueryString["id"];
            if (string.IsNullOrEmpty(userIdStr))
            {
                lblError.Text = "No user selected.";
                lblError.Visible = true;
                pnlProfile.Visible = false;
                return;
            }

            int userId = Convert.ToInt32(userIdStr);

            try
            {
                DataRow user = DatabaseHelper.GetUserById(userId);
                if (user == null)
                {
                    lblError.Text = "User not found.";
                    lblError.Visible = true;
                    pnlProfile.Visible = false;
                    return;
                }

                string firstName = Convert.ToString(user["firstName"]);
                string lastName = Convert.ToString(user["lastName"]);
                string userType = Convert.ToString(user["userType"]);

                lblFullName.Text = firstName + " " + lastName;
                lblInitials.Text = (firstName.Length > 0 ? firstName[0].ToString() : "") + (lastName.Length > 0 ? lastName[0].ToString() : "");
                lblUserType.Text = userType;
                lblDateJoined.Text = Convert.ToDateTime(user["dateCreated"]).ToString("MMM yyyy");
                lblRating.Text = user["ratingScore"] != DBNull.Value ? Convert.ToDecimal(user["ratingScore"]).ToString("0.0") : "0.0";

                // Load freelancer or employer details
                if (userType == "Freelancer")
                {
                    DataRow fl = DatabaseHelper.GetFreelancerByUserId(userId);
                    if (fl != null)
                    {
                        pnlFreelancerInfo.Visible = true;
                        lblSkills.Text = Convert.ToString(fl["skills"]);
                        lblExperience.Text = Convert.ToString(fl["experience"]);
                        lblRate.Text = Convert.ToDecimal(fl["hourlyRate"]).ToString("N0");
                    }
                }
                else if (userType == "Employer")
                {
                    DataRow em = DatabaseHelper.GetEmployerByUserId(userId);
                    if (em != null)
                    {
                        pnlEmployerInfo.Visible = true;
                        lblCompany.Text = Convert.ToString(em["companyName"]);
                        lblIndustry.Text = Convert.ToString(em["industry"]);
                        lblDescription.Text = Convert.ToString(em["description"]);
                    }
                }
            }
            catch (Exception ex)
            {
                lblError.Text = "Error loading profile: " + ex.Message;
                lblError.Visible = true;
                pnlProfile.Visible = false;
            }
        }
    }
}

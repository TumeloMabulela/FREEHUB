using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class CompletedProjects : Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            // Only logged-in employers can view their completed projects.
            if (!AuthHelper.RequireRole(this, "Employer")) return;

            if (!IsPostBack)
            {
                pnlCompletedMessage.Visible = false;
                LoadCompletedProjects();
            }
        }


        // Load real completed projects for the current employer.

        private void LoadCompletedProjects()
        {
            int userId = AuthHelper.GetCurrentUserId(this);

            DataTable completed =
                DatabaseHelper.GetCompletedProjectsByEmployer(userId);

            int count = completed != null ? completed.Rows.Count : 0;

            litCompletedCount.Text = count.ToString();

            rptCompleted.DataSource = completed;
            rptCompleted.DataBind();

            rptCompleted.Visible = count > 0;
            pnlNoCompleted.Visible = count == 0;
        }


        // Handle the per-project action buttons.

        protected void rptCompleted_ItemCommand(
            object source,
            RepeaterCommandEventArgs e)
        {
            string arg = Convert.ToString(e.CommandArgument);

            switch (e.CommandName)
            {
                case "RateFreelancer":
                    Response.Redirect(
                        "RateFreelancer.aspx?projectId=" + arg);
                    break;

                case "ViewProject":
                    Response.Redirect(
                        "ProjectDetails.aspx?id=" + arg);
                    break;

                case "ViewFreelancer":
                    Response.Redirect(
                        "ViewProfile.aspx?userId=" + arg);
                    break;
            }
        }


        // Builds up to two uppercase initials from a name/title for avatars.

        protected string GetInitials(object value)
        {
            string text = Convert.ToString(value);

            if (string.IsNullOrWhiteSpace(text)) return "?";

            string[] parts = text.Trim().Split(
                new[] { ' ' },
                StringSplitOptions.RemoveEmptyEntries);

            if (parts.Length == 1)
            {
                return parts[0].Substring(
                    0,
                    Math.Min(2, parts[0].Length)).ToUpper();
            }

            return (parts[0].Substring(0, 1) +
                    parts[1].Substring(0, 1)).ToUpper();
        }
    }
}

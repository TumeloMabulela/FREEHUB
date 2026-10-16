using System;
using System.Web.UI;

namespace FreeHubProject
{
    public partial class CompletedProjects : Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;

            if (!IsPostBack)
            {
                pnlCompletedMessage.Visible = false;
            }
        }


        // Open the Rate Freelancer page

        protected void btnRateFreelancer_Click(
     object sender,
     EventArgs e)
        {
            Response.Redirect(
                "RateFreelancer.aspx"
            );
        }


        // View freelancer profile

        protected void btnViewFreelancer_Click(
            object sender,
            EventArgs e)
        {
            ShowMessage(
                "Freelancer profile opened successfully."
            );
        }


        // View completed project

        protected void btnViewProject_Click(
            object sender,
            EventArgs e)
        {
            ShowMessage(
                "Completed project details opened."
            );
        }


        // Contact support

        protected void btnContactSupport_Click(
            object sender,
            EventArgs e)
        {
            HelpHelper.StartHelpChat(this, null, "Completed Projects");
        }


        // Display status message

        private void ShowMessage(
            string message)
        {
            MessageHelper.Success(this, message);
        }
    }
}
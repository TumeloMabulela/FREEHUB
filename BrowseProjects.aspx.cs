using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace FreeHubProject
{
    public partial class BrowseProjects : System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
        }


        protected void btnFilter_Click(
            object sender,
            EventArgs e)
        {
            lblFilterMessage.Text =
                "The selected filters have been applied. " +
                "The real filtering will be connected to SQL Server later.";
        }


        protected void btnReset_Click(
            object sender,
            EventArgs e)
        {
            ddlCategory.SelectedIndex = 0;
            ddlBudget.SelectedIndex = 0;
            ddlDate.SelectedIndex = 0;

            lblFilterMessage.Text =
                "All filters have been reset.";
        }


        protected void btnProjectOne_Click(
            object sender,
            EventArgs e)
        {
            LoadProject(
                "Website Development Project",
                "Recently posted",
                "The employer has posted a website development project and is looking for a skilled freelancer. The complete project information will be loaded from the SQL Server database when the database is connected.",
                "Budget available",
                "To be confirmed",
                "Web Development",
                "Experience required",
                "Employer Name",
                "Employer information will be loaded from the database",
                "Employer rating",
                "EM"
            );
        }


        protected void btnProjectTwo_Click(
            object sender,
            EventArgs e)
        {
            LoadProject(
                "Mobile Application Project",
                "Recently posted",
                "The employer is looking for a freelancer to develop a mobile application. The complete requirements, budget and employer information will be retrieved from SQL Server later.",
                "Budget available",
                "To be confirmed",
                "Mobile Development",
                "Experience required",
                "Employer Name",
                "Employer information will be loaded from the database",
                "Employer rating",
                "EM"
            );
        }


        protected void btnProjectThree_Click(
            object sender,
            EventArgs e)
        {
            LoadProject(
                "Content Writing Project",
                "Recently posted",
                "The employer requires a freelancer with strong writing and communication skills. The complete project requirements will be stored and loaded from the database.",
                "Budget available",
                "To be confirmed",
                "Writing",
                "Experience required",
                "Employer Name",
                "Employer information will be loaded from the database",
                "Employer rating",
                "EM"
            );
        }


        protected void btnProjectFour_Click(
            object sender,
            EventArgs e)
        {
            LoadProject(
                "Social Media Marketing Project",
                "Recently posted",
                "The employer is looking for a freelancer to manage social media content and marketing activities. The real project details will come from SQL Server.",
                "Monthly budget",
                "To be confirmed",
                "Marketing",
                "Experience required",
                "Employer Name",
                "Employer information will be loaded from the database",
                "Employer rating",
                "EM"
            );
        }


        protected void btnProjectFive_Click(
            object sender,
            EventArgs e)
        {
            LoadProject(
                "Logo Design Project",
                "Recently posted",
                "The employer requires a creative freelancer to design a professional logo. The project information will be dynamically loaded after the database is connected.",
                "Budget available",
                "To be confirmed",
                "Graphic Design",
                "Experience required",
                "Employer Name",
                "Employer information will be loaded from the database",
                "Employer rating",
                "EM"
            );
        }


        private void LoadProject(
            string projectTitle,
            string posted,
            string description,
            string budget,
            string deadline,
            string category,
            string experience,
            string employerName,
            string employerDetails,
            string employerRating,
            string employerInitials)
        {
            lblProjectTitle.Text =
                projectTitle;

            lblPosted.Text =
                posted;

            lblDescription.Text =
                description;

            lblBudget.Text =
                budget;

            lblDeadline.Text =
                deadline;

            lblCategory.Text =
                category;

            lblExperience.Text =
                experience;

            lblEmployerName.Text =
                employerName;

            lblEmployerDetails.Text =
                employerDetails;

            lblEmployerRating.Text =
                employerRating;

            lblEmployerInitials.Text =
                employerInitials;

            lblProjectMessage.Text =
                "";
        }


        protected void btnLoadMore_Click(
            object sender,
            EventArgs e)
        {
            lblFilterMessage.Text =
                "More projects will be loaded from SQL Server after the database is connected.";
        }


        protected void btnReturn_Click(
            object sender,
            EventArgs e)
        {
            lblProjectMessage.Text =
                "You are currently viewing the project list.";
        }


        protected void btnSubmitProposal_Click(
            object sender,
            EventArgs e)
        {
            // Store selected project info in session for the proposal page
            Session["SelectedProjectTitle"] = lblProjectTitle.Text;
            Session["SelectedProjectBudget"] = lblBudget.Text;
            Session["SelectedProjectDeadline"] = lblDeadline.Text;
            Session["SelectedProjectCategory"] = lblCategory.Text;

            Response.Redirect("SubmitProposal.aspx");
        }


        protected void btnSaveProject_Click(
            object sender,
            EventArgs e)
        {
            lblProjectMessage.Text =
                "Project saved successfully.";
        }


        protected void btnViewProfile_Click(
            object sender,
            EventArgs e)
        {
            lblProjectMessage.Text =
                "The employer profile page will be connected later.";
        }
    }
}
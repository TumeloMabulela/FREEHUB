using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class SelectProposal : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;
        }

        protected void btnBackToProject_Click(object sender, EventArgs e)
        {
            Response.Redirect("MyProjects.aspx");
        }

        protected void btnSelectProposal1_Click(object sender, EventArgs e)
        {
            SelectAndReview("Thabo Mokoena");
        }

        protected void btnSelectProposal2_Click(object sender, EventArgs e)
        {
            SelectAndReview("Aisha Khan");
        }

        protected void btnSelectProposal3_Click(object sender, EventArgs e)
        {
            SelectAndReview("John Tau");
        }

        protected void btnSelectProposal4_Click(object sender, EventArgs e)
        {
            SelectAndReview("Sarah Patel");
        }

        protected void btnViewProposal1_Click(object sender, EventArgs e)
        {
            ViewProposalDetails("Thabo Mokoena", "R12,000", "15 days",
                "I have over 5 years of experience in designing and developing modern, responsive websites. I specialize in creating user-friendly interfaces that drive conversions and improve user experience.");
        }

        protected void btnViewProposal2_Click(object sender, EventArgs e)
        {
            ViewProposalDetails("Aisha Khan", "R9,500", "18 days",
                "I can deliver a clean, modern and fully responsive website redesign that aligns with your brand and business goals. I have strong skills in frontend and UI/UX design.");
        }

        protected void btnViewProposal3_Click(object sender, EventArgs e)
        {
            ViewProposalDetails("John Tau", "R8,000", "20 days",
                "I will redesign your website with a modern look and better user experience. I have strong skills in frontend and UI/UX design with 3 years of experience.");
        }

        protected void btnViewProposal4_Click(object sender, EventArgs e)
        {
            ViewProposalDetails("Sarah Patel", "R8,500", "22 days",
                "I can deliver a fast, responsive and SEO-friendly website redesign that matches your brand and goals. Experienced in HTML, CSS, JavaScript and React.");
        }

        private void SelectAndReview(string freelancerName)
        {
            Session["SelectedFreelancerName"] = freelancerName;
            lblProposalMessage.Text = freelancerName + "'s proposal has been selected for review.";
            Response.Redirect("ReviewProposal.aspx");
        }

        private void ViewProposalDetails(string name, string rate, string time, string coverLetter)
        {
            Session["ViewProposalName"] = name;
            Session["ViewProposalRate"] = rate;
            Session["ViewProposalTime"] = time;
            Session["ViewProposalCoverLetter"] = coverLetter;
            Response.Redirect("ReviewProposal.aspx");
        }

        protected void btnLoadMoreProposals_Click(object sender, EventArgs e)
        {
            lblProposalMessage.Text = "All proposals for this project have been displayed.";
        }

        protected void btnContactSupport_Click(object sender, EventArgs e)
        {
            lblProposalMessage.Text = "For support, please email support@freehub.co.za";
        }

        protected void btnHelpSupport_Click(object sender, EventArgs e)
        {
            lblProposalMessage.Text = "For support, please email support@freehub.co.za";
        }
    }
}

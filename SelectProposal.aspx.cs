using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace FreeHubProject
{
    public partial class SelectProposal : System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;
        }


        protected void btnBackToProject_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "MyProjects.aspx"
            );
        }


        protected void btnSelectProposal1_Click(
            object sender,
            EventArgs e)
        {
            lblProposalMessage.Text =
                "Thabo Mokoena's proposal has been selected. " +
                "The project will be updated in SQL Server later.";
        }


        protected void btnSelectProposal2_Click(
            object sender,
            EventArgs e)
        {
            lblProposalMessage.Text =
                "Aisha Khan's proposal has been selected. " +
                "The project will be updated in SQL Server later.";
        }


        protected void btnSelectProposal3_Click(
            object sender,
            EventArgs e)
        {
            lblProposalMessage.Text =
                "John Tau's proposal has been selected. " +
                "The project will be updated in SQL Server later.";
        }


        protected void btnSelectProposal4_Click(
            object sender,
            EventArgs e)
        {
            lblProposalMessage.Text =
                "Sarah Patel's proposal has been selected. " +
                "The project will be updated in SQL Server later.";
        }


        protected void btnViewProposal1_Click(
            object sender,
            EventArgs e)
        {
            lblProposalMessage.Text =
                "Viewing Thabo Mokoena's proposal details.";
        }


        protected void btnViewProposal2_Click(
            object sender,
            EventArgs e)
        {
            lblProposalMessage.Text =
                "Viewing Aisha Khan's proposal details.";
        }


        protected void btnViewProposal3_Click(
            object sender,
            EventArgs e)
        {
            lblProposalMessage.Text =
                "Viewing John Tau's proposal details.";
        }


        protected void btnViewProposal4_Click(
            object sender,
            EventArgs e)
        {
            lblProposalMessage.Text =
                "Viewing Sarah Patel's proposal details.";
        }


        protected void btnLoadMoreProposals_Click(
            object sender,
            EventArgs e)
        {
            lblProposalMessage.Text =
                "More proposals will be loaded " +
                "from SQL Server later.";
        }


        protected void btnContactSupport_Click(
            object sender,
            EventArgs e)
        {
            lblProposalMessage.Text =
                "The support page will be connected later.";
        }


        protected void btnHelpSupport_Click(
            object sender,
            EventArgs e)
        {
            lblProposalMessage.Text =
                "The support page will be connected later.";
        }
    }
}
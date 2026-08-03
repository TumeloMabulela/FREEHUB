using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace FreeHubProject
{
    public partial class ReviewProposal : System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
        }


        protected void btnBackToProposals_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "SelectProposal.aspx"
            );
        }


        protected void btnViewProfile_Click(
            object sender,
            EventArgs e)
        {
            lblReviewMessage.Text =
                "The freelancer profile page will be connected later.";
        }


        protected void btnApproveProposal_Click(
            object sender,
            EventArgs e)
        {
            lblReviewMessage.Text =
                "The proposal has been approved successfully. " +
                "The project status will be updated in SQL Server later.";
        }


        protected void btnRequestChanges_Click(
            object sender,
            EventArgs e)
        {
            lblReviewMessage.Text =
                "The request changes function will be connected " +
                "to the messaging system later.";
        }


        protected void btnRejectProposal_Click(
            object sender,
            EventArgs e)
        {
            lblReviewMessage.Text =
                "The proposal has been rejected. " +
                "The proposal status will be updated in SQL Server later.";
        }


        protected void btnSidebarSupport_Click(
            object sender,
            EventArgs e)
        {
            lblReviewMessage.Text =
                "The support page will be connected later.";
        }


        protected void btnContactSupport_Click(
            object sender,
            EventArgs e)
        {
            lblReviewMessage.Text =
                "The support page will be connected later.";
        }
    }
}
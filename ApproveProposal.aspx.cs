using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace FreeHubProject
{
    public partial class ApproveProposal : System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
        }


        protected void btnBackToReview_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "ReviewProposal.aspx"
            );
        }


        protected void btnConfirmApproval_Click(
            object sender,
            EventArgs e)
        {
            if (chkConfirmApproval.Checked)
            {
                lblApprovalMessage.Text =
                    "The proposal has been approved successfully. " +
                    "The project will be updated in SQL Server later.";
            }
            else
            {
                lblApprovalMessage.Text =
                    "Please confirm that you have reviewed " +
                    "the proposal before approving it.";
            }
        }


        protected void btnCancelApproval_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "ReviewProposal.aspx"
            );
        }


        protected void btnSupport_Click(
            object sender,
            EventArgs e)
        {
            lblApprovalMessage.Text =
                "The support page will be connected later.";
        }


        protected void btnHelp_Click(
            object sender,
            EventArgs e)
        {
            lblApprovalMessage.Text =
                "The support page will be connected later.";
        }
    }
}
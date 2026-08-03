using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace FreeHubProject
{
    public partial class RejectProposal : System.Web.UI.Page
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


        protected void btnConfirmReject_Click(
            object sender,
            EventArgs e)
        {
            if (rblRejectReason.SelectedIndex == -1)
            {
                lblRejectMessage.Text =
                    "Please select a reason for rejecting the proposal.";

                return;
            }


            if (!chkConfirmReject.Checked)
            {
                lblRejectMessage.Text =
                    "Please confirm that you understand the rejection action.";

                return;
            }


            lblRejectMessage.Text =
                "The proposal has been rejected successfully. " +
                "The proposal status and notification will be " +
                "saved to SQL Server later.";
        }


        protected void btnCancelReject_Click(
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
            lblRejectMessage.Text =
                "The support page will be connected later.";
        }


        protected void btnHelp_Click(
            object sender,
            EventArgs e)
        {
            lblRejectMessage.Text =
                "The support page will be connected later.";
        }
    }
}
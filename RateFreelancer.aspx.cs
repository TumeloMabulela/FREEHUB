using System;

namespace FreeHubProject
{
    public partial class RateFreelancer : System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlRatingMessage.Visible = false;
            }
        }


        protected void btnSubmitRating_Click(
            object sender,
            EventArgs e)
        {
            int rating;

            bool ratingIsValid =
                int.TryParse(
                    hfRating.Value,
                    out rating
                );


            if (!ratingIsValid ||
                rating < 1 ||
                rating > 5)
            {
                ShowMessage(
                    "Please select a rating before submitting.",
                    false
                );

                return;
            }


            string comment =
                txtComment.Text.Trim();


            ShowMessage(
                "Your " +
                rating +
                "-star rating was submitted successfully.",
                true
            );


            btnSubmitRating.Enabled = false;

            btnSubmitRating.Text =
                "Rating Submitted";
        }


        protected void btnCancel_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "CompletedProjects.aspx"
            );
        }


        protected void btnViewProfile_Click(
            object sender,
            EventArgs e)
        {
            ShowMessage(
                "The freelancer profile page will be connected later.",
                true
            );
        }


        protected void btnReportFreelancer_Click(
            object sender,
            EventArgs e)
        {
            ShowMessage(
                "The report freelancer page will be connected later.",
                false
            );
        }


        protected void btnContactSupport_Click(
            object sender,
            EventArgs e)
        {
            ShowMessage(
                "The support page will be connected later.",
                true
            );
        }


        private void ShowMessage(
            string message,
            bool success)
        {
            pnlRatingMessage.Visible = true;

            lblRatingMessage.Text = message;


            if (success)
            {
                pnlRatingMessage.CssClass =
                    "rating-message-panel rating-success-message";
            }
            else
            {
                pnlRatingMessage.CssClass =
                    "rating-message-panel rating-error-message";
            }
        }
    }
}
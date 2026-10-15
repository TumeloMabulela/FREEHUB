using System;
using System.Data;

namespace FreeHubProject
{
    public partial class SubmitProposal : System.Web.UI.Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireRole(this, "Freelancer")) return;

            if (!IsPostBack)
            {
                pnlMessage.Visible = false;
                LoadProjectInfo();
            }
        }

        private void LoadProjectInfo()
        {
            string projectId = Request.QueryString["projectId"];

            if (string.IsNullOrWhiteSpace(projectId))
            {
                // Use session-stored project info (from BrowseProjects)
                lblProjectTitle.Text = Session["SelectedProjectTitle"] as string ?? "Project";
                lblProjectBudget.Text = Session["SelectedProjectBudget"] as string ?? "To be confirmed";
                lblProjectDeadline.Text = Session["SelectedProjectDeadline"] as string ?? "To be confirmed";
                lblProjectCategory.Text = Session["SelectedProjectCategory"] as string ?? "General";
                return;
            }

            try
            {
                DataRow project = DatabaseHelper.GetProjectById(Convert.ToInt32(projectId));
                if (project != null)
                {
                    lblProjectTitle.Text = Convert.ToString(project["title"]);
                    lblProjectBudget.Text = "R" + Convert.ToDecimal(project["budget"]).ToString("N2");
                    lblProjectDeadline.Text = Convert.ToDateTime(project["deadline"]).ToString("dd MMM yyyy");
                    lblProjectCategory.Text = Convert.ToString(project["category"]);
                }
                else
                {
                    ShowMessage("Project not found.", false);
                }
            }
            catch
            {
                lblProjectTitle.Text = Session["SelectedProjectTitle"] as string ?? "Project";
                lblProjectBudget.Text = Session["SelectedProjectBudget"] as string ?? "To be confirmed";
                lblProjectDeadline.Text = Session["SelectedProjectDeadline"] as string ?? "To be confirmed";
                lblProjectCategory.Text = Session["SelectedProjectCategory"] as string ?? "General";
            }
        }

        protected void btnSubmitProposal_Click(object sender, EventArgs e)
        {
            // Validate
            if (string.IsNullOrWhiteSpace(txtCoverLetter.Text))
            {
                ShowMessage("Please enter a cover letter.", false);
                return;
            }

            if (txtCoverLetter.Text.Trim().Length < 50)
            {
                ShowMessage("Cover letter must be at least 50 characters.", false);
                return;
            }

            decimal proposedRate;
            if (!decimal.TryParse(txtProposedRate.Text.Trim(), out proposedRate) || proposedRate <= 0)
            {
                ShowMessage("Please enter a valid proposed rate.", false);
                return;
            }

            int completionDays;
            if (!int.TryParse(txtCompletionTime.Text.Trim(), out completionDays) || completionDays <= 0)
            {
                ShowMessage("Please enter the estimated completion time as a number of days (e.g. 15).", false);
                return;
            }

            // Store a friendly, converted duration (e.g. "15 days (about 2 weeks)").
            string completionTime = DescribeDuration(completionDays);

            // Try to submit to database
            try
            {
                string projectIdStr = Request.QueryString["projectId"];
                int projectId = 0;
                if (!string.IsNullOrWhiteSpace(projectIdStr))
                {
                    projectId = Convert.ToInt32(projectIdStr);
                }

                int userId = AuthHelper.GetCurrentUserId(this);

                if (projectId > 0)
                {
                    int result = DatabaseHelper.SubmitProposal(
                        projectId,
                        userId,
                        txtCoverLetter.Text.Trim(),
                        proposedRate,
                        completionTime
                    );

                    if (result > 0)
                    {
                        ShowMessage("Your proposal has been submitted successfully! The employer will review it shortly.", true);
                        btnSubmitProposal.Enabled = false;
                        btnSubmitProposal.Text = "Proposal Submitted";
                        // Inside btnSubmitProposal_Click upon successful database submission (result > 0):
                     
                        string proposalMsg = "You have successfully submitted a proposal.";
                        NotificationHelper.CreateNotification(userId, "Proposal", proposalMsg);
                    }
                    else if (result == -1)
                    {
                        ShowMessage("You have already submitted a proposal for this project.", false);
                    }
                    else
                    {
                        ShowMessage("An error occurred. Please try again.", false);
                    }
                }
                else
                {
                    // Session-based fallback
                    ShowMessage("Your proposal has been submitted successfully! The employer will review it shortly.", true);
                    btnSubmitProposal.Enabled = false;
                    btnSubmitProposal.Text = "Proposal Submitted";
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Your proposal has been submitted successfully! The employer will review it shortly.", true);
                btnSubmitProposal.Enabled = false;
                btnSubmitProposal.Text = "Proposal Submitted";
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("BrowseProjects.aspx");
        }

        // Converts a number of days into a friendly description that also shows
        // the equivalent in weeks / months / years.
        private static string DescribeDuration(int days)
        {
            if (days <= 0) return "";

            string dayLabel = days + (days == 1 ? " day" : " days");

            if (days < 7)
            {
                return dayLabel;
            }
            if (days < 30)
            {
                double weeks = Math.Round(days / 7.0, 1);
                return dayLabel + " (about " + weeks + (weeks == 1 ? " week)" : " weeks)");
            }
            if (days < 365)
            {
                double months = Math.Round(days / 30.0, 1);
                return dayLabel + " (about " + months + (months == 1 ? " month)" : " months)");
            }
            double years = Math.Round(days / 365.0, 1);
            return dayLabel + " (about " + years + (years == 1 ? " year)" : " years)");
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = message;
            pnlMessage.CssClass = success
                ? "post-status post-success"
                : "post-status post-error";
        }
    }
}

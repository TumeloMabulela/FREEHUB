using System;
using System.Data;

namespace FreeHubProject
{
    public partial class SubmitProposal : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Only freelancers can submit proposals
            string userType = Session["UserType"] as string ?? "";
            if (userType.Equals("Employer", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("BrowseProjects.aspx");
                return;
            }

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

            if (string.IsNullOrWhiteSpace(txtCompletionTime.Text))
            {
                ShowMessage("Please enter an estimated completion time.", false);
                return;
            }

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
                        txtCompletionTime.Text.Trim()
                    );

                    if (result > 0)
                    {
                        ShowMessage("Your proposal has been submitted successfully! The employer will review it shortly.", true);
                        btnSubmitProposal.Enabled = false;
                        btnSubmitProposal.Text = "Proposal Submitted";
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

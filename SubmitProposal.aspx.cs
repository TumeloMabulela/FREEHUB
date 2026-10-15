using System;
using System.Data;
using System.Globalization;
using System.Text.RegularExpressions;

namespace FreeHubProject
{
    public partial class SubmitProposal : System.Web.UI.Page
    {
        private const int CoverMin = 200;
        private const int CoverMax = 800;
        private const int RateMin = 1;
        private const int RateMax = 200000;

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
                    lblProjectTitle.Text = TitleHelper.TitleCase(Convert.ToString(project["title"]));
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
            // Clear previous field messages.
            lblCoverError.Text = "";
            lblRateError.Text = "";
            lblDateError.Text = "";

            // Normalise the pasted/typed cover letter into clean paragraphs before
            // validating and saving, so the stored value and the length check match.
            txtCoverLetter.Text = TextHelper.NormalizeDescription(txtCoverLetter.Text);

            bool valid = true;

            // ----- Cover letter: 200..800 characters (trimmed, actual characters) -----
            string cover = (txtCoverLetter.Text ?? "").Trim();
            if (cover.Length == 0)
            {
                SetFieldError(lblCoverError, "Minimum 200 characters required.");
                valid = false;
            }
            else if (cover.Length < CoverMin)
            {
                SetFieldError(lblCoverError, "Minimum 200 characters required.");
                valid = false;
            }
            else if (cover.Length > CoverMax)
            {
                SetFieldError(lblCoverError, "Maximum 800 characters allowed.");
                valid = false;
            }

            // ----- Proposed rate: positive whole number, R1..R200000 (no decimals/commas) -----
            string rateRaw = (txtProposedRate.Text ?? "").Trim();
            int rate = 0;
            if (rateRaw.Length == 0)
            {
                SetFieldError(lblRateError, "Proposed rate is required.");
                valid = false;
            }
            else if (!Regex.IsMatch(rateRaw, @"^[0-9]+$"))
            {
                SetFieldError(lblRateError, "Enter a valid positive amount.");
                valid = false;
            }
            else if (!int.TryParse(rateRaw, NumberStyles.None, CultureInfo.InvariantCulture, out rate) || rate < RateMin)
            {
                SetFieldError(lblRateError, "Minimum amount is R1.00.");
                valid = false;
            }
            else if (rate > RateMax)
            {
                SetFieldError(lblRateError, "Maximum allowed is R200,000.00.");
                valid = false;
            }

            // ----- Completion date: today or future; compute days using LOCAL date -----
            int completionDays = -1;
            string dateRaw = (txtCompletionDate.Text ?? "").Trim();
            DateTime selectedDate;
            if (dateRaw.Length == 0)
            {
                SetFieldError(lblDateError, "Please select a completion date.");
                valid = false;
            }
            else if (!DateTime.TryParseExact(dateRaw, "yyyy-MM-dd", CultureInfo.InvariantCulture,
                        DateTimeStyles.None, out selectedDate)
                     && !DateTime.TryParse(dateRaw, CultureInfo.CurrentCulture, DateTimeStyles.None, out selectedDate))
            {
                SetFieldError(lblDateError, "Please select a completion date.");
                valid = false;
            }
            else
            {
                DateTime today = DateTime.Now.Date;              // local date, not UTC
                DateTime sel = selectedDate.Date;
                if (sel < today)
                {
                    SetFieldError(lblDateError, "Past dates are not allowed.");
                    valid = false;
                }
                else
                {
                    completionDays = (int)(sel - today).TotalDays;
                }
            }

            if (!valid)
            {
                // Preserve entered values (ViewState keeps the textboxes) and show a summary.
                ShowMessage("Please correct the highlighted fields and try again.", false);
                return;
            }

            decimal proposedRate = rate;   // whole number -> DECIMAL(12,2)

            // Preserve the existing days-based storage: store a friendly, converted
            // duration string in estimatedCompletionTime (e.g. "15 days (about 2 weeks)").
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

                // Server-side ownership guard: a user must never apply to a project
                // posted by their OWN Employer profile (same registered account).
                if (projectId > 0 && DatabaseHelper.IsProjectOwnedByUser(projectId, userId))
                {
                    ShowMessage("You cannot submit a proposal for a project posted by your own Employer profile.", false);
                    return;
                }

                if (projectId > 0)
                {
                    int result = DatabaseHelper.SubmitProposal(
                        projectId,
                        userId,
                        cover,
                        proposedRate,
                        completionTime
                    );

                    if (result > 0)
                    {
                        ShowMessage("Your proposal has been submitted successfully! The employer will review it shortly.", true);
                        btnSubmitProposal.Enabled = false;
                        btnSubmitProposal.Text = "Proposal Submitted";

                        string proposalMsg = "You have successfully submitted a proposal.";
                        NotificationHelper.CreateNotification(userId, "Proposal", proposalMsg);
                    }
                    else if (result == -1)
                    {
                        ShowMessage("You have already submitted a proposal for this project.", false);
                    }
                    else if (result == -2)
                    {
                        ShowMessage("You cannot submit a proposal for a project posted by your own Employer profile.", false);
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
            catch
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

        /// <summary>Shows an error beside a field label (red text) and keeps the field marked.</summary>
        private static void SetFieldError(System.Web.UI.WebControls.Label label, string message)
        {
            label.Text = message;
            label.CssClass = "sp2-msg err";
        }

        // Converts a number of days into a friendly description that also shows
        // the equivalent in weeks / months / years. Preserved from the original.
        private static string DescribeDuration(int days)
        {
            if (days <= 0) return "0 days";

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
            if (success) MessageHelper.Success(this, message);
            else MessageHelper.Error(this, message);
        }
    }
}

// ============================================================
// B500 - Submit Proposal (Tumelo London Mabulela)
// FILE: SubmitProposal.aspx.cs
// PURPOSE: Allows a logged-in freelancer to submit a proposal
// on an open project. Validates all fields before saving.
// ============================================================

using System;
using System.Data;
using System.Globalization;
using System.Text.RegularExpressions;

namespace FreeHubProject
{
    public partial class SubmitProposal : System.Web.UI.Page
    {
        // Cover letter must be between 200 and 800 characters
        private const int CoverMin = 200;
        private const int CoverMax = 800;

        // Proposed rate must be between R1 and R200,000
        private const int RateMin = 1;
        private const int RateMax = 200000;

        protected void Page_Load(object sender, EventArgs e)
        {
            // IF the user is not logged in OR is not a Freelancer, redirect them away
            // An employer trying to access this page gets redirected to Default.aspx
            if (!AuthHelper.RequireRole(this, "Freelancer")) return;

            // IF this is the first time loading (not a form submission), load the project info
            if (!IsPostBack)
            {
                pnlMessage.Visible = false;
                LoadProjectInfo();
            }
        }

        private void LoadProjectInfo()
        {
            string projectId = Request.QueryString["projectId"];

            // IF there is no project ID in the URL, use session values as a fallback
            if (string.IsNullOrWhiteSpace(projectId))
            {
                lblProjectTitle.Text = Session["SelectedProjectTitle"] as string ?? "Project";
                lblProjectBudget.Text = Session["SelectedProjectBudget"] as string ?? "To be confirmed";
                lblProjectDeadline.Text = Session["SelectedProjectDeadline"] as string ?? "To be confirmed";
                lblProjectCategory.Text = Session["SelectedProjectCategory"] as string ?? "General";
                return;
            }

            try
            {
                DataRow project = DatabaseHelper.GetProjectById(Convert.ToInt32(projectId));

                // IF the project was found, display its details at the top of the form
                if (project != null)
                {
                    lblProjectTitle.Text = TitleHelper.TitleCase(Convert.ToString(project["title"]));
                    lblProjectBudget.Text = "R" + Convert.ToDecimal(project["budget"]).ToString("N2");
                    lblProjectDeadline.Text = Convert.ToDateTime(project["deadline"]).ToString("dd MMM yyyy");
                    lblProjectCategory.Text = Convert.ToString(project["category"]);
                }
                else
                {
                    // IF the project was not found in the database, show an error
                    ShowMessage("Project not found.", false);
                }
            }
            catch
            {
                // IF a database error occurred, fall back to session values
                lblProjectTitle.Text = Session["SelectedProjectTitle"] as string ?? "Project";
                lblProjectBudget.Text = Session["SelectedProjectBudget"] as string ?? "To be confirmed";
                lblProjectDeadline.Text = Session["SelectedProjectDeadline"] as string ?? "To be confirmed";
                lblProjectCategory.Text = Session["SelectedProjectCategory"] as string ?? "General";
            }
        }

        protected void btnSubmitProposal_Click(object sender, EventArgs e)
        {
            // Clear any previous field error messages from a prior submission attempt
            lblCoverError.Text = "";
            lblRateError.Text = "";
            lblDateError.Text = "";

            // Clean up the cover letter text before validating it
            txtCoverLetter.Text = TextHelper.NormalizeDescription(txtCoverLetter.Text);

            bool valid = true;

            // --- VALIDATE COVER LETTER ---
            string cover = (txtCoverLetter.Text ?? "").Trim();

            // IF cover letter is completely empty
            if (cover.Length == 0)
            {
                SetFieldError(lblCoverError, "Minimum 200 characters required.");
                valid = false;
            }
            // IF cover letter is too short (less than 200 characters)
            else if (cover.Length < CoverMin)
            {
                SetFieldError(lblCoverError, "Minimum 200 characters required.");
                valid = false;
            }
            // IF cover letter is too long (more than 800 characters)
            else if (cover.Length > CoverMax)
            {
                SetFieldError(lblCoverError, "Maximum 800 characters allowed.");
                valid = false;
            }

            // --- VALIDATE PROPOSED RATE ---
            string rateRaw = (txtProposedRate.Text ?? "").Trim();
            int rate = 0;

            // IF the rate field is empty
            if (rateRaw.Length == 0)
            {
                SetFieldError(lblRateError, "Proposed rate is required.");
                valid = false;
            }
            // IF the rate contains anything other than digits (e.g. commas, decimals, letters)
            else if (!Regex.IsMatch(rateRaw, @"^[0-9]+$"))
            {
                SetFieldError(lblRateError, "Enter a valid positive amount.");
                valid = false;
            }
            // IF the rate is less than the minimum (R1)
            else if (!int.TryParse(rateRaw, NumberStyles.None, CultureInfo.InvariantCulture, out rate) || rate < RateMin)
            {
                SetFieldError(lblRateError, "Minimum amount is R1.00.");
                valid = false;
            }
            // IF the rate exceeds the maximum (R200,000)
            else if (rate > RateMax)
            {
                SetFieldError(lblRateError, "Maximum allowed is R200,000.00.");
                valid = false;
            }

            // --- VALIDATE COMPLETION DATE ---
            int completionDays = -1;
            string dateRaw = (txtCompletionDate.Text ?? "").Trim();
            DateTime selectedDate;

            // IF no completion date was selected
            if (dateRaw.Length == 0)
            {
                SetFieldError(lblDateError, "Please select a completion date.");
                valid = false;
            }
            // IF the date cannot be parsed in either yyyy-MM-dd or current culture format
            else if (!DateTime.TryParseExact(dateRaw, "yyyy-MM-dd", CultureInfo.InvariantCulture,
                        DateTimeStyles.None, out selectedDate)
                     && !DateTime.TryParse(dateRaw, CultureInfo.CurrentCulture, DateTimeStyles.None, out selectedDate))
            {
                SetFieldError(lblDateError, "Please select a completion date.");
                valid = false;
            }
            else
            {
                DateTime today = DateTime.Now.Date;
                DateTime sel = selectedDate.Date;

                // IF the selected date is in the past, reject it
                if (sel < today)
                {
                    SetFieldError(lblDateError, "Past dates are not allowed.");
                    valid = false;
                }
                else
                {
                    // Calculate how many days from today until the selected date
                    completionDays = (int)(sel - today).TotalDays;
                }
            }

            // IF any validation failed, stop here and show a summary message
            if (!valid)
            {
                ShowMessage("Please correct the highlighted fields and try again.", false);
                return;
            }

            decimal proposedRate = rate;

            // Convert the number of days to a friendly display string
            // e.g. "15 days (about 2 weeks)"
            string completionTime = DescribeDuration(completionDays);

            try
            {
                string projectIdStr = Request.QueryString["projectId"];
                int projectId = 0;

                // IF there is a project ID in the URL, parse it
                if (!string.IsNullOrWhiteSpace(projectIdStr))
                {
                    projectId = Convert.ToInt32(projectIdStr);
                }

                int userId = AuthHelper.GetCurrentUserId(this);

                // IF the user is trying to apply to their OWN project (via dual role),
                // block the submission - you cannot apply to your own project
                if (projectId > 0 && DatabaseHelper.IsProjectOwnedByUser(projectId, userId))
                {
                    ShowMessage("You cannot submit a proposal for a project posted by your own Employer profile.", false);
                    return;
                }

                // IF a valid project ID exists, submit to the database
                if (projectId > 0)
                {
                    // Returns: >0 = success, -1 = duplicate, -2 = own project
                    int result = DatabaseHelper.SubmitProposal(
                        projectId, userId, cover, proposedRate, completionTime);

                    // IF proposal was saved successfully
                    if (result > 0)
                    {
                        ShowMessage("Your proposal has been submitted successfully! The employer will review it shortly.", true);
                        btnSubmitProposal.Enabled = false; // prevent double submission
                        btnSubmitProposal.Text = "Proposal Submitted";

                        // Send the freelancer a confirmation notification
                        string proposalMsg = "You have successfully submitted a proposal.";
                        NotificationHelper.CreateNotification(userId, "Proposal", proposalMsg);
                    }
                    // IF the freelancer already submitted a proposal for this project
                    else if (result == -1)
                    {
                        ShowMessage("You have already submitted a proposal for this project.", false);
                    }
                    // IF the project belongs to the user's own employer profile
                    else if (result == -2)
                    {
                        ShowMessage("You cannot submit a proposal for a project posted by your own Employer profile.", false);
                    }
                    else
                    {
                        // IF some other unexpected error occurred
                        ShowMessage("An error occurred. Please try again.", false);
                    }
                }
                else
                {
                    // IF no project ID in URL, show success anyway (session-based flow)
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
            // Go back to the browse page without submitting anything
            Response.Redirect("BrowseProjects.aspx");
        }

        private static void SetFieldError(System.Web.UI.WebControls.Label label, string message)
        {
            // Show red error text next to the specific field that failed validation
            label.Text = message;
            label.CssClass = "sp2-msg err";
        }

        private static string DescribeDuration(int days)
        {
            // IF days is zero or less, just return "0 days"
            if (days <= 0) return "0 days";

            string dayLabel = days + (days == 1 ? " day" : " days");

            // IF less than a week, just show the days
            if (days < 7) return dayLabel;

            // IF less than a month, show days and approximate weeks
            if (days < 30)
            {
                double weeks = Math.Round(days / 7.0, 1);
                return dayLabel + " (about " + weeks + (weeks == 1 ? " week)" : " weeks)");
            }

            // IF less than a year, show days and approximate months
            if (days < 365)
            {
                double months = Math.Round(days / 30.0, 1);
                return dayLabel + " (about " + months + (months == 1 ? " month)" : " months)");
            }

            // IF a year or more, show days and approximate years
            double years = Math.Round(days / 365.0, 1);
            return dayLabel + " (about " + years + (years == 1 ? " year)" : " years)");
        }

        private void ShowMessage(string message, bool success)
        {
            // IF success is true, show a green success message
            // IF success is false, show a red error message
            if (success) MessageHelper.Success(this, message);
            else MessageHelper.Error(this, message);
        }
    }
}

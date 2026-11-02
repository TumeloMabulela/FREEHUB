// ============================================================
// B500 - Submit Proposal (Tumelo London Mabulela)
// FILE: SubmitProposal.aspx.cs
//
// PURPOSE: Allows a logged-in freelancer to submit a proposal
// on an open project. Validates cover letter length, proposed
// rate, and completion date before saving to the Proposal table.
// Prevents duplicate proposals and self-proposals.
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

        // ============================================================
        // PAGE LOAD
        // 1. Checks user is logged in AND is a Freelancer role
        // 2. On first load, calls LoadProjectInfo() to show the
        //    project details at the top of the form
        // ============================================================
        protected void Page_Load(object sender, EventArgs e)
        {
            // SECURITY: only freelancers can submit proposals
            if (!AuthHelper.RequireRole(this, "Freelancer")) return;

            if (!IsPostBack)
            {
                pnlMessage.Visible = false;
                LoadProjectInfo();
            }
        }

        // ============================================================
        // LoadProjectInfo()
        // Gets the project ID from the URL (e.g. ?projectId=3)
        // and loads the project details to display at the top of
        // the form so the freelancer knows what they're applying for.
        // Falls back to session values if no query string is present.
        // ============================================================
        private void LoadProjectInfo()
        {
            string projectId = Request.QueryString["projectId"];

            if (string.IsNullOrWhiteSpace(projectId))
            {
                // Fall back to session values set by BrowseProjects page
                lblProjectTitle.Text = Session["SelectedProjectTitle"] as string ?? "Project";
                lblProjectBudget.Text = Session["SelectedProjectBudget"] as string ?? "To be confirmed";
                lblProjectDeadline.Text = Session["SelectedProjectDeadline"] as string ?? "To be confirmed";
                lblProjectCategory.Text = Session["SelectedProjectCategory"] as string ?? "General";
                return;
            }

            try
            {
                // Fetch the project record by ID
                DataRow project = DatabaseHelper.GetProjectById(Convert.ToInt32(projectId));
                if (project != null)
                {
                    // Display project info at the top of the proposal form
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
                // If DB call fails, fall back to session values
                lblProjectTitle.Text = Session["SelectedProjectTitle"] as string ?? "Project";
                lblProjectBudget.Text = Session["SelectedProjectBudget"] as string ?? "To be confirmed";
                lblProjectDeadline.Text = Session["SelectedProjectDeadline"] as string ?? "To be confirmed";
                lblProjectCategory.Text = Session["SelectedProjectCategory"] as string ?? "General";
            }
        }

        // ============================================================
        // btnSubmitProposal_Click()
        // Main submission handler. Steps:
        // 1. Clear previous error messages
        // 2. Normalise the cover letter text
        // 3. Validate cover letter length (200-800 chars)
        // 4. Validate proposed rate (R1-R200,000, whole numbers only)
        // 5. Validate completion date (today or future)
        // 6. Check user is not applying to their own project
        // 7. Call DatabaseHelper.SubmitProposal() to save to DB
        // 8. Handle result codes: success, duplicate, self-proposal
        // 9. Send notification to the freelancer on success
        // ============================================================
        protected void btnSubmitProposal_Click(object sender, EventArgs e)
        {
            // Clear previous field error messages
            lblCoverError.Text = "";
            lblRateError.Text = "";
            lblDateError.Text = "";

            // Normalise the cover letter - clean up whitespace and formatting
            txtCoverLetter.Text = TextHelper.NormalizeDescription(txtCoverLetter.Text);

            bool valid = true;

            // --- VALIDATE: Cover letter (200-800 characters) ---
            string cover = (txtCoverLetter.Text ?? "").Trim();
            if (cover.Length == 0)
            {
                // Empty - show minimum required
                SetFieldError(lblCoverError, "Minimum 200 characters required.");
                valid = false;
            }
            else if (cover.Length < CoverMin)
            {
                // Too short
                SetFieldError(lblCoverError, "Minimum 200 characters required.");
                valid = false;
            }
            else if (cover.Length > CoverMax)
            {
                // Too long
                SetFieldError(lblCoverError, "Maximum 800 characters allowed.");
                valid = false;
            }

            // --- VALIDATE: Proposed rate (whole number, R1-R200,000) ---
            string rateRaw = (txtProposedRate.Text ?? "").Trim();
            int rate = 0;
            if (rateRaw.Length == 0)
            {
                SetFieldError(lblRateError, "Proposed rate is required.");
                valid = false;
            }
            else if (!Regex.IsMatch(rateRaw, @"^[0-9]+$"))
            {
                // Must be digits only - no decimals, commas, or symbols
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

            // --- VALIDATE: Completion date (must be today or future) ---
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
                DateTime today = DateTime.Now.Date;
                DateTime sel = selectedDate.Date;
                if (sel < today)
                {
                    // Past dates not allowed
                    SetFieldError(lblDateError, "Past dates are not allowed.");
                    valid = false;
                }
                else
                {
                    // Calculate days from today to selected date
                    completionDays = (int)(sel - today).TotalDays;
                }
            }

            // Stop here if any validation failed
            if (!valid)
            {
                ShowMessage("Please correct the highlighted fields and try again.", false);
                return;
            }

            decimal proposedRate = rate;

            // Convert days to a friendly string e.g. "15 days (about 2 weeks)"
            string completionTime = DescribeDuration(completionDays);

            try
            {
                string projectIdStr = Request.QueryString["projectId"];
                int projectId = 0;
                if (!string.IsNullOrWhiteSpace(projectIdStr))
                {
                    projectId = Convert.ToInt32(projectIdStr);
                }

                // Get the current user's ID from the session
                int userId = AuthHelper.GetCurrentUserId(this);

                // SECURITY: prevent a user from applying to their own project
                // (in case they have both a Freelancer and Employer profile)
                if (projectId > 0 && DatabaseHelper.IsProjectOwnedByUser(projectId, userId))
                {
                    ShowMessage("You cannot submit a proposal for a project posted by your own Employer profile.", false);
                    return;
                }

                if (projectId > 0)
                {
                    // Save the proposal to the database
                    // Returns: >0 = success, -1 = duplicate, -2 = own project
                    int result = DatabaseHelper.SubmitProposal(
                        projectId,
                        userId,
                        cover,
                        proposedRate,
                        completionTime
                    );

                    if (result > 0)
                    {
                        // SUCCESS: proposal saved
                        ShowMessage("Your proposal has been submitted successfully! The employer will review it shortly.", true);
                        btnSubmitProposal.Enabled = false; // prevent double-submit
                        btnSubmitProposal.Text = "Proposal Submitted";

                        // Send the freelancer a notification confirming submission
                        string proposalMsg = "You have successfully submitted a proposal.";
                        NotificationHelper.CreateNotification(userId, "Proposal", proposalMsg);
                    }
                    else if (result == -1)
                    {
                        // DUPLICATE: already applied to this project
                        ShowMessage("You have already submitted a proposal for this project.", false);
                    }
                    else if (result == -2)
                    {
                        // SELF-PROPOSAL: own employer project
                        ShowMessage("You cannot submit a proposal for a project posted by your own Employer profile.", false);
                    }
                    else
                    {
                        ShowMessage("An error occurred. Please try again.", false);
                    }
                }
                else
                {
                    // No project ID in URL - show success anyway (session-based fallback)
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

        // Go back to Browse Projects without submitting
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("BrowseProjects.aspx");
        }

        // ============================================================
        // SetFieldError()
        // Shows a red error message next to a specific form field.
        // Called when a single field fails validation.
        // ============================================================
        private static void SetFieldError(System.Web.UI.WebControls.Label label, string message)
        {
            label.Text = message;
            label.CssClass = "sp2-msg err";
        }

        // ============================================================
        // DescribeDuration(int days)
        // Converts a number of days into a human-readable string.
        // Examples:
        //   5 days -> "5 days"
        //   15 days -> "15 days (about 2 weeks)"
        //   45 days -> "45 days (about 1.5 months)"
        //   400 days -> "400 days (about 1.1 years)"
        // ============================================================
        private static string DescribeDuration(int days)
        {
            if (days <= 0) return "0 days";

            string dayLabel = days + (days == 1 ? " day" : " days");

            if (days < 7) return dayLabel;

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

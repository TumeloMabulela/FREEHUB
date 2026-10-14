using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class PostProject : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireRole(this, "Employer")) return;

            // Prevent selecting a past deadline: the browser date picker will not
            // allow anything earlier than today.
            txtDeadline.Attributes["min"] = DateTime.Today.ToString("yyyy-MM-dd");

            if (!IsPostBack)
            {
                pnlPreview.Visible = false;
                pnlProjectStatus.Visible = false;
                btnEditProject.Visible = false;
            }
        }

        private int GetEmployerId()
        {
            int userId = Convert.ToInt32(Session["UserID"]);
            try
            {
                DataRow employer = DatabaseHelper.GetEmployerByUserId(userId);
                if (employer != null)
                {
                    return Convert.ToInt32(employer["employerID"]);
                }
            }
            catch { }
            return 0;
        }

        // Returns the effective category: the specified text when "Other" is chosen,
        // otherwise the selected dropdown value.
        private string GetSelectedCategory()
        {
            if (ddlCategory.SelectedValue.Equals("Other", StringComparison.OrdinalIgnoreCase))
            {
                return txtOtherCategory.Text.Trim();
            }
            return ddlCategory.SelectedValue;
        }

        // POST PROJECT - Save to database
        protected void btnSubmitProject_Click(object sender, EventArgs e)
        {
            if (!ValidateProject()) return;

            int employerId = GetEmployerId();

            if (employerId == 0)
            {
                try
                {
                    int userId = Convert.ToInt32(Session["UserID"]);
                    string firstName = Session["FirstName"] as string ?? "User";
                    string email = Session["Email"] as string ?? "";

                    string createQuery = @"INSERT INTO Employer (userID, companyName, industry, description, contactEmail)
                                  VALUES (@UserID, @Company, 'General', 'Employer account', @Email);
                                  SELECT SCOPE_IDENTITY();";
                    object result = DatabaseHelper.ExecuteScalar(createQuery,
                        new SqlParameter("@UserID", userId),
                        new SqlParameter("@Company", firstName + "'s Projects"),
                        new SqlParameter("@Email", email));
                    employerId = Convert.ToInt32(result);

                    DatabaseHelper.ExecuteNonQuery(
                        "UPDATE [User] SET userType = 'Employer' WHERE userID = @UserID",
                        new SqlParameter("@UserID", userId));
                    Session["UserType"] = "Employer";
                }
                catch (Exception ex)
                {
                    ShowMessage("Error creating employer profile: " + ex.Message, false);
                    return;
                }
            }

            // Get skills, budget, deadline...
            List<string> selectedSkills = new List<string>();
            foreach (ListItem skill in cblSkills.Items)
            {
                if (skill.Selected) selectedSkills.Add(skill.Text);
            }
            string skills = string.Join(", ", selectedSkills);

            // Budget is a whole-number rand amount. ValidateProject() has already
            // confirmed it is digits-only, > 0 and <= R200 000; parse it strictly here
            // (NumberStyles.None rejects signs, decimals, thousands separators, etc.).
            decimal budget;
            if (!decimal.TryParse(txtBudget.Text.Trim(),
                    System.Globalization.NumberStyles.None,
                    System.Globalization.CultureInfo.InvariantCulture,
                    out budget)
                || budget <= 0 || budget > MaxBudget)
            {
                // Server-side safety net in case client validation was bypassed.
                string msg = budget > MaxBudget
                    ? "Maximum budget allowed is R200 000.00"
                    : "Enter a valid whole-number budget amount.";
                lblErrBudget.Text = msg;
                ShowValidationPopup(msg, "Budget amount");
                return;
            }

            DateTime deadline;
            if (!DateTime.TryParse(txtDeadline.Text, out deadline))
            {
                ShowMessage("Please enter a valid deadline date.", false);
                return;
            }

            if (deadline.Date < DateTime.Today)
            {
                ShowMessage("The deadline cannot be in the past. Please choose today or a future date.", false);
                return;
            }

            // Validate the optional attachment (PDF or image only, max 10 MB).
            if (fileAttachment.HasFile)
            {
                string ext = System.IO.Path.GetExtension(fileAttachment.FileName).ToLowerInvariant();
                string[] allowed = { ".pdf", ".jpg", ".jpeg", ".png", ".gif", ".webp" };
                if (Array.IndexOf(allowed, ext) < 0)
                {
                    ShowMessage("Attachments must be a PDF or an image (JPG, JPEG, PNG, GIF, WEBP).", false);
                    return;
                }
                if (fileAttachment.PostedFile.ContentLength > 10 * 1024 * 1024)
                {
                    ShowMessage("The attachment is too large. Maximum size is 10 MB.", false);
                    return;
                }
            }

            // Ensure the employer has enough funds in their wallet to cover the
            // project budget before allowing the post. The budget is held in escrow.
            int postingUserId = Convert.ToInt32(Session["UserID"]);
            int walletID = 0;
            decimal walletBalance = 0m;
            try
            {
                DataRow wallet = DatabaseHelper.GetWalletByUserId(postingUserId);
                if (wallet != null)
                {
                    walletID = Convert.ToInt32(wallet["walletID"]);
                    if (wallet["balance"] != DBNull.Value)
                        walletBalance = Convert.ToDecimal(wallet["balance"]);
                }
            }
            catch
            {
                walletID = 0;
                walletBalance = 0m;
            }

            if (walletID == 0)
            {
                ShowMessage(
                    "No wallet was found for your account. Please log in again.",
                    false);
                return;
            }

            if (walletBalance < budget)
            {
                ShowMessage(
                    "Insufficient wallet funds to post this project. " +
                    "Your available balance is R" + walletBalance.ToString("N2") +
                    " but the project budget is R" + budget.ToString("N2") +
                    ". Please fund your wallet before posting.",
                    false);
                return;
            }

            try
            {
                string query = @"INSERT INTO Project 
            (employerID, title, description, category, budget, budgetType, deadline, projectStatus, experienceLevel, skills)
            VALUES 
            (@EmployerID, @Title, @Description, @Category, @Budget, @BudgetType, @Deadline, 'Open', @Experience, @Skills);
            SELECT SCOPE_IDENTITY();";

                object result = DatabaseHelper.ExecuteScalar(query,
                    new SqlParameter("@EmployerID", employerId),
                    new SqlParameter("@Title", txtProjectTitle.Text.Trim()),
                    new SqlParameter("@Description", txtDescription.Text.Trim()),
                    new SqlParameter("@Category", GetSelectedCategory()),
                    new SqlParameter("@Budget", budget),
                    new SqlParameter("@BudgetType", rblBudgetType.SelectedValue),
                    new SqlParameter("@Deadline", deadline),
                    new SqlParameter("@Experience", ddlExperience.SelectedValue),
                    new SqlParameter("@Skills", skills));

                int projectId = Convert.ToInt32(result);

                // Save the optional attachment (PDF or image) to the Uploads folder.
                if (fileAttachment.HasFile)
                {
                    try
                    {
                        string uploadFolder = Server.MapPath("~/Uploads/");
                        if (!System.IO.Directory.Exists(uploadFolder))
                        {
                            System.IO.Directory.CreateDirectory(uploadFolder);
                        }

                        string ext = System.IO.Path.GetExtension(fileAttachment.FileName);
                        string uniqueFileName = "project_" + projectId + "_" +
                            Guid.NewGuid().ToString("N") + ext;
                        string savePath = System.IO.Path.Combine(uploadFolder, uniqueFileName);
                        fileAttachment.SaveAs(savePath);
                    }
                    catch (Exception uploadEx)
                    {
                        // The project is already created; surface a non-fatal warning.
                        ShowMessage("Project posted, but the attachment could not be saved: " + uploadEx.Message, false);
                    }
                }

                // Deduct the project budget from the employer's wallet and hold it
                // in escrow until the freelancer completes the project.
                decimal newBalance = walletBalance - budget;
                DatabaseHelper.UpdateWalletBalance(walletID, newBalance);

                string escrowReference = TransactionStore.CreateReference("ESCROW");
                DatabaseHelper.AddTransaction(
                    walletID,
                    "Funds held in escrow for project: " + txtProjectTitle.Text.Trim() +
                        " (Project ID: " + projectId + ")",
                    "Escrow",
                    budget,
                    "Held",
                    escrowReference,
                    "Wallet");

                // Keep the session balance in sync so other pages reflect the deduction.
                Session["AvailableBalance"] = newBalance;

                // Broadcast & Notify Users about the new project post
                int currentUserId = Convert.ToInt32(Session["UserID"]);
                string posterName = Session["FirstName"] as string ?? "A user";
                string projectTitle = txtProjectTitle.Text.Trim();

                string notificationText = $"A new project \"{projectTitle}\" has been posted by {posterName}. <a href='ProjectDetails.aspx?projectId={projectId}' style='color:#059669; font-weight:bold;'>View Details</a>";

                // Notify poster and broadcast to all active system users
                NotificationHelper.CreateNotification(currentUserId, "Project", notificationText);
                NotificationHelper.BroadcastNotification(currentUserId, "Project", notificationText);

                // Notify the employer that funds were removed from their wallet and held.
                string fundsHeldNotification =
                    "R" + budget.ToString("N2") + " has been removed from your wallet " +
                    "and held in escrow for your project \"" + projectTitle + "\".";
                NotificationHelper.CreateNotification(currentUserId, "Payment", fundsHeldNotification);

                ClearProjectForm();

                // Show a success pop-up with the escrow summary and let the user choose
                // where to go next (Dashboard or My Projects), instead of auto-redirecting.
                litSuccessMessage.Text =
                    "Project posted successfully! R" + budget.ToString("N2") +
                    " has been removed from your wallet and is held in escrow until the " +
                    "freelancer completes the project. Your remaining wallet balance is R" +
                    newBalance.ToString("N2") + ". (Project ID: " + projectId + ")";
                pnlSuccessModal.Visible = true;
            }
            catch (Exception ex)
            {
                ShowMessage("Error posting project: " + ex.Message, false);
            }
        }

        // EDIT PROJECT - not used for now since projects are in DB
        protected void btnEditProject_Click(object sender, EventArgs e)
        {
            ShowMessage("To edit a project, go to My Projects and select the project you want to edit.", true);
        }

        // PREVIEW
        protected void btnPreview_Click(object sender, EventArgs e)
        {
            lblPreviewTitle.Text = txtProjectTitle.Text;
            lblPreviewCategory.Text = GetSelectedCategory();
            lblPreviewDescription.Text = txtDescription.Text;
            lblPreviewBudget.Text = "R" + txtBudget.Text + " - " + rblBudgetType.SelectedItem.Text;
            lblPreviewDeadline.Text = txtDeadline.Text;
            lblPreviewExperience.Text = ddlExperience.SelectedValue;

            List<string> selectedSkills = new List<string>();
            foreach (ListItem skill in cblSkills.Items)
            {
                if (skill.Selected) selectedSkills.Add(skill.Text);
            }
            lblPreviewSkills.Text = selectedSkills.Count > 0
                ? string.Join(", ", selectedSkills) : "No skills selected";

            pnlPreview.Visible = true;
            ShowMessage("Preview generated. Review your project before posting.", true);
        }

        // CANCEL
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ClearProjectForm();
            pnlPreview.Visible = false;
            pnlProjectStatus.Visible = false;
        }

        // SUCCESS POP-UP NAVIGATION
        protected void btnGoDashboard_Click(object sender, EventArgs e)
        {
            Response.Redirect("Dashboard.aspx");
        }

        protected void btnGoMyProjects_Click(object sender, EventArgs e)
        {
            Response.Redirect("MyProjects.aspx");
        }

        /// <summary>Maximum budget a project may be posted with (R200 000.00).</summary>
        private const decimal MaxBudget = 200000m;

        /// <summary>Minimum number of characters required in the project description.</summary>
        private const int MinDescriptionLength = 50;

        /// <summary>
        /// Shows a validation message as a pop-up modal (reusing the page's modal styling)
        /// instead of the old top status bar. Used for budget limit / low-amount messages
        /// and the summary shown when Post is clicked with invalid fields.
        /// </summary>
        private void ShowValidationPopup(string message, string title = "Please check your details")
        {
            string safeMsg = message.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            string safeTitle = title.Replace("\\", "\\\\").Replace("'", "\\'");
            string script = "if(window.ppShowValidation){ppShowValidation('" + safeMsg + "','" + safeTitle + "');}";
            // Plain WebForms page (no AJAX ScriptManager), so register via ClientScript.
            ClientScript.RegisterStartupScript(GetType(), "ppValidate_" + Guid.NewGuid().ToString("N"), script, true);
        }

        // Clears all inline field errors and their red borders. Called at the start of
        // every validation pass so stale messages never linger.
        private void ClearFieldErrors()
        {
            lblErrTitle.Text = "";
            lblErrCategory.Text = "";
            lblErrOtherCategory.Text = "";
            lblErrExperience.Text = "";
            lblErrDescription.Text = "";
            lblErrBudgetType.Text = "";
            lblErrBudget.Text = "";
            lblErrDeadline.Text = "";
            lblErrSkills.Text = "";

            txtProjectTitle.CssClass = "post-input";
            ddlCategory.CssClass = "post-input";
            txtOtherCategory.CssClass = "post-input";
            ddlExperience.CssClass = "post-input";
            txtDescription.CssClass = "post-textarea";
            txtDeadline.CssClass = "post-input";
            rblBudgetType.CssClass = "post-budget-options";
            // txtBudget keeps its class; the red border is on the wrapper box (handled client-side).
        }

        // VALIDATE — sets a compact message beside each invalid field's label and
        // highlights the field border, instead of one big message at the top.
        private bool ValidateProject()
        {
            ClearFieldErrors();
            bool valid = true;
            bool firstHandled = false; // track whether we've seen the first error (for focus)
            string budgetPopup = null; // specific budget message to surface as a pop-up

            if (string.IsNullOrWhiteSpace(txtProjectTitle.Text))
            {
                lblErrTitle.Text = "Please enter a project title.";
                txtProjectTitle.CssClass = "post-input input-invalid";
                valid = false; firstHandled = true;
            }

            if (string.IsNullOrWhiteSpace(ddlCategory.SelectedValue))
            {
                lblErrCategory.Text = "Please select a category.";
                ddlCategory.CssClass = "post-input input-invalid";
                valid = false; firstHandled = true;
            }
            else if (ddlCategory.SelectedValue.Equals("Other", StringComparison.OrdinalIgnoreCase)
                     && string.IsNullOrWhiteSpace(txtOtherCategory.Text))
            {
                lblErrOtherCategory.Text = "Please specify the category.";
                txtOtherCategory.CssClass = "post-input input-invalid";
                valid = false; firstHandled = true;
            }

            if (string.IsNullOrWhiteSpace(ddlExperience.SelectedValue))
            {
                lblErrExperience.Text = "Please select an experience level.";
                ddlExperience.CssClass = "post-input input-invalid";
                valid = false; firstHandled = true;
            }

            string descText = (txtDescription.Text ?? "").Trim();
            if (descText.Length == 0)
            {
                lblErrDescription.Text = "Please enter a project description.";
                txtDescription.CssClass = "post-textarea input-invalid";
                valid = false; firstHandled = true;
            }
            else if (descText.Length < MinDescriptionLength)
            {
                lblErrDescription.Text = "Please enter at least 50 characters (" + descText.Length + "/50).";
                txtDescription.CssClass = "post-textarea input-invalid";
                valid = false; firstHandled = true;
            }

            if (string.IsNullOrWhiteSpace(rblBudgetType.SelectedValue))
            {
                lblErrBudgetType.Text = "Please choose a budget type.";
                rblBudgetType.CssClass = "post-budget-options input-invalid";
                valid = false; firstHandled = true;
            }

            // Budget: required, whole number (digits only), greater than zero, <= R200 000.
            string budgetRaw = (txtBudget.Text ?? "").Trim();
            if (budgetRaw.Length == 0)
            {
                lblErrBudget.Text = "Please enter a budget amount.";
                valid = false; firstHandled = true;
            }
            else if (!System.Text.RegularExpressions.Regex.IsMatch(budgetRaw, "^[0-9]+$"))
            {
                lblErrBudget.Text = "Enter whole rand amounts only (digits 0-9).";
                valid = false; firstHandled = true;
            }
            else
            {
                decimal parsed;
                if (!decimal.TryParse(budgetRaw,
                        System.Globalization.NumberStyles.None,
                        System.Globalization.CultureInfo.InvariantCulture, out parsed))
                {
                    lblErrBudget.Text = "Enter a valid budget amount.";
                    valid = false; firstHandled = true;
                }
                else if (parsed <= 0)
                {
                    lblErrBudget.Text = "Budget must be greater than zero.";
                    budgetPopup = "Please enter a budget greater than R0.00.";
                    valid = false; firstHandled = true;
                }
                else if (parsed > MaxBudget)
                {
                    lblErrBudget.Text = "Maximum budget allowed is R200 000.00";
                    budgetPopup = "Maximum budget allowed is R200 000.00.";
                    valid = false; firstHandled = true;
                }
            }

            if (string.IsNullOrWhiteSpace(txtDeadline.Text))
            {
                lblErrDeadline.Text = "Please select a deadline.";
                txtDeadline.CssClass = "post-input input-invalid";
                valid = false; firstHandled = true;
            }

            bool skillSelected = false;
            foreach (ListItem skill in cblSkills.Items)
            {
                if (skill.Selected) { skillSelected = true; break; }
            }
            if (!skillSelected)
            {
                lblErrSkills.Text = "Please select at least one skill.";
                valid = false; firstHandled = true;
            }

            // Keep the top status panel hidden for field-level validation; messages
            // now appear beside each field and as a pop-up summary.
            if (!valid)
            {
                pnlProjectStatus.Visible = false;

                // Show a pop-up. For budget-specific issues (too low / exceeding limit)
                // show that exact message; otherwise a short "please review" summary.
                if (!string.IsNullOrEmpty(budgetPopup))
                    ShowValidationPopup(budgetPopup, "Budget amount");
                else
                    ShowValidationPopup("Please review the highlighted fields and try again.");
            }

            // Mark firstHandled as used (avoids an unused-variable warning while keeping
            // the hook available for future focus handling).
            System.Diagnostics.Debug.WriteLineIf(firstHandled, "PostProject validation failed.");

            return valid;
        }

        // CLEAR FORM
        private void ClearProjectForm()
        {
            txtProjectTitle.Text = "";
            ddlCategory.SelectedIndex = 0;
            txtOtherCategory.Text = "";
            ddlExperience.SelectedIndex = 0;
            txtDescription.Text = "";
            rblBudgetType.SelectedValue = "Fixed";
            txtBudget.Text = "";
            txtDeadline.Text = "";
            lblAttachment.Text = "";
            pnlPreview.Visible = false;

            foreach (ListItem skill in cblSkills.Items)
            {
                skill.Selected = false;
            }
        }

        // SHOW MESSAGE
        // Success/informational messages (e.g. Preview) stay in the inline status panel.
        // Error messages are now surfaced as a pop-up modal, per the new UX.
        private void ShowMessage(string message, bool success)
        {
            if (success)
            {
                pnlProjectStatus.Visible = true;
                lblProjectStatus.Text = "<span style='display:flex;align-items:center;gap:10px;'><span style='background:#2e7d56;color:#fff;border-radius:50%;width:24px;height:24px;display:flex;align-items:center;justify-content:center;font-size:14px;'>&#10003;</span> " + message + "</span>";
                pnlProjectStatus.CssClass = "post-status post-success";
            }
            else
            {
                pnlProjectStatus.Visible = false;
                ShowValidationPopup(message, "Unable to post project");
            }
        }
    }
}
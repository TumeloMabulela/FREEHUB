// ============================================================
// B400 - Comment Project / Project Details
// FILE: ProjectDetails.aspx.cs
//
// PURPOSE: Shows the full details of a single project including
// title, description, budget, deadline, employer info and status.
// Also handles the comment section where users can post, reply,
// edit, and delete comments on the project.
// ============================================================

using System;
using System.Data;

namespace FreeHubProject
{
    public partial class ProjectDetails : System.Web.UI.Page
    {
        // ============================================================
        // ProjectId (property)
        // Reads the project ID from the URL query string.
        // e.g. ProjectDetails.aspx?id=3 -> returns 3
        // Returns 0 if no valid ID is found in the URL.
        // ============================================================
        private int ProjectId
        {
            get
            {
                int id = 0;
                int.TryParse(Request.QueryString["id"], out id);
                return id;
            }
        }

        // ============================================================
        // PAGE LOAD
        // 1. Checks the user is logged in
        // 2. On first load calls LoadProject() to show project details
        // 3. On first load calls LoadComments() to show the comments
        // ============================================================
        protected void Page_Load(object sender, EventArgs e)
        {
            // IF user is not logged in, send them to the login page
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // IF this is the first load (not a button click postback), load the data
            if (!IsPostBack)
            {
                pnlMessage.Visible = false;
                LoadProject();    // fills in title, description, budget, etc.
                LoadComments();   // fills in the comment list below the project
            }
        }

        // ============================================================
        // LoadProject()
        // Fetches the project record from the database using the
        // ID from the URL. Fills in all the detail labels on screen:
        // title, employer name, posted date, description, category,
        // experience level, budget type, budget amount, deadline, status.
        // ============================================================
        private void LoadProject()
        {
            // IF there is no valid project ID in the URL, show an error and stop
            if (ProjectId <= 0)
            {
                ShowMessage("No project selected.", false);
                return;
            }

            try
            {
                DataRow project = DatabaseHelper.GetProjectById(ProjectId);

                // IF the project was not found in the database (deleted or wrong ID)
                if (project == null)
                {
                    ShowMessage("Project not found.", false);
                    return;
                }

                // Fill in all the labels with the project data
                lblTitle.Text = TitleHelper.TitleCase(Convert.ToString(project["title"]));
                lblEmployerName.Text = Convert.ToString(project["employerName"]);
                lblPosted.Text = Convert.ToDateTime(project["dateCreated"]).ToString("dd MMM yyyy");
                lblDescription.Text = Convert.ToString(project["description"]);
                lblCategory.Text = Convert.ToString(project["category"]);
                lblExperience.Text = Convert.ToString(project["experienceLevel"]);

                // Show "Fixed Price" instead of just "Fixed" for better readability
                lblBudgetType.Text = Convert.ToString(project["budgetType"]) == "Fixed"
                    ? "Fixed Price"
                    : Convert.ToString(project["budgetType"]);

                lblBudget.Text = "R" + Convert.ToDecimal(project["budget"]).ToString("N2");
                lblDeadline.Text = Convert.ToDateTime(project["deadline"]).ToString("dd MMM yyyy");
                lblStatus.Text = Convert.ToString(project["projectStatus"]);
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading project: " + ex.Message, false);
            }
        }

        // ============================================================
        // LoadComments()
        // Fetches all comments for this project from the database.
        // Binds them to the comment repeater to display on screen.
        // Shows the "no comments yet" panel if none exist.
        // ============================================================
        private void LoadComments()
        {
            // IF no valid project ID in the URL, don't try to load comments
            if (ProjectId <= 0) return;

            try
            {
                // Get all comments for this project ordered by date
                DataTable comments = DatabaseHelper.GetCommentsByProject(ProjectId);

                // Bind comments to the repeater
                rptComments.DataSource = comments;
                rptComments.DataBind();

                // Show the comment count e.g. "3"
                lblCommentCount.Text = comments.Rows.Count.ToString();

                // IF no comments exist, show the "no comments yet" empty state panel
                pnlNoComments.Visible = comments.Rows.Count == 0;
            }
            catch
            {
                // IF loading fails, show the empty state and reset count to 0
                pnlNoComments.Visible = true;
                lblCommentCount.Text = "0";
            }
        }

        // ============================================================
        // rptComments_ItemCommand()
        // Fires when any button inside the comment repeater is clicked.
        // Handles three commands:
        // - DeleteComment: removes the comment from the database
        // - ReplyComment: sets up the reply box with the author's name
        // - EditComment: loads the existing text into the input box
        // ============================================================
        protected void rptComments_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            // IF the user clicked the Delete button on a comment
            if (e.CommandName == "DeleteComment")
            {
                int commentId = Convert.ToInt32(e.CommandArgument);
                try
                {
                    // Delete the comment - only if it belongs to the current user (userID check)
                    string query = "DELETE FROM Comment WHERE commentID = @CommentID AND userID = @UserID";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@CommentID", commentId),
                        new System.Data.SqlClient.SqlParameter("@UserID", Convert.ToInt32(Session["UserID"])));

                    // Reload the comment list to reflect the deletion
                    LoadComments();
                    ShowMessage("Comment deleted successfully.", true);
                }
                catch (Exception ex)
                {
                    ShowMessage("Error deleting comment: " + ex.Message, false);
                }
            }
            // IF the user clicked the Reply button on a comment
            else if (e.CommandName == "ReplyComment")
            {
                // Show the reply panel and pre-fill with the author's name
                string authorName = Convert.ToString(e.CommandArgument);
                pnlReplyingTo.Visible = true;
                lblReplyingTo.Text = authorName;
                txtComment.Text = "";
                txtComment.Focus(); // move cursor to the comment box
            }
            // IF the user clicked the Edit button on their own comment
            else if (e.CommandName == "EditComment")
            {
                // CommandArgument format is "commentID|commentText"
                string[] parts = Convert.ToString(e.CommandArgument).Split('|');

                // IF the argument was split into at least 2 parts (ID and text)
                if (parts.Length >= 2)
                {
                    // Store the comment ID in ViewState so we know which one to update
                    ViewState["EditingCommentID"] = parts[0];

                    // Pre-fill the text box with the existing comment text
                    txtComment.Text = parts[1];
                    pnlReplyingTo.Visible = true;
                    lblReplyingTo.Text = "Editing your comment";
                    txtComment.Focus();
                }
            }
        }

        // ============================================================
        // btnPostComment_Click()
        // Handles posting a new comment OR updating an existing one.
        // Steps:
        // 1. Validate comment is not empty and not too long
        // 2. IF editing: update the existing comment in the database
        // 3. IF replying: prefix comment with @username
        // 4. IF new: insert a new comment into the Comment table
        // 5. Clear the input and reload the comment list
        // ============================================================
        protected void btnPostComment_Click(object sender, EventArgs e)
        {
            // IF the comment box is empty, show an error and stop
            if (string.IsNullOrWhiteSpace(txtComment.Text))
            {
                ShowMessage("Please enter a comment.", false);
                return;
            }

            // IF the comment is longer than 1000 characters, reject it
            if (txtComment.Text.Trim().Length > 1000)
            {
                ShowMessage("Comment cannot exceed 1000 characters.", false);
                return;
            }

            try
            {
                int userId = Convert.ToInt32(Session["UserID"]);
                string commentText = txtComment.Text.Trim();

                // IF there is a comment ID stored in ViewState, we are EDITING an existing comment
                if (ViewState["EditingCommentID"] != null)
                {
                    int commentId = Convert.ToInt32(ViewState["EditingCommentID"]);

                    // Update the existing comment text in the database
                    string updateQuery = "UPDATE Comment SET commentText = @Text WHERE commentID = @ID AND userID = @UserID";
                    DatabaseHelper.ExecuteNonQuery(updateQuery,
                        new System.Data.SqlClient.SqlParameter("@Text", commentText),
                        new System.Data.SqlClient.SqlParameter("@ID", commentId),
                        new System.Data.SqlClient.SqlParameter("@UserID", userId));

                    // Clear the editing state so the next submit creates a new comment
                    ViewState["EditingCommentID"] = null;
                    ShowMessage("Comment updated successfully!", true);
                }
                else
                {
                    // IF the reply panel is visible AND has a name AND is not in edit mode,
                    // prefix the comment with @username to show who is being replied to
                    if (pnlReplyingTo.Visible &&
                        !string.IsNullOrEmpty(lblReplyingTo.Text) &&
                        lblReplyingTo.Text != "Editing your comment")
                    {
                        commentText = "@" + lblReplyingTo.Text + " " + commentText;
                    }

                    // Insert a new comment into the Comment table
                    DatabaseHelper.AddComment(ProjectId, userId, commentText);

                    // ============================================================
                    // NOTIFY THE EMPLOYER when a freelancer posts a comment
                    // 1. Get the project and employer details
                    // 2. IF the commenter is not the employer themselves, send a notification
                    // 3. The notification includes the comment text and a link to reply
                    // ============================================================
                    try
                    {
                        // Get the project details to find the employer
                        DataRow project = DatabaseHelper.GetProjectById(ProjectId);
                        if (project != null)
                        {
                            // Get the employer's user ID from the project
                            string getEmployerQuery = @"
                                SELECT e.userID AS EmployerUserID, u.firstName + ' ' + u.lastName AS EmployerName
                                FROM Project p
                                INNER JOIN Employer e ON p.employerID = e.employerID
                                INNER JOIN [User] u ON e.userID = u.userID
                                WHERE p.projectID = @ProjectID";

                            DataRow employerRow = DatabaseHelper.GetDataRow(getEmployerQuery,
                                new System.Data.SqlClient.SqlParameter("@ProjectID", ProjectId));

                            if (employerRow != null)
                            {
                                int employerUserId = Convert.ToInt32(employerRow["EmployerUserID"]);

                                // IF the commenter is NOT the employer themselves, send notification
                                // (no point notifying the employer about their own comment)
                                if (employerUserId != userId)
                                {
                                    // Get the commenter's name
                                    string commenterName = Session["FirstName"] + " " + Session["LastName"];
                                    string projectTitle = Convert.ToString(project["title"]);

                                    // Build the notification message with a reply link
                                    string notificationMsg = $"{commenterName} commented on your project " +
                                        $"<strong>\"{projectTitle}\"</strong>: " +
                                        $"<em>\"{(commentText.Length > 100 ? commentText.Substring(0, 100) + "..." : commentText)}\"</em> " +
                                        $"<a href='ProjectDetails.aspx?id={ProjectId}' style='color:#059669;font-weight:bold;'>Reply here</a>";

                                    // Send the notification to the employer
                                    NotificationHelper.CreateNotification(employerUserId, "Project", notificationMsg);
                                }
                            }
                        }
                    }
                    catch
                    {
                        // IF notification fails, don't block the comment from being posted
                        // The comment is already saved, the notification is just a bonus
                    }

                    ShowMessage("Comment posted successfully!", true);
                }

                // Clear the input box and hide the reply panel
                txtComment.Text = "";
                pnlReplyingTo.Visible = false;

                // Reload comments so the new/edited one appears immediately
                LoadComments();
            }
            catch (Exception ex)
            {
                ShowMessage("Error posting comment: " + ex.Message, false);
            }
        }

        // ============================================================
        // btnCancelReply_Click()
        // Hides the reply panel and clears the reply-to label
        // when the user cancels a reply or edit.
        // ============================================================
        protected void btnCancelReply_Click(object sender, EventArgs e)
        {
            pnlReplyingTo.Visible = false;
            lblReplyingTo.Text = "";
        }

        // ============================================================
        // GetAvatarColor(int index)
        // Returns a colour from a fixed array based on the comment
        // index. Used to give each commenter a different avatar colour.
        // Cycles through 6 colours using modulus (%).
        // ============================================================
        protected string GetAvatarColor(int index)
        {
            string[] colors = { "#2e7d56", "#1a5276", "#7d3c98", "#d35400", "#27ae60", "#2980b9" };
            return colors[index % colors.Length];
        }

        // ============================================================
        // GetTimeAgo(DateTime date)
        // Converts a UTC timestamp to a human-readable "time ago" string.
        // Examples:
        //   Less than 1 minute -> "Just now"
        //   Less than 60 minutes -> "5 min ago"
        //   Less than 24 hours -> "3 hours ago"
        //   Less than 7 days -> "2 days ago"
        //   7 days or more -> "15 Oct 2026"
        // ============================================================
        protected string GetTimeAgo(DateTime date)
        {
            // Calculate the time difference between now (UTC) and when the comment was posted
            TimeSpan diff = DateTime.UtcNow - DateTime.SpecifyKind(date, DateTimeKind.Utc);

            // IF posted less than 1 minute ago
            if (diff.TotalMinutes < 1) return "Just now";

            // IF posted less than 1 hour ago, show minutes
            if (diff.TotalMinutes < 60) return (int)diff.TotalMinutes + " min ago";

            // IF posted less than 24 hours ago, show hours
            if (diff.TotalHours < 24) return (int)diff.TotalHours + " hours ago";

            // IF posted less than 7 days ago, show days
            if (diff.TotalDays < 7) return (int)diff.TotalDays + " days ago";

            // IF older than 7 days, show the full date in South Africa time
            return TimeHelper.ToSast(date).ToString("dd MMM yyyy");
        }

        // ============================================================
        // ShowMessage()
        // Shows a green success message or red error message.
        // IF success = true -> green
        // IF success = false -> red
        // ============================================================
        private void ShowMessage(string message, bool success)
        {
            // IF success is true, show a green success message
            if (success) MessageHelper.Success(this, message);
            else MessageHelper.Error(this, message);
        }
    }
}

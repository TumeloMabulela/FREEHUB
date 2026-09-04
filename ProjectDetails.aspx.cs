using System;
using System.Data;

namespace FreeHubProject
{
    public partial class ProjectDetails : System.Web.UI.Page
    {
        private int ProjectId
        {
            get
            {
                int id = 0;
                int.TryParse(Request.QueryString["id"], out id);
                return id;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                pnlMessage.Visible = false;
                LoadProject();
                LoadComments();
            }
        }

        private void LoadProject()
        {
            if (ProjectId <= 0)
            {
                ShowMessage("No project selected.", false);
                return;
            }

            try
            {
                DataRow project = DatabaseHelper.GetProjectById(ProjectId);
                if (project == null)
                {
                    ShowMessage("Project not found.", false);
                    return;
                }

                lblTitle.Text = Convert.ToString(project["title"]);
                lblEmployerName.Text = Convert.ToString(project["employerName"]);
                lblPosted.Text = Convert.ToDateTime(project["dateCreated"]).ToString("dd MMM yyyy");
                lblDescription.Text = Convert.ToString(project["description"]);
                lblCategory.Text = Convert.ToString(project["category"]);
                lblExperience.Text = Convert.ToString(project["experienceLevel"]);
                lblBudgetType.Text = Convert.ToString(project["budgetType"]) == "Fixed" ? "Fixed Price" : Convert.ToString(project["budgetType"]);
                lblBudget.Text = "R" + Convert.ToDecimal(project["budget"]).ToString("N2");
                lblDeadline.Text = Convert.ToDateTime(project["deadline"]).ToString("dd MMM yyyy");
                lblStatus.Text = Convert.ToString(project["projectStatus"]);
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading project: " + ex.Message, false);
            }
        }

        private void LoadComments()
        {
            if (ProjectId <= 0) return;

            try
            {
                DataTable comments = DatabaseHelper.GetCommentsByProject(ProjectId);
                rptComments.DataSource = comments;
                rptComments.DataBind();
                lblCommentCount.Text = comments.Rows.Count.ToString();
                pnlNoComments.Visible = comments.Rows.Count == 0;
            }
            catch
            {
                pnlNoComments.Visible = true;
                lblCommentCount.Text = "0";
            }
        }

        protected void rptComments_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteComment")
            {
                int commentId = Convert.ToInt32(e.CommandArgument);
                try
                {
                    string query = "DELETE FROM Comment WHERE commentID = @CommentID AND userID = @UserID";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@CommentID", commentId),
                        new System.Data.SqlClient.SqlParameter("@UserID", Convert.ToInt32(Session["UserID"])));
                    LoadComments();
                    ShowMessage("Comment deleted successfully.", true);
                }
                catch (Exception ex)
                {
                    ShowMessage("Error deleting comment: " + ex.Message, false);
                }
            }
            else if (e.CommandName == "ReplyComment")
            {
                string authorName = Convert.ToString(e.CommandArgument);
                pnlReplyingTo.Visible = true;
                lblReplyingTo.Text = authorName;
                txtComment.Text = "";
                txtComment.Focus();
            }
            else if (e.CommandName == "EditComment")
            {
                string[] parts = Convert.ToString(e.CommandArgument).Split('|');
                if (parts.Length >= 2)
                {
                    ViewState["EditingCommentID"] = parts[0];
                    txtComment.Text = parts[1];
                    pnlReplyingTo.Visible = true;
                    lblReplyingTo.Text = "Editing your comment";
                    txtComment.Focus();
                }
            }
            else if (e.CommandName == "ReactComment")
            {
                // Just show a visual feedback - emoji reactions are decorative for now
                ShowMessage("Reaction added!", true);
                LoadComments();
            }
        }

        protected void btnCancelReply_Click(object sender, EventArgs e)
        {
            pnlReplyingTo.Visible = false;
            lblReplyingTo.Text = "";
            ViewState["EditingCommentID"] = null;
        }

        protected void btnPostComment_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtComment.Text))
            {
                ShowMessage("Please enter a comment.", false);
                return;
            }

            if (txtComment.Text.Trim().Length > 1000)
            {
                ShowMessage("Comment cannot exceed 1000 characters.", false);
                return;
            }

            try
            {
                int userId = Convert.ToInt32(Session["UserID"]);
                string commentText = txtComment.Text.Trim();

                // Check if editing
                if (ViewState["EditingCommentID"] != null)
                {
                    int commentId = Convert.ToInt32(ViewState["EditingCommentID"]);
                    string updateQuery = "UPDATE Comment SET commentText = @Text WHERE commentID = @ID AND userID = @UserID";
                    DatabaseHelper.ExecuteNonQuery(updateQuery,
                        new System.Data.SqlClient.SqlParameter("@Text", commentText),
                        new System.Data.SqlClient.SqlParameter("@ID", commentId),
                        new System.Data.SqlClient.SqlParameter("@UserID", userId));
                    ViewState["EditingCommentID"] = null;
                    ShowMessage("Comment updated successfully!", true);
                }
                else
                {
                    // Check if replying
                    if (pnlReplyingTo.Visible && !string.IsNullOrEmpty(lblReplyingTo.Text) && lblReplyingTo.Text != "Editing your comment")
                    {
                        commentText = "@" + lblReplyingTo.Text + " " + commentText;
                    }
                    DatabaseHelper.AddComment(ProjectId, userId, commentText);
                    ShowMessage("Comment posted successfully!", true);
                }

                txtComment.Text = "";
                pnlReplyingTo.Visible = false;
                LoadComments();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected string GetAvatarColor(int index)
        {
            string[] colors = { "#2e7d56", "#1a5276", "#7d3c98", "#d35400", "#27ae60", "#2980b9" };
            return colors[index % colors.Length];
        }

        protected string GetTimeAgo(DateTime date)
        {
            TimeSpan diff = DateTime.Now - date;
            if (diff.TotalMinutes < 1) return "Just now";
            if (diff.TotalMinutes < 60) return (int)diff.TotalMinutes + " min ago";
            if (diff.TotalHours < 24) return (int)diff.TotalHours + " hours ago";
            if (diff.TotalDays < 7) return (int)diff.TotalDays + " days ago";
            return date.ToString("dd MMM yyyy");
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = message;
            pnlMessage.CssClass = success ? "post-status post-success" : "post-status post-error";
        }
    }
}

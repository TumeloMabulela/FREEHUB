using System;
using System.Data;
using System.Globalization;

namespace FreeHubProject
{
    public partial class ProjectDetails : System.Web.UI.Page
    {
        private const string CommentSessionKey =
            "FreeHubProjectComments";


        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlMessage.Visible = false;

                EnsureCommentsExist();
                LoadComments();
            }
        }


        private void EnsureCommentsExist()
        {
            DataTable comments =
                Session[CommentSessionKey]
                as DataTable;

            if (comments != null)
            {
                return;
            }

            comments =
                CreateCommentTable();


            AddInitialComment(
                comments,
                "Sarah Lee",
                "SL",
                "This sounds like an interesting project! Do you have a preferred tech stack for the front-end development?",
                DateTime.Now.AddHours(-2),
                false
            );

            AddInitialComment(
                comments,
                GetCurrentUserName(),
                GetInitials(
                    GetCurrentUserName()
                ),
                "Hi! I have experience with React, Next.js and Tailwind CSS. I can definitely help with your project.",
                DateTime.Now.AddHours(-1),
                true
            );

            AddInitialComment(
                comments,
                "John Smith",
                "JS",
                "Great! Next.js would be perfect for our needs. Looking forward to your proposal.",
                DateTime.Now.AddMinutes(-30),
                false
            );

            AddInitialComment(
                comments,
                "Aisha Khan",
                "AK",
                "Can you please share more details about the admin panel requirements?",
                DateTime.Now.AddMinutes(-10),
                false
            );

            Session[CommentSessionKey] =
                comments;
        }


        private DataTable CreateCommentTable()
        {
            DataTable table =
                new DataTable();

            table.Columns.Add(
                "CommentId",
                typeof(string)
            );

            table.Columns.Add(
                "AuthorName",
                typeof(string)
            );

            table.Columns.Add(
                "Initials",
                typeof(string)
            );

            table.Columns.Add(
                "CommentText",
                typeof(string)
            );

            table.Columns.Add(
                "CommentDate",
                typeof(DateTime)
            );

            table.Columns.Add(
                "IsCurrentUser",
                typeof(bool)
            );

            table.Columns.Add(
                "ReplyToCommentId",
                typeof(string)
            );

            table.Columns.Add(
                "ReplyToName",
                typeof(string)
            );

            return table;
        }


        private void AddInitialComment(
            DataTable comments,
            string authorName,
            string initials,
            string commentText,
            DateTime commentDate,
            bool isCurrentUser)
        {
            DataRow row =
                comments.NewRow();

            row["CommentId"] =
                Guid.NewGuid().ToString("N");

            row["AuthorName"] =
                authorName;

            row["Initials"] =
                initials;

            row["CommentText"] =
                commentText;

            row["CommentDate"] =
                commentDate;

            row["IsCurrentUser"] =
                isCurrentUser;

            row["ReplyToCommentId"] =
                "";

            row["ReplyToName"] =
                "";

            comments.Rows.Add(row);
        }


        private DataTable GetComments()
        {
            DataTable comments =
                Session[CommentSessionKey]
                as DataTable;

            if (comments == null)
            {
                comments =
                    CreateCommentTable();

                Session[CommentSessionKey] =
                    comments;
            }

            return comments;
        }


        private void LoadComments()
        {
            DataTable comments =
                GetComments();

            DataTable displayTable =
                CreateDisplayTable();

            DataView sortedComments =
                comments.DefaultView;

            sortedComments.Sort =
                ddlCommentSort.SelectedValue ==
                "Oldest"
                    ? "CommentDate ASC"
                    : "CommentDate DESC";


            foreach (
                DataRowView commentView
                in sortedComments)
            {
                DataRow sourceRow =
                    commentView.Row;

                DataRow displayRow =
                    displayTable.NewRow();

                DateTime commentDate =
                    Convert.ToDateTime(
                        sourceRow["CommentDate"]
                    );

                displayRow["CommentId"] =
                    sourceRow["CommentId"];

                displayRow["AuthorName"] =
                    sourceRow["AuthorName"];

                displayRow["Initials"] =
                    sourceRow["Initials"];

                displayRow["CommentText"] =
                    sourceRow["CommentText"];

                displayRow["IsCurrentUser"] =
                    sourceRow["IsCurrentUser"];

                displayRow["ReplyToName"] =
                    sourceRow["ReplyToName"];

                displayRow["DisplayTime"] =
                    GetRelativeTime(
                        commentDate
                    );

                displayTable.Rows.Add(
                    displayRow
                );
            }


            rptComments.DataSource =
                displayTable;

            rptComments.DataBind();


            lblCommentCount.Text =
                "(" +
                comments.Rows.Count +
                ")";

            pnlNoComments.Visible =
                comments.Rows.Count == 0;
        }


        private DataTable CreateDisplayTable()
        {
            DataTable table =
                new DataTable();

            table.Columns.Add(
                "CommentId",
                typeof(string)
            );

            table.Columns.Add(
                "AuthorName",
                typeof(string)
            );

            table.Columns.Add(
                "Initials",
                typeof(string)
            );

            table.Columns.Add(
                "CommentText",
                typeof(string)
            );

            table.Columns.Add(
                "DisplayTime",
                typeof(string)
            );

            table.Columns.Add(
                "IsCurrentUser",
                typeof(bool)
            );

            table.Columns.Add(
                "ReplyToName",
                typeof(string)
            );

            return table;
        }


        protected void btnPostComment_Click(
            object sender,
            EventArgs e)
        {
            string commentText =
                txtComment.Text.Trim();

            if (string.IsNullOrWhiteSpace(
                commentText))
            {
                ShowMessage(
                    "Please enter a comment before posting.",
                    false
                );

                return;
            }

            if (commentText.Length > 1000)
            {
                ShowMessage(
                    "Your comment cannot exceed 1,000 characters.",
                    false
                );

                return;
            }


            DataTable comments =
                GetComments();

            string replyToCommentId =
                hfReplyToCommentId.Value;

            string replyToName =
                "";

            if (!string.IsNullOrWhiteSpace(
                replyToCommentId))
            {
                DataRow replyComment =
                    FindComment(
                        comments,
                        replyToCommentId
                    );

                if (replyComment != null)
                {
                    replyToName =
                        Convert.ToString(
                            replyComment["AuthorName"]
                        );
                }
            }


            string currentUserName =
                GetCurrentUserName();

            DataRow newComment =
                comments.NewRow();

            newComment["CommentId"] =
                Guid.NewGuid().ToString("N");

            newComment["AuthorName"] =
                currentUserName;

            newComment["Initials"] =
                GetInitials(
                    currentUserName
                );

            newComment["CommentText"] =
                commentText;

            newComment["CommentDate"] =
                DateTime.Now;

            newComment["IsCurrentUser"] =
                true;

            newComment["ReplyToCommentId"] =
                replyToCommentId ?? "";

            newComment["ReplyToName"] =
                replyToName;

            comments.Rows.Add(
                newComment
            );

            Session[CommentSessionKey] =
                comments;


            txtComment.Text =
                "";

            ClearReply();

            ddlCommentSort.SelectedValue =
                "Newest";

            LoadComments();

            ShowMessage(
                "Your comment was posted successfully.",
                true
            );
        }


        protected void rptComments_ItemCommand(
            object source,
            System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName !=
                "ReplyComment")
            {
                return;
            }

            string commentId =
                Convert.ToString(
                    e.CommandArgument
                );

            DataRow comment =
                FindComment(
                    GetComments(),
                    commentId
                );

            if (comment == null)
            {
                ShowMessage(
                    "The selected comment could not be found.",
                    false
                );

                return;
            }

            hfReplyToCommentId.Value =
                commentId;

            lblReplyingTo.Text =
                Convert.ToString(
                    comment["AuthorName"]
                );

            pnlReplyingTo.Visible =
                true;

            txtComment.Focus();
        }


        protected void btnCancelReply_Click(
            object sender,
            EventArgs e)
        {
            ClearReply();
        }


        private void ClearReply()
        {
            hfReplyToCommentId.Value =
                "";

            lblReplyingTo.Text =
                "";

            pnlReplyingTo.Visible =
                false;
        }


        protected void ddlCommentSort_SelectedIndexChanged(
            object sender,
            EventArgs e)
        {
            LoadComments();
        }


        private DataRow FindComment(
            DataTable comments,
            string commentId)
        {
            foreach (
                DataRow row
                in comments.Rows)
            {
                if (string.Equals(
                    Convert.ToString(
                        row["CommentId"]
                    ),
                    commentId,
                    StringComparison.OrdinalIgnoreCase))
                {
                    return row;
                }
            }

            return null;
        }


        private string GetCurrentUserName()
        {
            string userName =
                Convert.ToString(
                    Session["CurrentUserName"]
                );

            if (string.IsNullOrWhiteSpace(
                userName))
            {
                userName =
                    "Mabuella London";

                Session["CurrentUserName"] =
                    userName;
            }

            return userName;
        }


        private string GetInitials(
            string fullName)
        {
            if (string.IsNullOrWhiteSpace(
                fullName))
            {
                return "FH";
            }

            string[] names =
                fullName.Split(
                    new[] { ' ' },
                    StringSplitOptions.RemoveEmptyEntries
                );

            if (names.Length == 1)
            {
                return names[0]
                    .Substring(0, 1)
                    .ToUpperInvariant();
            }

            return
                names[0]
                    .Substring(0, 1)
                    .ToUpperInvariant() +
                names[names.Length - 1]
                    .Substring(0, 1)
                    .ToUpperInvariant();
        }


        private string GetRelativeTime(
            DateTime commentDate)
        {
            TimeSpan difference =
                DateTime.Now -
                commentDate;

            if (difference.TotalMinutes < 1)
            {
                return "Just now";
            }

            if (difference.TotalMinutes < 60)
            {
                int minutes =
                    Math.Max(
                        1,
                        (int)difference.TotalMinutes
                    );

                return
                    minutes +
                    (
                        minutes == 1
                            ? " minute ago"
                            : " minutes ago"
                    );
            }

            if (difference.TotalHours < 24)
            {
                int hours =
                    Math.Max(
                        1,
                        (int)difference.TotalHours
                    );

                return
                    hours +
                    (
                        hours == 1
                            ? " hour ago"
                            : " hours ago"
                    );
            }

            if (difference.TotalDays < 7)
            {
                int days =
                    Math.Max(
                        1,
                        (int)difference.TotalDays
                    );

                return
                    days +
                    (
                        days == 1
                            ? " day ago"
                            : " days ago"
                    );
            }

            return commentDate.ToString(
                "dd MMM yyyy",
                CultureInfo.InvariantCulture
            );
        }


        private void ShowMessage(
            string message,
            bool success)
        {
            pnlMessage.Visible =
                true;

            lblMessage.Text =
                message;

            pnlMessage.CssClass =
                success
                    ? "pd-message pd-success-message"
                    : "pd-message pd-error-message";
        }
    }
}
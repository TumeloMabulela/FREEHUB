using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class StartChat : System.Web.UI.Page
    {
        private readonly string _connStr = ConfigurationManager.ConnectionStrings["FreeHubDB"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;

            if (!IsPostBack)
            {
                BindApprovedChatUsers("");

                string userFromQuery = Request.QueryString["user"];
                string openChat = Request.QueryString["open"];

                if (!string.IsNullOrWhiteSpace(userFromQuery))
                {
                    SelectUserByName(userFromQuery);
                }
                else if (SelectedOtherUserId > 0)
                {
                    SelectUserById(SelectedOtherUserId);
                }
            }
        }

        private int CurrentUserId
        {
            get { return Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0; }
        }

        public int SelectedOtherUserId
        {
            get { return Session["SelectedOtherUserId"] != null ? Convert.ToInt32(Session["SelectedOtherUserId"]) : 0; }
            set { Session["SelectedOtherUserId"] = value; }
        }

        private int ActiveProjectId
        {
            get { return Session["ActiveProjectId"] != null ? Convert.ToInt32(Session["ActiveProjectId"]) : 0; }
            set { Session["ActiveProjectId"] = value; }
        }

        private void BindApprovedChatUsers(string searchText)
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    SELECT DISTINCT 
                        u.userID AS UserID,
                        (u.firstName + ' ' + u.lastName) AS Name,
                        (LEFT(u.firstName, 1) + LEFT(u.lastName, 1)) AS Initials,
                        p.projectID AS ProjectID,
                        p.title AS ProjectTitle,
                        ISNULL((SELECT TOP 1 content FROM dbo.Message WHERE (senderID = u.userID AND receiverID = @CurrentUserID) OR (senderID = @CurrentUserID AND receiverID = u.userID) ORDER BY timeStamp DESC), 'No messages yet') AS LastMessage,
                        ISNULL((SELECT TOP 1 FORMAT(timeStamp, 'hh:mm tt') FROM dbo.Message WHERE (senderID = u.userID AND receiverID = @CurrentUserID) OR (senderID = @CurrentUserID AND receiverID = u.userID) ORDER BY timeStamp DESC), '') AS LastTime
                    FROM dbo.Proposal prop
                    INNER JOIN dbo.Project p ON prop.projectID = p.projectID
                    INNER JOIN dbo.Employer e ON p.employerID = e.employerID
                    INNER JOIN dbo.Freelancer f ON prop.freelancerID = f.freelancerID
                    INNER JOIN dbo.[User] u ON (
                        CASE 
                            WHEN e.userID = @CurrentUserID THEN f.userID
                            WHEN f.userID = @CurrentUserID THEN e.userID
                        END = u.userID
                    )
                    WHERE prop.status = 'Approved' 
                      AND (e.userID = @CurrentUserID OR f.userID = @CurrentUserID)";

                if (!string.IsNullOrWhiteSpace(searchText))
                {
                    query += " AND (u.firstName + ' ' + u.lastName LIKE @Search OR p.title LIKE @Search)";
                }

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CurrentUserID", CurrentUserId);
                    if (!string.IsNullOrWhiteSpace(searchText))
                    {
                        cmd.Parameters.AddWithValue("@Search", "%" + searchText + "%");
                    }

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            rptUsers.DataSource = dt;
            rptUsers.DataBind();
            lblNoUsers.Visible = dt.Rows.Count == 0;

            // Auto-select first user if none selected
            if (dt.Rows.Count > 0 && SelectedOtherUserId == 0)
            {
                SelectUserById(Convert.ToInt32(dt.Rows[0]["UserID"]));
            }
        }

        public string GetAvatarClass(string initials)
        {
            switch (initials.ToUpper())
            {
                case "RT": return "avatar-rt";
                case "MT": return "avatar-mt";
                case "MU": return "avatar-mu";
                default: return "avatar-ml";
            }
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectUser")
            {
                int otherUserId = Convert.ToInt32(e.CommandArgument);
                SelectUserById(otherUserId);
            }
        }

        private void SelectUserByName(string userName)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"SELECT TOP 1 userID FROM dbo.[User] WHERE (firstName + ' ' + lastName) = @UserName OR username = @UserName";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserName", userName);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null)
                    {
                        SelectUserById(Convert.ToInt32(result));
                    }
                }
            }
        }

        private void SelectUserById(int otherUserId)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    SELECT TOP 1 
                        u.userID AS UserID,
                        (u.firstName + ' ' + u.lastName) AS Name,
                        (LEFT(u.firstName, 1) + LEFT(u.lastName, 1)) AS Initials,
                        p.projectID AS ProjectID,
                        p.projectStatus AS ProjectStatus
                    FROM dbo.Proposal prop
                    INNER JOIN dbo.Project p ON prop.projectID = p.projectID
                    INNER JOIN dbo.Employer e ON p.employerID = e.employerID
                    INNER JOIN dbo.Freelancer f ON prop.freelancerID = f.freelancerID
                    INNER JOIN dbo.[User] u ON u.userID = @OtherUserID
                    WHERE prop.status = 'Approved' 
                      AND ((e.userID = @CurrentUserID AND f.userID = @OtherUserID) OR (f.userID = @CurrentUserID AND e.userID = @OtherUserID))";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CurrentUserID", CurrentUserId);
                    cmd.Parameters.AddWithValue("@OtherUserID", otherUserId);
                    conn.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            SelectedOtherUserId = Convert.ToInt32(dr["UserID"]);
                            ActiveProjectId = Convert.ToInt32(dr["ProjectID"]);
                            string projectStatus = dr["ProjectStatus"].ToString();

                            lblChatName.Text = dr["Name"].ToString();
                            lblChatInitials.Text = dr["Initials"].ToString();

                            if (projectStatus.Equals("Completed", StringComparison.OrdinalIgnoreCase))
                            {
                                btnSend.Enabled = false;
                                pnlRatingModal.Visible = true;
                                ShowStatus("Project Completed. Messaging is closed.");
                            }
                            else
                            {
                                btnSend.Enabled = true;
                            }

                            LoadChatMessages();
                        }
                    }
                }
            }
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            if (SelectedOtherUserId <= 0 || string.IsNullOrWhiteSpace(txtMessage.Text)) return;

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    INSERT INTO dbo.Message (senderID, receiverID, projectID, content, timeStamp, status)
                    VALUES (@SenderID, @ReceiverID, @ProjectID, @Content, GETDATE(), 'Sent')";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@SenderID", CurrentUserId);
                    cmd.Parameters.AddWithValue("@ReceiverID", SelectedOtherUserId);
                    cmd.Parameters.AddWithValue("@ProjectID", ActiveProjectId > 0 ? (object)ActiveProjectId : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Content", txtMessage.Text.Trim());

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            string senderName = Session["FirstName"] != null ? Session["FirstName"].ToString() : "A user";
            NotificationHelper.CreateNotification(SelectedOtherUserId, "Message", $"{senderName} sent you a message.");

            txtMessage.Text = "";
            ShowStatus("Message sent successfully.");
            LoadChatMessages();
            BindApprovedChatUsers("");
        }

        private void LoadChatMessages()
        {
            phMessages.Controls.Clear();
            if (SelectedOtherUserId <= 0) return;

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    SELECT senderID, content, FORMAT(timeStamp, 'hh:mm tt') AS timeStr
                    FROM dbo.Message
                    WHERE (senderID = @CurrentUserID AND receiverID = @OtherUserID)
                       OR (senderID = @OtherUserID AND receiverID = @CurrentUserID)
                    ORDER BY timeStamp ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CurrentUserID", CurrentUserId);
                    cmd.Parameters.AddWithValue("@OtherUserID", SelectedOtherUserId);
                    conn.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            int senderId = Convert.ToInt32(dr["senderID"]);
                            string content = HttpUtility.HtmlEncode(dr["content"].ToString());
                            string timeStr = dr["timeStr"].ToString();

                            bool isMe = (senderId == CurrentUserId);
                            string rowClass = isMe ? "msg-row sent" : "msg-row received";
                            string bubbleClass = isMe ? "msg-bubble-sent" : "msg-bubble-received";
                            string ticksHtml = isMe ? "<span class='ticks-blue'>✓✓</span>" : "";
                            string initials = isMe ? "ML" : lblChatInitials.Text;
                            string avatarClass = GetAvatarClass(initials);

                            string html = $@"
                                <div class='{rowClass}'>
                                    <div class='avatar-circle {avatarClass}' style='width:32px;height:32px;font-size:11px;'>{initials}</div>
                                    <div class='{bubbleClass}'>
                                        <div>{content}</div>
                                        <div class='msg-meta'><span>{timeStr}</span> {ticksHtml}</div>
                                    </div>
                                </div>";

                            phMessages.Controls.Add(new LiteralControl(html));
                        }
                    }
                }
            }
        }

        protected void btnSubmitRating_Click(object sender, EventArgs e)
        {
            if (SelectedOtherUserId <= 0 || ActiveProjectId <= 0) return;

            int score = Convert.ToInt32(ddlRatingStars.SelectedValue);
            string comment = txtRatingComment.Text.Trim();
            decimal updatedScore = 0.00m;

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                conn.Open();
                string insertQuery = @"
                    INSERT INTO dbo.Rating (projectID, raterUserID, ratedUserID, score, ratingComment, ratingDate)
                    VALUES (@ProjectID, @RaterUserID, @RatedUserID, @Score, @Comment, GETDATE())";

                using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@ProjectID", ActiveProjectId);
                    cmd.Parameters.AddWithValue("@RaterUserID", CurrentUserId);
                    cmd.Parameters.AddWithValue("@RatedUserID", SelectedOtherUserId);
                    cmd.Parameters.AddWithValue("@Score", score);
                    cmd.Parameters.AddWithValue("@Comment", string.IsNullOrEmpty(comment) ? (object)DBNull.Value : comment);
                    cmd.ExecuteNonQuery();
                }

                string updateQuery = @"
                    UPDATE dbo.[User]
                    SET ratingScore = (SELECT CAST(AVG(CAST(score AS DECIMAL(3,2))) AS DECIMAL(3,2)) FROM dbo.Rating WHERE ratedUserID = @RatedUserID)
                    OUTPUT INSERTED.ratingScore WHERE userID = @RatedUserID";

                using (SqlCommand cmdUpdate = new SqlCommand(updateQuery, conn))
                {
                    cmdUpdate.Parameters.AddWithValue("@RatedUserID", SelectedOtherUserId);
                    object res = cmdUpdate.ExecuteScalar();
                    if (res != null) updatedScore = Convert.ToDecimal(res);
                }
            }

            pnlRatingModal.Visible = false;
            ShowStatus($"Rating submitted! Reputation score updated to {updatedScore:F1} / 5.0.");
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            pnlRatingModal.Visible = false;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindApprovedChatUsers(txtSearch.Text.Trim());
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            BindApprovedChatUsers(txtSearch.Text.Trim());
        }

        private void ShowStatus(string message)
        {
            pnlStatus.Visible = true;
            lblStatus.Text = message;
        }
    }
}
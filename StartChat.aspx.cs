using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;
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
                // Heartbeat: update current user's last seen timestamp
                DatabaseHelper.UpdateUserLastSeen(CurrentUserId);

                BindApprovedChatUsers("");

                string queryUserId = Request.QueryString["userId"];
                string userFromQuery = Request.QueryString["user"];

                // Deep links (e.g. a "Message" button elsewhere) open the popup straight away.
                // A plain visit to Messages shows the dashboard first (popup stays closed).
                if (!string.IsNullOrWhiteSpace(queryUserId))
                {
                    int uid;
                    if (int.TryParse(queryUserId, out uid))
                    {
                        SelectUserById(uid);
                    }
                }
                else if (!string.IsNullOrWhiteSpace(userFromQuery))
                {
                    SelectUserByName(userFromQuery);
                }
                else
                {
                    // Fresh Messages visit: dashboard only, no auto-opened conversation.
                    ChatOpen = false;
                }
            }
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            // Welcome screen vs active chat.
            pnlWelcome.Visible = !ChatOpen;
            pnlChatPopup.Visible = ChatOpen;

            // Add 'chat-open' class for mobile responsive (hides sidebar, shows chat).
            workspacePanel.Attributes["class"] = ChatOpen ? "fh-msg-root chat-open" : "fh-msg-root";

            // Project details side-panel: only shown when a conversation is open AND there
            // is an active project between the two users.
            if (ChatOpen && ActiveProjectId > 0)
            {
                pnlProjectBar.Visible = true;
                pnlProjectDetails.Visible = true;
                BindProjectDetails();
            }
            else
            {
                pnlProjectBar.Visible = false;
                pnlProjectDetails.Visible = false;
            }

            // Scroll the thread to the newest message after it renders (open or switch).
            if (ChatOpen)
            {
                ScriptManager.RegisterStartupScript(
                    this, GetType(), "scrollPopup",
                    "if (window.scrollPopupToBottom) { scrollPopupToBottom(); }", true);
            }
        }

        /// <summary>
        /// Fills the project-details side panel and project sub-bar with data from
        /// the active project between the current user and the selected contact.
        /// Also binds the shared files repeater inside the details panel.
        /// </summary>
        private void BindProjectDetails()
        {
            if (ActiveProjectId <= 0) return;

            DataRow project = DatabaseHelper.GetProjectById(ActiveProjectId);
            if (project != null)
            {
                string title = Convert.ToString(project["title"]);
                string status = Convert.ToString(project["projectStatus"]);

                lblProjectBarTitle.Text = title;
                lblProjectBarStatus.Text = status;
                lblDetailsProjectTitle.Text = title;
                lblDetailsProjectStatus.Text = status;
            }
            else
            {
                lblProjectBarTitle.Text = "Project";
                lblProjectBarStatus.Text = "—";
                lblDetailsProjectTitle.Text = "Project";
                lblDetailsProjectStatus.Text = "—";
            }

            // Shared files for the details panel — files exchanged between the two users.
            LoadSharedFilesForDetailsPanel();
        }

        /// <summary>
        /// Binds the shared-files repeater inside the collapsible project details panel
        /// with files exchanged between the current user and the selected contact.
        /// </summary>
        private void LoadSharedFilesForDetailsPanel()
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    SELECT attachmentUrl, timeStamp 
                    FROM dbo.Message 
                    WHERE ((senderID = @CurrentUserID AND receiverID = @OtherUserID) 
                        OR (senderID = @OtherUserID AND receiverID = @CurrentUserID))
                      AND attachmentUrl IS NOT NULL 
                      AND attachmentUrl != ''
                    ORDER BY timeStamp DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CurrentUserID", CurrentUserId);
                    cmd.Parameters.AddWithValue("@OtherUserID", SelectedOtherUserId);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dtFiles = new DataTable();
                        da.Fill(dtFiles);

                        rptSharedFiles.DataSource = dtFiles;
                        rptSharedFiles.DataBind();
                        lblNoSharedFiles.Visible = dtFiles.Rows.Count == 0;
                    }
                }
            }
        }

        public int CurrentUserId
        {
            get { return Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0; }
        }

        public int SelectedOtherUserId
        {
            get { return Session["SelectedOtherUserId"] != null ? Convert.ToInt32(Session["SelectedOtherUserId"]) : 0; }
            set { Session["SelectedOtherUserId"] = value; }
        }

        /// <summary>
        /// True when a conversation is open, so the floating chat popup is shown over the
        /// Messages dashboard. False shows the dashboard/workspace only.
        /// </summary>
        public bool ChatOpen
        {
            get { return ViewState["ChatOpen"] != null && (bool)ViewState["ChatOpen"]; }
            set { ViewState["ChatOpen"] = value; }
        }

        private int ActiveProjectId
        {
            get { return Session["ActiveProjectId"] != null ? Convert.ToInt32(Session["ActiveProjectId"]) : 0; }
            set { Session["ActiveProjectId"] = value; }
        }

        /// <summary>
        /// The active conversation-list filter: All, Unread, Clients, or Freelancers.
        /// </summary>
        private string ContactFilter
        {
            get { return ViewState["ContactFilter"] as string ?? "All"; }
            set { ViewState["ContactFilter"] = value; }
        }

        private void BindApprovedChatUsers(string searchText)
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                // One row PER CONTACT (other user), not per project. A freelancer and an
                // employer who have worked on several projects together share a single chat,
                // so a completed project followed by a new one reuses the same conversation
                // instead of creating a duplicate contact row.
                string query = @"
                    SELECT
                        u.userID AS UserID,
                        u.userType AS UserType,
                        (u.firstName + ' ' + u.lastName) AS Name,
                        (LEFT(u.firstName, 1) + LEFT(u.lastName, 1)) AS Initials,
                        ISNULL((SELECT TOP 1 content FROM dbo.Message WHERE (senderID = u.userID AND receiverID = @CurrentUserID) OR (senderID = @CurrentUserID AND receiverID = u.userID) ORDER BY timeStamp DESC), 'No messages yet') AS LastMessage,
                        -- Displayed time, converted from stored UTC to South Africa time (UTC+2)
                        ISNULL((SELECT TOP 1 FORMAT(DATEADD(HOUR, 2, timeStamp), 'hh:mm tt') FROM dbo.Message WHERE (senderID = u.userID AND receiverID = @CurrentUserID) OR (senderID = @CurrentUserID AND receiverID = u.userID) ORDER BY timeStamp DESC), '') AS LastTime,
                        -- Sortable raw timestamp of the latest message (NULL sorts last)
                        (SELECT TOP 1 timeStamp FROM dbo.Message WHERE (senderID = u.userID AND receiverID = @CurrentUserID) OR (senderID = @CurrentUserID AND receiverID = u.userID) ORDER BY timeStamp DESC) AS LastTimeSort,
                        -- Count of unread messages FROM this contact TO the current user
                        (SELECT COUNT(*) FROM dbo.Message WHERE senderID = u.userID AND receiverID = @CurrentUserID AND status <> 'Read') AS UnreadCount
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
                    query += " AND (u.firstName + ' ' + u.lastName LIKE @Search)";
                }

                // Role filters: Clients = contacts who are Employers; Freelancers = contacts who are Freelancers.
                if (ContactFilter == "Clients")
                {
                    query += " AND u.userType = 'Employer'";
                }
                else if (ContactFilter == "Freelancers")
                {
                    query += " AND u.userType = 'Freelancer'";
                }

                // Collapse to a single row per contact regardless of how many shared projects.
                query += @"
                    GROUP BY u.userID, u.userType, u.firstName, u.lastName";

                // Unread filter is applied after grouping (depends on the aggregated unread count).
                if (ContactFilter == "Unread")
                {
                    query += @"
                    HAVING (SELECT COUNT(*) FROM dbo.Message WHERE senderID = u.userID AND receiverID = @CurrentUserID AND status <> 'Read') > 0";
                }

                // Newest conversation first; contacts with no messages fall to the bottom.
                query += " ORDER BY LastTimeSort DESC";

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
            lblNoUsers.Visible = (dt.Rows.Count == 0);

            // Reflect the active filter in the tab styling.
            SetActiveFilterTab();
        }

        /// <summary>
        /// Handles clicks on the All / Unread / Clients / Freelancers filter tabs.
        /// </summary>
        protected void Filter_Click(object sender, EventArgs e)
        {
            var btn = sender as System.Web.UI.WebControls.LinkButton;
            if (btn != null)
            {
                ContactFilter = btn.CommandArgument;
            }
            BindApprovedChatUsers(txtSearch.Text.Trim());
        }

        /// <summary>
        /// Adds the 'active' CSS class to whichever filter tab is currently selected.
        /// </summary>
        private void SetActiveFilterTab()
        {
            btnFilterAll.CssClass = "fh-filter" + (ContactFilter == "All" ? " active" : "");
            btnFilterUnread.CssClass = "fh-filter" + (ContactFilter == "Unread" ? " active" : "");
            btnFilterClients.CssClass = "fh-filter-chip" + (ContactFilter == "Clients" ? " active" : "");
            btnFilterFreelancers.CssClass = "fh-filter-chip" + (ContactFilter == "Freelancers" ? " active" : "");
        }

        protected void btnToggleDetails_Click(object sender, EventArgs e)
        {
            if (SelectedOtherUserId <= 0) return;

            pnlUserDetailsModal.Visible = true;
            LoadUserDetailsAndSharedFiles(SelectedOtherUserId);
        }

        protected void btnCloseDetails_Click(object sender, EventArgs e)
        {
            pnlUserDetailsModal.Visible = false;
        }

        private void LoadUserDetailsAndSharedFiles(int targetUserId)
        {
            // 1. Load User Profile Details
            DataRow user = DatabaseHelper.GetUserById(targetUserId);
            if (user != null)
            {
                lblDetailName.Text = Convert.ToString(user["firstName"]) + " " + Convert.ToString(user["lastName"]);
                lblDetailEmail.Text = Convert.ToString(user["email"]);
                lblDetailContact.Text = user["contactNumber"] != DBNull.Value ? Convert.ToString(user["contactNumber"]) : "N/A";
                lblDetailUserType.Text = Convert.ToString(user["userType"]);

                decimal rating = user["ratingScore"] != DBNull.Value ? Convert.ToDecimal(user["ratingScore"]) : 0.0m;
                lblDetailRating.Text = rating.ToString("F1");
            }

            // 2. Load Shared File Attachments History
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    SELECT attachmentUrl, timeStamp 
                    FROM dbo.Message 
                    WHERE ((senderID = @CurrentUserID AND receiverID = @OtherUserID) 
                        OR (senderID = @OtherUserID AND receiverID = @CurrentUserID))
                      AND attachmentUrl IS NOT NULL 
                      AND attachmentUrl != ''
                    ORDER BY timeStamp DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CurrentUserID", CurrentUserId);
                    cmd.Parameters.AddWithValue("@OtherUserID", targetUserId);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dtFiles = new DataTable();
                        da.Fill(dtFiles);

                        if (dtFiles.Rows.Count > 0)
                        {
                            rptSharedFiles.DataSource = dtFiles;
                            rptSharedFiles.DataBind();
                            lblNoSharedFiles.Visible = false;
                        }
                        else
                        {
                            rptSharedFiles.DataSource = null;
                            rptSharedFiles.DataBind();
                            lblNoSharedFiles.Visible = true;
                        }
                    }
                }
            }
        }

        public string GetAvatarClass(string initials)
        {
            if (string.IsNullOrEmpty(initials)) return "avatar-ml";
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
            SelectedOtherUserId = otherUserId;
            ChatOpen = true;   // opening/switching a conversation shows the floating popup

            // Fetch user profile info
            DataRow user = DatabaseHelper.GetUserById(otherUserId);
            if (user != null)
            {
                string firstName = user["firstName"].ToString();
                string lastName = user["lastName"].ToString();
                lblChatName.Text = firstName + " " + lastName;
                lblChatInitials.Text = (!string.IsNullOrEmpty(firstName) ? firstName[0].ToString() : "") +
                                       (!string.IsNullOrEmpty(lastName) ? lastName[0].ToString() : "");

                string accountStatus = Convert.ToString(user["accountStatus"]);
                if (accountStatus == "Inactive" || accountStatus == "Deleted" || accountStatus == "Deactivated")
                {
                    lblPartnerStatus.Text = "Account Deactivated 🔴";
                    statusDot.Attributes["class"] = "status-dot offline";
                }
                else
                {
                    string onlineStatus = DatabaseHelper.GetUserOnlineStatus(otherUserId);
                    lblPartnerStatus.Text = onlineStatus;

                    // Green dot only when actually online; red otherwise (last seen / offline).
                    bool isOnline = onlineStatus.IndexOf("Online", StringComparison.OrdinalIgnoreCase) >= 0;
                    statusDot.Attributes["class"] = isOnline ? "status-dot" : "status-dot offline";
                }
            }

            bool isChatEndedOrDeactivated = false;
            string lockReasonMessage = string.Empty;

            // 1. Check if partner account status is Deactivated, Deleted, or Inactive
            if (user != null)
            {
                string accountStatus = Convert.ToString(user["accountStatus"]);
                if (accountStatus.Equals("Deactivated", StringComparison.OrdinalIgnoreCase) ||
                    accountStatus.Equals("Deleted", StringComparison.OrdinalIgnoreCase) ||
                    accountStatus.Equals("Inactive", StringComparison.OrdinalIgnoreCase))
                {
                    isChatEndedOrDeactivated = true;
                    lockReasonMessage = "The profile has been deactivated";
                }
            }

            // 2. Check if there is an active/completed proposal/project between these two users (with proper JOINs)
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                // Pick the MOST RECENT approved project between these two users, and prefer a
                // project that is still active. This way, when an old project is completed and
                // a new one is approved with the same people, the existing chat reopens for the
                // new project instead of staying locked on the completed one.
                string query = @"SELECT TOP 1 p.projectID, p.projectStatus, u.accountStatus AS EmployerAccountStatus
                    FROM dbo.Proposal prop
                    INNER JOIN dbo.Project p ON prop.projectID = p.projectID
                    INNER JOIN dbo.Employer e ON p.employerID = e.employerID
                    INNER JOIN dbo.Freelancer f ON prop.freelancerID = f.freelancerID
                    INNER JOIN dbo.[User] u ON e.userID = u.userID
                    WHERE prop.status = 'Approved'
                      AND ((e.userID = @CurrentUserID AND f.userID = @OtherUserID) OR (f.userID = @CurrentUserID AND e.userID = @OtherUserID))
                    ORDER BY
                        CASE WHEN p.projectStatus IN ('Completed', 'Cancelled') THEN 1 ELSE 0 END ASC,
                        p.dateCreated DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CurrentUserID", CurrentUserId);
                    cmd.Parameters.AddWithValue("@OtherUserID", otherUserId);
                    conn.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            ActiveProjectId = Convert.ToInt32(dr["projectID"]);
                            string projectStatus = dr["projectStatus"].ToString();
                            string empAccountStatus = dr["EmployerAccountStatus"].ToString();

                            if (projectStatus.Equals("Completed", StringComparison.OrdinalIgnoreCase) ||
                                projectStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
                            {
                                isChatEndedOrDeactivated = true;
                                lockReasonMessage = "Project completed";

                                // Close data reader so we can execute a scalar check safely on the same connection
                                dr.Close();

                                // Check if the current user has already rated this project
                                string checkRatingQuery = "SELECT COUNT(*) FROM dbo.Rating WHERE projectID = @ProjectID AND raterUserID = @RaterUserID";
                                int existingRatings = 0;
                                using (SqlCommand ratingCmd = new SqlCommand(checkRatingQuery, conn))
                                {
                                    ratingCmd.Parameters.AddWithValue("@ProjectID", ActiveProjectId);
                                    ratingCmd.Parameters.AddWithValue("@RaterUserID", CurrentUserId);
                                    existingRatings = Convert.ToInt32(ratingCmd.ExecuteScalar());
                                }

                                // Only show rating modal if completed AND the current user hasn't rated yet
                                if (ActiveProjectId > 0 && existingRatings == 0 && projectStatus.Equals("Completed", StringComparison.OrdinalIgnoreCase))
                                {
                                    pnlRatingModal.Visible = true;
                                }
                                else
                                {
                                    pnlRatingModal.Visible = false;
                                }
                            }
                            else if (empAccountStatus.Equals("Deactivated", StringComparison.OrdinalIgnoreCase) ||
                                     empAccountStatus.Equals("Deleted", StringComparison.OrdinalIgnoreCase) ||
                                     empAccountStatus.Equals("Inactive", StringComparison.OrdinalIgnoreCase))
                            {
                                isChatEndedOrDeactivated = true;
                                lockReasonMessage = "The profile has been deactivated";
                            }
                        }
                        else
                        {
                            ActiveProjectId = 0;
                        }
                    }
                }
            }

            // Apply Chat Locking UI Rules (Preserving DB History)
            if (isChatEndedOrDeactivated)
            {
                btnSend.Enabled = false;
                fileUploadControl.Enabled = false;
                txtMessage.Enabled = false;
                txtMessage.Attributes["placeholder"] = "Chat has ended. Messages are read-only.";

                ShowStatus(lockReasonMessage);
            }
            else
            {
                btnSend.Enabled = true;
                fileUploadControl.Enabled = true;
                txtMessage.Enabled = true;
                txtMessage.Attributes["placeholder"] = "Type your message...";
            }

            // Mark unread messages as Read without deleting any table rows
            DatabaseHelper.MarkMessagesAsRead(CurrentUserId, otherUserId, ActiveProjectId > 0 ? (int?)ActiveProjectId : null);

            LoadChatMessages();
        }
        protected void btnSend_Click(object sender, EventArgs e)
        {
            if (SelectedOtherUserId <= 0 || (string.IsNullOrWhiteSpace(txtMessage.Text) && !fileUploadControl.HasFile)) return;

            string savedAttachmentUrl = null;

            // Handle file attachment upload
            if (fileUploadControl.HasFile)
            {
                try
                {
                    string folderPath = Server.MapPath("~/Uploads/");
                    if (!Directory.Exists(folderPath))
                    {
                        Directory.CreateDirectory(folderPath);
                    }

                    string fileExt = Path.GetExtension(fileUploadControl.FileName);
                    string fileName = Guid.NewGuid().ToString("N") + fileExt;
                    string fullPath = Path.Combine(folderPath, fileName);

                    fileUploadControl.SaveAs(fullPath);
                    savedAttachmentUrl = "~/Uploads/" + fileName;
                }
                catch (Exception ex)
                {
                    ShowStatus("Error uploading file: " + ex.Message);
                    return;
                }
            }

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    INSERT INTO dbo.Message (senderID, receiverID, projectID, content, attachmentUrl, timeStamp, status)
                    VALUES (@SenderID, @ReceiverID, @ProjectID, @Content, @AttachmentUrl, GETDATE(), 'Sent')";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@SenderID", CurrentUserId);
                    cmd.Parameters.AddWithValue("@ReceiverID", SelectedOtherUserId);
                    cmd.Parameters.AddWithValue("@ProjectID", ActiveProjectId > 0 ? (object)ActiveProjectId : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Content", txtMessage.Text.Trim());
                    cmd.Parameters.AddWithValue("@AttachmentUrl", string.IsNullOrEmpty(savedAttachmentUrl) ? (object)DBNull.Value : savedAttachmentUrl);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            string senderName = Session["FirstName"] != null ? Session["FirstName"].ToString() : "A user";
            NotificationHelper.CreateNotification(SelectedOtherUserId, "Message", $"{senderName} sent you a message.");

            txtMessage.Text = "";
            lblAttachedFileName.Text = "";
            ShowStatus("Message sent successfully.");

            LoadChatMessages();
            BindApprovedChatUsers("");
        }

        private void LoadChatMessages()
        {
            if (SelectedOtherUserId <= 0)
            {
                rptMessages.DataSource = null;
                rptMessages.DataBind();
                return;
            }

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    SELECT 
                        messageID, 
                        senderID, 
                        receiverID, 
                        content, 
                        attachmentUrl, 
                        status, 
                        timeStamp
                    FROM dbo.Message
                    WHERE (senderID = @CurrentUserID AND receiverID = @OtherUserID)
                       OR (senderID = @OtherUserID AND receiverID = @CurrentUserID)
                    ORDER BY timeStamp ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CurrentUserID", CurrentUserId);
                    cmd.Parameters.AddWithValue("@OtherUserID", SelectedOtherUserId);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        rptMessages.DataSource = dt;
                        rptMessages.DataBind();
                    }
                }
            }
        }

        protected void btnSearchUser_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtSearch.Text))
            {
                pnlSearchResults.Visible = false;
                return;
            }

            DataTable dtUsers = DatabaseHelper.SearchRegisteredUsers(txtSearch.Text.Trim(), CurrentUserId);

            pnlSearchResults.Visible = true;

            if (dtUsers != null && dtUsers.Rows.Count > 0)
            {
                rptSearchResults.DataSource = dtUsers;
                rptSearchResults.DataBind();
                lblNoUsersFound.Visible = false;
            }
            else
            {
                rptSearchResults.DataSource = null;
                rptSearchResults.DataBind();
                lblNoUsersFound.Visible = true;
            }
        }

        protected void rptSearchResults_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "StartChatWithUser")
            {
                int targetUserId = Convert.ToInt32(e.CommandArgument);

                pnlSearchResults.Visible = false;
                txtSearch.Text = "";

                SelectUserById(targetUserId);
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

        /// <summary>
        /// Closes the floating conversation popup and returns to the Messages dashboard,
        /// keeping the user on the Messages page.
        /// </summary>
        protected void btnCloseChat_Click(object sender, EventArgs e)
        {
            ChatOpen = false;
            SelectedOtherUserId = 0;
            pnlRatingModal.Visible = false;
            pnlUserDetailsModal.Visible = false;
            // Refresh the contact list so the previously-selected row is no longer highlighted.
            BindApprovedChatUsers("");
        }

        /// <summary>
        /// Returns true if the stored attachment actually exists on disk for the running app.
        /// Used by the markup to avoid rendering dead links that 404.
        /// </summary>
        public bool AttachmentExists(object attachmentUrl)
        {
            if (attachmentUrl == null || attachmentUrl == DBNull.Value) return false;

            string url = attachmentUrl.ToString();
            if (string.IsNullOrWhiteSpace(url)) return false;

            try
            {
                string physicalPath = Server.MapPath(url);
                return !string.IsNullOrEmpty(physicalPath) && File.Exists(physicalPath);
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Resolves a stored attachment url (e.g. "~/Uploads/x.pdf") to a browser url.
        /// </summary>
        public string ResolveAttachmentUrl(object attachmentUrl)
        {
            if (attachmentUrl == null || attachmentUrl == DBNull.Value) return "#";
            string url = attachmentUrl.ToString();
            if (string.IsNullOrWhiteSpace(url)) return "#";
            return ResolveUrl(url);
        }
    }
}
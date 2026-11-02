using System;
using System.Collections.Generic;
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
                // Heartbeat: update current user's last seen timestamp.
                DatabaseHelper.UpdateUserLastSeen(CurrentUserId);

                // Opening Messages delivers any still-'Sent' messages to the current user.
                DatabaseHelper.MarkMessagesAsDelivered(CurrentUserId);

                BindApprovedChatUsers("");

                string queryUserId = Request.QueryString["userId"];
                string userFromQuery = Request.QueryString["user"];

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
                    ChatOpen = false;
                }
            }
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            pnlWelcome.Visible = !ChatOpen;
            pnlChatPopup.Visible = ChatOpen;

            workspacePanel.Attributes["class"] = ChatOpen ? "fh-msg-root chat-open" : "fh-msg-root";

            if (ChatOpen)
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

            if (ChatOpen)
            {
                ScriptManager.RegisterStartupScript(
                    this, GetType(), "scrollPopup",
                    "if (window.scrollPopupToBottom) { scrollPopupToBottom(); }", true);
            }
        }

        // ============================================================
        // PROJECT DETAILS / STATUS PANEL
        // ============================================================

        private void BindProjectDetails()
        {
            bool active = ChatIsActive;

            if (ActiveProjectId > 0)
            {
                DataRow project = DatabaseHelper.GetProjectById(ActiveProjectId);
                if (project != null)
                {
                    string title = Convert.ToString(project["title"]);
                    string status = Convert.ToString(project["projectStatus"]);

                    lblProjectBarTitle.Text = Server.HtmlEncode(title);
                    lblProjectBarStatus.Text = Server.HtmlEncode(status);
                    lblDetailsProjectTitle.Text = Server.HtmlEncode(title);
                    lblDetailsProjectStatus.Text = Server.HtmlEncode(status);

                    // "View Project" is role-aware: employers go to My Projects, freelancers
                    // go to View Progress. The right-panel "View project details" link keeps
                    // pointing at the full project page.
                    string role = Session["UserType"] as string ?? "";
                    string viewProjectUrl = role.Equals("Employer", StringComparison.OrdinalIgnoreCase)
                        ? ResolveUrl("~/MyProjects.aspx")
                        : ResolveUrl("~/ViewProgress.aspx");
                    lnkViewProject.NavigateUrl = viewProjectUrl;
                    lnkViewProject.Visible = true;

                    // Project-status dot reflects the PROJECT status (distinct from chat status).
                    bool projActive = !status.Equals("Completed", StringComparison.OrdinalIgnoreCase) &&
                                      !status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase);
                    projBarDot.Attributes["class"] = projActive ? "fh-dot-green" : "fh-dot-grey";
                    detailsStatusDot.Attributes["class"] = projActive ? "fh-dot-green" : "fh-dot-grey";
                }
                else
                {
                    SetNoProjectLabels();
                }
            }
            else
            {
                SetNoProjectLabels();
            }

            // Conversation status card (distinct from project status).
            pnlStatusActive.Visible = active;
            pnlStatusEnded.Visible = !active;

            LoadSharedFilesForDetailsPanel();
        }

        private void SetNoProjectLabels()
        {
            lblProjectBarTitle.Text = "No active project";
            lblProjectBarStatus.Text = "&#8212;";
            lblDetailsProjectTitle.Text = "No active project";
            lblDetailsProjectStatus.Text = "&#8212;";
            lnkViewProject.Visible = false;
            projBarDot.Attributes["class"] = "fh-dot-grey";
            detailsStatusDot.Attributes["class"] = "fh-dot-grey";
        }

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

        // ============================================================
        // STATE
        // ============================================================

        public int CurrentUserId
        {
            get { return Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0; }
        }

        public int SelectedOtherUserId
        {
            get { return Session["SelectedOtherUserId"] != null ? Convert.ToInt32(Session["SelectedOtherUserId"]) : 0; }
            set { Session["SelectedOtherUserId"] = value; }
        }

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
        /// Whether the OPEN conversation is currently active (messaging allowed). Set during
        /// SelectUserById from the authoritative derived availability; defaults to active.
        /// </summary>
        private bool ChatIsActive
        {
            get { return ViewState["ChatIsActive"] == null || (bool)ViewState["ChatIsActive"]; }
            set { ViewState["ChatIsActive"] = value; }
        }

        /// <summary>
        /// The active conversation-list filter: All, Unread, Ended, Clients, or Freelancers.
        /// </summary>
        private string ContactFilter
        {
            get { return ViewState["ContactFilter"] as string ?? "All"; }
            set { ViewState["ContactFilter"] = value; }
        }

        // ============================================================
        // CONVERSATION LIST
        // ============================================================

        private void BindApprovedChatUsers(string searchText)
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                // One row PER CONTACT (other user). A freelancer and employer who have worked
                // on several projects share ONE conversation, so completed-then-new projects
                // reuse the same contact row instead of duplicating it. The IsActive column is
                // derived authoritatively: active = any Approved proposal between the two users
                // whose project is NOT Completed/Cancelled.
                string query = @"
                    SELECT
                        u.userID AS UserID,
                        u.userType AS UserType,
                        (u.firstName + ' ' + u.lastName) AS Name,
                        (LEFT(u.firstName, 1) + LEFT(u.lastName, 1)) AS Initials,
                        ISNULL((SELECT TOP 1 content FROM dbo.Message WHERE (senderID = u.userID AND receiverID = @CurrentUserID) OR (senderID = @CurrentUserID AND receiverID = u.userID) ORDER BY timeStamp DESC), 'No messages yet') AS LastMessage,
                        ISNULL((SELECT TOP 1 FORMAT(DATEADD(HOUR, 2, timeStamp), 'hh:mm tt') FROM dbo.Message WHERE (senderID = u.userID AND receiverID = @CurrentUserID) OR (senderID = @CurrentUserID AND receiverID = u.userID) ORDER BY timeStamp DESC), '') AS LastTime,
                        (SELECT TOP 1 timeStamp FROM dbo.Message WHERE (senderID = u.userID AND receiverID = @CurrentUserID) OR (senderID = @CurrentUserID AND receiverID = u.userID) ORDER BY timeStamp DESC) AS LastTimeSort,
                        (SELECT COUNT(*) FROM dbo.Message WHERE senderID = u.userID AND receiverID = @CurrentUserID AND status <> 'Read') AS UnreadCount,
                        CAST(CASE WHEN EXISTS (
                                SELECT 1 FROM dbo.Proposal prop2
                                INNER JOIN dbo.Project p2 ON prop2.projectID = p2.projectID
                                INNER JOIN dbo.Employer e2 ON p2.employerID = e2.employerID
                                INNER JOIN dbo.Freelancer f2 ON prop2.freelancerID = f2.freelancerID
                                WHERE prop2.status = 'Approved'
                                  AND p2.projectStatus NOT IN ('Completed','Cancelled')
                                  AND ((e2.userID = @CurrentUserID AND f2.userID = u.userID) OR (f2.userID = @CurrentUserID AND e2.userID = u.userID))
                            ) THEN 1 ELSE 0 END AS BIT) AS IsActive
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

                // Role filters: Clients = Employers; Freelancers = Freelancers.
                if (ContactFilter == "Clients")
                {
                    query += " AND u.userType = 'Employer'";
                }
                else if (ContactFilter == "Freelancers")
                {
                    query += " AND u.userType = 'Freelancer'";
                }

                query += @"
                    GROUP BY u.userID, u.userType, u.firstName, u.lastName";

                // Unread filter applies after grouping.
                if (ContactFilter == "Unread")
                {
                    query += @"
                    HAVING (SELECT COUNT(*) FROM dbo.Message WHERE senderID = u.userID AND receiverID = @CurrentUserID AND status <> 'Read') > 0";
                }
                else if (ContactFilter == "Ended")
                {
                    // Ended = NO active shared project remains between the two users.
                    query += @"
                    HAVING NOT EXISTS (
                        SELECT 1 FROM dbo.Proposal prop3
                        INNER JOIN dbo.Project p3 ON prop3.projectID = p3.projectID
                        INNER JOIN dbo.Employer e3 ON p3.employerID = e3.employerID
                        INNER JOIN dbo.Freelancer f3 ON prop3.freelancerID = f3.freelancerID
                        WHERE prop3.status = 'Approved'
                          AND p3.projectStatus NOT IN ('Completed','Cancelled')
                          AND ((e3.userID = @CurrentUserID AND f3.userID = u.userID) OR (f3.userID = @CurrentUserID AND e3.userID = u.userID)))";
                }

                // Also surface the FreeHub Support (admin) conversation under All/Unread.
                bool includeAdmin = (ContactFilter == "All" || ContactFilter == "Unread");
                if (includeAdmin)
                {
                    string adminRow = @"
                    UNION
                    SELECT
                        u.userID AS UserID,
                        u.userType AS UserType,
                        (u.firstName + ' ' + u.lastName) AS Name,
                        (LEFT(u.firstName, 1) + LEFT(u.lastName, 1)) AS Initials,
                        ISNULL((SELECT TOP 1 content FROM dbo.Message WHERE (senderID = u.userID AND receiverID = @CurrentUserID) OR (senderID = @CurrentUserID AND receiverID = u.userID) ORDER BY timeStamp DESC), '') AS LastMessage,
                        ISNULL((SELECT TOP 1 FORMAT(DATEADD(HOUR, 2, timeStamp), 'hh:mm tt') FROM dbo.Message WHERE (senderID = u.userID AND receiverID = @CurrentUserID) OR (senderID = @CurrentUserID AND receiverID = u.userID) ORDER BY timeStamp DESC), '') AS LastTime,
                        (SELECT TOP 1 timeStamp FROM dbo.Message WHERE (senderID = u.userID AND receiverID = @CurrentUserID) OR (senderID = @CurrentUserID AND receiverID = u.userID) ORDER BY timeStamp DESC) AS LastTimeSort,
                        (SELECT COUNT(*) FROM dbo.Message WHERE senderID = u.userID AND receiverID = @CurrentUserID AND status <> 'Read') AS UnreadCount,
                        CAST(1 AS BIT) AS IsActive
                    FROM dbo.[User] u
                    WHERE u.userType = 'Admin'
                      AND u.userID <> @CurrentUserID
                      AND EXISTS (SELECT 1 FROM dbo.Message m WHERE (m.senderID = u.userID AND m.receiverID = @CurrentUserID) OR (m.senderID = @CurrentUserID AND m.receiverID = u.userID))";
                    if (!string.IsNullOrWhiteSpace(searchText))
                    {
                        adminRow += " AND (u.firstName + ' ' + u.lastName LIKE @Search)";
                    }
                    if (ContactFilter == "Unread")
                    {
                        adminRow += " AND (SELECT COUNT(*) FROM dbo.Message WHERE senderID = u.userID AND receiverID = @CurrentUserID AND status <> 'Read') > 0";
                    }
                    query += adminRow;
                }

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

            UpdateUnreadBadge();
            SetActiveFilterTab();
        }

        /// <summary>
        /// Handles the All / Unread / Ended segmented tabs (and the hidden role chips).
        /// Searching/filtering must NOT clear an already-open conversation, so we only
        /// rebind the list — the selected conversation and its messages stay in place.
        /// </summary>
        protected void Filter_Click(object sender, EventArgs e)
        {
            var btn = sender as System.Web.UI.WebControls.LinkButton;
            if (btn != null)
            {
                ContactFilter = btn.CommandArgument;
            }
            BindApprovedChatUsers(txtSearch.Text.Trim());

            // Preserve the open conversation (and its message thread) across a filter change.
            if (ChatOpen && SelectedOtherUserId > 0)
            {
                LoadChatMessages();
            }
        }

        /// <summary>Contact-role dropdown (All contacts / Clients / Freelancers).</summary>
        protected void ddlContactFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            string val = ddlContactFilter.SelectedValue;
            ContactFilter = (val == "Clients" || val == "Freelancers") ? val : "All";

            // Keep the All/Unread/Ended segment visually consistent.
            BindApprovedChatUsers(txtSearch.Text.Trim());

            if (ChatOpen && SelectedOtherUserId > 0)
            {
                LoadChatMessages();
            }
        }

        /// <summary>
        /// Shows the real total unread-message count next to the Messages heading. Counted
        /// from live data (all messages to the current user not yet Read), independent of the
        /// active filter. Hidden when zero.
        /// </summary>
        private void UpdateUnreadBadge()
        {
            int unread = 0;
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string q = "SELECT COUNT(*) FROM dbo.Message WHERE receiverID = @Me AND status <> 'Read'";
                using (SqlCommand cmd = new SqlCommand(q, conn))
                {
                    cmd.Parameters.AddWithValue("@Me", CurrentUserId);
                    conn.Open();
                    unread = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }

            if (unread > 0)
            {
                litUnreadTotal.Text = unread > 99 ? "99+" : unread.ToString();
                pnlUnreadTotal.Visible = true;
            }
            else
            {
                pnlUnreadTotal.Visible = false;
            }
        }

        private void SetActiveFilterTab()
        {
            btnFilterAll.CssClass = "fh-filter" + (ContactFilter == "All" ? " active" : "");
            btnFilterUnread.CssClass = "fh-filter" + (ContactFilter == "Unread" ? " active" : "");
            btnFilterEnded.CssClass = "fh-filter" + (ContactFilter == "Ended" ? " active" : "");
        }

        // ============================================================
        // CONTACT INFO MODAL
        // ============================================================

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
            DataRow user = DatabaseHelper.GetUserById(targetUserId);
            if (user != null)
            {
                lblDetailName.Text = Server.HtmlEncode(Convert.ToString(user["firstName"]) + " " + Convert.ToString(user["lastName"]));
                lblDetailEmail.Text = Server.HtmlEncode(Convert.ToString(user["email"]));
                lblDetailContact.Text = user["contactNumber"] != DBNull.Value ? Server.HtmlEncode(Convert.ToString(user["contactNumber"])) : "N/A";
                lblDetailUserType.Text = Server.HtmlEncode(Convert.ToString(user["userType"]));

                decimal rating = user["ratingScore"] != DBNull.Value ? Convert.ToDecimal(user["ratingScore"]) : 0.0m;
                lblDetailRating.Text = rating.ToString("F1");
            }

            LoadSharedFilesForDetailsPanel();
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

        // ============================================================
        // CONVERSATION SELECTION
        // ============================================================

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
            ChatOpen = true;

            // Header identity + partner last-seen (existing, authoritative — no invented data).
            DataRow user = DatabaseHelper.GetUserById(otherUserId);
            if (user != null)
            {
                string firstName = Convert.ToString(user["firstName"]);
                string lastName = Convert.ToString(user["lastName"]);
                lblChatName.Text = Server.HtmlEncode(firstName + " " + lastName);
                lblChatInitials.Text = Server.HtmlEncode(
                    (!string.IsNullOrEmpty(firstName) ? firstName[0].ToString() : "") +
                    (!string.IsNullOrEmpty(lastName) ? lastName[0].ToString() : ""));

                string accountStatus = Convert.ToString(user["accountStatus"]);
                if (accountStatus == "Inactive" || accountStatus == "Deleted" || accountStatus == "Deactivated")
                {
                    lblPartnerStatus.Text = "Account deactivated";
                    statusDot.Attributes["class"] = "status-dot offline";
                }
                else
                {
                    string onlineStatus = DatabaseHelper.GetUserOnlineStatus(otherUserId);
                    lblPartnerStatus.Text = Server.HtmlEncode(onlineStatus);
                    bool isOnline = onlineStatus.IndexOf("Online", StringComparison.OrdinalIgnoreCase) >= 0;
                    statusDot.Attributes["class"] = isOnline ? "status-dot" : "status-dot offline";
                }
            }

            // Derive availability + governing project from authoritative records.
            ChatLifecycle.ChatAvailability avail = ChatLifecycle.GetAvailability(_connStr, CurrentUserId, otherUserId);
            ActiveProjectId = avail.SelectedProjectId;
            ChatIsActive = avail.IsActive;

            // Project selector: show only when more than one approved project is shared.
            BindProjectSelector(otherUserId);

            ApplyAvailabilityUi(avail);

            // Rating modal: only when the governing project is Completed and not yet rated.
            MaybeShowRatingModal(avail);

            // Mark ALL unread messages from this contact as Read (one continuous chat per contact).
            DatabaseHelper.MarkMessagesAsRead(CurrentUserId, otherUserId, null);

            LoadChatMessages();

            // Rebind the list so this contact's unread badge clears immediately.
            BindApprovedChatUsers(txtSearch != null ? txtSearch.Text.Trim() : "");
        }

        /// <summary>
        /// Enables/disables the composer and shows the ended-notice based on derived availability.
        /// </summary>
        private void ApplyAvailabilityUi(ChatLifecycle.ChatAvailability avail)
        {
            bool active = avail.IsActive;

            pnlComposer.Visible = active;
            pnlEndedNotice.Visible = !active;

            // Ended-notice reason reflects WHY the chat ended (cancelled vs completed vs other).
            if (!active)
            {
                litEndedReason.Text = Server.HtmlEncode(
                    !string.IsNullOrEmpty(avail.ReasonMessage) ? avail.ReasonMessage : "This conversation has ended.");
            }

            btnSend.Enabled = active;
            fileUploadControl.Enabled = active;
            txtMessage.Enabled = active;
            txtMessage.Attributes["placeholder"] = active ? "Write a message..." : "Messaging is unavailable in ended chats.";
        }

        private void MaybeShowRatingModal(ChatLifecycle.ChatAvailability avail)
        {
            pnlRatingModal.Visible = false;
            if (ActiveProjectId <= 0) return;
            if (!string.Equals(avail.ProjectStatus, "Completed", StringComparison.OrdinalIgnoreCase)) return;

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string q = "SELECT COUNT(*) FROM dbo.Rating WHERE projectID = @ProjectID AND raterUserID = @RaterUserID";
                using (SqlCommand cmd = new SqlCommand(q, conn))
                {
                    cmd.Parameters.AddWithValue("@ProjectID", ActiveProjectId);
                    cmd.Parameters.AddWithValue("@RaterUserID", CurrentUserId);
                    conn.Open();
                    int existing = Convert.ToInt32(cmd.ExecuteScalar());
                    if (existing == 0) pnlRatingModal.Visible = true;
                }
            }
        }

        /// <summary>
        /// Populates the compact project selector when the two users share more than one
        /// approved project. Picking one updates the governing project context (View Project,
        /// details panel). History/attachments stay with their original projects.
        /// </summary>
        private void BindProjectSelector(int otherUserId)
        {
            List<ChatLifecycle.SharedProject> projects = ChatLifecycle.GetSharedProjects(_connStr, CurrentUserId, otherUserId);

            if (projects.Count > 1)
            {
                ddlProjectSelect.Items.Clear();
                foreach (var p in projects)
                {
                    string label = p.Title + (p.IsActive ? "" : " (ended)");
                    ddlProjectSelect.Items.Add(new ListItem(label, p.ProjectId.ToString()));
                }

                // Keep the currently governing project selected.
                if (ActiveProjectId > 0)
                {
                    ListItem sel = ddlProjectSelect.Items.FindByValue(ActiveProjectId.ToString());
                    if (sel != null)
                    {
                        ddlProjectSelect.ClearSelection();
                        sel.Selected = true;
                    }
                }
                ddlProjectSelect.Visible = true;
            }
            else
            {
                ddlProjectSelect.Items.Clear();
                ddlProjectSelect.Visible = false;
            }
        }

        /// <summary>
        /// Switches the governing project when several are active. Re-derives availability
        /// for the chosen project's status so the composer/ended-notice stay accurate.
        /// </summary>
        protected void ddlProjectSelect_SelectedIndexChanged(object sender, EventArgs e)
        {
            int projId;
            if (!int.TryParse(ddlProjectSelect.SelectedValue, out projId) || projId <= 0) return;

            ActiveProjectId = projId;

            // Re-derive availability from the chosen project's authoritative status.
            DataRow project = DatabaseHelper.GetProjectById(projId);
            bool projActive = false;
            if (project != null)
            {
                string status = Convert.ToString(project["projectStatus"]);
                projActive = !status.Equals("Completed", StringComparison.OrdinalIgnoreCase) &&
                             !status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase);
            }
            ChatIsActive = projActive;

            var avail = new ChatLifecycle.ChatAvailability
            {
                IsActive = projActive,
                SelectedProjectId = projId,
                ProjectStatus = project != null ? Convert.ToString(project["projectStatus"]) : ""
            };
            ApplyAvailabilityUi(avail);

            LoadChatMessages();
        }

        // ============================================================
        // SEND
        // ============================================================

        protected void btnSend_Click(object sender, EventArgs e)
        {
            if (SelectedOtherUserId <= 0) return;

            // SERVER-SIDE RECHECK: availability can change while the page is open (e.g. the
            // project completes in another tab). Never trust the client — re-derive here.
            bool allowed = IsAdminContact(SelectedOtherUserId) ||
                           ChatLifecycle.HasActiveSharedProject(_connStr, CurrentUserId, SelectedOtherUserId);

            if (!allowed)
            {
                // Reflect the ended state and reject the send/upload. The textbox keeps the
                // user's draft (we do NOT clear txtMessage) so nothing is lost.
                ChatIsActive = false;
                ApplyAvailabilityUi(new ChatLifecycle.ChatAvailability { IsActive = false, SelectedProjectId = ActiveProjectId });
                LoadChatMessages();
                BindApprovedChatUsers(txtSearch != null ? txtSearch.Text.Trim() : "");
                MessageHelper.Warning(this, "This conversation has ended because the project is completed. Your message history remains available.", "Messaging unavailable");
                return;
            }

            if (string.IsNullOrWhiteSpace(txtMessage.Text) && !fileUploadControl.HasFile) return;

            // Voice notes are no longer supported: reject audio uploads server-side (never
            // save them). Text and document/image attachments continue to work.
            if (fileUploadControl.HasFile && IsAudioFileName(fileUploadControl.FileName))
            {
                MessageHelper.Warning(this, "Voice notes are no longer supported. Please send a text message or a document/image.", "Not supported");
                return; // draft preserved
            }

            string savedAttachmentUrl = null;

            if (fileUploadControl.HasFile)
            {
                try
                {
                    string folderPath = Server.MapPath("~/Uploads/");
                    if (!Directory.Exists(folderPath))
                    {
                        Directory.CreateDirectory(folderPath);
                    }

                    string originalName = Path.GetFileName(fileUploadControl.FileName);
                    string safeOriginal = MakeSafeFileName(originalName);
                    string fileName = Guid.NewGuid().ToString("N") + "_" + safeOriginal;
                    string fullPath = Path.Combine(folderPath, fileName);

                    fileUploadControl.SaveAs(fullPath);
                    savedAttachmentUrl = "~/Uploads/" + fileName;
                }
                catch (Exception ex)
                {
                    // Draft preserved: do not clear txtMessage on a failed upload.
                    MessageHelper.Error(this, "Error uploading file: " + ex.Message);
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

            // Only clear the draft + attachment AFTER a successful send.
            txtMessage.Text = "";
            lblAttachedFileName.Text = "";

            LoadChatMessages();
            BindApprovedChatUsers(txtSearch != null ? txtSearch.Text.Trim() : "");
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
                        messageID, senderID, receiverID, content, attachmentUrl, status, timeStamp
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

        private bool IsAdminContact(int otherUserId)
        {
            DataRow u = DatabaseHelper.GetUserById(otherUserId);
            return u != null && string.Equals(Convert.ToString(u["userType"]), "Admin", StringComparison.OrdinalIgnoreCase);
        }

        // ============================================================
        // SEARCH (system user lookup)
        // ============================================================

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

        // ============================================================
        // RATING
        // ============================================================

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
            MessageHelper.Success(this, $"Rating submitted! Reputation score updated to {updatedScore:F1} / 5.0.", "Thank you");
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            pnlRatingModal.Visible = false;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindApprovedChatUsers(txtSearch.Text.Trim());
            if (ChatOpen && SelectedOtherUserId > 0) LoadChatMessages();
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            BindApprovedChatUsers(txtSearch.Text.Trim());
            // Searching must not clear an already-opened conversation.
            if (ChatOpen && SelectedOtherUserId > 0) LoadChatMessages();
        }

        /// <summary>Closes the conversation and returns to the Messages list.</summary>
        protected void btnCloseChat_Click(object sender, EventArgs e)
        {
            ChatOpen = false;
            SelectedOtherUserId = 0;
            pnlRatingModal.Visible = false;
            pnlUserDetailsModal.Visible = false;
            BindApprovedChatUsers("");
        }

        // ============================================================
        // ATTACHMENT HELPERS (used by markup)
        // ============================================================

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

        public string ResolveAttachmentUrl(object attachmentUrl)
        {
            if (attachmentUrl == null || attachmentUrl == DBNull.Value) return "#";
            string url = attachmentUrl.ToString();
            if (string.IsNullOrWhiteSpace(url)) return "#";
            return ResolveUrl(url);
        }

        public string OriginalFileName(object attachmentUrl)
        {
            if (attachmentUrl == null || attachmentUrl == DBNull.Value) return "";
            string stored = System.IO.Path.GetFileName(attachmentUrl.ToString());
            if (string.IsNullOrEmpty(stored)) return "";

            int underscore = stored.IndexOf('_');
            if (underscore == 32)
            {
                string rest = stored.Substring(underscore + 1);
                if (!string.IsNullOrEmpty(rest)) return rest;
            }
            return stored;
        }

        /// <summary>Lowercased file extension (no dot) of the stored attachment, or "".</summary>
        private string AttachmentExt(object attachmentUrl)
        {
            string name = OriginalFileName(attachmentUrl);
            string ext = System.IO.Path.GetExtension(name);
            return string.IsNullOrEmpty(ext) ? "" : ext.TrimStart('.').ToLowerInvariant();
        }

        /// <summary>True when the attachment is a renderable image (by extension).</summary>
        public bool IsImageAttachment(object attachmentUrl)
        {
            switch (AttachmentExt(attachmentUrl))
            {
                case "jpg": case "jpeg": case "png": case "gif": case "webp": case "bmp": case "svg":
                    return true;
                default:
                    return false;
            }
        }

        /// <summary>True when the attachment is a playable audio clip / voice note (by extension).</summary>
        public bool IsAudioAttachment(object attachmentUrl)
        {
            switch (AttachmentExt(attachmentUrl))
            {
                case "mp3": case "wav": case "webm": case "ogg": case "oga": case "m4a": case "aac":
                    return true;
                default:
                    return false;
            }
        }

        /// <summary>True when a raw uploaded filename is an audio/voice-note type (blocked).</summary>
        private bool IsAudioFileName(string fileName)
        {
            if (string.IsNullOrEmpty(fileName)) return false;
            string ext = System.IO.Path.GetExtension(fileName);
            if (string.IsNullOrEmpty(ext)) return false;
            switch (ext.TrimStart('.').ToLowerInvariant())
            {
                case "mp3": case "wav": case "webm": case "ogg": case "oga": case "m4a": case "aac":
                    return true;
                default:
                    return false;
            }
        }

        /// <summary>True when the attachment is neither image nor audio (a document card).</summary>
        public bool IsDocAttachment(object attachmentUrl)
        {
            return !IsImageAttachment(attachmentUrl) && !IsAudioAttachment(attachmentUrl);
        }

        /// <summary>Short uppercase extension label for the file icon (e.g. "PDF").</summary>
        public string FileExtLabel(object attachmentUrl)
        {
            string name = OriginalFileName(attachmentUrl);
            string ext = System.IO.Path.GetExtension(name);
            if (string.IsNullOrEmpty(ext)) return "\U0001F4C4"; // generic doc glyph
            ext = ext.TrimStart('.').ToUpperInvariant();
            if (ext.Length > 4) ext = ext.Substring(0, 4);
            return ext;
        }

        /// <summary>
        /// File type + size when available (never fabricated). If the file is missing on
        /// disk we only report the type; size is shown only for files that actually exist.
        /// </summary>
        public string FileMeta(object attachmentUrl)
        {
            string name = OriginalFileName(attachmentUrl);
            string ext = System.IO.Path.GetExtension(name);
            string type = string.IsNullOrEmpty(ext) ? "File" : ext.TrimStart('.').ToUpperInvariant();

            if (AttachmentExists(attachmentUrl))
            {
                try
                {
                    string physicalPath = Server.MapPath(attachmentUrl.ToString());
                    var fi = new FileInfo(physicalPath);
                    return type + " \u00B7 " + FormatSize(fi.Length);
                }
                catch
                {
                    return type;
                }
            }
            return type;
        }

        private static string FormatSize(long bytes)
        {
            if (bytes < 1024) return bytes + " B";
            double kb = bytes / 1024.0;
            if (kb < 1024) return kb.ToString("0.#") + " KB";
            double mb = kb / 1024.0;
            return mb.ToString("0.#") + " MB";
        }

        // ============================================================
        // SYSTEM / LIFECYCLE MESSAGE HELPERS (used by markup)
        // ============================================================

        public bool IsSystemRow(object content)
        {
            return ChatLifecycle.IsSystemMessage(content);
        }

        public string SystemText(object content)
        {
            return ChatLifecycle.StripSystem(content);
        }

        /// <summary>
        /// Conversation-list preview: system rows show their stripped text; "No messages yet"
        /// passes through unchanged.
        /// </summary>
        public string ConversationPreview(object content)
        {
            if (content == null || content == DBNull.Value) return "";
            if (ChatLifecycle.IsSystemMessage(content)) return ChatLifecycle.StripSystem(content);
            return Convert.ToString(content);
        }

        private static string MakeSafeFileName(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "file";
            foreach (char c in System.IO.Path.GetInvalidFileNameChars())
            {
                name = name.Replace(c, '-');
            }
            name = name.Replace('_', '-');
            return string.IsNullOrWhiteSpace(name) ? "file" : name;
        }
    }
}

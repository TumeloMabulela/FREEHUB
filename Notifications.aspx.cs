using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class Notifications : System.Web.UI.Page
    {
        private readonly string _connStr = ConfigurationManager.ConnectionStrings["FreeHubDB"]?.ConnectionString;

        // Exposed so the details modal markup can set the icon colour class.
        protected string DetailIconClass = "system";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;

            if (CurrentUserId <= 0)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                CurrentFilter = "All";
                BindNotifications();
            }
        }

        private int CurrentUserId
        {
            get { return Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0; }
        }

        /// <summary>Active category tab: All, Unread, Projects, Messages, System, Payments, Archived.</summary>
        private string CurrentFilter
        {
            get { return Session["NotificationFilter"] as string ?? "All"; }
            set { Session["NotificationFilter"] = value; }
        }

        /// <summary>
        /// The currently expanded notification (0 = none). The card markup reads this to show
        /// the full content and the inline action buttons inside the selected notification.
        /// </summary>
        public int SelectedNotificationId
        {
            get { return ViewState["SelectedNotificationId"] != null ? (int)ViewState["SelectedNotificationId"] : 0; }
            set { ViewState["SelectedNotificationId"] = value; }
        }

        // ============================================================
        // BINDING
        // ============================================================
        private void BindNotifications()
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                var sb = new StringBuilder(@"
                    SELECT notificationID AS Id, type AS Type, content AS Content, status AS Status,
                           FORMAT(DATEADD(HOUR, 2, notificationTimestamp), 'dd MMM yyyy, hh:mm tt') AS Time
                    FROM dbo.Notification
                    WHERE userID = @UserID");

                // Category tab scoping.
                switch (CurrentFilter)
                {
                    case "Unread": sb.Append(" AND status = 'Unread'"); break;
                    case "Archived": sb.Append(" AND status = 'Archived'"); break;
                    case "Projects": sb.Append(" AND status <> 'Archived' AND type IN ('Project','Proposal')"); break;
                    case "Messages": sb.Append(" AND status <> 'Archived' AND type = 'Message'"); break;
                    case "Payments": sb.Append(" AND status <> 'Archived' AND type = 'Payment'"); break;
                    case "System": sb.Append(" AND status <> 'Archived' AND type NOT IN ('Project','Proposal','Message','Payment')"); break;
                    default: sb.Append(" AND status <> 'Archived'"); break; // All
                }

                // Type dropdown filter.
                string typeFilter = ddlType != null ? ddlType.SelectedValue : "All";
                if (typeFilter == "System")
                {
                    sb.Append(" AND type NOT IN ('Project','Proposal','Message','Payment')");
                }
                else if (!string.IsNullOrEmpty(typeFilter) && typeFilter != "All")
                {
                    sb.Append(" AND type = @TypeFilter");
                }

                // Time dropdown filter.
                int days = 0;
                if (ddlTime != null) int.TryParse(ddlTime.SelectedValue, out days);
                if (days > 0)
                {
                    sb.Append(" AND notificationTimestamp >= DATEADD(DAY, -@Days, GETDATE())");
                }

                // Search (case-insensitive on content).
                string search = txtSearch != null ? txtSearch.Text.Trim() : "";
                if (!string.IsNullOrEmpty(search))
                {
                    sb.Append(" AND LOWER(content) LIKE @Search");
                }

                sb.Append(" ORDER BY notificationTimestamp DESC");

                using (SqlCommand cmd = new SqlCommand(sb.ToString(), conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                    if (typeFilter != "All" && typeFilter != "System")
                        cmd.Parameters.AddWithValue("@TypeFilter", typeFilter);
                    if (days > 0)
                        cmd.Parameters.AddWithValue("@Days", days);
                    if (!string.IsNullOrEmpty(search))
                        cmd.Parameters.AddWithValue("@Search", "%" + search.ToLower() + "%");

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            // Shape display columns (title/description/icon/category) from type+content.
            dt.Columns.Add("Title", typeof(string));
            dt.Columns.Add("Description", typeof(string));
            dt.Columns.Add("Icon", typeof(string));
            dt.Columns.Add("IconClass", typeof(string));
            dt.Columns.Add("Category", typeof(string));

            foreach (DataRow row in dt.Rows)
            {
                string type = row["Type"].ToString();
                row["Title"] = TitleForType(type);
                row["Description"] = row["Content"].ToString();
                row["Icon"] = IconForType(type);
                row["IconClass"] = IconClassForType(type);
                row["Category"] = CategoryForType(type);
            }

            rptNotifications.DataSource = dt;
            rptNotifications.DataBind();
            lblNoNotifications.Visible = (dt.Rows.Count == 0);

            UpdateTabsAndCounts();
            UpdateMarkAllButton();
        }

        // ============================================================
        // TYPE → DISPLAY HELPERS
        // ============================================================
        private string TitleForType(string type)
        {
            switch (type)
            {
                case "Message": return "New Message";
                case "Project": return "Project Update";
                case "Proposal": return "Proposal Update";
                case "Payment": return "Payment Update";
                case "Welcome": return "Welcome to FreeHUB";
                default: return "System Notification";
            }
        }

        private string IconForType(string type)
        {
            switch (type)
            {
                case "Message": return "💬";
                case "Project": return "📁";
                case "Proposal": return "📝";
                case "Payment": return "💳";
                default: return "⚙";
            }
        }

        // Maps to the CSS colour class used by both the icon badge and the category badge.
        private string IconClassForType(string type)
        {
            switch (type)
            {
                case "Message": return "message";
                case "Project": return "project";
                case "Proposal": return "proposal";
                case "Payment": return "payment";
                default: return "system";
            }
        }

        private string CategoryForType(string type)
        {
            switch (type)
            {
                case "Message": return "Message";
                case "Project": return "Project";
                case "Proposal": return "Proposal";
                case "Payment": return "Payment";
                case "Welcome": return "Welcome";
                default: return "System";
            }
        }

        // ============================================================
        // TAB COUNTS + STYLES
        // ============================================================
        private void UpdateTabsAndCounts()
        {
            int all = 0, unread = 0, projects = 0, messages = 0, system = 0, payments = 0, archived = 0;

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string q = @"
                    SELECT
                        ISNULL(SUM(CASE WHEN status <> 'Archived' THEN 1 ELSE 0 END),0) AS AllC,
                        ISNULL(SUM(CASE WHEN status = 'Unread' THEN 1 ELSE 0 END),0) AS UnreadC,
                        ISNULL(SUM(CASE WHEN status <> 'Archived' AND type IN ('Project','Proposal') THEN 1 ELSE 0 END),0) AS ProjC,
                        ISNULL(SUM(CASE WHEN status <> 'Archived' AND type = 'Message' THEN 1 ELSE 0 END),0) AS MsgC,
                        ISNULL(SUM(CASE WHEN status <> 'Archived' AND type NOT IN ('Project','Proposal','Message','Payment') THEN 1 ELSE 0 END),0) AS SysC,
                        ISNULL(SUM(CASE WHEN status <> 'Archived' AND type = 'Payment' THEN 1 ELSE 0 END),0) AS PayC,
                        ISNULL(SUM(CASE WHEN status = 'Archived' THEN 1 ELSE 0 END),0) AS ArchC
                    FROM dbo.Notification WHERE userID = @UserID";
                using (SqlCommand cmd = new SqlCommand(q, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            all = Convert.ToInt32(dr["AllC"]);
                            unread = Convert.ToInt32(dr["UnreadC"]);
                            projects = Convert.ToInt32(dr["ProjC"]);
                            messages = Convert.ToInt32(dr["MsgC"]);
                            system = Convert.ToInt32(dr["SysC"]);
                            payments = Convert.ToInt32(dr["PayC"]);
                            archived = Convert.ToInt32(dr["ArchC"]);
                        }
                    }
                }
            }

            btnAll.Text = "All" + Count(all);
            btnUnread.Text = "Unread" + Count(unread);
            btnProjects.Text = "Projects" + Count(projects);
            btnMessages.Text = "Messages" + Count(messages);
            btnSystem.Text = "System" + Count(system);
            btnPayments.Text = "Payments" + Count(payments);
            btnArchived.Text = "Archived" + Count(archived);

            btnAll.CssClass = Tab("All");
            btnUnread.CssClass = Tab("Unread");
            btnProjects.CssClass = Tab("Projects");
            btnMessages.CssClass = Tab("Messages");
            btnSystem.CssClass = Tab("System");
            btnPayments.CssClass = Tab("Payments");
            btnArchived.CssClass = Tab("Archived");
        }

        private string Count(int n) { return n > 0 ? string.Format(" ({0})", n) : ""; }
        private string Tab(string name) { return CurrentFilter == name ? "nx-tab active-tab" : "nx-tab"; }

        private void UpdateMarkAllButton()
        {
            int unread = 0;
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string q = "SELECT COUNT(*) FROM dbo.Notification WHERE userID = @UserID AND status = 'Unread'";
                using (SqlCommand cmd = new SqlCommand(q, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                    conn.Open();
                    unread = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            btnMarkAllRead.Enabled = unread > 0;
        }

        // ============================================================
        // FILTER / TAB EVENTS
        // ============================================================
        protected void Filters_Changed(object sender, EventArgs e) { BindNotifications(); }

        protected void btnAll_Click(object sender, EventArgs e) { CurrentFilter = "All"; BindNotifications(); }
        protected void btnUnread_Click(object sender, EventArgs e) { CurrentFilter = "Unread"; BindNotifications(); }
        protected void btnProjects_Click(object sender, EventArgs e) { CurrentFilter = "Projects"; BindNotifications(); }
        protected void btnMessages_Click(object sender, EventArgs e) { CurrentFilter = "Messages"; BindNotifications(); }
        protected void btnSystem_Click(object sender, EventArgs e) { CurrentFilter = "System"; BindNotifications(); }
        protected void btnPayments_Click(object sender, EventArgs e) { CurrentFilter = "Payments"; BindNotifications(); }
        protected void btnArchived_Click(object sender, EventArgs e) { CurrentFilter = "Archived"; BindNotifications(); }

        // ============================================================
        // MARK ALL AS READ
        // ============================================================
        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string q = "UPDATE dbo.Notification SET status = 'Read' WHERE userID = @UserID AND status = 'Unread'";
                using (SqlCommand cmd = new SqlCommand(q, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            ShowNotificationStatus("All notifications marked as read.");
            BindNotifications();
        }

        // ============================================================
        // CARD ACTIONS (click + 3-dot menu)
        // ============================================================
        protected void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int notificationId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out notificationId)) return;

            // Validate ownership server-side before any action.
            string ownerType = GetNotificationType(notificationId);
            if (ownerType == null) return; // not found or not owned by this user

            switch (e.CommandName)
            {
                case "SelectNotification":
                    // Clicking a notification expands it inline so you can read it in place and
                    // see the action buttons inside the card. Clicking it again collapses it.
                    if (SelectedNotificationId == notificationId)
                    {
                        SelectedNotificationId = 0; // collapse
                    }
                    else
                    {
                        SelectedNotificationId = notificationId; // expand
                        UpdateNotificationStatus(notificationId, "Read"); // reading it marks it read
                    }
                    BindNotifications();
                    break;

                case "ViewDetails":
                    // Explicit "View Details" opens the related page (chat/progress/wallet).
                    UpdateNotificationStatus(notificationId, "Read");
                    RouteToTarget(ownerType);
                    break;

                case "ToggleRead":
                    {
                        string status = GetNotificationStatus(notificationId);
                        string newStatus = status == "Read" ? "Unread" : "Read";
                        UpdateNotificationStatus(notificationId, newStatus);
                        ShowNotificationStatus(newStatus == "Read" ? "Notification marked as read." : "Notification marked as unread.");
                        BindNotifications();
                    }
                    break;

                case "ToggleArchive":
                    {
                        string status = GetNotificationStatus(notificationId);
                        if (status == "Archived")
                        {
                            UpdateNotificationStatus(notificationId, "Read");
                            ShowNotificationStatus("Notification unarchived.");
                        }
                        else
                        {
                            UpdateNotificationStatus(notificationId, "Archived");
                            ShowNotificationStatus("Notification archived.");
                        }
                        BindNotifications();
                    }
                    break;
            }
        }

        /// <summary>Routes to the correct destination for a notification type.</summary>
        private void RouteToTarget(string type)
        {
            switch (type)
            {
                case "Message":
                    Response.Redirect("StartChat.aspx");
                    break;
                case "Project":
                case "Proposal":
                    // Freelancers manage proposals/progress; employers manage their projects.
                    Response.Redirect("ViewProgress.aspx");
                    break;
                case "Payment":
                    Response.Redirect("Wallet.aspx");
                    break;
                default:
                    // System/Welcome: no dedicated page — show details inline.
                    int id = Session["SelectedNotificationId"] != null ? Convert.ToInt32(Session["SelectedNotificationId"]) : 0;
                    // Fall back to staying on the page (details modal not opened for a plain click).
                    break;
            }
        }

        // ============================================================
        // DETAILS MODAL
        // ============================================================
        private void LoadSelectedNotification(int notificationId)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    SELECT type, content,
                           FORMAT(DATEADD(HOUR, 2, notificationTimestamp), 'dd MMM yyyy, hh:mm tt') AS Time, status
                    FROM dbo.Notification
                    WHERE notificationID = @NotificationID AND userID = @UserID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@NotificationID", notificationId);
                    cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            string type = dr["type"].ToString();
                            string content = dr["content"].ToString();
                            string status = dr["status"].ToString();

                            pnlDetailsModal.Visible = true;
                            lblSelectedTitle.Text = TitleForType(type);
                            lblSelectedPreview.Text = content;
                            lblSelectedTime.Text = dr["Time"].ToString();
                            lblSelectedIcon.Text = IconForType(type);
                            lblReadStatus.Text = status;
                            DetailIconClass = IconClassForType(type);

                            btnToggleRead.Text = status == "Read" ? "Mark as Unread" : "Mark as Read";
                            btnToggleArchive.Text = status == "Archived" ? "Unarchive" : "Archive";

                            // "Open" routes to the target for actionable types.
                            btnOpenTarget.Visible = (type == "Message" || type == "Project" || type == "Proposal" || type == "Payment");
                        }
                    }
                }
            }
        }

        protected void btnCloseDetails_Click(object sender, EventArgs e)
        {
            pnlDetailsModal.Visible = false;
            BindNotifications();
        }

        protected void btnOpenTarget_Click(object sender, EventArgs e)
        {
            if (Session["SelectedNotificationId"] == null) return;
            int id = Convert.ToInt32(Session["SelectedNotificationId"]);
            string type = GetNotificationType(id);
            if (type == null) return;
            UpdateNotificationStatus(id, "Read");
            RouteToTarget(type);
        }

        protected void btnToggleRead_Click(object sender, EventArgs e)
        {
            if (Session["SelectedNotificationId"] == null) return;
            int id = Convert.ToInt32(Session["SelectedNotificationId"]);
            if (GetNotificationType(id) == null) return;

            string status = GetNotificationStatus(id);
            string newStatus = status == "Read" ? "Unread" : "Read";
            UpdateNotificationStatus(id, newStatus);
            ShowNotificationStatus(newStatus == "Read" ? "Notification marked as read." : "Notification marked as unread.");
            LoadSelectedNotification(id);
            BindNotifications();
        }

        protected void btnToggleArchive_Click(object sender, EventArgs e)
        {
            if (Session["SelectedNotificationId"] == null) return;
            int id = Convert.ToInt32(Session["SelectedNotificationId"]);
            if (GetNotificationType(id) == null) return;

            string status = GetNotificationStatus(id);
            if (status == "Archived")
            {
                UpdateNotificationStatus(id, "Read");
                ShowNotificationStatus("Notification unarchived.");
            }
            else
            {
                UpdateNotificationStatus(id, "Archived");
                ShowNotificationStatus("Notification archived.");
            }
            pnlDetailsModal.Visible = false;
            BindNotifications();
        }

        // Legacy handlers kept so wired events still resolve; route via the modal's Open button now.
        protected void btnViewMessage_Click(object sender, EventArgs e)
        {
            if (Session["SelectedNotificationId"] == null) return;
            int id = Convert.ToInt32(Session["SelectedNotificationId"]);
            UpdateNotificationStatus(id, "Read");
            Response.Redirect("StartChat.aspx");
        }

        protected void btnViewProject_Click(object sender, EventArgs e)
        {
            if (Session["SelectedNotificationId"] == null) return;
            int id = Convert.ToInt32(Session["SelectedNotificationId"]);
            UpdateNotificationStatus(id, "Read");
            Response.Redirect("ViewProgress.aspx");
        }

        // ============================================================
        // DB HELPERS (all user-scoped + parameterized)
        // ============================================================
        private string GetNotificationType(int notificationId)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string q = "SELECT type FROM dbo.Notification WHERE notificationID = @Id AND userID = @UserID";
                using (SqlCommand cmd = new SqlCommand(q, conn))
                {
                    cmd.Parameters.AddWithValue("@Id", notificationId);
                    cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                    conn.Open();
                    object r = cmd.ExecuteScalar();
                    return r == null ? null : r.ToString();
                }
            }
        }

        private string GetNotificationStatus(int notificationId)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string q = "SELECT status FROM dbo.Notification WHERE notificationID = @Id AND userID = @UserID";
                using (SqlCommand cmd = new SqlCommand(q, conn))
                {
                    cmd.Parameters.AddWithValue("@Id", notificationId);
                    cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                    conn.Open();
                    object r = cmd.ExecuteScalar();
                    return r == null ? "" : r.ToString();
                }
            }
        }

        private void UpdateNotificationStatus(int notificationId, string status)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = "UPDATE dbo.Notification SET status = @Status WHERE notificationID = @NotificationID AND userID = @UserID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Status", status);
                    cmd.Parameters.AddWithValue("@NotificationID", notificationId);
                    cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void ShowNotificationStatus(string message)
        {
            pnlNotificationStatus.Visible = true;
            lblNotificationStatus.Text = message;
        }
    }
}

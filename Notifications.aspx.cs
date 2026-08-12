using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class Notifications : System.Web.UI.Page
    {
        private readonly string _connStr = ConfigurationManager.ConnectionStrings["FreeHubDB"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;

            if (!IsPostBack)
            {
                Session["NotificationFilter"] = "All";
                BindNotifications();
            }
        }

        private int CurrentUserId
        {
            get { return Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0; }
        }

        private string CurrentFilter
        {
            get { return Session["NotificationFilter"] != null ? Session["NotificationFilter"].ToString() : "All"; }
            set { Session["NotificationFilter"] = value; }
        }

        private void BindNotifications()
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    SELECT 
                        notificationID AS Id,
                        type AS Type,
                        content AS Title,
                        content AS Description,
                        content AS Preview,
                        FORMAT(notificationTimestamp, 'dd MMM yyyy, hh:mm tt') AS Time,
                        status AS Status
                    FROM dbo.Notification
                    WHERE userID = @UserID";

                if (CurrentFilter == "Unread")
                {
                    query += " AND status = 'Unread'";
                }
                else if (CurrentFilter == "Archived")
                {
                    query += " AND status = 'Archived'";
                }
                else
                {
                    query += " AND status != 'Archived'";
                }

                query += " ORDER BY notificationTimestamp DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            dt.Columns.Add("Icon", typeof(string));
            foreach (DataRow row in dt.Rows)
            {
                string type = row["Type"].ToString();
                switch (type)
                {
                    case "Message": row["Icon"] = "✉"; break;
                    case "Project": row["Icon"] = "▣"; break;
                    case "Proposal": row["Icon"] = "▤"; break;
                    case "Payment": row["Icon"] = "R"; break;
                    default: row["Icon"] = "♧"; break;
                }
            }

            rptNotifications.DataSource = dt;
            rptNotifications.DataBind();

            lblNoNotifications.Visible = (dt.Rows.Count == 0);
            UpdateTabBadgesAndStyles();
        }

        private void UpdateTabBadgesAndStyles()
        {
            int allCount = 0, unreadCount = 0, archivedCount = 0;

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    SELECT 
                        ISNULL(SUM(CASE WHEN status != 'Archived' THEN 1 ELSE 0 END), 0) AS AllCount,
                        ISNULL(SUM(CASE WHEN status = 'Unread' THEN 1 ELSE 0 END), 0) AS UnreadCount,
                        ISNULL(SUM(CASE WHEN status = 'Archived' THEN 1 ELSE 0 END), 0) AS ArchivedCount
                    FROM dbo.Notification
                    WHERE userID = @UserID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            allCount = Convert.ToInt32(dr["AllCount"]);
                            unreadCount = Convert.ToInt32(dr["UnreadCount"]);
                            archivedCount = Convert.ToInt32(dr["ArchivedCount"]);
                        }
                    }
                }
            }

            btnAll.Text = allCount > 0 ? string.Format("All ({0})", allCount) : "All";
            btnUnread.Text = unreadCount > 0 ? string.Format("Unread ({0})", unreadCount) : "Unread";
            btnArchived.Text = archivedCount > 0 ? string.Format("Archived ({0})", archivedCount) : "Archived";

            btnAll.CssClass = "notification-tab";
            btnUnread.CssClass = "notification-tab";
            btnArchived.CssClass = "notification-tab";

            switch (CurrentFilter)
            {
                case "Unread": btnUnread.CssClass = "notification-tab active-tab"; break;
                case "Archived": btnArchived.CssClass = "notification-tab active-tab"; break;
                default: btnAll.CssClass = "notification-tab active-tab"; break;
            }
        }

        protected void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectNotification")
            {
                int notificationId = Convert.ToInt32(e.CommandArgument);
                Session["SelectedNotificationId"] = notificationId;
                LoadSelectedNotification(notificationId);
            }
        }

        private void LoadSelectedNotification(int notificationId)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    SELECT notificationID, type, content, FORMAT(notificationTimestamp, 'dd MMM yyyy, hh:mm tt') AS notificationTimestamp, status 
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
                            pnlSelectedNotification.Visible = true;
                            lblSelectNotification.Visible = false;

                            string type = dr["type"].ToString();
                            lblSelectedTitle.Text = type + " Alert";
                            lblSelectedDescription.Text = dr["content"].ToString();
                            lblSelectedPreview.Text = dr["content"].ToString();
                            lblSelectedTime.Text = dr["notificationTimestamp"].ToString();

                            string status = dr["status"].ToString();
                            lblReadStatus.Text = status;

                            btnToggleRead.Text = (status == "Read") ? "Mark as Unread" : "Mark as Read";
                            btnToggleArchive.Text = (status == "Archived") ? "Unarchive" : "Archive";

                            switch (type)
                            {
                                case "Message": lblSelectedIcon.Text = "✉"; break;
                                case "Project": lblSelectedIcon.Text = "▣"; break;
                                case "Proposal": lblSelectedIcon.Text = "▤"; break;
                                case "Payment": lblSelectedIcon.Text = "R"; break;
                                default: lblSelectedIcon.Text = "♧"; break;
                            }

                            btnViewMessage.Visible = (type == "Message");
                        }
                    }
                }
            }
        }

        protected void btnViewMessage_Click(object sender, EventArgs e)
        {
            if (Session["SelectedNotificationId"] == null) return;
            int notificationId = Convert.ToInt32(Session["SelectedNotificationId"]);

            UpdateNotificationStatus(notificationId, "Read");
            Response.Redirect("StartChat.aspx?open=true");
        }

        protected void btnToggleRead_Click(object sender, EventArgs e)
        {
            if (Session["SelectedNotificationId"] == null) return;
            int notificationId = Convert.ToInt32(Session["SelectedNotificationId"]);

            if (btnToggleRead.Text == "Mark as Read")
            {
                UpdateNotificationStatus(notificationId, "Read");
                ShowNotificationStatus("Notification marked as read.");
            }
            else
            {
                UpdateNotificationStatus(notificationId, "Unread");
                ShowNotificationStatus("Notification marked as unread.");
            }

            LoadSelectedNotification(notificationId);
            BindNotifications();
        }

        protected void btnToggleArchive_Click(object sender, EventArgs e)
        {
            if (Session["SelectedNotificationId"] == null) return;
            int notificationId = Convert.ToInt32(Session["SelectedNotificationId"]);

            if (btnToggleArchive.Text == "Archive")
            {
                UpdateNotificationStatus(notificationId, "Archived");
                pnlSelectedNotification.Visible = false;
                lblSelectNotification.Visible = true;
                ShowNotificationStatus("Notification archived successfully.");
            }
            else
            {
                UpdateNotificationStatus(notificationId, "Read");
                pnlSelectedNotification.Visible = false;
                lblSelectNotification.Visible = true;
                ShowNotificationStatus("Notification unarchived successfully.");
            }

            BindNotifications();
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

        protected void btnAll_Click(object sender, EventArgs e)
        {
            CurrentFilter = "All";
            BindNotifications();
        }

        protected void btnUnread_Click(object sender, EventArgs e)
        {
            CurrentFilter = "Unread";
            BindNotifications();
        }

        protected void btnArchived_Click(object sender, EventArgs e)
        {
            CurrentFilter = "Archived";
            BindNotifications();
        }

        private void ShowNotificationStatus(string message)
        {
            pnlNotificationStatus.Visible = true;
            lblNotificationStatus.Text = message;
        }
    }
}
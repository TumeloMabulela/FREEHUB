using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;


namespace FreeHubProject
{
    public partial class Notifications : System.Web.UI.Page
    {
        private List<NotificationItem> NotificationData
        {
            get
            {
                if (Session["NotificationData"] == null)
                {
                    Session["NotificationData"] =
                        CreateNotifications();
                }

                return
                    (List<NotificationItem>)
                    Session["NotificationData"];
            }

            set
            {
                Session["NotificationData"] = value;
            }
        }


        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;

            if (!IsPostBack)
            {
                Session["NotificationData"] = null; // Force reload from DB
                Session["NotificationFilter"] = "All";
                BindNotifications();

                UpdateSummary();
            }
        }


        private List<NotificationItem>
            CreateNotifications()
        {
            return new List<NotificationItem>
            {
                new NotificationItem
                {
                    Id = 1,
                    Type = "Message",
                    Icon = "✉",
                    Title =
                        "New message from Thabo Mokoena",
                    Description =
                        "Thabo Mokoena sent you a new message regarding the UI/UX design project.",
                    Preview =
                        "Hi Mabulela, are you available to discuss the project update?",
                    Time = "2 min ago",
                    UserName = "Thabo Mokoena",
                    IsRead = false,
                    IsArchived = false
                },

                new NotificationItem
                {
                    Id = 2,
                    Type = "Project",
                    Icon = "▣",
                    Title =
                        "Project update from Mabulela Tumelo",
                    Description =
                        "The project Mobile App Development has been updated.",
                    Preview =
                        "The latest project requirements and deadlines are now available.",
                    Time = "Today, 10:28 AM",
                    UserName = "",
                    IsRead = false,
                    IsArchived = false
                },

                new NotificationItem
                {
                    Id = 3,
                    Type = "Proposal",
                    Icon = "▤",
                    Title =
                        "New proposal received",
                    Description =
                        "You received a new proposal for the Brand Identity Design project.",
                    Preview =
                        "A freelancer has submitted a proposal for your review.",
                    Time = "Today, 9:15 AM",
                    UserName = "",
                    IsRead = false,
                    IsArchived = false
                },

                new NotificationItem
                {
                    Id = 4,
                    Type = "Payment",
                    Icon = "R",
                    Title =
                        "Payment received",
                    Description =
                        "You have received a payment of ZAR 2 500.00.",
                    Preview =
                        "The payment has been successfully processed and added to your account.",
                    Time = "Yesterday, 4:45 PM",
                    UserName = "",
                    IsRead = true,
                    IsArchived = false
                },

                new NotificationItem
                {
                    Id = 5,
                    Type = "Welcome",
                    Icon = "♧",
                    Title =
                        "Welcome to FreeHUB",
                    Description =
                        "Explore opportunities and grow your freelance business.",
                    Preview =
                        "Complete your profile to start finding projects and connecting with clients.",
                    Time = "May 10, 2026",
                    UserName = "",
                    IsRead = true,
                    IsArchived = false
                }
            };
        }


        private void BindNotifications()
        {
            string filter =
                Session["NotificationFilter"] == null
                ? "All"
                : Session["NotificationFilter"]
                    .ToString();


            List<NotificationItem> list =
                NotificationData;


            if (filter == "Unread")
            {
                list = list
                    .Where(
                        item =>
                        !item.IsRead &&
                        !item.IsArchived
                    )
                    .ToList();
            }
            else if (filter == "Archived")
            {
                list = list
                    .Where(
                        item =>
                        item.IsArchived
                    )
                    .ToList();
            }
            else
            {
                list = list
                    .Where(
                        item =>
                        !item.IsArchived
                    )
                    .ToList();
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

            // Only message notifications
            // can open Start Chat

            btnViewMessage.Visible =
                item.Type == "Message";
        }

        private void UpdateTabBadgesAndStyles()
        {
            NotificationItem selected =
                GetSelectedNotification();

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


            btnAll.CssClass = "notification-tab";
            btnUnread.CssClass = "notification-tab";
            btnArchived.CssClass = "notification-tab";

            selected.IsRead = true;


            NotificationData =
                NotificationData;


            // Send selected user to StartChat

            string userName =
                Server.UrlEncode(
                    selected.UserName
                );


            Response.Redirect(
                "StartChat.aspx?user=" +
                userName +
                "&open=true"
            );
        }


        protected void btnMarkRead_Click(
            object sender,
            EventArgs e)
        {
            NotificationItem selected =
                GetSelectedNotification();


            if (selected == null)
            {
                return;
            }

private void LoadSelectedNotification(int notificationId)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    SELECT notificationID, type, content, FORMAT(notificationTimestamp, 'dd MMM yyyy, hh:mm tt') AS notificationTimestamp, status 
                    FROM dbo.Notification 
                    WHERE notificationID = @NotificationID AND userID = @UserID";

            selected.IsRead = true;


            NotificationData =
                NotificationData;


            LoadSelectedNotification(
                selected
            );


                            switch (type)
                            {
                                case "Message": lblSelectedIcon.Text = "✉"; break;
                                case "Project": lblSelectedIcon.Text = "▣"; break;
                                case "Proposal": lblSelectedIcon.Text = "▤"; break;
                                case "Payment": lblSelectedIcon.Text = "R"; break;
                                default: lblSelectedIcon.Text = "♧"; break;
                            }

                            // Show specific action buttons based on notification type
                            btnViewMessage.Visible = (type == "Message");

                            // Check if content has a project ID link pattern
                            bool hasProjectLink = contentText.Contains("ProjectDetails.aspx?projectId=") || type == "Project" || type == "Proposal";
                            btnViewProject.Visible = hasProjectLink;
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

        protected void btnViewProject_Click(object sender, EventArgs e)
        {
            if (Session["SelectedNotificationId"] == null) return;
            int notificationId = Convert.ToInt32(Session["SelectedNotificationId"]);
            UpdateNotificationStatus(notificationId, "Read");

            // Extract project ID from content string if present
            string contentText = lblSelectedDescription.Text;
            Match match = Regex.Match(contentText, @"projectId=(\d+)");
            if (match.Success)
            {
                string projId = match.Groups[1].Value;
                Response.Redirect($"ProjectDetails.aspx?id={projId}");
            }
            else
            {
                Response.Redirect("BrowseProjects.aspx");
            }
        }

        protected void btnToggleRead_Click(object sender, EventArgs e)
        {
            if (Session["SelectedNotificationId"] == null) return;
            int notificationId = Convert.ToInt32(Session["SelectedNotificationId"]);

            // Determine target status based on current button text
            string newStatus = (btnToggleRead.Text == "Mark as Read") ? "Read" : "Unread";

            // Update status in database (Marking as Read decreases unread count; Mark as Unread increases it)
            UpdateNotificationStatus(notificationId, newStatus);

            string actionText = (newStatus == "Read") ? "marked as read (count decreased)" : "marked as unread (count increased)";
            ShowNotificationStatus($"Notification {actionText}.");

            // Refresh the notifications list and update current view
            LoadSelectedNotification(notificationId);
            BindNotifications();

            UpdateSummary();


            ShowNotificationStatus(
                "Notification marked as read."
            );
        }


        protected void btnArchive_Click(
            object sender,
            EventArgs e)
        {
            NotificationItem selected =
                GetSelectedNotification();


            if (selected == null)
            {
                return;
            }


            selected.IsArchived = true;


            NotificationData =
                NotificationData;


            pnlSelectedNotification.Visible =
                false;

            lblSelectNotification.Visible =
                true;


            BindNotifications();

            UpdateSummary();


            ShowNotificationStatus(
                "Notification archived successfully."
            );
        }


        protected void btnAll_Click(
            object sender,
            EventArgs e)
        {
            Session[
                "NotificationFilter"
            ] = "All";


            BindNotifications();
        }


        protected void btnUnread_Click(
            object sender,
            EventArgs e)
        {
            Session[
                "NotificationFilter"
            ] = "Unread";


            BindNotifications();
        }


        protected void btnArchived_Click(
            object sender,
            EventArgs e)
        {
            Session[
                "NotificationFilter"
            ] = "Archived";


            BindNotifications();
        }


        private void UpdateSummary()
        {
            lblMessageCount.Text =
                NotificationData
                .Count(
                    item =>
                    item.Type == "Message" &&
                    !item.IsRead &&
                    !item.IsArchived
                )
                .ToString();


            lblProjectCount.Text =
                NotificationData
                .Count(
                    item =>
                    item.Type == "Project" &&
                    !item.IsRead &&
                    !item.IsArchived
                )
                .ToString();


            lblProposalCount.Text =
                NotificationData
                .Count(
                    item =>
                    item.Type == "Proposal" &&
                    !item.IsRead &&
                    !item.IsArchived
                )
                .ToString();


            lblPaymentCount.Text =
                NotificationData
                .Count(
                    item =>
                    item.Type == "Payment" &&
                    !item.IsRead &&
                    !item.IsArchived
                )
                .ToString();
        }


        private NotificationItem
            GetSelectedNotification()
        {
            if (
                Session[
                    "SelectedNotificationId"
                ] == null
            )
            {
                return null;
            }


            int id =
                Convert.ToInt32(
                    Session[
                        "SelectedNotificationId"
                    ]
                );


            return NotificationData
                .FirstOrDefault(
                    item =>
                    item.Id == id
                );
        }


        private void ShowNotificationStatus(
            string message)
        {
            pnlNotificationStatus.Visible =
                true;

            lblNotificationStatus.Text =
                message;
        }
    }


    [Serializable]

    public class NotificationItem
    {
        public int Id
        {
            get;
            set;
        }


        public string Type
        {
            get;
            set;
        }


        public string Icon
        {
            get;
            set;
        }


        public string Title
        {
            get;
            set;
        }


        public string Description
        {
            get;
            set;
        }


        public string Preview
        {
            get;
            set;
        }


        public string Time
        {
            get;
            set;
        }


        public string UserName
        {
            get;
            set;
        }


        public bool IsRead
        {
            get;
            set;
        }


        public bool IsArchived
        {
            get;
            set;
        }
    }
}

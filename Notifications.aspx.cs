using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI.WebControls;

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
                    Session["NotificationData"] = LoadNotificationsFromDB();
                }
                return (List<NotificationItem>)Session["NotificationData"];
            }
            set { Session["NotificationData"] = value; }
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
                Session["NotificationData"] = null; // Force reload from DB
                Session["NotificationFilter"] = "All";
                BindNotifications();
                UpdateSummary();
            }
        }

        private List<NotificationItem> LoadNotificationsFromDB()
        {
            int userId = Convert.ToInt32(Session["UserID"]);
            List<NotificationItem> list = new List<NotificationItem>();

            try
            {
                DataTable dt = DatabaseHelper.GetNotificationsByUser(userId);
                int id = 1;
                foreach (DataRow row in dt.Rows)
                {
                    string type = Convert.ToString(row["type"]);
                    string icon = type == "Message" ? "✉" : type == "Project" ? "▣" : type == "Proposal" ? "▤" : type == "Payment" ? "R" : "♧";

                    list.Add(new NotificationItem
                    {
                        Id = id++,
                        DbId = Convert.ToInt32(row["notificationID"]),
                        Type = type,
                        Icon = icon,
                        Title = Convert.ToString(row["content"]),
                        Description = "",
                        Preview = Convert.ToString(row["content"]),
                        Time = GetTimeAgo(Convert.ToDateTime(row["notificationTimestamp"])),
                        UserName = "",
                        IsRead = Convert.ToString(row["status"]) == "Read",
                        IsArchived = Convert.ToString(row["status"]) == "Archived"
                    });
                }
            }
            catch { }

            return list;
        }

        private string GetTimeAgo(DateTime date)
        {
            TimeSpan diff = DateTime.Now - date;
            if (diff.TotalMinutes < 1) return "Just now";
            if (diff.TotalMinutes < 60) return (int)diff.TotalMinutes + " min ago";
            if (diff.TotalHours < 24) return (int)diff.TotalHours + " hours ago";
            if (diff.TotalDays < 7) return (int)diff.TotalDays + " days ago";
            return date.ToString("dd MMM yyyy");
        }

        private void BindNotifications()
        {
            string filter = Session["NotificationFilter"] == null ? "All" : Session["NotificationFilter"].ToString();
            List<NotificationItem> list = NotificationData;

            if (filter == "Unread")
                list = list.Where(item => !item.IsRead && !item.IsArchived).ToList();
            else if (filter == "Archived")
                list = list.Where(item => item.IsArchived).ToList();
            else
                list = list.Where(item => !item.IsArchived).ToList();

            rptNotifications.DataSource = list;
            rptNotifications.DataBind();
            lblNoNotifications.Visible = list.Count == 0;
        }

        protected void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectNotification")
            {
                int notificationId = Convert.ToInt32(e.CommandArgument);
                Session["SelectedNotificationId"] = notificationId;

                NotificationItem selected = NotificationData.FirstOrDefault(item => item.Id == notificationId);
                if (selected != null)
                {
                    LoadSelectedNotification(selected);
                }
            }
        }

        private void LoadSelectedNotification(NotificationItem item)
        {
            pnlSelectedNotification.Visible = true;
            lblSelectNotification.Visible = false;
            lblSelectedIcon.Text = item.Icon;
            lblSelectedTitle.Text = item.Title;
            lblSelectedDescription.Text = item.Description;
            lblSelectedPreview.Text = item.Preview;
            lblSelectedTime.Text = item.Time;
            lblReadStatus.Text = item.IsRead ? "Read" : "Unread";
            btnViewMessage.Visible = item.Type == "Message";
        }

        protected void btnViewMessage_Click(object sender, EventArgs e)
        {
            Response.Redirect("StartChat.aspx");
        }

        protected void btnMarkRead_Click(object sender, EventArgs e)
        {
            NotificationItem selected = GetSelectedNotification();
            if (selected == null) return;

            selected.IsRead = true;
            NotificationData = NotificationData;

            // Mark in database
            try { DatabaseHelper.MarkNotificationRead(selected.DbId); } catch { }

            LoadSelectedNotification(selected);
            BindNotifications();
            UpdateSummary();
            ShowNotificationStatus("Notification marked as read.");
        }

        protected void btnArchive_Click(object sender, EventArgs e)
        {
            NotificationItem selected = GetSelectedNotification();
            if (selected == null) return;

            selected.IsArchived = true;
            NotificationData = NotificationData;

            pnlSelectedNotification.Visible = false;
            lblSelectNotification.Visible = true;

            BindNotifications();
            UpdateSummary();
            ShowNotificationStatus("Notification archived successfully.");
        }

        protected void btnAll_Click(object sender, EventArgs e)
        {
            Session["NotificationFilter"] = "All";
            BindNotifications();
        }

        protected void btnUnread_Click(object sender, EventArgs e)
        {
            Session["NotificationFilter"] = "Unread";
            BindNotifications();
        }

        protected void btnArchived_Click(object sender, EventArgs e)
        {
            Session["NotificationFilter"] = "Archived";
            BindNotifications();
        }

        private void UpdateSummary()
        {
            lblMessageCount.Text = NotificationData.Count(item => item.Type == "Message" && !item.IsRead && !item.IsArchived).ToString();
            lblProjectCount.Text = NotificationData.Count(item => item.Type == "Project" && !item.IsRead && !item.IsArchived).ToString();
            lblProposalCount.Text = NotificationData.Count(item => item.Type == "Proposal" && !item.IsRead && !item.IsArchived).ToString();
            lblPaymentCount.Text = NotificationData.Count(item => item.Type == "Payment" && !item.IsRead && !item.IsArchived).ToString();
        }

        private NotificationItem GetSelectedNotification()
        {
            if (Session["SelectedNotificationId"] == null) return null;
            int id = Convert.ToInt32(Session["SelectedNotificationId"]);
            return NotificationData.FirstOrDefault(item => item.Id == id);
        }

        private void ShowNotificationStatus(string message)
        {
            if (pnlNotificationStatus != null)
            {
                pnlNotificationStatus.Visible = true;
                lblNotificationStatus.Text = message;
            }
        }
    }

    [Serializable]
    public class NotificationItem
    {
        public int Id { get; set; }
        public int DbId { get; set; }
        public string Type { get; set; }
        public string Icon { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Preview { get; set; }
        public string Time { get; set; }
        public string UserName { get; set; }
        public bool IsRead { get; set; }
        public bool IsArchived { get; set; }
    }
}

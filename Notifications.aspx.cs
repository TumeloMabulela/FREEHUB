using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
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


            rptNotifications.DataSource = list;

            rptNotifications.DataBind();


            lblNoNotifications.Visible =
                list.Count == 0;
        }


        protected void rptNotifications_ItemCommand(
            object source,
            System.Web.UI.WebControls
                .RepeaterCommandEventArgs e)
        {
            if (
                e.CommandName ==
                "SelectNotification"
            )
            {
                int notificationId =
                    Convert.ToInt32(
                        e.CommandArgument
                    );


                Session[
                    "SelectedNotificationId"
                ] = notificationId;


                NotificationItem selected =
                    NotificationData
                    .FirstOrDefault(
                        item =>
                        item.Id ==
                        notificationId
                    );


                if (selected != null)
                {
                    LoadSelectedNotification(
                        selected
                    );
                }
            }
        }


        private void LoadSelectedNotification(
            NotificationItem item)
        {
            pnlSelectedNotification.Visible =
                true;

            lblSelectNotification.Visible =
                false;


            lblSelectedIcon.Text =
                item.Icon;

            lblSelectedTitle.Text =
                item.Title;

            lblSelectedDescription.Text =
                item.Description;

            lblSelectedPreview.Text =
                item.Preview;

            lblSelectedTime.Text =
                item.Time;


            if (item.IsRead)
            {
                lblReadStatus.Text =
                    "Read";
            }
            else
            {
                lblReadStatus.Text =
                    "Unread";
            }


            // Only message notifications
            // can open Start Chat

            btnViewMessage.Visible =
                item.Type == "Message";
        }


        // Opens StartChat.aspx

        protected void btnViewMessage_Click(
            object sender,
            EventArgs e)
        {
            NotificationItem selected =
                GetSelectedNotification();


            if (
                selected == null ||
                selected.Type != "Message"
            )
            {
                ShowNotificationStatus(
                    "This notification does not contain a chat message."
                );

                return;
            }


            // Mark notification as read

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


            selected.IsRead = true;


            NotificationData =
                NotificationData;


            LoadSelectedNotification(
                selected
            );


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
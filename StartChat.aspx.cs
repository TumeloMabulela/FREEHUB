using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class StartChat : System.Web.UI.Page
    {
        private readonly string _connStr = ConfigurationManager.ConnectionStrings["FreeHubDB"]?.ConnectionString;

        private List<ChatUser> Users
        {
            get
            {
                return new List<ChatUser>
                {
                    new ChatUser
                    {
                        Name = "Thabo Mokoena",
                        Initials = "TM",
                        Status = "Online",
                        Role = "UI/UX Designer",
                        Location = "Cape Town, South Africa"
                    },

                    new ChatUser
                    {
                        Name = "Aisha Khan",
                        Initials = "AK",
                        Status = "Offline",
                        Role = "Web Developer",
                        Location = "Johannesburg, South Africa"
                    },

                    new ChatUser
                    {
                        Name = "John Tau",
                        Initials = "JT",
                        Status = "Online",
                        Role = "Software Developer",
                        Location = "Pretoria, South Africa"
                    },

                    new ChatUser
                    {
                        Name = "Sarah Patel",
                        Initials = "SP",
                        Status = "Offline",
                        Role = "Graphic Designer",
                        Location = "Durban, South Africa"
                    }
                };
            }
        }


        protected void Page_Load(object sender, EventArgs e)
        {
            get { return Session["SelectedOtherUserId"] != null ? Convert.ToInt32(Session["SelectedOtherUserId"]) : 0; }
            set { Session["SelectedOtherUserId"] = value; }
        }

            if (!IsPostBack)
            {
                BindUsers("");

                // Disable chat buttons when the page first opens

                btnViewProfile.Enabled = false;

                btnEndChat.Enabled = false;

                btnSend.Enabled = false;


                // Check whether Notifications.aspx
                // sent a user to StartChat.aspx

                string userFromNotification =
                    Request.QueryString["user"];

                string openChat =
                    Request.QueryString["open"];


                if (!string.IsNullOrWhiteSpace(
                    userFromNotification))
                {
                    ChatUser selectedUser =
                        Users.FirstOrDefault(
                            user =>
                            user.Name.Equals(
                                userFromNotification,
                                StringComparison.OrdinalIgnoreCase
                            )
                        );


                    if (selectedUser != null)
                    {
                        // Store the selected user's details

                        Session["SelectedUser"] =
                            selectedUser.Name;

                        Session["SelectedInitials"] =
                            selectedUser.Initials;

                        Session["SelectedStatus"] =
                            selectedUser.Status;

                        Session["SelectedRole"] =
                            selectedUser.Role;

                        Session["SelectedLocation"] =
                            selectedUser.Location;


                        // Display the selected user

                        LoadSelectedUser();


                        // Automatically open the chat
                        // when open=true is received

                        if (openChat == "true")
                        {
                            OpenChatFromNotification();
                        }
                        else
                        {
                            LoadChat();
                        }
                    }
                    else
                    {
                        LoadSelectedUser();

                        LoadChat();
                    }
                }
                else
                {
                    LoadSelectedUser();

                    LoadChat();
                }
            }
        }


        // Display users

        private void BindUsers(string searchText)
        {
            List<ChatUser> filteredUsers = Users;

            if (!string.IsNullOrWhiteSpace(searchText))
            {
                filteredUsers = Users
                    .Where(user =>
                        user.Name.IndexOf(
                            searchText,
                            StringComparison.OrdinalIgnoreCase
                        ) >= 0
                    )
                    .ToList();
            }

            rptUsers.DataSource = filteredUsers;

            rptUsers.DataBind();
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectUser")
            {
                string selectedName =
                    e.CommandArgument.ToString();

                ChatUser selectedUser =
                    Users.FirstOrDefault(
                        user => user.Name == selectedName
                    );

                if (selectedUser != null)
                {
                    Session["SelectedUser"] =
                        selectedUser.Name;

                    Session["SelectedInitials"] =
                        selectedUser.Initials;

                    Session["SelectedStatus"] =
                        selectedUser.Status;

                    Session["SelectedRole"] =
                        selectedUser.Role;

                    Session["SelectedLocation"] =
                        selectedUser.Location;


                    LoadSelectedUser();


                    ShowStatus(
                        selectedUser.Name +
                        " has been selected."
                    );
                }
            }
        }


        // Load selected user information

        private void LoadSelectedUser()
        {
            if (Session["SelectedUser"] != null)
            {
                pnlSelectedUser.Visible = true;

                lblNoUser.Visible = false;


                lblSelectedName.Text =
                    Session["SelectedUser"].ToString();

                lblSelectedInitials.Text =
                    Session["SelectedInitials"].ToString();

                lblSelectedRole.Text =
                    Session["SelectedRole"].ToString();

                lblSelectedLocation.Text =
                    Session["SelectedLocation"].ToString();
            }
            else
            {
                pnlSelectedUser.Visible = false;

                lblNoUser.Visible = true;
            }
        }


        // Start the chat normally

        protected void btnStartChat_Click(
            object sender,
            EventArgs e)
        {
            if (Session["SelectedUser"] == null)
            {
                ShowStatus(
                    "Please select a user first."
                );

                return;
            }


            // 2. Check if there is an active/completed proposal/project between these two users (with proper JOINs)
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                List<ChatMessage> messages =
                    new List<ChatMessage>();


                messages.Add(
                    new ChatMessage
                    {
                        Text =
                            "Hi, thanks for reaching out! " +
                            "How can I help you?",

                        Sender = "User"
                    }
                );


                Session["Messages"] = messages;
            }


            LoadChat();


            ShowStatus(
                "Chat session opened successfully."
            );
        }


        // Automatically open a chat
        // when coming from Notifications.aspx

        private void OpenChatFromNotification()
        {
            if (Session["SelectedUser"] == null)
            {
                return;
            }


            Session["ChatActive"] = true;


            lblChatName.Text =
                Session["SelectedUser"].ToString();

            lblChatInitials.Text =
                Session["SelectedInitials"].ToString();

            lblChatStatus.Text =
                Session["SelectedStatus"].ToString();


            btnViewProfile.Enabled = true;

            btnEndChat.Enabled = true;

            btnSend.Enabled = true;


            // Create the message received
            // from the notification

            if (Session["Messages"] == null)
            {
                List<ChatMessage> messages =
                    new List<ChatMessage>();


                messages.Add(
                    new ChatMessage
                    {
                        Text =
                            "Hi Mabulela, are you available " +
                            "to discuss the project update?",

                        Sender = "User"
                    }
                );


                Session["Messages"] = messages;
            }


            LoadChat();


            ShowStatus(
                "Chat opened from your notification."
            );
        }


        // Send a message

        protected void btnSend_Click(
            object sender,
            EventArgs e)
        {
            if (Session["ChatActive"] == null ||
                !(bool)Session["ChatActive"])
            {
                ShowStatus(
                    "Please start a chat first."
                );

                return;
            }


            if (string.IsNullOrWhiteSpace(
                txtMessage.Text))
            {
                ShowStatus(
                    "Please type a message."
                );

                return;
            }


            List<ChatMessage> messages;


            if (Session["Messages"] == null)
            {
                messages =
                    new List<ChatMessage>();
            }
            else
            {
                messages =
                    (List<ChatMessage>)
                    Session["Messages"];
            }


            messages.Add(
                new ChatMessage
                {
                    Text =
                        txtMessage.Text.Trim(),

                    Sender = "Me"
                }
            );


            Session["Messages"] = messages;


            txtMessage.Text = "";


            LoadChat();


            ShowStatus(
                "Message sent successfully."
            );
        }


        // Display messages

        private void LoadChat()
        {
            phMessages.Controls.Clear();


            if (Session["Messages"] == null)
            {
                phMessages.Controls.Add(
                    new LiteralControl(
                        "<div class='empty-chat'>" +
                        "Select a user and start a chat." +
                        "</div>"
                    )
                );

                return;
            }


            List<ChatMessage> messages =
                (List<ChatMessage>)
                Session["Messages"];


            foreach (ChatMessage message
                in messages)
            {
                string messageClass;


                if (message.Sender == "Me")
                {
                    messageClass =
                        "sent-message";
                }
                else
                {
                    messageClass =
                        "received-message";
                }


                string safeMessage =
                    HttpUtility.HtmlEncode(
                        message.Text
                    );


                phMessages.Controls.Add(
                    new LiteralControl(
                        "<div class='" +
                        messageClass +
                        "'>" +

                        safeMessage +

                        "</div>"
                    )
                );
            }
        }


        // Search when Search button is clicked

        protected void btnSearch_Click(
            object sender,
            EventArgs e)
        {
            BindUsers(
                txtSearch.Text.Trim()
            );
        }


        // Search when the search text changes

        protected void txtSearch_TextChanged(
            object sender,
            EventArgs e)
        {
            BindUsers(
                txtSearch.Text.Trim()
            );
        }


        // View selected user's profile

        protected void btnViewProfile_Click(
            object sender,
            EventArgs e)
        {
            if (Session["SelectedUser"] == null)
            {
                ShowStatus(
                    "There is no selected user."
                );

                return;
            }


            string userName =
                Session["SelectedUser"].ToString();


            ShowStatus(
                "Profile details for " +
                userName +
                ": " +

                Session["SelectedRole"].ToString() +

                ", " +

                Session["SelectedLocation"].ToString()
            );
        }


        // End the chat

        protected void btnEndChat_Click(
            object sender,
            EventArgs e)
        {
            Session.Remove(
                "ChatActive"
            );

            Session.Remove(
                "Messages"
            );


            lblChatName.Text =
                "No chat selected";

            lblChatInitials.Text =
                "CH";

            lblChatStatus.Text =
                "Select a user and click Start Chat";


            btnViewProfile.Enabled = false;

            btnEndChat.Enabled = false;

            btnSend.Enabled = false;


            txtMessage.Text = "";


            LoadChat();


            ShowStatus(
                "The chat session has ended."
            );
        }


        // Display a status message

        private void ShowStatus(
            string message)
        {
            pnlStatus.Visible = true;

            lblStatus.Text = message;
        }
    }


    // User class

    [Serializable]

    public class ChatUser
    {
        public string Name
        {
            get;
            set;
        }


        public string Initials
        {
            get;
            set;
        }


        public string Status
        {
            get;
            set;
        }


        public string Role
        {
            get;
            set;
        }


        public string Location
        {
            get;
            set;
        }
    }


    // Message class

    [Serializable]

    public class ChatMessage
    {
        public string Text
        {
            get;
            set;
        }

        private void ShowStatus(string message)
        {
            pnlStatus.Visible = true;
            lblStatus.Text = message;
        }
    }
}
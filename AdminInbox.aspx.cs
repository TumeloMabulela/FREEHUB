using System;
using System.Data;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class AdminInbox : System.Web.UI.Page
    {
        private int AdminId
        {
            get { return AuthHelper.GetCurrentUserId(this); }
        }

        public int SelectedUserId
        {
            get { return ViewState["SelInboxUser"] != null ? (int)ViewState["SelInboxUser"] : 0; }
            set { ViewState["SelInboxUser"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireRole(this, "Admin")) return;

            if (!IsPostBack)
            {
                DatabaseHelper.UpdateUserLastSeen(AdminId);

                // Allow deep-link ?user=ID to open a specific conversation.
                int uid;
                if (int.TryParse(Request.QueryString["user"], out uid) && uid > 0)
                {
                    SelectedUserId = uid;
                }

                LoadConversations();
                if (SelectedUserId > 0) OpenThread(SelectedUserId);
            }
        }

        private void LoadConversations()
        {
            DataTable dt = DatabaseHelper.GetAdminConversations(AdminId);
            rptConversations.DataSource = dt;
            rptConversations.DataBind();
            lblNoConvos.Visible = dt.Rows.Count == 0;
        }

        protected bool IsFromAdmin(object senderId)
        {
            return Convert.ToInt32(senderId) == AdminId;
        }

        protected void rptConversations_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Open")
            {
                int uid = Convert.ToInt32(e.CommandArgument);
                OpenThread(uid);
                LoadConversations(); // refresh unread badges after marking read
            }
        }

        private void OpenThread(int otherUserId)
        {
            SelectedUserId = otherUserId;

            // Mark their messages to the admin as read.
            DatabaseHelper.MarkMessagesAsRead(AdminId, otherUserId, null);

            DataRow u = DatabaseHelper.GetUserById(otherUserId);
            if (u != null)
            {
                string name = (Convert.ToString(u["firstName"]) + " " + Convert.ToString(u["lastName"])).Trim();
                litThreadName.Text = Server.HtmlEncode(name) + " &mdash; " + Server.HtmlEncode(Convert.ToString(u["userType"]));
            }

            DataTable msgs = DatabaseHelper.GetConversation(AdminId, otherUserId);
            rptMessages.DataSource = msgs;
            rptMessages.DataBind();

            pnlThread.Visible = true;
            pnlNoThread.Visible = false;
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            if (SelectedUserId <= 0) return;
            string body = txtReply.Text.Trim();
            if (string.IsNullOrEmpty(body)) { OpenThread(SelectedUserId); return; }

            DatabaseHelper.SendMessage(AdminId, SelectedUserId, body);
            NotificationHelper.CreateNotification(SelectedUserId, "Message",
                "FreeHub Support replied to your query.");

            txtReply.Text = "";
            OpenThread(SelectedUserId);
            LoadConversations();
        }
    }
}

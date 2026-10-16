using System;
using System.Data;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class AdminDisputes : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireRole(this, "Admin")) return;
            if (!IsPostBack)
            {
                LoadDisputes();
            }
        }

        private void LoadDisputes()
        {
            DataTable dt = DatabaseHelper.GetAllDisputes();
            rptDisputes.DataSource = dt;
            rptDisputes.DataBind();
            lblEmpty.Visible = dt.Rows.Count == 0;
        }

        protected string FormatAdminNote(object adminComment)
        {
            string note = Convert.ToString(adminComment);
            if (string.IsNullOrWhiteSpace(note)) return "";
            return "<div style='color:#5a5a5a;margin-top:4px;font-size:11px;'>Note: " + Server.HtmlEncode(note) + "</div>";
        }

        protected void rptDisputes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Resolve") return;

            int disputeID = Convert.ToInt32(e.CommandArgument);

            var ddl = e.Item.FindControl("ddlStatus") as DropDownList;
            var txt = e.Item.FindControl("txtComment") as TextBox;
            string newStatus = ddl != null ? ddl.SelectedValue : "In Review";
            string comment = txt != null ? txt.Text.Trim() : "";

            // Closing (rejecting) a dispute requires a reason the user can see.
            if (newStatus.Equals("Closed", StringComparison.OrdinalIgnoreCase) && string.IsNullOrWhiteSpace(comment))
            {
                ShowMessage("Please enter a reason in the note field before closing (rejecting) dispute #" + disputeID + ".");
                LoadDisputes();
                return;
            }

            int adminUserId = AuthHelper.GetCurrentUserId(this);
            bool ok = DatabaseHelper.ResolveDispute(disputeID, adminUserId, newStatus, comment);

            if (ok)
            {
                int ownerId = DatabaseHelper.GetUserIdForDispute(disputeID);
                if (ownerId > 0)
                {
                    string userMsg = "Your dispute #" + disputeID + " is now '" + newStatus + "'.";
                    if (!string.IsNullOrWhiteSpace(comment))
                        userMsg += " Admin note: " + comment;
                    NotificationHelper.CreateNotification(ownerId, "Dispute", userMsg);
                }
                ShowMessage("Dispute #" + disputeID + " updated to '" + newStatus + "'.");
            }
            else
            {
                ShowMessage("Could not update dispute #" + disputeID + ".");
            }

            LoadDisputes();
        }

        private void ShowMessage(string msg)
        {
            litMsg.Text = Server.HtmlEncode(msg);
            pnlMsg.Visible = true;
        }
    }
}

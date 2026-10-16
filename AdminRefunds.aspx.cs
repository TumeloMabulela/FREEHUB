using System;
using System.Data;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class AdminRefunds : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireRole(this, "Admin")) return;
            if (!IsPostBack) LoadRefunds();
        }

        private void LoadRefunds()
        {
            DataTable dt = DatabaseHelper.GetAllRefunds();
            rpt.DataSource = dt;
            rpt.DataBind();
            lblEmpty.Visible = dt.Rows.Count == 0;
        }

        protected bool IsPending(object status)
        {
            return string.Equals(Convert.ToString(status), "Pending", StringComparison.OrdinalIgnoreCase);
        }

        protected void rpt_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int txnId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Approve")
            {
                int ownerId = DatabaseHelper.ApproveRefund(txnId);
                if (ownerId > 0)
                {
                    NotificationHelper.CreateNotification(ownerId, "Payment",
                        "Your refund has been approved and credited to your wallet.");
                    ShowMessage("Refund approved and the user's wallet was credited.");
                }
                else
                {
                    ShowMessage("Could not approve this refund (it may already be processed).");
                }
            }
            else if (e.CommandName == "AskReject")
            {
                // Open the reason modal for this refund.
                hfRejectTxnId.Value = txnId.ToString();
                txtReason.Text = "";
                lblReasonErr.Visible = false;
                pnlReject.Visible = true;
                return; // don't reload/close the modal
            }

            LoadRefunds();
        }

        protected void btnCancelReject_Click(object sender, EventArgs e)
        {
            pnlReject.Visible = false;
            LoadRefunds();
        }

        protected void btnConfirmReject_Click(object sender, EventArgs e)
        {
            string reason = txtReason.Text.Trim();
            if (string.IsNullOrWhiteSpace(reason))
            {
                lblReasonErr.Visible = true;
                pnlReject.Visible = true;
                return;
            }

            int txnId;
            if (!int.TryParse(hfRejectTxnId.Value, out txnId) || txnId <= 0)
            {
                pnlReject.Visible = false;
                LoadRefunds();
                return;
            }

            int ownerId = DatabaseHelper.RejectRefund(txnId, reason);
            if (ownerId > 0)
            {
                NotificationHelper.CreateNotification(ownerId, "Payment",
                    "Your refund request was declined. Reason: " + reason);
                ShowMessage("Refund request rejected. The user has been notified with your reason.");
            }
            else
            {
                ShowMessage("Could not reject this refund.");
            }

            pnlReject.Visible = false;
            LoadRefunds();
        }

        private void ShowMessage(string msg)
        {
            litMsg.Text = Server.HtmlEncode(msg);
            pnlMsg.Visible = true;
        }
    }
}

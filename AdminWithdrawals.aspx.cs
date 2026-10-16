using System;
using System.Data;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class AdminWithdrawals : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireRole(this, "Admin")) return;
            if (!IsPostBack) LoadWithdrawals();
        }

        private void LoadWithdrawals()
        {
            DataTable dt = DatabaseHelper.GetAllWithdrawals();
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
                int ownerId = DatabaseHelper.ApproveWithdrawal(txnId);
                if (ownerId > 0)
                {
                    NotificationHelper.CreateNotification(ownerId, "Payment",
                        "Your withdrawal has been approved and paid out.");
                    ShowMessage("Withdrawal approved.");
                }
                else
                {
                    ShowMessage("Could not approve this withdrawal.");
                }
            }
            else if (e.CommandName == "AskReject")
            {
                hfRejectTxnId.Value = txnId.ToString();
                txtReason.Text = "";
                lblReasonErr.Visible = false;
                pnlReject.Visible = true;
                return;
            }

            LoadWithdrawals();
        }

        protected void btnCancelReject_Click(object sender, EventArgs e)
        {
            pnlReject.Visible = false;
            LoadWithdrawals();
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
                LoadWithdrawals();
                return;
            }

            int ownerId = DatabaseHelper.RejectWithdrawal(txnId, reason);
            if (ownerId > 0)
            {
                NotificationHelper.CreateNotification(ownerId, "Payment",
                    "Your withdrawal request was declined and the amount returned to your wallet. Reason: " + reason);
                ShowMessage("Withdrawal rejected, the amount was returned to the user's wallet, and the user was notified with your reason.");
            }
            else
            {
                ShowMessage("Could not reject this withdrawal (it may already be processed).");
            }

            pnlReject.Visible = false;
            LoadWithdrawals();
        }

        private void ShowMessage(string msg)
        {
            litMsg.Text = Server.HtmlEncode(msg);
            pnlMsg.Visible = true;
        }
    }
}

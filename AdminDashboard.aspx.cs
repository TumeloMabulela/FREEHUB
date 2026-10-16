using System;
using System.Data;

namespace FreeHubProject
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Admin-only page. Server-side authorisation is enforced here regardless
            // of what links are shown in the UI.
            if (!AuthHelper.RequireRole(this, "Admin")) return;

            if (!IsPostBack)
            {
                BindDashboard();
            }
        }

        /// <summary>
        /// Loads all dynamic content for the dashboard. Every value comes from the
        /// existing database via DatabaseHelper; nothing is hardcoded and nothing is
        /// mutated (read-only aggregates + a read-only activity feed).
        /// </summary>
        private void BindDashboard()
        {
            // Greeting name (from session, HTML-encoded).
            litAdminName.Text = Server.HtmlEncode((Session["FirstName"] as string ?? "Admin").Trim());

            // Current date and time in South Africa time (matches the rest of the site).
            DateTime now = TimeHelper.Now;
            litTodayDate.Text = Server.HtmlEncode(now.ToString("dddd, dd MMM yyyy"));
            litTodayTime.Text = Server.HtmlEncode(now.ToString("hh:mm tt"));

            // ---- Live counts (statistics cards + sidebar status summary) ----
            int openDisputes = DatabaseHelper.GetOpenDisputeCount();
            int pendingRefunds = DatabaseHelper.GetPendingRefundCount();
            int pendingWithdrawals = DatabaseHelper.GetPendingWithdrawalCount();
            int unreadHelp = DatabaseHelper.GetAdminUnreadMessageCount(DatabaseHelper.AdminUserId);

            litOpenDisputes.Text = openDisputes.ToString();
            litPendingRefunds.Text = pendingRefunds.ToString();
            litPendingWithdrawals.Text = pendingWithdrawals.ToString();
            litUnreadHelp.Text = unreadHelp.ToString();

            // Contextual subtitles that react to the data.
            litRefundSub.Text = pendingRefunds == 0 ? "No pending refunds" : "Awaiting your review";
            litWithdrawalSub.Text = pendingWithdrawals == 0 ? "No pending withdrawals" : "Awaiting your review";
            litHelpSub.Text = unreadHelp == 0 ? "All caught up!" : "Users are waiting";

            // Sidebar status-summary dots.
            litSumDisputes.Text = openDisputes.ToString();
            litSumRefunds.Text = pendingRefunds.ToString();
            litSumWithdrawals.Text = pendingWithdrawals.ToString();

            // ---- Recent activity feed (read-only) ----
            DataTable activity = DatabaseHelper.GetRecentAdminActivity(15);

            // Sidebar filter counts derive from the same feed so they stay in sync.
            int totalCount = activity.Rows.Count;
            int openCount = 0, resolvedCount = 0;
            foreach (DataRow row in activity.Rows)
            {
                if (IsOpenStatus(Convert.ToString(row["status"]))) openCount++;
                else resolvedCount++;
            }
            litCountAll.Text = totalCount.ToString();
            litCountOpen.Text = openCount.ToString();
            litCountResolved.Text = resolvedCount.ToString();

            // Apply the active filter (All / Open / Resolved) to what the table shows.
            string filter = (Request.QueryString["filter"] ?? "all").ToLowerInvariant();
            SetActiveFilterClasses(filter);

            DataView view = activity.DefaultView;
            if (filter == "open")
            {
                view.RowFilter = BuildStatusFilterExpression(true);
            }
            else if (filter == "resolved")
            {
                view.RowFilter = BuildStatusFilterExpression(false);
            }

            if (view.Count == 0)
            {
                rptActivity.Visible = false;
                pnlActivityEmpty.Visible = true;
            }
            else
            {
                rptActivity.Visible = true;
                pnlActivityEmpty.Visible = false;
                rptActivity.DataSource = view;
                rptActivity.DataBind();
            }
        }

        /// <summary>True for statuses considered "open / needs attention".</summary>
        protected static bool IsOpenStatus(string status)
        {
            if (string.IsNullOrWhiteSpace(status)) return true;
            string s = status.Trim();
            return s.Equals("Open", StringComparison.OrdinalIgnoreCase)
                || s.Equals("In Review", StringComparison.OrdinalIgnoreCase)
                || s.Equals("Pending", StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>Builds a DataView RowFilter selecting open (or non-open) statuses.</summary>
        private static string BuildStatusFilterExpression(bool openOnly)
        {
            // Open set: Open, In Review, Pending. Resolved set: everything else.
            string openExpr = "(status = 'Open' OR status = 'In Review' OR status = 'Pending' OR status IS NULL)";
            return openOnly ? openExpr : "NOT " + openExpr;
        }

        private void SetActiveFilterClasses(string filter)
        {
            fltAll.Attributes["class"] = "ad-filter" + (filter == "all" ? " active" : "");
            fltOpen.Attributes["class"] = "ad-filter" + (filter == "open" ? " active" : "");
            fltResolved.Attributes["class"] = "ad-filter" + (filter == "resolved" ? " active" : "");
        }

        // ---- Repeater formatting helpers (used from the .aspx markup) ----

        protected string FormatActivityDate(object dbDate)
        {
            DateTime d = TimeHelper.ToSast(dbDate);
            if (d == DateTime.MinValue) return "";
            return Server.HtmlEncode(d.ToString("dd MMM yyyy")) +
                   "<span class=\"ad-time\">" + Server.HtmlEncode(d.ToString("hh:mm tt")) + "</span>";
        }

        protected string TypeBadgeClass(object type)
        {
            string t = Convert.ToString(type).ToLowerInvariant();
            if (t == "dispute") return "ad-type-dispute";
            if (t == "refund") return "ad-type-refund";
            if (t == "withdrawal") return "ad-type-withdrawal";
            return "ad-type-dispute";
        }

        protected string StatusBadgeClass(object status)
        {
            return IsOpenStatus(Convert.ToString(status)) ? "ad-badge-open" : "ad-badge-done";
        }

        /// <summary>Deep-link each activity row's action to the correct admin page.</summary>
        protected string ActivityActionUrl(object type, object refId)
        {
            string t = Convert.ToString(type).ToLowerInvariant();
            string id = Convert.ToString(refId);
            if (t == "dispute") return "AdminDisputes.aspx";
            if (t == "refund") return "AdminRefunds.aspx";
            if (t == "withdrawal") return "AdminWithdrawals.aspx";
            return "AdminDashboard.aspx";
        }
    }
}

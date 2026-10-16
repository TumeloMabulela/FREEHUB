using System;
using System.Collections.Generic;
using System.Data;

namespace FreeHubProject
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Require login - redirect guests to homepage
            if (Session["UserID"] == null)
            {
                Response.Redirect("Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                ShowDashboardMessage();
                LoadDashboard();
            }
        }

        // Display a one-time success/info message passed via Session
        // (e.g. after posting a project or submitting a proposal), then clear it.
        private void ShowDashboardMessage()
        {
            string message = Session["DashboardMessage"] as string;
            if (!string.IsNullOrEmpty(message))
            {
                litDashboardMessage.Text = message;
                pnlDashboardMessage.Visible = true;
                Session.Remove("DashboardMessage");
            }
        }

        private void LoadDashboard()
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string userType = Session["UserType"] as string ?? "";
            string firstName = Session["FirstName"] as string ?? "User";

            // Welcome info
            litFirstName.Text = Server.HtmlEncode(firstName);
            litRole.Text = Server.HtmlEncode(userType);

            // Rating
            decimal rating = Session["RatingScore"] != null
                ? Convert.ToDecimal(Session["RatingScore"]) : 0.00m;
            litRating.Text = rating.ToString("0.00");

            // Wallet balance
            decimal balance = Session["AvailableBalance"] != null
                ? Convert.ToDecimal(Session["AvailableBalance"]) : 0.00m;
            litBalance.Text = balance.ToString("N2");

            // Role-specific content
            if (userType.Equals("Employer", StringComparison.OrdinalIgnoreCase))
            {
                LoadEmployerDashboard(userID);
            }
            else if (userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
            {
                LoadFreelancerDashboard(userID);
            }
            else
            {
                // Default for Admin or other types
                litProjectsLabel.Text = "Projects";
                litProjectsCount.Text = "0";
                litProposalsLabel.Text = "Proposals";
                litProposalsCount.Text = "0";
            }

            // Load recent activity
            LoadRecentActivity(userID, userType);
        }

        private void LoadEmployerDashboard(int userID)
        {
            pnlEmployerActions.Visible = true;
            pnlFreelancerActions.Visible = false;

            // Show the employer dashboard body; hide the freelancer generic layout.
            pnlEmployerDash.Visible = true;
            pnlFreelancerDash.Visible = false;

            // Quick Actions (left column, employer set) + overview cards beside welcome.
            pnlEmployerQuick.Visible = true;
            pnlFreelancerQuick.Visible = false;
            pnlEmployerStats.Visible = true;

            // Employer wallet-balance stat card (same live value as the shared balance).
            decimal empBalance = Session["AvailableBalance"] != null
                ? Convert.ToDecimal(Session["AvailableBalance"]) : 0.00m;
            litBalanceEmp.Text = empBalance.ToString("N2");

            // Keep the legacy freelancer-style labels in sync (used only if the generic
            // stat row is ever shown); the employer stat row uses its own literals below.
            litProjectsLabel.Text = "My Projects";
            litProposalsLabel.Text = "Proposals Received";

            DataTable projects = DatabaseHelper.GetProjectsByEmployer(userID);

            int activeCount = 0, completedCount = 0, totalProposals = 0;

            if (projects != null)
            {
                foreach (DataRow row in projects.Rows)
                {
                    string status = Convert.ToString(row["projectStatus"]).Trim();

                    // "Active" = Open / In Progress / Under Review (same definition used on
                    // the My Projects page). "Completed" = officially completed projects.
                    if (status.Equals("Open", StringComparison.OrdinalIgnoreCase)
                        || status.Equals("In Progress", StringComparison.OrdinalIgnoreCase)
                        || status.Equals("Under Review", StringComparison.OrdinalIgnoreCase))
                    {
                        activeCount++;
                    }
                    else if (status.Equals("Completed", StringComparison.OrdinalIgnoreCase))
                    {
                        completedCount++;
                    }

                    if (row["proposalCount"] != DBNull.Value)
                        totalProposals += Convert.ToInt32(row["proposalCount"]);
                }
            }

            // Legacy literals (kept for compatibility with any shared markup).
            litProjectsCount.Text = projects != null ? projects.Rows.Count.ToString() : "0";
            litProposalsCount.Text = totalProposals.ToString();

            // Employer stat cards (live data; nothing hardcoded).
            litActiveCount.Text = activeCount.ToString();
            litProposalsReceived.Text = totalProposals.ToString();
            litCompletedCount.Text = completedCount.ToString();

            // ----- My Projects list (most recent first; query already orders by dateCreated DESC) -----
            var projectItems = new List<EmployerProjectItem>();
            var deadlineItems = new List<EmployerDeadlineItem>();

            if (projects != null)
            {
                foreach (DataRow row in projects.Rows)
                {
                    string status = Convert.ToString(row["projectStatus"]).Trim();
                    string title = TitleHelper.TitleCase(Convert.ToString(row["title"]));
                    decimal budget = row["budget"] != DBNull.Value ? Convert.ToDecimal(row["budget"]) : 0m;
                    int proposalCount = row["proposalCount"] != DBNull.Value ? Convert.ToInt32(row["proposalCount"]) : 0;

                    projectItems.Add(new EmployerProjectItem
                    {
                        Title = title,
                        Status = status,
                        StatusClass = GetStatusBadgeClass(status),
                        BudgetFormatted = "R" + budget.ToString("N2"),
                        ProposalCount = proposalCount,
                        Progress = GetProgressPercent(status, row),
                        ProjectId = Convert.ToInt32(row["projectID"])
                    });

                    // Upcoming deadlines: everything not completed/cancelled, that has a date.
                    bool finished = status.Equals("Completed", StringComparison.OrdinalIgnoreCase)
                                    || status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase);
                    if (!finished && row["deadline"] != DBNull.Value)
                    {
                        deadlineItems.Add(new EmployerDeadlineItem
                        {
                            Title = title,
                            Deadline = Convert.ToDateTime(row["deadline"])
                        });
                    }
                }
            }

            // Show the five most recent projects in the My Projects card.
            List<EmployerProjectItem> topProjects = projectItems.Count > 5
                ? projectItems.GetRange(0, 5) : projectItems;
            rptEmpProjects.DataSource = topProjects;
            rptEmpProjects.DataBind();
            pnlEmpNoProjects.Visible = (topProjects.Count == 0);

            // Upcoming deadlines sorted by soonest first; show up to five.
            deadlineItems.Sort((a, b) => a.Deadline.CompareTo(b.Deadline));
            List<EmployerDeadlineItem> topDeadlines = deadlineItems.Count > 5
                ? deadlineItems.GetRange(0, 5) : deadlineItems;
            rptEmpDeadlines.DataSource = topDeadlines;
            rptEmpDeadlines.DataBind();
            pnlEmpNoDeadlines.Visible = (topDeadlines.Count == 0);
        }

        /// <summary>
        /// Progress percentage for a project, reusing the exact status-based formula from
        /// the View Progress page (Completed=100, Under Review=85, In Progress started=50 /
        /// not started=15, otherwise 0). No new/invented calculation.
        /// </summary>
        private int GetProgressPercent(string status, DataRow row)
        {
            if (status.Equals("Completed", StringComparison.OrdinalIgnoreCase)) return 100;
            if (status.Equals("Under Review", StringComparison.OrdinalIgnoreCase)) return 85;
            if (status.Equals("In Progress", StringComparison.OrdinalIgnoreCase))
            {
                bool started = false;
                if (row.Table.Columns.Contains("isStarted") && row["isStarted"] != DBNull.Value)
                    started = Convert.ToInt32(row["isStarted"]) == 1;
                return started ? 50 : 15;
            }
            return 0; // Open / other
        }

        /// <summary>Maps a project status to a badge CSS class (display colour only).</summary>
        private string GetStatusBadgeClass(string status)
        {
            string s = (status ?? "").Trim().ToLowerInvariant();
            switch (s)
            {
                case "open": return "emp-badge-open";
                case "in progress": return "emp-badge-progress";
                case "under review": return "emp-badge-review";
                case "completed": return "emp-badge-completed";
                case "cancelled": return "emp-badge-cancelled";
                default: return "emp-badge-default";
            }
        }

        private void LoadFreelancerDashboard(int userID)
        {
            pnlFreelancerActions.Visible = true;
            pnlEmployerActions.Visible = false;

            // The new employer dashboard body is employer-only; keep it hidden here so the
            // freelancer view is completely unchanged.
            pnlEmployerDash.Visible = false;
            pnlFreelancerDash.Visible = true;

            // Quick Actions beside the welcome heading (freelancer set).
            pnlFreelancerQuick.Visible = true;
            pnlEmployerQuick.Visible = false;

            // Get freelancer's proposals
            litProposalsLabel.Text = "My Proposals";
            DataTable proposals = DatabaseHelper.GetProposalsByFreelancer(userID);
            litProposalsCount.Text = proposals != null ? proposals.Rows.Count.ToString() : "0";

            // Count available open projects
            litProjectsLabel.Text = "Open Projects";
            DataTable openProjects = DatabaseHelper.GetOpenProjects();
            litProjectsCount.Text = openProjects != null ? openProjects.Rows.Count.ToString() : "0";
        }

        private void LoadRecentActivity(int userID, string userType)
        {
            var activities = new List<ActivityItem>();

            try
            {
                // Get recent transactions as activity
                DataRow wallet = DatabaseHelper.GetWalletByUserId(userID);
                if (wallet != null)
                {
                    int walletID = Convert.ToInt32(wallet["walletID"]);
                    DataTable transactions = DatabaseHelper.GetTransactionsByWallet(walletID);
                    if (transactions != null)
                    {
                        int count = 0;
                        foreach (DataRow row in transactions.Rows)
                        {
                            if (count >= 3) break;
                            string desc = Convert.ToString(row["itemDescription"]);
                            string type = Convert.ToString(row["transactionType"]);
                            DateTime date = Convert.ToDateTime(row["transactionDate"]);
                            decimal amount = Convert.ToDecimal(row["transactionAmount"]);

                            string activityText = type == "Credit"
                                ? "Received R" + amount.ToString("N2") + " - " + desc
                                : "Paid R" + amount.ToString("N2") + " - " + desc;

                            activities.Add(new ActivityItem
                            {
                                Description = activityText,
                                DateFormatted = FormatDate(date)
                            });
                            count++;
                        }
                    }
                }

                // Get recent proposals
                if (userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
                {
                    DataTable proposals = DatabaseHelper.GetProposalsByFreelancer(userID);
                    if (proposals != null)
                    {
                        int count = 0;
                        foreach (DataRow row in proposals.Rows)
                        {
                            if (count >= 3) break;
                            string title = Convert.ToString(row["projectTitle"]);
                            string status = Convert.ToString(row["status"]);
                            DateTime date = Convert.ToDateTime(row["date"]);

                            activities.Add(new ActivityItem
                            {
                                Description = "Proposal for \"" + title + "\" - " + status,
                                DateFormatted = FormatDate(date)
                            });
                            count++;
                        }
                    }
                }
            }
            catch
            {
                // Silently handle any data errors
            }

            if (activities.Count > 5)
                activities = activities.GetRange(0, 5);

            bool isEmployer = userType.Equals("Employer", StringComparison.OrdinalIgnoreCase);
            bool hasActivity = activities.Count > 0;

            if (isEmployer)
            {
                // Bind the employer dashboard's Recent Activity card.
                rptEmpActivity.DataSource = activities;
                rptEmpActivity.DataBind();
                pnlEmpNoActivity.Visible = !hasActivity;
            }
            else
            {
                // Freelancer dashboard's Recent Activity list (unchanged behaviour).
                rptActivity.DataSource = activities;
                rptActivity.DataBind();
                pnlNoActivity.Visible = !hasActivity;
            }
        }

        private string FormatDate(DateTime date)
        {
            // Stored dates are UTC (Azure SQL). Measure age against UTC and display in SA time.
            TimeSpan diff = DateTime.UtcNow - DateTime.SpecifyKind(date, DateTimeKind.Utc);
            if (diff.TotalMinutes < 60) return ((int)diff.TotalMinutes) + " min ago";
            if (diff.TotalHours < 24) return ((int)diff.TotalHours) + "h ago";
            if (diff.TotalDays < 7) return ((int)diff.TotalDays) + "d ago";
            return TimeHelper.ToSast(date).ToString("dd MMM yyyy");
        }

        public class ActivityItem
        {
            public string Description { get; set; }
            public string DateFormatted { get; set; }
        }

        /// <summary>A single row in the employer "My Projects" dashboard card.</summary>
        public class EmployerProjectItem
        {
            public int ProjectId { get; set; }
            public string Title { get; set; }
            public string Status { get; set; }
            public string StatusClass { get; set; }
            public string BudgetFormatted { get; set; }
            public int ProposalCount { get; set; }
            public int Progress { get; set; }
        }

        /// <summary>A single row in the employer "Upcoming Deadlines" dashboard card.</summary>
        public class EmployerDeadlineItem
        {
            public string Title { get; set; }
            public DateTime Deadline { get; set; }
        }
    }
}

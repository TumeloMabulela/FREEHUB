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
                LoadDashboard();
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

            // Get employer's projects
            litProjectsLabel.Text = "My Projects";
            DataTable projects = DatabaseHelper.GetProjectsByEmployer(userID);
            litProjectsCount.Text = projects != null ? projects.Rows.Count.ToString() : "0";

            // Count proposals received on employer's projects
            litProposalsLabel.Text = "Proposals Received";
            int totalProposals = 0;
            if (projects != null)
            {
                foreach (DataRow row in projects.Rows)
                {
                    if (row["proposalCount"] != DBNull.Value)
                        totalProposals += Convert.ToInt32(row["proposalCount"]);
                }
            }
            litProposalsCount.Text = totalProposals.ToString();
        }

        private void LoadFreelancerDashboard(int userID)
        {
            pnlFreelancerActions.Visible = true;
            pnlEmployerActions.Visible = false;

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

            if (activities.Count > 0)
            {
                // Sort by most recent and take top 5
                activities.Sort((a, b) => string.Compare(b.DateFormatted, a.DateFormatted));
                if (activities.Count > 5)
                    activities = activities.GetRange(0, 5);

                rptActivity.DataSource = activities;
                rptActivity.DataBind();
                pnlNoActivity.Visible = false;
            }
            else
            {
                pnlNoActivity.Visible = true;
            }
        }

        private string FormatDate(DateTime date)
        {
            TimeSpan diff = DateTime.Now - date;
            if (diff.TotalMinutes < 60) return ((int)diff.TotalMinutes) + " min ago";
            if (diff.TotalHours < 24) return ((int)diff.TotalHours) + "h ago";
            if (diff.TotalDays < 7) return ((int)diff.TotalDays) + "d ago";
            return date.ToString("dd MMM yyyy");
        }

        public class ActivityItem
        {
            public string Description { get; set; }
            public string DateFormatted { get; set; }
        }
    }
}

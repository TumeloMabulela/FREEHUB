using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class ViewProgress : Page
    {
        private readonly string _connStr = ConfigurationManager.ConnectionStrings["FreeHubDB"]?.ConnectionString;

        protected int CurrentUserId
        {
            get { return Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0; }
        }

        public string UserType
        {
            get { return Session["UserType"] as string ?? "Freelancer"; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;

            if (!IsPostBack)
            {
                pnlMessage.Visible = false;
                litUserRoleHeader.Text = UserType;
                LoadProgressData();
            }
        }

        /// <summary>
        /// Active status filter tab. Defaults to "InProgress" so the page opens showing
        /// only projects currently in progress (as required). Persisted in ViewState so the
        /// selection survives ASP.NET postbacks.
        /// </summary>
        private string CurrentFilter
        {
            get
            {
                string f = ViewState["ProgressFilter"] as string;
                return (f == "All" || f == "Completed") ? f : "InProgress";
            }
            set { ViewState["ProgressFilter"] = value; }
        }

        private void LoadProgressData()
        {
            DataTable dt = new DataTable();
            int totalCount = 0, completedCount = 0, inProgressCount = 0;
            decimal totalPercentSum = 0;

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = "";

                if (UserType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
                {
                    // Freelancer projects assigned via approved proposals
                    query = @"
                        SELECT DISTINCT 
                            p.projectID AS ProjectId,
                            p.title AS Title,
                            p.budget AS Budget,
                            p.deadline AS Deadline,
                            p.projectStatus AS Status,
                            ISNULL(p.isStarted, 0) AS IsStarted,
                            'Client' AS PartnerLabel,
                            (u.firstName + ' ' + u.lastName) AS PartnerName,
                            e.userID AS PartnerUserId
                        FROM dbo.Proposal prop
                        INNER JOIN dbo.Project p ON prop.projectID = p.projectID
                        INNER JOIN dbo.Employer e ON p.employerID = e.employerID
                        INNER JOIN dbo.[User] u ON e.userID = u.userID
                        INNER JOIN dbo.Freelancer f ON prop.freelancerID = f.freelancerID
                        WHERE f.userID = @UserID AND prop.status = 'Approved'";
                }
                else
                {
                    // Employer projects posted by user
                    query = @"
                        SELECT 
                            p.projectID AS ProjectId,
                            p.title AS Title,
                            p.budget AS Budget,
                            p.deadline AS Deadline,
                            p.projectStatus AS Status,
                            ISNULL(p.isStarted, 0) AS IsStarted,
                            'Assigned Freelancer' AS PartnerLabel,
                            ISNULL((SELECT TOP 1 (us.firstName + ' ' + us.lastName) FROM dbo.Proposal pr INNER JOIN dbo.Freelancer fr ON pr.freelancerID = fr.freelancerID INNER JOIN dbo.[User] us ON fr.userID = us.userID WHERE pr.projectID = p.projectID AND pr.status = 'Approved'), 'Pending Assignment') AS PartnerName,
                            ISNULL((SELECT TOP 1 us.userID FROM dbo.Proposal pr INNER JOIN dbo.Freelancer fr ON pr.freelancerID = fr.freelancerID INNER JOIN dbo.[User] us ON fr.userID = us.userID WHERE pr.projectID = p.projectID AND pr.status = 'Approved'), 0) AS PartnerUserId
                        FROM dbo.Project p
                        INNER JOIN dbo.Employer e ON p.employerID = e.employerID
                        WHERE e.userID = @UserID AND p.projectStatus != 'Cancelled'";
                }

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", CurrentUserId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            dt.Columns.Add("ProgressPercent", typeof(int));

            // Compute the progress percentage for each project and tally the overall
            // (unfiltered) stats shown in the top stat cards + right-column widgets.
            foreach (DataRow row in dt.Rows)
            {
                string status = row["Status"].ToString();
                int isStarted = Convert.ToInt32(row["IsStarted"]);
                int percent = 0;

                if (status.Equals("Completed", StringComparison.OrdinalIgnoreCase))
                {
                    percent = 100;
                    completedCount++;
                }
                else if (status.Equals("Under Review", StringComparison.OrdinalIgnoreCase))
                {
                    percent = 85;
                    inProgressCount++;
                }
                else if (status.Equals("In Progress", StringComparison.OrdinalIgnoreCase))
                {
                    percent = isStarted == 1 ? 50 : 15;
                    inProgressCount++;
                }
                else
                {
                    percent = 0;
                }

                row["ProgressPercent"] = percent;
                totalPercentSum += percent;
                totalCount++;
            }

            // --- Status filter tabs (All Projects | In Progress | Completed) ---
            // Counts come straight from the full dataset (never hardcoded). "In Progress"
            // covers projects that have started but are not officially completed, i.e.
            // status 'In Progress' or 'Under Review'. "Completed" is strictly the projects
            // whose status is officially 'Completed' (not merely 100% progress).
            // "All Projects" is every eligible row already scoped to this user by the query.
            int allCount = dt.Rows.Count;
            int filterCompletedCount = completedCount;      // status == Completed
            int filterInProgressCount = inProgressCount;    // In Progress or Under Review

            lnkTabAll.Text = "All Projects <span class=\"vp-tab-count\">" + allCount + "</span>";
            lnkTabInProgress.Text = "In Progress <span class=\"vp-tab-count\">" + filterInProgressCount + "</span>";
            lnkTabCompleted.Text = "Completed <span class=\"vp-tab-count\">" + filterCompletedCount + "</span>";

            lnkTabAll.CssClass = CurrentFilter == "All" ? "vp-tab vp-tab-active" : "vp-tab";
            lnkTabInProgress.CssClass = CurrentFilter == "InProgress" ? "vp-tab vp-tab-active" : "vp-tab";
            lnkTabCompleted.CssClass = CurrentFilter == "Completed" ? "vp-tab vp-tab-active" : "vp-tab";

            // Build the filtered view for the project list + deadlines, using the existing
            // status field only (no duplication: each row is tested once).
            DataTable view = dt.Clone();
            foreach (DataRow row in dt.Rows)
            {
                string status = Convert.ToString(row["Status"]).Trim();
                bool isCompleted = status.Equals("Completed", StringComparison.OrdinalIgnoreCase);
                bool isActive = status.Equals("In Progress", StringComparison.OrdinalIgnoreCase)
                                || status.Equals("Under Review", StringComparison.OrdinalIgnoreCase);

                bool include;
                if (CurrentFilter == "Completed") include = isCompleted;
                else if (CurrentFilter == "InProgress") include = isActive;
                else include = true; // All Projects
                if (include) view.ImportRow(row);
            }

            // "Project Progress List (N)" count reflects the CURRENT filtered view.
            litListCount.Text = view.Rows.Count.ToString();

            rptProgressProjects.DataSource = view;
            rptProgressProjects.DataBind();
            rptDeadlines.DataSource = view;
            rptDeadlines.DataBind();

            // Empty-state handling: hide the scrollable list wrapper when the selected
            // filter has no projects so no empty scrollbar shows, and surface a centred,
            // filter + role aware message instead.
            bool isEmpty = view.Rows.Count == 0;
            pnlListWrap.Visible = !isEmpty;
            pnlNoProjects.Visible = isEmpty;
            if (isEmpty) SetEmptyState();

            // Bind the Progress Overview widget from the FULL (unfiltered) dataset so the
            // overview totals always reflect every eligible project regardless of the tab.
            int avgCompletion = totalCount > 0 ? (int)(totalPercentSum / totalCount) : 0;
            litPieAvg.Text = avgCompletion + "%";
            litCountCompleted.Text = $"{completedCount} ({(totalCount > 0 ? (completedCount * 100) / totalCount : 0)}%)";
            litCountInProgress.Text = $"{inProgressCount} ({(totalCount > 0 ? (inProgressCount * 100) / totalCount : 0)}%)";
        }

        /// <summary>
        /// Sets the centred empty-state heading/description for the currently selected
        /// filter, adapting the supporting text for Employer vs Freelancer accounts.
        /// </summary>
        private void SetEmptyState()
        {
            bool isEmployer = UserType.Equals("Employer", StringComparison.OrdinalIgnoreCase);

            if (CurrentFilter == "Completed")
            {
                litEmptyTitle.Text = "No completed projects.";
                litEmptyText.Text = isEmployer
                    ? "Projects that have been successfully completed will appear here."
                    : "Projects you have successfully completed will appear here.";
            }
            else if (CurrentFilter == "InProgress")
            {
                litEmptyTitle.Text = "No projects in progress.";
                litEmptyText.Text = isEmployer
                    ? "Projects currently being worked on will appear here."
                    : "Projects you are currently working on will appear here.";
            }
            else // All Projects
            {
                litEmptyTitle.Text = "No projects found.";
                litEmptyText.Text = "Your projects will appear here when they become available.";
            }
        }

        protected void FilterTab_Command(object sender, CommandEventArgs e)
        {
            string cmd = Convert.ToString(e.CommandName);
            CurrentFilter = (cmd == "All" || cmd == "Completed") ? cmd : "InProgress";
            LoadProgressData();

            // Reset the project-list scrollbar to the top whenever the filter changes.
            ClientScript.RegisterStartupScript(GetType(), "vpScrollTop",
                "var l=document.querySelector('.vp-list'); if(l){l.scrollTop=0;}", true);
        }

        protected void rptProgressProjects_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int projectId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "StartProject")
            {
                // 1. Update project status and isStarted flag in database
                string updateQuery = "UPDATE dbo.Project SET projectStatus = 'In Progress', isStarted = 1 WHERE projectID = @ProjectID";
                DatabaseHelper.ExecuteNonQuery(updateQuery, new SqlParameter("@ProjectID", projectId));

                // 2. Fetch employer ID to notify them
                string getEmpQuery = @"
                    SELECT e.userID, p.title 
                    FROM dbo.Project p 
                    INNER JOIN dbo.Employer e ON p.employerID = e.employerID 
                    WHERE p.projectID = @ProjectID";
                DataRow dr = DatabaseHelper.GetDataRow(getEmpQuery, new SqlParameter("@ProjectID", projectId));

                if (dr != null)
                {
                    int employerUserId = Convert.ToInt32(dr["userID"]);
                    string projTitle = Convert.ToString(dr["title"]);
                    string notifMsg = $"The project '{projTitle}' has been started by the freelancer and is now In Progress.";
                    NotificationHelper.CreateNotification(employerUserId, "Project", notifMsg);
                }

                ShowMessage("Project started successfully! Employer has been notified and progress updated.", true);
                LoadProgressData();
            }
            else if (e.CommandName == "GoToSubmitWork")
            {
                Response.Redirect($"SubmitWork.aspx?projectId={projectId}");
            }
            else if (e.CommandName == "ReviewWork")
            {
                // Redirects the employer to the Review Work page to approve or reject the submission
                Response.Redirect($"ReviewWork.aspx?projectId={projectId}");
            }
            else if (e.CommandName == "ViewDetails")
            {
                Response.Redirect($"ProjectDetails.aspx?id={projectId}");
            }
        }
        protected string GetStatusBadgeStyle(string status)
        {
            if (status.Equals("Completed", StringComparison.OrdinalIgnoreCase))
                return "background: #e6f4ea; color: #137333; font-size: 11px; font-weight: 600; padding: 4px 10px; border-radius: 20px;";
            if (status.Equals("Under Review", StringComparison.OrdinalIgnoreCase))
                return "background: #fef3c7; color: #d97706; font-size: 11px; font-weight: 600; padding: 4px 10px; border-radius: 20px;";
            return "background: #e8f0fe; color: #1a73e8; font-size: 11px; font-weight: 600; padding: 4px 10px; border-radius: 20px;";
        }

        protected string GetProgressBarColor(string status)
        {
            if (status.Equals("Completed", StringComparison.OrdinalIgnoreCase)) return "#137333";
            if (status.Equals("Under Review", StringComparison.OrdinalIgnoreCase)) return "#d97706";
            return "#2563eb";
        }

        protected string GetDeadlineBadgeStyle(string status, object deadlineObj)
        {
            if (status.Equals("Completed", StringComparison.OrdinalIgnoreCase))
                return "background: #e6f4ea; color: #137333; font-size: 10px; font-weight: 700; padding: 3px 8px; border-radius: 12px;";

            DateTime deadline;
            if (DateTime.TryParse(deadlineObj?.ToString(), out deadline))
            {
                int daysLeft = (deadline - DateTime.Now).Days;
                if (daysLeft <= 3)
                    return "background: #fee2e2; color: #dc2626; font-size: 10px; font-weight: 700; padding: 3px 8px; border-radius: 12px;";
                return "background: #fef3c7; color: #d97706; font-size: 10px; font-weight: 700; padding: 3px 8px; border-radius: 12px;";
            }
            return "background: #f3f4f6; color: #374151; font-size: 10px; font-weight: 700; padding: 3px 8px; border-radius: 12px;";
        }

        protected string GetDeadlineLabel(string status, object deadlineObj)
        {
            if (status.Equals("Completed", StringComparison.OrdinalIgnoreCase)) return "Completed";

            DateTime deadline;
            if (DateTime.TryParse(deadlineObj?.ToString(), out deadline))
            {
                int daysLeft = (deadline - DateTime.Now).Days;
                if (daysLeft < 0) return "Overdue";
                if (daysLeft == 0) return "Due Today";
                return $"{daysLeft} days left";
            }
            return "Pending";
        }

        private void ShowMessage(string message, bool success)
        {
            if (success) MessageHelper.Success(this, message);
            else MessageHelper.Error(this, message);
        }
    }
}
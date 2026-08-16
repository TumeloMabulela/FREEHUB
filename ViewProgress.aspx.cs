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

            rptProgressProjects.DataSource = dt;
            rptProgressProjects.DataBind();
            rptDeadlines.DataSource = dt;
            rptDeadlines.DataBind();

            lblNoProjects.Visible = (totalCount == 0);

            // Bind Stats & Pie Chart
            litStatTotal.Text = totalCount.ToString();
            litStatCompleted.Text = completedCount.ToString();
            litStatActive.Text = inProgressCount.ToString();

            int avgCompletion = totalCount > 0 ? (int)(totalPercentSum / totalCount) : 0;
            litStatAvgCompletion.Text = avgCompletion + "%";
            litPieAvg.Text = avgCompletion + "%";
            litCountCompleted.Text = $"{completedCount} ({(totalCount > 0 ? (completedCount * 100) / totalCount : 0)}%)";
            litCountInProgress.Text = $"{inProgressCount} ({(totalCount > 0 ? (inProgressCount * 100) / totalCount : 0)}%)";
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
                Response.Redirect($"ProjectDetails.aspx?id={projectId}");
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

        protected void btnViewAllProjects_Click(object sender, EventArgs e)
        {
            Response.Redirect(UserType.Equals("Employer", StringComparison.OrdinalIgnoreCase) ? "MyProjects.aspx" : "BrowseProjects.aspx");
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = message;
            pnlMessage.Style["background-color"] = success ? "#d1fae5" : "#fee2e2";
            pnlMessage.Style["color"] = success ? "#065f46" : "#991b1b";
        }
    }
}
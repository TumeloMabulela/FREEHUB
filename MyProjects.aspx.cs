using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class MyProjects : System.Web.UI.Page
    {
        /// <summary>
        /// Active status filter pill: "All" (default), "Active", "Completed" or "Cancelled".
        /// Stored in ViewState so it survives postbacks (sort change, delete) — mirrors the
        /// Select Proposal page's filter pattern.
        /// </summary>
        private string CurrentFilter
        {
            get
            {
                string f = ViewState["ProjectFilter"] as string;
                return (f == "Active" || f == "Completed" || f == "Cancelled") ? f : "All";
            }
            set { ViewState["ProjectFilter"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Employer only - Freelancers cannot access My Projects
            string userType = Session["UserType"] as string ?? "";
            if (userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Allow an initial filter via query string (back-compat with old ?view= links).
                string view = Request.QueryString["view"];
                if (string.Equals(view, "Completed", StringComparison.OrdinalIgnoreCase)) CurrentFilter = "Completed";
                else if (string.Equals(view, "Cancelled", StringComparison.OrdinalIgnoreCase)) CurrentFilter = "Cancelled";
                else if (string.Equals(view, "Active", StringComparison.OrdinalIgnoreCase)) CurrentFilter = "Active";

                // Restore the saved sort preference so it persists across visits.
                string savedSort = Session["MyProjectsSort"] as string;
                if (savedSort == "Oldest" || savedSort == "Newest")
                {
                    System.Web.UI.WebControls.ListItem item = ddlSortProjects.Items.FindByValue(savedSort);
                    if (item != null)
                    {
                        ddlSortProjects.ClearSelection();
                        item.Selected = true;
                    }
                }

                LoadProjects();
            }
        }

        /// <summary>Current sort direction from the dropdown (defaults to Newest).</summary>
        private string CurrentSort
        {
            get { return ddlSortProjects.SelectedValue == "Oldest" ? "Oldest" : "Newest"; }
        }

        private void LoadProjects()
        {
            int userId = Convert.ToInt32(Session["UserID"]);

            try
            {
                // Fetch all projects for the employer.
                DataTable allProjects = DatabaseHelper.GetProjectsByEmployer(userId);

                int totalCount = allProjects.Rows.Count;
                int activeCount = 0, completedCount = 0, cancelledCount = 0;

                foreach (DataRow row in allProjects.Rows)
                {
                    string status = Convert.ToString(row["projectStatus"]);

                    // Include 'Under Review' in Active project counts.
                    if (status == "Open" || status == "In Progress" || status == "Under Review")
                    {
                        activeCount++;
                    }
                    else if (status == "Completed")
                    {
                        completedCount++;
                    }
                    else if (status == "Cancelled")
                    {
                        cancelledCount++;
                    }
                }

                // Set each pill's label + count badge as inline HTML on the LinkButton Text
                // so the labels/counts can never be lost across postbacks. Counts are always
                // from the employer's own full result set (never hardcoded).
                pnlFilterTabs.Visible = true;
                lnkTabAll.Text = "All Projects <span class=\"mp-tab-count\">" + totalCount + "</span>";
                lnkTabActive.Text = "Active <span class=\"mp-tab-count\">" + activeCount + "</span>";
                lnkTabCompleted.Text = "Completed <span class=\"mp-tab-count\">" + completedCount + "</span>";
                lnkTabCancelled.Text = "Cancelled <span class=\"mp-tab-count\">" + cancelledCount + "</span>";

                // Highlight the active pill (FreeHUB green).
                lnkTabAll.CssClass = CurrentFilter == "All" ? "mp-tab mp-tab-active" : "mp-tab";
                lnkTabActive.CssClass = CurrentFilter == "Active" ? "mp-tab mp-tab-active" : "mp-tab";
                lnkTabCompleted.CssClass = CurrentFilter == "Completed" ? "mp-tab mp-tab-active" : "mp-tab";
                lnkTabCancelled.CssClass = CurrentFilter == "Cancelled" ? "mp-tab mp-tab-active" : "mp-tab";

                // Build the filtered view for the selected pill (each row tested once).
                DataTable filtered = allProjects.Clone();
                foreach (DataRow row in allProjects.Rows)
                {
                    string status = Convert.ToString(row["projectStatus"]);
                    bool include;

                    switch (CurrentFilter)
                    {
                        case "Active":
                            // Open, In Progress AND Under Review are all "active".
                            include = (status == "Open" || status == "In Progress" || status == "Under Review");
                            break;

                        case "Completed":
                            include = (status == "Completed");
                            break;

                        case "Cancelled":
                            include = (status == "Cancelled");
                            break;

                        default: // All Projects — every project regardless of status.
                            include = true;
                            break;
                    }

                    if (include)
                    {
                        filtered.ImportRow(row);
                    }
                }

                // Sort by the ACTUAL posting DateTime (not a formatted string), with projectID
                // as a stable tie-breaker. Newest First = DESC, Oldest First = ASC.
                string direction = CurrentSort == "Oldest" ? "ASC" : "DESC";
                DataView dv = filtered.DefaultView;
                dv.Sort = "dateCreated " + direction + ", projectID " + direction;
                DataTable sorted = dv.ToTable();

                rptProjects.DataSource = sorted;
                rptProjects.DataBind();

                // "Projects (N)" count reflects the CURRENT filtered view.
                lblProjectCount.Text = sorted.Rows.Count.ToString();

                // Toggle list vs empty-state (mutually exclusive).
                bool isEmpty = (sorted.Rows.Count == 0);
                pnlProjectList.Visible = !isEmpty;
                pnlEmptyProjects.Visible = isEmpty;

                if (isEmpty)
                {
                    switch (CurrentFilter)
                    {
                        case "Active":
                            litEmptyTitle.Text = "No Active Projects";
                            litEmptyText.Text = "Projects that are open or in progress will appear here.";
                            break;
                        case "Completed":
                            litEmptyTitle.Text = "No Completed Projects";
                            litEmptyText.Text = "Projects you complete will appear here.";
                            break;
                        case "Cancelled":
                            litEmptyTitle.Text = "No Cancelled Projects";
                            litEmptyText.Text = "Projects you cancel will appear here.";
                            break;
                        default:
                            litEmptyTitle.Text = "No Projects Yet";
                            litEmptyText.Text = "Projects you post will appear here.";
                            break;
                    }
                }
            }
            catch
            {
                pnlProjectList.Visible = false;
                pnlEmptyProjects.Visible = true;
                litEmptyTitle.Text = "No projects found";
                litEmptyText.Text = "There are no projects available in this section.";
                lblProjectCount.Text = "0";
                lnkTabAll.Text = "All Projects <span class=\"mp-tab-count\">0</span>";
                lnkTabActive.Text = "Active <span class=\"mp-tab-count\">0</span>";
                lnkTabCompleted.Text = "Completed <span class=\"mp-tab-count\">0</span>";
                lnkTabCancelled.Text = "Cancelled <span class=\"mp-tab-count\">0</span>";
            }
        }

        protected void FilterTab_Command(object sender, System.Web.UI.WebControls.CommandEventArgs e)
        {
            string cmd = Convert.ToString(e.CommandName);
            CurrentFilter = (cmd == "Active" || cmd == "Completed" || cmd == "Cancelled") ? cmd : "All";
            LoadProjects();

            // Reset the project list scrollbar to the top on filter switch; the main page
            // scroll position is left untouched.
            ClientScript.RegisterStartupScript(GetType(), "mpScrollTop",
                "var l=document.querySelector('.mp-list'); if(l){l.scrollTop=0;}", true);
        }

        protected void ddlSortProjects_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            // Remember the choice so it carries across filter switches and future visits.
            Session["MyProjectsSort"] = CurrentSort;
            LoadProjects();

            // Reset the project list scrollbar to the top so the first item in the new
            // order is visible; the main page scroll position is left untouched.
            ClientScript.RegisterStartupScript(GetType(), "mpScrollTop",
                "var l=document.querySelector('.mp-list'); if(l){l.scrollTop=0;}", true);
        }

        protected void rptProjects_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteProject")
            {
                int projectId = Convert.ToInt32(e.CommandArgument);
                try
                {
                    // Delete ALL related records first
                    DatabaseHelper.ExecuteNonQuery("DELETE FROM Comment WHERE projectID = @ID",
                        new System.Data.SqlClient.SqlParameter("@ID", projectId));
                    DatabaseHelper.ExecuteNonQuery("DELETE FROM Proposal WHERE projectID = @ID",
                        new System.Data.SqlClient.SqlParameter("@ID", projectId));
                    DatabaseHelper.ExecuteNonQuery("DELETE FROM Rating WHERE projectID = @ID",
                        new System.Data.SqlClient.SqlParameter("@ID", projectId));
                    DatabaseHelper.ExecuteNonQuery("DELETE FROM Dispute WHERE projectID = @ID",
                        new System.Data.SqlClient.SqlParameter("@ID", projectId));
                    DatabaseHelper.ExecuteNonQuery("DELETE FROM ChatSession WHERE projectID = @ID",
                        new System.Data.SqlClient.SqlParameter("@ID", projectId));
                    // Now delete the project
                    DatabaseHelper.ExecuteNonQuery("DELETE FROM Project WHERE projectID = @ID",
                        new System.Data.SqlClient.SqlParameter("@ID", projectId));
                }
                catch { }
                LoadProjects();
            }
        }

        /// <summary>
        /// Maps an existing project status to its badge CSS class (display colour only).
        /// Does not change or add any status values or business logic.
        /// </summary>
        protected string GetStatusClass(object status)
        {
            string s = Convert.ToString(status).Trim().ToLowerInvariant();
            switch (s)
            {
                case "open": return "mp-status-open";
                case "in progress": return "mp-status-progress";
                case "under review": return "mp-status-review";
                case "completed": return "mp-status-completed";
                case "cancelled": return "mp-status-cancelled";
                default: return "mp-status-default";
            }
        }
    }
}

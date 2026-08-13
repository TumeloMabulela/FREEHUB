using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class MyProjects : System.Web.UI.Page
    {
        protected string SelectedView
        {
            get
            {
                string view = Request.QueryString["view"];
                if (string.Equals(view, "Completed", StringComparison.OrdinalIgnoreCase)) return "Completed";
                if (string.Equals(view, "Cancelled", StringComparison.OrdinalIgnoreCase)) return "Cancelled";
                return "Active";
            }
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
                LoadProjects();
            }
        }

        private void LoadProjects()
        {
            int userId = Convert.ToInt32(Session["UserID"]);

            try
            {
                // Get counts
                DataTable allProjects = DatabaseHelper.GetProjectsByEmployer(userId);
                int activeCount = 0, completedCount = 0, cancelledCount = 0;

                foreach (DataRow row in allProjects.Rows)
                {
                    string status = Convert.ToString(row["projectStatus"]);
                    if (status == "Open" || status == "In Progress") activeCount++;
                    else if (status == "Completed") completedCount++;
                    else if (status == "Cancelled") cancelledCount++;
                }

                lblActiveCount.Text = activeCount.ToString();
                lblCompletedCount.Text = completedCount.ToString();
                lblCancelledCount.Text = cancelledCount.ToString();

                // Filter by selected view
                DataTable filtered = allProjects.Clone();
                foreach (DataRow row in allProjects.Rows)
                {
                    string status = Convert.ToString(row["projectStatus"]);
                    bool include = false;

                    switch (SelectedView)
                    {
                        case "Completed":
                            include = status == "Completed";
                            break;
                        case "Cancelled":
                            include = status == "Cancelled";
                            break;
                        default: // Active
                            include = status == "Open" || status == "In Progress";
                            break;
                    }

                    if (include) filtered.ImportRow(row);
                }

                rptProjects.DataSource = filtered;
                rptProjects.DataBind();

                // Show/hide panels
                pnlProjectList.Visible = filtered.Rows.Count > 0;
                pnlEmptyProjects.Visible = filtered.Rows.Count == 0;

                // Set section title
                lblSectionTitle.Text = SelectedView == "Completed" ? "Completed Projects" :
                                       SelectedView == "Cancelled" ? "Cancelled Projects" : "Active Projects";
            }
            catch (Exception ex)
            {
                pnlProjectList.Visible = false;
                pnlEmptyProjects.Visible = true;
                lblSectionTitle.Text = "Active Projects";
                lblActiveCount.Text = "0";
                lblCompletedCount.Text = "0";
                lblCancelledCount.Text = "0";
            }
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

                    // Notify self about deletion
                    int userId = Convert.ToInt32(Session["UserID"]);
                    DatabaseHelper.SendNotification(userId, "Project", "You have deleted a project successfully.");
                }
                catch { }
                LoadProjects();
            }
        }

        protected string GetTabClass(string viewName)
        {
            return string.Equals(SelectedView, viewName, StringComparison.OrdinalIgnoreCase)
                ? "my-projects-tab my-projects-tab-active"
                : "my-projects-tab";
        }

        protected string GetMiniMenuClass(string viewName)
        {
            return string.Equals(SelectedView, viewName, StringComparison.OrdinalIgnoreCase)
                ? "my-projects-mini-active" : "";
        }
    }
}

using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class BrowseProjects : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProjects();
            }
        }

        private void LoadProjects()
        {
            try
            {
                DataTable projects = DatabaseHelper.GetOpenProjects();

                if (projects.Rows.Count == 0)
                {
                    pnlNoProjects.Visible = true;
                    lblFilterMessage.Text = "";
                }
                else
                {
                    pnlNoProjects.Visible = false;
                    lblFilterMessage.Text = projects.Rows.Count + " open project(s) found";
                }

                rptProjects.DataSource = projects;
                rptProjects.DataBind();
            }
            catch (Exception ex)
            {
                pnlNoProjects.Visible = true;
                lblFilterMessage.Text = "Error loading projects: " + ex.Message;
            }
        }

        protected void rptProjects_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectProject")
            {
                int projectId = Convert.ToInt32(e.CommandArgument);
                LoadProjectDetails(projectId);
            }
        }

        private void LoadProjectDetails(int projectId)
        {
            try
            {
                DataRow project = DatabaseHelper.GetProjectById(projectId);

                if (project == null)
                {
                    lblProjectMessage.Text = "Project not found.";
                    return;
                }

                // Show details panel
                pnlNoSelection.Visible = false;
                pnlProjectDetails.Visible = true;

                // Fill in details
                lblProjectTitle.Text = Convert.ToString(project["title"]);
                lblPosted.Text = "Posted " + Convert.ToDateTime(project["dateCreated"]).ToString("dd MMM yyyy");
                lblDescription.Text = Convert.ToString(project["description"]);
                lblBudget.Text = "R" + Convert.ToDecimal(project["budget"]).ToString("N2") + " (" + Convert.ToString(project["budgetType"]) + ")";
                lblDeadline.Text = Convert.ToDateTime(project["deadline"]).ToString("dd MMM yyyy");
                lblCategory.Text = Convert.ToString(project["category"]);
                lblExperience.Text = Convert.ToString(project["experienceLevel"]);
                lblEmployerName.Text = Convert.ToString(project["employerName"]);
                lblEmployerDetails.Text = Convert.ToString(project["companyName"]);
                lblEmployerRating.Text = "Verified Employer";

                // Initials
                string name = Convert.ToString(project["employerName"]);
                string initials = "";
                string[] parts = name.Split(' ');
                foreach (string part in parts)
                {
                    if (part.Length > 0) initials += part[0];
                }
                lblEmployerInitials.Text = initials.ToUpper();

                // Store for submit proposal
                ViewState["SelectedProjectId"] = projectId;
                lblProjectMessage.Text = "";
            }
            catch (Exception ex)
            {
                lblProjectMessage.Text = "Error: " + ex.Message;
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            try
            {
                string query = @"SELECT p.projectID, p.title, p.description, p.category, p.budget,
                                p.budgetType, p.dateCreated, p.deadline, p.projectStatus,
                                p.experienceLevel, p.skills, e.companyName,
                                u.firstName + ' ' + u.lastName AS employerName
                                FROM Project p
                                INNER JOIN Employer e ON p.employerID = e.employerID
                                INNER JOIN [User] u ON e.userID = u.userID
                                WHERE p.projectStatus = 'Open'";

                // Category filter
                if (!string.IsNullOrEmpty(ddlCategory.SelectedValue))
                {
                    query += " AND p.category = '" + ddlCategory.SelectedValue.Replace("'", "''") + "'";
                }

                // Budget filter
                if (!string.IsNullOrEmpty(ddlBudget.SelectedValue))
                {
                    string[] range = ddlBudget.SelectedValue.Split('-');
                    if (range.Length == 2)
                    {
                        query += " AND p.budget >= " + range[0] + " AND p.budget <= " + range[1];
                    }
                }

                // Date filter
                if (!string.IsNullOrEmpty(ddlDate.SelectedValue))
                {
                    int days = Convert.ToInt32(ddlDate.SelectedValue);
                    query += " AND p.dateCreated >= DATEADD(day, -" + days + ", GETDATE())";
                }

                query += " ORDER BY p.dateCreated DESC";

                DataTable results = DatabaseHelper.ExecuteQuery(query);

                rptProjects.DataSource = results;
                rptProjects.DataBind();

                pnlNoProjects.Visible = results.Rows.Count == 0;
                lblFilterMessage.Text = results.Rows.Count + " project(s) found";
            }
            catch (Exception ex)
            {
                lblFilterMessage.Text = "Filter error: " + ex.Message;
            }
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            ddlCategory.SelectedIndex = 0;
            ddlBudget.SelectedIndex = 0;
            ddlDate.SelectedIndex = 0;
            LoadProjects();
        }

        protected void btnSubmitProposal_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (ViewState["SelectedProjectId"] != null)
            {
                Response.Redirect("SubmitProposal.aspx?projectId=" + ViewState["SelectedProjectId"]);
            }
            else
            {
                lblProjectMessage.Text = "Please select a project first.";
            }
        }

        protected void btnSaveProject_Click(object sender, EventArgs e)
        {
            lblProjectMessage.Text = "Project saved to your list.";
        }
    }
}

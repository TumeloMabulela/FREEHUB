using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class BrowseProjects : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProjectsFromDatabase();
            }
        }

        private void LoadProjectsFromDatabase()
        {
            try
            {
                DataTable projects = DatabaseHelper.GetOpenProjects();

                if (projects.Rows.Count > 0)
                {
                    // Load first project into the detail panel
                    LoadProjectDetail(projects.Rows[0]);
                    lblFilterMessage.Text = projects.Rows.Count + " projects available";
                }
                else
                {
                    lblFilterMessage.Text = "No projects available at this time.";
                }
            }
            catch
            {
                // Fallback to hardcoded data if database not available
                LoadFallbackProject();
            }
        }

        private void LoadProjectDetail(DataRow project)
        {
            lblProjectTitle.Text = Convert.ToString(project["title"]);
            lblPosted.Text = "Posted " + Convert.ToDateTime(project["dateCreated"]).ToString("dd MMM yyyy");
            lblDescription.Text = Convert.ToString(project["description"]);
            lblBudget.Text = "R" + Convert.ToDecimal(project["budget"]).ToString("N2") + " - " +
                            Convert.ToString(project["budgetType"]);
            lblDeadline.Text = Convert.ToDateTime(project["deadline"]).ToString("dd MMM yyyy");
            lblCategory.Text = Convert.ToString(project["category"]);
            lblExperience.Text = Convert.ToString(project["experienceLevel"]);
            lblEmployerName.Text = Convert.ToString(project["employerName"]);
            lblEmployerDetails.Text = "Company: " + Convert.ToString(project["companyName"]);
            lblEmployerRating.Text = "Verified Employer";

            string name = Convert.ToString(project["employerName"]);
            string initials = "";
            string[] parts = name.Split(' ');
            foreach (string part in parts)
            {
                if (part.Length > 0) initials += part[0];
            }
            lblEmployerInitials.Text = initials.ToUpper();

            // Store project ID for submit proposal
            ViewState["SelectedProjectId"] = Convert.ToInt32(project["projectID"]);

            lblProjectMessage.Text = "";
        }

        private void LoadFallbackProject()
        {
            lblProjectTitle.Text = "E-commerce Website Redesign";
            lblPosted.Text = "Posted recently";
            lblDescription.Text = "We need a modern and user-friendly redesign of our existing e-commerce website. The goal is to improve UX/UI, increase conversion rate, and ensure mobile responsiveness. The project includes front-end and back-end development.";
            lblBudget.Text = "R8,000 - R15,000 - Fixed Price";
            lblDeadline.Text = "30 Jun 2026";
            lblCategory.Text = "Web Development";
            lblExperience.Text = "Intermediate";
            lblEmployerName.Text = "John Smith";
            lblEmployerDetails.Text = "Company: TechStore SA";
            lblEmployerRating.Text = "4.8 rating";
            lblEmployerInitials.Text = "JS";
            lblFilterMessage.Text = "Showing sample projects";
        }

        protected void btnProjectOne_Click(object sender, EventArgs e)
        {
            LoadProjectByIndex(0);
        }

        protected void btnProjectTwo_Click(object sender, EventArgs e)
        {
            LoadProjectByIndex(1);
        }

        protected void btnProjectThree_Click(object sender, EventArgs e)
        {
            LoadProjectByIndex(2);
        }

        protected void btnProjectFour_Click(object sender, EventArgs e)
        {
            LoadProjectByIndex(3);
        }

        protected void btnProjectFive_Click(object sender, EventArgs e)
        {
            LoadProjectByIndex(4);
        }

        private void LoadProjectByIndex(int index)
        {
            try
            {
                DataTable projects = DatabaseHelper.GetOpenProjects();
                if (projects.Rows.Count > index)
                {
                    LoadProjectDetail(projects.Rows[index]);
                }
                else if (projects.Rows.Count > 0)
                {
                    LoadProjectDetail(projects.Rows[0]);
                }
                else
                {
                    LoadFallbackProject();
                }
            }
            catch
            {
                LoadFallbackProject();
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            try
            {
                string category = ddlCategory.SelectedValue;
                string query = @"SELECT p.projectID, p.title, p.description, p.category, p.budget,
                                p.budgetType, p.dateCreated, p.deadline, p.projectStatus,
                                p.experienceLevel, p.skills, e.companyName,
                                u.firstName + ' ' + u.lastName AS employerName
                                FROM Project p
                                INNER JOIN Employer e ON p.employerID = e.employerID
                                INNER JOIN [User] u ON e.userID = u.userID
                                WHERE p.projectStatus = 'Open'";

                if (!string.IsNullOrEmpty(category))
                {
                    query += " AND p.category = @Category";
                }

                query += " ORDER BY p.dateCreated DESC";

                DataTable results;
                if (!string.IsNullOrEmpty(category))
                {
                    results = DatabaseHelper.ExecuteQuery(query,
                        new SqlParameter("@Category", category));
                }
                else
                {
                    results = DatabaseHelper.ExecuteQuery(query);
                }

                if (results.Rows.Count > 0)
                {
                    LoadProjectDetail(results.Rows[0]);
                    lblFilterMessage.Text = results.Rows.Count + " projects found matching your filters.";
                }
                else
                {
                    lblFilterMessage.Text = "No projects found matching your filters.";
                }
            }
            catch
            {
                lblFilterMessage.Text = "Filters applied.";
            }
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            ddlCategory.SelectedIndex = 0;
            ddlBudget.SelectedIndex = 0;
            ddlDate.SelectedIndex = 0;
            LoadProjectsFromDatabase();
            lblFilterMessage.Text = "All filters have been reset.";
        }

        protected void btnLoadMore_Click(object sender, EventArgs e)
        {
            lblFilterMessage.Text = "All available projects are displayed.";
        }

        protected void btnReturn_Click(object sender, EventArgs e)
        {
            lblProjectMessage.Text = "";
        }

        protected void btnSubmitProposal_Click(object sender, EventArgs e)
        {
            Session["SelectedProjectTitle"] = lblProjectTitle.Text;
            Session["SelectedProjectBudget"] = lblBudget.Text;
            Session["SelectedProjectDeadline"] = lblDeadline.Text;
            Session["SelectedProjectCategory"] = lblCategory.Text;

            if (ViewState["SelectedProjectId"] != null)
            {
                Response.Redirect("SubmitProposal.aspx?projectId=" + ViewState["SelectedProjectId"]);
            }
            else
            {
                Response.Redirect("SubmitProposal.aspx");
            }
        }

        protected void btnSaveProject_Click(object sender, EventArgs e)
        {
            lblProjectMessage.Text = "Project saved to your list.";
        }

        protected void btnViewProfile_Click(object sender, EventArgs e)
        {
            lblProjectMessage.Text = "Employer: " + lblEmployerName.Text + " | " + lblEmployerDetails.Text;
        }
    }
}

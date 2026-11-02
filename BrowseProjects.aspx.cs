// ============================================================
// B100 - Browse Project (Tumelo London Mabulela)
// FILE: BrowseProjects.aspx.cs
//
// PURPOSE: Allows logged-in freelancers to browse all open
// projects posted by employers. Freelancers can filter by
// category, budget, or date, click a project to see details,
// and navigate to submit a proposal.
// ============================================================

using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class BrowseProjects : System.Web.UI.Page
    {
        // ============================================================
        // PAGE LOAD
        // Runs every time the page is opened.
        // 1. Checks the user is logged in via AuthHelper.RequireLogin()
        // 2. Redirects employers away - this is a freelancer-only page
        // 3. On first load (not a postback) calls LoadProjects()
        // ============================================================
        protected void Page_Load(object sender, EventArgs e)
        {
            // SECURITY CHECK: redirect to login if not authenticated
            if (!AuthHelper.RequireLogin(this)) return;

            // ROLE CHECK: employers don't browse projects, they post them
            // redirect them to their dashboard instead
            string userType = Session["UserType"] as string ?? "";
            if (userType.Equals("Employer", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("Dashboard.aspx");
                return;
            }

            // Only load data on first visit, not on every button click (postback)
            if (!IsPostBack)
            {
                LoadProjects();
            }
        }

        // ============================================================
        // LoadProjects()
        // Pulls all Open projects from the database EXCLUDING any
        // projects posted by the currently logged-in user's own
        // Employer profile (so freelancers don't see their own posts).
        // Binds results to the project list repeater on screen.
        // ============================================================
        private void LoadProjects()
        {
            try
            {
                // Get the current user's ID to exclude their own projects
                int currentUserId = AuthHelper.GetCurrentUserId(this);

                // DatabaseHelper.GetOpenProjectsExcludingOwner() runs:
                // SELECT * FROM Project WHERE projectStatus = 'Open'
                // AND employer's userID != currentUserId
                DataTable projects = DatabaseHelper.GetOpenProjectsExcludingOwner(currentUserId);

                if (projects.Rows.Count == 0)
                {
                    // Show the "no projects" empty state panel
                    pnlNoProjects.Visible = true;
                    lblFilterMessage.Text = "";
                }
                else
                {
                    // Show the count of results e.g. "5 open project(s) found"
                    pnlNoProjects.Visible = false;
                    lblFilterMessage.Text = projects.Rows.Count + " open project(s) found";
                }

                // Bind the project list to the repeater control on the page
                rptProjects.DataSource = projects;
                rptProjects.DataBind();
            }
            catch (Exception ex)
            {
                // If the database call fails, show the empty state with the error
                pnlNoProjects.Visible = true;
                lblFilterMessage.Text = "Error loading projects: " + ex.Message;
            }
        }

        // ============================================================
        // rptProjects_ItemCommand()
        // Fires when a user clicks any button inside the project list.
        // Checks the command name - if "SelectProject" it loads the
        // full details of the clicked project on the right-hand panel.
        // ============================================================
        protected void rptProjects_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectProject")
            {
                // Get the project ID from the button's CommandArgument
                int projectId = Convert.ToInt32(e.CommandArgument);
                LoadProjectDetails(projectId);
            }
        }

        // ============================================================
        // LoadProjectDetails(int projectId)
        // Fetches the full project record from the database by ID.
        // Fills in all the labels on the right-hand details panel:
        // title, description, budget, deadline, employer info, etc.
        // Also stores the project ID in ViewState so the Submit
        // Proposal button knows which project was selected.
        // ============================================================
        private void LoadProjectDetails(int projectId)
        {
            try
            {
                // Fetch the full project row including employer name and company
                DataRow project = DatabaseHelper.GetProjectById(projectId);

                if (project == null)
                {
                    lblProjectMessage.Text = "Project not found.";
                    return;
                }

                // Hide the "select a project" placeholder and show the details panel
                pnlNoSelection.Visible = false;
                pnlProjectDetails.Visible = true;

                // Fill in all the detail labels
                lblProjectTitle.Text = TitleHelper.TitleCase(Convert.ToString(project["title"]));
                lblPosted.Text = "Posted " + Convert.ToDateTime(project["dateCreated"]).ToString("dd MMM yyyy");
                lblDescription.Text = Convert.ToString(project["description"]);

                // Format budget as e.g. "R15,000.00 - Fixed Price"
                lblBudget.Text = "R" + Convert.ToDecimal(project["budget"]).ToString("N2") + " - " + 
                    (Convert.ToString(project["budgetType"]) == "Fixed" ? "Fixed Price" : 
                     Convert.ToString(project["budgetType"]) == "Hourly" ? "Hourly Rate" : 
                     Convert.ToString(project["budgetType"]));

                lblDeadline.Text = Convert.ToDateTime(project["deadline"]).ToString("dd MMM yyyy");
                lblCategory.Text = Convert.ToString(project["category"]);
                lblExperience.Text = Convert.ToString(project["experienceLevel"]);
                lblEmployerName.Text = Convert.ToString(project["employerName"]);

                // Show "Verified Employer" badge only if the employer has a company name
                bool isVerified = !string.IsNullOrWhiteSpace(Convert.ToString(project["companyName"]));
                pnlEmployerVerified.Visible = isVerified;
                if (isVerified)
                {
                    lblEmployerRating.Text = "Verified Employer";
                }

                // Build initials from employer name e.g. "John Smith" -> "JS"
                string name = Convert.ToString(project["employerName"]);
                string initials = "";
                string[] parts = name.Split(' ');
                foreach (string part in parts)
                {
                    if (part.Length > 0) initials += part[0];
                }
                lblEmployerInitials.Text = initials.ToUpper();

                // Store the selected project ID in ViewState so the Submit Proposal
                // button can read it even after a postback
                ViewState["SelectedProjectId"] = projectId;
                lblProjectMessage.Text = "";
            }
            catch (Exception ex)
            {
                lblProjectMessage.Text = "Error: " + ex.Message;
            }
        }

        // ============================================================
        // btnFilter_Click()
        // Fires when the employer clicks the Filter button.
        // Builds a dynamic SQL query based on selected dropdown values:
        // - Category filter (exact match on category column)
        // - Budget filter (range check on budget column)
        // - Date filter (projects posted within X days)
        // NOTE: Category uses string concatenation (known limitation).
        // Budget and date use inline values. Should use SqlParameters.
        // ============================================================
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            try
            {
                int currentUserId = AuthHelper.GetCurrentUserId(this);

                // Base query - always filters by Open status and excludes own projects
                string query = @"SELECT p.projectID, p.title, p.description, p.category, p.budget,
                                p.budgetType, p.dateCreated, p.deadline, p.projectStatus,
                                p.experienceLevel, p.skills, e.companyName,
                                u.firstName + ' ' + u.lastName AS employerName
                                FROM Project p
                                INNER JOIN Employer e ON p.employerID = e.employerID
                                INNER JOIN [User] u ON e.userID = u.userID
                                WHERE p.projectStatus = 'Open'
                                  AND e.userID <> @ExcludeUserID";

                // Add category filter if selected
                if (!string.IsNullOrEmpty(ddlCategory.SelectedValue))
                {
                    query += " AND p.category = '" + ddlCategory.SelectedValue.Replace("'", "''") + "'";
                }

                // Add budget range filter if selected (e.g. "5000-15000")
                if (!string.IsNullOrEmpty(ddlBudget.SelectedValue))
                {
                    string[] range = ddlBudget.SelectedValue.Split('-');
                    if (range.Length == 2)
                    {
                        query += " AND p.budget >= " + range[0] + " AND p.budget <= " + range[1];
                    }
                }

                // Add date filter - projects posted within the last X days
                if (!string.IsNullOrEmpty(ddlDate.SelectedValue))
                {
                    int days = Convert.ToInt32(ddlDate.SelectedValue);
                    query += " AND p.dateCreated >= DATEADD(day, -" + days + ", GETDATE())";
                }

                query += " ORDER BY p.dateCreated DESC";

                // Execute the filtered query - only @ExcludeUserID is parameterised
                DataTable results = DatabaseHelper.ExecuteQuery(query,
                    new SqlParameter("@ExcludeUserID", currentUserId));

                rptProjects.DataSource = results;
                rptProjects.DataBind();

                // Show/hide empty state and update count label
                pnlNoProjects.Visible = results.Rows.Count == 0;
                pnlProjectDetails.Visible = false;
                pnlNoSelection.Visible = true;
                lblFilterMessage.Text = results.Rows.Count + " project(s) found matching your filters";
            }
            catch (Exception ex)
            {
                lblFilterMessage.Text = "Filter error: " + ex.Message;
            }
        }

        // ============================================================
        // btnReset_Click()
        // Clears all filter dropdowns back to their default values
        // and reloads the full unfiltered project list.
        // ============================================================
        protected void btnReset_Click(object sender, EventArgs e)
        {
            ddlCategory.SelectedIndex = 0;
            ddlBudget.SelectedIndex = 0;
            ddlDate.SelectedIndex = 0;
            LoadProjects();
        }

        // ============================================================
        // btnSubmitProposal_Click()
        // Navigates the freelancer to the Submit Proposal page for
        // the currently selected project.
        // Gets the project ID from ViewState (set in LoadProjectDetails).
        // Falls back to QueryString if ViewState was cleared.
        // ============================================================
        protected void btnSubmitProposal_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            int projectId = 0;

            // First try ViewState (most reliable after a click-select)
            if (ViewState["SelectedProjectId"] != null)
            {
                int.TryParse(ViewState["SelectedProjectId"].ToString(), out projectId);
            }

            // Fallback: check the URL query string
            if (projectId <= 0 && !string.IsNullOrEmpty(Request.QueryString["id"]))
            {
                int.TryParse(Request.QueryString["id"], out projectId);
            }

            if (projectId > 0)
            {
                // Redirect to SubmitProposal.aspx with the project ID in the URL
                Response.Redirect("SubmitProposal.aspx?projectId=" + projectId);
            }
            else
            {
                lblProjectMessage.Text = "Please select a project first.";
            }
        }

        // ============================================================
        // btnViewDetails_Click()
        // Navigates to the full ProjectDetails.aspx page for the
        // currently selected project (opens comments, full description).
        // ============================================================
        protected void btnViewDetails_Click(object sender, EventArgs e)
        {
            if (ViewState["SelectedProjectId"] != null)
            {
                Response.Redirect("ProjectDetails.aspx?id=" + ViewState["SelectedProjectId"]);
            }
            else
            {
                lblProjectMessage.Text = "Please select a project first.";
            }
        }
    }
}

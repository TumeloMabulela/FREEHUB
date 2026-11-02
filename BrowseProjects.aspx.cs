// ============================================================
// B100 - Browse Project (Tumelo London Mabulela)
// FILE: BrowseProjects.aspx.cs
// PURPOSE: Allows logged-in freelancers to browse all open
// projects, filter them, and navigate to submit a proposal.
// ============================================================

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
            // IF the user is not logged in, AuthHelper redirects them to Login.aspx
            // and we stop executing this page
            if (!AuthHelper.RequireLogin(this)) return;

            string userType = Session["UserType"] as string ?? "";

            // IF the logged-in user is an Employer, they don't need to browse projects
            // because employers post projects, not browse them - redirect to dashboard
            if (userType.Equals("Employer", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("Dashboard.aspx");
                return;
            }

            // IF this is the first time the page loads (not a button click/postback)
            // then load the project list from the database
            if (!IsPostBack)
            {
                LoadProjects();
            }
        }

        private void LoadProjects()
        {
            try
            {
                int currentUserId = AuthHelper.GetCurrentUserId(this);

                // Get all open projects except the ones posted by this user's own employer profile
                DataTable projects = DatabaseHelper.GetOpenProjectsExcludingOwner(currentUserId);

                // IF no projects were found, show the empty state panel
                if (projects.Rows.Count == 0)
                {
                    pnlNoProjects.Visible = true;
                    lblFilterMessage.Text = "";
                }
                else
                {
                    // IF projects were found, hide the empty panel and show the count
                    pnlNoProjects.Visible = false;
                    lblFilterMessage.Text = projects.Rows.Count + " open project(s) found";
                }

                // Bind the data to the repeater to show the project list on screen
                rptProjects.DataSource = projects;
                rptProjects.DataBind();
            }
            catch (Exception ex)
            {
                // IF something goes wrong with the database call, show the empty panel
                // and display the error message so we know what went wrong
                pnlNoProjects.Visible = true;
                lblFilterMessage.Text = "Error loading projects: " + ex.Message;
            }
        }

        protected void rptProjects_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // IF the user clicked the "Select Project" button in the list
            // (not some other button like a delete or action button)
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

                // IF no project was found with that ID (e.g. it was deleted), show an error
                if (project == null)
                {
                    lblProjectMessage.Text = "Project not found.";
                    return;
                }

                // Hide the placeholder and show the actual project details panel
                pnlNoSelection.Visible = false;
                pnlProjectDetails.Visible = true;

                // Fill in all the detail labels on the right panel
                lblProjectTitle.Text = TitleHelper.TitleCase(Convert.ToString(project["title"]));
                lblPosted.Text = "Posted " + Convert.ToDateTime(project["dateCreated"]).ToString("dd MMM yyyy");
                lblDescription.Text = Convert.ToString(project["description"]);

                // Format the budget with the budget type label
                // IF budgetType is "Fixed" show "Fixed Price", IF "Hourly" show "Hourly Rate"
                lblBudget.Text = "R" + Convert.ToDecimal(project["budget"]).ToString("N2") + " - " +
                    (Convert.ToString(project["budgetType"]) == "Fixed" ? "Fixed Price" :
                     Convert.ToString(project["budgetType"]) == "Hourly" ? "Hourly Rate" :
                     Convert.ToString(project["budgetType"]));

                lblDeadline.Text = Convert.ToDateTime(project["deadline"]).ToString("dd MMM yyyy");
                lblCategory.Text = Convert.ToString(project["category"]);
                lblExperience.Text = Convert.ToString(project["experienceLevel"]);
                lblEmployerName.Text = Convert.ToString(project["employerName"]);

                // IF the employer has a company name they are considered verified
                // Show the "Verified Employer" badge, otherwise hide it
                bool isVerified = !string.IsNullOrWhiteSpace(Convert.ToString(project["companyName"]));
                pnlEmployerVerified.Visible = isVerified;
                if (isVerified)
                {
                    lblEmployerRating.Text = "Verified Employer";
                }

                // Build initials from the employer's full name e.g. "John Smith" -> "JS"
                string name = Convert.ToString(project["employerName"]);
                string initials = "";
                string[] parts = name.Split(' ');
                foreach (string part in parts)
                {
                    // IF this part of the name has at least one character, take the first letter
                    if (part.Length > 0) initials += part[0];
                }
                lblEmployerInitials.Text = initials.ToUpper();

                // Save the selected project ID in ViewState so the Submit Proposal
                // button knows which project was selected even after a postback
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
                int currentUserId = AuthHelper.GetCurrentUserId(this);

                // Base query - always starts with Open projects excluding the user's own
                string query = @"SELECT p.projectID, p.title, p.description, p.category, p.budget,
                                p.budgetType, p.dateCreated, p.deadline, p.projectStatus,
                                p.experienceLevel, p.skills, e.companyName,
                                u.firstName + ' ' + u.lastName AS employerName
                                FROM Project p
                                INNER JOIN Employer e ON p.employerID = e.employerID
                                INNER JOIN [User] u ON e.userID = u.userID
                                WHERE p.projectStatus = 'Open'
                                  AND e.userID <> @ExcludeUserID";

                // IF the user selected a category from the dropdown, add that filter
                if (!string.IsNullOrEmpty(ddlCategory.SelectedValue))
                {
                    query += " AND p.category = '" + ddlCategory.SelectedValue.Replace("'", "''") + "'";
                }

                // IF the user selected a budget range (e.g. "5000-15000"), split it and add the range filter
                if (!string.IsNullOrEmpty(ddlBudget.SelectedValue))
                {
                    string[] range = ddlBudget.SelectedValue.Split('-');
                    // IF the range has exactly two parts (min and max), add both to the query
                    if (range.Length == 2)
                    {
                        query += " AND p.budget >= " + range[0] + " AND p.budget <= " + range[1];
                    }
                }

                // IF the user selected a date range (e.g. last 7 days), add that filter
                if (!string.IsNullOrEmpty(ddlDate.SelectedValue))
                {
                    int days = Convert.ToInt32(ddlDate.SelectedValue);
                    query += " AND p.dateCreated >= DATEADD(day, -" + days + ", GETDATE())";
                }

                query += " ORDER BY p.dateCreated DESC";

                DataTable results = DatabaseHelper.ExecuteQuery(query,
                    new SqlParameter("@ExcludeUserID", currentUserId));

                rptProjects.DataSource = results;
                rptProjects.DataBind();

                // IF no results matched the filter, show the empty state panel
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

        protected void btnReset_Click(object sender, EventArgs e)
        {
            // Reset all filter dropdowns to their default "All" option
            ddlCategory.SelectedIndex = 0;
            ddlBudget.SelectedIndex = 0;
            ddlDate.SelectedIndex = 0;
            // Reload the full unfiltered project list
            LoadProjects();
        }

        protected void btnSubmitProposal_Click(object sender, EventArgs e)
        {
            // IF the user is somehow not logged in, send them to login
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            int projectId = 0;

            // IF ViewState has a selected project ID, use that first
            if (ViewState["SelectedProjectId"] != null)
            {
                int.TryParse(ViewState["SelectedProjectId"].ToString(), out projectId);
            }

            // IF ViewState was empty, try the URL query string as a fallback
            if (projectId <= 0 && !string.IsNullOrEmpty(Request.QueryString["id"]))
            {
                int.TryParse(Request.QueryString["id"], out projectId);
            }

            // IF we have a valid project ID, go to the Submit Proposal page
            if (projectId > 0)
            {
                Response.Redirect("SubmitProposal.aspx?projectId=" + projectId);
            }
            else
            {
                // IF no project was selected, show an error asking them to select one first
                lblProjectMessage.Text = "Please select a project first.";
            }
        }

        protected void btnViewDetails_Click(object sender, EventArgs e)
        {
            // IF a project is selected, go to its full details page
            if (ViewState["SelectedProjectId"] != null)
            {
                Response.Redirect("ProjectDetails.aspx?id=" + ViewState["SelectedProjectId"]);
            }
            else
            {
                // IF nothing was selected, prompt the user to select first
                lblProjectMessage.Text = "Please select a project first.";
            }
        }
    }
}

// ================================================================
// USE CASE: B600 - Select Proposal
// WHO: Employer and Freelancer
// WHAT: Shows a list of proposals.
//       - Employers see proposals received on their projects
//       - Freelancers see proposals they submitted
//       Both can filter by status: All / Pending / Approved / Rejected
// ================================================================

using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class SelectProposal : System.Web.UI.Page
    {
        // Runs when the page first opens
        protected void Page_Load(object sender, EventArgs e)
        {
            // Stop if not logged in
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Only load data on the first visit (not after button clicks)
            if (!IsPostBack)
            {
                pnlMessage.Visible = false;

                // Check if the user is a Freelancer and save it for later use
                string userType = Session["UserType"] as string ?? "";
                if (userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
                {
                    ViewState["IsFreelancer"] = true;
                }
                else
                {
                    ViewState["IsFreelancer"] = false;
                }

                LoadProposals();
            }
        }

        // Loads proposals from the database based on the user's role and selected filter tab
        private void LoadProposals()
        {
            int userId = Convert.ToInt32(Session["UserID"]);
            string userType = Session["UserType"] as string ?? "";

            try
            {
                DataTable proposals;

                // If user is an Employer - get proposals received on their projects
                if (userType.Equals("Employer", StringComparison.OrdinalIgnoreCase))
                {
                    string query = @"SELECT pr.proposalID, pr.coverLetter, pr.proposedRate,
                                    pr.estimatedCompletionTime, pr.status, pr.date,
                                    u.firstName + ' ' + u.lastName AS freelancerName,
                                    p.title AS projectTitle
                                    FROM Proposal pr
                                    INNER JOIN Freelancer f ON pr.freelancerID = f.freelancerID
                                    INNER JOIN [User] u ON f.userID = u.userID
                                    INNER JOIN Project p ON pr.projectID = p.projectID
                                    INNER JOIN Employer e ON p.employerID = e.employerID
                                    WHERE e.userID = @UserID
                                    ORDER BY pr.date DESC";
                    proposals = DatabaseHelper.ExecuteQuery(query, new SqlParameter("@UserID", userId));
                }
                else
                {
                    // If user is a Freelancer - get only their own submitted proposals
                    string query = @"SELECT pr.proposalID, pr.coverLetter, pr.proposedRate,
                                    pr.estimatedCompletionTime, pr.status, pr.date,
                                    u2.firstName + ' ' + u2.lastName AS freelancerName,
                                    p.title AS projectTitle
                                    FROM Proposal pr
                                    INNER JOIN Freelancer f ON pr.freelancerID = f.freelancerID
                                    INNER JOIN [User] u2 ON f.userID = u2.userID
                                    INNER JOIN Project p ON pr.projectID = p.projectID
                                    WHERE f.userID = @UserID
                                    ORDER BY pr.date DESC";
                    proposals = DatabaseHelper.ExecuteQuery(query, new SqlParameter("@UserID", userId));
                }

                bool isEmployer = userType.Equals("Employer", StringComparison.OrdinalIgnoreCase);

                // Show the filter tabs
                pnlFilterTabs.Visible = true;

                // Count proposals by status to show in each tab badge
                int totalCount = proposals.Rows.Count;
                int pendingCount = 0, approvedCount = 0, rejectedCount = 0;
                foreach (DataRow r in proposals.Rows)
                {
                    string st = Convert.ToString(r["status"]).Trim();
                    if (st.Equals("Approved", StringComparison.OrdinalIgnoreCase)) approvedCount++;
                    else if (st.Equals("Rejected", StringComparison.OrdinalIgnoreCase)) rejectedCount++;
                    else if (st.Equals("Pending", StringComparison.OrdinalIgnoreCase)) pendingCount++;
                }

                // Employers see "Pending Approval", freelancers just see "Pending"
                string pendingLabel = isEmployer ? "Pending Approval" : "Pending";

                // Update each tab label with its count
                lnkTabAll.Text = "All <span class=\"pl-tab-count\">" + totalCount + "</span>";
                lnkTabPending.Text = pendingLabel + " <span class=\"pl-tab-count\">" + pendingCount + "</span>";
                lnkTabApproved.Text = "Approved <span class=\"pl-tab-count\">" + approvedCount + "</span>";
                lnkTabRejected.Text = "Rejected <span class=\"pl-tab-count\">" + rejectedCount + "</span>";

                // Highlight the currently selected tab
                lnkTabAll.CssClass = CurrentFilter == "All" ? "pl-tab pl-tab-active" : "pl-tab";
                lnkTabPending.CssClass = CurrentFilter == "Pending" ? "pl-tab pl-tab-active" : "pl-tab";
                lnkTabApproved.CssClass = CurrentFilter == "Approved" ? "pl-tab pl-tab-active" : "pl-tab";
                lnkTabRejected.CssClass = CurrentFilter == "Rejected" ? "pl-tab pl-tab-active" : "pl-tab";

                // Filter the list if a specific tab is selected (not "All")
                if (CurrentFilter != "All")
                {
                    DataTable view = proposals.Clone();
                    foreach (DataRow r in proposals.Rows)
                    {
                        string st = Convert.ToString(r["status"]).Trim();
                        if (st.Equals(CurrentFilter, StringComparison.OrdinalIgnoreCase))
                            view.ImportRow(r);
                    }
                    proposals = view;
                }

                // Bind the proposals to the list on screen
                rptProposals.DataSource = proposals;
                rptProposals.DataBind();

                bool isEmpty = proposals.Rows.Count == 0;

                // Show empty state if no proposals in this tab
                pnlNoProposals.Visible = isEmpty;
                lblProposalCount.Text = proposals.Rows.Count.ToString();
                pnlListWrap.Visible = !isEmpty;

                // Set the empty state message based on which tab is selected
                if (isEmpty)
                {
                    if (CurrentFilter == "Approved")
                    {
                        litEmptyTitle.Text = "No Approved Proposals";
                        litEmptyText.Text = isEmployer
                            ? "Proposals you approve will appear here."
                            : "Your approved proposals will appear here.";
                    }
                    else if (CurrentFilter == "Rejected")
                    {
                        litEmptyTitle.Text = "No Rejected Proposals";
                        litEmptyText.Text = isEmployer
                            ? "Proposals you reject will appear here."
                            : "Your rejected proposals will appear here.";
                    }
                    else if (CurrentFilter == "Pending")
                    {
                        litEmptyTitle.Text = "No Pending Proposals";
                        litEmptyText.Text = isEmployer
                            ? "New proposals awaiting your approval will appear here."
                            : "Your proposals awaiting a decision will appear here.";
                    }
                    else
                    {
                        litEmptyTitle.Text = isEmployer ? "No Proposals Received" : "No Proposals Yet";
                        litEmptyText.Text = isEmployer
                            ? "Proposals submitted to your projects will appear here."
                            : "Your submitted proposals will appear here.";
                    }
                }
            }
            catch (Exception ex)
            {
                pnlNoProposals.Visible = true;
                ShowMessage("Error loading proposals: " + ex.Message, false);
            }
        }

        // Remembers which tab the user has selected (All / Pending / Approved / Rejected)
        private string CurrentFilter
        {
            get
            {
                string f = ViewState["ProposalFilter"] as string;
                return (f == "Pending" || f == "Approved" || f == "Rejected") ? f : "All";
            }
            set { ViewState["ProposalFilter"] = value; }
        }

        // Runs when a filter tab is clicked - changes the active tab and reloads the list
        protected void FilterTab_Command(object sender, System.Web.UI.WebControls.CommandEventArgs e)
        {
            string cmd = Convert.ToString(e.CommandName);
            CurrentFilter = (cmd == "Pending" || cmd == "Approved" || cmd == "Rejected") ? cmd : "All";
            LoadProposals();

            // Scroll the list back to the top after switching tabs
            ClientScript.RegisterStartupScript(GetType(), "plScrollTop",
                "var l=document.querySelector('.pl-list'); if(l){l.scrollTop=0;}", true);
        }

        // Runs when any button inside a proposal row is clicked
        protected void rptProposals_ItemCommand(object source,
            System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            int proposalId = Convert.ToInt32(e.CommandArgument);

            // View button or Approve button - go to the Review page to read the full proposal
            if (e.CommandName == "ApproveProposal")
            {
                Response.Redirect("ReviewProposal.aspx?id=" + proposalId);
            }
            // Quick reject directly from the list
            else if (e.CommandName == "RejectProposal")
            {
                try
                {
                    string query = "UPDATE Proposal SET status = 'Rejected' WHERE proposalID = @ID";
                    DatabaseHelper.ExecuteNonQuery(query, new SqlParameter("@ID", proposalId));
                    ShowMessage("Proposal rejected. The freelancer has been notified.", true);
                }
                catch (Exception ex)
                {
                    ShowMessage("Error: " + ex.Message, false);
                }
                LoadProposals();
            }
            // View full proposal details
            else if (e.CommandName == "ViewProposal"
                     || e.CommandName == "ViewDetails"
                     || e.CommandName == "ReadAll")
            {
                Response.Redirect("ReviewProposal.aspx?id=" + proposalId);
            }
            // Delete a proposal from the list
            else if (e.CommandName == "DeleteProposal")
            {
                try
                {
                    string query = "DELETE FROM Proposal WHERE proposalID = @ID";
                    DatabaseHelper.ExecuteNonQuery(query, new SqlParameter("@ID", proposalId));
                    ShowMessage("Proposal deleted successfully.", true);
                }
                catch (Exception ex)
                {
                    ShowMessage("Error deleting proposal: " + ex.Message, false);
                }
                LoadProposals();
            }
        }

        // Shows a green or red message
        private void ShowMessage(string message, bool success)
        {
            if (success) MessageHelper.Success(this, message);
            else MessageHelper.Error(this, message);
        }

        // Returns true if the current user is a Freelancer
        protected bool IsFreelancerView()
        {
            string userType = Session["UserType"] as string ?? "";
            return userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase);
        }

        // Returns the CSS class for the status badge colour
        // e.g. "approved" -> green badge, "rejected" -> red badge
        protected string GetStatusClass(object status)
        {
            string s = Convert.ToString(status).Trim().ToLowerInvariant();
            switch (s)
            {
                case "approved": return "pl-badge-approved";
                case "rejected": return "pl-badge-rejected";
                case "under review": return "pl-badge-review";
                case "withdrawn": return "pl-badge-withdrawn";
                case "pending": return "pl-badge-pending";
                default: return "pl-badge-default";
            }
        }

        // Returns the icon shown on the status badge
        protected string GetStatusIcon(object status)
        {
            string s = Convert.ToString(status).Trim().ToLowerInvariant();
            switch (s)
            {
                case "approved": return "&#9989;";     // tick
                case "rejected": return "&#10060;";    // cross
                case "under review": return "&#8987;"; // hourglass
                case "pending": return "&#9201;";      // clock
                default: return "";
            }
        }

        // Returns a friendly label for the status
        // "Under Review" shows as "In Review", "Pending" shows differently for employer vs freelancer
        protected string GetStatusLabel(object status)
        {
            string s = Convert.ToString(status).Trim();
            if (s.Equals("Under Review", StringComparison.OrdinalIgnoreCase)) return "In Review";
            if (s.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                return IsFreelancerView() ? "Pending" : "Pending Approval";
            return s;
        }
    }
}

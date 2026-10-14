using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class SelectProposal : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                pnlMessage.Visible = false;

                // Restrict Select/Approve/Reject to Employer only
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

        private void LoadProposals()
        {
            int userId = Convert.ToInt32(Session["UserID"]);
            string userType = Session["UserType"] as string ?? "";

            try
            {
                DataTable proposals;

                if (userType.Equals("Employer", StringComparison.OrdinalIgnoreCase))
                {
                    // Employer sees proposals received for their projects
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
                    proposals = DatabaseHelper.ExecuteQuery(query,
                        new SqlParameter("@UserID", userId));
                }
                else
                {
                    // Freelancer sees their own submitted proposals
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
                    proposals = DatabaseHelper.ExecuteQuery(query,
                        new SqlParameter("@UserID", userId));
                }

                bool isEmployer = userType.Equals("Employer", StringComparison.OrdinalIgnoreCase);

                // Filter tabs apply to the employer view only; freelancers keep their
                // existing "all my proposals" list unchanged.
                pnlFilterTabs.Visible = isEmployer;

                if (isEmployer)
                {
                    // Count each category from the full set (dynamic, not hardcoded):
                    //   Pending Approval = status 'Pending' (genuinely awaiting a decision).
                    //   Approved = status 'Approved'. Rejected = status 'Rejected'.
                    //   Withdrawn/Cancelled (if any) are not counted in these three tabs.
                    int pendingCount = 0, approvedCount = 0, rejectedCount = 0;
                    foreach (DataRow r in proposals.Rows)
                    {
                        string st = Convert.ToString(r["status"]).Trim();
                        if (st.Equals("Approved", StringComparison.OrdinalIgnoreCase)) approvedCount++;
                        else if (st.Equals("Rejected", StringComparison.OrdinalIgnoreCase)) rejectedCount++;
                        else if (st.Equals("Pending", StringComparison.OrdinalIgnoreCase)) pendingCount++;
                    }

                    // Set each tab's full label + count badge as inline HTML on the LinkButton
                    // Text, so the labels/counts can never be lost across postbacks.
                    lnkTabPending.Text = "Pending Approval <span class=\"pl-tab-count\">" + pendingCount + "</span>";
                    lnkTabApproved.Text = "Approved <span class=\"pl-tab-count\">" + approvedCount + "</span>";
                    lnkTabRejected.Text = "Rejected <span class=\"pl-tab-count\">" + rejectedCount + "</span>";

                    // Highlight the active tab (FreeHUB green).
                    lnkTabPending.CssClass = CurrentFilter == "Pending" ? "pl-tab pl-tab-active" : "pl-tab";
                    lnkTabApproved.CssClass = CurrentFilter == "Approved" ? "pl-tab pl-tab-active" : "pl-tab";
                    lnkTabRejected.CssClass = CurrentFilter == "Rejected" ? "pl-tab pl-tab-active" : "pl-tab";

                    // Build the filtered view for the selected tab.
                    DataTable view = proposals.Clone();
                    foreach (DataRow r in proposals.Rows)
                    {
                        string st = Convert.ToString(r["status"]).Trim();
                        bool include;
                        if (CurrentFilter == "Approved")
                            include = st.Equals("Approved", StringComparison.OrdinalIgnoreCase);
                        else if (CurrentFilter == "Rejected")
                            include = st.Equals("Rejected", StringComparison.OrdinalIgnoreCase);
                        else
                            include = st.Equals("Pending", StringComparison.OrdinalIgnoreCase);
                        if (include) view.ImportRow(r);
                    }
                    proposals = view;
                }

                rptProposals.DataSource = proposals;
                rptProposals.DataBind();

                pnlNoProposals.Visible = proposals.Rows.Count == 0;
                lblProposalCount.Text = proposals.Rows.Count.ToString();

                // Friendly empty-state message tailored to the active filter.
                if (proposals.Rows.Count == 0 && isEmployer)
                {
                    pnlNoProposals.Controls.Clear();
                    if (CurrentFilter == "Approved")
                        pnlNoProposals.Controls.Add(new System.Web.UI.LiteralControl(
                            "<h3>No approved proposals yet</h3><p>Proposals you approve will appear here.</p>"));
                    else if (CurrentFilter == "Rejected")
                        pnlNoProposals.Controls.Add(new System.Web.UI.LiteralControl(
                            "<h3>No rejected proposals found.</h3><p>Proposals you reject will appear here.</p>"));
                    else
                        pnlNoProposals.Controls.Add(new System.Web.UI.LiteralControl(
                            "<h3>No proposals awaiting approval</h3><p>Pending proposals for your projects will appear here for review.</p>"));
                }
            }
            catch (Exception ex)
            {
                pnlNoProposals.Visible = true;
                ShowMessage("Error loading proposals: " + ex.Message, false);
            }
        }

        /// <summary>Active approval filter tab: "Pending" (default), "Approved" or "Rejected".</summary>
        private string CurrentFilter
        {
            get
            {
                string f = ViewState["ProposalFilter"] as string;
                return (f == "Approved" || f == "Rejected") ? f : "Pending";
            }
            set { ViewState["ProposalFilter"] = value; }
        }

        protected void FilterTab_Command(object sender, System.Web.UI.WebControls.CommandEventArgs e)
        {
            string cmd = Convert.ToString(e.CommandName);
            CurrentFilter = (cmd == "Approved" || cmd == "Rejected") ? cmd : "Pending";
            LoadProposals();

            // Reset the proposal list scrollbar to the top on filter switch.
            ClientScript.RegisterStartupScript(GetType(), "plScrollTop",
                "var l=document.querySelector('.pl-list'); if(l){l.scrollTop=0;}", true);
        }

        protected void rptProposals_ItemCommand(object source,
            System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            int proposalId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "ApproveProposal")
            {
                // Select Proposal goes to Review page - NOT auto-approve
                Response.Redirect("ReviewProposal.aspx?id=" + proposalId);
            }
            else if (e.CommandName == "RejectProposal")
            {
                try
                {
                    string query = "UPDATE Proposal SET status = 'Rejected' WHERE proposalID = @ID";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new SqlParameter("@ID", proposalId));
                    ShowMessage("Proposal rejected. The freelancer has been notified.", true);
                }
                catch (Exception ex)
                {
                    ShowMessage("Error: " + ex.Message, false);
                }
                LoadProposals();
            }
            else if (e.CommandName == "ViewProposal"
                     || e.CommandName == "ViewDetails"
                     || e.CommandName == "ReadAll")
            {
                // Opens the existing full-proposal page (ReviewProposal.aspx), which loads the
                // complete cover letter and enforces its own role-based authorisation
                // (employers can act, freelancers are read-only).
                Response.Redirect("ReviewProposal.aspx?id=" + proposalId);
            }
            else if (e.CommandName == "DeleteProposal")
            {
                try
                {
                    string query = "DELETE FROM Proposal WHERE proposalID = @ID";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new SqlParameter("@ID", proposalId));
                    ShowMessage("Proposal deleted successfully.", true);
                }
                catch (Exception ex)
                {
                    ShowMessage("Error deleting proposal: " + ex.Message, false);
                }
                LoadProposals();
            }
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            lblProposalMessage.Text = message;
            pnlMessage.CssClass = success ? "post-status post-success" : "post-status post-error";
        }

        protected bool IsFreelancerView()
        {
            string userType = Session["UserType"] as string ?? "";
            return userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Maps an existing proposal status value to its badge CSS class.
        /// Does not change or add status values — only picks a colour for display.
        /// </summary>
        protected string GetStatusClass(object status)
        {
            string s = Convert.ToString(status).Trim().ToLowerInvariant();
            switch (s)
            {
                case "approved": return "pl-badge-approved";
                case "rejected": return "pl-badge-rejected";
                case "withdrawn": return "pl-badge-withdrawn";
                case "pending": return "pl-badge-pending";
                default: return "pl-badge-default";
            }
        }
    }
}

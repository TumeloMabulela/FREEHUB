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

                rptProposals.DataSource = proposals;
                rptProposals.DataBind();

                pnlNoProposals.Visible = proposals.Rows.Count == 0;
            }
            catch (Exception ex)
            {
                pnlNoProposals.Visible = true;
                ShowMessage("Error loading proposals: " + ex.Message, false);
            }
        }

        protected void rptProposals_ItemCommand(object source,
            System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            int proposalId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "ApproveProposal")
            {
                try
                {
                    // Approve proposal and set project to In Progress
                    string query = @"UPDATE Proposal SET status = 'Approved' WHERE proposalID = @ID;
                                    UPDATE Project SET projectStatus = 'In Progress'
                                    WHERE projectID = (SELECT projectID FROM Proposal WHERE proposalID = @ID)";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new SqlParameter("@ID", proposalId));
                    ShowMessage("Proposal approved! The project is now In Progress.", true);
                }
                catch (Exception ex)
                {
                    ShowMessage("Error: " + ex.Message, false);
                }
                LoadProposals();
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
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            lblProposalMessage.Text = message;
            pnlMessage.CssClass = success ? "post-status post-success" : "post-status post-error";
        }
    }
}

using System;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    public partial class ReviewProposal : System.Web.UI.Page
    {
        private int ProposalId
        {
            get
            {
                int id = 0;
                int.TryParse(Request.QueryString["id"], out id);
                return id;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Freelancers can view their own proposals (read-only), Employers can approve/reject
            string userType = Session["UserType"] as string ?? "";
            bool isFreelancer = userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase);

            if (!IsPostBack)
            {
                pnlMessage.Visible = false;
                // Hide ALL action buttons for freelancers (read-only view)
                if (isFreelancer)
                {
                    pnlActions.Visible = false;
                }
                LoadProposal();
            }
        }

        private void LoadProposal()
        {
            if (ProposalId <= 0)
            {
                ShowMessage("No proposal selected.", false);
                pnlActions.Visible = false;
                return;
            }

            try
            {
                string query = @"SELECT pr.proposalID, pr.coverLetter, pr.proposedRate,
                                pr.estimatedCompletionTime, pr.status, pr.date,
                                u.firstName + ' ' + u.lastName AS freelancerName,
                                p.title AS projectTitle
                                FROM Proposal pr
                                INNER JOIN Freelancer f ON pr.freelancerID = f.freelancerID
                                INNER JOIN [User] u ON f.userID = u.userID
                                INNER JOIN Project p ON pr.projectID = p.projectID
                                WHERE pr.proposalID = @ProposalID";

                DataTable result = DatabaseHelper.ExecuteQuery(query,
                    new SqlParameter("@ProposalID", ProposalId));

                if (result.Rows.Count == 0)
                {
                    ShowMessage("Proposal not found.", false);
                    pnlActions.Visible = false;
                    return;
                }

                DataRow proposal = result.Rows[0];

                string freelancerName = Convert.ToString(proposal["freelancerName"]);
                lblFreelancerName.Text = freelancerName;
                lblFreelancerInitials.Text = GetInitials(freelancerName);
                lblProjectTitle.Text = Convert.ToString(proposal["projectTitle"]);
                lblRate.Text = "R" + Convert.ToDecimal(proposal["proposedRate"]).ToString("N0");
                lblTime.Text = Convert.ToString(proposal["estimatedCompletionTime"]);
                lblDate.Text = Convert.ToDateTime(proposal["date"]).ToString("dd MMM yyyy");
                lblCoverLetter.Text = Convert.ToString(proposal["coverLetter"]);
                lblStatus.Text = Convert.ToString(proposal["status"]);

                // Hide action buttons if already approved/rejected
                string status = Convert.ToString(proposal["status"]);
                if (status != "Pending")
                {
                    btnApproveProposal.Visible = false;
                    btnRejectProposal.Visible = false;
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading proposal: " + ex.Message, false);
            }
        }

        protected void btnApproveProposal_Click(object sender, EventArgs e)
        {
            try
            {
                string query = @"UPDATE Proposal SET status = 'Approved' WHERE proposalID = @ID;
                                UPDATE Project SET projectStatus = 'In Progress'
                                WHERE projectID = (SELECT projectID FROM Proposal WHERE proposalID = @ID)";
                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@ID", ProposalId));

                ShowMessage("Proposal approved! The project is now In Progress and the freelancer has been assigned.", true);
                btnApproveProposal.Visible = false;
                btnRejectProposal.Visible = false;
                lblStatus.Text = "Approved";
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void btnRejectProposal_Click(object sender, EventArgs e)
        {
            try
            {
                string query = "UPDATE Proposal SET status = 'Rejected' WHERE proposalID = @ID";
                DatabaseHelper.ExecuteNonQuery(query,
                    new SqlParameter("@ID", ProposalId));

                ShowMessage("Proposal rejected. The freelancer has been notified.", true);
                btnApproveProposal.Visible = false;
                btnRejectProposal.Visible = false;
                lblStatus.Text = "Rejected";
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void btnBackToProposals_Click(object sender, EventArgs e)
        {
            Response.Redirect("SelectProposal.aspx");
        }

        private string GetInitials(string name)
        {
            string initials = "";
            string[] parts = name.Split(' ');
            foreach (string part in parts)
            {
                if (part.Length > 0) initials += part[0];
            }
            return initials.ToUpper();
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            lblReviewMessage.Text = message;
            pnlMessage.CssClass = success ? "post-status post-success" : "post-status post-error";
        }
    }
}

using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class StartChat : System.Web.UI.Page
    {
        private readonly string _connStr = ConfigurationManager.ConnectionStrings["FreeHubDB"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;

            if (!IsPostBack)
            {
                // Heartbeat: update current user's last seen timestamp
                DatabaseHelper.UpdateUserLastSeen(CurrentUserId);

                BindApprovedChatUsers("");

                string queryUserId = Request.QueryString["userId"];
                string userFromQuery = Request.QueryString["user"];

                if (!string.IsNullOrWhiteSpace(queryUserId))
                {
                    int uid;
                    if (int.TryParse(queryUserId, out uid))
                    {
                        SelectUserById(uid);
                    }
                }
                else if (!string.IsNullOrWhiteSpace(userFromQuery))
                {
                    SelectUserByName(userFromQuery);
                }
                else if (SelectedOtherUserId > 0)
                {
                    SelectUserById(SelectedOtherUserId);
                }
            }
        }

        public int CurrentUserId
        {
            get { return Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0; }
        }

        public int SelectedOtherUserId
        {
            get { return Session["SelectedOtherUserId"] != null ? Convert.ToInt32(Session["SelectedOtherUserId"]) : 0; }
            set { Session["SelectedOtherUserId"] = value; }
        }

        private int ActiveProjectId
        {
            get { return Session["ActiveProjectId"] != null ? Convert.ToInt32(Session["ActiveProjectId"]) : 0; }
            set { Session["ActiveProjectId"] = value; }
        }

        private void BindApprovedChatUsers(string searchText)
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    SELECT DISTINCT 
                        u.userID AS UserID,
                        (u.firstName + ' ' + u.lastName) AS Name,
                        (LEFT(u.firstName, 1) + LEFT(u.lastName, 1)) AS Initials,
                        p.projectID AS ProjectID,
                        p.title AS ProjectTitle,
                        ISNULL((SELECT TOP 1 content FROM dbo.Message WHERE (senderID = u.userID AND receiverID = @CurrentUserID) OR (senderID = @CurrentUserID AND receiverID = u.userID) ORDER BY timeStamp DESC), 'No messages yet') AS LastMessage,
                        ISNULL((SELECT TOP 1 FORMAT(timeStamp, 'hh:mm tt') FROM dbo.Message WHERE (senderID = u.userID AND receiverID = @CurrentUserID) OR (senderID = @CurrentUserID AND receiverID = u.userID) ORDER BY timeStamp DESC), '') AS LastTime
                    FROM dbo.Proposal prop
                    INNER JOIN dbo.Project p ON prop.projectID = p.projectID
                    INNER JOIN dbo.Employer e ON p.employerID = e.employerID
                    INNER JOIN dbo.Freelancer f ON prop.freelancerID = f.freelancerID
                    INNER JOIN dbo.[User] u ON (
                        CASE 
                            WHEN e.userID = @CurrentUserID THEN f.userID
                            WHEN f.userID = @CurrentUserID THEN e.userID
                        END = u.userID
                    )
                    WHERE prop.status = 'Approved' 
                      AND (e.userID = @CurrentUserID OR f.userID = @CurrentUserID)";

                if (!string.IsNullOrWhiteSpace(searchText))
                {
                    query += " AND (u.firstName + ' ' + u.lastName LIKE @Search OR p.title LIKE @Search)";
                }

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CurrentUserID", CurrentUserId);
                    if (!string.IsNullOrWhiteSpace(searchText))
                    {
                        cmd.Parameters.AddWithValue("@Search", "%" + searchText + "%");
                    }

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            rptUsers.DataSource = dt;
            rptUsers.DataBind();
            lblNoUsers.Visible = (dt.Rows.Count == 0);

            if (dt.Rows.Count > 0 && SelectedOtherUserId == 0)
            {
                SelectUserById(Convert.ToInt32(dt.Rows[0]["UserID"]));
            }
        }

        protected void btnToggleDetails_Click(object sender, EventArgs e)
        {
            if (SelectedOtherUserId <= 0) return;

            pnlUserDetailsModal.Visible = true;
            LoadUserDetailsAndSharedFiles(SelectedOtherUserId);
        }

        protected void btnCloseDetails_Click(object sender, EventArgs e)
        {
            pnlUserDetailsModal.Visible = false;
        }

        private void LoadUserDetailsAndSharedFiles(int targetUserId)
        {
            // 1. Load User Profile Details
            DataRow user = DatabaseHelper.GetUserById(targetUserId);
            if (user != null)
            {
                lblDetailName.Text = Convert.ToString(user["firstName"]) + " " + Convert.ToString(user["lastName"]);
                lblDetailEmail.Text = Convert.ToString(user["email"]);
                lblDetailContact.Text = user["contactNumber"] != DBNull.Value ? Convert.ToString(user["contactNumber"]) : "N/A";
                lblDetailUserType.Text = Convert.ToString(user["userType"]);

                decimal rating = user["ratingScore"] != DBNull.Value ? Convert.ToDecimal(user["ratingScore"]) : 0.0m;
                lblDetailRating.Text = rating.ToString("F1");
            }

            // 2. Load Shared File Attachments History
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    SELECT attachmentUrl, timeStamp 
                    FROM dbo.Message 
                    WHERE ((senderID = @CurrentUserID AND receiverID = @OtherUserID) 
                        OR (senderID = @OtherUserID AND receiverID = @CurrentUserID))
                      AND attachmentUrl IS NOT NULL 
                      AND attachmentUrl != ''
                    ORDER BY timeStamp DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CurrentUserID", CurrentUserId);
                    cmd.Parameters.AddWithValue("@OtherUserID", targetUserId);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dtFiles = new DataTable();
                        da.Fill(dtFiles);

                        if (dtFiles.Rows.Count > 0)
                        {
                            rptSharedFiles.DataSource = dtFiles;
                            rptSharedFiles.DataBind();
                            lblNoSharedFiles.Visible = false;
                        }
                        else
                        {
                            rptSharedFiles.DataSource = null;
                            rptSharedFiles.DataBind();
                            lblNoSharedFiles.Visible = true;
                        }
                    }
                }
            }
        }

        public string GetAvatarClass(string initials)
        {
            if (string.IsNullOrEmpty(initials)) return "avatar-ml";
            switch (initials.ToUpper())
            {
                case "RT": return "avatar-rt";
                case "MT": return "avatar-mt";
                case "MU": return "avatar-mu";
                default: return "avatar-ml";
            }
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectUser")
            {
                int otherUserId = Convert.ToInt32(e.CommandArgument);
                SelectUserById(otherUserId);
            }
        }

        private void SelectUserByName(string userName)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"SELECT TOP 1 userID FROM dbo.[User] WHERE (firstName + ' ' + lastName) = @UserName OR username = @UserName";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserName", userName);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null)
                    {
                        SelectUserById(Convert.ToInt32(result));
                    }
                }
            }
        }

        private void SelectUserById(int otherUserId)
        {
            SelectedOtherUserId = otherUserId;

            // Fetch user profile info
            DataRow user = DatabaseHelper.GetUserById(otherUserId);
            if (user != null)
            {
                string firstName = user["firstName"].ToString();
                string lastName = user["lastName"].ToString();
                lblChatName.Text = firstName + " " + lastName;
                lblChatInitials.Text = (!string.IsNullOrEmpty(firstName) ? firstName[0].ToString() : "") +
                                       (!string.IsNullOrEmpty(lastName) ? lastName[0].ToString() : "");

                string accountStatus = Convert.ToString(user["accountStatus"]);
                if (accountStatus == "Inactive" || accountStatus == "Deleted" || accountStatus == "Deactivated")
                {
                    lblPartnerStatus.Text = "Account Deactivated 🔴";
                }
                else
                {
                    lblPartnerStatus.Text = DatabaseHelper.GetUserOnlineStatus(otherUserId);
                }
            }

            bool isChatEndedOrDeactivated = false;
            string lockReasonMessage = string.Empty;

            // 1. Check if partner account status is Deactivated, Deleted, or Inactive
            if (user != null)
            {
                string accountStatus = Convert.ToString(user["accountStatus"]);
                if (accountStatus.Equals("Deactivated", StringComparison.OrdinalIgnoreCase) ||
                    accountStatus.Equals("Deleted", StringComparison.OrdinalIgnoreCase) ||
                    accountStatus.Equals("Inactive", StringComparison.OrdinalIgnoreCase))
                {
                    isChatEndedOrDeactivated = true;
                    lockReasonMessage = "The profile has been deactivated";
                }
            }

            // 2. Check if there is an active/completed proposal/project between these two users (with proper JOINs)
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"SELECT TOP 1 p.projectID, p.projectStatus, u.accountStatus AS EmployerAccountStatus FROM dbo.Proposal prop INNER JOIN dbo.Project p ON prop.projectID = p.projectID INNER JOIN dbo.Employer e ON p.employerID = e.employerID INNER JOIN dbo.Freelancer f ON prop.freelancerID = f.freelancerID INNER JOIN dbo.[User] u ON e.userID = u.userID WHERE prop.status = 'Approved' AND ((e.userID = @CurrentUserID AND f.userID = @OtherUserID) OR (f.userID = @CurrentUserID AND e.userID = @OtherUserID))";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CurrentUserID", CurrentUserId);
                    cmd.Parameters.AddWithValue("@OtherUserID", otherUserId);
                    conn.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            ActiveProjectId = Convert.ToInt32(dr["projectID"]);
                            string projectStatus = dr["projectStatus"].ToString();
                            string empAccountStatus = dr["EmployerAccountStatus"].ToString();

                            if (projectStatus.Equals("Completed", StringComparison.OrdinalIgnoreCase) ||
                                projectStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
                            {
                                isChatEndedOrDeactivated = true;
                                lockReasonMessage = "Project completed";

                                // Close data reader so we can execute a scalar check safely on the same connection
                                dr.Close();

                                // Check if the current user has already rated this project
                                string checkRatingQuery = "SELECT COUNT(*) FROM dbo.Rating WHERE projectID = @ProjectID AND raterUserID = @RaterUserID";
                                int existingRatings = 0;
                                using (SqlCommand ratingCmd = new SqlCommand(checkRatingQuery, conn))
                                {
                                    ratingCmd.Parameters.AddWithValue("@ProjectID", ActiveProjectId);
                                    ratingCmd.Parameters.AddWithValue("@RaterUserID", CurrentUserId);
                                    existingRatings = Convert.ToInt32(ratingCmd.ExecuteScalar());
                                }

                                // Only show rating modal if completed AND the current user hasn't rated yet
                                if (ActiveProjectId > 0 && existingRatings == 0 && projectStatus.Equals("Completed", StringComparison.OrdinalIgnoreCase))
                                {
                                    pnlRatingModal.Visible = true;
                                }
                                else
                                {
                                    pnlRatingModal.Visible = false;
                                }
                            }
                            else if (empAccountStatus.Equals("Deactivated", StringComparison.OrdinalIgnoreCase) ||
                                     empAccountStatus.Equals("Deleted", StringComparison.OrdinalIgnoreCase) ||
                                     empAccountStatus.Equals("Inactive", StringComparison.OrdinalIgnoreCase))
                            {
                                isChatEndedOrDeactivated = true;
                                lockReasonMessage = "The profile has been deactivated";
                            }
                        }
                        else
                        {
                            ActiveProjectId = 0;
                        }
                    }
                }
            }

            // Apply Chat Locking UI Rules (Preserving DB History)
            if (isChatEndedOrDeactivated)
            {
                btnSend.Enabled = false;
                fileUploadControl.Enabled = false;
                txtMessage.Enabled = false;
                txtMessage.Attributes["placeholder"] = "Chat has ended. Messages are read-only.";

                ShowStatus(lockReasonMessage);
            }
            else
            {
                btnSend.Enabled = true;
                fileUploadControl.Enabled = true;
                txtMessage.Enabled = true;
                txtMessage.Attributes["placeholder"] = "Type your message...";
            }

            // Mark unread messages as Read without deleting any table rows
            DatabaseHelper.MarkMessagesAsRead(CurrentUserId, otherUserId, ActiveProjectId > 0 ? (int?)ActiveProjectId : null);

            LoadChatMessages();
        }
        protected void btnSend_Click(object sender, EventArgs e)
        {
            if (SelectedOtherUserId <= 0 || (string.IsNullOrWhiteSpace(txtMessage.Text) && !fileUploadControl.HasFile)) return;

            string savedAttachmentUrl = null;

            // Handle file attachment upload
            if (fileUploadControl.HasFile)
            {
                try
                {
                    string folderPath = Server.MapPath("~/Uploads/");
                    if (!Directory.Exists(folderPath))
                    {
                        Directory.CreateDirectory(folderPath);
                    }

                    string fileExt = Path.GetExtension(fileUploadControl.FileName);
                    string fileName = Guid.NewGuid().ToString("N") + fileExt;
                    string fullPath = Path.Combine(folderPath, fileName);

                    fileUploadControl.SaveAs(fullPath);
                    savedAttachmentUrl = "~/Uploads/" + fileName;
                }
                catch (Exception ex)
                {
                    ShowStatus("Error uploading file: " + ex.Message);
                    return;
                }
            }

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    INSERT INTO dbo.Message (senderID, receiverID, projectID, content, attachmentUrl, timeStamp, status)
                    VALUES (@SenderID, @ReceiverID, @ProjectID, @Content, @AttachmentUrl, GETDATE(), 'Sent')";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@SenderID", CurrentUserId);
                    cmd.Parameters.AddWithValue("@ReceiverID", SelectedOtherUserId);
                    cmd.Parameters.AddWithValue("@ProjectID", ActiveProjectId > 0 ? (object)ActiveProjectId : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Content", txtMessage.Text.Trim());
                    cmd.Parameters.AddWithValue("@AttachmentUrl", string.IsNullOrEmpty(savedAttachmentUrl) ? (object)DBNull.Value : savedAttachmentUrl);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            string senderName = Session["FirstName"] != null ? Session["FirstName"].ToString() : "A user";
            NotificationHelper.CreateNotification(SelectedOtherUserId, "Message", $"{senderName} sent you a message.");

            txtMessage.Text = "";
            lblAttachedFileName.Text = "";
            ShowStatus("Message sent successfully.");

            LoadChatMessages();
            BindApprovedChatUsers("");
        }

        private void LoadChatMessages()
        {
            if (SelectedOtherUserId <= 0)
            {
                rptMessages.DataSource = null;
                rptMessages.DataBind();
                return;
            }

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string query = @"
                    SELECT 
                        messageID, 
                        senderID, 
                        receiverID, 
                        content, 
                        attachmentUrl, 
                        status, 
                        timeStamp
                    FROM dbo.Message
                    WHERE (senderID = @CurrentUserID AND receiverID = @OtherUserID)
                       OR (senderID = @OtherUserID AND receiverID = @CurrentUserID)
                    ORDER BY timeStamp ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CurrentUserID", CurrentUserId);
                    cmd.Parameters.AddWithValue("@OtherUserID", SelectedOtherUserId);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        rptMessages.DataSource = dt;
                        rptMessages.DataBind();
                    }
                }
            }
        }

        protected void btnSearchUser_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtSearch.Text))
            {
                pnlSearchResults.Visible = false;
                return;
            }

            DataTable dtUsers = DatabaseHelper.SearchRegisteredUsers(txtSearch.Text.Trim(), CurrentUserId);

            pnlSearchResults.Visible = true;

            if (dtUsers != null && dtUsers.Rows.Count > 0)
            {
                rptSearchResults.DataSource = dtUsers;
                rptSearchResults.DataBind();
                lblNoUsersFound.Visible = false;
            }
            else
            {
                rptSearchResults.DataSource = null;
                rptSearchResults.DataBind();
                lblNoUsersFound.Visible = true;
            }
        }

        protected void rptSearchResults_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "StartChatWithUser")
            {
                int targetUserId = Convert.ToInt32(e.CommandArgument);

                pnlSearchResults.Visible = false;
                txtSearch.Text = "";

                SelectUserById(targetUserId);
            }
        }

        protected void btnSubmitRating_Click(object sender, EventArgs e)
        {
            if (SelectedOtherUserId <= 0 || ActiveProjectId <= 0) return;

            int score = Convert.ToInt32(ddlRatingStars.SelectedValue);
            string comment = txtRatingComment.Text.Trim();
            decimal updatedScore = 0.00m;

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                conn.Open();
                string insertQuery = @"
                    INSERT INTO dbo.Rating (projectID, raterUserID, ratedUserID, score, ratingComment, ratingDate)
                    VALUES (@ProjectID, @RaterUserID, @RatedUserID, @Score, @Comment, GETDATE())";

                using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@ProjectID", ActiveProjectId);
                    cmd.Parameters.AddWithValue("@RaterUserID", CurrentUserId);
                    cmd.Parameters.AddWithValue("@RatedUserID", SelectedOtherUserId);
                    cmd.Parameters.AddWithValue("@Score", score);
                    cmd.Parameters.AddWithValue("@Comment", string.IsNullOrEmpty(comment) ? (object)DBNull.Value : comment);
                    cmd.ExecuteNonQuery();
                }

                string updateQuery = @"
                    UPDATE dbo.[User]
                    SET ratingScore = (SELECT CAST(AVG(CAST(score AS DECIMAL(3,2))) AS DECIMAL(3,2)) FROM dbo.Rating WHERE ratedUserID = @RatedUserID)
                    OUTPUT INSERTED.ratingScore WHERE userID = @RatedUserID";

                using (SqlCommand cmdUpdate = new SqlCommand(updateQuery, conn))
                {
                    cmdUpdate.Parameters.AddWithValue("@RatedUserID", SelectedOtherUserId);
                    object res = cmdUpdate.ExecuteScalar();
                    if (res != null) updatedScore = Convert.ToDecimal(res);
                }
            }

            pnlRatingModal.Visible = false;
            ShowStatus($"Rating submitted! Reputation score updated to {updatedScore:F1} / 5.0.");
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            pnlRatingModal.Visible = false;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindApprovedChatUsers(txtSearch.Text.Trim());
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            BindApprovedChatUsers(txtSearch.Text.Trim());
        }

        private void ShowStatus(string message)
        {
            pnlStatus.Visible = true;
            lblStatus.Text = message;
        }
    }
}
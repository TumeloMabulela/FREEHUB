using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;

namespace FreeHubProject
{
    public static class DatabaseHelper
    {
        // Resolve the connection string lazily (per call) rather than in a static field.
        // A static field initializer that throws makes the WHOLE class unusable with the
        // confusing "The type initializer for 'DatabaseHelper' threw an exception" error.
        // Resolving it here means a missing/invalid config produces a clear, direct message.
        private static string GetConnectionString()
        {
            var setting = ConfigurationManager.ConnectionStrings["FreeHubDB"];
            if (setting == null || string.IsNullOrWhiteSpace(setting.ConnectionString))
            {
                throw new ConfigurationErrorsException(
                    "Database connection string 'FreeHubDB' is missing or empty. " +
                    "Ensure ConnectionStrings.config exists next to Web.config and contains the FreeHubDB entry.");
            }
            return setting.ConnectionString;
        }

        public static SqlConnection GetConnection()
        {
            return new SqlConnection(GetConnectionString());
        }

        // ============================================================
        // GENERAL EXECUTORS
        // ============================================================

        public static DataTable ExecuteQuery(string query, params SqlParameter[] parameters)
        {
            DataTable table = new DataTable();
            using (SqlConnection conn = GetConnection())
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null) cmd.Parameters.AddRange(parameters);
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        adapter.Fill(table);
                    }
                }
            }
            return table;
        }

        // Alias for ExecuteQuery for compatibility across modules
        public static DataTable GetDataTable(string query, params SqlParameter[] parameters)
        {
            return ExecuteQuery(query, parameters);
        }

        // Returns a single DataRow
        public static DataRow GetDataRow(string query, params SqlParameter[] parameters)
        {
            DataTable dt = GetDataTable(query, parameters);
            return (dt != null && dt.Rows.Count > 0) ? dt.Rows[0] : null;
        }

        public static int ExecuteNonQuery(string query, params SqlParameter[] parameters)
        {
            using (SqlConnection conn = GetConnection())
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null) cmd.Parameters.AddRange(parameters);
                    conn.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        public static object ExecuteScalar(string query, params SqlParameter[] parameters)
        {
            using (SqlConnection conn = GetConnection())
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null) cmd.Parameters.AddRange(parameters);
                    conn.Open();
                    return cmd.ExecuteScalar();
                }
            }
        }

        // Password hashing using SHA256
        public static string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }

        // ============================================================
        // USER AUTHENTICATION & REGISTRATION
        // ============================================================

        public static bool EmailExists(string email)
        {
            string query = "SELECT COUNT(*) FROM [User] WHERE email = @Email";
            object result = ExecuteScalar(query, new SqlParameter("@Email", email));
            return Convert.ToInt32(result) > 0;
        }

        public static bool UsernameExists(string username)
        {
            string query = "SELECT COUNT(*) FROM [User] WHERE username = @Username";
            object result = ExecuteScalar(query, new SqlParameter("@Username", username));
            return Convert.ToInt32(result) > 0;
        }

        public static int RegisterUser(string firstName, string lastName, string email,
            string contactNumber, string username, string password, string userType)
        {
            string hashedPassword = HashPassword(password);

            string query = @"
                INSERT INTO [User] (firstName, lastName, email, contactNumber, username, password, accountStatus, userType, ratingScore)
                VALUES (@FirstName, @LastName, @Email, @ContactNumber, @Username, @Password, 'Active', @UserType, 0.00);
                SELECT SCOPE_IDENTITY();";

            object result = ExecuteScalar(query,
                new SqlParameter("@FirstName", firstName),
                new SqlParameter("@LastName", lastName),
                new SqlParameter("@Email", email),
                new SqlParameter("@ContactNumber", string.IsNullOrEmpty(contactNumber) ? (object)DBNull.Value : contactNumber),
                new SqlParameter("@Username", username),
                new SqlParameter("@Password", hashedPassword),
                new SqlParameter("@UserType", userType)
            );

            if (result == null || result == DBNull.Value) return -1;

            int userID = Convert.ToInt32(result);
            CreateWallet(userID);
            return userID;
        }

        public static void CreateWallet(int userID)
        {
            string query = "INSERT INTO Wallet (userID, balance, walletStatus) VALUES (@UserID, 0.00, 'Active')";
            ExecuteNonQuery(query, new SqlParameter("@UserID", userID));
        }

        public static DataRow AuthenticateUser(string emailOrUsername, string password)
        {
            string hashedPassword = HashPassword(password);

            string query = @"
                SELECT userID, firstName, lastName, email, contactNumber, username,
                       accountStatus, userType, ratingScore, dateCreated
                FROM [User]
                WHERE (LOWER(email) = LOWER(@Login) OR LOWER(username) = LOWER(@Login))
                  AND password = @Password";

            DataTable result = ExecuteQuery(query,
                new SqlParameter("@Login", emailOrUsername.Trim()),
                new SqlParameter("@Password", hashedPassword)
            );

            if (result.Rows.Count > 0) return result.Rows[0];

            result = ExecuteQuery(query,
                new SqlParameter("@Login", emailOrUsername.Trim()),
                new SqlParameter("@Password", password)
            );

            if (result.Rows.Count > 0) return result.Rows[0];

            string findQuery = @"
                SELECT userID, firstName, lastName, email, contactNumber, username,
                       accountStatus, userType, ratingScore, dateCreated, password
                FROM [User]
                WHERE LOWER(email) = LOWER(@Login) OR LOWER(username) = LOWER(@Login)";

            DataTable findResult = ExecuteQuery(findQuery,
                new SqlParameter("@Login", emailOrUsername.Trim())
            );

            if (findResult.Rows.Count > 0)
            {
                string storedPassword = Convert.ToString(findResult.Rows[0]["password"]);
                if (storedPassword == password || storedPassword == hashedPassword)
                {
                    return findResult.Rows[0];
                }
            }

            return null;
        }

        public static DataRow GetUserById(int userID)
        {
            string query = @"SELECT userID, firstName, lastName, email, contactNumber,
                    username, accountStatus, userType, ratingScore, dateCreated, lastSeen
                    FROM [User] WHERE userID = @UserID";
            DataTable result = ExecuteQuery(query, new SqlParameter("@UserID", userID));
            if (result.Rows.Count > 0) return result.Rows[0];
            return null;
        }

        public static DataRow GetWalletByUserId(int userID)
        {
            string query = "SELECT walletID, userID, balance, dateCreated, walletStatus FROM Wallet WHERE userID = @UserID";
            DataTable result = ExecuteQuery(query, new SqlParameter("@UserID", userID));
            if (result.Rows.Count > 0) return result.Rows[0];
            return null;
        }

        public static DataRow GetEmployerByUserId(int userID)
        {
            string query = "SELECT employerID, userID, companyName, industry, description, contactEmail FROM Employer WHERE userID = @UserID";
            DataTable result = ExecuteQuery(query, new SqlParameter("@UserID", userID));
            if (result.Rows.Count > 0) return result.Rows[0];
            return null;
        }

        public static DataRow GetFreelancerByUserId(int userID)
        {
            string query = "SELECT freelancerID, userID, skills, experience, portfolioLinks, hourlyRate FROM Freelancer WHERE userID = @UserID";
            DataTable result = ExecuteQuery(query, new SqlParameter("@UserID", userID));
            if (result.Rows.Count > 0) return result.Rows[0];
            return null;
        }

        // ============================================================
        // PROFILE STATUS MANAGEMENT
        // ============================================================

        public static void EnsureProfileStatusTable()
        {
            string query = @"
                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProfileStatus')
                BEGIN
                    CREATE TABLE dbo.ProfileStatus (
                        profileStatusID INT IDENTITY(1,1) PRIMARY KEY,
                        userID INT NOT NULL,
                        profileType NVARCHAR(20) NOT NULL,
                        status NVARCHAR(20) NOT NULL DEFAULT 'Active',
                        deactivatedDate DATETIME NULL,
                        reactivatedDate DATETIME NULL,
                        CONSTRAINT UQ_ProfileStatus UNIQUE(userID, profileType)
                    )
                END";
            ExecuteNonQuery(query);
        }

        public static string GetProfileStatus(int userID, string profileType)
        {
            bool profileExists = false;
            if (profileType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
                profileExists = GetFreelancerByUserId(userID) != null;
            else if (profileType.Equals("Employer", StringComparison.OrdinalIgnoreCase))
                profileExists = GetEmployerByUserId(userID) != null;

            if (!profileExists) return "NotCreated";

            EnsureProfileStatusTable();
            string query = "SELECT status FROM ProfileStatus WHERE userID = @UserID AND profileType = @ProfileType";
            object result = ExecuteScalar(query,
                new SqlParameter("@UserID", userID),
                new SqlParameter("@ProfileType", profileType));

            if (result == null || result == DBNull.Value)
            {
                ExecuteNonQuery(
                    "INSERT INTO ProfileStatus (userID, profileType, status) VALUES (@UserID, @ProfileType, 'Active')",
                    new SqlParameter("@UserID", userID),
                    new SqlParameter("@ProfileType", profileType));
                return "Active";
            }

            return Convert.ToString(result);
        }

        public static bool DeactivateUserProfile(int userID, string profileType)
        {
            EnsureProfileStatusTable();
            string query = @"
                IF EXISTS (SELECT 1 FROM ProfileStatus WHERE userID = @UserID AND profileType = @ProfileType)
                    UPDATE ProfileStatus SET status = 'Deactivated', deactivatedDate = GETDATE()
                    WHERE userID = @UserID AND profileType = @ProfileType
                ELSE
                    INSERT INTO ProfileStatus (userID, profileType, status, deactivatedDate)
                    VALUES (@UserID, @ProfileType, 'Deactivated', GETDATE())";

            int rows = ExecuteNonQuery(query,
                new SqlParameter("@UserID", userID),
                new SqlParameter("@ProfileType", profileType));
            return rows > 0;
        }

        public static bool ReactivateUserProfile(int userID, string profileType)
        {
            EnsureProfileStatusTable();
            string query = @"
                IF EXISTS (SELECT 1 FROM ProfileStatus WHERE userID = @UserID AND profileType = @ProfileType)
                    UPDATE ProfileStatus SET status = 'Active', reactivatedDate = GETDATE()
                    WHERE userID = @UserID AND profileType = @ProfileType
                ELSE
                    INSERT INTO ProfileStatus (userID, profileType, status, reactivatedDate)
                    VALUES (@UserID, @ProfileType, 'Active', GETDATE())";

            int rows = ExecuteNonQuery(query,
                new SqlParameter("@UserID", userID),
                new SqlParameter("@ProfileType", profileType));

            ExecuteNonQuery(
                "UPDATE [User] SET accountStatus = 'Active', userType = @ProfileType WHERE userID = @UserID",
                new SqlParameter("@ProfileType", profileType),
                new SqlParameter("@UserID", userID));

            return rows > 0;
        }

        public static void GetUserProfileStatuses(int userID, out string freelancerStatus, out string employerStatus)
        {
            freelancerStatus = GetProfileStatus(userID, "Freelancer");
            employerStatus = GetProfileStatus(userID, "Employer");
        }

        // ============================================================
        // PROJECT OPERATIONS
        // ============================================================

        public static DataRow GetProjectById(int projectID)
        {
            string query = @"SELECT p.projectID, p.title, p.description, p.category, p.budget,
                            p.budgetType, p.dateCreated, p.deadline, p.projectStatus,
                            p.experienceLevel, p.skills, p.employerID,
                            e.companyName, u.firstName + ' ' + u.lastName AS employerName
                            FROM Project p
                            INNER JOIN Employer e ON p.employerID = e.employerID
                            INNER JOIN [User] u ON e.userID = u.userID
                            WHERE p.projectID = @ProjectID";
            DataTable result = ExecuteQuery(query, new SqlParameter("@ProjectID", projectID));
            if (result.Rows.Count > 0) return result.Rows[0];
            return null;
        }

        public static DataTable GetOpenProjects()
        {
            string query = @"SELECT p.projectID, p.title, p.description, p.category, p.budget,
                            p.budgetType, p.dateCreated, p.deadline, p.projectStatus,
                            p.experienceLevel, p.skills, e.companyName,
                            u.firstName + ' ' + u.lastName AS employerName
                            FROM Project p
                            INNER JOIN Employer e ON p.employerID = e.employerID
                            INNER JOIN [User] u ON e.userID = u.userID
                            WHERE p.projectStatus = 'Open'
                            ORDER BY p.dateCreated DESC";
            return ExecuteQuery(query);
        }

        /// <summary>
        /// Open projects for freelancer discovery, EXCLUDING projects posted by the
        /// given registered user's own Employer profile. The exclusion compares the
        /// underlying account (Employer.userID), not the selected profile, so a user
        /// with both profiles never sees their own employer projects while browsing.
        /// </summary>
        public static DataTable GetOpenProjectsExcludingOwner(int excludeUserID)
        {
            string query = @"SELECT p.projectID, p.title, p.description, p.category, p.budget,
                            p.budgetType, p.dateCreated, p.deadline, p.projectStatus,
                            p.experienceLevel, p.skills, e.companyName,
                            u.firstName + ' ' + u.lastName AS employerName
                            FROM Project p
                            INNER JOIN Employer e ON p.employerID = e.employerID
                            INNER JOIN [User] u ON e.userID = u.userID
                            WHERE p.projectStatus = 'Open'
                              AND e.userID <> @ExcludeUserID
                            ORDER BY p.dateCreated DESC";
            return ExecuteQuery(query, new SqlParameter("@ExcludeUserID", excludeUserID));
        }

        /// <summary>
        /// Returns true if the given project was posted by the given registered user's
        /// own Employer profile (resolved via Project.employerID -> Employer.userID).
        /// Used to block a freelancer from applying to their own employer project.
        /// </summary>
        public static bool IsProjectOwnedByUser(int projectID, int userID)
        {
            string query = @"SELECT COUNT(*)
                             FROM Project p
                             INNER JOIN Employer e ON p.employerID = e.employerID
                             WHERE p.projectID = @ProjectID AND e.userID = @UserID";
            object result = ExecuteScalar(query,
                new SqlParameter("@ProjectID", projectID),
                new SqlParameter("@UserID", userID));
            return result != null && result != DBNull.Value && Convert.ToInt32(result) > 0;
        }

        public static DataTable GetProjectsByEmployer(int userID)
        {
            string query = @"SELECT p.projectID, p.title, p.description, p.category, p.budget,
                            p.dateCreated, p.deadline, p.projectStatus,
                            (SELECT COUNT(*) FROM Proposal pr WHERE pr.projectID = p.projectID) AS proposalCount
                            FROM Project p
                            INNER JOIN Employer e ON p.employerID = e.employerID
                            WHERE e.userID = @UserID
                            ORDER BY p.dateCreated DESC";
            return ExecuteQuery(query, new SqlParameter("@UserID", userID));
        }

        // ============================================================
        // PROPOSAL OPERATIONS
        // ============================================================

        public static int SubmitProposal(int projectID, int userID, string coverLetter,
            decimal proposedRate, string estimatedTime)
        {
            // Defense-in-depth: never allow a proposal on a project posted by the same
            // registered account's own Employer profile, no matter the caller. Returns
            // -2 so callers can distinguish this from a generic failure. No record is
            // created or modified when this guard trips.
            if (IsProjectOwnedByUser(projectID, userID))
            {
                return -2;
            }

            DataRow freelancer = GetFreelancerByUserId(userID);
            int freelancerID;

            if (freelancer != null)
            {
                freelancerID = Convert.ToInt32(freelancer["freelancerID"]);
            }
            else
            {
                string createQuery = @"INSERT INTO Freelancer (userID, skills, experience, portfolioLinks, hourlyRate)
                                      VALUES (@UserID, 'General', '', '', @Rate);
                                      SELECT SCOPE_IDENTITY();";
                object newId = ExecuteScalar(createQuery,
                    new SqlParameter("@UserID", userID),
                    new SqlParameter("@Rate", proposedRate));
                freelancerID = Convert.ToInt32(newId);
            }

            string checkQuery = "SELECT COUNT(*) FROM Proposal WHERE projectID = @ProjectID AND freelancerID = @FreelancerID";
            object existsResult = ExecuteScalar(checkQuery,
                new SqlParameter("@ProjectID", projectID),
                new SqlParameter("@FreelancerID", freelancerID));

            if (Convert.ToInt32(existsResult) > 0)
            {
                return -1; // Already submitted
            }

            string insertQuery = @"INSERT INTO Proposal (projectID, freelancerID, coverLetter, proposedRate, estimatedCompletionTime, status)
                                  VALUES (@ProjectID, @FreelancerID, @CoverLetter, @ProposedRate, @EstimatedTime, 'Pending');
                                  SELECT SCOPE_IDENTITY();";

            object result = ExecuteScalar(insertQuery,
                new SqlParameter("@ProjectID", projectID),
                new SqlParameter("@FreelancerID", freelancerID),
                new SqlParameter("@CoverLetter", coverLetter),
                new SqlParameter("@ProposedRate", proposedRate),
                new SqlParameter("@EstimatedTime", estimatedTime));

            if (result != null && result != DBNull.Value)
            {
                return Convert.ToInt32(result);
            }

            return 0;
        }

        public static DataTable GetProposalsByProject(int projectID)
        {
            string query = @"SELECT pr.proposalID, pr.coverLetter, pr.proposedRate,
                            pr.estimatedCompletionTime, pr.status, pr.date,
                            u.firstName + ' ' + u.lastName AS freelancerName,
                            u.ratingScore, f.skills
                            FROM Proposal pr
                            INNER JOIN Freelancer f ON pr.freelancerID = f.freelancerID
                            INNER JOIN [User] u ON f.userID = u.userID
                            WHERE pr.projectID = @ProjectID
                            ORDER BY pr.date DESC";
            return ExecuteQuery(query, new SqlParameter("@ProjectID", projectID));
        }

        public static DataTable GetProposalsByFreelancer(int userID)
        {
            string query = @"SELECT pr.proposalID, pr.coverLetter, pr.proposedRate,
                            pr.estimatedCompletionTime, pr.status, pr.date,
                            p.title AS projectTitle, p.budget, p.category
                            FROM Proposal pr
                            INNER JOIN Project p ON pr.projectID = p.projectID
                            INNER JOIN Freelancer f ON pr.freelancerID = f.freelancerID
                            WHERE f.userID = @UserID
                            ORDER BY pr.date DESC";
            return ExecuteQuery(query, new SqlParameter("@UserID", userID));
        }

        // ============================================================
        // WALLET OPERATIONS
        // ============================================================

        public static void UpdateWalletBalance(int walletID, decimal newBalance)
        {
            string query = "UPDATE Wallet SET balance = @Balance WHERE walletID = @WalletID";
            ExecuteNonQuery(query,
                new SqlParameter("@Balance", newBalance),
                new SqlParameter("@WalletID", walletID));
        }

        public static int AddTransaction(int walletID, string description,
            string transactionType, decimal amount, string status,
            string reference, string paymentMethod)
        {
            string query = @"
                INSERT INTO [Transaction]
                    (walletID, itemDescription, transactionType, transactionAmount,
                     transactionStatus, reference, paymentMethod)
                VALUES
                    (@WalletID, @Description, @Type, @Amount,
                     @Status, @Reference, @PaymentMethod);
                SELECT SCOPE_IDENTITY();";

            object result = ExecuteScalar(query,
                new SqlParameter("@WalletID", walletID),
                new SqlParameter("@Description", description ?? ""),
                new SqlParameter("@Type", transactionType),
                new SqlParameter("@Amount", Math.Abs(amount)),
                new SqlParameter("@Status", status ?? "Completed"),
                new SqlParameter("@Reference", reference ?? ""),
                new SqlParameter("@PaymentMethod", paymentMethod ?? ""));

            if (result != null && result != DBNull.Value)
                return Convert.ToInt32(result);

            return 0;
        }

        public static DataTable GetTransactionsByWallet(int walletID)
        {
            string query = @"
                SELECT transactionID, walletID, itemDescription, transactionType,
                       transactionAmount, transactionDate, transactionStatus,
                       reference, paymentMethod
                FROM [Transaction]
                WHERE walletID = @WalletID
                ORDER BY transactionDate DESC";

            return ExecuteQuery(query, new SqlParameter("@WalletID", walletID));
        }

        public static decimal GetWalletBalance(int walletID)
        {
            string query = "SELECT balance FROM Wallet WHERE walletID = @WalletID";
            object result = ExecuteScalar(query, new SqlParameter("@WalletID", walletID));
            if (result != null && result != DBNull.Value)
                return Convert.ToDecimal(result);
            return 0.00m;
        }

        public static DataRow GetTransactionById(int transactionID)
        {
            string query = @"
                SELECT transactionID, walletID, itemDescription, transactionType,
                       transactionAmount, transactionDate, transactionStatus,
                       reference, paymentMethod
                FROM [Transaction]
                WHERE transactionID = @TransactionID";
            DataTable result = ExecuteQuery(query,
                new SqlParameter("@TransactionID", transactionID));
            if (result.Rows.Count > 0) return result.Rows[0];
            return null;
        }


        // ============================================================
        // COMMENT OPERATIONS (B400)
        // ============================================================

        public static int AddComment(int projectID, int userID, string commentText)
        {
            string query = @"INSERT INTO Comment (projectID, userID, commentText)
                            VALUES (@ProjectID, @UserID, @CommentText);
                            SELECT SCOPE_IDENTITY();";
            object result = ExecuteScalar(query,
                new SqlParameter("@ProjectID", projectID),
                new SqlParameter("@UserID", userID),
                new SqlParameter("@CommentText", commentText));
            if (result != null && result != DBNull.Value)
                return Convert.ToInt32(result);
            return 0;
        }

        public static DataTable GetCommentsByProject(int projectID)
        {
            string query = @"SELECT c.commentID, c.commentText, c.commentDate,
                            u.firstName + ' ' + u.lastName AS authorName, u.userType, u.userID
                            FROM Comment c
                            INNER JOIN [User] u ON c.userID = u.userID
                            WHERE c.projectID = @ProjectID
                            ORDER BY c.commentDate DESC";
            return ExecuteQuery(query, new SqlParameter("@ProjectID", projectID));
        }
        public static string FormatEmail(string email)
        {
            return string.IsNullOrWhiteSpace(email) ? "" : email.Trim().ToLower();
        }
        public static string CapitalizeName(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "";
            name = name.Trim();
            return char.ToUpper(name[0]) + (name.Length > 1 ? name.Substring(1).ToLower() : "");
        }
        public static DataTable SearchRegisteredUsers(string searchTerm, int currentUserId)
        {
            string query = @"
        SELECT userID, firstName, lastName, email, userType 
        FROM dbo.[User] 
        WHERE userID != @CurrentUserID 
          AND accountStatus != 'Deleted'
          AND (firstName LIKE @Search OR lastName LIKE @Search OR email LIKE @Search OR username LIKE @Search)
        ORDER BY firstName ASC";

            string formattedSearch = "%" + searchTerm.Trim() + "%";

            return GetDataTable(query,
                new SqlParameter("@CurrentUserID", currentUserId),
                new SqlParameter("@Search", formattedSearch));
        }
        /// <summary>
        /// Capitalizes comma-separated skill inputs (e.g., "c#, web development" -> "C#, Web Development").
        /// </summary>
        /// <summary>
        /// Capitalizes comma-separated skill inputs (e.g., "c#, web development" -> "C#, Web Development").
        /// </summary>/// <param name="projectId">Optional project ID associated with the conversation.</param>
        // Updates user's last active / logout timestamp
        // Updates user's last active timestamp
        public static void UpdateUserLastSeen(int userId)
        {
            string query = "UPDATE dbo.[User] SET lastSeen = GETDATE() WHERE userID = @UserID";
            ExecuteNonQuery(query, new SqlParameter("@UserID", userId));
        }

        // Formats Last Seen for display next to the chat header
        public static string GetUserOnlineStatus(int targetUserId)
        {
            DataRow user = GetUserById(targetUserId);
            if (user == null) return "Offline";

            string accountStatus = Convert.ToString(user["accountStatus"]);
            if (accountStatus == "Inactive" || accountStatus == "Deleted") return "Offline";

            if (user["lastSeen"] == DBNull.Value) return "Offline";

            // lastSeen is stored as UTC (Azure SQL GETDATE()). Compute the age against
            // UTC so the online window is correct regardless of the web host's time zone,
            // and display the timestamp in South Africa time.
            DateTime lastSeenUtc = Convert.ToDateTime(user["lastSeen"]);
            TimeSpan diff = DateTime.UtcNow - lastSeenUtc;
            DateTime lastSeen = TimeHelper.ToSast(lastSeenUtc);

            // Consider online if active within the last 3 minutes
            if (diff.TotalMinutes < 3)
            {
                return "Online 🟢";
            }

            if (diff.TotalMinutes < 60)
                return string.Format("Last seen {0}m ago", (int)diff.TotalMinutes);

            if (diff.TotalHours < 24)
                return string.Format("Last seen today at {0:HH:mm}", lastSeen);

            return string.Format("Last seen {0:dd MMM} at {1:HH:mm}", lastSeen, lastSeen);
        }
        // Formats Last Seen for display
        
        // Marks unread messages as 'Read' when a chat session is opened
        public static void MarkMessagesAsRead(int currentUserId, int senderUserId, int? projectId = null)
        {
            string query = @"
        UPDATE dbo.Message 
        SET status = 'Read', readTimestamp = GETDATE() 
        WHERE receiverID = @CurrentUserID 
          AND senderID = @SenderID 
          AND status != 'Read'";

            if (projectId.HasValue && projectId.Value > 0)
            {
                query += " AND projectID = @ProjectID";
                ExecuteNonQuery(query,
                    new SqlParameter("@CurrentUserID", currentUserId),
                    new SqlParameter("@SenderID", senderUserId),
                    new SqlParameter("@ProjectID", projectId.Value));
            }
            else
            {
                ExecuteNonQuery(query,
                    new SqlParameter("@CurrentUserID", currentUserId),
                    new SqlParameter("@SenderID", senderUserId));
            }
        }

        /// <summary>
        /// Marks all 'Sent' messages addressed to a user as 'Delivered'.
        /// Called when the user loads the Messages page, meaning the messages have
        /// reached their client. Senders then see ✓✓ (gray) instead of single ✓.
        /// </summary>
        public static void MarkMessagesAsDelivered(int receiverUserId)
        {
            string query = @"
                UPDATE dbo.Message 
                SET status = 'Delivered' 
                WHERE receiverID = @ReceiverID 
                  AND status = 'Sent'";
            ExecuteNonQuery(query, new SqlParameter("@ReceiverID", receiverUserId));
        }

        public static string CapitalizeSkills(string skills)
        {
            if (string.IsNullOrWhiteSpace(skills)) return "";

            string[] parts = skills.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            for (int i = 0; i < parts.Length; i++)
            {
                string trimmed = parts[i].Trim();
                if (trimmed.Length > 0)
                {
                    parts[i] = char.ToUpper(trimmed[0]) + (trimmed.Length > 1 ? trimmed.Substring(1) : "");
                }
            }

            return string.Join(", ", parts);
        }

        // ============================================================
        // ADMIN OPERATIONS
        // Admin is User #1 / Admin #1 (seeded). These helpers power the
        // admin portal: dispute resolution, refund & withdrawal approval,
        // and the admin support inbox fed by the Help links.
        // ============================================================

        /// <summary>The seeded platform admin user id (User #1).</summary>
        public const int AdminUserId = 1;

        /// <summary>Resolve the Admin.adminID for a given admin user id (defaults to 1).</summary>
        public static int GetAdminId(int adminUserId)
        {
            object result = ExecuteScalar(
                "SELECT TOP 1 adminID FROM dbo.Admin WHERE userID = @UserID ORDER BY adminID",
                new SqlParameter("@UserID", adminUserId));
            if (result != null && result != DBNull.Value) return Convert.ToInt32(result);
            return 0;
        }

        // ---------- Disputes (admin side) ----------

        public static DataTable GetAllDisputes(string statusFilter = null)
        {
            string query = @"
                SELECT d.disputeID, d.userID, d.projectID, d.transactionID,
                       d.disputeDescription, d.reason, d.status, d.dateCreated,
                       d.adminID, d.adminComment, d.resolvedDate,
                       (u.firstName + ' ' + u.lastName) AS raisedByName,
                       u.email AS raisedByEmail
                FROM dbo.Dispute d
                INNER JOIN dbo.[User] u ON d.userID = u.userID";
            if (!string.IsNullOrWhiteSpace(statusFilter) && !statusFilter.Equals("All", StringComparison.OrdinalIgnoreCase))
            {
                query += " WHERE d.status = @Status";
                query += " ORDER BY d.dateCreated DESC";
                return ExecuteQuery(query, new SqlParameter("@Status", statusFilter));
            }
            query += " ORDER BY d.dateCreated DESC";
            return ExecuteQuery(query);
        }

        public static DataRow GetDisputeById(int disputeID)
        {
            string query = @"
                SELECT d.disputeID, d.userID, d.projectID, d.transactionID,
                       d.disputeDescription, d.reason, d.status, d.dateCreated,
                       d.adminID, d.adminComment, d.resolvedDate,
                       (u.firstName + ' ' + u.lastName) AS raisedByName
                FROM dbo.Dispute d
                INNER JOIN dbo.[User] u ON d.userID = u.userID
                WHERE d.disputeID = @DisputeID";
            return GetDataRow(query, new SqlParameter("@DisputeID", disputeID));
        }

        /// <summary>Admin updates a dispute's status (and optional comment). On Resolved/Closed, stamps resolvedDate.</summary>
        public static bool ResolveDispute(int disputeID, int adminUserId, string newStatus, string adminComment)
        {
            int adminId = GetAdminId(adminUserId);
            bool closing = newStatus.Equals("Resolved", StringComparison.OrdinalIgnoreCase) ||
                           newStatus.Equals("Closed", StringComparison.OrdinalIgnoreCase);
            string query = @"
                UPDATE dbo.Dispute
                SET status = @Status,
                    adminID = @AdminID,
                    adminComment = @AdminComment,
                    resolvedDate = " + (closing ? "GETDATE()" : "NULL") + @"
                WHERE disputeID = @DisputeID";
            int rows = ExecuteNonQuery(query,
                new SqlParameter("@Status", newStatus),
                new SqlParameter("@AdminID", adminId > 0 ? (object)adminId : DBNull.Value),
                new SqlParameter("@AdminComment", string.IsNullOrEmpty(adminComment) ? (object)DBNull.Value : adminComment),
                new SqlParameter("@DisputeID", disputeID));
            return rows > 0;
        }

        public static int GetUserIdForDispute(int disputeID)
        {
            object result = ExecuteScalar("SELECT userID FROM dbo.Dispute WHERE disputeID = @DisputeID",
                new SqlParameter("@DisputeID", disputeID));
            return (result != null && result != DBNull.Value) ? Convert.ToInt32(result) : 0;
        }

        // ---------- Refunds (admin side) ----------
        // A refund is a dbo.[Transaction] with transactionType = 'Refund'.

        public static DataTable GetAllRefunds(string statusFilter = null)
        {
            string query = @"
                SELECT t.transactionID, t.walletID, t.itemDescription, t.transactionType,
                       t.transactionAmount, t.transactionDate, t.transactionStatus,
                       t.reference, t.paymentMethod,
                       w.userID AS walletUserID,
                       (u.firstName + ' ' + u.lastName) AS ownerName, u.email AS ownerEmail
                FROM dbo.[Transaction] t
                INNER JOIN dbo.Wallet w ON t.walletID = w.walletID
                INNER JOIN dbo.[User] u ON w.userID = u.userID
                WHERE t.transactionType = 'Refund'";
            if (!string.IsNullOrWhiteSpace(statusFilter) && !statusFilter.Equals("All", StringComparison.OrdinalIgnoreCase))
            {
                query += " AND t.transactionStatus = @Status";
                query += " ORDER BY t.transactionDate DESC";
                return ExecuteQuery(query, new SqlParameter("@Status", statusFilter));
            }
            query += " ORDER BY t.transactionDate DESC";
            return ExecuteQuery(query);
        }

        /// <summary>
        /// Approve a pending refund: flip the transaction to Completed and credit the
        /// owner's wallet with the refund amount. Returns the walletUserID (0 on failure).
        /// </summary>
        public static int ApproveRefund(int transactionID)
        {
            DataRow txn = GetTransactionById(transactionID);
            if (txn == null) return 0;
            if (!Convert.ToString(txn["transactionType"]).Equals("Refund", StringComparison.OrdinalIgnoreCase))
                return 0;
            if (Convert.ToString(txn["transactionStatus"]).Equals("Completed", StringComparison.OrdinalIgnoreCase))
                return 0; // already done

            int walletID = Convert.ToInt32(txn["walletID"]);
            decimal amount = Convert.ToDecimal(txn["transactionAmount"]);

            decimal balance = GetWalletBalance(walletID);
            UpdateWalletBalance(walletID, balance + amount);

            ExecuteNonQuery(
                "UPDATE dbo.[Transaction] SET transactionStatus = 'Completed' WHERE transactionID = @Id",
                new SqlParameter("@Id", transactionID));

            object owner = ExecuteScalar("SELECT userID FROM dbo.Wallet WHERE walletID = @W",
                new SqlParameter("@W", walletID));
            return (owner != null && owner != DBNull.Value) ? Convert.ToInt32(owner) : 0;
        }

        /// <summary>Reject a pending refund: mark the transaction Failed and record the reason. Returns walletUserID.</summary>
        public static int RejectRefund(int transactionID, string reason = null)
        {
            DataRow txn = GetTransactionById(transactionID);
            if (txn == null) return 0;
            int walletID = Convert.ToInt32(txn["walletID"]);
            StampRejectionReason(transactionID, reason);
            ExecuteNonQuery(
                "UPDATE dbo.[Transaction] SET transactionStatus = 'Failed' WHERE transactionID = @Id AND transactionType = 'Refund'",
                new SqlParameter("@Id", transactionID));
            object owner = ExecuteScalar("SELECT userID FROM dbo.Wallet WHERE walletID = @W",
                new SqlParameter("@W", walletID));
            return (owner != null && owner != DBNull.Value) ? Convert.ToInt32(owner) : 0;
        }

        /// <summary>
        /// Append a rejection reason to a transaction's itemDescription so it is
        /// persisted on the record (and later visible to the user in their history).
        /// </summary>
        private static void StampRejectionReason(int transactionID, string reason)
        {
            if (string.IsNullOrWhiteSpace(reason)) return;
            string note = " [Rejected: " + reason.Trim() + "]";
            ExecuteNonQuery(
                @"UPDATE dbo.[Transaction]
                  SET itemDescription = LEFT(ISNULL(itemDescription,'') + @Note, 500)
                  WHERE transactionID = @Id",
                new SqlParameter("@Note", note),
                new SqlParameter("@Id", transactionID));
        }

        // ---------- Withdrawals (admin side) ----------
        // Withdrawals are recorded as dbo.[Transaction] of type 'Withdrawal'
        // (the funds are already deducted when the request is created).

        public static DataTable GetAllWithdrawals(string statusFilter = null)
        {
            string query = @"
                SELECT t.transactionID, t.walletID, t.itemDescription, t.transactionType,
                       t.transactionAmount, t.transactionDate, t.transactionStatus,
                       t.reference, t.paymentMethod,
                       w.userID AS walletUserID,
                       (u.firstName + ' ' + u.lastName) AS ownerName, u.email AS ownerEmail
                FROM dbo.[Transaction] t
                INNER JOIN dbo.Wallet w ON t.walletID = w.walletID
                INNER JOIN dbo.[User] u ON w.userID = u.userID
                WHERE t.transactionType = 'Withdrawal'";
            if (!string.IsNullOrWhiteSpace(statusFilter) && !statusFilter.Equals("All", StringComparison.OrdinalIgnoreCase))
            {
                query += " AND t.transactionStatus = @Status";
                query += " ORDER BY t.transactionDate DESC";
                return ExecuteQuery(query, new SqlParameter("@Status", statusFilter));
            }
            query += " ORDER BY t.transactionDate DESC";
            return ExecuteQuery(query);
        }

        /// <summary>Approve a pending withdrawal: mark the transaction Completed. Returns walletUserID.</summary>
        public static int ApproveWithdrawal(int transactionID)
        {
            DataRow txn = GetTransactionById(transactionID);
            if (txn == null) return 0;
            ExecuteNonQuery(
                "UPDATE dbo.[Transaction] SET transactionStatus = 'Completed' WHERE transactionID = @Id AND transactionType = 'Withdrawal'",
                new SqlParameter("@Id", transactionID));
            object owner = ExecuteScalar("SELECT userID FROM dbo.Wallet w INNER JOIN dbo.[Transaction] t ON w.walletID = t.walletID WHERE t.transactionID = @Id",
                new SqlParameter("@Id", transactionID));
            return (owner != null && owner != DBNull.Value) ? Convert.ToInt32(owner) : 0;
        }

        /// <summary>
        /// Reject a pending withdrawal: mark Failed and refund the held amount back to the wallet
        /// (the amount was deducted when the request was created). Returns walletUserID.
        /// </summary>
        public static int RejectWithdrawal(int transactionID, string reason = null)
        {
            DataRow txn = GetTransactionById(transactionID);
            if (txn == null) return 0;
            if (Convert.ToString(txn["transactionStatus"]).Equals("Completed", StringComparison.OrdinalIgnoreCase))
                return 0;
            int walletID = Convert.ToInt32(txn["walletID"]);
            decimal amount = Convert.ToDecimal(txn["transactionAmount"]);

            decimal balance = GetWalletBalance(walletID);
            UpdateWalletBalance(walletID, balance + amount); // return the held funds

            StampRejectionReason(transactionID, reason);
            ExecuteNonQuery(
                "UPDATE dbo.[Transaction] SET transactionStatus = 'Failed' WHERE transactionID = @Id AND transactionType = 'Withdrawal'",
                new SqlParameter("@Id", transactionID));

            object owner = ExecuteScalar("SELECT userID FROM dbo.Wallet WHERE walletID = @W",
                new SqlParameter("@W", walletID));
            return (owner != null && owner != DBNull.Value) ? Convert.ToInt32(owner) : 0;
        }

        // ---------- Admin support inbox (Help routing) ----------
        // The admin's inbox lists every user who has messaged the admin
        // (receiverID = AdminUserId) OR whom the admin has messaged. This
        // bypasses the proposal-join contact query used for normal chat.

        public static DataTable GetAdminConversations(int adminUserId)
        {
            string query = @"
                SELECT
                    u.userID AS UserID,
                    u.userType AS UserType,
                    (u.firstName + ' ' + u.lastName) AS Name,
                    (LEFT(u.firstName,1) + LEFT(u.lastName,1)) AS Initials,
                    ISNULL((SELECT TOP 1 content FROM dbo.Message
                            WHERE (senderID = u.userID AND receiverID = @AdminID)
                               OR (senderID = @AdminID AND receiverID = u.userID)
                            ORDER BY timeStamp DESC), '') AS LastMessage,
                    ISNULL((SELECT TOP 1 FORMAT(DATEADD(HOUR,2,timeStamp),'hh:mm tt') FROM dbo.Message
                            WHERE (senderID = u.userID AND receiverID = @AdminID)
                               OR (senderID = @AdminID AND receiverID = u.userID)
                            ORDER BY timeStamp DESC), '') AS LastTime,
                    (SELECT TOP 1 timeStamp FROM dbo.Message
                            WHERE (senderID = u.userID AND receiverID = @AdminID)
                               OR (senderID = @AdminID AND receiverID = u.userID)
                            ORDER BY timeStamp DESC) AS LastTimeSort,
                    (SELECT COUNT(*) FROM dbo.Message
                            WHERE senderID = u.userID AND receiverID = @AdminID AND status <> 'Read') AS UnreadCount
                FROM dbo.[User] u
                WHERE u.userID <> @AdminID
                  AND EXISTS (SELECT 1 FROM dbo.Message m
                              WHERE (m.senderID = u.userID AND m.receiverID = @AdminID)
                                 OR (m.senderID = @AdminID AND m.receiverID = u.userID))
                ORDER BY LastTimeSort DESC";
            return ExecuteQuery(query, new SqlParameter("@AdminID", adminUserId));
        }

        public static DataTable GetConversation(int userA, int userB)
        {
            string query = @"
                SELECT messageID, senderID, receiverID, content, attachmentUrl,
                       timeStamp, status
                FROM dbo.Message
                WHERE (senderID = @A AND receiverID = @B)
                   OR (senderID = @B AND receiverID = @A)
                ORDER BY timeStamp ASC";
            return ExecuteQuery(query,
                new SqlParameter("@A", userA),
                new SqlParameter("@B", userB));
        }

        /// <summary>Insert a plain (projectID NULL) message. Returns new messageID.</summary>
        public static int SendMessage(int senderID, int receiverID, string content, string attachmentUrl = null)
        {
            string query = @"
                INSERT INTO dbo.Message (senderID, receiverID, projectID, content, attachmentUrl, timeStamp, status)
                VALUES (@Sender, @Receiver, NULL, @Content, @Attachment, GETDATE(), 'Sent');
                SELECT SCOPE_IDENTITY();";
            object result = ExecuteScalar(query,
                new SqlParameter("@Sender", senderID),
                new SqlParameter("@Receiver", receiverID),
                new SqlParameter("@Content", string.IsNullOrEmpty(content) ? "" : content),
                new SqlParameter("@Attachment", string.IsNullOrEmpty(attachmentUrl) ? (object)DBNull.Value : attachmentUrl));
            return (result != null && result != DBNull.Value) ? Convert.ToInt32(result) : 0;
        }

        public static int GetAdminUnreadMessageCount(int adminUserId)
        {
            object result = ExecuteScalar(
                "SELECT COUNT(*) FROM dbo.Message WHERE receiverID = @AdminID AND status <> 'Read'",
                new SqlParameter("@AdminID", adminUserId));
            return (result != null && result != DBNull.Value) ? Convert.ToInt32(result) : 0;
        }

        // ============================================================
        // ADMIN DASHBOARD — read-only aggregates for the control panel.
        // These never mutate data; they only surface counts and a recent
        // activity feed drawn from the existing Dispute / Transaction tables.
        // ============================================================

        /// <summary>Number of open disputes (Open or In Review).</summary>
        public static int GetOpenDisputeCount()
        {
            object r = ExecuteScalar(
                "SELECT COUNT(*) FROM dbo.Dispute WHERE status = 'Open' OR status = 'In Review'");
            return (r != null && r != DBNull.Value) ? Convert.ToInt32(r) : 0;
        }

        /// <summary>Number of pending refund transactions.</summary>
        public static int GetPendingRefundCount()
        {
            object r = ExecuteScalar(
                "SELECT COUNT(*) FROM dbo.[Transaction] WHERE transactionType = 'Refund' AND transactionStatus = 'Pending'");
            return (r != null && r != DBNull.Value) ? Convert.ToInt32(r) : 0;
        }

        /// <summary>Number of pending withdrawal transactions.</summary>
        public static int GetPendingWithdrawalCount()
        {
            object r = ExecuteScalar(
                "SELECT COUNT(*) FROM dbo.[Transaction] WHERE transactionType = 'Withdrawal' AND transactionStatus = 'Pending'");
            return (r != null && r != DBNull.Value) ? Convert.ToInt32(r) : 0;
        }

        /// <summary>
        /// Read-only unified "recent activity" feed for the admin dashboard.
        /// Merges the most recent disputes, refunds and withdrawals into a single
        /// list ordered by date (newest first). Returns a client-side DataTable with
        /// uniform columns: type, refId, description, userName, activityDate, status.
        /// No data is modified.
        /// </summary>
        public static DataTable GetRecentAdminActivity(int top = 15)
        {
            if (top < 1) top = 1;
            if (top > 100) top = 100;

            string query = @"
                SELECT TOP (@Top) type, refId, description, userName, activityDate, status FROM (
                    SELECT 'Dispute' AS type,
                           d.disputeID AS refId,
                           'New dispute opened' AS description,
                           (u.firstName + ' ' + u.lastName) AS userName,
                           d.dateCreated AS activityDate,
                           d.status AS status
                    FROM dbo.Dispute d
                    INNER JOIN dbo.[User] u ON d.userID = u.userID

                    UNION ALL

                    SELECT 'Refund' AS type,
                           t.transactionID AS refId,
                           'Refund request' AS description,
                           (u.firstName + ' ' + u.lastName) AS userName,
                           t.transactionDate AS activityDate,
                           t.transactionStatus AS status
                    FROM dbo.[Transaction] t
                    INNER JOIN dbo.Wallet w ON t.walletID = w.walletID
                    INNER JOIN dbo.[User] u ON w.userID = u.userID
                    WHERE t.transactionType = 'Refund'

                    UNION ALL

                    SELECT 'Withdrawal' AS type,
                           t.transactionID AS refId,
                           'Withdrawal request' AS description,
                           (u.firstName + ' ' + u.lastName) AS userName,
                           t.transactionDate AS activityDate,
                           t.transactionStatus AS status
                    FROM dbo.[Transaction] t
                    INNER JOIN dbo.Wallet w ON t.walletID = w.walletID
                    INNER JOIN dbo.[User] u ON w.userID = u.userID
                    WHERE t.transactionType = 'Withdrawal'
                ) AS feed
                ORDER BY activityDate DESC";

            return ExecuteQuery(query, new SqlParameter("@Top", top));
        }
    }
}
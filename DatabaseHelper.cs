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
        private static string GetConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["FreeHubDB"].ConnectionString;
        }

        public static SqlConnection GetConnection()
        {
            return new SqlConnection(GetConnectionString());
        }

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

            // Try with hashed password first
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

            // Try with plain-text password (for existing records)
            result = ExecuteQuery(query,
                new SqlParameter("@Login", emailOrUsername.Trim()),
                new SqlParameter("@Password", password)
            );

            if (result.Rows.Count > 0) return result.Rows[0];

            // Try without any password check - just find the user to verify connection works
            // Then compare password in code
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
                // Compare stored password with input (plain) or hashed
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
                            username, accountStatus, userType, ratingScore, dateCreated
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

        /// <summary>
        /// Submits a proposal. Returns proposalID on success, -1 if already submitted, 0 on error.
        /// </summary>
        public static int SubmitProposal(int projectID, int userID, string coverLetter,
            decimal proposedRate, string estimatedTime)
        {
            // First get the freelancerID for this user
            DataRow freelancer = GetFreelancerByUserId(userID);
            int freelancerID;

            if (freelancer != null)
            {
                freelancerID = Convert.ToInt32(freelancer["freelancerID"]);
            }
            else
            {
                // Auto-create a basic freelancer profile if user is registered but hasn't created one
                string createQuery = @"INSERT INTO Freelancer (userID, skills, experience, portfolioLinks, hourlyRate)
                                      VALUES (@UserID, 'General', '', '', @Rate);
                                      SELECT SCOPE_IDENTITY();";
                object newId = ExecuteScalar(createQuery,
                    new SqlParameter("@UserID", userID),
                    new SqlParameter("@Rate", proposedRate));
                freelancerID = Convert.ToInt32(newId);
            }

            // Check if already submitted
            string checkQuery = "SELECT COUNT(*) FROM Proposal WHERE projectID = @ProjectID AND freelancerID = @FreelancerID";
            object existsResult = ExecuteScalar(checkQuery,
                new SqlParameter("@ProjectID", projectID),
                new SqlParameter("@FreelancerID", freelancerID));

            if (Convert.ToInt32(existsResult) > 0)
            {
                return -1; // Already submitted
            }

            // Insert proposal
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

        /// <summary>
        /// Updates the wallet balance for a given wallet ID.
        /// </summary>
        public static void UpdateWalletBalance(int walletID, decimal newBalance)
        {
            string query = "UPDATE Wallet SET balance = @Balance WHERE walletID = @WalletID";
            ExecuteNonQuery(query,
                new SqlParameter("@Balance", newBalance),
                new SqlParameter("@WalletID", walletID));
        }

        /// <summary>
        /// Adds a transaction record to the Transaction table.
        /// </summary>
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

        /// <summary>
        /// Gets all transactions for a wallet, ordered by date descending.
        /// </summary>
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

        /// <summary>
        /// Gets the current wallet balance from the database.
        /// </summary>
        public static decimal GetWalletBalance(int walletID)
        {
            string query = "SELECT balance FROM Wallet WHERE walletID = @WalletID";
            object result = ExecuteScalar(query, new SqlParameter("@WalletID", walletID));
            if (result != null && result != DBNull.Value)
                return Convert.ToDecimal(result);
            return 0.00m;
        }

        /// <summary>
        /// Gets a single transaction by its ID.
        /// </summary>
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
    }
}

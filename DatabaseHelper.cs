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
    }
}

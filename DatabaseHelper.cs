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

            string query = @"
                SELECT userID, firstName, lastName, email, contactNumber, username,
                       accountStatus, userType, ratingScore, dateCreated
                FROM [User]
                WHERE (email = @Login OR username = @Login)
                  AND password = @Password
                  AND accountStatus = 'Active'";

            DataTable result = ExecuteQuery(query,
                new SqlParameter("@Login", emailOrUsername),
                new SqlParameter("@Password", hashedPassword)
            );

            if (result.Rows.Count > 0) return result.Rows[0];
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
    }
}

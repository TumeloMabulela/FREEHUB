using System;
using System.Web.UI;

namespace FreeHubProject
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Load the homepage statistics from the database on every page load so the
            // values always reflect the latest committed records. (No postbacks occur on
            // this public page, but loading unconditionally keeps it correct regardless.)
            LoadStatistics();
        }

        /// <summary>
        /// Populates the four homepage statistics from live database data. Any database
        /// error is swallowed and the fields fall back to their safe defaults so a
        /// visitor never sees an error or sensitive details.
        /// </summary>
        private void LoadStatistics()
        {
            try
            {
                // 1) Registered freelancers: distinct users who have a Freelancer profile
                //    and whose account is Active (excludes Inactive/Suspended accounts).
                //    DISTINCT on userID guards against any duplicate profile rows.
                int freelancers = ToInt(DatabaseHelper.ExecuteScalar(
                    @"SELECT COUNT(DISTINCT f.userID)
                      FROM dbo.Freelancer f
                      INNER JOIN dbo.[User] u ON f.userID = u.userID
                      WHERE u.accountStatus = 'Active'"));

                // 2) Registered employers: same rule via the Employer profile table.
                int employers = ToInt(DatabaseHelper.ExecuteScalar(
                    @"SELECT COUNT(DISTINCT e.userID)
                      FROM dbo.Employer e
                      INNER JOIN dbo.[User] u ON e.userID = u.userID
                      WHERE u.accountStatus = 'Active'"));

                // 3) Projects posted: every project (Open, In Progress, Completed,
                //    Cancelled). There is no soft-delete column in the schema, so all
                //    rows are valid posted projects. Proposals are a separate table and
                //    are not counted here.
                int projects = ToInt(DatabaseHelper.ExecuteScalar(
                    "SELECT COUNT(*) FROM dbo.Project"));

                // 4) Success rate = Completed / (Completed + Cancelled) * 100.
                //    The schema distinguishes a successful final outcome (projectStatus
                //    'Completed') from an unsuccessful one ('Cancelled'), so the rate is
                //    meaningful. Open and In Progress are excluded from the denominator.
                int completed = ToInt(DatabaseHelper.ExecuteScalar(
                    "SELECT COUNT(*) FROM dbo.Project WHERE projectStatus = 'Completed'"));
                int finalised = ToInt(DatabaseHelper.ExecuteScalar(
                    "SELECT COUNT(*) FROM dbo.Project WHERE projectStatus IN ('Completed', 'Cancelled')"));

                litFreelancers.Text = FormatCount(freelancers);
                litProjects.Text = FormatCount(projects);
                litEmployers.Text = FormatCount(employers);

                // Divide-by-zero safe: with no finalised projects there is no meaningful
                // rate yet, so show N/A rather than invent a number.
                litSuccessRate.Text = finalised > 0
                    ? (int)Math.Round((double)completed / finalised * 100) + "%"
                    : "N/A";
            }
            catch
            {
                // Never surface database errors to visitors; leave the safe defaults
                // declared in the markup (0 / 0 / 0 / N/A).
            }
        }

        /// <summary>Safely converts a COUNT(*) scalar result to an int.</summary>
        private static int ToInt(object scalar)
        {
            return (scalar == null || scalar == DBNull.Value) ? 0 : Convert.ToInt32(scalar);
        }

        /// <summary>
        /// Formats a count for display:
        ///   0–999       -> the actual number (e.g. 156)
        ///   1,000+      -> compact one-decimal "K" (e.g. 1.5K, 12.4K)
        /// No "+" is appended, so the figure never overstates the real count.
        /// </summary>
        private static string FormatCount(int value)
        {
            if (value < 1000) return value.ToString();

            // One decimal place, truncated (not rounded up) so the compact value never
            // exceeds the true count, then trim a trailing ".0" (e.g. 2000 -> "2K").
            double thousands = Math.Floor(value / 100.0) / 10.0; // e.g. 12450 -> 12.4
            string text = thousands.ToString("0.0");
            if (text.EndsWith(".0")) text = text.Substring(0, text.Length - 2);
            return text + "K";
        }
    }
}

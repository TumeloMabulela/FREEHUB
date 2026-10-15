using System;

namespace FreeHubProject
{
    /// <summary>
    /// Centralized time handling for the site.
    ///
    /// The database is Azure SQL, whose GETDATE()/server clock is UTC. All timestamp
    /// columns are therefore stored as UTC. The UI must display South Africa Standard
    /// Time (SAST, UTC+2, no daylight saving), so every stored value is converted here
    /// before it is shown, and "now" for comparisons is taken in SAST as well.
    /// </summary>
    public static class TimeHelper
    {
        // South Africa Standard Time is UTC+02:00 all year (no DST).
        private static readonly TimeSpan SastOffset = TimeSpan.FromHours(2);

        private static TimeZoneInfo GetSastZone()
        {
            // Windows id is "South Africa Standard Time"; fall back to a fixed +02:00
            // zone if the id is unavailable (e.g. on non-Windows hosts).
            try
            {
                return TimeZoneInfo.FindSystemTimeZoneById("South Africa Standard Time");
            }
            catch
            {
                return TimeZoneInfo.CreateCustomTimeZone(
                    "SAST",
                    SastOffset,
                    "South Africa Standard Time",
                    "SAST");
            }
        }

        private static readonly TimeZoneInfo Sast = GetSastZone();

        /// <summary>
        /// Current time in South Africa Standard Time. Use this instead of DateTime.Now
        /// anywhere a local "now" is needed for display or age calculations.
        /// </summary>
        public static DateTime Now
        {
            get { return TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, Sast); }
        }

        /// <summary>
        /// Converts a UTC timestamp read from the database into South Africa time.
        /// Values with Kind=Local are assumed already correct and returned unchanged;
        /// Unspecified/Utc values are treated as UTC (matching how Azure SQL stores them).
        /// </summary>
        public static DateTime ToSast(DateTime utc)
        {
            if (utc.Kind == DateTimeKind.Local)
            {
                return utc;
            }

            DateTime asUtc = DateTime.SpecifyKind(utc, DateTimeKind.Utc);
            return TimeZoneInfo.ConvertTimeFromUtc(asUtc, Sast);
        }

        /// <summary>
        /// Converts a database value (object) into South Africa time.
        /// Returns DateTime.MinValue if the value is null/unparseable.
        /// </summary>
        public static DateTime ToSast(object dbValue)
        {
            if (dbValue == null || dbValue == DBNull.Value)
            {
                return DateTime.MinValue;
            }

            DateTime parsed;
            if (dbValue is DateTime)
            {
                parsed = (DateTime)dbValue;
            }
            else if (!DateTime.TryParse(dbValue.ToString(), out parsed))
            {
                return DateTime.MinValue;
            }

            return ToSast(parsed);
        }
    }
}

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace FreeHubProject
{
    /// <summary>
    /// Centralised, authoritative source of truth for whether a conversation between an
    /// Employer and a Freelancer is OPEN or ENDED, plus the project context behind it.
    ///
    /// A FreeHub conversation is ONE continuous thread per pair of users (keyed by the
    /// sender/receiver pair in dbo.Message), spanning however many projects they have
    /// worked on together. Chat availability is therefore DERIVED on every request from
    /// the real Project/Proposal records — never from a cached browser value or a stale
    /// flag — exactly as the lifecycle rules require:
    ///
    ///   * The chat is OPEN while at least one APPROVED proposal exists between the two
    ///     users whose Project is NOT Completed/Cancelled (and both accounts are active).
    ///   * Completing a project automatically ends the chat only when NO other qualifying
    ///     active project remains between the same two participants.
    ///   * A new approval/appointment of the same freelancer by the same employer makes a
    ///     fresh active project appear, so the derived state flips straight back to OPEN
    ///     and the SAME existing conversation (and its whole history) is reused.
    ///
    /// This means "end on completion" and "reopen on new appointment" need no schema
    /// changes and no duplicate conversations — they fall out of the derived state. The
    /// completion/approval handlers only post an idempotent system separator so repeated
    /// postbacks never create duplicate notices.
    /// </summary>
    public static class ChatLifecycle
    {
        /// <summary>Resolves the FreeHubDB connection string the same way the rest of the app does.</summary>
        private static string ConnStr()
        {
            var setting = System.Configuration.ConfigurationManager.ConnectionStrings["FreeHubDB"];
            return setting?.ConnectionString;
        }

        // ---- Convenience overloads so callers (completion/approval handlers) don't need
        //      to resolve the connection string themselves. ----

        /// <summary>
        /// Marks the chat between the project's participants as ended on project completion.
        /// Posts the ended system notice ONCE (idempotent) only when NO other qualifying
        /// active project remains between the same two users — otherwise the chat stays open
        /// for the still-active appointment. Safe to call repeatedly.
        /// </summary>
        public static void OnProjectCompleted(int projectId, int actingUserId)
        {
            string conn = ConnStr();
            if (string.IsNullOrEmpty(conn) || projectId <= 0) return;

            int employerUserId, freelancerUserId;
            if (!TryGetProjectParticipants(conn, projectId, out employerUserId, out freelancerUserId)) return;

            // Keep the chat open if another approved project between the two is still active.
            if (HasActiveSharedProject(conn, employerUserId, freelancerUserId)) return;

            int from = actingUserId > 0 ? actingUserId : employerUserId;
            int to = (from == employerUserId) ? freelancerUserId : employerUserId;

            PostSystemNoticeOnce(conn, from, to, projectId, "ENDED",
                "This conversation has ended because the project is completed. Your message history remains available.");
        }

        /// <summary>
        /// Chat lifecycle for when an employer deletes/cancels a project. Call this AFTER the
        /// project's status has been set to 'Cancelled' (so the "other active project" check
        /// no longer counts the cancelled one).
        ///
        ///  * If the same employer and freelancer have NO other active project together, the
        ///    conversation ends: a notice "This chat has ended because the project was
        ///    cancelled." is posted once (idempotent) and the derived model shows it as Ended.
        ///  * If another active project remains, the chat STAYS open; a system separator
        ///    naming the cancelled project is recorded, and the derived model automatically
        ///    switches the governing project context to a remaining active one.
        ///
        /// Participants are resolved from the (retained) Approved proposal, so this must run
        /// while the Proposal row still exists — i.e. use a soft cancel, not a hard delete.
        /// </summary>
        public static void OnProjectCancelled(int projectId, int actingUserId, string projectTitle)
        {
            string conn = ConnStr();
            if (string.IsNullOrEmpty(conn) || projectId <= 0) return;

            int employerUserId, freelancerUserId;
            if (!TryGetProjectParticipants(conn, projectId, out employerUserId, out freelancerUserId)) return;

            int from = actingUserId > 0 ? actingUserId : employerUserId;
            int to = (from == employerUserId) ? freelancerUserId : employerUserId;
            string title = string.IsNullOrWhiteSpace(projectTitle) ? "a project" : "\"" + projectTitle + "\"";

            if (HasActiveSharedProject(conn, employerUserId, freelancerUserId))
            {
                // Another active project remains — keep the chat open, just record the
                // cancellation as a project separator. The derived model re-points the
                // governing project to a remaining active one on the next open.
                PostSystemNoticeOnce(conn, from, to, projectId, "CANCELLED",
                    "The project " + title + " was cancelled. This conversation remains open for your other active project.");
            }
            else
            {
                // No other active project — end the conversation with the cancellation reason.
                PostSystemNoticeOnce(conn, from, to, projectId, "ENDEDCANCEL",
                    "This chat has ended because the project was cancelled.");
            }
        }

        /// <summary>
        /// Reopens the existing conversation between the project's participants on a new
        /// approval/appointment. Posts a project-separator notice ONCE (idempotent) so the
        /// reused thread clearly marks where the new project begins. Safe to call repeatedly
        /// (repeated approval postbacks never duplicate the notice).
        /// </summary>
        public static void OnProposalApproved(int projectId, int actingUserId, string projectTitle)
        {
            string conn = ConnStr();
            if (string.IsNullOrEmpty(conn) || projectId <= 0) return;

            int employerUserId, freelancerUserId;
            if (!TryGetProjectParticipants(conn, projectId, out employerUserId, out freelancerUserId)) return;

            int from = actingUserId > 0 ? actingUserId : employerUserId;
            int to = (from == employerUserId) ? freelancerUserId : employerUserId;

            string title = string.IsNullOrWhiteSpace(projectTitle) ? "a new project" : "\"" + projectTitle + "\"";
            PostSystemNoticeOnce(conn, from, to, projectId, "REOPEN",
                "New project appointment: " + title + ". This conversation has reopened and your history remains available.");
        }

        // Sentinel prefix stored in Message.content for system/lifecycle events so the UI
        // can render them as distinct "system events" (not user messages) and so the
        // inserts can be made idempotent (we check for an existing identical row first).
        public const string SystemPrefix = "\u0001SYS\u0001";

        /// <summary>
        /// Snapshot of a conversation's derived availability and the project it is scoped to.
        /// </summary>
        public sealed class ChatAvailability
        {
            public bool IsActive;              // true => messaging allowed
            public int SelectedProjectId;      // the project the chat currently reflects (0 = none)
            public string ProjectTitle = "";
            public string ProjectStatus = "";
            public string ReasonMessage = "";  // why the chat is locked (shown when !IsActive)
            public bool OtherAccountInactive;  // partner account deactivated/deleted/inactive
        }

        /// <summary>
        /// A project shared between the two users via an approved proposal (used for the
        /// project selector when several qualifying projects are active at once).
        /// </summary>
        public sealed class SharedProject
        {
            public int ProjectId;
            public string Title = "";
            public string Status = "";
            public bool IsActive;    // not Completed/Cancelled
        }

        /// <summary>
        /// Returns the derived chat availability between two users, preferring the most
        /// recent still-active shared project. If every shared project is completed/
        /// cancelled, the most recent completed one is reported so history + project
        /// context stay available while messaging is blocked.
        /// </summary>
        public static ChatAvailability GetAvailability(string connStr, int currentUserId, int otherUserId)
        {
            var result = new ChatAvailability();

            // 1. Partner account state first — a deactivated/deleted partner locks the chat
            //    regardless of project state.
            DataRow partner = DatabaseHelper.GetUserById(otherUserId);
            if (partner != null)
            {
                string acct = Convert.ToString(partner["accountStatus"]);
                if (acct.Equals("Deactivated", StringComparison.OrdinalIgnoreCase) ||
                    acct.Equals("Deleted", StringComparison.OrdinalIgnoreCase) ||
                    acct.Equals("Inactive", StringComparison.OrdinalIgnoreCase))
                {
                    result.OtherAccountInactive = true;
                }
            }

            // 2. Pick the governing project between the two users. Prefer a still-active
            //    approved project (newest first); otherwise fall back to the newest
            //    completed/cancelled one so the ended chat still shows its last project.
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT TOP 1 p.projectID, p.title, p.projectStatus
                    FROM dbo.Proposal prop
                    INNER JOIN dbo.Project p ON prop.projectID = p.projectID
                    INNER JOIN dbo.Employer e ON p.employerID = e.employerID
                    INNER JOIN dbo.Freelancer f ON prop.freelancerID = f.freelancerID
                    WHERE prop.status = 'Approved'
                      AND ((e.userID = @Me AND f.userID = @Other) OR (f.userID = @Me AND e.userID = @Other))
                    ORDER BY
                        CASE WHEN p.projectStatus IN ('Completed','Cancelled') THEN 1 ELSE 0 END ASC,
                        p.dateCreated DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Me", currentUserId);
                    cmd.Parameters.AddWithValue("@Other", otherUserId);
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            result.SelectedProjectId = Convert.ToInt32(dr["projectID"]);
                            result.ProjectTitle = Convert.ToString(dr["title"]);
                            result.ProjectStatus = Convert.ToString(dr["projectStatus"]);
                        }
                    }
                }
            }

            // 3. Derive the final availability from the project status + account state.
            bool projectActive =
                result.SelectedProjectId > 0 &&
                !result.ProjectStatus.Equals("Completed", StringComparison.OrdinalIgnoreCase) &&
                !result.ProjectStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase);

            if (result.OtherAccountInactive)
            {
                result.IsActive = false;
                result.ReasonMessage = "The participant's account is no longer active.";
            }
            else if (result.SelectedProjectId == 0)
            {
                // No approved project between them (e.g. an admin support thread). Leave
                // the conversation open — this governs only Employer/Freelancer project
                // chats; non-project threads are handled by the caller.
                result.IsActive = true;
            }
            else if (projectActive)
            {
                result.IsActive = true;
            }
            else
            {
                result.IsActive = false;
                // Reason reflects WHY the chat ended: cancelled vs completed.
                if (result.ProjectStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
                {
                    result.ReasonMessage = "This chat has ended because the project was cancelled.";
                }
                else
                {
                    result.ReasonMessage =
                        "This conversation has ended because the project is completed. Your message history remains available.";
                }
            }

            return result;
        }

        /// <summary>
        /// True when the two users still share at least one APPROVED proposal whose project
        /// is active (not Completed/Cancelled). This is the authoritative "messaging allowed"
        /// test used server-side on every send/upload.
        /// </summary>
        public static bool HasActiveSharedProject(string connStr, int currentUserId, int otherUserId)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT COUNT(*)
                    FROM dbo.Proposal prop
                    INNER JOIN dbo.Project p ON prop.projectID = p.projectID
                    INNER JOIN dbo.Employer e ON p.employerID = e.employerID
                    INNER JOIN dbo.Freelancer f ON prop.freelancerID = f.freelancerID
                    WHERE prop.status = 'Approved'
                      AND p.projectStatus NOT IN ('Completed','Cancelled')
                      AND ((e.userID = @Me AND f.userID = @Other) OR (f.userID = @Me AND e.userID = @Other))";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Me", currentUserId);
                    cmd.Parameters.AddWithValue("@Other", otherUserId);
                    conn.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
        }

        /// <summary>
        /// All approved shared projects between the two users, newest first, each flagged
        /// active/ended. Used to drive the compact project selector when more than one
        /// qualifying project is active simultaneously.
        /// </summary>
        public static List<SharedProject> GetSharedProjects(string connStr, int currentUserId, int otherUserId)
        {
            var list = new List<SharedProject>();
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT DISTINCT p.projectID, p.title, p.projectStatus, p.dateCreated
                    FROM dbo.Proposal prop
                    INNER JOIN dbo.Project p ON prop.projectID = p.projectID
                    INNER JOIN dbo.Employer e ON p.employerID = e.employerID
                    INNER JOIN dbo.Freelancer f ON prop.freelancerID = f.freelancerID
                    WHERE prop.status = 'Approved'
                      AND ((e.userID = @Me AND f.userID = @Other) OR (f.userID = @Me AND e.userID = @Other))
                    ORDER BY p.dateCreated DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Me", currentUserId);
                    cmd.Parameters.AddWithValue("@Other", otherUserId);
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string status = Convert.ToString(dr["projectStatus"]);
                            list.Add(new SharedProject
                            {
                                ProjectId = Convert.ToInt32(dr["projectID"]),
                                Title = Convert.ToString(dr["title"]),
                                Status = status,
                                IsActive = !status.Equals("Completed", StringComparison.OrdinalIgnoreCase) &&
                                           !status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase)
                            });
                        }
                    }
                }
            }
            return list;
        }

        /// <summary>
        /// Finds the two user IDs (employer userID, freelancer userID) behind a project, so
        /// the completion/approval handlers can address the correct conversation.
        /// Returns false when the project has no approved proposal yet.
        /// </summary>
        public static bool TryGetProjectParticipants(string connStr, int projectId, out int employerUserId, out int freelancerUserId)
        {
            employerUserId = 0;
            freelancerUserId = 0;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT TOP 1 e.userID AS EmployerUserID, f.userID AS FreelancerUserID
                    FROM dbo.Proposal prop
                    INNER JOIN dbo.Project p ON prop.projectID = p.projectID
                    INNER JOIN dbo.Employer e ON p.employerID = e.employerID
                    INNER JOIN dbo.Freelancer f ON prop.freelancerID = f.freelancerID
                    WHERE prop.status = 'Approved' AND p.projectID = @ProjectId";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ProjectId", projectId);
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            employerUserId = Convert.ToInt32(dr["EmployerUserID"]);
                            freelancerUserId = Convert.ToInt32(dr["FreelancerUserID"]);
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        /// <summary>
        /// Posts a system separator/notice into the conversation IDEMPOTENTLY: if an
        /// identical system row already exists for this project + kind, nothing is inserted.
        /// This keeps repeated approval/completion postbacks from duplicating notices.
        ///
        /// The message is stored with the SystemPrefix so the chat UI renders it as a
        /// distinct system event. senderID is the acting user, receiverID the other party.
        /// </summary>
        public static void PostSystemNoticeOnce(string connStr, int fromUserId, int toUserId, int projectId, string kind, string text)
        {
            // A stable key embedded in the content so duplicates can be detected cheaply
            // without a schema change. Format: \u0001SYS\u0001<kind>:<projectId>\u0001<text>
            string tag = SystemPrefix + kind + ":" + projectId + SystemPrefix;
            string content = tag + text;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Idempotency: skip if the SAME system notice (same kind + project, in either
                // direction between the two users) already exists.
                string existsQuery = @"
                    SELECT COUNT(*) FROM dbo.Message
                    WHERE content LIKE @TagLike
                      AND ((senderID = @From AND receiverID = @To) OR (senderID = @To AND receiverID = @From))";
                using (SqlCommand check = new SqlCommand(existsQuery, conn))
                {
                    check.Parameters.AddWithValue("@TagLike", EscapeLike(tag) + "%");
                    check.Parameters.AddWithValue("@From", fromUserId);
                    check.Parameters.AddWithValue("@To", toUserId);
                    if (Convert.ToInt32(check.ExecuteScalar()) > 0) return; // already posted
                }

                string insert = @"
                    INSERT INTO dbo.Message (senderID, receiverID, projectID, content, attachmentUrl, timeStamp, status)
                    VALUES (@From, @To, @ProjectId, @Content, NULL, GETDATE(), 'Read')";
                using (SqlCommand ins = new SqlCommand(insert, conn))
                {
                    ins.Parameters.AddWithValue("@From", fromUserId);
                    ins.Parameters.AddWithValue("@To", toUserId);
                    ins.Parameters.AddWithValue("@ProjectId", projectId > 0 ? (object)projectId : DBNull.Value);
                    ins.Parameters.AddWithValue("@Content", content);
                    ins.ExecuteNonQuery();
                }
            }
        }

        /// <summary>True when a stored message is a system/lifecycle event (not a user message).</summary>
        public static bool IsSystemMessage(object content)
        {
            if (content == null || content == DBNull.Value) return false;
            return Convert.ToString(content).StartsWith(SystemPrefix, StringComparison.Ordinal);
        }

        /// <summary>
        /// Strips the sentinel + key from a system message, returning the human-readable text.
        /// Non-system content is returned unchanged.
        /// </summary>
        public static string StripSystem(object content)
        {
            string s = content == null || content == DBNull.Value ? "" : Convert.ToString(content);
            if (!s.StartsWith(SystemPrefix, StringComparison.Ordinal)) return s;

            // Content = \u0001SYS\u0001<kind>:<projectId>\u0001<text>
            int second = s.IndexOf(SystemPrefix, SystemPrefix.Length, StringComparison.Ordinal);
            if (second < 0) return s.Substring(SystemPrefix.Length);
            return s.Substring(second + SystemPrefix.Length);
        }

        private static string EscapeLike(string value)
        {
            if (string.IsNullOrEmpty(value)) return value;
            return value.Replace("[", "[[]").Replace("%", "[%]").Replace("_", "[_]");
        }
    }
}

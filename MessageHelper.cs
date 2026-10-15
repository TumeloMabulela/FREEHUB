using System;
using System.Web.UI;

namespace FreeHubProject
{
    /// <summary>
    /// Centralised helper for triggering the global centre-screen popup message
    /// system (defined in Site1.Master via fhShowMessage) from server-side code,
    /// after an operation has actually completed.
    ///
    /// Usage from a code-behind:
    ///     MessageHelper.Success(this, "Project posted successfully.");
    ///     MessageHelper.Error(this, "Unable to submit proposal.");
    ///     MessageHelper.Warning(this, "Please correct the highlighted fields.");
    ///     MessageHelper.Info(this, "Your request is being processed.");
    ///
    /// The message/title are JavaScript-string escaped here, and the client additionally
    /// HTML-escapes before inserting into the DOM, so dynamic content cannot inject
    /// markup or script.
    /// </summary>
    public static class MessageHelper
    {
        public static void Success(Page page, string message, string title = null)
        {
            Show(page, "success", message, title);
        }

        public static void Error(Page page, string message, string title = null)
        {
            Show(page, "error", message, title);
        }

        public static void Warning(Page page, string message, string title = null)
        {
            Show(page, "warning", message, title);
        }

        public static void Info(Page page, string message, string title = null)
        {
            Show(page, "info", message, title);
        }

        /// <summary>
        /// Registers a one-time startup script that calls fhShowMessage after the page
        /// (and any partial postback) finishes loading. Safe for UpdatePanel partial
        /// postbacks via ScriptManager when one is present; falls back to the standard
        /// ClientScript registration otherwise. A unique key per call prevents the same
        /// message being queued twice on a single response, while using the current
        /// request means it will not re-fire on a later refresh/postback.
        /// </summary>
        public static void Show(Page page, string type, string message, string title = null)
        {
            if (page == null) return;

            string t = (type ?? "info").ToLowerInvariant();
            if (t != "success" && t != "error" && t != "warning" && t != "info") t = "info";

            string script = "if(window.fhShowMessage){fhShowMessage('" + t + "','" +
                            JsEscape(title) + "','" + JsEscape(message) + "');}";

            string key = "fhMsg_" + Guid.NewGuid().ToString("N");

            // Prefer ScriptManager registration so the popup also fires after an
            // UpdatePanel async postback; fall back to ClientScript for full postbacks.
            ScriptManager sm = ScriptManager.GetCurrent(page);
            if (sm != null && sm.IsInAsyncPostBack)
            {
                ScriptManager.RegisterStartupScript(page, page.GetType(), key, script, true);
            }
            else
            {
                page.ClientScript.RegisterStartupScript(page.GetType(), key, script, true);
            }
        }

        /// <summary>Escapes a string for safe inclusion inside a single-quoted JS literal.</summary>
        private static string JsEscape(string s)
        {
            if (string.IsNullOrEmpty(s)) return string.Empty;
            System.Text.StringBuilder sb = new System.Text.StringBuilder(s.Length + 8);
            foreach (char c in s)
            {
                switch (c)
                {
                    case '\\': sb.Append("\\\\"); break;
                    case '\'': sb.Append("\\'"); break;
                    case '"': sb.Append("\\\""); break;
                    case '\r': sb.Append("\\r"); break;
                    case '\n': sb.Append("\\n"); break;
                    case '<': sb.Append("\\u003c"); break;  // avoid closing a <script>
                    case '>': sb.Append("\\u003e"); break;
                    case '&': sb.Append("\\u0026"); break;
                    default: sb.Append(c); break;
                }
            }
            return sb.ToString();
        }
    }
}

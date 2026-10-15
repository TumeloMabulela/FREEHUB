using System;
using System.Collections.Generic;
using System.Text;

namespace FreeHubProject
{
    /// <summary>
    /// Smart Title Capitalisation for project titles. Centralised, shared utility used
    /// on both the save path (PostProject / EditProject) and the display path (all pages
    /// that show project titles). Mirrors fhText/fhTitle on the client.
    ///
    /// Rules:
    ///   - Each word's first letter is capitalised; the rest lower-cased.
    ///   - Small connector words (a, an, the, of, and, or, for, to, in, on, at, by, with,
    ///     from, as, vs) are lower-cased UNLESS they are the first word.
    ///   - Recognised acronyms / technical terms are forced to their canonical casing
    ///     (AI, API, HTML, CSS, JS, SQL, UI, UX, PHP, ASP.NET, C#, C++, iOS, JavaScript,
    ///     TypeScript, GitHub, E-Commerce, etc.).
    ///   - Hyphenated words are title-cased segment by segment (e.g. "e-commerce" -> "E-Commerce").
    ///   - Numbers, special characters and multiple spaces are preserved (spaces collapsed to one);
    ///     word order and the user's wording are never changed.
    /// It never inserts/removes words.
    /// </summary>
    public static class TitleHelper
    {
        // Canonical casing for recognised terms, keyed by the lower-cased input token.
        private static readonly Dictionary<string, string> Acronyms =
            new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            { "ai", "AI" },
            { "api", "API" },
            { "apis", "APIs" },
            { "html", "HTML" },
            { "css", "CSS" },
            { "js", "JS" },
            { "sql", "SQL" },
            { "ui", "UI" },
            { "ux", "UX" },
            { "ui/ux", "UI/UX" },
            { "php", "PHP" },
            { "asp.net", "ASP.NET" },
            { "aspnet", "ASP.NET" },
            { ".net", ".NET" },
            { "c#", "C#" },
            { "c++", "C++" },
            { "ios", "iOS" },
            { "android", "Android" },
            { "javascript", "JavaScript" },
            { "typescript", "TypeScript" },
            { "github", "GitHub" },
            { "gitlab", "GitLab" },
            { "ecommerce", "E-Commerce" },
            { "e-commerce", "E-Commerce" },
            { "saas", "SaaS" },
            { "paas", "PaaS" },
            { "crm", "CRM" },
            { "cms", "CMS" },
            { "seo", "SEO" },
            { "pdf", "PDF" },
            { "json", "JSON" },
            { "xml", "XML" },
            { "rest", "REST" },
            { "graphql", "GraphQL" },
            { "nodejs", "Node.js" },
            { "node.js", "Node.js" },
            { "vuejs", "Vue.js" },
            { "nextjs", "Next.js" },
            { "mysql", "MySQL" },
            { "postgresql", "PostgreSQL" },
            { "mongodb", "MongoDB" },
            { "wordpress", "WordPress" },
            { "woocommerce", "WooCommerce" },
            { "ios/android", "iOS/Android" }
        };

        // Connector words kept lower-case unless first in the title.
        private static readonly HashSet<string> SmallWords =
            new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "a", "an", "the", "and", "or", "nor", "but", "of", "to", "in", "on",
            "at", "by", "for", "with", "from", "as", "vs", "via", "per"
        };

        /// <summary>
        /// Returns the smart title-cased form of <paramref name="input"/>.
        /// Null/empty/whitespace input is returned trimmed (possibly empty).
        /// </summary>
        public static string TitleCase(string input)
        {
            if (string.IsNullOrWhiteSpace(input)) return (input ?? string.Empty).Trim();

            // Split on whitespace, dropping empties (collapses multiple spaces).
            string[] words = input.Trim().Split(new[] { ' ', '\t', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries);
            var result = new List<string>(words.Length);

            for (int i = 0; i < words.Length; i++)
            {
                bool isFirst = (i == 0);
                bool isLast = (i == words.Length - 1);
                result.Add(FormatWord(words[i], isFirst, isLast));
            }

            return string.Join(" ", result);
        }

        private static string FormatWord(string word, bool isFirst, bool isLast)
        {
            // Whole-token acronym match (covers "asp.net", "c#", "ui/ux", "node.js", etc.).
            string canonical;
            if (Acronyms.TryGetValue(word, out canonical))
                return canonical;

            // Hyphenated: title-case each segment, keep the hyphens.
            if (word.IndexOf('-') >= 0)
            {
                string[] segs = word.Split('-');
                for (int s = 0; s < segs.Length; s++)
                    segs[s] = FormatSegment(segs[s]);
                return string.Join("-", segs);
            }

            // Small connector word (not first, not last) stays lower-case.
            if (!isFirst && !isLast && SmallWords.Contains(word))
                return word.ToLowerInvariant();

            return FormatSegment(word);
        }

        // Capitalises the first letter of a plain segment, lower-cases the rest,
        // while leaving leading non-letters (e.g. "(hello") handled gracefully and
        // honouring the acronym dictionary for the segment too.
        private static string FormatSegment(string seg)
        {
            if (string.IsNullOrEmpty(seg)) return seg;

            string canonical;
            if (Acronyms.TryGetValue(seg, out canonical))
                return canonical;

            var sb = new StringBuilder(seg.Length);
            bool capitalisedFirstLetter = false;
            for (int i = 0; i < seg.Length; i++)
            {
                char c = seg[i];
                if (!capitalisedFirstLetter && char.IsLetter(c))
                {
                    sb.Append(char.ToUpperInvariant(c));
                    capitalisedFirstLetter = true;
                }
                else
                {
                    sb.Append(char.ToLowerInvariant(c));
                }
            }
            return sb.ToString();
        }
    }
}

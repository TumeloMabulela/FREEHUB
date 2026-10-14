using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace FreeHubProject
{
    /// <summary>
    /// Server-side counterpart of fhText.js. Normalises description / cover-letter
    /// text into clean paragraphs before validation and saving, so the stored value
    /// matches what the user sees. Mirrors the client logic exactly:
    ///   - joins single line breaks within a paragraph into spaces,
    ///   - keeps a blank line as a paragraph separator (max one),
    ///   - preserves bullet (-, *, •) and numbered (1. / 1)) list lines,
    ///   - collapses runs of spaces/tabs and trims.
    /// It never changes wording, punctuation, or sentence order.
    /// </summary>
    public static class TextHelper
    {
        private static readonly Regex ListLine = new Regex(@"^([-*•]|\d+[.)])\s+", RegexOptions.Compiled);
        private static readonly Regex Spaces = new Regex(@"[ \t]+", RegexOptions.Compiled);
        private static readonly Regex BlankLineSplit = new Regex(@"\n[ \t]*\n+", RegexOptions.Compiled);

        public static string NormalizeDescription(string raw)
        {
            if (string.IsNullOrEmpty(raw)) return raw ?? string.Empty;

            string text = raw.Replace("\r\n", "\n").Replace("\r", "\n").Replace('\u00A0', ' ');

            string[] blocks = BlankLineSplit.Split(text);
            var outBlocks = new List<string>();

            foreach (string blockRaw in blocks)
            {
                string[] lines = blockRaw.Split('\n');
                var mergedLines = new List<string>();
                string buffer = "";

                foreach (string lineRaw in lines)
                {
                    string line = Spaces.Replace(lineRaw, " ").Trim();
                    if (line.Length == 0) continue;

                    if (ListLine.IsMatch(line))
                    {
                        if (buffer.Length > 0) { mergedLines.Add(buffer); buffer = ""; }
                        mergedLines.Add(line);
                    }
                    else
                    {
                        buffer = buffer.Length > 0 ? (buffer + " " + line) : line;
                    }
                }
                if (buffer.Length > 0) mergedLines.Add(buffer);

                string block = string.Join("\n", mergedLines).Trim();
                if (block.Length > 0) outBlocks.Add(block);
            }

            return string.Join("\n\n", outBlocks);
        }
    }
}

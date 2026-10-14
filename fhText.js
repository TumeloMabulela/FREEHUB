/* ============================================================
   FreeHUB — shared description/cover-letter text formatting.
   Normalises pasted text into clean paragraphs, enforces a
   single blank line between paragraphs, and keeps lists intact.
   Attach to any <textarea> by giving it the attribute
   data-fh-format="true". Pair with a counter via
   data-fh-counter="<counterElementId>" (optional).
   ============================================================ */
(function () {
    "use strict";

    // A line that should NOT be merged with its neighbours:
    // bullet points (-, *, •), or numbered list items (1. / 1) ).
    function isListLine(line) {
        var t = line.trim();
        return /^([-*•]|\d+[.)])\s+/.test(t);
    }

    // Core normaliser used by both paste handling and pre-save cleanup.
    //  - Joins single line breaks inside a paragraph into spaces.
    //  - Treats a blank line as a paragraph separator (max one kept).
    //  - Preserves bullet / numbered list lines as their own lines.
    //  - Collapses runs of spaces/tabs; trims trailing spaces.
    //  - Does NOT change wording, punctuation, or order.
    function fhNormalizeText(raw) {
        if (raw == null) return "";

        // Normalise newlines and non-breaking spaces first.
        var text = String(raw)
            .replace(/\r\n?/g, "\n")
            .replace(/\u00A0/g, " ");

        // Split into blocks separated by one or more blank lines.
        var blocks = text.split(/\n[ \t]*\n+/);
        var outBlocks = [];

        for (var b = 0; b < blocks.length; b++) {
            var lines = blocks[b].split("\n");
            var mergedLines = [];
            var buffer = "";

            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].replace(/[ \t]+/g, " ").trim();
                if (line === "") continue;

                if (isListLine(line)) {
                    // Flush any running paragraph, then keep the list item on its own line.
                    if (buffer) { mergedLines.push(buffer); buffer = ""; }
                    mergedLines.push(line);
                } else {
                    // Continuation of the current paragraph: join with a space.
                    buffer = buffer ? (buffer + " " + line) : line;
                }
            }
            if (buffer) mergedLines.push(buffer);

            var block = mergedLines.join("\n").trim();
            if (block !== "") outBlocks.push(block);
        }

        // One blank line between paragraphs.
        return outBlocks.join("\n\n");
    }

    // Enforce "WhatsApp-style" Enter behaviour while typing/editing:
    // collapse 3+ consecutive newlines down to at most two (one blank line).
    function limitBlankLines(value) {
        return String(value).replace(/\r\n?/g, "\n").replace(/\n{3,}/g, "\n\n");
    }

    function updateCounter(area) {
        var counterId = area.getAttribute("data-fh-counter");
        if (!counterId) return;
        var el = document.getElementById(counterId);
        if (el) el.innerText = area.value.trim().length;
    }

    function attach(area) {
        if (!area || area.__fhFormatted) return;
        area.__fhFormatted = true;

        // Justify the editing view too (display containers are justified via CSS).
        area.style.textAlign = "justify";

        // On paste: normalise the pasted fragment and insert it in place.
        area.addEventListener("paste", function (e) {
            var cd = e.clipboardData || window.clipboardData;
            if (!cd) return; // let the browser handle it; input handler will tidy up
            e.preventDefault();

            var pasted = cd.getData("text");
            var clean = fhNormalizeText(pasted);

            var start = area.selectionStart, end = area.selectionEnd;
            var before = area.value.substring(0, start);
            var after = area.value.substring(end);
            area.value = limitBlankLines(before + clean + after);

            // Place the caret after the inserted text.
            var pos = (before + clean).length;
            area.selectionStart = area.selectionEnd = pos;

            updateCounter(area);
            // Let any page-specific input listeners react.
            area.dispatchEvent(new Event("input", { bubbles: true }));
        });

        // While typing: never allow more than one blank line in a row.
        area.addEventListener("input", function () {
            var limited = limitBlankLines(area.value);
            if (limited !== area.value) {
                var pos = area.selectionStart;
                area.value = limited;
                area.selectionStart = area.selectionEnd = Math.min(pos, limited.length);
            }
            updateCounter(area);
        });

        // On blur: full normalise so the saved value is clean.
        area.addEventListener("blur", function () {
            var clean = fhNormalizeText(area.value);
            if (clean !== area.value) {
                area.value = clean;
                updateCounter(area);
            }
        });
    }

    function initAll() {
        var areas = document.querySelectorAll("textarea[data-fh-format='true']");
        for (var i = 0; i < areas.length; i++) attach(areas[i]);
    }

    // Expose for manual use if needed.
    window.fhNormalizeText = fhNormalizeText;
    window.fhFormatAttach = attach;

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", initAll);
    } else {
        initAll();
    }
})();

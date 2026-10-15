/* ============================================================
   FreeHUB — Smart Title Capitalisation (client mirror).
   Formats a project-title <input> on BLUR only, so typing and
   the caret are never disturbed. Mirrors TitleHelper.cs.
   Attach by adding data-fh-title="true" to the input.
   ============================================================ */
(function () {
    "use strict";

    // Canonical casing for recognised terms (lower-cased key -> canonical).
    var ACRONYMS = {
        "ai": "AI", "api": "API", "apis": "APIs", "html": "HTML", "css": "CSS",
        "js": "JS", "sql": "SQL", "ui": "UI", "ux": "UX", "ui/ux": "UI/UX",
        "php": "PHP", "asp.net": "ASP.NET", "aspnet": "ASP.NET", ".net": ".NET",
        "c#": "C#", "c++": "C++", "ios": "iOS", "android": "Android",
        "javascript": "JavaScript", "typescript": "TypeScript", "github": "GitHub",
        "gitlab": "GitLab", "ecommerce": "E-Commerce", "e-commerce": "E-Commerce",
        "saas": "SaaS", "paas": "PaaS", "crm": "CRM", "cms": "CMS", "seo": "SEO",
        "pdf": "PDF", "json": "JSON", "xml": "XML", "rest": "REST", "graphql": "GraphQL",
        "nodejs": "Node.js", "node.js": "Node.js", "vuejs": "Vue.js", "nextjs": "Next.js",
        "mysql": "MySQL", "postgresql": "PostgreSQL", "mongodb": "MongoDB",
        "wordpress": "WordPress", "woocommerce": "WooCommerce", "ios/android": "iOS/Android"
    };

    var SMALL = {
        "a": 1, "an": 1, "the": 1, "and": 1, "or": 1, "nor": 1, "but": 1, "of": 1,
        "to": 1, "in": 1, "on": 1, "at": 1, "by": 1, "for": 1, "with": 1, "from": 1,
        "as": 1, "vs": 1, "via": 1, "per": 1
    };

    function formatSegment(seg) {
        if (!seg) return seg;
        var low = seg.toLowerCase();
        if (ACRONYMS.hasOwnProperty(low)) return ACRONYMS[low];
        var out = "", capped = false;
        for (var i = 0; i < seg.length; i++) {
            var c = seg[i];
            if (!capped && /[a-z]/i.test(c)) { out += c.toUpperCase(); capped = true; }
            else { out += c.toLowerCase(); }
        }
        return out;
    }

    function formatWord(word, isFirst, isLast) {
        var low = word.toLowerCase();
        if (ACRONYMS.hasOwnProperty(low)) return ACRONYMS[low];

        if (word.indexOf("-") >= 0) {
            return word.split("-").map(formatSegment).join("-");
        }
        if (!isFirst && !isLast && SMALL.hasOwnProperty(low)) return low;
        return formatSegment(word);
    }

    function titleCase(input) {
        if (!input || !input.trim()) return (input || "").trim();
        var words = input.trim().split(/\s+/);
        var out = [];
        for (var i = 0; i < words.length; i++) {
            out.push(formatWord(words[i], i === 0, i === words.length - 1));
        }
        return out.join(" ");
    }

    function attach(el) {
        if (!el || el.__fhTitle) return;
        el.__fhTitle = true;
        // Only reformat when the user leaves the field — never while typing.
        el.addEventListener("blur", function () {
            var formatted = titleCase(el.value);
            if (formatted !== el.value) {
                el.value = formatted;
                el.dispatchEvent(new Event("input", { bubbles: true }));
            }
        });
    }

    function initAll() {
        var inputs = document.querySelectorAll("input[data-fh-title='true']");
        for (var i = 0; i < inputs.length; i++) attach(inputs[i]);
    }

    window.fhTitleCase = titleCase; // exposed for reuse

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", initAll);
    } else {
        initAll();
    }
})();

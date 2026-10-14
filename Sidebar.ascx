<%@ Control Language="C#" AutoEventWireup="true"
    CodeBehind="Sidebar.ascx.cs"
    Inherits="FreeHubProject.Sidebar" %><!-- Collapsed toggle strip pinned to the left edge (Visual Studio "Server Explorer" style) -->
<button type="button" id="fhMenuToggle" class="fh-menu-toggle" onclick="fhToggleMenu(event)" aria-label="Toggle menu" aria-expanded="false">
    <span class="fh-menu-toggle-ic">&#9776;</span>
    <span class="fh-menu-toggle-text">Menu</span>
</button>

<!-- Slide-in menu panel (hidden off to the left until the toggle is clicked) -->
<nav id="fhSlidePanel" class="fh-slide-panel">

    <div class="fh-slide-head">
        <span class="fh-slide-title">Menu</span>
        <button type="button" class="fh-slide-close" onclick="fhToggleMenu(event)" aria-label="Close menu">&#10005;</button>
    </div>

    <div class="fh-slide-body">

        <% if (!GetActiveClass("Default").Contains("active")) { %>
        <a href="javascript:history.back()" class="fh-menu-back">&#8592; Back</a>
        <% } %>

        <a href="Default.aspx" class="sidebar-item <%= GetActiveClass("Default") %>">
            <span class="sidebar-icon">&#127968;</span><span>Dashboard</span>
        </a>

        <a href="BrowseProjects.aspx" class="sidebar-item <%= GetActiveClass("BrowseProjects") %>">
            <span class="sidebar-icon">&#128269;</span><span>Browse Projects</span>
        </a>

        <% if (CurrentUserType == "Employer") { %>
        <a href="MyProjects.aspx" class="sidebar-item <%= GetActiveClass("MyProjects") %>">
            <span class="sidebar-icon">&#128196;</span><span>My Projects</span>
        </a>
        <a href="PostProject.aspx" class="sidebar-item <%= GetActiveClass("PostProject") %>">
            <span class="sidebar-icon">&#10133;</span><span>Post a Project</span>
        </a>
        <a href="SelectProposal.aspx" class="sidebar-item <%= GetActiveClass("SelectProposal") %>">
            <span class="sidebar-icon">&#128221;</span><span>Proposals Received</span>
        </a>
        <a href="ViewProgress.aspx" class="sidebar-item <%= GetActiveClass("ViewProgress") %>">
            <span class="sidebar-icon">&#128200;</span><span>View Progress</span>
        </a>
        <% } %>

        <% if (CurrentUserType == "Freelancer") { %>
        <a href="SelectProposal.aspx" class="sidebar-item <%= GetActiveClass("SelectProposal") %>">
            <span class="sidebar-icon">&#128221;</span><span>My Proposals</span>
        </a>
        <a href="ViewProgress.aspx" class="sidebar-item <%= GetActiveClass("ViewProgress") %>">
            <span class="sidebar-icon">&#128200;</span><span>View Progress</span>
        </a>
        <% } %>

        <a href="StartChat.aspx" class="sidebar-item <%= GetActiveClass("StartChat") %>">
            <span class="sidebar-icon">&#128172;</span><span>Messages</span>
        </a>

        <a href="Wallet.aspx" class="sidebar-item <%= GetActiveClass("Wallet") %>">
            <span class="sidebar-icon">&#128176;</span><span>Wallet</span>
        </a>

        <div class="fh-menu-heading">PROJECTS</div>

        <a href="CompletedProjects.aspx" class="sidebar-item <%= GetActiveClass("CompletedProjects") %>">
            <span class="sidebar-icon">&#9989;</span><span>Completed Projects</span>
        </a>

        <a href="RateFreelancer.aspx" class="sidebar-item <%= GetActiveClass("RateFreelancer") %>">
            <span class="sidebar-icon">&#11088;</span><span>Ratings</span>
        </a>

    </div>
</nav>

<!-- Dim backdrop shown while the panel is open -->
<div id="fhMenuBackdrop" class="fh-menu-backdrop" onclick="fhToggleMenu(event)"></div>

<script type="text/javascript">
    function fhToggleMenu(e) {
        if (e) { e.preventDefault(); e.stopPropagation(); }
        var panel = document.getElementById("fhSlidePanel");
        var toggle = document.getElementById("fhMenuToggle");
        var backdrop = document.getElementById("fhMenuBackdrop");
        if (!panel) return;
        var open = panel.classList.toggle("open");
        if (backdrop) backdrop.classList.toggle("show", open);
        if (toggle) {
            toggle.classList.toggle("hidden", open);
            toggle.setAttribute("aria-expanded", open ? "true" : "false");
        }
        document.body.classList.toggle("fh-menu-open", open);
    }
    // Close on Escape.
    document.addEventListener("keydown", function (ev) {
        if (ev.key === "Escape") {
            var panel = document.getElementById("fhSlidePanel");
            if (panel && panel.classList.contains("open")) { fhToggleMenu(ev); }
        }
    });
</script>

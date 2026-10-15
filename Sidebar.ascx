<%@ Control Language="C#" AutoEventWireup="true"
    CodeBehind="Sidebar.ascx.cs"
    Inherits="FreeHubProject.Sidebar" %><aside class="freehub-sidebar">

    <div class="sidebar-back">
        <% if (!GetActiveClass("Default").Contains("active")) { %>
        <a href="javascript:history.back()" class="fh-back-pill" style="margin:14px 16px 0;">
            <span class="fh-back-circle">&#8592;</span>
            <span class="fh-back-text">Back</span>
        </a>
        <% } %>
    </div>

    <div class="sidebar-section">

        <a href="Default.aspx"
           class="sidebar-item <%= GetActiveClass("Default") %>">
            <span class="sidebar-icon">&#127968;</span>
            <span>Dashboard</span>
        </a>

        <a href="BrowseProjects.aspx"
           class="sidebar-item <%= GetActiveClass("BrowseProjects") %>">
            <span class="sidebar-icon">&#128269;</span>
            <span>Browse Projects</span>
        </a>

        <% if (CurrentUserType == "Employer") { %>
        <a href="MyProjects.aspx"
           class="sidebar-item <%= GetActiveClass("MyProjects") %>">
            <span class="sidebar-icon">&#128196;</span>
            <span>My Projects</span>
        </a>
        <a href="PostProject.aspx"
           class="sidebar-item <%= GetActiveClass("PostProject") %>">
            <span class="sidebar-icon">&#10133;</span>
            <span>Post a Project</span>
        </a>
        <a href="SelectProposal.aspx"
           class="sidebar-item <%= GetActiveClass("SelectProposal") %>">
            <span class="sidebar-icon">&#128221;</span>
            <span>Proposals Received</span>
        </a>
        <a href="ViewProgress.aspx" class="sidebar-item <%= GetActiveClass("ViewProgress") %>">
            <span class="sidebar-icon">&#128200;</span>
            <span>View Progress</span>
        </a>
        <% } %>

        <% if (CurrentUserType == "Freelancer") { %>
        <a href="SelectProposal.aspx"
           class="sidebar-item <%= GetActiveClass("SelectProposal") %>">
            <span class="sidebar-icon">&#128221;</span>
            <span>My Proposals</span>
        </a>
        <a href="ViewProgress.aspx" class="sidebar-item <%= GetActiveClass("ViewProgress") %>">
            <span class="sidebar-icon">&#128200;</span>
            <span>View Progress</span>
        </a>
        <% } %>

        <a href="StartChat.aspx"
           class="sidebar-item <%= GetActiveClass("StartChat") %>">
            <span class="sidebar-icon">&#128172;</span>
            <span>Messages</span>
        </a>

        <a href="Wallet.aspx"
           class="sidebar-item <%= GetActiveClass("Wallet") %>">
            <span class="sidebar-icon">&#128176;</span>
            <span>Wallet</span>
        </a>

        <!-- Subtle divider between the main nav and the support links -->
        <div class="sidebar-divider"></div>

        <a href="FAQs.aspx"
           class="sidebar-item <%= GetActiveClass("FAQs") %>">
            <span class="sidebar-icon">&#10067;</span>
            <span>FAQs</span>
        </a>

        <a href="Help.aspx"
           class="sidebar-item <%= GetActiveClass("Help") %>">
            <span class="sidebar-icon">&#127911;</span>
            <span>Help &amp; Support</span>
        </a>

        <a href="TrustSafety.aspx"
           class="sidebar-item <%= GetActiveClass("TrustSafety") %>">
            <span class="sidebar-icon">&#128737;</span>
            <span>Trust &amp; Safety</span>
        </a>

        <a href="Feedback.aspx"
           class="sidebar-item <%= GetActiveClass("Feedback") %>">
            <span class="sidebar-icon">&#128161;</span>
            <span>Feedback &amp; Suggestions</span>
        </a>

    </div></aside>
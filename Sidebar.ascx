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

        <% if (CurrentUserType == "Admin") { %>
        <a href="AdminDashboard.aspx"
           class="sidebar-item <%= GetActiveClass("AdminDashboard") %>">
            <span class="sidebar-icon">&#128737;</span>
            <span>Admin Panel</span>
        </a>
        <a href="AdminInbox.aspx"
           class="sidebar-item <%= GetActiveClass("AdminInbox") %>">
            <span class="sidebar-icon">&#128172;</span>
            <span>Support Inbox</span>
        </a>
        <a href="AdminDisputes.aspx"
           class="sidebar-item <%= GetActiveClass("AdminDisputes") %>">
            <span class="sidebar-icon">&#9878;</span>
            <span>Disputes</span>
        </a>
        <a href="AdminRefunds.aspx"
           class="sidebar-item <%= GetActiveClass("AdminRefunds") %>">
            <span class="sidebar-icon">&#128181;</span>
            <span>Refunds</span>
        </a>
        <a href="AdminWithdrawals.aspx"
           class="sidebar-item <%= GetActiveClass("AdminWithdrawals") %>">
            <span class="sidebar-icon">&#127974;</span>
            <span>Withdrawals</span>
        </a>
        <% } else { %>

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

        <a href="StartChat.aspx?help=1&userId=1"
           class="sidebar-item <%= GetActiveClass("StartChat") %>">
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

    </div>
    <% } %></aside>
<%@ Control Language="C#" AutoEventWireup="true"
    CodeBehind="Sidebar.ascx.cs"
    Inherits="FreeHubProject.Sidebar" %><aside class="freehub-sidebar">

    <div class="sidebar-back">
        <% if (!GetActiveClass("Default").Contains("active")) { %>
        <a href="javascript:history.back()" style="display:inline-block;color:#fff;background-color:#173f2c;text-decoration:none;font-size:13px;font-weight:500;padding:8px 16px;border-radius:6px;margin:10px 16px;">&#8592; Back</a>
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
        <% } %>

        <% if (CurrentUserType == "Freelancer") { %>
        <a href="SelectProposal.aspx"
           class="sidebar-item <%= GetActiveClass("SelectProposal") %>">
            <span class="sidebar-icon">&#128221;</span>
            <span>My Proposals</span>
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

    </div>

    <div class="sidebar-heading">PROJECTS</div>

    <div class="sidebar-section">

        <a href="CompletedProjects.aspx"
           class="sidebar-item <%= GetActiveClass("CompletedProjects") %>">
            <span class="sidebar-icon">&#9989;</span>
            <span>Completed Projects</span>
        </a>

        <a href="RateFreelancer.aspx"
           class="sidebar-item <%= GetActiveClass("RateFreelancer") %>">
            <span class="sidebar-icon">&#11088;</span>
            <span>Ratings</span>
        </a>

    </div>

</aside>
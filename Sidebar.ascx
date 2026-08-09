<%@ Control Language="C#" AutoEventWireup="true"
    CodeBehind="Sidebar.ascx.cs"
    Inherits="FreeHubProject.Sidebar" %>

<aside class="freehub-sidebar">

    <div class="sidebar-back">
        <a href="javascript:history.back()" class="sidebar-back-link">&larr; Back</a>
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
            <span>Find Work</span>
        </a>

        <a href="MyProjects.aspx"
           class="sidebar-item <%= GetActiveClass("MyProjects") %>">
            <span class="sidebar-icon">&#128196;</span>
            <span>My Projects</span>
        </a>

        <% if (CurrentUserType == "Freelancer") { %>
        <a href="SelectProposal.aspx"
           class="sidebar-item <%= GetActiveClass("SelectProposal") %>">
            <span class="sidebar-icon">&#128221;</span>
            <span>My Proposals</span>
        </a>
        <% } %>

        <% if (CurrentUserType == "Employer") { %>
        <a href="SelectProposal.aspx"
           class="sidebar-item <%= GetActiveClass("SelectProposal") %>">
            <span class="sidebar-icon">&#128221;</span>
            <span>Proposals Received</span>
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

        <a href="Notifications.aspx"
           class="sidebar-item <%= GetActiveClass("Notifications") %>">
            <span class="sidebar-icon">&#128276;</span>
            <span>Notifications</span>
        </a>

    </div>

    <div class="sidebar-heading">PROJECTS</div>

    <div class="sidebar-section">

        <% if (CurrentUserType == "Employer") { %>
        <a href="PostProject.aspx"
           class="sidebar-item <%= GetActiveClass("PostProject") %>">
            <span class="sidebar-icon">&#10133;</span>
            <span>Post a Project</span>
        </a>
        <% } %>

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

    <div class="sidebar-heading">ACCOUNT</div>

    <div class="sidebar-section">

        <a href="ManageProfile.aspx"
           class="sidebar-item <%= GetActiveClass("ManageProfile") %>">
            <span class="sidebar-icon">&#128100;</span>
            <span>Profile</span>
        </a>

        <a href="SwitchRole.aspx"
           class="sidebar-item <%= GetActiveClass("SwitchRole") %>">
            <span class="sidebar-icon">&#128260;</span>
            <span>Switch Role</span>
        </a>

    </div>

</aside>

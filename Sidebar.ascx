<%@ Control Language="C#" AutoEventWireup="true"
    CodeBehind="Sidebar.ascx.cs"
    Inherits="FreeHubProject.Sidebar" %>

<aside class="freehub-sidebar">

    <div class="sidebar-section">

        <a href="Default.aspx"
           class="sidebar-item <%= GetActiveClass("Default") %>">
            <span class="sidebar-icon">&#8962;</span>
            <span>Dashboard</span>
        </a>

        <a href="BrowseProjects.aspx"
           class="sidebar-item <%= GetActiveClass("BrowseProjects") %>">
            <span class="sidebar-icon">&#9997;</span>
            <span>Find Work</span>
        </a>

        <a href="MyProjects.aspx"
           class="sidebar-item <%= GetActiveClass("MyProjects") %>">
            <span class="sidebar-icon">&#9635;</span>
            <span>My Projects</span>
        </a>

        <a href="SelectProposal.aspx"
           class="sidebar-item <%= GetActiveClass("SelectProposal") %>">
            <span class="sidebar-icon">&#9636;</span>
            <span>Proposals</span>
        </a>

        <a href="StartChat.aspx"
           class="sidebar-item <%= GetActiveClass("StartChat") %>">
            <span class="sidebar-icon">&#9993;</span>
            <span>Messages</span>
        </a>

        <a href="Wallet.aspx"
           class="sidebar-item <%= GetActiveClass("Wallet") %>">
            <span class="sidebar-icon">&#9649;</span>
            <span>Wallet</span>
        </a>

    </div>

    <div class="sidebar-heading">PROFILE</div>

    <div class="sidebar-section">

        <a href="CompletedProjects.aspx"
           class="sidebar-item <%= GetActiveClass("CompletedProjects") %>">
            <span class="sidebar-icon">&#9745;</span>
            <span>Completed Projects</span>
        </a>

        <a href="Notifications.aspx"
           class="sidebar-item <%= GetActiveClass("Notifications") %>">
            <span class="sidebar-icon">&#9881;</span>
            <span>Notifications</span>
        </a>

    </div>

</aside>

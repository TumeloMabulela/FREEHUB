<%@ Page Title="Browse Projects"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="BrowseProjects.aspx.cs"
    Inherits="FreeHubProject.BrowseProjects" %>

<asp:Content ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">
</asp:Content>

<asp:Content ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="browse-page">

        <!-- LEFT SIDEBAR -->
        <aside class="browse-sidebar">

            <div class="sidebar-section">

                <a href="Default.aspx" class="sidebar-link">
                    <span class="sidebar-icon">▦</span>
                    <span>Dashboard</span>
                </a>

                <a href="BrowseProjects.aspx"
                    class="sidebar-link active-sidebar-link">

                    <span class="sidebar-icon">⌕</span>
                    <span>Browse Projects</span>
                </a>

                <a href="#" class="sidebar-link">
                    <span class="sidebar-icon">▤</span>
                    <span>My Proposals</span>
                </a>

                <a href="StartChat.aspx" class="sidebar-link">
                    <span class="sidebar-icon">✉</span>
                    <span>Messages</span>
                </a>

                <a href="Wallet.aspx" class="sidebar-link">
                    <span class="sidebar-icon">◯</span>
                    <span>Wallet</span>
                </a>

                <a href="#" class="sidebar-link">
                    <span class="sidebar-icon">♡</span>
                    <span>Saved Projects</span>
                </a>

            </div>


            <div class="sidebar-account">

                <p class="sidebar-account-title">
                    ACCOUNT
                </p>

                <a href="#" class="sidebar-link">
                    <span class="sidebar-icon">●</span>
                    <span>Profile</span>
                </a>

                <a href="#" class="sidebar-link">
                    <span class="sidebar-icon">⚙</span>
                    <span>Settings</span>
                </a>

                <a href="#" class="sidebar-link">
                    <span class="sidebar-icon">?</span>
                    <span>Help &amp; Support</span>
                </a>

            </div>


            <div class="switch-mode">

                <div>
                    <small>Switch to</small>
                    <strong>Employer Mode</strong>
                </div>

                <span>›</span>

            </div>

        </aside>


        <!-- MAIN PAGE -->
        <main class="browse-main">

            <!-- PAGE HEADING -->
            <div class="browse-title">

                <h1>Browse Projects</h1>

                <p>
                    Find projects that match your skills and interests.
                </p>

            </div>


            <!-- FILTERS -->
            <div class="browse-filters">

                <div class="filter-group">

                    <label>Category</label>

                    <asp:DropDownList
                        ID="ddlCategory"
                        runat="server"
                        CssClass="filter-dropdown">

                        <asp:ListItem Value="">
                            All Categories
                        </asp:ListItem>

                        <asp:ListItem>
                            Web Development
                        </asp:ListItem>

                        <asp:ListItem>
                            Mobile Development
                        </asp:ListItem>

                        <asp:ListItem>
                            Graphic Design
                        </asp:ListItem>

                        <asp:ListItem>
                            Writing
                        </asp:ListItem>

                        <asp:ListItem>
                            Marketing
                        </asp:ListItem>

                    </asp:DropDownList>

                </div>


                <div class="filter-group">

                    <label>Budget Range</label>

                    <asp:DropDownList
                        ID="ddlBudget"
                        runat="server"
                        CssClass="filter-dropdown">

                        <asp:ListItem Value="">
                            All Budgets
                        </asp:ListItem>

                        <asp:ListItem>
                            R1,000 - R5,000
                        </asp:ListItem>

                        <asp:ListItem>
                            R5,000 - R10,000
                        </asp:ListItem>

                        <asp:ListItem>
                            R10,000 - R20,000
                        </asp:ListItem>

                        <asp:ListItem>
                            R20,000+
                        </asp:ListItem>

                    </asp:DropDownList>

                </div>


                <div class="filter-group">

                    <label>Date Posted</label>

                    <asp:DropDownList
                        ID="ddlDate"
                        runat="server"
                        CssClass="filter-dropdown">

                        <asp:ListItem Value="">
                            Any Time
                        </asp:ListItem>

                        <asp:ListItem>
                            Today
                        </asp:ListItem>

                        <asp:ListItem>
                            Last 7 Days
                        </asp:ListItem>

                        <asp:ListItem>
                            Last 30 Days
                        </asp:ListItem>

                    </asp:DropDownList>

                </div>


                <asp:Button
                    ID="btnFilter"
                    runat="server"
                    Text="⌕  Filters"
                    CssClass="filter-button"
                    OnClick="btnFilter_Click" />


                <asp:Button
                    ID="btnReset"
                    runat="server"
                    Text="Reset"
                    CssClass="reset-button"
                    OnClick="btnReset_Click" />

            </div>


            <asp:Label
                ID="lblFilterMessage"
                runat="server"
                CssClass="filter-message">
            </asp:Label>


            <!-- PROJECT LIST AND DETAILS -->
            <div class="browse-layout">


                <!-- LEFT PROJECT LIST -->
                <section class="projects-column">

                    <div class="projects-header">

                        <span>
                            <strong>Projects</strong> available
                        </span>

                        <asp:DropDownList
                            ID="ddlSort"
                            runat="server"
                            CssClass="sort-dropdown">

                            <asp:ListItem>
                                Sort by: Newest First
                            </asp:ListItem>

                            <asp:ListItem>
                                Sort by: Oldest First
                            </asp:ListItem>

                            <asp:ListItem>
                                Sort by: Highest Budget
                            </asp:ListItem>

                        </asp:DropDownList>

                    </div>


                    <!-- PROJECT 1 -->
                    <asp:LinkButton
                        ID="btnProjectOne"
                        runat="server"
                        CssClass="project-card selected-project"
                        OnClick="btnProjectOne_Click">

                        <span class="project-image web-icon">
                            &lt;/&gt;
                        </span>

                        <span class="project-info">

                            <span class="project-name">
                                Website Development Project
                            </span>

                            <span class="project-category">
                                Web Development
                            </span>

                            <span class="project-meta">
                                Recently posted
                                •
                                Proposals received
                            </span>

                        </span>

                        <span class="project-budget">

                            <span>
                                Budget Available
                            </span>

                            <small>
                                Fixed Price
                            </small>

                        </span>

                    </asp:LinkButton>


                    <!-- PROJECT 2 -->
                    <asp:LinkButton
                        ID="btnProjectTwo"
                        runat="server"
                        CssClass="project-card"
                        OnClick="btnProjectTwo_Click">

                        <span class="project-image mobile-icon">
                            ▯
                        </span>

                        <span class="project-info">

                            <span class="project-name">
                                Mobile Application Project
                            </span>

                            <span class="project-category">
                                Mobile Development
                            </span>

                            <span class="project-meta">
                                Recently posted
                                •
                                Proposals received
                            </span>

                        </span>

                        <span class="project-budget">

                            <span>
                                Budget Available
                            </span>

                            <small>
                                Fixed Price
                            </small>

                        </span>

                    </asp:LinkButton>


                    <!-- PROJECT 3 -->
                    <asp:LinkButton
                        ID="btnProjectThree"
                        runat="server"
                        CssClass="project-card"
                        OnClick="btnProjectThree_Click">

                        <span class="project-image writing-icon">
                            ✎
                        </span>

                        <span class="project-info">

                            <span class="project-name">
                                Content Writing Project
                            </span>

                            <span class="project-category">
                                Writing
                            </span>

                            <span class="project-meta">
                                Recently posted
                                •
                                Proposals received
                            </span>

                        </span>

                        <span class="project-budget">

                            <span>
                                Budget Available
                            </span>

                            <small>
                                Fixed Price
                            </small>

                        </span>

                    </asp:LinkButton>


                    <!-- PROJECT 4 -->
                    <asp:LinkButton
                        ID="btnProjectFour"
                        runat="server"
                        CssClass="project-card"
                        OnClick="btnProjectFour_Click">

                        <span class="project-image marketing-icon">
                            ⚑
                        </span>

                        <span class="project-info">

                            <span class="project-name">
                                Social Media Marketing Project
                            </span>

                            <span class="project-category">
                                Marketing
                            </span>

                            <span class="project-meta">
                                Recently posted
                                •
                                Proposals received
                            </span>

                        </span>

                        <span class="project-budget">

                            <span>
                                Monthly Budget
                            </span>

                            <small>
                                Monthly
                            </small>

                        </span>

                    </asp:LinkButton>


                    <!-- PROJECT 5 -->
                    <asp:LinkButton
                        ID="btnProjectFive"
                        runat="server"
                        CssClass="project-card"
                        OnClick="btnProjectFive_Click">

                        <span class="project-image design-icon">
                            ✿
                        </span>

                        <span class="project-info">

                            <span class="project-name">
                                Logo Design Project
                            </span>

                            <span class="project-category">
                                Graphic Design
                            </span>

                            <span class="project-meta">
                                Recently posted
                                •
                                Proposals received
                            </span>

                        </span>

                        <span class="project-budget">

                            <span>
                                Budget Available
                            </span>

                            <small>
                                Fixed Price
                            </small>

                        </span>

                    </asp:LinkButton>


                    <asp:Button
                        ID="btnLoadMore"
                        runat="server"
                        Text="Load More  ˅"
                        CssClass="load-more-button"
                        OnClick="btnLoadMore_Click" />

                </section>


                <!-- RIGHT PROJECT DETAILS -->
                <section class="details-column">

                    <div class="details-top">

                        <span class="new-project-label">
                            New
                        </span>

                        <asp:Button
                            ID="btnReturn"
                            runat="server"
                            Text="← Return to List"
                            CssClass="return-button"
                            OnClick="btnReturn_Click" />

                    </div>


                    <p class="posted-information">

                        <asp:Label
                            ID="lblPosted"
                            runat="server"
                            Text="Recently posted">
                        </asp:Label>

                    </p>


                    <h2>

                        <asp:Label
                            ID="lblProjectTitle"
                            runat="server"
                            Text="Website Development Project">
                        </asp:Label>

                    </h2>


                    <div class="details-line"></div>


                    <h3>About the project</h3>

                    <p class="details-description">

                        <asp:Label
                            ID="lblDescription"
                            runat="server"
                            Text="The employer has posted a project and is looking for a skilled freelancer. The complete project information will be loaded from the SQL Server database when the database is connected.">
                        </asp:Label>

                    </p>


                    <!-- PROJECT INFORMATION -->
                    <div class="details-grid">

                        <div class="detail-box">

                            <span class="detail-icon">
                                ▣
                            </span>

                            <div>

                                <small>Budget</small>

                                <strong>

                                    <asp:Label
                                        ID="lblBudget"
                                        runat="server"
                                        Text="Budget available">
                                    </asp:Label>

                                </strong>

                                <em>Fixed Price</em>

                            </div>

                        </div>


                        <div class="detail-box">

                            <span class="detail-icon">
                                ▣
                            </span>

                            <div>

                                <small>Project Deadline</small>

                                <strong>

                                    <asp:Label
                                        ID="lblDeadline"
                                        runat="server"
                                        Text="To be confirmed">
                                    </asp:Label>

                                </strong>

                                <em>Project deadline</em>

                            </div>

                        </div>


                        <div class="detail-box">

                            <span class="detail-icon">
                                □
                            </span>

                            <div>

                                <small>Category</small>

                                <strong>

                                    <asp:Label
                                        ID="lblCategory"
                                        runat="server"
                                        Text="Web Development">
                                    </asp:Label>

                                </strong>

                                <em>Project category</em>

                            </div>

                        </div>


                        <div class="detail-box">

                            <span class="detail-icon">
                                ★
                            </span>

                            <div>

                                <small>Experience Level</small>

                                <strong>

                                    <asp:Label
                                        ID="lblExperience"
                                        runat="server"
                                        Text="Experience required">
                                    </asp:Label>

                                </strong>

                                <em>Required experience</em>

                            </div>

                        </div>

                    </div>


                    <!-- EMPLOYER -->
                    <div class="employer-section">

                        <h3>About the employer</h3>

                        <div class="employer-row">

                            <div class="employer-avatar">

                                <asp:Label
                                    ID="lblEmployerInitials"
                                    runat="server"
                                    Text="EM">
                                </asp:Label>

                            </div>


                            <div class="employer-information">

                                <strong>

                                    <asp:Label
                                        ID="lblEmployerName"
                                        runat="server"
                                        Text="Employer Name">
                                    </asp:Label>

                                </strong>

                                <small>

                                    <asp:Label
                                        ID="lblEmployerDetails"
                                        runat="server"
                                        Text="Employer information will be loaded from the database">
                                    </asp:Label>

                                </small>

                                <span>

                                    <asp:Label
                                        ID="lblEmployerRating"
                                        runat="server"
                                        Text="Employer rating">
                                    </asp:Label>

                                </span>

                            </div>


                            <asp:Button
                                ID="btnViewProfile"
                                runat="server"
                                Text="View Profile"
                                CssClass="view-profile-button"
                                OnClick="btnViewProfile_Click" />

                        </div>

                    </div>


                    <!-- BUTTONS -->
                    <div class="project-actions">

                        <asp:Button
                            ID="btnSubmitProposal"
                            runat="server"
                            Text="Submit Proposal"
                            CssClass="submit-button"
                            OnClick="btnSubmitProposal_Click" />


                        <asp:Button
                            ID="btnSaveProject"
                            runat="server"
                            Text="♡  Save Project"
                            CssClass="save-button"
                            OnClick="btnSaveProject_Click" />

                    </div>


                    <asp:Label
                        ID="lblProjectMessage"
                        runat="server"
                        CssClass="project-message">
                    </asp:Label>

                </section>

            </div>

        </main>

    </div>

</asp:Content>
<%@ Page Title="Browse Projects"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="BrowseProjects.aspx.cs"
    Inherits="FreeHubProject.BrowseProjects" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">
</asp:Content>

<asp:Content ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <!-- PAGE HEADING -->
            <div class="post-page-heading">
                <h1>Browse Projects</h1>
                <p>Find projects that match your skills and interests.</p>
            </div>

            <!-- FILTERS -->
            <div class="browse-filters">

                <div class="filter-group">
                    <label>Category</label>
                    <asp:DropDownList ID="ddlCategory" runat="server" CssClass="filter-dropdown">
                        <asp:ListItem Value="">All Categories</asp:ListItem>
                        <asp:ListItem>Web Development</asp:ListItem>
                        <asp:ListItem>Software Development</asp:ListItem>
                        <asp:ListItem>Mobile Development</asp:ListItem>
                        <asp:ListItem>UI/UX Design</asp:ListItem>
                        <asp:ListItem>Graphic Design</asp:ListItem>
                        <asp:ListItem>Digital Marketing</asp:ListItem>
                        <asp:ListItem>Writing</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="filter-group">
                    <label>Budget Range</label>
                    <asp:DropDownList ID="ddlBudget" runat="server" CssClass="filter-dropdown">
                        <asp:ListItem Value="">All Budgets</asp:ListItem>
                        <asp:ListItem Value="1000-5000">R1,000 - R5,000</asp:ListItem>
                        <asp:ListItem Value="5000-10000">R5,000 - R10,000</asp:ListItem>
                        <asp:ListItem Value="10000-20000">R10,000 - R20,000</asp:ListItem>
                        <asp:ListItem Value="20000-999999">R20,000+</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="filter-group">
                    <label>Date Posted</label>
                    <asp:DropDownList ID="ddlDate" runat="server" CssClass="filter-dropdown">
                        <asp:ListItem Value="">Any Time</asp:ListItem>
                        <asp:ListItem Value="1">Today</asp:ListItem>
                        <asp:ListItem Value="7">Last 7 Days</asp:ListItem>
                        <asp:ListItem Value="30">Last 30 Days</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <asp:Button ID="btnFilter" runat="server" Text="Filter"
                    CssClass="filter-button" OnClick="btnFilter_Click" />
                <asp:Button ID="btnReset" runat="server" Text="Reset"
                    CssClass="reset-button" OnClick="btnReset_Click" />
            </div>

            <!-- STATUS -->
            <asp:Label ID="lblFilterMessage" runat="server" CssClass="filter-message" />

            <!-- PROJECT LIST -->
            <div class="browse-layout">

                <!-- LEFT: PROJECT LIST -->
                <section class="projects-column">

                    <asp:Panel ID="pnlNoProjects" runat="server" Visible="false" CssClass="no-projects-message">
                        <h3>No projects available</h3>
                        <p>There are no open projects at the moment. Check back later or ask an employer to post a project.</p>
                    </asp:Panel>

                    <asp:Repeater ID="rptProjects" runat="server" OnItemCommand="rptProjects_ItemCommand">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnSelectProject" runat="server"
                                CssClass="project-card"
                                CommandName="SelectProject"
                                CommandArgument='<%# Eval("projectID") %>'>

                                <span class="project-info">
                                    <span class="project-name"><%# Eval("title") %></span>
                                    <span class="project-category"><%# Eval("category") %></span>
                                    <span class="project-meta">
                                        Posted <%# Convert.ToDateTime(Eval("dateCreated")).ToString("dd MMM yyyy") %>
                                    </span>
                                </span>
                                <span class="project-budget">
                                    <span>R<%# Convert.ToDecimal(Eval("budget")).ToString("N0") %></span>
                                    <small><%# Eval("budgetType").ToString() == "Fixed" ? "Fixed Price" : Eval("budgetType").ToString() == "Hourly" ? "Hourly Rate" : Eval("budgetType") %></small>
                                </span>

                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>

                </section>

                <!-- RIGHT: PROJECT DETAILS -->
                <section class="details-column">

                    <!-- Empty state -->
                    <asp:Panel ID="pnlNoSelection" runat="server" CssClass="no-selection-panel">
                        <h3>Select a project</h3>
                        <p>Click on a project from the list to view its full details, budget, deadline and employer information.</p>
                    </asp:Panel>

                    <!-- Project details (hidden until selected) -->
                    <asp:Panel ID="pnlProjectDetails" runat="server" Visible="false">

                        <p class="posted-information">
                            <asp:Label ID="lblPosted" runat="server" />
                        </p>

                        <h2><asp:Label ID="lblProjectTitle" runat="server" /></h2>

                        <div class="details-line"></div>

                        <h3>About the project</h3>
                        <p class="details-description">
                            <asp:Label ID="lblDescription" runat="server" />
                        </p>

                        <!-- PROJECT INFO GRID -->
                        <div class="details-grid">
                            <div class="detail-box">
                                <div>
                                    <small>Budget</small>
                                    <strong><asp:Label ID="lblBudget" runat="server" /></strong>
                                </div>
                            </div>
                            <div class="detail-box">
                                <div>
                                    <small>Deadline</small>
                                    <strong><asp:Label ID="lblDeadline" runat="server" /></strong>
                                </div>
                            </div>
                            <div class="detail-box">
                                <div>
                                    <small>Category</small>
                                    <strong><asp:Label ID="lblCategory" runat="server" /></strong>
                                </div>
                            </div>
                            <div class="detail-box">
                                <div>
                                    <small>Experience Level</small>
                                    <strong><asp:Label ID="lblExperience" runat="server" /></strong>
                                </div>
                            </div>
                        </div>

                        <!-- EMPLOYER -->
                        <div class="employer-section">
                            <h3>About the employer</h3>
                            <div class="employer-row">
                                <div class="employer-avatar">
                                    <asp:Label ID="lblEmployerInitials" runat="server" />
                                </div>
                                <div class="employer-information">
                                    <strong><asp:Label ID="lblEmployerName" runat="server" /></strong>
                                    <small><asp:Label ID="lblEmployerDetails" runat="server" /></small>
                                    <span><asp:Label ID="lblEmployerRating" runat="server" /></span>
                                </div>
                            </div>
                        </div>

                        <!-- ACTIONS -->
                        <div class="project-actions">
                            <asp:Button ID="btnSubmitProposal" runat="server"
                                Text="Submit Proposal" CssClass="submit-button"
                                OnClick="btnSubmitProposal_Click" />
                            <asp:Button ID="btnViewDetails" runat="server"
                                Text="View Details &amp; Comment" CssClass="save-button"
                                OnClick="btnViewDetails_Click" />
                        </div>

                        <!-- COMMENTS SECTION - View on Project Details page -->

                        <asp:Label ID="lblProjectMessage" runat="server" CssClass="project-message" />

                    </asp:Panel>

                </section>

            </div>

        </section>

    </div>

</asp:Content>

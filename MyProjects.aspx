<%@ Page Title="My Projects"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="MyProjects.aspx.cs"
    Inherits="FreeHubProject.MyProjects" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="MyProjectsHead"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <link href="<%= ResolveUrl("~/MyProjects.css?v=6") %>"
          rel="stylesheet"
          type="text/css" />
</asp:Content>

<asp:Content ID="MyProjectsContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="my-projects-page">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <main class="my-projects-main">

            <div class="project-breadcrumb">
                <a href="Default.aspx">Dashboard</a>
                <span>&#8250;</span>
                <strong>My Projects</strong>
            </div>

            <div class="my-projects-heading">
                <div>
                    <h1>My Projects</h1>
                    <p>Manage your active, completed and cancelled projects.</p>
                </div>

                <a href="PostProject.aspx" class="my-projects-post-button">
                    + Post a Project
                </a>
            </div>

            <section class="my-projects-tabs">
                <asp:HyperLink
                    ID="lnkTabActive"
                    runat="server"
                    NavigateUrl="~/MyProjects.aspx?view=Active"
                    CssClass="my-projects-tab">
                    Active Projects
                    <span>
                        <asp:Label ID="lblActiveCount" runat="server" Text="0" />
                    </span>
                </asp:HyperLink>

                <asp:HyperLink
                    ID="lnkTabCompleted"
                    runat="server"
                    NavigateUrl="~/MyProjects.aspx?view=Completed"
                    CssClass="my-projects-tab">
                    Completed Projects
                    <span>
                        <asp:Label ID="lblCompletedCount" runat="server" Text="0" />
                    </span>
                </asp:HyperLink>

                <asp:HyperLink
                    ID="lnkTabCancelled"
                    runat="server"
                    NavigateUrl="~/MyProjects.aspx?view=Cancelled"
                    CssClass="my-projects-tab">
                    Cancelled Projects
                    <span>
                        <asp:Label ID="lblCancelledCount" runat="server" Text="0" />
                    </span>
                </asp:HyperLink>

                <asp:DropDownList ID="ddlSortProjects" runat="server" CssClass="my-projects-sort mp-sort"
                    AutoPostBack="true" OnSelectedIndexChanged="ddlSortProjects_SelectedIndexChanged">
                    <asp:ListItem Text="Newest First" Value="Newest" />
                    <asp:ListItem Text="Oldest First" Value="Oldest" />
                </asp:DropDownList>
            </section>

            <!-- TWO CONTAINERS: scrollable project list (left) + info sidebar (right) -->
            <div class="mp-layout">

                <!-- LEFT: project list -->
                <section class="mp-list-wrap">
                    <div class="mp-list-heading">
                        <h2><asp:Label ID="lblSectionTitle" runat="server" Text="Active Projects" /></h2>
                        <p>Select a project to view its details, proposals and contracts.</p>
                    </div>

                    <asp:Panel ID="pnlProjectList" runat="server" CssClass="mp-list">
                        <asp:Repeater ID="rptProjects" runat="server" OnItemCommand="rptProjects_ItemCommand">
                            <ItemTemplate>
                                <article class="mp-card">

                                    <!-- LEFT ZONE: folder icon + name + status -->
                                    <div class="mp-left">
                                        <span class="mp-folder-icon" aria-hidden="true">&#128193;</span>
                                        <div class="mp-left-text">
                                            <h3 class="mp-name"><%# Server.HtmlEncode(Convert.ToString(Eval("title"))) %></h3>
                                            <span class='<%# "mp-status " + GetStatusClass(Eval("projectStatus")) %>'><%# Server.HtmlEncode(Convert.ToString(Eval("projectStatus"))) %></span>
                                        </div>
                                    </div>

                                    <!-- RIGHT ZONE: details row + actions row -->
                                    <div class="mp-right">
                                        <div class="mp-details">
                                            <div class="mp-detail">
                                                <span class="mp-detail-icon mp-icon-budget" aria-hidden="true">&#128176;</span>
                                                <span class="mp-detail-text">
                                                    <span class="mp-detail-label">Budget</span>
                                                    <strong class="mp-detail-value">R<%# Convert.ToDecimal(Eval("budget")).ToString("N0") %></strong>
                                                </span>
                                            </div>

                                            <span class="mp-divider"></span>

                                            <div class="mp-detail">
                                                <span class="mp-detail-icon mp-icon-proposals" aria-hidden="true">&#128101;</span>
                                                <span class="mp-detail-text">
                                                    <span class="mp-detail-label">Proposals</span>
                                                    <strong class="mp-detail-value"><%# Eval("proposalCount") %></strong>
                                                </span>
                                            </div>

                                            <span class="mp-divider"></span>

                                            <div class="mp-detail">
                                                <span class="mp-detail-icon mp-icon-posted" aria-hidden="true">&#128197;</span>
                                                <span class="mp-detail-text">
                                                    <span class="mp-detail-label">Posted</span>
                                                    <strong class="mp-detail-value"><%# TimeHelper.ToSast(Eval("dateCreated")).ToString("dd MMM yyyy") %></strong>
                                                </span>
                                            </div>
                                        </div>

                                        <div class="mp-actions">
                                            <!-- Conditional Review Work button (status "Under Review") - preserved -->
                                            <asp:PlaceHolder ID="phReviewWork" runat="server" Visible='<%# Eval("projectStatus").ToString() == "Under Review" %>'>
                                                <a href='ReviewWork.aspx?projectId=<%# Eval("projectID") %>' class="mp-btn mp-btn-review">&#128269; Review Work</a>
                                            </asp:PlaceHolder>

                                            <a href='EditProject.aspx?id=<%# Eval("projectID") %>' class="mp-btn mp-btn-edit">&#9998; Edit Project</a>
                                            <a href="SelectProposal.aspx" class="mp-btn mp-btn-view">&#128065; View Proposals</a>

                                            <asp:LinkButton ID="btnDeleteProject" runat="server"
                                                CommandName="DeleteProject"
                                                CommandArgument='<%# Eval("projectID") %>'
                                                CssClass="mp-btn mp-btn-delete"
                                                OnClientClick="return fhConfirm(this, 'Are you sure you want to delete this project? This action cannot be undone.', 'Delete Project');">
                                                &#128465; Delete
                                            </asp:LinkButton>
                                        </div>
                                    </div>

                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </asp:Panel>

                    <asp:Panel ID="pnlEmptyProjects" runat="server" CssClass="mp-empty" Visible="false">
                        <div class="mp-empty-icon">&#128193;</div>
                        <h3>No projects found</h3>
                        <p>There are no projects available in this section.</p>
                    </asp:Panel>
                </section>

                <!-- RIGHT: information sidebar -->
                <aside class="mp-sidebar">
                    <div class="mp-info-card">
                        <h4>Tips for Managing Your Projects</h4>
                        <ul class="mp-tips">
                            <li>Write clear and detailed project descriptions.</li>
                            <li>Review proposals and choose the right freelancer.</li>
                            <li>Communicate your requirements clearly.</li>
                            <li>Track progress and approve work on time.</li>
                            <li>Keep your project updated and respond to freelancers.</li>
                        </ul>
                    </div>

                    <div class="mp-info-card">
                        <h4>Need Help?</h4>
                        <p>If you need assistance with managing your projects, our support team is here.</p>
                        <a href="mailto:support@freehub.co.za" class="mp-support-btn">Contact Support</a>
                    </div>

                    <div class="mp-info-card">
                        <h4>Next Step</h4>
                        <p>Review the proposals for your active projects and choose the best freelancer.</p>
                    </div>
                </aside>

            </div>

        </main>

    </div>
</asp:Content>
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

    <link href="<%= ResolveUrl("~/MyProjects.css?v=5") %>"
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

                <a href="Default.aspx">
                    Dashboard
                </a>

                <span>�</span>

                <strong>
                    My Projects
                </strong>

            </div>


            <div class="my-projects-heading">

                <div>

                    <h1>
                        My Projects
                    </h1>

                    <p>
                        Manage your active, completed and cancelled projects.
                    </p>

                </div>

                <a href="PostProject.aspx"
                   class="my-projects-post-button">

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
                        <asp:Label
                            ID="lblActiveCount"
                            runat="server"
                            Text="0">
                        </asp:Label>
                    </span>

                </asp:HyperLink>


                <asp:HyperLink
                    ID="lnkTabCompleted"
                    runat="server"
                    NavigateUrl="~/MyProjects.aspx?view=Completed"
                    CssClass="my-projects-tab">

                    Completed Projects

                    <span>
                        <asp:Label
                            ID="lblCompletedCount"
                            runat="server"
                            Text="0">
                        </asp:Label>
                    </span>

                </asp:HyperLink>


                <asp:HyperLink
                    ID="lnkTabCancelled"
                    runat="server"
                    NavigateUrl="~/MyProjects.aspx?view=Cancelled"
                    CssClass="my-projects-tab">

                    Cancelled Projects

                    <span>
                        <asp:Label
                            ID="lblCancelledCount"
                            runat="server"
                            Text="0">
                        </asp:Label>
                    </span>

                </asp:HyperLink>

            </section>


            <section class="my-projects-list-card">

                <div class="my-projects-list-heading">

                    <div>

                        <h2>

                            <asp:Label
                                ID="lblSectionTitle"
                                runat="server"
                                Text="Active Projects">
                            </asp:Label>

                        </h2>

                        <p>
                            Select a project to view its details,
                            proposals and contracts.
                        </p>

                    </div>

                    <asp:DropDownList
                        ID="ddlSortProjects"
                        runat="server"
                        CssClass="my-projects-sort">

                        <asp:ListItem
                            Text="Newest First"
                            Value="Newest">
                        </asp:ListItem>

                        <asp:ListItem
                            Text="Oldest First"
                            Value="Oldest">
                        </asp:ListItem>

                    </asp:DropDownList>

                </div>


                <asp:Panel
                    ID="pnlProjectList"
                    runat="server">

                    <asp:Repeater ID="rptProjects" runat="server" OnItemCommand="rptProjects_ItemCommand">
                        <ItemTemplate>
                            <article class="my-project-card">
                                <div class="my-project-information">
                                    <div class="my-project-title-row">
                                        <h3><%# Eval("title") %></h3>
                                        <span class="my-project-status active-project-status"><%# Eval("projectStatus") %></span>
                                    </div>
                                    <p><%# Eval("description").ToString().Length > 100 ? Eval("description").ToString().Substring(0, 100) + "..." : Eval("description") %></p>
                                    <div class="my-project-meta">
                                        <span>Budget: <strong>R<%# Convert.ToDecimal(Eval("budget")).ToString("N0") %></strong></span>
                                        <span>Proposals: <strong><%# Eval("proposalCount") %></strong></span>
                                        <span>Posted: <strong><%# Convert.ToDateTime(Eval("dateCreated")).ToString("dd MMM yyyy") %></strong></span>
                                    </div>
                                </div>
                                <div class="my-project-actions">
                                    <a href='EditProject.aspx?id=<%# Eval("projectID") %>' class="my-project-secondary-button">Edit Project</a>
                                    <a href="SelectProposal.aspx" class="my-project-primary-button">View Proposals</a>
                                    <asp:LinkButton ID="btnDeleteProject" runat="server"
                                        CommandName="DeleteProject"
                                        CommandArgument='<%# Eval("projectID") %>'
                                        CssClass="my-project-delete-button"
                                        OnClientClick="return confirm('Are you sure you want to delete this project? This action cannot be undone.');">
                                        &#128465; Delete
                                    </asp:LinkButton>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>

                </asp:Panel>


                <asp:Panel
                    ID="pnlEmptyProjects"
                    runat="server"
                    CssClass="my-projects-empty"
                    Visible="false">

                    <div>
                        ?
                    </div>

                    <h3>
                        No projects found
                    </h3>

                    <p>
                        There are no projects available in this section.
                    </p>

                </asp:Panel>

            </section>

        </main>

    </div>

</asp:Content>
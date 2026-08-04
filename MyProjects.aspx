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

                    <article class="my-project-card">

                        <div class="my-project-icon">
                            ?
                        </div>

                        <div class="my-project-information">

                            <div class="my-project-title-row">

                                <h3>
                                    E-commerce Website Redesign
                                </h3>

                                <asp:Label
                                    ID="lblProjectStatus"
                                    runat="server"
                                    CssClass="my-project-status active-project-status"
                                    Text="Active">
                                </asp:Label>

                            </div>

                            <p>
                                Modern redesign of an existing e-commerce
                                platform with improved UI and responsiveness.
                            </p>

                            <div class="my-project-meta">

                                <span>
                                    Budget:
                                    <strong>R8,000 - R15,000</strong>
                                </span>

                                <span>
                                    Proposals:
                                    <strong>8</strong>
                                </span>

                                <span>
                                    Posted:
                                    <strong>10 May 2024</strong>
                                </span>

                            </div>

                        </div>


                        <div class="my-project-actions">

                            <a href="ProjectDetails.aspx"
                               class="my-project-secondary-button">

                                View Details

                            </a>

                            <a href="SelectProposal.aspx"
                               class="my-project-primary-button">

                                View Proposals

                            </a>

                        </div>

                    </article>

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
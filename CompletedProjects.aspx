<%@ Page Title="Completed Projects"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="CompletedProjects.aspx.cs"
    Inherits="FreeHubProject.CompletedProjects" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="completed-page-layout">

        <!-- LEFT SIDEBAR -->

        <uc:Sidebar runat="server" ID="SidebarControl" />


        <!-- MAIN CONTENT -->

        <main class="completed-main-content">


            <!-- BREADCRUMB -->

            <div class="completed-breadcrumb">

                My Projects

                <span>&#8250;</span>

                <strong>

                    Completed Projects

                </strong>

            </div>


            <!-- PAGE HEADING -->

            <div class="completed-heading">

                <div>

                    <h1>

                        Completed Projects

                    </h1>


                    <p>

                        View completed projects and rate your
                        experience working with freelancers.

                    </p>

                </div>


                <div class="completed-count">

                    <strong>

                        <asp:Literal ID="litCompletedCount" runat="server" Text="0" />

                    </strong>

                    Completed

                </div>

            </div>


            <!-- STATUS MESSAGE -->

            <asp:Panel
                ID="pnlCompletedMessage"
                runat="server"
                CssClass="completed-status-message"
                Visible="false">

                <asp:Label
                    ID="lblCompletedMessage"
                    runat="server">

                </asp:Label>

            </asp:Panel>


            <!-- PROJECT LIST (real data) -->

            <asp:Repeater
                ID="rptCompleted"
                runat="server"
                OnItemCommand="rptCompleted_ItemCommand">

                <ItemTemplate>

                    <section class="completed-project-card">


                        <!-- PROJECT HEADER -->

                        <div class="completed-project-top">


                            <div class="completed-project-icon">

                                <%# Server.HtmlEncode(GetInitials(Eval("title"))) %>

                            </div>


                            <div class="completed-project-information">

                                <div class="completed-project-title-row">

                                    <h2>

                                        <%# Eval("title") %>

                                    </h2>


                                    <span class="completed-badge">

                                        Completed

                                    </span>

                                </div>


                                <p>

                                    <%# Eval("description") %>

                                </p>


                                <div class="completed-project-details">

                                    <span>

                                        Completed:
                                        <%# Convert.ToDateTime(Eval("deadline")).ToString("dd MMM yyyy") %>

                                    </span>


                                    <span>

                                        Total Amount:
                                        R<%# Convert.ToDecimal(Eval("proposedRate")).ToString("N0") %>

                                    </span>


                                    <span>

                                        Duration:
                                        <%# Eval("estimatedCompletionTime") %>

                                    </span>

                                </div>

                            </div>

                        </div>


                        <!-- FREELANCER INFORMATION -->

                        <div class="completed-freelancer-section">


                            <div class="completed-section-heading">

                                <h3>

                                    Freelancer

                                </h3>


                                <span>

                                    Project successfully delivered

                                </span>

                            </div>


                            <div class="completed-freelancer-card">


                                <div class="completed-avatar">

                                    <%# Server.HtmlEncode(GetInitials(Eval("freelancerName"))) %>

                                </div>


                                <div class="completed-freelancer-info">

                                    <div class="completed-name-row">

                                        <h3>

                                            <%# Eval("freelancerName") %>

                                        </h3>

                                    </div>


                                    <span>

                                        <%# Convert.ToDecimal(Eval("freelancerRating")).ToString("0.0") %>

                                        <small>

                                            (<%# Eval("freelancerReviewCount") %> Reviews)

                                        </small>

                                    </span>

                                </div>


                                <asp:LinkButton
                                    runat="server"
                                    CssClass="completed-view-button"
                                    CommandName="ViewFreelancer"
                                    CommandArgument='<%# Eval("freelancerUserID") %>'
                                    CausesValidation="false"
                                    Text="View Profile" />

                            </div>

                        </div>


                        <!-- PROJECT COMPLETION -->

                        <div class="completed-delivery-section">


                            <div>

                                <h3>

                                    Project Delivery

                                </h3>


                                <p>

                                    The freelancer submitted the final
                                    project and the work was accepted.

                                </p>

                            </div>


                            <div class="completed-delivery-status">


                                <div>

                                    <strong>

                                        Delivery Accepted

                                    </strong>


                                    <small>

                                        Project completed successfully

                                    </small>

                                </div>

                            </div>

                        </div>


                        <!-- ACTIONS -->

                        <div class="completed-project-actions">


                            <div>

                                <h3>

                                    Rate Your Experience

                                </h3>


                                <p>

                                    Your feedback helps build a trusted
                                    FreeHUB community.

                                </p>

                            </div>


                            <div class="completed-action-buttons">


                                <asp:LinkButton
                                    runat="server"
                                    CssClass="completed-rate-button"
                                    CommandName="RateFreelancer"
                                    CommandArgument='<%# Eval("projectID") %>'
                                    CausesValidation="false"
                                    Text="Rate Freelancer" />


                                <asp:LinkButton
                                    runat="server"
                                    CssClass="completed-project-button"
                                    CommandName="ViewProject"
                                    CommandArgument='<%# Eval("projectID") %>'
                                    CausesValidation="false"
                                    Text="View Project" />

                            </div>

                        </div>


                    </section>

                </ItemTemplate>

            </asp:Repeater>


            <!-- EMPTY STATE -->

            <asp:Panel
                ID="pnlNoCompleted"
                runat="server"
                CssClass="completed-empty"
                Visible="false">

                <h3>No completed projects yet</h3>

                <p>

                    When a freelancer finishes a project and you accept
                    the delivery, it will appear here.

                </p>

            </asp:Panel>


            <!-- INFORMATION BOX -->

            <section class="completed-information-box">


                <div class="completed-information-icon">

                    i

                </div>


                <div>

                    <strong>

                        Share your experience

                    </strong>


                    <p>

                        Your rating will help other employers
                        make informed decisions when choosing
                        freelancers.

                    </p>

                </div>

            </section>


        </main>

    </div>

</asp:Content>
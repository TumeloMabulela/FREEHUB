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

                        1

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


            <!-- PROJECT CARD -->

            <section class="completed-project-card">


                <!-- PROJECT HEADER -->

                <div class="completed-project-top">


                    <div class="completed-project-icon">

                        ?

                    </div>


                    <div class="completed-project-information">

                        <div class="completed-project-title-row">

                            <h2>

                                E-commerce Website Redesign

                            </h2>


                            <span class="completed-badge">

                                ? Completed

                            </span>

                        </div>


                        <p>

                            A modern and responsive e-commerce
                            website redesign with improved
                            navigation and user experience.

                        </p>


                        <div class="completed-project-details">

                            <span>

                                ?? Completed:
                                25 May 2024

                            </span>


                            <span>

                                ?? Total Amount:
                                R12,000

                            </span>


                            <span>

                                ? Duration:
                                15 Days

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

                            TM

                        </div>


                        <div class="completed-freelancer-info">

                            <div class="completed-name-row">

                                <h3>

                                    Thabo Mokoena

                                </h3>


                                <span class="completed-top-rated">

                                    Top Rated Freelancer

                                </span>

                            </div>


                            <p>

                                Full-Stack Web Developer

                            </p>


                            <span>

                                ? 4.8

                                <small>

                                    (56 Reviews)

                                </small>

                            </span>


                            <span class="completed-location">

                                � South Africa

                            </span>

                        </div>


                        <asp:Button
                            ID="btnViewFreelancer"
                            runat="server"
                            Text="View Profile"
                            CssClass="completed-view-button"
                            CausesValidation="false"
                            OnClick="btnViewFreelancer_Click" />

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

                        <span>

                            ?

                        </span>


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


                        <asp:Button
                            ID="btnRateFreelancer"
                            runat="server"
                            Text="? Rate Freelancer"
                            CssClass="completed-rate-button"
                            CausesValidation="false"
                            OnClick="btnRateFreelancer_Click" />


                        <asp:Button
                            ID="btnViewProject"
                            runat="server"
                            Text="View Project"
                            CssClass="completed-project-button"
                            CausesValidation="false"
                            OnClick="btnViewProject_Click" />

                    </div>

                </div>


            </section>


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
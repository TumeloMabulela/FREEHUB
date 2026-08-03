<%@ Page Title="Select Proposal"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="SelectProposal.aspx.cs"
    Inherits="FreeHubProject.SelectProposal" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="select-proposal-page">

        <!-- EMPLOYER SIDEBAR -->
        <aside class="employer-sidebar">

            <div class="employer-menu">

                <a href="Dashboard.aspx" class="employer-link">
                    <span>▦</span>
                    Dashboard
                </a>

                <a href="FindWork.aspx" class="employer-link">
                    <span>⌕</span>
                    Find Work
                </a>

                <a href="MyProjects.aspx"
                    class="employer-link active">

                    <span>▣</span>
                    My Projects
                </a>

                <a href="Messages.aspx" class="employer-link">
                    <span>✉</span>
                    Messages
                </a>

                <a href="#" class="employer-link">
                    <span>▤</span>
                    Contracts
                </a>

                <a href="#" class="employer-link">
                    <span>R</span>
                    Payments
                </a>

            </div>


            <div class="employer-account">

                <p>ACCOUNT</p>

                <a href="#" class="employer-link">
                    <span>●</span>
                    Profile
                </a>

                <a href="#" class="employer-link">
                    <span>⚙</span>
                    Company Settings
                </a>

                <a href="#" class="employer-link">
                    <span>◯</span>
                    Notification Settings
                </a>

                <a href="#" class="employer-link">
                    <span>?</span>
                    Help &amp; Support
                </a>

            </div>


            <!-- SUPPORT CARD -->
            <div class="sidebar-support">

                <h4>Need Help?</h4>

                <p>
                    Our support team is here
                    to help you.
                </p>

                <asp:Button
                    ID="btnContactSupport"
                    runat="server"
                    Text="◔ Contact Support"
                    CssClass="support-button"
                    OnClick="btnContactSupport_Click" />

            </div>

        </aside>


        <!-- MAIN CONTENT -->
        <main class="select-proposal-main">


            <!-- BREADCRUMBS -->
            <div class="proposal-breadcrumb">

                Dashboard

                <span>›</span>

                My Projects

                <span>›</span>

                Website Development Project

                <span>›</span>

                <strong>Proposals</strong>

            </div>


            <!-- PAGE TITLE -->
            <div class="select-page-heading">

                <div>

                    <h1>Select Proposal</h1>

                    <p>
                        Review proposals received and
                        select the best fit for your project.
                    </p>

                </div>


                <asp:Button
                    ID="btnBackToProject"
                    runat="server"
                    Text="← Back to Project"
                    CssClass="back-project-button"
                    OnClick="btnBackToProject_Click" />

            </div>


            <!-- PROJECT SUMMARY -->
            <section class="selected-project-summary">

                <div class="summary-project-icon">
                    ▣
                </div>


                <div class="summary-project-information">

                    <h2>
                        Website Development Project
                    </h2>

                    <p>
                        We need a modern and user-friendly
                        website with responsive pages.
                    </p>

                    <a href="#">
                        View Project Details
                    </a>

                </div>


                <div class="summary-information">

                    <small>Budget</small>

                    <strong>
                        R8,000 - R15,000
                    </strong>

                </div>


                <div class="summary-information">

                    <small>Deadline</small>

                    <strong>
                        30 May 2026
                    </strong>

                    <em>
                        18 days left
                    </em>

                </div>


                <div class="summary-information">

                    <small>Proposals Received</small>

                    <strong>
                        4 Proposals
                    </strong>

                </div>

            </section>


            <!-- PROPOSALS AND RIGHT PANEL -->
            <div class="proposal-content-layout">


                <!-- PROPOSALS -->
                <section class="proposals-area">


                    <div class="proposals-top">

                        <h2>
                            Proposals
                            <span>(4)</span>
                        </h2>


                        <div>

                            <label>
                                Sort by:
                            </label>

                            <asp:DropDownList
                                ID="ddlProposalSort"
                                runat="server"
                                CssClass="proposal-sort">

                                <asp:ListItem>
                                    Newest First
                                </asp:ListItem>

                                <asp:ListItem>
                                    Oldest First
                                </asp:ListItem>

                                <asp:ListItem>
                                    Lowest Rate
                                </asp:ListItem>

                                <asp:ListItem>
                                    Highest Rating
                                </asp:ListItem>

                            </asp:DropDownList>

                        </div>

                    </div>


                    <!-- PROPOSAL 1 -->
                    <div class="freelancer-proposal selected-proposal">

                        <div class="proposal-select-circle">
                            ●
                        </div>


                        <div class="freelancer-avatar avatar-blue">
                            TM
                        </div>


                        <div class="freelancer-proposal-info">

                            <div class="freelancer-name-row">

                                <h3>
                                    Thabo Mokoena
                                </h3>

                                <span class="top-rated">
                                    Top Rated
                                </span>

                            </div>


                            <p class="freelancer-rating">

                                ★ 4.8

                                <span>
                                    (56 Reviews)
                                </span>

                                • South Africa

                            </p>


                            <p class="proposal-preview">

                                I have over 5 years of experience
                                in designing and developing modern,
                                responsive websites. I specialise in
                                creating user-friendly interfaces.

                            </p>


                            <a href="#">
                                View Full Proposal
                            </a>

                        </div>


                        <div class="proposal-rate">

                            <small>
                                Proposed Rate
                            </small>

                            <strong>
                                R12,000
                            </strong>


                            <small>
                                Estimated Time
                            </small>

                            <strong>
                                15 days
                            </strong>


                            <em>
                                Submitted 2 hours ago
                            </em>

                        </div>


                        <div class="proposal-actions">

                            <asp:Button
                                ID="btnSelectProposal1"
                                runat="server"
                                Text="Select Proposal"
                                CssClass="select-proposal-button"
                                OnClick="btnSelectProposal1_Click" />


                            <asp:Button
                                ID="btnViewProposal1"
                                runat="server"
                                Text="View Details"
                                CssClass="view-proposal-button"
                                OnClick="btnViewProposal1_Click" />

                        </div>

                    </div>


                    <!-- PROPOSAL 2 -->
                    <div class="freelancer-proposal">

                        <div class="proposal-select-circle empty">
                            ○
                        </div>


                        <div class="freelancer-avatar avatar-purple">
                            AK
                        </div>


                        <div class="freelancer-proposal-info">

                            <div class="freelancer-name-row">

                                <h3>
                                    Aisha Khan
                                </h3>

                                <span class="top-rated">
                                    Top Rated
                                </span>

                            </div>


                            <p class="freelancer-rating">

                                ★ 4.7

                                <span>
                                    (34 Reviews)
                                </span>

                                • Pakistan

                            </p>


                            <p class="proposal-preview">

                                I can deliver a clean, modern and
                                fully responsive website that aligns
                                with your brand and business goals.

                            </p>


                            <a href="#">
                                View Full Proposal
                            </a>

                        </div>


                        <div class="proposal-rate">

                            <small>
                                Proposed Rate
                            </small>

                            <strong>
                                R10,500
                            </strong>


                            <small>
                                Estimated Time
                            </small>

                            <strong>
                                18 days
                            </strong>


                            <em>
                                Submitted 5 hours ago
                            </em>

                        </div>


                        <div class="proposal-actions">

                            <asp:Button
                                ID="btnSelectProposal2"
                                runat="server"
                                Text="Select Proposal"
                                CssClass="select-proposal-button"
                                OnClick="btnSelectProposal2_Click" />


                            <asp:Button
                                ID="btnViewProposal2"
                                runat="server"
                                Text="View Details"
                                CssClass="view-proposal-button"
                                OnClick="btnViewProposal2_Click" />

                        </div>

                    </div>


                    <!-- PROPOSAL 3 -->
                    <div class="freelancer-proposal">

                        <div class="proposal-select-circle empty">
                            ○
                        </div>


                        <div class="freelancer-avatar avatar-lightblue">
                            JT
                        </div>


                        <div class="freelancer-proposal-info">

                            <div class="freelancer-name-row">

                                <h3>
                                    John Tau
                                </h3>

                                <span class="top-rated">
                                    Top Rated
                                </span>

                            </div>


                            <p class="freelancer-rating">

                                ★ 4.6

                                <span>
                                    (22 Reviews)
                                </span>

                                • Kenya

                            </p>


                            <p class="proposal-preview">

                                I will create a professional website
                                with a modern look and better user
                                experience. The website will be
                                responsive and easy to use.

                            </p>


                            <a href="#">
                                View Full Proposal
                            </a>

                        </div>


                        <div class="proposal-rate">

                            <small>
                                Proposed Rate
                            </small>

                            <strong>
                                R9,000
                            </strong>


                            <small>
                                Estimated Time
                            </small>

                            <strong>
                                20 days
                            </strong>


                            <em>
                                Submitted 1 day ago
                            </em>

                        </div>


                        <div class="proposal-actions">

                            <asp:Button
                                ID="btnSelectProposal3"
                                runat="server"
                                Text="Select Proposal"
                                CssClass="select-proposal-button"
                                OnClick="btnSelectProposal3_Click" />


                            <asp:Button
                                ID="btnViewProposal3"
                                runat="server"
                                Text="View Details"
                                CssClass="view-proposal-button"
                                OnClick="btnViewProposal3_Click" />

                        </div>

                    </div>


                    <!-- PROPOSAL 4 -->
                    <div class="freelancer-proposal">

                        <div class="proposal-select-circle empty">
                            ○
                        </div>


                        <div class="freelancer-avatar avatar-yellow">
                            SP
                        </div>


                        <div class="freelancer-proposal-info">

                            <div class="freelancer-name-row">

                                <h3>
                                    Sarah Patel
                                </h3>

                                <span class="top-rated">
                                    Top Rated
                                </span>

                            </div>


                            <p class="freelancer-rating">

                                ★ 4.5

                                <span>
                                    (17 Reviews)
                                </span>

                                • India

                            </p>


                            <p class="proposal-preview">

                                I can deliver a high-quality website
                                that matches your brand and provides
                                an excellent experience for your
                                customers.

                            </p>


                            <a href="#">
                                View Full Proposal
                            </a>

                        </div>


                        <div class="proposal-rate">

                            <small>
                                Proposed Rate
                            </small>

                            <strong>
                                R8,500
                            </strong>


                            <small>
                                Estimated Time
                            </small>

                            <strong>
                                22 days
                            </strong>


                            <em>
                                Submitted 1 day ago
                            </em>

                        </div>


                        <div class="proposal-actions">

                            <asp:Button
                                ID="btnSelectProposal4"
                                runat="server"
                                Text="Select Proposal"
                                CssClass="select-proposal-button"
                                OnClick="btnSelectProposal4_Click" />


                            <asp:Button
                                ID="btnViewProposal4"
                                runat="server"
                                Text="View Details"
                                CssClass="view-proposal-button"
                                OnClick="btnViewProposal4_Click" />

                        </div>

                    </div>


                    <asp:Button
                        ID="btnLoadMoreProposals"
                        runat="server"
                        Text="Load More Proposals  ⌄"
                        CssClass="load-proposals-button"
                        OnClick="btnLoadMoreProposals_Click" />


                    <asp:Label
                        ID="lblProposalMessage"
                        runat="server"
                        CssClass="proposal-page-message">
                    </asp:Label>

                </section>


                <!-- RIGHT SIDE -->
                <aside class="proposal-right-side">


                    <!-- TIPS -->
                    <section class="proposal-tips">

                        <h3>
                            Tips for Choosing the
                            Right Freelancer
                        </h3>


                        <div class="tip">

                            <span>▣</span>

                            <p>
                                Review cover letters and
                                understand the freelancer's
                                approach.
                            </p>

                        </div>


                        <div class="tip">

                            <span>▣</span>

                            <p>
                                Compare proposed rates
                                and delivery times.
                            </p>

                        </div>


                        <div class="tip">

                            <span>★</span>

                            <p>
                                Check ratings, reviews
                                and past work.
                            </p>

                        </div>


                        <div class="tip">

                            <span>▤</span>

                            <p>
                                Choose a proposal that
                                best fits your needs
                                and budget.
                            </p>

                        </div>

                    </section>


                    <!-- HELP -->
                    <section class="proposal-help">

                        <h3>
                            Need Help?
                        </h3>

                        <p>
                            If you need assistance in
                            choosing the right freelancer,
                            our support team is here.
                        </p>


                        <asp:Button
                            ID="btnHelpSupport"
                            runat="server"
                            Text="◔ Contact Support"
                            CssClass="proposal-help-button"
                            OnClick="btnHelpSupport_Click" />

                    </section>


                    <!-- NEXT STEP -->
                    <section class="proposal-next-step">

                        <div>

                            <h3>
                                Next Step
                            </h3>

                            <p>
                                After selecting a proposal,
                                you can review the contract
                                details before approving.
                            </p>

                        </div>

                        <span>
                            ›
                        </span>

                    </section>

                </aside>

            </div>

        </main>

    </div>

</asp:Content>
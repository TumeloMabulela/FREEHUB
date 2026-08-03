<%@ Page Title="Review Proposal"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="ReviewProposal.aspx.cs"
    Inherits="FreeHubProject.ReviewProposal" %>

<asp:Content ID="ReviewProposalHead"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <link href="<%= ResolveUrl("~/ReviewProposal.css?v=20") %>"
          rel="stylesheet"
          type="text/css" />

</asp:Content>


<asp:Content ID="ReviewProposalContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="review-proposal-page">

        <!-- =====================================
             EMPLOYER SIDEBAR
        ====================================== -->

        <aside class="review-sidebar">

            <div class="review-menu">

                <a href="Dashboard.aspx"
                   class="review-link">

                    <span class="review-link-icon">
                        ▦
                    </span>

                    <span>
                        Dashboard
                    </span>

                </a>


                <a href="FindWork.aspx"
                   class="review-link">

                    <span class="review-link-icon">
                        ⌕
                    </span>

                    <span>
                        Find Work
                    </span>

                </a>


                <!-- MY PROJECTS -->

                <a href="MyProjects.aspx"
                   class="review-link active">

                    <span class="review-link-icon">
                        ▣
                    </span>

                    <span class="review-link-text">
                        My Projects
                    </span>

                    <span class="review-project-arrow">
                        ▴
                    </span>

                </a>


                <!-- MINI SECTION -->

                <div class="review-project-mini-menu">

                    <a href="MyProjects.aspx?view=Active">
                        Active Projects
                    </a>

                    <a href="MyProjects.aspx?view=Completed">
                        Completed Projects
                    </a>

                    <a href="MyProjects.aspx?view=Cancelled">
                        Cancelled Projects
                    </a>

                </div>


                <a href="Proposals.aspx"
                   class="review-link review-sub-active">

                    <span class="review-link-icon">
                        ▤
                    </span>

                    <span>
                        Proposals
                    </span>

                </a>


                <a href="Messages.aspx"
                   class="review-link">

                    <span class="review-link-icon">
                        ✉
                    </span>

                    <span class="review-link-text">
                        Messages
                    </span>

                    <span class="review-notification-badge">
                        2
                    </span>

                </a>


                <a href="Contracts.aspx"
                   class="review-link">

                    <span class="review-link-icon">
                        ▧
                    </span>

                    <span>
                        Contracts
                    </span>

                </a>


                <a href="Payments.aspx"
                   class="review-link">

                    <span class="review-link-icon">
                        R
                    </span>

                    <span>
                        Payments
                    </span>

                </a>

            </div>


            <div class="review-account">

                <p>
                    ACCOUNT
                </p>


                <a href="Profile.aspx"
                   class="review-link">

                    <span class="review-link-icon">
                        ●
                    </span>

                    <span>
                        Profile
                    </span>

                </a>


                <a href="Settings.aspx"
                   class="review-link">

                    <span class="review-link-icon">
                        ⚙
                    </span>

                    <span>
                        Company Settings
                    </span>

                </a>


                <a href="Notifications.aspx"
                   class="review-link">

                    <span class="review-link-icon">
                        ◯
                    </span>

                    <span>
                        Notification Settings
                    </span>

                </a>


                <a href="HelpSupport.aspx"
                   class="review-link">

                    <span class="review-link-icon">
                        ?
                    </span>

                    <span>
                        Help &amp; Support
                    </span>

                </a>

            </div>


            <div class="review-support">

                <h4>
                    Need Help?
                </h4>

                <p>
                    Our support team is ready
                    to assist you.
                </p>

                <asp:Button
                    ID="btnSidebarSupport"
                    runat="server"
                    Text="Contact Support"
                    CssClass="review-support-button"
                    CausesValidation="false"
                    OnClick="btnSidebarSupport_Click" />

            </div>

        </aside>


        <!-- =====================================
             MAIN PAGE
        ====================================== -->

        <main class="review-main">


            <!-- BREADCRUMB -->

            <div class="review-breadcrumb">

                <a href="Dashboard.aspx">
                    Dashboard
                </a>

                <span>
                    ›
                </span>

                <a href="MyProjects.aspx">
                    My Projects
                </a>

                <span>
                    ›
                </span>

                <a href="ProjectDetails.aspx">
                    Website Development Project
                </a>

                <span>
                    ›
                </span>

                <a href="Proposals.aspx">
                    Proposals
                </a>

                <span>
                    ›
                </span>

                <strong>
                    Review Proposal
                </strong>

            </div>


            <!-- PAGE HEADING -->

            <div class="review-heading">

                <div>

                    <h1>
                        Review Proposal
                    </h1>

                    <p>
                        Review the freelancer's complete proposal
                        before making your decision.
                    </p>

                </div>


                <asp:Button
                    ID="btnBackToProposals"
                    runat="server"
                    Text="← Back to Proposals"
                    CssClass="review-back-button"
                    CausesValidation="false"
                    OnClick="btnBackToProposals_Click" />

            </div>


            <!-- INFORMATION MESSAGE -->

            <div class="review-information-banner">

                <span class="review-information-icon">
                    i
                </span>

                <p>
                    You are reviewing this proposal.
                </p>

            </div>


            <!-- PROJECT INFORMATION -->

            <section class="review-project-card">

                <div class="review-project-icon">
                    ▣
                </div>


                <div class="review-project-details">

                    <p class="review-small-heading">
                        PROJECT
                    </p>

                    <h2>
                        Website Development Project
                    </h2>

                    <p>
                        Create a modern, responsive and
                        user-friendly website for a growing
                        business.
                    </p>

                </div>


                <div class="review-project-budget">

                    <small>
                        Project Budget
                    </small>

                    <strong>
                        R8,000 – R15,000
                    </strong>

                </div>

            </section>


            <div class="review-content-layout">


                <!-- =====================================
                     LEFT CONTENT
                ====================================== -->

                <section class="review-left-content">


                    <!-- FREELANCER PROFILE -->

                    <section class="review-card">

                        <div class="review-card-title">

                            <h2>
                                Freelancer Information
                            </h2>

                            <asp:Button
                                ID="btnViewProfile"
                                runat="server"
                                Text="View Full Profile"
                                CssClass="view-profile-button"
                                CausesValidation="false"
                                OnClick="btnViewProfile_Click" />

                        </div>


                        <div class="freelancer-review-profile">

                            <div class="review-avatar">
                                TM
                            </div>


                            <div class="review-freelancer-details">

                                <div class="review-name-row">

                                    <h2>
                                        Thabo Mokoena
                                    </h2>

                                    <span>
                                        Top Rated
                                    </span>

                                </div>


                                <p class="review-rating">

                                    ★ 4.8

                                    <span>
                                        (56 Reviews)
                                    </span>

                                    • South Africa

                                </p>


                                <p class="review-title">
                                    Full-Stack Web Developer
                                </p>


                                <p class="review-experience">

                                    5+ years of experience in
                                    website design and development.

                                </p>

                            </div>

                        </div>


                        <div class="review-profile-stats">

                            <div>

                                <small>
                                    Job Success
                                </small>

                                <strong>
                                    98%
                                </strong>

                            </div>


                            <div>

                                <small>
                                    Response Time
                                </small>

                                <strong>
                                    1 hour
                                </strong>

                            </div>


                            <div>

                                <small>
                                    Jobs Completed
                                </small>

                                <strong>
                                    45+
                                </strong>

                            </div>

                        </div>


                        <div class="review-skills">

                            <h3>
                                Skills
                            </h3>

                            <span>
                                HTML
                            </span>

                            <span>
                                CSS
                            </span>

                            <span>
                                JavaScript
                            </span>

                            <span>
                                ASP.NET
                            </span>

                            <span>
                                SQL Server
                            </span>

                            <span>
                                Responsive Design
                            </span>

                        </div>

                    </section>


                    <!-- PROPOSAL DETAILS -->

                    <section class="review-card">

                        <div class="review-card-title">

                            <h2>
                                Proposal Details
                            </h2>

                            <span class="proposal-status">
                                Submitted
                            </span>

                        </div>


                        <div class="proposal-information-grid">

                            <div>

                                <small>
                                    Proposed Rate
                                </small>

                                <strong>
                                    R12,000
                                </strong>

                                <p>
                                    Fixed Price
                                </p>

                            </div>


                            <div>

                                <small>
                                    Estimated Completion
                                </small>

                                <strong>
                                    15 Days
                                </strong>

                                <p>
                                    After project approval
                                </p>

                            </div>


                            <div>

                                <small>
                                    Proposal Submitted
                                </small>

                                <strong>
                                    Today
                                </strong>

                                <p>
                                    2 hours ago
                                </p>

                            </div>

                        </div>

                    </section>


                    <!-- COVER LETTER -->

                    <section class="review-card">

                        <div class="review-card-title">

                            <h2>
                                Cover Letter
                            </h2>

                        </div>


                        <div class="cover-letter-content">

                            <p>
                                Dear Employer,
                            </p>


                            <p>
                                I am excited to submit my proposal
                                for your Website Development Project.
                                I have more than five years of
                                experience creating modern,
                                professional and responsive websites.
                            </p>


                            <p>
                                I understand that you need a website
                                that is visually attractive,
                                user-friendly and easy to use on
                                different devices. I will use modern
                                web technologies to create a clean
                                design that supports your business
                                goals.
                            </p>


                            <p>
                                The website will include responsive
                                pages, clear navigation, secure
                                functionality and a professional
                                user experience. I will also test
                                the website before final delivery.
                            </p>


                            <p>
                                I estimate that the project can be
                                completed within 15 days. I will
                                provide regular progress updates and
                                communicate with you throughout the
                                development process.
                            </p>


                            <p>
                                Thank you for considering my
                                proposal. I look forward to working
                                with you.
                            </p>


                            <p>
                                Kind regards,
                                <br />

                                <strong>
                                    Thabo Mokoena
                                </strong>

                            </p>

                        </div>

                    </section>


                    <!-- ATTACHMENTS -->

                    <section class="review-card">

                        <div class="review-card-title">

                            <h2>
                                Attachments
                            </h2>

                        </div>


                        <div class="review-attachments">

                            <a href="#"
                               class="review-attachment-item">

                                <span class="review-pdf-icon">
                                    PDF
                                </span>

                                <div>

                                    <strong>
                                        Proposal_Document.pdf
                                    </strong>

                                    <small>
                                        1.2 MB
                                    </small>

                                </div>

                            </a>


                            <a href="#"
                               class="review-attachment-item">

                                <span class="review-zip-icon">
                                    ZIP
                                </span>

                                <div>

                                    <strong>
                                        Portfolio_Examples.zip
                                    </strong>

                                    <small>
                                        4.8 MB
                                    </small>

                                </div>

                            </a>

                        </div>

                    </section>


                    <!-- PORTFOLIO -->

                    <section class="review-card">

                        <div class="review-card-title">

                            <h2>
                                Relevant Work
                            </h2>

                            <a href="Profile.aspx">
                                View Portfolio
                            </a>

                        </div>


                        <div class="review-portfolio">

                            <div class="portfolio-item">

                                <div class="portfolio-image">
                                    WEB
                                </div>

                                <h4>
                                    Business Website
                                </h4>

                                <p>
                                    Responsive company website
                                </p>

                            </div>


                            <div class="portfolio-item">

                                <div class="portfolio-image">
                                    APP
                                </div>

                                <h4>
                                    Online Booking System
                                </h4>

                                <p>
                                    Web-based booking platform
                                </p>

                            </div>


                            <div class="portfolio-item">

                                <div class="portfolio-image">
                                    SHOP
                                </div>

                                <h4>
                                    E-Commerce Website
                                </h4>

                                <p>
                                    Online shopping platform
                                </p>

                            </div>

                        </div>

                    </section>


                    <!-- DECISION ACTIONS -->

                    <section class="review-decision-card">

                        <div>

                            <h2>
                                Make a Decision
                            </h2>

                            <p>
                                Review all the information before
                                approving or rejecting this proposal.
                            </p>

                        </div>


                        <div class="review-decision-buttons">

                            <asp:Button
                                ID="btnRejectProposal"
                                runat="server"
                                Text="× Reject Proposal"
                                CssClass="reject-proposal-button"
                                OnClick="btnRejectProposal_Click" />


                            <asp:Button
                                ID="btnRequestChanges"
                                runat="server"
                                Text="▣ Request Changes"
                                CssClass="request-changes-button"
                                OnClick="btnRequestChanges_Click" />


                            <asp:Button
                                ID="btnApproveProposal"
                                runat="server"
                                Text="✓ Approve Proposal"
                                CssClass="approve-proposal-button"
                                OnClick="btnApproveProposal_Click" />

                        </div>


                        <asp:Label
                            ID="lblReviewMessage"
                            runat="server"
                            CssClass="review-message">
                        </asp:Label>

                    </section>

                </section>


                <!-- =====================================
                     RIGHT SIDE
                ====================================== -->

                <aside class="review-right-content">


                    <!-- PROJECT SUMMARY -->

                    <section class="review-summary-card">

                        <div class="review-side-card-heading">

                            <span class="review-side-icon">
                                ▣
                            </span>

                            <h3>
                                Project Summary
                            </h3>

                        </div>


                        <h4>
                            Website Development Project
                        </h4>


                        <p class="review-summary-description">

                            Create a modern and responsive
                            website for a growing business.

                        </p>


                        <div class="summary-line">

                            <span>
                                Budget
                            </span>

                            <strong>
                                R8,000 - R15,000
                            </strong>

                        </div>


                        <div class="summary-line">

                            <span>
                                Deadline
                            </span>

                            <strong>
                                30 May 2024
                            </strong>

                        </div>


                        <div class="summary-line">

                            <span>
                                Posted Date
                            </span>

                            <strong>
                                10 May 2024
                            </strong>

                        </div>


                        <a href="ProjectDetails.aspx"
                           class="review-project-details-link">

                            View Project Details

                            <span>
                                ›
                            </span>

                        </a>

                    </section>


                    <!-- PROPOSAL SUMMARY -->

                    <section class="review-summary-card">

                        <h3>
                            Proposal Summary
                        </h3>


                        <div class="summary-line">

                            <span>
                                Proposed Rate
                            </span>

                            <strong>
                                R12,000
                            </strong>

                        </div>


                        <div class="summary-line">

                            <span>
                                Completion Time
                            </span>

                            <strong>
                                15 Days
                            </strong>

                        </div>


                        <div class="summary-line">

                            <span>
                                Freelancer Rating
                            </span>

                            <strong>
                                ★ 4.8
                            </strong>

                        </div>


                        <div class="summary-line">

                            <span>
                                Reviews
                            </span>

                            <strong>
                                56
                            </strong>

                        </div>


                        <div class="summary-line">

                            <span>
                                Experience
                            </span>

                            <strong>
                                5+ Years
                            </strong>

                        </div>

                    </section>


                    <!-- WHY THIS FREELANCER -->

                    <section class="review-checklist">

                        <div class="review-side-card-heading">

                            <span class="review-star-icon">
                                ☆
                            </span>

                            <h3>
                                Why this freelancer?
                            </h3>

                        </div>


                        <p>
                            ✓ High job success rate
                        </p>

                        <p>
                            ✓ Top rated freelancer
                        </p>

                        <p>
                            ✓ Strong portfolio and work history
                        </p>

                        <p>
                            ✓ Positive reviews from clients
                        </p>

                        <p>
                            ✓ Quick response time
                        </p>

                    </section>


                    <!-- REVIEW CHECKLIST -->

                    <section class="review-checklist">

                        <h3>
                            Review Checklist
                        </h3>


                        <p>
                            ✓ Proposal meets project needs
                        </p>

                        <p>
                            ✓ Rate fits the project budget
                        </p>

                        <p>
                            ✓ Completion time is suitable
                        </p>

                        <p>
                            ✓ Skills match project requirements
                        </p>

                        <p>
                            ✓ Freelancer experience reviewed
                        </p>

                    </section>


                    <!-- HELP -->

                    <section class="review-help">

                        <h3>
                            Need Assistance?
                        </h3>

                        <p>
                            Contact our support team if you
                            need help reviewing a proposal.
                        </p>


                        <asp:Button
                            ID="btnContactSupport"
                            runat="server"
                            Text="Contact Support"
                            CssClass="review-help-button"
                            CausesValidation="false"
                            OnClick="btnContactSupport_Click" />

                    </section>

                </aside>

            </div>

        </main>

    </div>

</asp:Content>
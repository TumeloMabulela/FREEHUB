<%@ Page Title="Approve Proposal"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="ApproveProposal.aspx.cs"
    Inherits="FreeHubProject.ApproveProposal" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="approve-page">

        <!-- EMPLOYER SIDEBAR -->
        <uc:Sidebar runat="server" ID="SidebarControl" />


        <!-- MAIN CONTENT -->
        <main class="approve-main">


            <!-- BREADCRUMB -->
            <div class="approve-breadcrumb">

                Dashboard

                <span>›</span>

                My Projects

                <span>›</span>

                Review Proposal

                <span>›</span>

                <strong>Approve Proposal</strong>

            </div>


            <!-- PAGE HEADING -->
            <div class="approve-heading">

                <div>

                    <h1>Approve Proposal</h1>

                    <p>
                        Review the proposal details and
                        confirm your decision.
                    </p>

                </div>


                <asp:Button
                    ID="btnBackToReview"
                    runat="server"
                    Text="← Back to Review"
                    CssClass="approve-back-button"
                    OnClick="btnBackToReview_Click" />

            </div>


            <!-- CONFIRMATION CARD -->
            <section class="approval-confirmation-card">

                <div class="approval-icon">
                    ✓
                </div>


                <div>

                    <h2>
                        Ready to Approve This Proposal?
                    </h2>

                    <p>
                        You are about to approve this freelancer's
                        proposal and move the project forward.
                    </p>

                </div>

            </section>


            <!-- CONTENT -->
            <div class="approve-content-layout">


                <!-- LEFT SIDE -->
                <section class="approve-left-content">


                    <!-- PROJECT -->
                    <section class="approve-card">

                        <h2>
                            Project Information
                        </h2>


                        <div class="approve-project-information">

                            <div class="approve-project-icon">
                                ▣
                            </div>


                            <div>

                                <h3>
                                    Website Development Project
                                </h3>

                                <p>
                                    Create a modern, responsive
                                    and user-friendly website
                                    for a growing business.
                                </p>

                            </div>

                        </div>


                        <div class="approve-project-details">

                            <div>

                                <small>
                                    Project Budget
                                </small>

                                <strong>
                                    R8,000 – R15,000
                                </strong>

                            </div>


                            <div>

                                <small>
                                    Project Deadline
                                </small>

                                <strong>
                                    30 May 2026
                                </strong>

                            </div>


                            <div>

                                <small>
                                    Project Status
                                </small>

                                <strong class="pending-status">
                                    Pending Approval
                                </strong>

                            </div>

                        </div>

                    </section>


                    <!-- FREELANCER -->
                    <section class="approve-card">

                        <h2>
                            Selected Freelancer
                        </h2>


                        <div class="approved-freelancer">

                            <div class="approved-avatar">
                                TM
                            </div>


                            <div>

                                <div class="approved-name-row">

                                    <h3>
                                        Thabo Mokoena
                                    </h3>

                                    <span>
                                        Top Rated
                                    </span>

                                </div>


                                <p class="approved-rating">

                                    ★ 4.8

                                    <span>
                                        (56 Reviews)
                                    </span>

                                    • South Africa

                                </p>


                                <p class="approved-title">

                                    Full-Stack Web Developer
                                </p>

                            </div>

                        </div>


                        <div class="approved-skills">

                            <span>HTML</span>

                            <span>CSS</span>

                            <span>JavaScript</span>

                            <span>ASP.NET</span>

                            <span>SQL Server</span>

                        </div>

                    </section>


                    <!-- PROPOSAL -->
                    <section class="approve-card">

                        <h2>
                            Approved Proposal Details
                        </h2>


                        <div class="approved-proposal-grid">

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
                                    After approval
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


                    <!-- IMPORTANT INFORMATION -->
                    <section class="approval-information">

                        <h3>
                            What happens after approval?
                        </h3>


                        <div class="approval-step">

                            <span>1</span>

                            <p>
                                The freelancer will receive a
                                notification that their proposal
                                has been approved.
                            </p>

                        </div>


                        <div class="approval-step">

                            <span>2</span>

                            <p>
                                The project status will change
                                to <strong>In Progress</strong>.
                            </p>

                        </div>


                        <div class="approval-step">

                            <span>3</span>

                            <p>
                                You can communicate with the
                                freelancer and track project
                                progress.
                            </p>

                        </div>

                    </section>


                    <!-- FINAL ACTION -->
                    <section class="final-approval-card">

                        <h2>
                            Confirm Proposal Approval
                        </h2>

                        <p>
                            By confirming, you agree to proceed
                            with the selected freelancer based on
                            the proposal details shown above.
                        </p>


                        <div class="approval-checkbox">

                            <asp:CheckBox
                                ID="chkConfirmApproval"
                                runat="server"
                                Text="I have reviewed the proposal and confirm that I want to approve it." />

                        </div>


                        <div class="final-approval-buttons">

                            <asp:Button
                                ID="btnConfirmApproval"
                                runat="server"
                                Text="✓ Confirm and Approve"
                                CssClass="confirm-approval-button"
                                OnClick="btnConfirmApproval_Click" />


                            <asp:Button
                                ID="btnCancelApproval"
                                runat="server"
                                Text="Cancel"
                                CssClass="cancel-approval-button"
                                OnClick="btnCancelApproval_Click" />

                        </div>


                        <asp:Label
                            ID="lblApprovalMessage"
                            runat="server"
                            CssClass="approval-message">
                        </asp:Label>

                    </section>

                </section>


                <!-- RIGHT SIDE -->
                <aside class="approve-right-content">


                    <!-- SUMMARY -->
                    <section class="approval-summary">

                        <h3>
                            Approval Summary
                        </h3>


                        <div class="approval-summary-line">

                            <span>
                                Freelancer
                            </span>

                            <strong>
                                Thabo Mokoena
                            </strong>

                        </div>


                        <div class="approval-summary-line">

                            <span>
                                Proposed Rate
                            </span>

                            <strong>
                                R12,000
                            </strong>

                        </div>


                        <div class="approval-summary-line">

                            <span>
                                Completion Time
                            </span>

                            <strong>
                                15 Days
                            </strong>

                        </div>


                        <div class="approval-summary-line">

                            <span>
                                Project Status
                            </span>

                            <strong class="pending-status">
                                Pending
                            </strong>

                        </div>

                    </section>


                    <!-- REMINDER -->
                    <section class="approval-reminder">

                        <div class="reminder-icon">
                            i
                        </div>


                        <div>

                            <h3>
                                Important Reminder
                            </h3>

                            <p>
                                Make sure you have reviewed
                                the freelancer's profile,
                                proposal and proposed rate
                                before approving.
                            </p>

                        </div>

                    </section>


                    <!-- HELP -->
                    <section class="approval-help">

                        <h3>
                            Need Assistance?
                        </h3>

                        <p>
                            Contact support if you need
                            help with the approval process.
                        </p>


                        <asp:Button
                            ID="btnHelp"
                            runat="server"
                            Text="Contact Support"
                            CssClass="approval-help-button"
                            OnClick="btnHelp_Click" />

                    </section>

                </aside>

            </div>

        </main>

    </div>

</asp:Content>
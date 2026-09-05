<%@ Page Title="Reject Proposal"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="RejectProposal.aspx.cs"
    Inherits="FreeHubProject.RejectProposal" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="reject-page">

        <!-- SIDEBAR -->
        <uc:Sidebar runat="server" ID="SidebarControl" />


        <!-- MAIN CONTENT -->
        <main class="reject-main">

            <!-- BREADCRUMB -->
            <div class="reject-breadcrumb">

                Dashboard

                <span>&#8250;</span>

                My Projects

                <span>&#8250;</span>

                Review Proposal

                <span>&#8250;</span>

                <strong>Reject Proposal</strong>

            </div>


            <!-- PAGE HEADING -->
            <div class="reject-heading">

                <div>

                    <h1>Reject Proposal</h1>

                    <p>
                        Review the proposal and provide a reason
                        for rejecting it.
                    </p>

                </div>

                <asp:Button
                    ID="btnBackToReview"
                    runat="server"
                    Text="← Back to Review"
                    CssClass="reject-back-button"
                    OnClick="btnBackToReview_Click" />

            </div>


            <!-- WARNING -->
            <section class="reject-warning-card">

                <div class="reject-warning-icon">
                    !
                </div>

                <div>

                    <h2>
                        Are You Sure You Want to Reject This Proposal?
                    </h2>

                    <p>
                        The freelancer will be notified that their
                        proposal was not selected.
                    </p>

                </div>

            </section>


            <!-- PAGE CONTENT -->
            <div class="reject-content-layout">


                <!-- LEFT CONTENT -->
                <section class="reject-left-content">


                    <!-- PROPOSAL INFORMATION -->
                    <section class="reject-card">

                        <h2>
                            Proposal Information
                        </h2>

                        <div class="reject-freelancer">

                            <div class="reject-avatar">
                                TM
                            </div>

                            <div>

                                <div class="reject-name-row">

                                    <h3>
                                        Thabo Mokoena
                                    </h3>

                                    <span>
                                        Top Rated
                                    </span>

                                </div>

                                <p class="reject-rating">

                                    ★ 4.8

                                    <span>
                                        (56 Reviews)
                                    </span>

                                    • South Africa

                                </p>

                                <p class="reject-title">
                                    Full-Stack Web Developer
                                </p>

                            </div>

                        </div>


                        <div class="reject-proposal-details">

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


                    <!-- REASON -->
                    <section class="reject-card">

                        <h2>
                            Reason for Rejection
                        </h2>

                        <p class="reject-description">

                            Please select a reason for rejecting
                            this proposal. This feedback may help
                            the freelancer improve future proposals.
                        </p>


                        <div class="reject-reasons">

                            <asp:RadioButtonList
                                ID="rblRejectReason"
                                runat="server"
                                CssClass="reject-radio-list">

                                <asp:ListItem
                                    Value="Budget">
                                    The proposed rate is outside my budget.
                                </asp:ListItem>

                                <asp:ListItem
                                    Value="Experience">
                                    The freelancer does not have the required experience.
                                </asp:ListItem>

                                <asp:ListItem
                                    Value="Skills">
                                    The freelancer's skills do not match the project requirements.
                                </asp:ListItem>

                                <asp:ListItem
                                    Value="Another">
                                    I selected another freelancer.
                                </asp:ListItem>

                                <asp:ListItem
                                    Value="Other">
                                    Other reason.
                                </asp:ListItem>

                            </asp:RadioButtonList>

                        </div>


                        <div class="reject-comment-section">

                            <label>
                                Additional Comments
                                <span>(Optional)</span>
                            </label>

                            <asp:TextBox
                                ID="txtRejectComments"
                                runat="server"
                                TextMode="MultiLine"
                                Rows="5"
                                CssClass="reject-comments"
                                placeholder="Provide additional feedback or explain your decision...">
                            </asp:TextBox>

                        </div>

                    </section>


                    <!-- CONFIRMATION -->
                    <section class="reject-confirmation-card">

                        <h2>
                            Confirm Proposal Rejection
                        </h2>

                        <p>
                            By confirming, the proposal will be
                            marked as rejected and the freelancer
                            will receive a notification.
                        </p>


                        <div class="reject-checkbox">

                            <asp:CheckBox
                                ID="chkConfirmReject"
                                runat="server"
                                Text="I understand that this action will reject the freelancer's proposal." />

                        </div>


                        <div class="reject-buttons">

                            <asp:Button
                                ID="btnConfirmReject"
                                runat="server"
                                Text="Reject Proposal"
                                CssClass="confirm-reject-button"
                                OnClick="btnConfirmReject_Click" />

                            <asp:Button
                                ID="btnCancelReject"
                                runat="server"
                                Text="Cancel"
                                CssClass="cancel-reject-button"
                                OnClick="btnCancelReject_Click" />

                        </div>


                        <asp:Label
                            ID="lblRejectMessage"
                            runat="server"
                            CssClass="reject-message">
                        </asp:Label>

                    </section>

                </section>


                <!-- RIGHT CONTENT -->
                <aside class="reject-right-content">


                    <!-- SUMMARY -->
                    <section class="reject-summary">

                        <h3>
                            Proposal Summary
                        </h3>

                        <div class="reject-summary-line">

                            <span>
                                Freelancer
                            </span>

                            <strong>
                                Thabo Mokoena
                            </strong>

                        </div>

                        <div class="reject-summary-line">

                            <span>
                                Proposed Rate
                            </span>

                            <strong>
                                R12,000
                            </strong>

                        </div>

                        <div class="reject-summary-line">

                            <span>
                                Completion Time
                            </span>

                            <strong>
                                15 Days
                            </strong>

                        </div>

                        <div class="reject-summary-line">

                            <span>
                                Current Status
                            </span>

                            <strong class="submitted-status">
                                Submitted
                            </strong>

                        </div>

                    </section>


                    <!-- IMPORTANT -->
                    <section class="reject-important">

                        <div class="reject-info-icon">
                            i
                        </div>

                        <div>

                            <h3>
                                Important
                            </h3>

                            <p>
                                Rejecting this proposal will not
                                affect your project. You can still
                                review other proposals and select
                                another freelancer.
                            </p>

                        </div>

                    </section>


                    <!-- HELP -->
                    <section class="reject-help">

                        <h3>
                            Need Assistance?
                        </h3>

                        <p>
                            Contact support if you need help
                            reviewing or managing proposals.
                        </p>

                        <asp:Button
                            ID="btnHelp"
                            runat="server"
                            Text="Contact Support"
                            CssClass="reject-help-button"
                            OnClick="btnHelp_Click" />

                    </section>

                </aside>

            </div>

        </main>

    </div>

</asp:Content>
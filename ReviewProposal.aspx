<%@ Page Title="Review Proposal - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="ReviewProposal.aspx.cs"
    Inherits="FreeHubProject.ReviewProposal" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <!-- HEADER -->
            <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:20px;">
                <div>
                    <div class="post-breadcrumb">
                        Dashboard <span>/</span> Proposals <span>/</span> Review Proposal
                    </div>
                    <h1 style="color:#173f2c; margin-top:5px;">Review Proposal</h1>
                    <p style="color:#666; font-size:14px;">Review the proposal details before making your decision.</p>
                </div>
                <a href="SelectProposal.aspx" style="display:inline-block;color:#fff;background-color:#173f2c;text-decoration:none;font-size:13px;font-weight:500;padding:10px 20px;border-radius:6px;white-space:nowrap;">&#8592; Back to Proposals</a>
            </div>

            <!-- MESSAGE -->
            <asp:Panel ID="pnlMessage" runat="server" CssClass="post-status" Visible="false">
                <asp:Label ID="lblReviewMessage" runat="server" />
            </asp:Panel>

            <!-- PROPOSAL CONTENT -->
            <div style="display:grid; grid-template-columns:1fr; gap:20px;">

                <!-- FREELANCER INFO -->
                <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:25px;">
                    <h3 style="color:#173f2c; margin-bottom:15px;">Freelancer Information</h3>
                    <div style="display:flex; gap:15px; align-items:center;">
                        <div style="width:50px;height:50px;border-radius:50%;background-color:#2e7d56;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:bold;font-size:18px;">
                            <asp:Label ID="lblFreelancerInitials" runat="server" />
                        </div>
                        <div>
                            <strong style="font-size:16px; color:#173f2c;"><asp:Label ID="lblFreelancerName" runat="server" /></strong>
                            <p style="color:#666; font-size:13px;">Project: <asp:Label ID="lblProjectTitle" runat="server" /></p>
                        </div>
                    </div>
                </div>

                <!-- PROPOSAL DETAILS -->
                <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:25px;">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
                        <h3 style="color:#173f2c;">Proposal Details</h3>
                        <span style="padding:4px 12px; border-radius:12px; font-size:12px; background:#fff3cd; color:#856404;">
                            <asp:Label ID="lblStatus" runat="server" />
                        </span>
                    </div>
                    <div style="display:grid; grid-template-columns:1fr 1fr 1fr; gap:20px; margin-bottom:20px;">
                        <div>
                            <small style="color:#888;">Proposed Rate</small><br/>
                            <strong style="color:#173f2c; font-size:18px;"><asp:Label ID="lblRate" runat="server" /></strong>
                        </div>
                        <div>
                            <small style="color:#888;">Estimated Completion</small><br/>
                            <strong style="color:#173f2c; font-size:18px;"><asp:Label ID="lblTime" runat="server" /></strong>
                        </div>
                        <div>
                            <small style="color:#888;">Submitted</small><br/>
                            <strong style="color:#173f2c;"><asp:Label ID="lblDate" runat="server" /></strong>
                        </div>
                    </div>
                </div>

                <!-- COVER LETTER -->
                <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:25px;">
                    <h3 style="color:#173f2c; margin-bottom:15px;">Cover Letter</h3>
                    <p style="color:#444; font-size:14px; line-height:1.8; white-space:pre-wrap;">
                        <asp:Label ID="lblCoverLetter" runat="server" />
                    </p>
                </div>

                <!-- ACTION BUTTONS -->
                <asp:Panel ID="pnlActions" runat="server" style="display:flex; gap:15px; margin-top:10px;">
                    <asp:Button ID="btnRejectProposal" runat="server"
                        Text="X  Reject Proposal"
                        OnClick="btnRejectProposal_Click"
                        OnClientClick="return confirm('Are you sure you want to reject this proposal?');"
                        style="flex:1;background-color:#fff;color:#dc3545;border:1px solid #dc3545;padding:12px;border-radius:8px;font-size:14px;font-weight:500;cursor:pointer;" />
                    <asp:Button ID="btnBackToProposals" runat="server"
                        Text="Request Changes"
                        OnClick="btnBackToProposals_Click"
                        style="flex:1;background-color:#fff;color:#173f2c;border:1px solid #ccc;padding:12px;border-radius:8px;font-size:14px;font-weight:500;cursor:pointer;" />
                    <asp:Button ID="btnApproveProposal" runat="server"
                        Text="&#10003;  Approve Proposal"
                        OnClick="btnApproveProposal_Click"
                        OnClientClick="return confirm('Are you sure you want to approve this proposal? The project will start.');"
                        style="flex:1;background-color:#2e7d56;color:#fff;border:none;padding:12px;border-radius:8px;font-size:14px;font-weight:500;cursor:pointer;" />
                </asp:Panel>

            </div>

        </section>

    </div>

</asp:Content>

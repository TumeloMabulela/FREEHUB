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
            <div class="post-breadcrumb">
                Dashboard <span>/</span> My Projects <span>/</span> Proposals <span>/</span> Review Proposal
            </div>
            <div style="display:flex; justify-content:space-between; align-items:flex-start; margin:10px 0 20px;">
                <div>
                    <h1 style="color:#173f2c;">Review Proposal</h1>
                    <p style="color:#666; font-size:14px;">Review the proposal details before making your decision.</p>
                </div>
                <a href="SelectProposal.aspx" style="display:inline-block;color:#fff;background-color:#2e7d56;text-decoration:none;font-size:13px;font-weight:500;padding:10px 20px;border-radius:6px;">&#8592; Back to Proposals</a>
            </div>

            <!-- MESSAGE -->
            <asp:Panel ID="pnlMessage" runat="server" CssClass="post-status" Visible="false">
                <asp:Label ID="lblReviewMessage" runat="server" />
            </asp:Panel>

            <!-- MAIN LAYOUT: Content + Sidebar -->
            <div style="display:grid; grid-template-columns:1fr 300px; gap:25px;">

                <!-- LEFT CONTENT -->
                <div>

                    <!-- FREELANCER INFO BAR -->
                    <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:20px; margin-bottom:15px; display:flex; align-items:center; gap:15px;">
                        <div style="width:50px;height:50px;border-radius:50%;background-color:#2e7d56;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:bold;font-size:18px;">
                            <asp:Label ID="lblFreelancerInitials" runat="server" />
                        </div>
                        <div style="flex:1;">
                            <strong style="font-size:16px; color:#173f2c;"><asp:Label ID="lblFreelancerName" runat="server" /></strong>
                            <p style="color:#666; font-size:13px; margin-top:3px;">Project: <asp:Label ID="lblProjectTitle" runat="server" /></p>
                        </div>
                        <span style="padding:4px 12px; border-radius:12px; font-size:12px; background:#fff3cd; color:#856404;">
                            <asp:Label ID="lblStatus" runat="server" />
                        </span>
                    </div>

                    <!-- COVER LETTER -->
                    <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:25px; margin-bottom:15px;">
                        <h3 style="color:#173f2c; margin-bottom:15px;">Cover Letter</h3>
                        <p style="color:#444; font-size:14px; line-height:1.8; white-space:pre-wrap;"><asp:Label ID="lblCoverLetter" runat="server" /></p>
                    </div>

                    <!-- PROPOSAL DETAILS -->
                    <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:25px; margin-bottom:15px;">
                        <h3 style="color:#173f2c; margin-bottom:15px;">Proposal Details</h3>
                        <div style="display:grid; grid-template-columns:1fr 1fr 1fr; gap:20px;">
                            <div>
                                <small style="color:#888; font-size:11px;">Proposed Rate</small><br/>
                                <strong style="color:#173f2c; font-size:18px;"><asp:Label ID="lblRate" runat="server" /></strong><br/>
                                <small style="color:#888;">Fixed Price</small>
                            </div>
                            <div>
                                <small style="color:#888; font-size:11px;">Estimated Completion</small><br/>
                                <strong style="color:#173f2c; font-size:18px;"><asp:Label ID="lblTime" runat="server" /></strong><br/>
                                <small style="color:#888;">After project approval</small>
                            </div>
                            <div>
                                <small style="color:#888; font-size:11px;">Proposal Submitted</small><br/>
                                <strong style="color:#173f2c;"><asp:Label ID="lblDate" runat="server" /></strong>
                            </div>
                        </div>
                    </div>

                    <!-- ACTION BUTTONS -->
                    <asp:Panel ID="pnlActions" runat="server">
                        <div style="display:flex; gap:12px; background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:20px;">
                            <asp:Button ID="btnRejectProposal" runat="server"
                                Text="X  Reject Proposal"
                                OnClick="btnRejectProposal_Click"
                                OnClientClick="return confirm('Are you sure you want to reject this proposal?');"
                                style="flex:1;background-color:#fff;color:#dc3545;border:1px solid #dc3545;padding:12px;border-radius:8px;font-size:14px;font-weight:500;cursor:pointer;" />
                            <asp:Button ID="btnRequestChanges" runat="server"
                                Text="Request Changes"
                                OnClick="btnRequestChanges_Click"
                                style="flex:1;background-color:#fff;color:#173f2c;border:1px solid #ccc;padding:12px;border-radius:8px;font-size:14px;font-weight:500;cursor:pointer;" />
                            <asp:Button ID="btnApproveProposal" runat="server"
                                Text="&#10003;  Approve Proposal"
                                OnClick="btnApproveProposal_Click"
                                OnClientClick="return confirm('Are you sure you want to approve this proposal? The project will start.');"
                                style="flex:1;background-color:#2e7d56;color:#fff;border:none;padding:12px;border-radius:8px;font-size:14px;font-weight:500;cursor:pointer;" />
                        </div>
                    </asp:Panel>

                </div>

                <!-- RIGHT SIDEBAR -->
                <div>

                    <!-- PROJECT SUMMARY -->
                    <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:20px; margin-bottom:15px;">
                        <h4 style="color:#173f2c; margin-bottom:12px;">Project Summary</h4>
                        <p style="font-size:13px; color:#555; margin-bottom:10px;"><asp:Label ID="lblProjectSummary" runat="server" /></p>
                        <div style="border-top:1px solid #f0f0f0; padding-top:10px; margin-top:10px;">
                            <p style="font-size:12px; color:#888;">Budget: <strong style="color:#173f2c;"><asp:Label ID="lblProjectBudget" runat="server" /></strong></p>
                            <p style="font-size:12px; color:#888; margin-top:5px;">Deadline: <strong style="color:#173f2c;"><asp:Label ID="lblProjectDeadline" runat="server" /></strong></p>
                        </div>
                    </div>

                    <!-- NEED HELP -->
                    <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:20px;">
                        <h4 style="color:#173f2c; margin-bottom:8px;">Need Help?</h4>
                        <p style="font-size:13px; color:#666; margin-bottom:12px;">If you need assistance in choosing the right freelancer, our support team is here.</p>
                        <a href="mailto:support@freehub.co.za" style="display:inline-block;color:#2e7d56;border:1px solid #2e7d56;padding:8px 16px;border-radius:20px;font-size:12px;text-decoration:none;">Contact Support</a>
                    </div>

                </div>

            </div>

        </section>

    </div>

</asp:Content>

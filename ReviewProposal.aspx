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
                    <asp:Button ID="btnApproveProposal" runat="server"
                        Text="Approve Proposal"
                        OnClick="btnApproveProposal_Click"
                        OnClientClick="return showProposalConfirm('approve', this);"
                        style="background-color:#2e7d56;color:#fff;border:none;padding:12px 24px;border-radius:20px;font-size:14px;font-weight:500;cursor:pointer;" />
                    <asp:Button ID="btnRejectProposal" runat="server"
                        Text="Reject Proposal"
                        OnClick="btnRejectProposal_Click"
                        OnClientClick="return showProposalConfirm('reject', this);"
                        style="background-color:#dc3545;color:#fff;border:none;padding:12px 24px;border-radius:20px;font-size:14px;font-weight:500;cursor:pointer;" />
                    <asp:Button ID="btnBackToProposals" runat="server"
                        Text="Back to Proposals"
                        OnClick="btnBackToProposals_Click"
                        style="background-color:#fff;color:#173f2c;border:1px solid #ccc;padding:12px 24px;border-radius:20px;font-size:14px;cursor:pointer;" />
                </asp:Panel>

            </div>

        </section>

    </div>

    <!-- Custom Confirmation Modal -->
    <style>
        .proposal-modal-overlay {
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.45);
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .proposal-modal {
            background: white;
            border-radius: 16px;
            padding: 36px 32px 28px;
            text-align: center;
            max-width: 360px;
            width: 90%;
            box-shadow: 0 12px 40px rgba(0,0,0,0.2);
            animation: pmIn 0.2s ease;
        }

        @keyframes pmIn {
            from { transform: scale(0.9); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }

        .proposal-modal-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            font-weight: bold;
            margin: 0 auto 16px;
        }

        .proposal-modal h3 {
            font-size: 18px;
            color: #1a1a1a;
            margin-bottom: 8px;
            font-weight: 700;
        }

        .proposal-modal p {
            font-size: 13px;
            color: #5a5a5a;
            margin-bottom: 22px;
            line-height: 1.6;
        }

        .proposal-modal-btn-confirm {
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            color: white;
            transition: opacity 0.2s;
        }

        .proposal-modal-btn-confirm:hover { opacity: 0.9; }

        .proposal-modal-btn-cancel {
            background: none;
            border: none;
            color: #5a5a5a;
            font-size: 14px;
            cursor: pointer;
            margin-top: 12px;
            padding: 8px 16px;
        }

        .proposal-modal-btn-cancel:hover { color: #1a1a1a; }
    </style>

    <script type="text/javascript">
        var pendingProposalBtn = null;

        function showProposalConfirm(action, btn) {
            pendingProposalBtn = btn;

            var existing = document.getElementById('proposalConfirmModal');
            if (existing) existing.remove();

            var iconBg, iconText, title, message, btnText, btnColor;

            if (action === 'approve') {
                iconBg = '#e8f5e0';
                iconText = '&#10003;';
                title = 'Approve Proposal';
                message = 'Are you sure you want to approve this proposal?<br/>The project will start immediately.';
                btnText = 'Yes, Approve';
                btnColor = '#2e7d56';
            } else {
                iconBg = '#fee2e2';
                iconText = '&#10007;';
                title = 'Reject Proposal';
                message = 'Are you sure you want to reject this proposal?<br/>This action cannot be undone.';
                btnText = 'Yes, Reject';
                btnColor = '#dc3545';
            }

            var overlay = document.createElement('div');
            overlay.id = 'proposalConfirmModal';
            overlay.className = 'proposal-modal-overlay';
            overlay.innerHTML =
                '<div class="proposal-modal">' +
                    '<div class="proposal-modal-icon" style="background:' + iconBg + '; color:' + btnColor + ';">' + iconText + '</div>' +
                    '<h3>' + title + '</h3>' +
                    '<p>' + message + '</p>' +
                    '<button type="button" class="proposal-modal-btn-confirm" style="background:' + btnColor + ';" onclick="confirmProposalAction();">' + btnText + '</button>' +
                    '<br/><button type="button" class="proposal-modal-btn-cancel" onclick="closeProposalModal();">Cancel</button>' +
                '</div>';

            document.body.appendChild(overlay);
            overlay.onclick = function(e) { if (e.target === overlay) closeProposalModal(); };

            return false;
        }

        function confirmProposalAction() {
            closeProposalModal();
            if (pendingProposalBtn) {
                __doPostBack(pendingProposalBtn.name, '');
            }
        }

        function closeProposalModal() {
            var m = document.getElementById('proposalConfirmModal');
            if (m) m.remove();
        }
    </script>

</asp:Content>

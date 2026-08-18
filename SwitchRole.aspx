<%@ Page Title="Switch Role - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="SwitchRole.aspx.cs"
    Inherits="FreeHubProject.SwitchRole" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="SwitchRoleHead"
    ContentPlaceHolderID="HeadContent"
    runat="server">
</asp:Content>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <div class="switch-role-page">

                <h1>Switch Role</h1>
                <p class="switch-role-description">
                    You are currently acting as: 
                    <strong><asp:Label ID="lblCurrentRole" runat="server" /></strong>
                </p>

                <!-- MESSAGE -->
                <asp:Panel ID="pnlMessage" runat="server" CssClass="post-status" Visible="false">
                    <asp:Label ID="lblMessage" runat="server" />
                </asp:Panel>

                <div class="switch-role-options">

                    <!-- FREELANCER OPTION -->
                    <div class="role-card">
                        <div class="role-card-icon">&#128188;</div>
                        <h2>Freelancer</h2>
                        <p>Find work, submit proposals, and get hired for projects.</p>
                        <ul class="role-features">
                            <li>Browse and apply to projects</li>
                            <li>Submit proposals to employers</li>
                            <li>Get rated after completing work</li>
                            <li>Withdraw earnings to your bank</li>
                        </ul>
                        <asp:Button ID="btnSwitchFreelancer" runat="server"
                            Text="Switch to Freelancer"
                            CssClass="role-switch-button freelancer-button"
                            OnClientClick="return showSwitchConfirm('Freelancer', this);"
                            OnClick="btnSwitchFreelancer_Click" />
                    </div>

                    <!-- EMPLOYER OPTION -->
                    <div class="role-card">
                        <div class="role-card-icon">&#128101;</div>
                        <h2>Employer</h2>
                        <p>Post projects, hire freelancers, and manage your team.</p>
                        <ul class="role-features">
                            <li>Post projects with budgets and deadlines</li>
                            <li>Review and approve proposals</li>
                            <li>Rate freelancers after completion</li>
                            <li>Fund your wallet for payments</li>
                        </ul>
                        <asp:Button ID="btnSwitchEmployer" runat="server"
                            Text="Switch to Employer"
                            CssClass="role-switch-button employer-button"
                            OnClientClick="return showSwitchConfirm('Employer', this);"
                            OnClick="btnSwitchEmployer_Click" />
                    </div>

                </div>

                <!-- Hidden buttons for modal postbacks -->
                <asp:Button ID="btnConfirmCreateFreelancer" runat="server" OnClick="btnConfirmCreateFreelancer_Click" style="display:none;" CausesValidation="false" />
                <asp:Button ID="btnConfirmCreateEmployer" runat="server" OnClick="btnConfirmCreateEmployer_Click" style="display:none;" CausesValidation="false" />
                <asp:Button ID="btnConfirmReactivateFreelancer" runat="server" OnClick="btnConfirmReactivateFreelancer_Click" style="display:none;" CausesValidation="false" />
                <asp:Button ID="btnConfirmReactivateEmployer" runat="server" OnClick="btnConfirmReactivateEmployer_Click" style="display:none;" CausesValidation="false" />

            </div>

        </section>

    </div>

    <!-- Confirmation Modal Styles -->
    <style>
        .sr-modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.45); z-index: 9999; display: flex; align-items: center; justify-content: center; }
        .sr-modal { background: white; border-radius: 16px; padding: 36px 32px 28px; text-align: center; max-width: 380px; width: 90%; box-shadow: 0 12px 40px rgba(0,0,0,0.2); animation: srIn 0.2s ease; }
        @keyframes srIn { from { transform: scale(0.9); opacity: 0; } to { transform: scale(1); opacity: 1; } }
        .sr-modal-icon { width: 50px; height: 50px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 22px; font-weight: bold; margin: 0 auto 16px; }
        .sr-modal h3 { font-size: 18px; color: #1a1a1a; margin-bottom: 8px; font-weight: 700; }
        .sr-modal p { font-size: 13px; color: #5a5a5a; margin-bottom: 22px; line-height: 1.6; }
        .sr-btn-confirm { width: 100%; padding: 12px; border: none; border-radius: 10px; font-size: 15px; font-weight: 600; cursor: pointer; background: #173f2c; color: white; transition: background 0.2s; }
        .sr-btn-confirm:hover { background: #1f5438; }
        .sr-btn-cancel { background: none; border: none; color: #5a5a5a; font-size: 14px; cursor: pointer; margin-top: 12px; padding: 8px 16px; }
        .sr-btn-cancel:hover { color: #1a1a1a; }
    </style>

    <script type="text/javascript">
        var pendingSwitchBtn = null;

        function showSwitchConfirm(role, btn) {
            pendingSwitchBtn = btn;
            var existing = document.getElementById('srModal');
            if (existing) existing.remove();

            var overlay = document.createElement('div');
            overlay.id = 'srModal';
            overlay.className = 'sr-modal-overlay';
            overlay.innerHTML =
                '<div class="sr-modal">' +
                    '<div class="sr-modal-icon" style="background:#e8f5e0; color:#173f2c;">&#128260;</div>' +
                    '<h3>Switch Role?</h3>' +
                    '<p>Are you sure you want to switch to <strong>' + role + '</strong>?</p>' +
                    '<button type="button" class="sr-btn-confirm" onclick="confirmSwitch();">Yes, Switch</button>' +
                    '<br/><button type="button" class="sr-btn-cancel" onclick="closeSrModal();">Cancel</button>' +
                '</div>';

            document.body.appendChild(overlay);
            overlay.onclick = function(ev) { if (ev.target === overlay) closeSrModal(); };
            return false;
        }

        function confirmSwitch() {
            closeSrModal();
            if (pendingSwitchBtn) __doPostBack(pendingSwitchBtn.name, '');
        }

        function showSwitchModal(type, role) {
            var existing = document.getElementById('srModal');
            if (existing) existing.remove();

            var iconBg, iconText, title, message, btnText, btnAction;

            if (type === 'deactivated') {
                iconBg = '#fff3e0';
                iconText = '&#9888;';
                title = 'Profile Deactivated';
                message = 'Your <strong>' + role + '</strong> profile is currently deactivated.<br/>Would you like to go and reactivate it?';
                btnText = 'Yes, Reactivate';
                if (role === 'Freelancer') {
                    btnAction = "document.getElementById('<%= btnConfirmReactivateFreelancer.ClientID %>').click();";
                } else {
                    btnAction = "document.getElementById('<%= btnConfirmReactivateEmployer.ClientID %>').click();";
                }
            } else {
                iconBg = '#e0f0ff';
                iconText = '&#43;';
                title = 'Profile Not Created';
                message = 'You don\'t have a <strong>' + role + '</strong> profile yet.<br/>Would you like to create one?';
                btnText = 'Yes, Create Profile';
                if (role === 'Freelancer') {
                    btnAction = "document.getElementById('<%= btnConfirmCreateFreelancer.ClientID %>').click();";
                } else {
                    btnAction = "document.getElementById('<%= btnConfirmCreateEmployer.ClientID %>').click();";
                }
            }

            var overlay = document.createElement('div');
            overlay.id = 'srModal';
            overlay.className = 'sr-modal-overlay';
            overlay.innerHTML =
                '<div class="sr-modal">' +
                    '<div class="sr-modal-icon" style="background:' + iconBg + ';">' + iconText + '</div>' +
                    '<h3>' + title + '</h3>' +
                    '<p>' + message + '</p>' +
                    '<button type="button" class="sr-btn-confirm" onclick="' + btnAction + '">' + btnText + '</button>' +
                    '<br/><button type="button" class="sr-btn-cancel" onclick="closeSrModal();">Cancel</button>' +
                '</div>';

            document.body.appendChild(overlay);
            overlay.onclick = function(ev) { if (ev.target === overlay) closeSrModal(); };
        }

        function closeSrModal() {
            var m = document.getElementById('srModal');
            if (m) m.remove();
        }
    </script>

</asp:Content>

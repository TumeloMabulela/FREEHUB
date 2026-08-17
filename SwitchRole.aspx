<%@ Page Title="Switch Role - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="SwitchRole.aspx.cs"
    Inherits="FreeHubProject.SwitchRole" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="SwitchRoleHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .switch-container {
            max-width: 700px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .switch-container h1 {
            font-size: 26px;
            color: #173f2c;
            margin-bottom: 6px;
        }

        .switch-container > p {
            color: #5a6e5f;
            font-size: 14px;
            margin-bottom: 32px;
        }

        .current-role-card {
            background: white;
            border: 2px solid #b7d68c;
            border-radius: 14px;
            padding: 28px;
            display: flex;
            align-items: center;
            gap: 20px;
            margin-bottom: 28px;
        }

        .current-role-icon {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background: #e8f5e0;
            color: #2d6b3f;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            flex-shrink: 0;
        }

        .current-role-info h3 {
            font-size: 18px;
            color: #173f2c;
            margin-bottom: 4px;
        }

        .current-role-info p {
            color: #5a6e5f;
            font-size: 13px;
            margin: 0;
        }

        .current-badge {
            display: inline-block;
            background: #e8f5e0;
            color: #16a34a;
            padding: 3px 10px;
            border-radius: 10px;
            font-size: 11px;
            font-weight: 600;
            margin-left: 10px;
        }

        .switch-to-card {
            background: white;
            border: 2px solid #e8ece8;
            border-radius: 14px;
            padding: 28px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
        }

        .switch-to-left {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .switch-to-icon {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background: #f0f4f0;
            color: #555;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            flex-shrink: 0;
        }

        .switch-to-info h3 {
            font-size: 18px;
            color: #173f2c;
            margin-bottom: 4px;
        }

        .switch-to-info p {
            color: #5a6e5f;
            font-size: 13px;
            margin: 0;
        }

        .switch-btn {
            padding: 12px 24px;
            background: #173f2c;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            white-space: nowrap;
            transition: background 0.2s;
        }

        .switch-btn:hover { background: #1f5438; }

        /* Confirmation Modal */
        .sr-modal-overlay {
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.45);
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .sr-modal {
            background: white;
            border-radius: 16px;
            padding: 36px 32px 28px;
            text-align: center;
            max-width: 380px;
            width: 90%;
            box-shadow: 0 12px 40px rgba(0,0,0,0.2);
            animation: srModalIn 0.2s ease;
        }

        @keyframes srModalIn {
            from { transform: scale(0.9); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }

        .sr-modal-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            margin: 0 auto 16px;
        }

        .sr-modal h3 {
            font-size: 18px;
            color: #1a1a1a;
            margin-bottom: 8px;
        }

        .sr-modal p {
            font-size: 13px;
            color: #5a5a5a;
            margin-bottom: 22px;
            line-height: 1.6;
        }

        .sr-modal-actions {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .sr-btn-confirm {
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            background: #173f2c;
            color: white;
            transition: background 0.2s;
        }

        .sr-btn-confirm:hover { background: #1f5438; }

        .sr-btn-cancel {
            background: none;
            border: none;
            color: #5a5a5a;
            font-size: 14px;
            cursor: pointer;
            padding: 10px 16px;
        }

        .sr-btn-cancel:hover { color: #1a1a1a; }

        .status-deactivated { color: #c47a1a; font-weight: 600; font-size: 12px; }
        .status-not-created { color: #2563eb; font-weight: 600; font-size: 12px; }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <div class="switch-container">

                <h1>Switch Role</h1>
                <p>Manage which profile you're currently using on FreeHUB.</p>

                <!-- Current Active Profile -->
                <div class="current-role-card">
                    <div class="current-role-icon">
                        <asp:Literal ID="litCurrentIcon" runat="server" />
                    </div>
                    <div class="current-role-info">
                        <h3><asp:Literal ID="litCurrentRole" runat="server" /> <span class="current-badge">Active</span></h3>
                        <p><asp:Literal ID="litCurrentDesc" runat="server" /></p>
                    </div>
                </div>

                <!-- Switch To Other Role -->
                <div class="switch-to-card">
                    <div class="switch-to-left">
                        <div class="switch-to-icon">
                            <asp:Literal ID="litOtherIcon" runat="server" />
                        </div>
                        <div class="switch-to-info">
                            <h3><asp:Literal ID="litOtherRole" runat="server" /></h3>
                            <p>
                                <asp:Literal ID="litOtherDesc" runat="server" />
                                <asp:Literal ID="litOtherStatus" runat="server" />
                            </p>
                        </div>
                    </div>
                    <asp:Button ID="btnSwitch" runat="server" CssClass="switch-btn"
                        OnClick="btnSwitch_Click" CausesValidation="false" />
                </div>

                <!-- Hidden fields for modal postback -->
                <asp:Button ID="btnConfirmReactivate" runat="server" OnClick="btnConfirmReactivate_Click"
                    style="display:none;" CausesValidation="false" />
                <asp:Button ID="btnConfirmCreate" runat="server" OnClick="btnConfirmCreate_Click"
                    style="display:none;" CausesValidation="false" />

            </div>

        </section>

    </div>

    <script type="text/javascript">
        function showSwitchModal(type, role) {
            var existing = document.getElementById('srConfirmModal');
            if (existing) existing.remove();

            var iconBg, iconText, title, message, btnText, btnAction;

            if (type === 'deactivated') {
                iconBg = '#fff3e0';
                iconText = '&#9888;';
                title = 'Profile Deactivated';
                message = 'Your <strong>' + role + '</strong> profile is currently deactivated. Would you like to reactivate it?';
                btnText = 'Yes, Reactivate';
                btnAction = "document.getElementById('" + '<%= btnConfirmReactivate.ClientID %>' + "').click();";
            } else {
                iconBg = '#e0f0ff';
                iconText = '&#43;';
                title = 'Profile Not Created';
                message = 'You don\'t have a <strong>' + role + '</strong> profile yet. Would you like to create one?';
                btnText = 'Yes, Create Profile';
                btnAction = "document.getElementById('" + '<%= btnConfirmCreate.ClientID %>' + "').click();";
            }

            var overlay = document.createElement('div');
            overlay.id = 'srConfirmModal';
            overlay.className = 'sr-modal-overlay';
            overlay.innerHTML =
                '<div class="sr-modal">' +
                    '<div class="sr-modal-icon" style="background:' + iconBg + ';">' + iconText + '</div>' +
                    '<h3>' + title + '</h3>' +
                    '<p>' + message + '</p>' +
                    '<div class="sr-modal-actions">' +
                        '<button type="button" class="sr-btn-confirm" onclick="' + btnAction + '">' + btnText + '</button>' +
                        '<button type="button" class="sr-btn-cancel" onclick="closeSrModal();">Cancel</button>' +
                    '</div>' +
                '</div>';

            document.body.appendChild(overlay);
            overlay.onclick = function(e) { if (e.target === overlay) closeSrModal(); };
        }

        function closeSrModal() {
            var m = document.getElementById('srConfirmModal');
            if (m) m.remove();
        }
    </script>

</asp:Content>

<%@ Page Title="Notifications"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="Notifications.aspx.cs"
    Inherits="FreeHubProject.Notifications" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .nx-page { font-family: Arial, Helvetica, sans-serif; }

        /* Header */
        .nx-head { display: flex; align-items: flex-start; justify-content: space-between; gap: 16px; flex-wrap: wrap; margin-bottom: 18px; }
        .nx-head h1 { margin: 0 0 4px 0; font-size: 24px; color: #10261c; }
        .nx-head p { margin: 0; color: #6b7280; font-size: 14px; }
        .nx-markall {
            display: inline-flex; align-items: center; gap: 8px;
            background: linear-gradient(90deg, #148b97 0%, #2fa86d 50%, #72c94b 100%);
            color: #fff; border: none; border-radius: 10px;
            padding: 10px 18px; font-size: 14px; font-weight: 700; cursor: pointer;
        }
        .nx-markall:hover { opacity: .92; }
        .nx-markall:disabled { background: #d7ded9; color: #9aa6a0; cursor: not-allowed; opacity: 1; }

        /* Status alert */
        .nx-alert { background:#eaf7ed; color:#276738; border:1px solid #c7e8d0; border-radius:8px; padding:10px 14px; font-size:13px; margin-bottom:14px; }

        /* Filter bar */
        .nx-filters { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 14px; }
        .nx-search-wrap { position: relative; flex: 1; min-width: 220px; }
        .nx-search-wrap .ic { position:absolute; left:12px; top:50%; transform:translateY(-50%); color:#9aa6a0; font-size:14px; }
        .nx-search { width:100%; box-sizing:border-box; padding:10px 12px 10px 34px; border:1px solid #e2e8e4; border-radius:10px; font-size:13px; background:#fff; font-family:Arial,Helvetica,sans-serif; }
        .nx-search:focus { outline:none; border-color:#1f9d55; box-shadow:0 0 0 3px rgba(31,157,85,.12); }
        .nx-select { padding:10px 12px; border:1px solid #e2e8e4; border-radius:10px; font-size:13px; background:#fff; color:#374151; min-width:160px; font-family:Arial,Helvetica,sans-serif; }
        .nx-select:focus { outline:none; border-color:#1f9d55; }

        /* Category tabs */
        .nx-tabs { display:flex; gap:8px; overflow-x:auto; padding-bottom:4px; margin-bottom:16px; border-bottom:1px solid #eef2ef; }
        .nx-tab {
            white-space:nowrap; border:none; background:transparent; color:#5a6e62;
            padding:9px 14px; font-size:13px; font-weight:600; cursor:pointer; border-radius:8px 8px 0 0;
            border-bottom:3px solid transparent; font-family:Arial,Helvetica,sans-serif;
        }
        .nx-tab:hover { color:#12833f; }
        .nx-tab.active-tab { color:#12833f; border-bottom-color:#1f9d55; background:#f3faf5; }

        /* Notification list + cards */
        .nx-list { display:flex; flex-direction:column; gap:12px; }
        /* The card is an <a> (LinkButton). Force flex so block children inside the anchor
           never fall back to inline rendering and split the card across lines. */
        a.nx-card, .nx-card {
            position:relative; display:flex !important; align-items:flex-start; gap:14px;
            width:100%; box-sizing:border-box;
            background:#fff; border:1px solid #e7ece9; border-left:4px solid transparent;
            border-radius:12px; padding:16px; box-shadow:0 1px 3px rgba(16,40,28,.05);
            text-decoration:none; color:inherit; cursor:pointer; transition:box-shadow .15s;
        }
        .nx-card:hover { box-shadow:0 6px 16px rgba(16,40,28,.09); }
        .nx-card.unread { background:#f1faf4; border-left-color:#1f9d55; }

        .nx-ic {
            width:44px; height:44px; border-radius:12px; flex-shrink:0;
            display:flex; align-items:center; justify-content:center; font-size:20px;
        }
        .nx-ic.project { background:#e6f0ff; color:#2563eb; }
        .nx-ic.message { background:#eafaf0; color:#12833f; }
        .nx-ic.proposal { background:#f3e8ff; color:#7e22ce; }
        .nx-ic.payment { background:#fef3c7; color:#b45309; }
        .nx-ic.system { background:#eef2f5; color:#475569; }

        .nx-body { flex:1; min-width:0; }
        .nx-title-row { display:flex; align-items:center; gap:8px; }
        .nx-title { font-size:14px; color:#10261c; margin:0; }
        .nx-card.unread .nx-title { font-weight:800; }
        .nx-dot { width:8px; height:8px; border-radius:50%; background:#ef4444; flex-shrink:0; }
        .nx-desc { color:#6b7280; font-size:13px; margin:4px 0 8px 0; line-height:1.4; }
        .nx-meta { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
        .nx-badge { font-size:11px; font-weight:700; padding:2px 9px; border-radius:12px; }
        .nx-badge.project { background:#e6f0ff; color:#2563eb; }
        .nx-badge.message { background:#eafaf0; color:#12833f; }
        .nx-badge.proposal { background:#f3e8ff; color:#7e22ce; }
        .nx-badge.payment { background:#fef3c7; color:#b45309; }
        .nx-badge.system { background:#eef2f5; color:#475569; }
        .nx-time { color:#9ca3af; font-size:12px; }

        /* 3-dot menu */
        .nx-menu-wrap { position:relative; flex-shrink:0; }
        .nx-dots { background:transparent; border:none; color:#9ca3af; font-size:20px; cursor:pointer; width:32px; height:32px; border-radius:8px; line-height:1; }
        .nx-dots:hover { background:#f2f6f3; color:#4b5b51; }
        .nx-menu {
            display:none; position:absolute; right:0; top:36px; z-index:40;
            background:#fff; border:1px solid #e5e9e6; border-radius:10px;
            box-shadow:0 10px 25px rgba(16,40,28,.15); min-width:170px; overflow:hidden;
        }
        .nx-menu.open { display:block; }
        .nx-menu .nx-mi {
            display:block; width:100%; text-align:left; background:transparent; border:none;
            padding:10px 14px; font-size:13px; color:#1f2937; cursor:pointer; font-family:Arial,Helvetica,sans-serif;
            border-bottom:1px solid #f3f4f6;
        }
        .nx-menu .nx-mi:last-child { border-bottom:none; }
        .nx-menu .nx-mi:hover { background:#f4f8f5; }

        .nx-empty { text-align:center; color:#9ca3af; font-size:14px; padding:40px 10px; background:#fff; border:1px dashed #e2e8e4; border-radius:12px; }

        /* Two-container master-detail layout. The detail panel on the right is the larger,
           primary reading area; the list on the left is a compact index. */
        .nx-split { display:grid; grid-template-columns: 360px 1fr; gap:20px; align-items:start; }
        .nx-list-panel { min-width:0; }
        .nx-card.selected { border-left-color:#1f9d55; background:#eafaf0; box-shadow:0 4px 12px rgba(16,40,28,.1); }

        /* Right detail panel (big) */
        .nx-detail-panel { position:sticky; top:90px; }
        .nx-detail {
            background:#fff; border:1px solid #e7ece9; border-radius:16px;
            padding:32px 34px; box-shadow:0 4px 18px rgba(16,40,28,.07); min-height:420px;
        }
        .nx-detail-head { display:flex; align-items:flex-start; gap:16px; margin-bottom:22px; }
        .nx-detail-head .nx-ic { width:56px; height:56px; font-size:26px; border-radius:14px; }
        .nx-detail-title { margin:0 0 8px 0; color:#10261c; font-size:24px; }
        .nx-detail-meta { display:flex; align-items:center; gap:12px; flex-wrap:wrap; }
        .nx-detail-content {
            color:#374151; font-size:16px; line-height:1.75; margin:0 0 28px 0;
            padding:20px 22px; background:#f7faf8; border-radius:12px; min-height:120px;
        }
        .nx-detail-actions { display:flex; gap:12px; flex-wrap:wrap; }

        .nx-act {
            display:inline-block; text-decoration:none; cursor:pointer;
            background:#eaf6ee; color:#0f5132; border:none; border-radius:10px;
            padding:12px 22px; font-size:14px; font-weight:700; font-family:Arial,Helvetica,sans-serif;
        }
        .nx-act:hover { background:#dcefe3; }
        .nx-act-primary {
            background:linear-gradient(90deg, #148b97 0%, #2fa86d 50%, #72c94b 100%);
            color:#fff;
        }
        .nx-act-primary:hover { opacity:.92; background:linear-gradient(90deg, #148b97 0%, #2fa86d 50%, #72c94b 100%); }

        /* Empty detail placeholder (fills the big right panel) */
        .nx-detail-empty {
            background:#fff; border:1px dashed #e2e8e4; border-radius:16px;
            padding:90px 32px; text-align:center; color:#9ca3af; min-height:420px;
            display:flex; flex-direction:column; align-items:center; justify-content:center;
        }
        .nx-detail-empty-icon { font-size:52px; margin-bottom:14px; opacity:.6; }
        .nx-detail-empty h3 { margin:0 0 8px 0; color:#5a6e62; font-size:19px; }
        .nx-detail-empty p { margin:0; font-size:14px; }

        /* Stack to one column on small screens */
        @media (max-width: 1000px) {
            .nx-split { grid-template-columns: 1fr; }
            .nx-detail-panel { position:static; }
        }

        @media (max-width: 720px) {
            .nx-head { flex-direction:column; }
            .nx-select { flex:1; min-width:120px; }
        }
    </style>

    <script type="text/javascript">
        // Toggle a card's 3-dot menu; close others. Prevent the card navigation.
        function nxToggleMenu(ev, id) {
            ev.preventDefault();
            ev.stopPropagation();
            var all = document.querySelectorAll('.nx-menu');
            for (var i = 0; i < all.length; i++) {
                if (all[i].id !== id) all[i].classList.remove('open');
            }
            var m = document.getElementById(id);
            if (m) m.classList.toggle('open');
            return false;
        }
        // Stop clicks inside the menu from bubbling to the card link.
        function nxMenuClick(ev) { ev.stopPropagation(); }
        // Close menus when clicking elsewhere.
        document.addEventListener('click', function () {
            var all = document.querySelectorAll('.nx-menu.open');
            for (var i = 0; i < all.length; i++) all[i].classList.remove('open');
        });

        // Debounced live search: auto-submit the search field after a pause.
        var nxSearchTimer = null;
        function nxSearchDebounce(btnId) {
            if (nxSearchTimer) clearTimeout(nxSearchTimer);
            nxSearchTimer = setTimeout(function () {
                var b = document.getElementById(btnId);
                if (b) b.click();
            }, 450);
        }
    </script>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="freehub-dashboard-layout">
        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">
            <div class="notifications-page nx-page">

                <div class="notification-breadcrumb" style="margin-bottom:12px;">
                    <a href="<%= ResolveUrl("~/Dashboard.aspx") %>" class="breadcrumb-link">Dashboard</a> <span>›</span>
                    <strong>Notifications</strong>
                </div>

                <!-- Header -->
                <div class="nx-head">
                    <div>
                        <h1>Notifications</h1>
                        <p>Stay updated with the latest activity on your account.</p>
                    </div>
                    <asp:Button ID="btnMarkAllRead" runat="server" CssClass="nx-markall" Text="✓ Mark All as Read" OnClick="btnMarkAllRead_Click" CausesValidation="false" />
                </div>

                <!-- Status alert -->
                <asp:Panel ID="pnlNotificationStatus" runat="server" CssClass="nx-alert" Visible="false">
                    <asp:Label ID="lblNotificationStatus" runat="server"></asp:Label>
                </asp:Panel>

                <!-- Search + filters -->
                <div class="nx-filters">
                    <div class="nx-search-wrap">
                        <span class="ic">🔍</span>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="nx-search" placeholder="Search notifications..."
                            AutoPostBack="true" OnTextChanged="Filters_Changed"
                            onkeyup="nxSearchDebounce('<%= btnDoSearch.ClientID %>');"></asp:TextBox>
                        <asp:Button ID="btnDoSearch" runat="server" OnClick="Filters_Changed" style="display:none;" CausesValidation="false" />
                    </div>
                    <asp:DropDownList ID="ddlType" runat="server" CssClass="nx-select" AutoPostBack="true" OnSelectedIndexChanged="Filters_Changed">
                        <asp:ListItem Text="All Types" Value="All" />
                        <asp:ListItem Text="Project Updates" Value="Project" />
                        <asp:ListItem Text="Messages" Value="Message" />
                        <asp:ListItem Text="Proposals" Value="Proposal" />
                        <asp:ListItem Text="Payments" Value="Payment" />
                        <asp:ListItem Text="System Notifications" Value="System" />
                    </asp:DropDownList>
                    <asp:DropDownList ID="ddlTime" runat="server" CssClass="nx-select" AutoPostBack="true" OnSelectedIndexChanged="Filters_Changed">
                        <asp:ListItem Text="All Time" Value="0" />
                        <asp:ListItem Text="Today" Value="1" />
                        <asp:ListItem Text="Last 7 Days" Value="7" />
                        <asp:ListItem Text="Last 30 Days" Value="30" />
                        <asp:ListItem Text="Last 90 Days" Value="90" />
                    </asp:DropDownList>
                </div>

                <!-- Category tabs -->
                <div class="nx-tabs">
                    <asp:Button ID="btnAll" runat="server" Text="All" CssClass="nx-tab" OnClick="btnAll_Click" CausesValidation="false" />
                    <asp:Button ID="btnUnread" runat="server" Text="Unread" CssClass="nx-tab" OnClick="btnUnread_Click" CausesValidation="false" />
                    <asp:Button ID="btnProjects" runat="server" Text="Projects" CssClass="nx-tab" OnClick="btnProjects_Click" CausesValidation="false" />
                    <asp:Button ID="btnMessages" runat="server" Text="Messages" CssClass="nx-tab" OnClick="btnMessages_Click" CausesValidation="false" />
                    <asp:Button ID="btnSystem" runat="server" Text="System" CssClass="nx-tab" OnClick="btnSystem_Click" CausesValidation="false" />
                    <asp:Button ID="btnPayments" runat="server" Text="Payments" CssClass="nx-tab" OnClick="btnPayments_Click" CausesValidation="false" />
                    <asp:Button ID="btnArchived" runat="server" Text="Archived" CssClass="nx-tab" OnClick="btnArchived_Click" CausesValidation="false" />
                </div>

                <!-- TWO-CONTAINER LAYOUT: list (left) + selected detail (right) -->
                <div class="nx-split">

                    <!-- LEFT: notification list -->
                    <div class="nx-list-panel">
                        <div class="nx-list">
                            <asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server"
                                        CssClass='<%# "nx-card" + (Eval("Status").ToString() == "Unread" ? " unread" : "") + (Convert.ToInt32(Eval("Id")) == SelectedNotificationId ? " selected" : "") %>'
                                        CommandName="SelectNotification" CommandArgument='<%# Eval("Id") %>'>
                                        <span class='<%# "nx-ic " + Eval("IconClass") %>'><%# Eval("Icon") %></span>
                                        <div class="nx-body">
                                            <div class="nx-title-row">
                                                <h4 class="nx-title"><%# Eval("Title") %></h4>
                                                <asp:PlaceHolder runat="server" Visible='<%# Eval("Status").ToString() == "Unread" %>'>
                                                    <span class="nx-dot" title="Unread"></span>
                                                </asp:PlaceHolder>
                                            </div>
                                            <div class="nx-desc"><%# Eval("Description") %></div>
                                            <div class="nx-meta">
                                                <span class='<%# "nx-badge " + Eval("IconClass") %>'><%# Eval("Category") %></span>
                                                <span class="nx-time"><%# Eval("Time") %></span>
                                            </div>
                                        </div>
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:Repeater>

                            <asp:Label ID="lblNoNotifications" runat="server" CssClass="nx-empty" Visible="false" Text="No notifications match your filters."></asp:Label>
                        </div>
                    </div>

                    <!-- RIGHT: selected notification detail -->
                    <div class="nx-detail-panel">
                        <asp:Panel ID="pnlDetail" runat="server" Visible="false" CssClass="nx-detail">
                            <div class="nx-detail-head">
                                <span class='<%= "nx-ic " + DetailIconClass %>'><asp:Label ID="lblSelectedIcon" runat="server"></asp:Label></span>
                                <div>
                                    <h3 class="nx-detail-title"><asp:Label ID="lblSelectedTitle" runat="server"></asp:Label></h3>
                                    <div class="nx-detail-meta">
                                        <span class='<%= "nx-badge " + DetailIconClass %>'><asp:Label ID="lblSelectedCategory" runat="server"></asp:Label></span>
                                        <span class="nx-time"><asp:Label ID="lblSelectedTime" runat="server"></asp:Label></span>
                                    </div>
                                </div>
                            </div>

                            <p class="nx-detail-content"><asp:Label ID="lblSelectedPreview" runat="server"></asp:Label></p>

                            <div class="nx-detail-actions">
                                <asp:Button ID="btnOpenTarget" runat="server" Text="View Details" CssClass="nx-act nx-act-primary" OnClick="btnOpenTarget_Click" CausesValidation="false" Visible="false" />
                                <asp:Button ID="btnToggleRead" runat="server" Text="Mark as Read" CssClass="nx-act" OnClick="btnToggleRead_Click" CausesValidation="false" />
                                <asp:Button ID="btnToggleArchive" runat="server" Text="Archive" CssClass="nx-act" OnClick="btnToggleArchive_Click" CausesValidation="false" />
                            </div>

                            <!-- kept for compatibility with existing code paths -->
                            <asp:Label ID="lblReadStatus" runat="server" Visible="false"></asp:Label>
                            <asp:Button ID="btnViewMessage" runat="server" OnClick="btnViewMessage_Click" style="display:none;" CausesValidation="false" />
                            <asp:Button ID="btnViewProject" runat="server" OnClick="btnViewProject_Click" style="display:none;" CausesValidation="false" />
                            <asp:Button ID="btnCloseDetails" runat="server" OnClick="btnCloseDetails_Click" style="display:none;" CausesValidation="false" />
                        </asp:Panel>

                        <asp:Panel ID="pnlNoSelection" runat="server" CssClass="nx-detail-empty">
                            <div class="nx-detail-empty-icon">🔔</div>
                            <h3>No notification selected</h3>
                            <p>Select a notification from the list to read it and take action.</p>
                        </asp:Panel>
                    </div>

                </div>

            </div>
        </section>
    </div>

</asp:Content>

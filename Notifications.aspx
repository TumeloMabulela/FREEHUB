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

        /* ===== Fixed-middle layout (scoped to Notifications via .nx-main). The main
           content is a NON-scrolling flex column filling the space between the fixed site
           header and footer; the top section (breadcrumb, heading, Mark All as Read,
           status alert, category tabs) stays stationary; and only the notification list
           body (and the detail panel's own content, if it overflows) scrolls. ===== */
        .freehub-main-content.nx-main {
            height: 100%; min-height: 0; display: flex; flex-direction: column; overflow: hidden;
            /* Trim the bottom padding (the shared .freehub-main-content sets 30px) so the
               list/split meets the top of the fixed footer with no external gap. Top and
               side padding are kept so the heading's position + alignment are unchanged. */
            padding-bottom: 0;
        }
        .nx-main .notifications-page {
            flex: 1 1 auto; min-height: 0; display: flex; flex-direction: column;
        }
        /* Stationary top section (everything above the master-detail split). */
        .nx-main .notification-breadcrumb,
        .nx-main .nx-head,
        .nx-main .nx-alert,
        .nx-main .nx-tabs { flex: 0 0 auto; }

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

        /* Notification list + cards (compact: fixed, consistent height) */
        .nx-list { display:flex; flex-direction:column; gap:8px; }
        /* The card is a DIV, so block children are always valid and never split it.
           A stretched LinkButton (.nx-card-link) overlays the card to make it clickable. */
        .nx-card {
            position:relative; display:flex; align-items:center; gap:12px;
            width:100%; box-sizing:border-box;
            background:#fff; border:1px solid #e7ece9; border-left:4px solid transparent;
            border-radius:10px; padding:12px 14px; box-shadow:0 1px 3px rgba(16,40,28,.05);
            color:inherit; cursor:pointer; transition:box-shadow .15s;
        }
        .nx-card:hover { box-shadow:0 6px 16px rgba(16,40,28,.09); }
        .nx-card.unread { background:#f1faf4; border-left-color:#1f9d55; }

        /* Full-card clickable overlay. Covers the whole card so a click anywhere opens
           it in the right panel; the inner content sits above it only for text selection. */
        .nx-card-link {
            position:absolute; inset:0; z-index:1;
            display:block; border-radius:10px; text-decoration:none; font-size:0; line-height:0;
        }
        .nx-card-link:focus-visible { outline:2px solid #2fa86d; outline-offset:-2px; }
        .nx-card .nx-ic, .nx-card .nx-body { position:relative; z-index:0; pointer-events:none; }

        .nx-ic {
            width:38px; height:38px; border-radius:10px; flex-shrink:0;
            display:flex; align-items:center; justify-content:center; font-size:17px;
        }
        .nx-ic.project { background:#e6f0ff; color:#2563eb; }
        .nx-ic.message { background:#eafaf0; color:#12833f; }
        .nx-ic.proposal { background:#f3e8ff; color:#7e22ce; }
        .nx-ic.payment { background:#fef3c7; color:#b45309; }
        .nx-ic.system { background:#eef2f5; color:#475569; }

        .nx-body { flex:1; min-width:0; }
        .nx-title-row { display:flex; align-items:center; gap:8px; }
        .nx-title {
            font-size:14px; color:#10261c; margin:0;
            white-space:nowrap; overflow:hidden; text-overflow:ellipsis; min-width:0;
        }
        .nx-card.unread .nx-title { font-weight:800; }
        .nx-dot { width:8px; height:8px; border-radius:50%; background:#ef4444; flex-shrink:0; }
        /* Single-line preview, truncated with an ellipsis (…) so cards stay a consistent
           compact height. The full message is shown in the right-hand detail panel. */
        .nx-desc {
            color:#6b7280; font-size:12.5px; margin:2px 0 6px 0; line-height:1.35;
            white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
        }
        .nx-meta { display:flex; align-items:center; gap:10px; flex-wrap:nowrap; }
        .nx-badge { font-size:11px; font-weight:700; padding:2px 9px; border-radius:12px; }
        .nx-badge.project { background:#e6f0ff; color:#2563eb; }
        .nx-badge.message { background:#eafaf0; color:#12833f; }
        .nx-badge.proposal { background:#f3e8ff; color:#7e22ce; }
        .nx-badge.payment { background:#fef3c7; color:#b45309; }
        .nx-badge.system { background:#eef2f5; color:#475569; }
        .nx-time { color:#9ca3af; font-size:11.5px; white-space:nowrap; }
        /* Keep the badge from shrinking so the meta row stays single-line and tidy. */
        .nx-meta .nx-badge { flex-shrink:0; }

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

        /* Keep the whole page inside the viewport width (no horizontal scroll on any size). */
        .nx-page { max-width:100%; }
        .nx-page * { box-sizing:border-box; }

        /* Two-container master-detail layout. Both panels share one fluid height that fits
           the viewport, so the page itself never grows with the number of notifications.
           The list column is fluid (clamp) so it adapts smoothly instead of a fixed width. */
        .nx-split {
            display:grid;
            grid-template-columns: clamp(300px, 32%, 400px) minmax(0, 1fr);
            gap:20px; width:100%;
            /* Shared container height: viewport minus the fixed header, the fixed
               footer, and the heading + tabs above it. The search/type/time filter row
               was removed, so the panels reclaim that height (~64px) and sit higher.
               dvh tracks mobile browser chrome; vh is the fallback for older browsers. */
            height: calc(100vh - 346px);
            height: calc(100dvh - 346px);
            min-height: 420px;
            max-height: calc(100vh - 226px);
        }
        /* Each column is a full-height flex container; min-height:0 lets the inner
           scroll area shrink and scroll instead of pushing the page taller. */
        /* Within the fixed-middle shell, the split fills the remaining height via flex
           instead of a viewport calc, so it always sits just below the static tabs and
           above the footer regardless of header/tab heights. */
        .nx-main .nx-split {
            height: auto; min-height: 0; max-height: none;
            flex: 1 1 auto;
        }

        .nx-list-panel { min-width:0; min-height:0; height:100%; display:flex; flex-direction:column; }
        .nx-card.selected { border-left-color:#1f9d55; background:#eafaf0; box-shadow:0 4px 12px rgba(16,40,28,.1); }

        /* LEFT: the list is the scroll area. The header/filters stay outside this. */
        .nx-list-panel .nx-list {
            flex:1 1 auto; min-height:0; overflow-y:auto; overflow-x:hidden;
            /* Right padding keeps cards off the scrollbar; bottom padding keeps the final
               card fully readable now that the list extends to the footer. */
            padding:2px 8px 14px 2px;
        }

        /* RIGHT: panel fills the shared height and scrolls its own content independently. */
        .nx-detail-panel {
            height:100%; min-height:0; display:flex; flex-direction:column;
        }
        /* The detail panel fills the shared height and is a NON-scrolling flex column:
           head (fixed) + body (fills) + actions (fixed bottom). No internal scrollbar. */
        .nx-detail {
            flex:1 1 auto; min-height:0; overflow:hidden;
            display:flex; flex-direction:column;
            background:#fff; border:1px solid #e7ece9; border-radius:16px;
            padding:26px 30px 22px; box-shadow:0 4px 18px rgba(16,40,28,.07);
        }
        .nx-detail-head { flex:0 0 auto; display:flex; align-items:flex-start; gap:16px; margin-bottom:16px; }
        .nx-detail-head .nx-ic { width:52px; height:52px; font-size:24px; border-radius:14px; }
        .nx-detail-title { margin:0 0 6px 0; color:#10261c; font-size:22px; }
        .nx-detail-meta { display:flex; align-items:center; gap:12px; flex-wrap:wrap; }

        /* Body fills the space between head and actions; min-height:0 so it can shrink. */
        .nx-detail-body { flex:1 1 auto; min-height:0; display:flex; flex-direction:column; }
        .nx-detail-content {
            color:#374151; font-size:15.5px; line-height:1.7; margin:0;
            padding:18px 20px; background:#f7faf8; border-radius:12px;
            /* Message wraps naturally and is clamped so it never forces the panel to
               scroll; longer text is opened via "View Full Message". */
            overflow:hidden; overflow-wrap:anywhere; white-space:pre-line;
            display:-webkit-box; -webkit-box-orient:vertical; -webkit-line-clamp:8;
        }
        .nx-viewfull-wrap { flex:0 0 auto; margin-top:10px; }
        .nx-viewfull {
            background:transparent; border:none; cursor:pointer; padding:0;
            color:#0f7a44; font-size:13.5px; font-weight:700; font-family:Arial,Helvetica,sans-serif;
            text-decoration:underline;
        }
        .nx-viewfull:hover { color:#0c6639; }

        /* Actions pinned to the bottom of the panel, always visible. */
        .nx-detail-actions { flex:0 0 auto; display:flex; gap:12px; flex-wrap:wrap; margin-top:16px; padding-top:14px; border-top:1px solid #f0f3f1; }

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

        /* Empty detail placeholder (fills the full shared panel height) */
        .nx-detail-empty {
            flex:1 1 auto; min-height:0;
            background:#fff; border:1px dashed #e2e8e4; border-radius:16px;
            padding:40px 32px; text-align:center; color:#9ca3af;
            display:flex; flex-direction:column; align-items:center; justify-content:center;
        }
        .nx-detail-empty-icon { font-size:52px; margin-bottom:14px; opacity:.6; }
        .nx-detail-empty h3 { margin:0 0 8px 0; color:#5a6e62; font-size:19px; }
        .nx-detail-empty p { margin:0; font-size:14px; }

        /* Thin, modern scrollbar in FreeHUB's green/white theme (left list + right detail). */
        .nx-list-panel .nx-list,
        .nx-detail { scrollbar-width: thin; scrollbar-color: #72c94b #eef3ef; }
        .nx-list-panel .nx-list::-webkit-scrollbar,
        .nx-detail::-webkit-scrollbar { width: 8px; }
        .nx-list-panel .nx-list::-webkit-scrollbar-track,
        .nx-detail::-webkit-scrollbar-track { background: #eef3ef; border-radius: 8px; }
        .nx-list-panel .nx-list::-webkit-scrollbar-thumb,
        .nx-detail::-webkit-scrollbar-thumb {
            background: linear-gradient(180deg, #2fa86d, #72c94b);
            border-radius: 8px; border: 2px solid #eef3ef;
        }
        .nx-list-panel .nx-list::-webkit-scrollbar-thumb:hover,
        .nx-detail::-webkit-scrollbar-thumb:hover { background: #2fa86d; }

        /* ============================================================
           RESPONSIVE: auto-adjust across screen sizes
           ============================================================ */

        /* Short viewports (small laptops): reclaim height so the panels still fit. */
        @media (max-height: 820px) {
            .nx-split { height: calc(100vh - 240px); height: calc(100dvh - 240px); }
        }
        /* Tall viewports (large monitors): a little more breathing room above/below. */
        @media (min-height: 1000px) {
            .nx-split { height: calc(100vh - 320px); height: calc(100dvh - 320px); }
        }

        /* Large desktops: cap the reading column so lines don't stretch too wide. */
        @media (min-width: 1600px) {
            .nx-split { grid-template-columns: 400px minmax(0, 1100px); justify-content:center; }
        }

        /* Narrow desktops / small laptops: tighten the gap and list width. */
        @media (max-width: 1200px) {
            .nx-split { gap:16px; grid-template-columns: clamp(280px, 30%, 340px) minmax(0, 1fr); }
            .nx-detail { padding:26px 24px; }
            .nx-detail-title { font-size:21px; }
        }

        /* Tablets & phones: stack to one column. Let the page flow naturally so the
           list isn't crammed into a tiny scroll box; cap list height so the detail
           panel is still reachable without endless scrolling. */
        @media (max-width: 1000px) {
            /* Release the fixed-middle shell so the whole page flows and scrolls naturally
               when the layout stacks into one column. */
            .freehub-main-content.nx-main { height:auto; overflow:visible; display:block; }
            .nx-main .notifications-page { display:block; flex:none; min-height:0; }
            .nx-main .nx-split { flex:none; }
            .nx-split {
                grid-template-columns: 1fr; height:auto; min-height:0; max-height:none; gap:14px;
            }
            .nx-list-panel { height:auto; display:block; }
            .nx-list-panel .nx-list {
                max-height:55vh; max-height:55dvh; overflow-y:auto;
            }
            .nx-detail-panel { height:auto; display:block; }
            .nx-detail, .nx-detail-empty { overflow:visible; min-height:0; }
            .nx-detail { padding:24px 22px; }
        }

        /* Small tablets / large phones. */
        @media (max-width: 720px) {
            .nx-head { flex-direction:column; }
            .nx-head h1 { font-size:21px; }
            .nx-filters { gap:8px; }
            .nx-select { flex:1 1 140px; min-width:0; }
            .nx-list-panel .nx-list { max-height:50vh; max-height:50dvh; }
            .nx-detail { padding:20px 18px; }
            .nx-detail-title { font-size:19px; }
            .nx-detail-content { font-size:15px; padding:16px 18px; }
            .nx-detail-head .nx-ic { width:48px; height:48px; font-size:22px; }
        }

        /* Phones: compact everything, full-width action buttons for easy tapping. */
        @media (max-width: 480px) {
            .nx-head h1 { font-size:19px; }
            .nx-markall { width:100%; justify-content:center; }
            .nx-search-wrap { min-width:0; flex:1 1 100%; }
            .nx-select { flex:1 1 100%; }
            .nx-card { padding:10px 12px; gap:10px; }
            .nx-ic { width:34px; height:34px; font-size:15px; }
            .nx-detail-actions { flex-direction:column; }
            .nx-detail-actions .nx-act { width:100%; text-align:center; }
            .nx-detail-head { gap:12px; margin-bottom:16px; }
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

        // Open the full notification message in a centred dialog (reuses the shared
        // .fh-modal design) so the details panel itself never needs to scroll. Esc/overlay
        // click or the Close button dismisses it; focus returns naturally.
        function nxShowFullMessage() {
            var src = document.getElementById('nxFullMessage');
            var titleEl = document.getElementById('nxFullTitle');
            var msg = src ? src.innerText : '';
            var title = titleEl && titleEl.innerText ? titleEl.innerText : 'Notification';

            var existing = document.getElementById('nxFullModal');
            if (existing) existing.remove();

            var overlay = document.createElement('div');
            overlay.id = 'nxFullModal';
            overlay.className = 'fh-modal-overlay';
            overlay.setAttribute('role', 'dialog');
            overlay.setAttribute('aria-modal', 'true');

            var box = document.createElement('div');
            box.className = 'fh-modal';
            box.style.maxWidth = '560px';
            box.style.textAlign = 'left';

            var h = document.createElement('h3');
            h.style.textAlign = 'left';
            h.textContent = title;

            var body = document.createElement('div');
            body.style.cssText = 'max-height:60vh; overflow-y:auto; white-space:pre-line; overflow-wrap:anywhere; color:#374151; font-size:14.5px; line-height:1.7; margin:8px 0 18px; text-align:left;';
            body.textContent = msg;   // textContent = safe (no HTML injection)

            var btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'fh-modal-btn-primary';
            btn.style.background = '#2e7d56';
            btn.textContent = 'Close';
            btn.onclick = function () { overlay.remove(); };

            box.appendChild(h); box.appendChild(body); box.appendChild(btn);
            overlay.appendChild(box);
            overlay.onclick = function (e) { if (e.target === overlay) overlay.remove(); };
            document.addEventListener('keydown', function esc(ev) {
                if ((ev.key === 'Escape' || ev.keyCode === 27)) { overlay.remove(); document.removeEventListener('keydown', esc); }
            });
            document.body.appendChild(overlay);
            btn.focus();
        }
    </script>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="freehub-dashboard-layout">
        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content nx-main">
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

                <!-- (Inline status banner removed — all notification action results now use
                     the centred global popup via MessageHelper, so there is no inline banner
                     or reserved spacing on the page.) -->

                <!-- (Search + type/time filter controls removed — the category tabs
                     below now sit directly under the heading and the panels expand up.) -->

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
                                    <%-- The card is a DIV (not an anchor). An anchor cannot legally wrap
                                         block-level content, and any HTML in the message body would close
                                         it early and split the card. The whole card is made clickable by a
                                         single stretched LinkButton (.nx-card-link) overlaid on top. --%>
                                    <div class='<%# "nx-card" + (Eval("Status").ToString() == "Unread" ? " unread" : "") + (Convert.ToInt32(Eval("Id")) == SelectedNotificationId ? " selected" : "") %>'>
                                        <span class='<%# "nx-ic " + Eval("IconClass") %>'><%# Server.HtmlEncode(Convert.ToString(Eval("Icon"))) %></span>
                                        <div class="nx-body">
                                            <div class="nx-title-row">
                                                <h4 class="nx-title"><%# Server.HtmlEncode(Convert.ToString(Eval("Title"))) %></h4>
                                                <asp:PlaceHolder runat="server" Visible='<%# Eval("Status").ToString() == "Unread" %>'>
                                                    <span class="nx-dot" title="Unread"></span>
                                                </asp:PlaceHolder>
                                            </div>
                                            <div class="nx-desc"><%# Server.HtmlEncode(Convert.ToString(Eval("Description"))) %></div>
                                            <div class="nx-meta">
                                                <span class='<%# "nx-badge " + Eval("IconClass") %>'><%# Server.HtmlEncode(Convert.ToString(Eval("Category"))) %></span>
                                                <span class="nx-time"><%# Server.HtmlEncode(Convert.ToString(Eval("Time"))) %></span>
                                            </div>
                                        </div>
                                        <asp:LinkButton runat="server" CssClass="nx-card-link"
                                            CommandName="SelectNotification" CommandArgument='<%# Eval("Id") %>'
                                            CausesValidation="false" ToolTip="Open notification"></asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>

                            <asp:Label ID="lblNoNotifications" runat="server" CssClass="nx-empty" Visible="false" Text="No notifications match your filters."></asp:Label>
                        </div>
                    </div>

                    <!-- RIGHT: selected notification detail -->
                    <div class="nx-detail-panel">
                        <asp:Panel ID="pnlDetail" runat="server" Visible="false" CssClass="nx-detail">
                            <!-- HEAD (stationary) -->
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

                            <!-- BODY (fills remaining height; message wraps and is clamped so the
                                 panel never scrolls — the full text opens in a dialog). -->
                            <div class="nx-detail-body">
                                <p class="nx-detail-content"><asp:Label ID="lblSelectedPreview" runat="server"></asp:Label></p>
                                <asp:Panel ID="pnlViewFull" runat="server" Visible="false" CssClass="nx-viewfull-wrap">
                                    <button type="button" class="nx-viewfull" onclick="nxShowFullMessage(); return false;">View Full Message</button>
                                </asp:Panel>
                            </div>

                            <!-- ACTIONS (stationary bottom section) -->
                            <div class="nx-detail-actions">
                                <asp:Button ID="btnOpenTarget" runat="server" Text="View Details" CssClass="nx-act nx-act-primary" OnClick="btnOpenTarget_Click" CausesValidation="false" Visible="false" />
                                <asp:Button ID="btnToggleRead" runat="server" Text="Mark as Read" CssClass="nx-act" OnClick="btnToggleRead_Click" CausesValidation="false" />
                                <asp:Button ID="btnToggleArchive" runat="server" Text="Archive" CssClass="nx-act" OnClick="btnToggleArchive_Click" CausesValidation="false" />
                            </div>

                            <!-- Full message text (hidden; copied into the dialog by nxShowFullMessage). -->
                            <span id="nxFullMessage" style="display:none;"><asp:Literal ID="litFullMessage" runat="server" /></span>
                            <span id="nxFullTitle" style="display:none;"><asp:Label ID="lblFullTitle" runat="server"></asp:Label></span>

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

<%@ Page Title="Messages"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="StartChat.aspx.cs"
    Inherits="FreeHubProject.StartChat" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* ===== Viewport lock: only inner regions scroll while on Messages ===== */
        body.messages-page,
        html:has(body.messages-page) {
            height: 100%;
            overflow: hidden;
        }

        .msgx-wrap {
            font-family: 'Segoe UI', system-ui, -apple-system, Arial, sans-serif;
            display: grid;
            grid-template-columns: 340px 1fr;
            gap: 0;
            height: calc(100vh - 150px);
            min-height: 480px;
            background: #ffffff;
            border-radius: 18px;
            border: 1px solid #eef2ef;
            box-shadow: 0 12px 30px rgba(16, 40, 28, 0.08);
            overflow: hidden;
            position: relative;
        }

        /* Success Alert */
        .chat-alert-success {
            background-color: #eaf7ed;
            color: #276738;
            padding: 10px 16px;
            border-radius: 8px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 12px;
            border: 1px solid #c7e8d0;
        }

        /* ===== LEFT: conversation / contact panel ===== */
        .conversation-panel {
            border-right: 1px solid #eef2ef;
            background: #fbfdfc;
            display: flex;
            flex-direction: column;
            min-height: 0;
        }

        .conversation-head {
            padding: 18px 16px 10px 16px;
        }

        .conversation-title {
            font-size: 19px;
            font-weight: 800;
            color: #10261c;
            margin: 0;
        }

        .conversation-subtitle {
            font-size: 12px;
            color: #8b9a90;
            margin: 2px 0 12px 0;
        }

        .chat-search-row {
            display: flex;
            gap: 8px;
            margin-bottom: 12px;
        }

        .chat-search-input {
            flex: 1;
            padding: 11px 16px;
            border: 1px solid #e6ece8;
            border-radius: 24px;
            font-size: 13px;
            background: #ffffff;
        }

        .chat-search-input:focus {
            outline: none;
            border-color: #1f9d55;
            box-shadow: 0 0 0 3px rgba(31, 157, 85, 0.12);
        }

        .chat-search-btn {
            background: linear-gradient(135deg, #1f9d55, #12833f);
            color: #fff;
            border: none;
            border-radius: 24px;
            padding: 8px 16px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
        }

        /* Filter tabs */
        .msgx-filters {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
        }

        .msgx-filter {
            border: 1px solid #e6ece8;
            background: #fff;
            color: #4b5b51;
            border-radius: 20px;
            padding: 5px 12px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .msgx-filter.active {
            background: #eafaf0;
            color: #12833f;
            border-color: #bfe8cd;
        }

        .msgx-filter .count-badge {
            background: #ef4444;
            color: #fff;
            border-radius: 10px;
            font-size: 10px;
            padding: 0 6px;
            line-height: 16px;
        }

        /* Search results */
        .search-results-box {
            margin: 0 12px 8px 12px;
            background: #f9fbf9;
            border: 1px solid #e0e8e2;
            border-radius: 8px;
            max-height: 200px;
            overflow-y: auto;
        }

        .search-result-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 12px;
            text-decoration: none;
            color: #243328;
            border-bottom: 1px solid #f0f0f0;
        }

        .search-result-item:hover { background: #eef5f0; }

        /* Contact list (scrolls independently) */
        .conversation-list {
            flex: 1;
            overflow-y: auto;
            padding: 6px 10px 12px 10px;
            min-height: 0;
        }

        .chat-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 11px 12px;
            border-radius: 12px;
            text-decoration: none;
            color: inherit;
            margin-bottom: 4px;
            border: 1px solid transparent;
            border-left: 3px solid transparent;
            transition: all 0.15s ease;
        }

        .chat-item:hover { background-color: #f2f8f4; }

        .chat-item.active {
            background-color: #eafaf0;
            border-color: #d5efdd;
            border-left: 3px solid #1f9d55;
        }

        .avatar-circle {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 14px;
            flex-shrink: 0;
            position: relative;
        }

        .avatar-rt { background-color: #d8f3dc; color: #2d6a4f; }
        .avatar-mt { background-color: #f3e8ff; color: #7e22ce; }
        .avatar-mu { background-color: #fef3c7; color: #b45309; }
        .avatar-ml { background-color: #dcfce7; color: #15803d; }

        .chat-item-info { flex: 1; overflow: hidden; }

        .chat-item-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2px;
        }

        .chat-item-name { font-weight: 600; font-size: 14px; color: #111827; }
        .chat-item-time { font-size: 11px; color: #9ca3af; }

        .chat-item-preview {
            font-size: 12px;
            color: #6b7280;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            background-color: #22c55e;
            border-radius: 50%;
            display: inline-block;
            margin-right: 5px;
            box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.18);
        }

        /* ===== RIGHT: dashboard workspace ===== */
        .msgx-workspace {
            position: relative;
            overflow-y: auto;
            padding: 22px;
            background: #f7faf8;
            min-height: 0;
        }

        .ws-welcome {
            background: #ffffff;
            border: 1px solid #eef2ef;
            border-radius: 16px;
            padding: 26px;
            text-align: center;
            margin-bottom: 18px;
        }

        .ws-welcome .ws-icon {
            width: 54px; height: 54px;
            border-radius: 14px;
            background: #eafaf0;
            color: #12833f;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            margin-bottom: 10px;
        }

        .ws-welcome h2 { margin: 0 0 4px 0; color: #10261c; font-size: 20px; }
        .ws-welcome p { margin: 0; color: #7d8c82; font-size: 13px; }

        .ws-actions {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
            margin-bottom: 18px;
        }

        .ws-action {
            background: #ffffff;
            border: 1px solid #eef2ef;
            border-radius: 14px;
            padding: 18px;
            cursor: pointer;
            transition: box-shadow .15s, transform .15s;
            text-decoration: none;
            color: inherit;
            display: block;
        }

        .ws-action:hover { box-shadow: 0 8px 20px rgba(16,40,28,.08); transform: translateY(-2px); }
        .ws-action .a-icon { font-size: 22px; }
        .ws-action .a-title { font-weight: 700; color: #10261c; margin-top: 8px; font-size: 14px; }
        .ws-action .a-sub { color: #8b9a90; font-size: 12px; margin-top: 2px; }

        .ws-cards { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }

        .ws-card {
            background: #ffffff;
            border: 1px solid #eef2ef;
            border-radius: 14px;
            padding: 16px;
        }

        .ws-card h3 { margin: 0 0 10px 0; font-size: 14px; color: #10261c; }

        .ws-file-row, .ws-pin-row {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 8px 0;
            border-bottom: 1px solid #f2f5f3;
            font-size: 12px;
            color: #4b5b51;
        }
        .ws-file-row:last-child, .ws-pin-row:last-child { border-bottom: none; }

        /* ===== FLOATING CHAT POPUP ===== */
        .msgx-popup-scrim {
            position: absolute;
            inset: 0;
            background: rgba(16, 40, 28, 0.04); /* very subtle, list stays clickable-looking */
            pointer-events: none;               /* do NOT block the contact list */
            z-index: 20;
        }

        .chat-popup {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 440px;
            height: min(580px, calc(100% - 44px));
            background: #ffffff;
            border: 1px solid #e6ece8;
            border-radius: 16px;
            box-shadow: 0 20px 50px rgba(16, 40, 28, 0.28);
            display: flex;
            flex-direction: column;
            overflow: hidden;
            z-index: 30;
        }

        .chat-popup.expanded {
            top: 22px;
            left: 22px;
            right: 22px;
            bottom: 22px;
            transform: none;
            width: auto;
            height: auto;
        }

        .chat-popup.minimized {
            top: auto;
            bottom: 22px;
            transform: translateX(-50%);
            height: 58px;
            width: 300px;
        }

        .chat-popup.minimized .popup-body,
        .chat-popup.minimized .popup-input { display: none; }

        /* Popup header (fixed) */
        .popup-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 14px;
            border-bottom: 1px solid #eef2ef;
            background: #ffffff;
            flex-shrink: 0;
        }

        .popup-user { display: flex; align-items: center; gap: 10px; text-decoration: none; color: inherit; }
        .popup-user .p-name { font-weight: 700; color: #10261c; font-size: 14px; }
        .popup-user .p-status { font-size: 11px; color: #6b7280; display: flex; align-items: center; }

        .popup-actions { display: flex; align-items: center; gap: 4px; }

        .popup-btn {
            width: 30px; height: 30px;
            border-radius: 8px;
            border: none;
            background: #f2f6f3;
            color: #4b5b51;
            cursor: pointer;
            font-size: 15px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
        }
        .popup-btn:hover { background: #e2efe7; }
        .popup-btn.close:hover { background: #fde8e8; color: #c0392b; }

        /* Popup body = the ONLY scrolling area */
        .popup-body {
            flex: 1;
            overflow-y: auto;
            padding: 16px;
            background: #f7faf8;
            display: flex;
            flex-direction: column;
            gap: 14px;
            min-height: 0;
        }

        .date-divider { text-align: center; margin: 4px 0; }
        .date-divider span {
            background-color: #eef2ef;
            color: #9ca3af;
            font-size: 11px;
            padding: 4px 12px;
            border-radius: 12px;
        }

        .msg-row { display: flex; gap: 10px; max-width: 78%; }
        .msg-row.received { align-self: flex-start; }
        .msg-row.sent { align-self: flex-end; flex-direction: row-reverse; }

        .msg-bubble-received {
            background-color: #ffffff;
            color: #1f2937;
            padding: 11px 15px;
            border-radius: 4px 18px 18px 18px;
            font-size: 13px;
            line-height: 1.45;
            box-shadow: 0 1px 2px rgba(16, 40, 28, 0.06);
        }

        .msg-bubble-sent {
            background: linear-gradient(135deg, #eafaf0, #dff5e7);
            color: #10261c;
            padding: 11px 15px;
            border-radius: 18px 4px 18px 18px;
            font-size: 13px;
            line-height: 1.45;
            box-shadow: 0 1px 2px rgba(16, 40, 28, 0.06);
        }

        .msg-meta {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 4px;
            font-size: 10px;
            color: #9ca3af;
            margin-top: 4px;
        }

        .ticks-blue { color: #2563eb !important; font-weight: bold; }
        .ticks-gray { color: #9ca3af; }

        /* Popup input (fixed) */
        .popup-input {
            border-top: 1px solid #eef2ef;
            padding: 12px 14px;
            background: #ffffff;
            flex-shrink: 0;
        }

        .thread-input-row {
            display: flex;
            align-items: center;
            gap: 10px;
            background: #f4f7f5;
            border: 1px solid #e6ece8;
            border-radius: 28px;
            padding: 5px 6px 5px 10px;
        }

        .file-upload-wrapper { position: relative; display: flex; align-items: center; }

        .attach-btn-label {
            background: transparent;
            border: none;
            width: 34px; height: 34px;
            display: flex; align-items: center; justify-content: center;
            color: #6b7280; cursor: pointer; font-size: 16px;
        }

        .file-upload-hidden { display: none; }

        .message-input {
            flex: 1;
            padding: 10px 12px;
            border: none;
            background: transparent;
            font-size: 13px;
            outline: none;
        }

        .send-btn-gradient {
            background: linear-gradient(135deg, #1f9d55, #12833f);
            color: #fff;
            border: none;
            border-radius: 50%;
            width: 40px; height: 40px;
            font-weight: 600;
            font-size: 15px;
            cursor: pointer;
            flex-shrink: 0;
        }

        .attachment-preview {
            font-size: 12px;
            color: #15803d;
            margin-top: 6px;
            padding-left: 8px;
            display: block;
        }

        /* ===== Shared modals (details + rating) ===== */
        .modal-overlay {
            position: fixed;
            top: 0; left: 0;
            width: 100vw; height: 100vh;
            background: rgba(0, 0, 0, 0.45);
            display: flex; align-items: center; justify-content: center;
            z-index: 9999;
        }

        .modal-pop-card {
            background: #ffffff;
            width: 90%;
            max-width: 480px;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            position: relative;
        }

        .rating-dropdown, .rating-comment-input {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 13px;
            margin-top: 6px;
            outline: none;
            background: #f9fafb;
        }

        .rating-dropdown:focus, .rating-comment-input:focus { border-color: #173f2c; background: #fff; }

        .submit-rating-button {
            background-color: #173f2c;
            color: #fff;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
        }
        .submit-rating-button:hover { background-color: #112d20; }

        .close-modal-button {
            background-color: #e5e7eb;
            color: #374151;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            margin-left: 8px;
        }
        .close-modal-button:hover { background-color: #d1d5db; }

        @media (max-width: 900px) {
            .msgx-wrap { grid-template-columns: 1fr; }
            .ws-actions, .ws-cards { grid-template-columns: 1fr; }
            .chat-popup { right: 12px; left: 12px; width: auto; }
        }
    </style>

    <script type="text/javascript">
        function handleEnterKey(e, buttonId) {
            var key = e.keyCode || e.which;
            if (key === 13) {
                e.preventDefault();
                var btn = document.getElementById(buttonId);
                if (btn) { btn.click(); }
                return false;
            }
            return true;
        }

        function showSelectedFileName(input) {
            var label = document.getElementById('<%= lblAttachedFileName.ClientID %>');
            if (!label) return;
            if (input.files && input.files[0]) {
                label.innerText = "📎 Attached: " + input.files[0].name;
            } else {
                label.innerText = "";
            }
        }

        // Add a body class so the viewport lock only applies to the Messages page.
        (function () {
            document.addEventListener("DOMContentLoaded", function () {
                document.body.classList.add("messages-page");
            });
        })();

        // Client-side popup controls (minimise / expand). Close is a server postback.
        function popupToggleMinimize() {
            var p = document.getElementById("chatPopup");
            if (!p) return;
            p.classList.remove("expanded");
            p.classList.toggle("minimized");
        }
        function popupToggleExpand() {
            var p = document.getElementById("chatPopup");
            if (!p) return;
            p.classList.remove("minimized");
            p.classList.toggle("expanded");
        }
        // Keep the messages area scrolled to the newest message after each load/switch.
        function scrollPopupToBottom() {
            var b = document.getElementById("popupBody");
            if (b) b.scrollTop = b.scrollHeight;
        }
        document.addEventListener("DOMContentLoaded", scrollPopupToBottom);
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:ScriptManager ID="chatScriptManager" runat="server" />

    <!-- Success Alert Panel -->
    <asp:Panel ID="pnlStatus" runat="server" CssClass="chat-alert-success" Visible="false">
        <span>✔</span>
        <asp:Label ID="lblStatus" runat="server"></asp:Label>
    </asp:Panel>

    <div class="msgx-wrap">

        <!-- ============ LEFT: CONVERSATION / CONTACT PANEL ============ -->
        <div class="conversation-panel">

            <div class="conversation-head">
                <h1 class="conversation-title">Messages</h1>
                <p class="conversation-subtitle">Stay connected with clients and freelancers on FreeHUB.</p>

                <asp:Panel ID="pnlChatSearch" runat="server" DefaultButton="btnSearchUser" CssClass="chat-search-row">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="chat-search-input" placeholder="Search conversations..." />
                    <asp:Button ID="btnSearchUser" runat="server" Text="Search 🔍" CssClass="chat-search-btn" OnClick="btnSearchUser_Click" />
                </asp:Panel>

                <!-- Filter tabs (visual grouping; All is the active default) -->
                <div class="msgx-filters">
                    <span class="msgx-filter active">All</span>
                    <span class="msgx-filter">Unread</span>
                    <span class="msgx-filter">Clients</span>
                    <span class="msgx-filter">Freelancers</span>
                </div>
            </div>

            <!-- Search Results Dropdown List -->
            <asp:Panel ID="pnlSearchResults" runat="server" CssClass="search-results-box" Visible="false">
                <div style="padding: 8px 12px; font-size: 11px; font-weight: bold; color: #5a6e5f; background: #eef5f0;">MATCHING SYSTEM USERS:</div>
                <asp:Repeater ID="rptSearchResults" runat="server" OnItemCommand="rptSearchResults_ItemCommand">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnSelectSearchResult" runat="server" CssClass="search-result-item" CommandName="StartChatWithUser" CommandArgument='<%# Eval("userID") %>'>
                            <div>
                                <strong style="display: block; font-size: 13px; color: #173f2c;"><%# Eval("firstName") %> <%# Eval("lastName") %></strong>
                                <small style="color: #6b7280; font-size: 11px;"><%# Eval("email") %></small>
                            </div>
                            <span style="background: #e8f5e0; color: #2d6b3f; padding: 2px 6px; border-radius: 8px; font-size: 10px; font-weight: 600;"><%# Eval("userType") %></span>
                        </asp:LinkButton>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Label ID="lblNoUsersFound" runat="server" Visible="false" Text="No users found." Style="display: block; padding: 10px; text-align: center; color: #9ca3af; font-size: 12px;" />
            </asp:Panel>

            <!-- Conversations List (scrolls independently) -->
            <div class="conversation-list">
                <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnSelectUser" runat="server" CssClass='<%# Convert.ToInt32(Eval("UserID")) == SelectedOtherUserId ? "chat-item active" : "chat-item" %>' CommandName="SelectUser" CommandArgument='<%# Eval("UserID") %>'>
                            <div class='<%# "avatar-circle " + GetAvatarClass(Eval("Initials").ToString()) %>'>
                                <%# Eval("Initials") %>
                            </div>
                            <div class="chat-item-info">
                                <div class="chat-item-header">
                                    <span class="chat-item-name"><%# Eval("Name") %></span>
                                    <span class="chat-item-time"><%# Eval("LastTime") %></span>
                                </div>
                                <div class="chat-item-preview"><%# Eval("LastMessage") %></div>
                            </div>
                        </asp:LinkButton>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Label ID="lblNoUsers" runat="server" Visible="false" Text="No active conversations." CssClass="chat-item-preview" Style="padding:10px; display:block;"></asp:Label>
            </div>
        </div>

        <!-- ============ RIGHT: DASHBOARD WORKSPACE ============ -->
        <div class="msgx-workspace">

            <!-- Welcome -->
            <div class="ws-welcome">
                <div class="ws-icon">💬</div>
                <h2>Welcome to Messages</h2>
                <p>Select a conversation to start chatting, or start a new one.</p>
            </div>

            <!-- Quick actions -->
            <div class="ws-actions">
                <a class="ws-action" href="StartChat.aspx">
                    <div class="a-icon">✉️</div>
                    <div class="a-title">New Message</div>
                    <div class="a-sub">Start a conversation with a contact.</div>
                </a>
                <a class="ws-action" href="BrowseProjects.aspx">
                    <div class="a-icon">🧑‍💻</div>
                    <div class="a-title">Find Freelancers</div>
                    <div class="a-sub">Discover talent and start a chat.</div>
                </a>
                <a class="ws-action" href="#">
                    <div class="a-icon">📎</div>
                    <div class="a-title">Share Files</div>
                    <div class="a-sub">Send documents and designs.</div>
                </a>
            </div>

            <!-- Pinned + Recently shared -->
            <div class="ws-cards">
                <div class="ws-card">
                    <h3>Pinned Contacts</h3>
                    <asp:Repeater ID="rptPinnedContacts" runat="server">
                        <ItemTemplate>
                            <div class="ws-pin-row">
                                <div class='<%# "avatar-circle " + GetAvatarClass(Eval("Initials").ToString()) %>' style="width:32px;height:32px;font-size:12px;">
                                    <%# Eval("Initials") %>
                                </div>
                                <span><%# Eval("Name") %></span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Label ID="lblNoPinned" runat="server" Visible="false" Text="No contacts yet." Style="font-size:12px;color:#9ca3af;" />
                </div>

                <div class="ws-card">
                    <h3>Recently Shared Files</h3>
                    <asp:Repeater ID="rptRecentFiles" runat="server">
                        <ItemTemplate>
                            <div class="ws-file-row">
                                <span>📄</span>
                                <span style="flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;"><%# System.IO.Path.GetFileName(Eval("attachmentUrl").ToString()) %></span>
                                <small style="color:#9ca3af;"><%# TimeHelper.ToSast(Eval("timeStamp")).ToString("dd MMM") %></small>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Label ID="lblNoRecentFiles" runat="server" Visible="false" Text="No files shared yet." Style="font-size:12px;color:#9ca3af;" />
                </div>
            </div>

            <!-- ============ FLOATING CHAT POPUP ============ -->
            <asp:UpdatePanel ID="upChat" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:Panel ID="pnlChatPopup" runat="server" Visible="false">

                        <div class="msgx-popup-scrim"></div>

                        <div id="chatPopup" class="chat-popup">

                            <!-- HEADER (fixed) -->
                            <div class="popup-header">
                                <asp:LinkButton ID="btnOpenHeaderModal" runat="server" CssClass="popup-user" OnClick="btnToggleDetails_Click" title="View Profile & Shared Files">
                                    <div class="avatar-circle avatar-rt">
                                        <asp:Label ID="lblChatInitials" runat="server" Text="--"></asp:Label>
                                    </div>
                                    <div>
                                        <div class="p-name">
                                            <asp:Label ID="lblChatName" runat="server" Text="Select a conversation"></asp:Label>
                                        </div>
                                        <div class="p-status">
                                            <span class="status-dot"></span>
                                            <asp:Label ID="lblPartnerStatus" runat="server" Text="Offline"></asp:Label>
                                        </div>
                                    </div>
                                </asp:LinkButton>

                                <div class="popup-actions">
                                    <asp:LinkButton ID="btnInfoIcon" runat="server" CssClass="popup-btn" OnClick="btnToggleDetails_Click" title="Info">ⓘ</asp:LinkButton>
                                    <button type="button" class="popup-btn" title="Minimise" onclick="popupToggleMinimize();return false;">—</button>
                                    <button type="button" class="popup-btn" title="Expand" onclick="popupToggleExpand();return false;">□</button>
                                    <asp:LinkButton ID="btnCloseChat" runat="server" CssClass="popup-btn close" OnClick="btnCloseChat_Click" title="Close" CausesValidation="false">×</asp:LinkButton>
                                </div>
                            </div>

                            <!-- BODY = ONLY THIS SCROLLS -->
                            <div id="popupBody" class="popup-body">
                                <div class="date-divider"><span>Today</span></div>
                                <asp:Repeater ID="rptMessages" runat="server">
                                    <ItemTemplate>
                                        <div class='<%# Convert.ToInt32(Eval("senderID")) == CurrentUserId ? "msg-row sent" : "msg-row received" %>'>
                                            <div class='<%# Convert.ToInt32(Eval("senderID")) == CurrentUserId ? "msg-bubble-sent" : "msg-bubble-received" %>'>
                                                <%# Eval("content") %>

                                                <asp:PlaceHolder ID="phAttachment" runat="server" Visible='<%# Eval("attachmentUrl") != DBNull.Value && !string.IsNullOrEmpty(Eval("attachmentUrl").ToString()) %>'>
                                                    <div style="margin-top: 6px; padding-top: 4px; border-top: 1px solid rgba(0,0,0,0.1);">
                                                        <asp:PlaceHolder ID="phAttachmentLink" runat="server" Visible='<%# AttachmentExists(Eval("attachmentUrl")) %>'>
                                                            <a href='<%# ResolveAttachmentUrl(Eval("attachmentUrl")) %>' target="_blank" style="color: #059669; font-weight: bold; text-decoration: underline; font-size: 11px;">
                                                                📎 View Attached File
                                                            </a>
                                                        </asp:PlaceHolder>
                                                        <asp:PlaceHolder ID="phAttachmentMissing" runat="server" Visible='<%# !AttachmentExists(Eval("attachmentUrl")) %>'>
                                                            <span style="color: #b91c1c; font-style: italic; font-size: 11px;" title='<%# Eval("attachmentUrl") %>'>
                                                                📎 Attachment unavailable
                                                            </span>
                                                        </asp:PlaceHolder>
                                                    </div>
                                                </asp:PlaceHolder>

                                                <div class="msg-meta">
                                                    <span><%# TimeHelper.ToSast(Eval("timeStamp")).ToString("HH:mm") %></span>
                                                    <asp:PlaceHolder ID="phReadReceipt" runat="server" Visible='<%# Convert.ToInt32(Eval("senderID")) == CurrentUserId %>'>
                                                        <span class='<%# Eval("status").ToString() == "Read" ? "ticks-blue" : "ticks-gray" %>'>
                                                            <%# Eval("status").ToString() == "Read" ? "✓✓" : "✓" %>
                                                        </span>
                                                    </asp:PlaceHolder>
                                                </div>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>

                            <!-- INPUT (fixed) -->
                            <div class="popup-input">
                                <asp:Panel ID="pnlChatInput" runat="server" DefaultButton="btnSend" CssClass="thread-input-row">
                                    <div class="file-upload-wrapper">
                                        <label for="<%= fileUploadControl.ClientID %>" class="attach-btn-label" title="Attach file">📎</label>
                                        <asp:FileUpload ID="fileUploadControl" runat="server" CssClass="file-upload-hidden" onchange="showSelectedFileName(this);" />
                                    </div>
                                    <asp:TextBox ID="txtMessage" runat="server" CssClass="message-input" placeholder="Type your message..." onkeydown="return handleEnterKey(event, '<%= btnSend.ClientID %>');"></asp:TextBox>
                                    <asp:Button ID="btnSend" runat="server" Text="➤" CssClass="send-btn-gradient" OnClick="btnSend_Click" />
                                </asp:Panel>
                                <asp:Label ID="lblAttachedFileName" runat="server" CssClass="attachment-preview"></asp:Label>
                            </div>

                        </div>
                    </asp:Panel>
                </ContentTemplate>
                <Triggers>
                    <asp:PostBackTrigger ControlID="btnSend" />
                </Triggers>
            </asp:UpdatePanel>

        </div>
    </div>

    <!-- CONTACT DETAILS & SHARED FILES MODAL -->
    <asp:Panel ID="pnlUserDetailsModal" runat="server" CssClass="modal-overlay" Visible="false">
        <div class="modal-pop-card">
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e0e8e2; padding-bottom: 12px; margin-bottom: 16px;">
                <h3 style="margin: 0; color: #173f2c; font-size: 18px;">Contact Info & Shared Files</h3>
                <asp:LinkButton ID="btnCloseDetails" runat="server" OnClick="btnCloseDetails_Click" Style="color: #888; text-decoration: none; font-size: 20px; font-weight: bold; cursor: pointer;">✕</asp:LinkButton>
            </div>

            <div style="background: #f9fbf9; border: 1px solid #e0e8e2; border-radius: 8px; padding: 14px; margin-bottom: 18px; display: grid; grid-template-columns: 1fr 1fr; gap: 10px; font-size: 13px; color: #243328;">
                <div><strong>Full Name:</strong> <asp:Label ID="lblDetailName" runat="server" /></div>
                <div><strong>Account Type:</strong> <asp:Label ID="lblDetailUserType" runat="server" /></div>
                <div><strong>Email:</strong> <asp:Label ID="lblDetailEmail" runat="server" /></div>
                <div><strong>Contact:</strong> <asp:Label ID="lblDetailContact" runat="server" /></div>
                <div style="grid-column: span 2;"><strong>Rating Score:</strong> ⭐ <asp:Label ID="lblDetailRating" runat="server" /> / 5.0</div>
            </div>

            <div style="border-top: 1px solid #e0e8e2; padding-top: 14px;">
                <strong style="color: #173f2c; font-size: 14px; display: block; margin-bottom: 8px;">Shared Files History</strong>
                <div style="max-height: 180px; overflow-y: auto; border: 1px solid #f0f0f0; border-radius: 6px; padding: 8px;">
                    <asp:Repeater ID="rptSharedFiles" runat="server">
                        <HeaderTemplate>
                            <ul style="list-style: none; padding: 0; margin: 0;">
                        </HeaderTemplate>
                        <ItemTemplate>
                            <li style="padding: 8px; border-bottom: 1px solid #f0f0f0; font-size: 12px; display: flex; justify-content: space-between; align-items: center;">
                                <span style="color: #243328; font-weight: 500;">📎 <%# System.IO.Path.GetFileName(Eval("attachmentUrl").ToString()) %></span>
                                <div>
                                    <small style="color: #888; margin-right: 10px;"><%# TimeHelper.ToSast(Eval("timeStamp")).ToString("dd MMM yyyy, HH:mm") %></small>
                                    <asp:PlaceHolder runat="server" Visible='<%# AttachmentExists(Eval("attachmentUrl")) %>'>
                                        <a href='<%# ResolveAttachmentUrl(Eval("attachmentUrl")) %>' target="_blank" style="color: #059669; font-weight: bold; text-decoration: underline;">Download</a>
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder runat="server" Visible='<%# !AttachmentExists(Eval("attachmentUrl")) %>'>
                                        <span style="color: #b91c1c; font-style: italic;">Unavailable</span>
                                    </asp:PlaceHolder>
                                </div>
                            </li>
                        </ItemTemplate>
                        <FooterTemplate>
                            </ul>
                        </FooterTemplate>
                    </asp:Repeater>
                    <asp:Label ID="lblNoSharedFiles" runat="server" Visible="false" Text="No shared files in this conversation yet." Style="font-size: 13px; color: #888; display: block; text-align: center; padding: 12px 0;" />
                </div>
            </div>

            <div style="text-align: right; margin-top: 18px;">
                <asp:Button ID="btnCloseModalBtn" runat="server" Text="Close" OnClick="btnCloseDetails_Click" CausesValidation="false" Style="background: #173f2c; color: white; border: none; padding: 8px 18px; border-radius: 6px; font-weight: 600; cursor: pointer;" />
            </div>
        </div>
    </asp:Panel>

    <!-- Rating Popup Modal -->
    <asp:Panel ID="pnlRatingModal" runat="server" CssClass="modal-overlay" Visible="false">
        <div class="modal-pop-card">
            <div class="modal-header" style="border-bottom: 1px solid #e5e7eb; padding-bottom: 12px; margin-bottom: 16px;">
                <h3 style="margin: 0; color: #173f2c; font-size: 18px;">Project completed</h3>
                <p style="margin: 4px 0 0 0; font-size: 13px; color: #6b7280;">Messaging has ended. Please rate your experience.</p>
            </div>
            <div class="modal-body" style="font-size: 13px; color: #374151;">
                <label style="font-weight: 600; display: block; color: #173f2c;">Rating (1 to 5 Stars):</label>
                <asp:DropDownList ID="ddlRatingStars" runat="server" CssClass="rating-dropdown">
                    <asp:ListItem Text="5 Stars - Excellent" Value="5" Selected="True" />
                    <asp:ListItem Text="4 Stars - Very Good" Value="4" />
                    <asp:ListItem Text="3 Stars - Good" Value="3" />
                    <asp:ListItem Text="2 Stars - Fair" Value="2" />
                    <asp:ListItem Text="1 Star - Poor" Value="1" />
                </asp:DropDownList>
                <br /><br />
                <label style="font-weight: 600; display: block; color: #173f2c;">Feedback Comment (Optional):</label>
                <asp:TextBox ID="txtRatingComment" runat="server" TextMode="MultiLine" Rows="3" CssClass="rating-comment-input" placeholder="Write a short review..."></asp:TextBox>
            </div>
            <div class="modal-footer" style="margin-top: 20px; text-align: right;">
                <asp:Button ID="btnSubmitRating" runat="server" Text="Submit Rating" CssClass="submit-rating-button" OnClick="btnSubmitRating_Click" />
                <asp:Button ID="btnCloseModal" runat="server" Text="Close" CssClass="close-modal-button" OnClick="btnCloseModal_Click" CausesValidation="false" />
            </div>
        </div>
    </asp:Panel>

</asp:Content>

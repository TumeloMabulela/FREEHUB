<%@ Page Title="Messages"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="StartChat.aspx.cs"
    Inherits="FreeHubProject.StartChat" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* ===== FreeHub Messages workspace ===== */
        .fh-msg-root {
            font-family: Arial, Helvetica, sans-serif;
            display: flex;
            height: calc(100vh - 170px);
            min-height: 520px;
            background: #ffffff;
            border: 1px solid #e5e9e6;
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 10px 28px rgba(16, 40, 28, 0.07);
        }

        .fh-alert {
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
            font-family: Arial, Helvetica, sans-serif;
        }

        /* ===== SIDEBAR (≈320px) ===== */
        .fh-sidebar {
            width: 320px;
            flex-shrink: 0;
            border-right: 1px solid #e5e9e6;
            display: flex;
            flex-direction: column;
            background: #ffffff;
            min-height: 0;
        }

        .fh-sidebar-head { padding: 18px 18px 10px 18px; }
        .fh-sidebar-title { margin: 0 0 12px 0; font-size: 22px; font-weight: 800; color: #10261c; }

        .fh-search {
            position: relative;
            margin-bottom: 12px;
        }
        .fh-search .fh-search-icon {
            position: absolute; left: 12px; top: 50%; transform: translateY(-50%);
            color: #9aa6a0; font-size: 14px; pointer-events: none;
        }
        .fh-search-input {
            width: 100%;
            box-sizing: border-box;
            padding: 10px 12px 10px 34px;
            border: 1px solid #e2e8e4;
            border-radius: 10px;
            font-size: 13px;
            background: #f7faf8;
            font-family: Arial, Helvetica, sans-serif;
        }
        .fh-search-input:focus { outline: none; border-color: #1f9d55; background: #fff; box-shadow: 0 0 0 3px rgba(31,157,85,.12); }
        .fh-search-btn { display: none; } /* search runs on text change / enter */

        /* Segmented filter (All / Unread) */
        .fh-filters {
            display: flex;
            background: #eef4f0;
            border-radius: 10px;
            padding: 3px;
            gap: 3px;
            margin-bottom: 6px;
        }
        .fh-filter {
            flex: 1;
            text-align: center;
            padding: 7px 6px;
            font-size: 13px;
            font-weight: 600;
            color: #5a6e62;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
        }
        .fh-filter.active { background: #d9f2e1; color: #12833f; }
        /* Clients/Freelancers kept as secondary chips below */
        .fh-filter-sub {
            display: flex; gap: 6px; margin: 2px 0 2px 0;
        }
        .fh-filter-chip {
            font-size: 11px; font-weight: 600; color: #5a6e62;
            border: 1px solid #e2e8e4; border-radius: 14px;
            padding: 4px 10px; cursor: pointer; text-decoration: none; background:#fff;
        }
        .fh-filter-chip.active { background: #eafaf0; color: #12833f; border-color: #bfe8cd; }

        .fh-section-label { font-size: 11px; font-weight: 700; color: #9aa6a0; letter-spacing: .4px; padding: 10px 18px 4px 18px; }

        /* Search results dropdown */
        .fh-search-results {
            margin: 0 14px 8px 14px;
            background: #f9fbf9; border: 1px solid #e0e8e2; border-radius: 10px;
            max-height: 220px; overflow-y: auto;
        }
        .fh-search-result-item {
            display: flex; justify-content: space-between; align-items: center;
            padding: 10px 12px; text-decoration: none; color: #243328;
            border-bottom: 1px solid #eef2ef;
        }
        .fh-search-result-item:hover { background: #eef5f0; }

        /* Conversation list — scrolls independently */
        .fh-conv-list {
            flex: 1;
            overflow-y: auto;
            padding: 2px 10px 12px 10px;
            min-height: 0;
        }
        .fh-conv {
            display: flex; align-items: center; gap: 12px;
            padding: 11px 10px; border-radius: 10px;
            text-decoration: none; color: inherit; cursor: pointer;
            border-left: 3px solid transparent;
        }
        .fh-conv:hover { background: #f4f8f5; }
        .fh-conv.active { background: #eafaf0; border-left-color: #1f9d55; }

        .fh-avatar {
            width: 42px; height: 42px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 14px; flex-shrink: 0;
        }
        .avatar-rt { background:#d8f3dc; color:#2d6a4f; }
        .avatar-mt { background:#f3e8ff; color:#7e22ce; }
        .avatar-mu { background:#fef3c7; color:#b45309; }
        .avatar-ml { background:#dcfce7; color:#15803d; }

        .fh-conv-info { flex: 1; overflow: hidden; }
        .fh-conv-top { display: flex; justify-content: space-between; align-items: center; }
        .fh-conv-name { font-weight: 700; font-size: 14px; color: #111827; }
        .fh-conv-time { font-size: 11px; color: #9ca3af; }
        .fh-conv-time.unread { color: #1f9d55; font-weight: 700; }
        .fh-conv-bottom { display: flex; align-items: center; justify-content: space-between; gap: 8px; margin-top: 2px; }
        .fh-conv-preview { font-size: 12px; color: #6b7280; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex: 1; }
        .fh-unread-badge {
            background: #1f9d55; color: #fff; font-size: 11px; font-weight: 700;
            min-width: 20px; height: 20px; border-radius: 10px; padding: 0 6px;
            display: inline-flex; align-items: center; justify-content: center; flex-shrink: 0;
        }

        /* ===== CHAT AREA (flexible) ===== */
        .fh-chat {
            flex: 1;
            display: flex;
            flex-direction: column;
            min-width: 0;
            min-height: 0;
            background: #f7faf8;
        }

        /* The ASP.NET UpdatePanel renders a <div id="upChat"> between .fh-chat and
           the chat panel. It must be a bounded flex column so the messages area scrolls
           and the composer stays pinned at the bottom. */
        #upChat {
            flex: 1;
            min-height: 0;
            display: flex;
            flex-direction: column;
        }

        /* Active chat panel: bounded-height flex column (header + project bar fixed,
           messages scroll, composer pinned). */
        .fh-chat-panel {
            flex: 1;
            min-height: 0;
            display: flex;
            flex-direction: column;
        }

        /* Welcome screen */
        .fh-welcome {
            flex: 1;
            display: flex; flex-direction: column;
            align-items: center; justify-content: center;
            text-align: center; padding: 24px;
            background: #ffffff;
        }
        .fh-welcome-icon {
            width: 92px; height: 92px; border-radius: 24px;
            display: flex; align-items: center; justify-content: center;
            font-size: 44px; color: #1f9d55; margin-bottom: 18px;
            border: 2px solid #d9f2e1;
        }
        .fh-welcome h2 { margin: 0 0 6px 0; font-size: 26px; color: #10261c; }
        .fh-welcome p { margin: 0 0 18px 0; color: #7d8c82; font-size: 14px; }
        .fh-welcome-btn {
            background: linear-gradient(135deg, #1f9d55, #12833f);
            color: #fff; border: none; border-radius: 10px;
            padding: 12px 22px; font-size: 14px; font-weight: 700;
            cursor: pointer; text-decoration: none; display: inline-block;
            font-family: Arial, Helvetica, sans-serif;
        }

        /* Chat header (fixed) */
        .fh-chat-head {
            display: flex; align-items: center; justify-content: space-between;
            padding: 12px 18px; background: #ffffff; border-bottom: 1px solid #e5e9e6;
            flex-shrink: 0;
        }
        .fh-chat-head-user { display: flex; align-items: center; gap: 12px; text-decoration: none; color: inherit; }
        .fh-chat-head-name { font-weight: 800; color: #10261c; font-size: 15px; }
        .fh-chat-head-status { font-size: 12px; color: #6b7280; display: flex; align-items: center; }
        .status-dot {
            width: 8px; height: 8px; background: #22c55e; border-radius: 50%;
            display: inline-block; margin-right: 5px; box-shadow: 0 0 0 3px rgba(34,197,94,.18);
        }
        .status-dot.offline { background: #ef4444; box-shadow: 0 0 0 3px rgba(239,68,68,.18); }
        .fh-head-actions { display: flex; align-items: center; gap: 10px; }
        .fh-view-project {
            border: 1px solid #cfe8d8; background: #fff; color: #12833f;
            border-radius: 8px; padding: 7px 12px; font-size: 13px; font-weight: 700;
            cursor: pointer; text-decoration: none;
        }
        .fh-view-project:hover { background: #eafaf0; }
        .fh-icon-btn {
            width: 36px; height: 36px; border-radius: 50%; border: 1px solid #e5e9e6;
            background: #fff; color: #5a6e62; display: inline-flex; align-items: center;
            justify-content: center; cursor: pointer; text-decoration: none; font-size: 15px;
        }
        .fh-icon-btn:hover { background: #f2f6f3; }

        /* Project sub-bar under header */
        .fh-project-bar {
            display: flex; align-items: center; gap: 8px;
            padding: 8px 18px; background: #ffffff; border-bottom: 1px solid #eef2ef;
            font-size: 13px; color: #4b5b51; flex-shrink: 0;
        }
        .fh-project-bar .proj-name { font-weight: 700; color: #10261c; }
        .fh-dot-green { width: 8px; height: 8px; border-radius: 50%; background: #1f9d55; display: inline-block; }

        /* Messages — ONLY this scrolls */
        .fh-messages {
            flex: 1; overflow-y: auto; min-height: 0;
            padding: 16px 22px;
            display: flex; flex-direction: column; gap: 10px;
        }
        .fh-day { align-self: center; background: #e8efe9; color: #5a6e62; font-size: 12px; padding: 4px 12px; border-radius: 12px; margin: 4px 0; }

        .fh-row { display: flex; gap: 8px; max-width: 72%; }
        .fh-row.recv { align-self: flex-start; }
        .fh-row.sent { align-self: flex-end; flex-direction: row-reverse; }
        .fh-row-avatar {
            width: 30px; height: 30px; border-radius: 50%; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            font-size: 11px; font-weight: 700; background: #d8f3dc; color: #2d6a4f;
        }
        .fh-bubble {
            padding: 9px 13px; font-size: 14px; line-height: 1.4; color: #10261c;
            box-shadow: 0 1px 2px rgba(16,40,28,.08); position: relative;
        }
        .fh-row.recv .fh-bubble { background: #ffffff; border-radius: 4px 14px 14px 14px; }
        .fh-row.sent .fh-bubble { background: #d9fdd3; border-radius: 14px 4px 14px 14px; }
        .fh-bubble-time { font-size: 10.5px; color: #667781; margin-left: 10px; float: right; position: relative; top: 4px; }
        .ticks-blue { color: #53bdeb !important; }
        .ticks-gray { color: #667781; }

        /* File card inside a bubble */
        .fh-file-card {
            display: flex; align-items: center; gap: 10px;
            background: #ffffff; border: 1px solid #e5e9e6; border-radius: 10px;
            padding: 8px 10px; margin-top: 2px; min-width: 200px;
        }
        .fh-file-ic { font-size: 22px; }
        .fh-file-meta { flex: 1; overflow: hidden; }
        .fh-file-name { font-weight: 700; font-size: 13px; color: #10261c; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .fh-file-sub { font-size: 11px; color: #8b9a90; }
        .fh-file-dl { color: #1f9d55; font-size: 18px; text-decoration: none; flex-shrink: 0; }
        .fh-file-missing { color: #b91c1c; font-style: italic; font-size: 12px; }

        /* Input (fixed) */
        .fh-input-wrap { padding: 12px 18px; background: #ffffff; border-top: 1px solid #e5e9e6; flex-shrink: 0; }
        .fh-input-row {
            display: flex; align-items: center; gap: 8px;
            background: #f4f7f5; border: 1px solid #e6ece8; border-radius: 26px;
            padding: 5px 6px 5px 10px;
        }
        .fh-attach { width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; color: #6b7280; cursor: pointer; font-size: 17px; }
        .fh-file-hidden { display: none; }
        .fh-msg-input { flex: 1; border: none; background: transparent; padding: 10px 8px; font-size: 14px; outline: none; font-family: Arial, Helvetica, sans-serif; }
        .fh-send {
            width: 44px; height: 44px; border-radius: 50%; border: none;
            background: linear-gradient(135deg, #1f9d55, #12833f); color: #fff;
            font-size: 16px; cursor: pointer; flex-shrink: 0;
        }
        .fh-attach-preview { font-size: 12px; color: #15803d; margin-top: 6px; padding-left: 10px; display: block; }

        /* ===== PROJECT DETAILS PANEL (≈280px, collapsible) ===== */
        .fh-details {
            width: 280px; flex-shrink: 0;
            border-left: 1px solid #e5e9e6; background: #ffffff;
            display: flex; flex-direction: column; min-height: 0;
            overflow-y: auto;
        }
        .fh-details.collapsed { display: none; }
        .fh-details-head {
            display: flex; align-items: center; justify-content: space-between;
            padding: 16px 18px; border-bottom: 1px solid #eef2ef;
        }
        .fh-details-title { font-size: 16px; font-weight: 800; color: #10261c; }
        .fh-details-body { padding: 16px 18px; }
        .fh-details-sub { font-size: 11px; font-weight: 700; color: #9aa6a0; letter-spacing: .4px; margin: 16px 0 8px 0; }
        .fh-details-project { font-size: 16px; font-weight: 800; color: #10261c; margin-bottom: 4px; }
        .fh-details-status { font-size: 13px; color: #4b5b51; display: flex; align-items: center; gap: 6px; }

        /* ===== Shared modals ===== */
        .modal-overlay {
            position: fixed; top:0; left:0; width:100vw; height:100vh;
            background: rgba(0,0,0,.45); display:flex; align-items:center; justify-content:center; z-index:9999;
        }
        .modal-pop-card { background:#fff; width:90%; max-width:480px; border-radius:12px; padding:24px; box-shadow:0 10px 25px rgba(0,0,0,.2); font-family: Arial, Helvetica, sans-serif; }
        .rating-dropdown, .rating-comment-input { width:100%; padding:10px 14px; border:1px solid #d1d5db; border-radius:8px; font-size:13px; margin-top:6px; outline:none; background:#f9fafb; box-sizing:border-box; }
        .rating-dropdown:focus, .rating-comment-input:focus { border-color:#173f2c; background:#fff; }
        .submit-rating-button { background:#173f2c; color:#fff; border:none; padding:10px 20px; border-radius:8px; font-weight:600; font-size:13px; cursor:pointer; }
        .close-modal-button { background:#e5e7eb; color:#374151; border:none; padding:10px 20px; border-radius:8px; font-weight:600; font-size:13px; cursor:pointer; margin-left:8px; }

        /* ===== Mobile ===== */
        .fh-back-btn { display: none; }
        @media (max-width: 820px) {
            .fh-msg-root { flex-direction: column; height: auto; min-height: 0; }
            .fh-details { display: none; }
            /* Show contacts first; when a chat is open, hide the list and show the chat with a back button. */
            .fh-msg-root.chat-open .fh-sidebar { display: none; }
            .fh-msg-root:not(.chat-open) .fh-chat { display: none; }
            .fh-sidebar { width: 100%; height: 70vh; }
            .fh-chat { height: calc(100vh - 170px); }
            .fh-back-btn { display: inline-flex; }
        }
    </style>

    <script type="text/javascript">
        function showSelectedFileName(input) {
            var label = document.getElementById('<%= lblAttachedFileName.ClientID %>');
            if (!label) return;
            label.innerText = (input.files && input.files[0]) ? ("📎 Attached: " + input.files[0].name) : "";
        }

        // Scroll the message area to the newest message (open/switch/postback).
        function scrollPopupToBottom() {
            var b = document.getElementById("fhMessages");
            if (!b) return;
            var jump = function () { b.scrollTop = b.scrollHeight; };
            jump();
            requestAnimationFrame(function () { requestAnimationFrame(jump); });
            setTimeout(jump, 60);
            setTimeout(jump, 200);
        }
        document.addEventListener("DOMContentLoaded", scrollPopupToBottom);
        if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(scrollPopupToBottom);
        }

        // Collapse/expand the project details panel (client-side).
        function toggleDetails() {
            var d = document.getElementById("pnlProjectDetails");
            if (d) d.classList.toggle("collapsed");
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:ScriptManager ID="chatScriptManager" runat="server" />

    <asp:Panel ID="pnlStatus" runat="server" CssClass="fh-alert" Visible="false">
        <span>✔</span>
        <asp:Label ID="lblStatus" runat="server"></asp:Label>
    </asp:Panel>

    <div runat="server" id="workspacePanel" class="fh-msg-root">

        <!-- ============ SIDEBAR ============ -->
        <div class="fh-sidebar">
            <div class="fh-sidebar-head">
                <h1 class="fh-sidebar-title">Messages</h1>

                <asp:Panel ID="pnlChatSearch" runat="server" DefaultButton="btnSearchUser" CssClass="fh-search">
                    <span class="fh-search-icon">🔍</span>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="fh-search-input" placeholder="Search conversations..."
                        AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                    <asp:Button ID="btnSearchUser" runat="server" Text="Search" CssClass="fh-search-btn" OnClick="btnSearchUser_Click" />
                </asp:Panel>

                <!-- Segmented All / Unread -->
                <div class="fh-filters">
                    <asp:LinkButton ID="btnFilterAll" runat="server" CssClass="fh-filter active" CommandArgument="All" OnClick="Filter_Click" CausesValidation="false">All</asp:LinkButton>
                    <asp:LinkButton ID="btnFilterUnread" runat="server" CssClass="fh-filter" CommandArgument="Unread" OnClick="Filter_Click" CausesValidation="false">Unread</asp:LinkButton>
                </div>
                <!-- Secondary role chips -->
                <div class="fh-filter-sub">
                    <asp:LinkButton ID="btnFilterClients" runat="server" CssClass="fh-filter-chip" CommandArgument="Clients" OnClick="Filter_Click" CausesValidation="false">Clients</asp:LinkButton>
                    <asp:LinkButton ID="btnFilterFreelancers" runat="server" CssClass="fh-filter-chip" CommandArgument="Freelancers" OnClick="Filter_Click" CausesValidation="false">Freelancers</asp:LinkButton>
                </div>
            </div>

            <!-- Search results -->
            <asp:Panel ID="pnlSearchResults" runat="server" CssClass="fh-search-results" Visible="false">
                <div style="padding:8px 12px; font-size:11px; font-weight:bold; color:#5a6e5f; background:#eef5f0;">MATCHING SYSTEM USERS:</div>
                <asp:Repeater ID="rptSearchResults" runat="server" OnItemCommand="rptSearchResults_ItemCommand">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnSelectSearchResult" runat="server" CssClass="fh-search-result-item" CommandName="StartChatWithUser" CommandArgument='<%# Eval("userID") %>'>
                            <div>
                                <strong style="display:block; font-size:13px; color:#173f2c;"><%# Eval("firstName") %> <%# Eval("lastName") %></strong>
                                <small style="color:#6b7280; font-size:11px;"><%# Eval("email") %></small>
                            </div>
                            <span style="background:#e8f5e0; color:#2d6b3f; padding:2px 6px; border-radius:8px; font-size:10px; font-weight:600;"><%# Eval("userType") %></span>
                        </asp:LinkButton>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Label ID="lblNoUsersFound" runat="server" Visible="false" Text="No users found." Style="display:block; padding:10px; text-align:center; color:#9ca3af; font-size:12px;" />
            </asp:Panel>

            <div class="fh-section-label">CONVERSATIONS</div>

            <!-- Conversation list (independent scroll) -->
            <div class="fh-conv-list">
                <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnSelectUser" runat="server" CssClass='<%# Convert.ToInt32(Eval("UserID")) == SelectedOtherUserId ? "fh-conv active" : "fh-conv" %>' CommandName="SelectUser" CommandArgument='<%# Eval("UserID") %>'>
                            <div class='<%# "fh-avatar " + GetAvatarClass(Eval("Initials").ToString()) %>'><%# Eval("Initials") %></div>
                            <div class="fh-conv-info">
                                <div class="fh-conv-top">
                                    <span class="fh-conv-name"><%# Eval("Name") %></span>
                                    <span class='<%# Convert.ToInt32(Eval("UnreadCount")) > 0 ? "fh-conv-time unread" : "fh-conv-time" %>'><%# Eval("LastTime") %></span>
                                </div>
                                <div class="fh-conv-bottom">
                                    <span class="fh-conv-preview"><%# Eval("LastMessage") %></span>
                                    <asp:PlaceHolder runat="server" Visible='<%# Convert.ToInt32(Eval("UnreadCount")) > 0 %>'>
                                        <span class="fh-unread-badge"><%# Eval("UnreadCount") %></span>
                                    </asp:PlaceHolder>
                                </div>
                            </div>
                        </asp:LinkButton>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Label ID="lblNoUsers" runat="server" Visible="false" Text="No active conversations." CssClass="fh-conv-preview" Style="padding:10px; display:block;"></asp:Label>
            </div>
        </div>

        <!-- ============ CHAT AREA ============ -->
        <div class="fh-chat">

            <!-- WELCOME SCREEN (shown when no conversation selected) -->
            <asp:Panel ID="pnlWelcome" runat="server" CssClass="fh-welcome">
                <div class="fh-welcome-icon">💬</div>
                <h2>Your conversations start here</h2>
                <p>Select a conversation to view messages.</p>
                <a class="fh-welcome-btn" href="BrowseProjects.aspx">Find freelancers</a>
            </asp:Panel>

            <!-- ACTIVE CHAT -->
            <asp:UpdatePanel ID="upChat" runat="server" UpdateMode="Conditional" ClientIDMode="Static">
                <ContentTemplate>
                    <asp:Panel ID="pnlChatPopup" runat="server" Visible="false" CssClass="fh-chat-panel">

                        <!-- Chat header (fixed) -->
                        <div class="fh-chat-head">
                            <asp:LinkButton ID="btnBack" runat="server" CssClass="fh-icon-btn fh-back-btn" OnClick="btnCloseChat_Click" CausesValidation="false" title="Back">←</asp:LinkButton>
                            <asp:LinkButton ID="btnOpenHeaderModal" runat="server" CssClass="fh-chat-head-user" OnClick="btnToggleDetails_Click" title="View Profile &amp; Shared Files">
                                <div class="fh-avatar avatar-rt"><asp:Label ID="lblChatInitials" runat="server" Text="--"></asp:Label></div>
                                <div>
                                    <div class="fh-chat-head-name"><asp:Label ID="lblChatName" runat="server" Text="Select a conversation"></asp:Label></div>
                                    <div class="fh-chat-head-status">
                                        <span id="statusDot" runat="server" class="status-dot offline"></span>
                                        <asp:Label ID="lblPartnerStatus" runat="server" Text="Offline"></asp:Label>
                                    </div>
                                </div>
                            </asp:LinkButton>

                            <div class="fh-head-actions">
                                <asp:LinkButton ID="btnViewProject" runat="server" CssClass="fh-view-project" OnClick="btnToggleDetails_Click" CausesValidation="false">View project</asp:LinkButton>
                                <a href="javascript:void(0);" class="fh-icon-btn" onclick="toggleDetails();return false;" title="Project details">ⓘ</a>
                                <asp:LinkButton ID="btnInfoIcon" runat="server" CssClass="fh-icon-btn" OnClick="btnToggleDetails_Click" title="Contact info" style="display:none;">i</asp:LinkButton>
                            </div>
                        </div>

                        <!-- Project sub-bar -->
                        <asp:Panel ID="pnlProjectBar" runat="server" CssClass="fh-project-bar" Visible="false">
                            <span>📁</span>
                            <span class="proj-name"><asp:Label ID="lblProjectBarTitle" runat="server" /></span>
                            <span class="fh-dot-green"></span>
                            <span><asp:Label ID="lblProjectBarStatus" runat="server" /></span>
                        </asp:Panel>

                        <!-- Messages — ONLY this scrolls -->
                        <div id="fhMessages" class="fh-messages">
                            <div class="fh-day">Today</div>
                            <asp:Repeater ID="rptMessages" runat="server">
                                <ItemTemplate>
                                    <div class='<%# Convert.ToInt32(Eval("senderID")) == CurrentUserId ? "fh-row sent" : "fh-row recv" %>'>
                                        <asp:PlaceHolder runat="server" Visible='<%# Convert.ToInt32(Eval("senderID")) != CurrentUserId %>'>
                                            <div class="fh-row-avatar"><asp:Label runat="server" Text='<%# lblChatInitials.Text %>' /></div>
                                        </asp:PlaceHolder>
                                        <div class="fh-bubble">
                                            <%# Server.HtmlEncode(Convert.ToString(Eval("content"))) %>

                                            <asp:PlaceHolder ID="phAttachment" runat="server" Visible='<%# Eval("attachmentUrl") != DBNull.Value && !string.IsNullOrEmpty(Eval("attachmentUrl").ToString()) %>'>
                                                <asp:PlaceHolder ID="phAttachmentLink" runat="server" Visible='<%# AttachmentExists(Eval("attachmentUrl")) %>'>
                                                    <div class="fh-file-card">
                                                        <span class="fh-file-ic">📄</span>
                                                        <div class="fh-file-meta">
                                                            <div class="fh-file-name"><%# System.IO.Path.GetFileName(Eval("attachmentUrl").ToString()) %></div>
                                                            <div class="fh-file-sub">Attachment</div>
                                                        </div>
                                                        <a class="fh-file-dl" href='<%# ResolveAttachmentUrl(Eval("attachmentUrl")) %>' target="_blank" title="Download">⬇</a>
                                                    </div>
                                                </asp:PlaceHolder>
                                                <asp:PlaceHolder ID="phAttachmentMissing" runat="server" Visible='<%# !AttachmentExists(Eval("attachmentUrl")) %>'>
                                                    <div class="fh-file-missing" title='<%# Eval("attachmentUrl") %>'>📎 Attachment unavailable</div>
                                                </asp:PlaceHolder>
                                            </asp:PlaceHolder>

                                            <span class="fh-bubble-time">
                                                <%# TimeHelper.ToSast(Eval("timeStamp")).ToString("HH:mm") %>
                                                <asp:PlaceHolder ID="phReadReceipt" runat="server" Visible='<%# Convert.ToInt32(Eval("senderID")) == CurrentUserId %>'>
                                                    <span class='<%# Eval("status").ToString() == "Read" ? "ticks-blue" : "ticks-gray" %>'><%# Eval("status").ToString() == "Read" ? "✓✓" : "✓" %></span>
                                                </asp:PlaceHolder>
                                            </span>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <!-- Input (fixed) -->
                        <div class="fh-input-wrap">
                            <asp:Panel ID="pnlChatInput" runat="server" DefaultButton="btnSend" CssClass="fh-input-row">
                                <label for="<%= fileUploadControl.ClientID %>" class="fh-attach" title="Attach file">📎</label>
                                <asp:FileUpload ID="fileUploadControl" runat="server" CssClass="fh-file-hidden" onchange="showSelectedFileName(this);" />
                                <asp:TextBox ID="txtMessage" runat="server" CssClass="fh-msg-input" placeholder="Type your message..."></asp:TextBox>
                                <asp:Button ID="btnSend" runat="server" Text="➤" CssClass="fh-send" OnClick="btnSend_Click" />
                            </asp:Panel>
                            <asp:Label ID="lblAttachedFileName" runat="server" CssClass="fh-attach-preview"></asp:Label>
                        </div>
                    </asp:Panel>
                </ContentTemplate>
                <Triggers>
                    <asp:PostBackTrigger ControlID="btnSend" />
                </Triggers>
            </asp:UpdatePanel>
        </div>

        <!-- ============ PROJECT DETAILS PANEL (collapsible) ============ -->
        <asp:Panel ID="pnlProjectDetails" runat="server" ClientIDMode="Static" CssClass="fh-details" Visible="false">
            <div class="fh-details-head">
                <span class="fh-details-title">Project details</span>
                <a href="javascript:void(0);" class="fh-icon-btn" onclick="toggleDetails();return false;" title="Close">✕</a>
            </div>
            <div class="fh-details-body">
                <div class="fh-details-project"><asp:Label ID="lblDetailsProjectTitle" runat="server" Text="No active project" /></div>
                <div class="fh-details-status"><span class="fh-dot-green"></span><asp:Label ID="lblDetailsProjectStatus" runat="server" Text="—" /></div>

                <div class="fh-details-sub">SHARED FILES</div>
                <asp:Repeater ID="rptSharedFiles" runat="server">
                    <ItemTemplate>
                        <div class="fh-file-card" style="margin-bottom:10px;">
                            <span class="fh-file-ic">📄</span>
                            <div class="fh-file-meta">
                                <div class="fh-file-name"><%# System.IO.Path.GetFileName(Eval("attachmentUrl").ToString()) %></div>
                                <div class="fh-file-sub"><%# TimeHelper.ToSast(Eval("timeStamp")).ToString("dd MMM yyyy") %></div>
                            </div>
                            <asp:PlaceHolder runat="server" Visible='<%# AttachmentExists(Eval("attachmentUrl")) %>'>
                                <a class="fh-file-dl" href='<%# ResolveAttachmentUrl(Eval("attachmentUrl")) %>' target="_blank" title="Download">⬇</a>
                            </asp:PlaceHolder>
                            <asp:PlaceHolder runat="server" Visible='<%# !AttachmentExists(Eval("attachmentUrl")) %>'>
                                <span class="fh-file-missing">N/A</span>
                            </asp:PlaceHolder>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Label ID="lblNoSharedFiles" runat="server" Visible="false" Text="No shared files yet." Style="font-size:13px; color:#9ca3af;" />
            </div>
        </asp:Panel>
    </div>

    <!-- CONTACT DETAILS & SHARED FILES MODAL (kept for the (i) / View project button) -->
    <asp:Panel ID="pnlUserDetailsModal" runat="server" CssClass="modal-overlay" Visible="false">
        <div class="modal-pop-card">
            <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #e0e8e2; padding-bottom:12px; margin-bottom:16px;">
                <h3 style="margin:0; color:#173f2c; font-size:18px;">Contact Info &amp; Shared Files</h3>
                <asp:LinkButton ID="btnCloseDetails" runat="server" OnClick="btnCloseDetails_Click" Style="color:#888; text-decoration:none; font-size:20px; font-weight:bold; cursor:pointer;">✕</asp:LinkButton>
            </div>
            <div style="background:#f9fbf9; border:1px solid #e0e8e2; border-radius:8px; padding:14px; margin-bottom:18px; display:grid; grid-template-columns:1fr 1fr; gap:10px; font-size:13px; color:#243328;">
                <div><strong>Full Name:</strong> <asp:Label ID="lblDetailName" runat="server" /></div>
                <div><strong>Account Type:</strong> <asp:Label ID="lblDetailUserType" runat="server" /></div>
                <div><strong>Email:</strong> <asp:Label ID="lblDetailEmail" runat="server" /></div>
                <div><strong>Contact:</strong> <asp:Label ID="lblDetailContact" runat="server" /></div>
                <div style="grid-column:span 2;"><strong>Rating Score:</strong> ⭐ <asp:Label ID="lblDetailRating" runat="server" /> / 5.0</div>
            </div>
            <div style="text-align:right;">
                <asp:Button ID="btnCloseModalBtn" runat="server" Text="Close" OnClick="btnCloseDetails_Click" CausesValidation="false" Style="background:#173f2c; color:white; border:none; padding:8px 18px; border-radius:6px; font-weight:600; cursor:pointer;" />
            </div>
        </div>
    </asp:Panel>

    <!-- Rating Modal -->
    <asp:Panel ID="pnlRatingModal" runat="server" CssClass="modal-overlay" Visible="false">
        <div class="modal-pop-card">
            <div style="border-bottom:1px solid #e5e7eb; padding-bottom:12px; margin-bottom:16px;">
                <h3 style="margin:0; color:#173f2c; font-size:18px;">Project completed</h3>
                <p style="margin:4px 0 0 0; font-size:13px; color:#6b7280;">Messaging has ended. Please rate your experience.</p>
            </div>
            <div style="font-size:13px; color:#374151;">
                <label style="font-weight:600; display:block; color:#173f2c;">Rating (1 to 5 Stars):</label>
                <asp:DropDownList ID="ddlRatingStars" runat="server" CssClass="rating-dropdown">
                    <asp:ListItem Text="5 Stars - Excellent" Value="5" Selected="True" />
                    <asp:ListItem Text="4 Stars - Very Good" Value="4" />
                    <asp:ListItem Text="3 Stars - Good" Value="3" />
                    <asp:ListItem Text="2 Stars - Fair" Value="2" />
                    <asp:ListItem Text="1 Star - Poor" Value="1" />
                </asp:DropDownList>
                <br /><br />
                <label style="font-weight:600; display:block; color:#173f2c;">Feedback Comment (Optional):</label>
                <asp:TextBox ID="txtRatingComment" runat="server" TextMode="MultiLine" Rows="3" CssClass="rating-comment-input" placeholder="Write a short review..."></asp:TextBox>
            </div>
            <div style="margin-top:20px; text-align:right;">
                <asp:Button ID="btnSubmitRating" runat="server" Text="Submit Rating" CssClass="submit-rating-button" OnClick="btnSubmitRating_Click" />
                <asp:Button ID="btnCloseModal" runat="server" Text="Close" CssClass="close-modal-button" OnClick="btnCloseModal_Click" CausesValidation="false" />
            </div>
        </div>
    </asp:Panel>

</asp:Content>

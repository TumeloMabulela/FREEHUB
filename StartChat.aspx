<%@ Page Title="Messages"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="StartChat.aspx.cs"
    Inherits="FreeHubProject.StartChat" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* ====================================================================
           FreeHUB Messages — modern 3-column messaging workspace.
           Palette: gradient #118A9B→#239E78→#65CA43 | green #0B8F43 / hover #067235
           bg #F5F8F7 | card #FFFFFF | text #192B40 | subtext #6B7280
           border #E5ECEA | light-green highlight #E8F7EC
           ==================================================================== */
        .fh-msg-root {
            font-family: 'Segoe UI', Inter, Arial, sans-serif;
            display: flex;
            gap: 16px;
            height: calc(100vh - 170px);
            min-height: 540px;
            background: transparent;
            border: none;
            border-radius: 0;
            overflow: visible;
            box-shadow: none;
            color: #192B40;
        }

        .fh-alert {
            background-color: #E8F7EC;
            color: #0B8F43;
            padding: 10px 16px;
            border-radius: 10px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 12px;
            border: 1px solid #c7e8d0;
            font-family: 'Segoe UI', Inter, Arial, sans-serif;
        }

        /* ===== SIDEBAR (≈340px) — white card ===== */
        .fh-sidebar {
            width: 340px;
            flex-shrink: 0;
            border: 1px solid #E5ECEA;
            border-radius: 16px;
            display: flex;
            flex-direction: column;
            background: #FFFFFF;
            min-height: 0;
            box-shadow: 0 1px 3px rgba(16, 40, 28, 0.05);
            overflow: hidden;
        }

        .fh-sidebar-head { padding: 20px 18px 12px 18px; }
        .fh-sidebar-title-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
        .fh-sidebar-title { margin: 0; font-size: 24px; font-weight: 800; color: #192B40; }
        .fh-compose-btn {
            width: 36px; height: 36px; border-radius: 10px;
            display: inline-flex; align-items: center; justify-content: center;
            background: #E8F7EC; color: #0B8F43; border: 1px solid #cdeed8;
            font-size: 16px; text-decoration: none; cursor: pointer;
            transition: background .2s ease;
        }
        .fh-compose-btn:hover { background: #d6f1e0; }

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
            padding: 11px 12px 11px 34px;
            border: 1px solid #E5ECEA;
            border-radius: 12px;
            font-size: 13px;
            background: #F5F8F7;
            font-family: 'Segoe UI', Inter, Arial, sans-serif;
            transition: border-color .2s ease, box-shadow .2s ease, background .2s ease;
        }
        .fh-search-input:focus { outline: none; border-color: #0B8F43; background: #fff; box-shadow: 0 0 0 3px rgba(11,143,67,.12); }
        .fh-search-btn { display: none; } /* search runs on text change / enter */

        /* Segmented filter (All / Unread) — pill toggle */
        .fh-filters {
            display: flex;
            background: #EEF4F0;
            border-radius: 12px;
            padding: 4px;
            gap: 4px;
            margin-bottom: 10px;
        }
        .fh-filter {
            flex: 1;
            text-align: center;
            padding: 8px 6px;
            font-size: 13px;
            font-weight: 600;
            color: #6B7280;
            border-radius: 9px;
            cursor: pointer;
            text-decoration: none;
            transition: background .2s ease, color .2s ease, box-shadow .2s ease;
        }
        .fh-filter.active { background: #FFFFFF; color: #0B8F43; box-shadow: 0 1px 2px rgba(16,40,28,.08); }
        /* Clients/Freelancers kept as secondary chips below */
        .fh-filter-sub {
            display: flex; gap: 8px; margin: 2px 0 2px 0;
        }
        .fh-filter-chip {
            font-size: 11.5px; font-weight: 600; color: #6B7280;
            border: 1px solid #E5ECEA; border-radius: 16px;
            padding: 5px 12px; cursor: pointer; text-decoration: none; background:#fff;
            transition: background .2s ease, color .2s ease, border-color .2s ease;
        }
        .fh-filter-chip:hover { border-color: #cdeed8; }
        .fh-filter-chip.active { background: #E8F7EC; color: #0B8F43; border-color: #bfe8cd; }

        .fh-section-label { font-size: 11px; font-weight: 700; color: #9aa6a0; letter-spacing: .4px; padding: 8px 18px 4px 18px; }

        /* Search results dropdown */
        .fh-search-results {
            margin: 0 14px 8px 14px;
            background: #F5F8F7; border: 1px solid #E5ECEA; border-radius: 12px;
            max-height: 220px; overflow-y: auto;
        }
        .fh-search-result-item {
            display: flex; justify-content: space-between; align-items: center;
            padding: 10px 12px; text-decoration: none; color: #192B40;
            border-bottom: 1px solid #e9efeb;
        }
        .fh-search-result-item:hover { background: #E8F7EC; }

        /* Conversation list — scrolls independently */
        .fh-conv-list {
            flex: 1;
            overflow-y: auto;
            padding: 2px 10px 12px 10px;
            min-height: 0;
        }
        .fh-conv {
            display: flex; align-items: center; gap: 12px;
            padding: 12px 10px; border-radius: 12px;
            text-decoration: none; color: inherit; cursor: pointer;
            border-left: 3px solid transparent;
            transition: background .2s ease;
        }
        .fh-conv:hover { background: #F5F8F7; }
        .fh-conv.active { background: #E8F7EC; border-left-color: #0B8F43; }
        .fh-conv.active .fh-conv-name { color: #0B8F43; }

        .fh-avatar {
            width: 44px; height: 44px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 14px; flex-shrink: 0;
        }
        .avatar-rt { background:#d8f3dc; color:#2d6a4f; }
        .avatar-mt { background:#f3e8ff; color:#7e22ce; }
        .avatar-mu { background:#fef3c7; color:#b45309; }
        .avatar-ml { background:#dcfce7; color:#15803d; }

        .fh-conv-info { flex: 1; overflow: hidden; }
        .fh-conv-top { display: flex; justify-content: space-between; align-items: center; }
        .fh-conv-name { font-weight: 700; font-size: 14px; color: #192B40; }
        .fh-conv-time { font-size: 11px; color: #9ca3af; flex-shrink: 0; margin-left: 8px; }
        .fh-conv-time.unread { color: #0B8F43; font-weight: 700; }
        .fh-conv-bottom { display: flex; align-items: center; justify-content: space-between; gap: 8px; margin-top: 3px; }
        .fh-conv-preview { font-size: 12.5px; color: #6B7280; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex: 1; }
        .fh-unread-badge {
            background: #0B8F43; color: #fff; font-size: 11px; font-weight: 700;
            min-width: 20px; height: 20px; border-radius: 10px; padding: 0 6px;
            display: inline-flex; align-items: center; justify-content: center; flex-shrink: 0;
        }

        /* ===== CHAT AREA (flexible) — white card ===== */
        .fh-chat {
            flex: 1;
            display: flex;
            flex-direction: column;
            min-width: 0;
            min-height: 0;
            background: #FFFFFF;
            border: 1px solid #E5ECEA;
            border-radius: 16px;
            box-shadow: 0 1px 3px rgba(16, 40, 28, 0.05);
            overflow: hidden;
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
            background: #FFFFFF;
        }
        .fh-welcome-icon {
            width: 92px; height: 92px; border-radius: 24px;
            display: flex; align-items: center; justify-content: center;
            font-size: 44px; color: #0B8F43; margin-bottom: 18px;
            background: #E8F7EC; border: 2px solid #d9f2e1;
        }
        .fh-welcome h2 { margin: 0 0 6px 0; font-size: 26px; color: #192B40; }
        .fh-welcome p { margin: 0 0 18px 0; color: #6B7280; font-size: 14px; }
        .fh-welcome-btn {
            background: #0B8F43;
            color: #fff; border: none; border-radius: 12px;
            padding: 12px 22px; font-size: 14px; font-weight: 700;
            cursor: pointer; text-decoration: none; display: inline-block;
            font-family: 'Segoe UI', Inter, Arial, sans-serif;
            transition: background .2s ease;
        }
        .fh-welcome-btn:hover { background: #067235; }

        /* Chat header (fixed) */
        .fh-chat-head {
            display: flex; align-items: center; justify-content: space-between;
            padding: 14px 18px; background: #FFFFFF; border-bottom: 1px solid #E5ECEA;
            flex-shrink: 0;
        }
        .fh-chat-head-user { display: flex; align-items: center; gap: 12px; text-decoration: none; color: inherit; }
        .fh-chat-head-name { font-weight: 800; color: #192B40; font-size: 15px; }
        .fh-chat-head-status { font-size: 12px; color: #6B7280; display: flex; align-items: center; }
        .status-dot {
            width: 8px; height: 8px; background: #22c55e; border-radius: 50%;
            display: inline-block; margin-right: 5px; box-shadow: 0 0 0 3px rgba(34,197,94,.18);
        }
        .status-dot.offline { background: #ef4444; box-shadow: 0 0 0 3px rgba(239,68,68,.18); }
        .fh-head-actions { display: flex; align-items: center; gap: 10px; }
        .fh-view-project {
            display: inline-flex; align-items: center; gap: 6px;
            border: 1px solid #E5ECEA; background: #fff; color: #192B40;
            border-radius: 10px; padding: 8px 14px; font-size: 13px; font-weight: 700;
            cursor: pointer; text-decoration: none; transition: background .2s ease, border-color .2s ease;
        }
        .fh-view-project:hover { background: #E8F7EC; border-color: #cdeed8; color: #0B8F43; }
        .fh-icon-btn {
            width: 38px; height: 38px; border-radius: 10px; border: 1px solid #E5ECEA;
            background: #fff; color: #6B7280; display: inline-flex; align-items: center;
            justify-content: center; cursor: pointer; text-decoration: none; font-size: 15px;
            transition: background .2s ease;
        }
        .fh-icon-btn:hover { background: #F5F8F7; }

        /* Project sub-bar under header */
        .fh-project-bar {
            display: flex; align-items: center; gap: 8px;
            padding: 9px 18px; background: #F5F8F7; border-bottom: 1px solid #E5ECEA;
            font-size: 13px; color: #4b5b51; flex-shrink: 0;
        }
        .fh-project-bar .proj-name { font-weight: 700; color: #192B40; }
        .fh-dot-green { width: 8px; height: 8px; border-radius: 50%; background: #0B8F43; display: inline-block; }

        /* Messages — ONLY this scrolls. Plain block flow; rows use text-align to
           place inline-block bubbles left (received) or right (sent). */
        .fh-messages {
            flex: 1; overflow-y: auto; min-height: 0;
            padding: 18px 24px;
            display: block;
            background: #F5F8F7;
        }
        .fh-day {
            display: table; margin: 4px auto 12px;
            background: #E8F7EC; color: #4b5b51; font-size: 12px; font-weight: 600;
            padding: 5px 14px; border-radius: 14px;
        }

        /* ====================================================================
           CHAT THREAD — rebuilt from scratch (v2). Fresh class names (fhb-*) so
           no older cached rule can apply. !important guarantees these win even if
           a stale stylesheet is still in the browser cache. Same page format:
           received left, sent right; bubbles size to their text only.
           ==================================================================== */

        /* Row: a full-width line. text-align decides which side the bubble sits. */
        .fhb-row { display: block !important; width: 100% !important; margin: 0 0 10px 0 !important; }
        .fhb-row.recv { text-align: left !important; }
        .fhb-row.sent { text-align: right !important; }

        .fhb-avatar {
            display: inline-flex !important; vertical-align: bottom !important;
            width: 28px !important; height: 28px !important; border-radius: 50% !important;
            align-items: center !important; justify-content: center !important;
            font-size: 10px !important; font-weight: 700 !important;
            background: #d8f3dc !important; color: #2d6a4f !important; margin-right: 6px !important;
        }

        /* Bubble: shrinks to its text. No min-width / min-height = compact. */
        .fhb-bubble {
            display: inline-block !important;
            width: auto !important;
            max-width: min(55%, 460px) !important;
            min-width: 0 !important;
            min-height: 0 !important;
            height: auto !important;
            box-sizing: border-box !important;
            padding: 7px 11px !important;
            margin: 0 !important;
            border-radius: 14px !important;
            font-size: 14px !important; line-height: 1.35 !important; color: #192B40 !important;
            box-shadow: 0 1px 2px rgba(16,40,28,.06) !important;
            white-space: pre-wrap !important; overflow-wrap: anywhere !important; word-break: break-word !important;
            text-align: left !important; vertical-align: bottom !important;
        }
        /* Normalise anything the global stylesheet might inject inside bubbles. */
        .fhb-bubble, .fhb-text, .fhb-meta { max-width: 100% !important; }
        .fhb-text { display: block !important; min-height: 0 !important; height: auto !important; padding: 0 !important; }
        .fhb-row.recv .fhb-bubble { background: #FFFFFF !important; border: 1px solid #E5ECEA !important; border-radius: 3px 14px 14px 14px !important; }
        .fhb-row.sent .fhb-bubble { background: #E8F7EC !important; border: 1px solid transparent !important; border-radius: 14px 3px 14px 14px !important; }

        /* Text line + compact meta (time + ticks) at the bottom-right. */
        .fhb-text { margin: 0 0 2px 0 !important; }
        .fhb-text:empty { display: none !important; }
        .fhb-meta {
            display: flex !important; justify-content: flex-end !important; align-items: center !important;
            gap: 4px !important; font-size: 10.5px !important; color: #8b9a90 !important; line-height: 1 !important;
        }
        .fhb-time { font-size: 10.5px !important; color: #8b9a90 !important; white-space: nowrap !important; }
        .ticks-blue { color: #0B8F43 !important; }
        .ticks-gray { color: #8b9a90 !important; }

        /* File card inside a bubble */
        .fh-file-card {
            display: flex; align-items: center; gap: 10px;
            background: #FFFFFF; border: 1px solid #E5ECEA; border-radius: 12px;
            padding: 8px 10px; margin-top: 2px; min-width: 200px;
        }
        .fh-file-ic { font-size: 22px; }
        .fh-file-meta { flex: 1; overflow: hidden; }
        .fh-file-name { font-weight: 700; font-size: 13px; color: #192B40; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .fh-file-sub { font-size: 11px; color: #8b9a90; }
        .fh-file-dl { color: #0B8F43; font-size: 18px; text-decoration: none; flex-shrink: 0; }
        .fh-file-missing { color: #b91c1c; font-style: italic; font-size: 12px; }

        /* Composer (fixed) */
        .fh-input-wrap { padding: 14px 18px; background: #FFFFFF; border-top: 1px solid #E5ECEA; flex-shrink: 0; }
        .fh-input-row {
            display: flex; align-items: center; gap: 6px;
            background: #F5F8F7; border: 1px solid #E5ECEA; border-radius: 28px;
            padding: 5px 6px 5px 10px;
            transition: border-color .2s ease, box-shadow .2s ease;
        }
        .fh-input-row:focus-within { border-color: #0B8F43; box-shadow: 0 0 0 3px rgba(11,143,67,.10); background: #fff; }
        .fh-attach { width: 38px; height: 38px; display: flex; align-items: center; justify-content: center; color: #6B7280; cursor: pointer; font-size: 17px; border-radius: 50%; transition: background .2s ease; }
        .fh-attach:hover { background: #E8F7EC; }
        .fh-emoji { width: 38px; height: 38px; display: inline-flex; align-items: center; justify-content: center; color: #6B7280; cursor: pointer; font-size: 17px; border-radius: 50%; text-decoration: none; transition: background .2s ease; }
        .fh-emoji:hover { background: #E8F7EC; }
        .fh-file-hidden { display: none; }
        .fh-msg-input { flex: 1; border: none; background: transparent; padding: 10px 8px; font-size: 14px; outline: none; font-family: 'Segoe UI', Inter, Arial, sans-serif; color: #192B40; }
        .fh-send {
            width: 44px; height: 44px; border-radius: 50%; border: none;
            background: #0B8F43; color: #fff;
            font-size: 16px; cursor: pointer; flex-shrink: 0;
            display: inline-flex; align-items: center; justify-content: center;
            transition: background .2s ease;
        }
        .fh-send:hover { background: #067235; }
        .fh-attach-preview { font-size: 12px; color: #0B8F43; margin-top: 6px; padding-left: 10px; display: block; }

        /* ===== PROJECT DETAILS PANEL (≈340px, collapsible) — white card ===== */
        .fh-details {
            width: 340px; flex-shrink: 0;
            border: 1px solid #E5ECEA; background: #FFFFFF;
            border-radius: 16px;
            display: flex; flex-direction: column; min-height: 0;
            overflow-y: auto;
            box-shadow: 0 1px 3px rgba(16, 40, 28, 0.05);
        }
        .fh-details.collapsed { display: none; }
        .fh-details-head {
            display: flex; align-items: center; justify-content: space-between;
            padding: 18px 18px 14px; border-bottom: 1px solid #E5ECEA;
        }
        .fh-details-title { font-size: 17px; font-weight: 800; color: #192B40; }
        .fh-details-body { padding: 16px 18px; }
        .fh-details-sub { font-size: 11px; font-weight: 700; color: #9aa6a0; letter-spacing: .4px; margin: 20px 0 8px 0; display: flex; align-items: center; justify-content: space-between; }
        .fh-details-sub .fh-viewall { font-size: 12px; font-weight: 600; color: #0B8F43; text-decoration: none; letter-spacing: 0; }
        .fh-details-sub .fh-viewall:hover { text-decoration: underline; }

        /* Main project card */
        .fh-proj-card {
            display: flex; align-items: center; gap: 12px;
            padding: 4px 0 2px;
        }
        .fh-proj-folder {
            width: 46px; height: 46px; border-radius: 12px; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            background: #FEF3C7; font-size: 22px;
        }
        .fh-details-project { font-size: 15px; font-weight: 800; color: #192B40; margin-bottom: 4px; }
        .fh-details-status { font-size: 13px; color: #6B7280; display: flex; align-items: center; gap: 6px; }

        /* Info note */
        .fh-info-note {
            display: flex; gap: 10px; align-items: flex-start;
            background: #F5F8F7; border: 1px solid #E5ECEA; border-radius: 12px;
            padding: 12px; margin-top: 14px; font-size: 12.5px; color: #6B7280; line-height: 1.5;
        }
        .fh-info-note .fh-info-ic { color: #0B8F43; flex-shrink: 0; font-size: 15px; }
        .fh-details-btn {
            display: block; width: 100%; box-sizing: border-box; text-align: center;
            background: #0B8F43; color: #fff; border: none; border-radius: 12px;
            padding: 11px 14px; font-size: 13.5px; font-weight: 700; cursor: pointer;
            text-decoration: none; margin-top: 12px; transition: background .2s ease;
        }
        .fh-details-btn:hover { background: #067235; }

        /* Empty-state card (shared files / milestones) */
        .fh-empty-card {
            display: flex; align-items: center; gap: 12px;
            background: #F5F8F7; border: 1px solid #E5ECEA; border-radius: 12px;
            padding: 14px; font-size: 12.5px; color: #6B7280; line-height: 1.4;
        }
        .fh-empty-ic { font-size: 22px; color: #9aa6a0; flex-shrink: 0; }
        .fh-empty-title { font-weight: 700; color: #192B40; font-size: 13px; }

        /* About user block */
        .fh-about {
            display: flex; align-items: center; gap: 12px; margin-top: 4px;
        }
        .fh-about-meta { flex: 1; }
        .fh-about-name { font-weight: 700; font-size: 14px; color: #192B40; }
        .fh-about-sub { font-size: 12px; color: #6B7280; display: flex; align-items: center; gap: 5px; margin-top: 2px; }
        .fh-about-line { font-size: 12.5px; color: #6B7280; display: flex; align-items: center; gap: 7px; margin-top: 8px; }
        .fh-view-profile {
            display: inline-block; margin-top: 12px;
            border: 1px solid #E5ECEA; background: #fff; color: #0B8F43;
            border-radius: 10px; padding: 8px 14px; font-size: 13px; font-weight: 700;
            cursor: pointer; text-decoration: none; transition: background .2s ease;
        }
        .fh-view-profile:hover { background: #E8F7EC; }

        /* ===== Shared modals ===== */
        .modal-overlay {
            position: fixed; top:0; left:0; width:100vw; height:100vh;
            background: rgba(0,0,0,.45); display:flex; align-items:center; justify-content:center; z-index:9999;
        }
        .modal-pop-card { background:#fff; width:90%; max-width:480px; border-radius:16px; padding:24px; box-shadow:0 10px 25px rgba(0,0,0,.2); font-family: 'Segoe UI', Inter, Arial, sans-serif; }
        .rating-dropdown, .rating-comment-input { width:100%; padding:10px 14px; border:1px solid #E5ECEA; border-radius:10px; font-size:13px; margin-top:6px; outline:none; background:#F5F8F7; box-sizing:border-box; }
        .rating-dropdown:focus, .rating-comment-input:focus { border-color:#0B8F43; background:#fff; }
        .submit-rating-button { background:#0B8F43; color:#fff; border:none; padding:10px 20px; border-radius:10px; font-weight:600; font-size:13px; cursor:pointer; }
        .submit-rating-button:hover { background:#067235; }
        .close-modal-button { background:#e5e7eb; color:#374151; border:none; padding:10px 20px; border-radius:10px; font-weight:600; font-size:13px; cursor:pointer; margin-left:8px; }

        /* ===== Responsive ===== */
        .fh-back-btn { display: none; }

        /* Tablet: wider bubble cap for the narrower panel. */
        @media (max-width: 1024px) {
            .fhb-bubble { max-width: 70% !important; }
        }

        /* Tablet: narrow the side columns, hide the right details panel. */
        @media (max-width: 1100px) {
            .fh-sidebar { width: 300px; }
            .fh-details { display: none; }
        }

        /* Mobile: stack to one column; show contacts first, chat on open. */
        @media (max-width: 820px) {
            .fh-msg-root { flex-direction: column; gap: 12px; height: auto; min-height: 0; }
            .fh-details { display: none; }
            .fh-msg-root.chat-open .fh-sidebar { display: none; }
            .fh-msg-root:not(.chat-open) .fh-chat { display: none; }
            .fh-sidebar { width: 100%; height: 70vh; }
            .fh-chat { height: calc(100vh - 170px); }
            .fh-back-btn { display: inline-flex; }
        }

        /* Mobile: largest bubble cap for small screens. */
        @media (max-width: 768px) {
            .fhb-bubble { max-width: 85% !important; }
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
                <div class="fh-sidebar-title-row">
                    <h1 class="fh-sidebar-title">Messages</h1>
                    <a href="BrowseProjects.aspx" class="fh-compose-btn" title="New conversation">&#9998;</a>
                </div>

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
                                <asp:LinkButton ID="btnViewProject" runat="server" CssClass="fh-view-project" OnClick="btnToggleDetails_Click" CausesValidation="false"><span aria-hidden="true">&#128193;</span> View project</asp:LinkButton>
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

                        <!-- Messages — ONLY this scrolls (chat thread rebuilt v2) -->
                        <div id="fhMessages" class="fh-messages">
                            <div class="fh-day">Today</div>
                            <!-- chat-thread-v3 -->
                            <div id="fhbVersion" style="display:none;">v3</div>
                            <asp:Repeater ID="rptMessages" runat="server">
                                <ItemTemplate>
                                    <div class='<%# Convert.ToInt32(Eval("senderID")) == CurrentUserId ? "fhb-row sent" : "fhb-row recv" %>'>
                                        <asp:PlaceHolder runat="server" Visible='<%# Convert.ToInt32(Eval("senderID")) != CurrentUserId %>'>
                                            <span class="fhb-avatar"><asp:Label runat="server" Text='<%# lblChatInitials.Text %>' /></span>
                                        </asp:PlaceHolder>
                                        <div class="fhb-bubble">
                                            <div class="fhb-text"><%# Server.HtmlEncode(Convert.ToString(Eval("content"))) %></div>

                                            <asp:PlaceHolder ID="phAttachment" runat="server" Visible='<%# Eval("attachmentUrl") != DBNull.Value && !string.IsNullOrEmpty(Eval("attachmentUrl").ToString()) %>'>
                                                <asp:PlaceHolder ID="phAttachmentLink" runat="server" Visible='<%# AttachmentExists(Eval("attachmentUrl")) %>'>
                                                    <div class="fh-file-card">
                                                        <span class="fh-file-ic">📄</span>
                                                        <div class="fh-file-meta">
                                                            <div class="fh-file-name"><%# OriginalFileName(Eval("attachmentUrl")) %></div>
                                                            <div class="fh-file-sub">Attachment</div>
                                                        </div>
                                                        <a class="fh-file-dl" href='<%# ResolveAttachmentUrl(Eval("attachmentUrl")) %>' target="_blank" title="Download">⬇</a>
                                                    </div>
                                                </asp:PlaceHolder>
                                                <asp:PlaceHolder ID="phAttachmentMissing" runat="server" Visible='<%# !AttachmentExists(Eval("attachmentUrl")) %>'>
                                                    <div class="fh-file-missing" title='<%# Eval("attachmentUrl") %>'>📎 Attachment unavailable</div>
                                                </asp:PlaceHolder>
                                            </asp:PlaceHolder>

                                            <div class="fhb-meta">
                                                <span class="fhb-time"><%# TimeHelper.ToSast(Eval("timeStamp")).ToString("HH:mm") %></span>
                                                <asp:PlaceHolder ID="phReadReceipt" runat="server" Visible='<%# Convert.ToInt32(Eval("senderID")) == CurrentUserId %>'>
                                                    <span class='<%# Eval("status").ToString() == "Read" ? "ticks-blue" : "ticks-gray" %>'><%# Eval("status").ToString() == "Read" ? "✓✓" : (Eval("status").ToString() == "Delivered" ? "✓✓" : "✓") %></span>
                                                </asp:PlaceHolder>
                                            </div>
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
                                <a href="javascript:void(0);" class="fh-emoji" title="Emoji" onclick="return false;">&#128578;</a>
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

                <!-- Main project card -->
                <div class="fh-proj-card">
                    <div class="fh-proj-folder" aria-hidden="true">📁</div>
                    <div>
                        <div class="fh-details-project"><asp:Label ID="lblDetailsProjectTitle" runat="server" Text="No active project" /></div>
                        <div class="fh-details-status"><span class="fh-dot-green"></span><asp:Label ID="lblDetailsProjectStatus" runat="server" Text="—" /></div>
                    </div>
                </div>

                <!-- Info note + create project (shown when there's no linked active project) -->
                <asp:Panel ID="pnlNoProjectNote" runat="server" Visible="false">
                    <div class="fh-info-note">
                        <span class="fh-info-ic" aria-hidden="true">&#9432;</span>
                        <span>This conversation isn't linked to an active project yet. Once a project is created, details will appear here.</span>
                    </div>
                    <a href="PostProject.aspx" class="fh-details-btn">Create a project</a>
                </asp:Panel>

                <!-- Shared files -->
                <div class="fh-details-sub">
                    <span>SHARED FILES</span>
                    <a href="javascript:void(0);" class="fh-viewall" onclick="return false;">View all</a>
                </div>
                <asp:Repeater ID="rptSharedFiles" runat="server">
                    <ItemTemplate>
                        <asp:PlaceHolder runat="server" Visible='<%# AttachmentExists(Eval("attachmentUrl")) %>'>
                            <a class="fh-file-card fh-file-card-link" href='<%# ResolveAttachmentUrl(Eval("attachmentUrl")) %>' target="_blank" title="Open file" style="margin-bottom:10px;">
                                <span class="fh-file-ic">📄</span>
                                <div class="fh-file-meta">
                                    <div class="fh-file-name"><%# OriginalFileName(Eval("attachmentUrl")) %></div>
                                    <div class="fh-file-sub"><%# TimeHelper.ToSast(Eval("timeStamp")).ToString("dd MMM yyyy") %></div>
                                </div>
                                <span class="fh-file-dl">⬇</span>
                            </a>
                        </asp:PlaceHolder>
                        <asp:PlaceHolder runat="server" Visible='<%# !AttachmentExists(Eval("attachmentUrl")) %>'>
                            <div class="fh-file-card" style="margin-bottom:10px;">
                                <span class="fh-file-ic">📄</span>
                                <div class="fh-file-meta">
                                    <div class="fh-file-name"><%# OriginalFileName(Eval("attachmentUrl")) %></div>
                                    <div class="fh-file-sub"><%# TimeHelper.ToSast(Eval("timeStamp")).ToString("dd MMM yyyy") %></div>
                                </div>
                                <span class="fh-file-missing">N/A</span>
                            </div>
                        </asp:PlaceHolder>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoSharedFiles" runat="server" CssClass="fh-empty-card" Visible="false">
                    <span class="fh-empty-ic" aria-hidden="true">📄</span>
                    <span><span class="fh-empty-title">No shared files yet.</span><br />Files shared in this conversation will appear here.</span>
                </asp:Panel>
                <%-- Preserved for backward compatibility with existing code paths. --%>
                <asp:Label ID="lblNoSharedFiles" runat="server" Visible="false" Text="No shared files yet." Style="display:none;" />

                <!-- Project milestones -->
                <div class="fh-details-sub"><span>&#9733; PROJECT MILESTONES</span></div>
                <div class="fh-empty-card">
                    <span class="fh-empty-ic" aria-hidden="true">📄</span>
                    <span><span class="fh-empty-title">Not available</span><br />Milestones will be shown once a project is created.</span>
                </div>

                <!-- About this user -->
                <div class="fh-details-sub"><span>&#128100; ABOUT THIS CONTACT</span></div>
                <div class="fh-about">
                    <div class="fh-avatar avatar-rt"><asp:Label ID="lblAboutInitials" runat="server" Text="--" /></div>
                    <div class="fh-about-meta">
                        <div class="fh-about-name"><asp:Label ID="lblAboutName" runat="server" Text="—" /></div>
                        <div class="fh-about-sub"><span class="fh-dot-green"></span><asp:Label ID="lblAboutStatus" runat="server" Text="Offline" /></div>
                    </div>
                </div>
                <div class="fh-about-line"><span aria-hidden="true">📍</span><asp:Label ID="lblAboutCountry" runat="server" Text="South Africa" /></div>
                <div class="fh-about-line"><span aria-hidden="true">🏷️</span><asp:Label ID="lblAboutRole" runat="server" Text="—" /></div>
                <asp:LinkButton ID="btnViewProfile" runat="server" CssClass="fh-view-profile" OnClick="btnToggleDetails_Click" CausesValidation="false">View profile</asp:LinkButton>
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
                <asp:TextBox ID="txtRatingComment" runat="server" TextMode="MultiLine" Rows="3" CssClass="rating-comment-input" data-fh-format="true" placeholder="Write a short review..."></asp:TextBox>
            </div>
            <div style="margin-top:20px; text-align:right;">
                <asp:Button ID="btnSubmitRating" runat="server" Text="Submit Rating" CssClass="submit-rating-button" OnClick="btnSubmitRating_Click" />
                <asp:Button ID="btnCloseModal" runat="server" Text="Close" CssClass="close-modal-button" OnClick="btnCloseModal_Click" CausesValidation="false" />
            </div>
        </div>
    </asp:Panel>

    <%-- Shared paragraph-formatting helper (same as Project Description). --%>
    <script src="<%= ResolveUrl("~/fhText.js") %>?v=1" type="text/javascript"></script>

</asp:Content>

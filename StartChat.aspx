<%@ Page Title="Messages"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="StartChat.aspx.cs"
    Inherits="FreeHubProject.StartChat" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* ================= FreeHub Messages — 3-column workspace =================
           Fits between the fixed site header and footer with NO outer page scrollbar.
           Only the conversation list, the message history and (when needed) the right
           panel scroll internally. Colours stay on the FreeHub teal→green palette with
           white cards, pale-grey backgrounds and restrained green accents. */

        .fh-msg-root {
            font-family: Arial, Helvetica, sans-serif;
            display: flex;
            /* Fill the space between the site header and footer. No min-height forcing it
               taller than the viewport (that produced an outer page scrollbar). Only the
               inner panels scroll. */
            height: calc(100vh - 172px);
            min-height: 0;
            background: #ffffff;
            border: 1px solid #e5e9e6;
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 10px 28px rgba(16, 40, 28, 0.07);
        }

        /* ===== LEFT: conversation list (≈320px, stationary head, scrolling body) ===== */
        .fh-sidebar {
            width: 320px; flex-shrink: 0;
            border-right: 1px solid #e5e9e6;
            display: flex; flex-direction: column;
            background: #ffffff; min-height: 0;
        }
        .fh-sidebar-head { padding: 18px 18px 10px 18px; flex-shrink: 0; }
        .fh-sidebar-title { margin: 0 0 12px 0; font-size: 22px; font-weight: 800; color: #10261c; display: flex; align-items: center; gap: 8px; }
        /* Small unread-count badge next to the Messages heading (real unread total). */
        .fh-head-badge {
            display: inline-flex; align-items: center; justify-content: center;
            min-width: 22px; height: 22px; padding: 0 7px; border-radius: 11px;
            background: #e6f6ec; color: #12833f; font-size: 12px; font-weight: 800;
        }

        .fh-search { position: relative; margin-bottom: 12px; }
        .fh-search .fh-search-icon {
            position: absolute; left: 12px; top: 50%; transform: translateY(-50%);
            color: #9aa6a0; font-size: 14px; pointer-events: none;
        }
        .fh-search-input {
            width: 100%; box-sizing: border-box;
            padding: 10px 12px 10px 34px;
            border: 1px solid #e2e8e4; border-radius: 10px;
            font-size: 13px; background: #f7faf8;
            font-family: Arial, Helvetica, sans-serif;
        }
        .fh-search-input:focus { outline: none; border-color: #1f9d55; background: #fff; box-shadow: 0 0 0 3px rgba(31,157,85,.12); }
        .fh-search-btn { display: none; }

        /* Segmented filter: All / Unread / Ended */
        .fh-filters {
            display: flex; background: #eef4f0; border-radius: 10px;
            padding: 3px; gap: 3px; margin-bottom: 8px;
        }
        .fh-filter {
            flex: 1; text-align: center; padding: 7px 6px;
            font-size: 13px; font-weight: 600; color: #5a6e62;
            border-radius: 8px; cursor: pointer; text-decoration: none;
        }
        .fh-filter.active { background: #d9f2e1; color: #12833f; }

        /* Role contact filter (preserved) */
        .fh-contact-filter {
            width: 100%; box-sizing: border-box;
            padding: 8px 10px; border: 1px solid #e2e8e4; border-radius: 10px;
            font-size: 12.5px; color: #4b5b51; background: #fff;
            font-family: Arial, Helvetica, sans-serif;
        }

        .fh-section-label { font-size: 11px; font-weight: 700; color: #9aa6a0; letter-spacing: .4px; padding: 10px 18px 4px 18px; flex-shrink: 0; }

        /* Search results dropdown */
        .fh-search-results {
            margin: 0 14px 8px 14px; background: #f9fbf9;
            border: 1px solid #e0e8e2; border-radius: 10px;
            max-height: 220px; overflow-y: auto; flex-shrink: 0;
        }
        .fh-search-result-item {
            display: flex; justify-content: space-between; align-items: center;
            padding: 10px 12px; text-decoration: none; color: #243328;
            border-bottom: 1px solid #eef2ef;
        }
        .fh-search-result-item:hover { background: #eef5f0; }

        /* Conversation list — ONLY this scrolls on the left */
        .fh-conv-list { flex: 1; overflow-y: auto; padding: 2px 10px 12px 10px; min-height: 0; }
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

        .fh-conv-info { flex: 1; overflow: hidden; min-width: 0; }
        .fh-conv-top { display: flex; justify-content: space-between; align-items: center; gap: 8px; }
        .fh-conv-name { font-weight: 700; font-size: 14px; color: #111827; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .fh-conv-time { font-size: 11px; color: #9ca3af; flex-shrink: 0; }
        .fh-conv-time.unread { color: #1f9d55; font-weight: 700; }
        .fh-conv-bottom { display: flex; align-items: center; justify-content: space-between; gap: 8px; margin-top: 3px; }
        .fh-conv-preview { font-size: 12px; color: #6b7280; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex: 1; }
        .fh-conv-dot { width: 6px; height: 6px; border-radius: 50%; background: #2DA66E; display: inline-block; margin-right: 6px; vertical-align: middle; }
        .fh-unread-badge {
            background: #1f9d55; color: #fff; font-size: 11px; font-weight: 700;
            min-width: 20px; height: 20px; border-radius: 10px; padding: 0 6px;
            display: inline-flex; align-items: center; justify-content: center; flex-shrink: 0;
        }
        /* Active / Ended status pill on each conversation row */
        .fh-conv-state { font-size: 10.5px; font-weight: 700; padding: 2px 8px; border-radius: 10px; flex-shrink: 0; }
        .fh-conv-state.active { color: #12833f; background: #e6f6ec; }
        .fh-conv-state.ended  { color: #6b7280; background: #eef1f0; }

        /* ===== CENTRE: conversation ===== */
        /* White by default so the welcome/empty state fills the whole centre area with no
           grey dead-space; the pale grey belongs only to the active message-scroll area. */
        .fh-chat { flex: 1; display: flex; flex-direction: column; min-width: 0; min-height: 0; background: #ffffff; }
        #upChat { flex: 1; min-height: 0; display: flex; flex-direction: column; }
        /* On the welcome/empty state (root NOT .chat-open) the UpdatePanel wraps a hidden
           chat panel; collapse it so the welcome fills the whole centre with no dead space. */
        .fh-msg-root:not(.chat-open) #upChat { flex: 0 0 auto; }
        .fh-msg-root.chat-open .fh-welcome { display: none; }
        .fh-chat-panel { flex: 1; min-height: 0; display: flex; flex-direction: column; }

        /* Welcome / empty state */
        .fh-welcome {
            flex: 1; display: flex; flex-direction: column;
            align-items: center; justify-content: center;
            text-align: center; padding: 24px; background: #ffffff;
        }
        .fh-welcome-icon {
            width: 92px; height: 92px; border-radius: 24px;
            display: flex; align-items: center; justify-content: center;
            font-size: 44px; color: #1f9d55; margin-bottom: 18px; border: 2px solid #d9f2e1;
        }
        .fh-welcome h2 { margin: 0 0 6px 0; font-size: 26px; color: #10261c; }
        .fh-welcome p { margin: 0 0 18px 0; color: #7d8c82; font-size: 14px; }
        .fh-welcome-btn {
            background: linear-gradient(135deg, #1f9d55, #12833f); color: #fff;
            border: none; border-radius: 10px; padding: 12px 22px;
            font-size: 14px; font-weight: 700; cursor: pointer;
            text-decoration: none; display: inline-block; font-family: Arial, Helvetica, sans-serif;
        }

        /* Conversation header (stationary) */
        .fh-chat-head {
            display: flex; align-items: center; justify-content: space-between;
            padding: 12px 18px; background: #ffffff; border-bottom: 1px solid #e5e9e6; flex-shrink: 0;
        }
        .fh-chat-head-user { display: flex; align-items: center; gap: 12px; text-decoration: none; color: inherit; }
        .fh-chat-head-name { font-weight: 800; color: #10261c; font-size: 15px; }
        .fh-chat-head-status { font-size: 12px; color: #6b7280; display: flex; align-items: center; }
        .status-dot {
            width: 8px; height: 8px; background: #22c55e; border-radius: 50%;
            display: inline-block; margin-right: 5px; box-shadow: 0 0 0 3px rgba(34,197,94,.18);
        }
        .status-dot.offline { background: #9ca3af; box-shadow: 0 0 0 3px rgba(156,163,175,.18); }
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

        /* Compact project strip under the header */
        .fh-project-bar {
            display: flex; align-items: center; gap: 8px;
            padding: 8px 18px; background: #ffffff; border-bottom: 1px solid #eef2ef;
            font-size: 13px; color: #4b5b51; flex-shrink: 0;
        }
        .fh-project-bar .proj-name { font-weight: 700; color: #10261c; }
        .fh-dot-green { width: 8px; height: 8px; border-radius: 50%; background: #1f9d55; display: inline-block; }
        .fh-dot-grey { width: 8px; height: 8px; border-radius: 50%; background: #9ca3af; display: inline-block; }
        /* Compact project selector (several active projects) */
        .fh-proj-select {
            margin-left: auto; font-size: 12px; color: #4b5b51; background: #f7faf8;
            border: 1px solid #e2e8e4; border-radius: 8px; padding: 4px 8px;
            font-family: Arial, Helvetica, sans-serif;
        }

        /* Messages — ONLY this scrolls in the centre. Vertical list; messages sit at the
           TOP and never stretch to fill the height (justify-content:flex-start). */
        .fh-messages {
            flex: 1; overflow-y: auto; min-height: 0;
            padding: 16px 22px; display: flex; flex-direction: column;
            justify-content: flex-start; gap: 11px; background: #f6f8f7;
        }
        /* Every direct child of the scrolling message column must keep its natural height.
           Without flex-shrink:0 the flex column compresses items when content overflows,
           making bubbles collapse and overlap the next message. */
        .fh-messages > * { flex: 0 0 auto; }
        .fh-day, .fh-sep {
            align-self: center; background: #e8efe9; color: #5a6e62;
            font-size: 12px; padding: 4px 12px; border-radius: 12px; margin: 4px 0; text-align: center;
        }
        /* System event (project separator / lifecycle notice) — visually distinct */
        .fh-sysevent {
            align-self: center; max-width: 80%;
            background: #eef4f1; color: #4b5b51; border: 1px dashed #cfe0d6;
            font-size: 12px; padding: 6px 14px; border-radius: 12px; margin: 6px 0; text-align: center;
        }

        /* Compact, content-sized bubbles. Each message = bubble row + timestamp beneath.
           The wrapper never stretches: it hugs its content (fit-content) up to max-width:70%
           and sits at the start of the cross axis so short messages stay small. */
        .fh-msg {
            display: flex; flex-direction: column; flex: 0 0 auto;
            width: fit-content; max-width: 70%; height: auto; min-height: 0;
        }
        .fh-msg.recv { align-self: flex-start; align-items: flex-start; }
        .fh-msg.sent { align-self: flex-end; align-items: flex-end; }
        /* The row holds the (optional) avatar + bubble; it hugs content, never flex:1. */
        .fh-row { display: flex; gap: 8px; align-items: flex-end; width: auto; }
        .fh-msg.sent .fh-row { flex-direction: row-reverse; }
        .fh-row-avatar {
            width: 30px; height: 30px; border-radius: 50%; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            font-size: 11px; font-weight: 700; background: #d8f3dc; color: #2d6a4f;
        }
        /* Bubble sizes to its content: fit-content width, automatic height, no min-height.
           NOTE: white-space:pre-wrap lives on .fh-bubble-text ONLY (the message text), NOT
           on the bubble — otherwise the source-code newlines/indentation between the text
           span and the attachment markup would render as huge blank vertical space. */
        .fh-bubble {
            width: fit-content; max-width: 100%; height: auto; min-height: 0;
            padding: 8px 12px; font-size: 14px; line-height: 1.45; color: #10261c;
            box-shadow: 0 1px 2px rgba(16,40,28,.06); position: relative;
            overflow-wrap: anywhere; word-break: break-word;
        }
        .fh-msg.recv .fh-bubble { background: #ffffff; border: 1px solid #eef2ef; border-radius: 12px; border-top-left-radius: 4px; }
        .fh-msg.sent .fh-bubble { background: #e6f8ea; border-radius: 12px; border-top-right-radius: 4px; }
        /* Message text: preserve the sender's own line breaks here (not markup whitespace). */
        .fh-bubble-text { display: block; white-space: pre-wrap; overflow-wrap: anywhere; word-break: break-word; }
        .fh-bubble-text:empty { display: none; }
        /* Timestamp sits 4px directly BELOW the bubble, aligned to the bubble's outer edge. */
        .fh-bubble-time { font-size: 10.5px; color: #8b9a90; margin-top: 4px; padding: 0 2px; }
        .ticks-blue { color: #1f9d55 !important; }
        .ticks-gray { color: #8b9a90; }

        /* Compact attachment card: single horizontal row (32px icon + name/status + action).
           Content-sized height, preferred ~300px width, constrained to the available space. */
        .fh-file-card {
            display: flex; align-items: center; gap: 10px;
            background: #ffffff; border: 1px solid #e5e9e6; border-radius: 10px;
            padding: 10px 12px; width: 300px; max-width: 100%;
            height: auto; text-decoration: none;
        }
        .fh-file-card--na { background: #f8f9f9; }
        .fh-file-ic {
            width: 32px; height: 32px; border-radius: 8px; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            font-size: 12px; background: #fdecec; color: #d14343; font-weight: 700;
        }
        .fh-file-meta { flex: 1; overflow: hidden; min-width: 0; }
        .fh-file-name { font-weight: 700; font-size: 13px; color: #10261c; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .fh-file-sub { font-size: 11px; color: #8b9a90; }
        .fh-file-dl { color: #1f9d55; font-size: 18px; text-decoration: none; flex-shrink: 0; }
        .fh-file-na { color: #c0c7c3; font-size: 18px; flex-shrink: 0; cursor: not-allowed; }

        /* Image thumbnail inside a bubble — aspect ratio preserved, capped at 280x180. */
        .fh-img-thumb {
            display: block; max-width: 280px; max-height: 180px; width: auto; height: auto;
            border-radius: 10px; cursor: pointer; object-fit: cover; background: #eef2ef;
        }

        /* Caption text that follows media gets a small top gap; attachment-only hides it. */
        .fh-bubble > .fh-bubble-text:not(:first-child) { margin-top: 6px; }

        /* Image lightbox overlay */
        .fh-lightbox {
            position: fixed; inset: 0; z-index: 10000;
            background: rgba(16,32,24,.82); display: flex; align-items: center; justify-content: center;
            padding: 32px;
        }
        .fh-lightbox-fig { margin: 0; max-width: 92vw; max-height: 90vh; display: flex; flex-direction: column; align-items: center; gap: 10px; }
        .fh-lightbox-img { max-width: 92vw; max-height: 82vh; border-radius: 10px; box-shadow: 0 12px 40px rgba(0,0,0,.4); object-fit: contain; }
        .fh-lightbox-cap { color: #e8efe9; font-size: 13px; text-align: center; max-width: 80vw; overflow-wrap: anywhere; }
        .fh-lightbox-close {
            position: absolute; top: 18px; right: 22px; width: 42px; height: 42px; border-radius: 50%;
            border: none; background: rgba(255,255,255,.14); color: #fff; font-size: 20px; cursor: pointer;
        }
        .fh-lightbox-close:hover { background: rgba(255,255,255,.26); }

        /* Composer (stationary) */
        .fh-input-wrap { padding: 12px 18px; background: #ffffff; border-top: 1px solid #e5e9e6; flex-shrink: 0; }
        .fh-input-row {
            display: flex; align-items: flex-end; gap: 8px;
            background: #f4f7f5; border: 1px solid #e6ece8; border-radius: 20px;
            padding: 5px 6px 5px 10px;
        }
        .fh-attach { width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; color: #6b7280; cursor: pointer; font-size: 17px; flex-shrink: 0; }
        .fh-file-hidden { display: none; }
        .fh-msg-input {
            flex: 1; border: none; background: transparent; padding: 10px 8px;
            font-size: 14px; outline: none; resize: none; max-height: 120px; overflow-y: auto;
            font-family: Arial, Helvetica, sans-serif; line-height: 1.4;
        }
        .fh-send {
            width: 42px; height: 42px; border-radius: 50%; border: none;
            background: linear-gradient(135deg, #1f9d55, #12833f); color: #fff;
            font-size: 16px; cursor: pointer; flex-shrink: 0;
        }
        .fh-send:disabled { opacity: .5; cursor: not-allowed; }
        .fh-input-help { font-size: 11px; color: #9aa6a0; margin-top: 6px; padding-left: 10px; display: block; }
        .fh-attach-preview { font-size: 12px; color: #15803d; margin-top: 4px; padding-left: 10px; display: block; }

        /* Ended-chat notice replacing the composer */
        .fh-ended-notice {
            margin: 12px 18px; padding: 14px 16px; display: flex; gap: 12px; align-items: flex-start;
            background: #f4f6f5; border: 1px solid #e3e8e5; border-radius: 12px; flex-shrink: 0;
        }
        .fh-ended-ic { font-size: 18px; color: #6b7280; flex-shrink: 0; }
        .fh-ended-text { font-size: 13px; color: #4b5b51; line-height: 1.5; }
        .fh-ended-text strong { color: #10261c; }

        /* ===== RIGHT: project details + shared files + conversation status ===== */
        .fh-details {
            width: 290px; flex-shrink: 0;
            border-left: 1px solid #e5e9e6; background: #ffffff;
            display: flex; flex-direction: column; min-height: 0;
        }
        .fh-details.collapsed { display: none; }
        .fh-details-head {
            display: flex; align-items: center; justify-content: space-between;
            padding: 16px 18px; border-bottom: 1px solid #eef2ef; flex-shrink: 0;
        }
        .fh-details-title { font-size: 16px; font-weight: 800; color: #10261c; }
        /* Fixed sub-header (project name/status/link + Shared Files label) stays put. */
        .fh-details-fixed { padding: 16px 18px 0; flex-shrink: 0; }
        /* Only the files list + conversation status scroll. */
        .fh-details-body { padding: 10px 18px 16px; overflow-y: auto; min-height: 0; flex: 1 1 auto; }
        .fh-details-sub { font-size: 11px; font-weight: 700; color: #9aa6a0; letter-spacing: .4px; margin: 18px 0 8px 0; }
        /* First label in each block (SHARED FILES in the fixed header, CONVERSATION STATUS
           at the top of the scroll area) sheds its top margin for tidy spacing. */
        .fh-details-fixed .fh-details-sub:last-child { margin-bottom: 0; }
        .fh-details-body > .fh-details-sub:first-child { margin-top: 0; }
        .fh-details-project { font-size: 16px; font-weight: 800; color: #10261c; margin-bottom: 4px; }
        .fh-details-status { font-size: 13px; color: #4b5b51; display: flex; align-items: center; gap: 6px; }
        .fh-details-link { display: inline-block; margin-top: 10px; font-size: 13px; font-weight: 700; color: #12833f; text-decoration: none; }
        .fh-details-link:hover { text-decoration: underline; }

        /* Conversation status card */
        .fh-status-card {
            border-radius: 10px; padding: 12px 14px; margin-top: 6px;
            display: flex; gap: 10px; align-items: flex-start;
        }
        .fh-status-card.active { background: #eafaf0; border: 1px solid #cdeedd; }
        .fh-status-card.ended { background: #f3f5f4; border: 1px solid #e3e8e5; }
        .fh-status-ic { font-size: 15px; flex-shrink: 0; margin-top: 1px; }
        .fh-status-title { font-size: 13.5px; font-weight: 700; color: #10261c; }
        .fh-status-sub { font-size: 12px; color: #5a6e62; margin-top: 2px; }

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
        @media (max-width: 980px) {
            .fh-details { display: none; }
            .fh-details:not(.collapsed) { display: flex; position: absolute; right: 0; top: 0; height: 100%; z-index: 20; box-shadow: -8px 0 24px rgba(16,40,28,.12); }
        }
        @media (max-width: 820px) {
            .fh-msg-root { flex-direction: column; height: auto; min-height: 0; position: static; }
            .fh-msg-root.chat-open .fh-sidebar { display: none; }
            .fh-msg-root:not(.chat-open) .fh-chat { display: none; }
            .fh-sidebar { width: 100%; height: 70vh; }
            .fh-chat { height: calc(100vh - 172px); }
            .fh-back-btn { display: inline-flex; }
        }
    </style>

    <script type="text/javascript">
        function showSelectedFileName(input) {
            var label = document.getElementById('<%= lblAttachedFileName.ClientID %>');
            if (!label) return;
            label.innerText = (input.files && input.files[0]) ? ("Attached: " + input.files[0].name) : "";
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
        // NOTE: scroll-to-bottom is now driven by the follow-logic in the page-foot script
        // (open/switch/send jump to bottom; reading older messages preserves position).

        // Collapse/expand the right project-details panel; the centre area expands to fill.
        function toggleDetails() {
            var d = document.getElementById("pnlProjectDetails");
            if (d) d.classList.toggle("collapsed");
        }

        // Composer: Enter sends, Shift+Enter inserts a new paragraph. Auto-grow height.
        function fhComposerKeydown(e, sendBtnId) {
            if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault();
                var btn = document.getElementById(sendBtnId);
                if (btn && !btn.disabled) { btn.click(); }
                return false;
            }
            return true;
        }
        function fhAutoGrow(el) {
            el.style.height = "auto";
            el.style.height = Math.min(el.scrollHeight, 120) + "px";
        }
        // Prevent duplicate sends: disable the Send button on submit (re-enabled on reload).
        function fhGuardSend(btn) {
            if (btn.dataset.sending === "1") return false;
            btn.dataset.sending = "1";
            setTimeout(function () { btn.disabled = true; }, 0);
            return true;
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:ScriptManager ID="chatScriptManager" runat="server" />

    <%-- Legacy inline status strip kept hidden; user-facing feedback uses the global popup. --%>
    <asp:Panel ID="pnlStatus" runat="server" Visible="false">
        <asp:Label ID="lblStatus" runat="server"></asp:Label>
    </asp:Panel>

    <div runat="server" id="workspacePanel" class="fh-msg-root">

        <!-- ============ LEFT: CONVERSATION LIST ============ -->
        <div class="fh-sidebar">
            <div class="fh-sidebar-head">
                <h1 class="fh-sidebar-title">Messages
                    <asp:Panel ID="pnlUnreadTotal" runat="server" CssClass="fh-head-badge" Visible="false">
                        <asp:Literal ID="litUnreadTotal" runat="server" />
                    </asp:Panel>
                </h1>

                <asp:Panel ID="pnlChatSearch" runat="server" DefaultButton="btnSearchUser" CssClass="fh-search">
                    <span class="fh-search-icon">&#128269;</span>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="fh-search-input" placeholder="Search conversations..."
                        AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                    <asp:Button ID="btnSearchUser" runat="server" Text="Search" CssClass="fh-search-btn" OnClick="btnSearchUser_Click" />
                </asp:Panel>

                <!-- Segmented All / Unread / Ended -->
                <div class="fh-filters">
                    <asp:LinkButton ID="btnFilterAll" runat="server" CssClass="fh-filter active" CommandArgument="All" OnClick="Filter_Click" CausesValidation="false">All</asp:LinkButton>
                    <asp:LinkButton ID="btnFilterUnread" runat="server" CssClass="fh-filter" CommandArgument="Unread" OnClick="Filter_Click" CausesValidation="false">Unread</asp:LinkButton>
                    <asp:LinkButton ID="btnFilterEnded" runat="server" CssClass="fh-filter" CommandArgument="Ended" OnClick="Filter_Click" CausesValidation="false">Ended</asp:LinkButton>
                </div>

                <!-- Contact-role filter (preserved) -->
                <asp:DropDownList ID="ddlContactFilter" runat="server" CssClass="fh-contact-filter" AutoPostBack="true" OnSelectedIndexChanged="ddlContactFilter_SelectedIndexChanged">
                    <asp:ListItem Text="All contacts" Value="AllContacts" Selected="True" />
                    <asp:ListItem Text="Clients" Value="Clients" />
                    <asp:ListItem Text="Freelancers" Value="Freelancers" />
                </asp:DropDownList>

                <%-- Hidden role chips retained so existing handlers/designer stay valid. --%>
                <asp:LinkButton ID="btnFilterClients" runat="server" CommandArgument="Clients" OnClick="Filter_Click" CausesValidation="false" Style="display:none;">Clients</asp:LinkButton>
                <asp:LinkButton ID="btnFilterFreelancers" runat="server" CommandArgument="Freelancers" OnClick="Filter_Click" CausesValidation="false" Style="display:none;">Freelancers</asp:LinkButton>
            </div>

            <!-- Search results -->
            <asp:Panel ID="pnlSearchResults" runat="server" CssClass="fh-search-results" Visible="false">
                <div style="padding:8px 12px; font-size:11px; font-weight:bold; color:#5a6e5f; background:#eef5f0;">MATCHING SYSTEM USERS:</div>
                <asp:Repeater ID="rptSearchResults" runat="server" OnItemCommand="rptSearchResults_ItemCommand">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnSelectSearchResult" runat="server" CssClass="fh-search-result-item" CommandName="StartChatWithUser" CommandArgument='<%# Eval("userID") %>'>
                            <div>
                                <strong style="display:block; font-size:13px; color:#173f2c;"><%# Server.HtmlEncode(Convert.ToString(Eval("firstName"))) %> <%# Server.HtmlEncode(Convert.ToString(Eval("lastName"))) %></strong>
                                <small style="color:#6b7280; font-size:11px;"><%# Server.HtmlEncode(Convert.ToString(Eval("email"))) %></small>
                            </div>
                            <span style="background:#e8f5e0; color:#2d6b3f; padding:2px 6px; border-radius:8px; font-size:10px; font-weight:600;"><%# Server.HtmlEncode(Convert.ToString(Eval("userType"))) %></span>
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
                            <div class='<%# "fh-avatar " + GetAvatarClass(Eval("Initials").ToString()) %>'><%# Server.HtmlEncode(Convert.ToString(Eval("Initials"))) %></div>
                            <div class="fh-conv-info">
                                <div class="fh-conv-top">
                                    <span class="fh-conv-name"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></span>
                                    <span class='<%# Convert.ToInt32(Eval("UnreadCount")) > 0 ? "fh-conv-time unread" : "fh-conv-time" %>'><%# Server.HtmlEncode(Convert.ToString(Eval("LastTime"))) %></span>
                                </div>
                                <div class="fh-conv-bottom">
                                    <span class="fh-conv-preview"><span class="fh-conv-dot"></span><%# Server.HtmlEncode(ConversationPreview(Eval("LastMessage"))) %></span>
                                    <asp:PlaceHolder runat="server" Visible='<%# Convert.ToInt32(Eval("UnreadCount")) > 0 %>'>
                                        <span class="fh-unread-badge"><%# Eval("UnreadCount") %></span>
                                    </asp:PlaceHolder>
                                    <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "fh-conv-state active" : "fh-conv-state ended" %>'><%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Ended" %></span>
                                </div>
                            </div>
                        </asp:LinkButton>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Label ID="lblNoUsers" runat="server" Visible="false" Text="No conversations yet." CssClass="fh-conv-preview" Style="padding:10px; display:block;"></asp:Label>
            </div>
        </div>

        <!-- ============ CENTRE: CONVERSATION ============ -->
        <div class="fh-chat">

            <!-- WELCOME / EMPTY STATE -->
            <asp:Panel ID="pnlWelcome" runat="server" CssClass="fh-welcome">
                <div class="fh-welcome-icon">&#128172;</div>
                <h2>Your conversations start here</h2>
                <p>Select a conversation to view messages.</p>
                <a class="fh-welcome-btn" href="BrowseProjects.aspx">Find freelancers</a>
            </asp:Panel>

            <!-- ACTIVE CONVERSATION -->
            <asp:UpdatePanel ID="upChat" runat="server" UpdateMode="Conditional" ClientIDMode="Static">
                <ContentTemplate>
                    <asp:Panel ID="pnlChatPopup" runat="server" Visible="false" CssClass="fh-chat-panel">

                        <!-- Conversation header (stationary) -->
                        <div class="fh-chat-head">
                            <asp:LinkButton ID="btnBack" runat="server" CssClass="fh-icon-btn fh-back-btn" OnClick="btnCloseChat_Click" CausesValidation="false" title="Back">&#8592;</asp:LinkButton>
                            <asp:LinkButton ID="btnOpenHeaderModal" runat="server" CssClass="fh-chat-head-user" OnClick="btnToggleDetails_Click" title="View contact info">
                                <div class="fh-avatar avatar-rt"><asp:Label ID="lblChatInitials" runat="server" Text="--"></asp:Label></div>
                                <div>
                                    <div class="fh-chat-head-name"><asp:Label ID="lblChatName" runat="server" Text="Select a conversation"></asp:Label></div>
                                    <div class="fh-chat-head-status">
                                        <span id="statusDot" runat="server" class="status-dot offline"></span>
                                        <asp:Label ID="lblPartnerStatus" runat="server" Text=""></asp:Label>
                                    </div>
                                </div>
                            </asp:LinkButton>

                            <div class="fh-head-actions">
                                <asp:HyperLink ID="lnkViewProject" runat="server" CssClass="fh-view-project" NavigateUrl="#">View Project</asp:HyperLink>
                                <%-- Retained server-side View Project button (hidden) so existing handler stays valid. --%>
                                <asp:LinkButton ID="btnViewProject" runat="server" OnClick="btnToggleDetails_Click" CausesValidation="false" Style="display:none;">View project</asp:LinkButton>
                                <a href="javascript:void(0);" class="fh-icon-btn" onclick="toggleDetails();return false;" title="Project details">&#9432;</a>
                                <asp:LinkButton ID="btnInfoIcon" runat="server" CssClass="fh-icon-btn" OnClick="btnToggleDetails_Click" title="Contact info" style="display:none;">i</asp:LinkButton>
                            </div>
                        </div>

                        <!-- Compact project strip -->
                        <asp:Panel ID="pnlProjectBar" runat="server" CssClass="fh-project-bar" Visible="false">
                            <span>&#128193;</span>
                            <span class="proj-name"><asp:Label ID="lblProjectBarTitle" runat="server" /></span>
                            <span id="projBarDot" runat="server" class="fh-dot-green"></span>
                            <span><asp:Label ID="lblProjectBarStatus" runat="server" /></span>

                            <%-- Compact project selector shown only when several active projects exist. --%>
                            <asp:DropDownList ID="ddlProjectSelect" runat="server" CssClass="fh-proj-select" Visible="false"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlProjectSelect_SelectedIndexChanged" />
                        </asp:Panel>

                        <!-- Messages — ONLY this scrolls -->
                        <div id="fhMessages" class="fh-messages">
                            <asp:Repeater ID="rptMessages" runat="server">
                                <ItemTemplate>
                                    <asp:PlaceHolder runat="server" Visible='<%# IsSystemRow(Eval("content")) %>'>
                                        <div class="fh-sysevent"><%# Server.HtmlEncode(SystemText(Eval("content"))) %></div>
                                    </asp:PlaceHolder>

                                    <asp:PlaceHolder runat="server" Visible='<%# !IsSystemRow(Eval("content")) %>'>
                                        <div class='<%# Convert.ToInt32(Eval("senderID")) == CurrentUserId ? "fh-msg sent" : "fh-msg recv" %>'>
                                            <div class="fh-row">
                                                <asp:PlaceHolder runat="server" Visible='<%# Convert.ToInt32(Eval("senderID")) != CurrentUserId %>'>
                                                    <div class="fh-row-avatar"><asp:Label runat="server" Text='<%# lblChatInitials.Text %>' /></div>
                                                </asp:PlaceHolder>
                                                <div class="fh-bubble">

                                                    <%-- Attachment (rendered as image / voice note / document card by type) --%>
                                                    <asp:PlaceHolder ID="phAttachment" runat="server" Visible='<%# Eval("attachmentUrl") != DBNull.Value && !string.IsNullOrEmpty(Eval("attachmentUrl").ToString()) %>'>

                                                        <%-- Missing / inaccessible file: unavailable state, no download --%>
                                                        <asp:PlaceHolder runat="server" Visible='<%# !AttachmentExists(Eval("attachmentUrl")) %>'>
                                                            <div class="fh-file-card fh-file-card--na">
                                                                <span class="fh-file-ic" style="background:#eef1f0;color:#9ca3af;">&#128196;</span>
                                                                <div class="fh-file-meta">
                                                                    <div class="fh-file-name" title='<%# Server.HtmlEncode(OriginalFileName(Eval("attachmentUrl"))) %>'><%# Server.HtmlEncode(OriginalFileName(Eval("attachmentUrl"))) %></div>
                                                                    <div class="fh-file-sub">Attachment unavailable</div>
                                                                </div>
                                                                <span class="fh-file-na" title="Download unavailable">&#8856;</span>
                                                            </div>
                                                        </asp:PlaceHolder>

                                                        <%-- Available file --%>
                                                        <asp:PlaceHolder runat="server" Visible='<%# AttachmentExists(Eval("attachmentUrl")) %>'>

                                                            <%-- IMAGE: compact thumbnail opening a lightbox --%>
                                                            <asp:PlaceHolder runat="server" Visible='<%# IsImageAttachment(Eval("attachmentUrl")) %>'>
                                                                <img class="fh-img-thumb" src='<%# ResolveAttachmentUrl(Eval("attachmentUrl")) %>'
                                                                     alt='<%# Server.HtmlEncode(OriginalFileName(Eval("attachmentUrl"))) %>'
                                                                     data-full='<%# ResolveAttachmentUrl(Eval("attachmentUrl")) %>'
                                                                     data-name='<%# Server.HtmlEncode(OriginalFileName(Eval("attachmentUrl"))) %>'
                                                                     onclick="fhOpenLightbox(this);" loading="lazy" />
                                                            </asp:PlaceHolder>

                                                            <%-- AUDIO (legacy voice notes): no longer supported — compact placeholder, no playback. --%>
                                                            <asp:PlaceHolder runat="server" Visible='<%# IsAudioAttachment(Eval("attachmentUrl")) %>'>
                                                                <div class="fh-file-card fh-file-card--na">
                                                                    <span class="fh-file-ic" style="background:#eef1f0;color:#9ca3af;">&#127908;</span>
                                                                    <div class="fh-file-meta">
                                                                        <div class="fh-file-name">Voice note</div>
                                                                        <div class="fh-file-sub">Voice note no longer supported</div>
                                                                    </div>
                                                                </div>
                                                            </asp:PlaceHolder>

                                                            <%-- DOCUMENT: compact horizontal card with download --%>
                                                            <asp:PlaceHolder runat="server" Visible='<%# IsDocAttachment(Eval("attachmentUrl")) %>'>
                                                                <a class="fh-file-card" href='<%# ResolveAttachmentUrl(Eval("attachmentUrl")) %>' target="_blank" title='<%# Server.HtmlEncode(OriginalFileName(Eval("attachmentUrl"))) %>'>
                                                                    <span class="fh-file-ic"><%# FileExtLabel(Eval("attachmentUrl")) %></span>
                                                                    <div class="fh-file-meta">
                                                                        <div class="fh-file-name"><%# Server.HtmlEncode(OriginalFileName(Eval("attachmentUrl"))) %></div>
                                                                        <div class="fh-file-sub"><%# Server.HtmlEncode(FileMeta(Eval("attachmentUrl"))) %></div>
                                                                    </div>
                                                                    <span class="fh-file-dl" title="Download">&#8681;</span>
                                                                </a>
                                                            </asp:PlaceHolder>
                                                        </asp:PlaceHolder>
                                                    </asp:PlaceHolder>

                                                    <%-- Message text (also serves as a caption beneath media when present). --%>
                                                    <span class="fh-bubble-text"><%# Server.HtmlEncode(Convert.ToString(Eval("content"))) %></span>
                                                </div>
                                            </div>
                                            <span class="fh-bubble-time">
                                                <%# TimeHelper.ToSast(Eval("timeStamp")).ToString("HH:mm") %>
                                                <asp:PlaceHolder ID="phReadReceipt" runat="server" Visible='<%# Convert.ToInt32(Eval("senderID")) == CurrentUserId %>'>
                                                    <span class='<%# Eval("status").ToString() == "Read" ? "ticks-blue" : "ticks-gray" %>'><%# Eval("status").ToString() == "Sent" ? "&#10003;" : "&#10003;&#10003;" %></span>
                                                </asp:PlaceHolder>
                                            </span>
                                        </div>
                                    </asp:PlaceHolder>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <!-- Composer (active) OR ended-notice -->
                        <asp:Panel ID="pnlComposer" runat="server" CssClass="fh-input-wrap">
                            <asp:Panel ID="pnlChatInput" runat="server" DefaultButton="btnSend" CssClass="fh-input-row">
                                <label for="<%= fileUploadControl.ClientID %>" class="fh-attach" title="Attach file">&#128206;</label>
                                <asp:FileUpload ID="fileUploadControl" runat="server" CssClass="fh-file-hidden" onchange="showSelectedFileName(this);" />
                                <asp:TextBox ID="txtMessage" runat="server" CssClass="fh-msg-input" TextMode="MultiLine" Rows="1"
                                    placeholder="Write a message..."></asp:TextBox>
                                <asp:Button ID="btnSend" runat="server" Text="&#10148;" CssClass="fh-send" OnClick="btnSend_Click" />
                            </asp:Panel>

                            <asp:Label ID="lblAttachedFileName" runat="server" CssClass="fh-attach-preview"></asp:Label>
                            <span class="fh-input-help">Enter to send &#183; Shift+Enter for a new paragraph</span>
                        </asp:Panel>

                        <asp:Panel ID="pnlEndedNotice" runat="server" CssClass="fh-ended-notice" Visible="false">
                            <span class="fh-ended-ic">&#128274;</span>
                            <span class="fh-ended-text">
                                <strong><asp:Literal ID="litEndedReason" runat="server" Text="This conversation has ended." /></strong>
                                Sending messages and attachments is disabled. Your message history remains available.
                            </span>
                        </asp:Panel>
                    </asp:Panel>
                </ContentTemplate>
                <Triggers>
                    <asp:PostBackTrigger ControlID="btnSend" />
                </Triggers>
            </asp:UpdatePanel>
        </div>

        <!-- ============ RIGHT: PROJECT DETAILS + SHARED FILES + STATUS ============ -->
        <asp:Panel ID="pnlProjectDetails" runat="server" ClientIDMode="Static" CssClass="fh-details" Visible="false">
            <div class="fh-details-head">
                <span class="fh-details-title">Project details</span>
                <a href="javascript:void(0);" class="fh-icon-btn" onclick="toggleDetails();return false;" title="Close">&#10005;</a>
            </div>
            <!-- Fixed sub-header: project name, status, link + Shared Files label stay put. -->
            <div class="fh-details-fixed">
                <div class="fh-details-project"><asp:Label ID="lblDetailsProjectTitle" runat="server" Text="No active project" /></div>
                <div class="fh-details-status">
                    <span id="detailsStatusDot" runat="server" class="fh-dot-green"></span>
                    <asp:Label ID="lblDetailsProjectStatus" runat="server" Text="&#8212;" />
                </div>

                <div class="fh-details-sub">SHARED FILES</div>
            </div>

            <!-- Scrolling area: shared-files list + conversation status. -->
            <div class="fh-details-body">
                <asp:Repeater ID="rptSharedFiles" runat="server">
                    <ItemTemplate>
                        <asp:PlaceHolder runat="server" Visible='<%# AttachmentExists(Eval("attachmentUrl")) %>'>
                            <a class="fh-file-card" href='<%# ResolveAttachmentUrl(Eval("attachmentUrl")) %>' target="_blank" title="Open file" style="margin-bottom:10px;">
                                <span class="fh-file-ic"><%# FileExtLabel(Eval("attachmentUrl")) %></span>
                                <div class="fh-file-meta">
                                    <div class="fh-file-name"><%# Server.HtmlEncode(OriginalFileName(Eval("attachmentUrl"))) %></div>
                                    <div class="fh-file-sub"><%# Server.HtmlEncode(FileMeta(Eval("attachmentUrl"))) %></div>
                                </div>
                                <span class="fh-file-dl">&#8681;</span>
                            </a>
                        </asp:PlaceHolder>
                        <asp:PlaceHolder runat="server" Visible='<%# !AttachmentExists(Eval("attachmentUrl")) %>'>
                            <div class="fh-file-card" style="margin-bottom:10px;">
                                <span class="fh-file-ic" style="background:#eef1f0;color:#9ca3af;">&#128196;</span>
                                <div class="fh-file-meta">
                                    <div class="fh-file-name"><%# Server.HtmlEncode(OriginalFileName(Eval("attachmentUrl"))) %></div>
                                    <div class="fh-file-sub">Attachment unavailable</div>
                                </div>
                                <span class="fh-file-na">&#8856;</span>
                            </div>
                        </asp:PlaceHolder>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Label ID="lblNoSharedFiles" runat="server" Visible="false" Text="No shared files yet." Style="font-size:13px; color:#9ca3af;" />

                <div class="fh-details-sub">CONVERSATION STATUS</div>
                <asp:Panel ID="pnlStatusActive" runat="server" CssClass="fh-status-card active">
                    <span class="fh-status-ic">&#128994;</span>
                    <div>
                        <div class="fh-status-title">Active</div>
                        <div class="fh-status-sub">You can send and receive messages.</div>
                    </div>
                </asp:Panel>
                <asp:Panel ID="pnlStatusEnded" runat="server" CssClass="fh-status-card ended" Visible="false">
                    <span class="fh-status-ic">&#128274;</span>
                    <div>
                        <div class="fh-status-title">Ended</div>
                        <div class="fh-status-sub">This conversation has ended. Message history remains available.</div>
                    </div>
                </asp:Panel>
            </div>
        </asp:Panel>
    </div>

    <!-- IMAGE LIGHTBOX (centre-section image previews) -->
    <div id="fhLightbox" class="fh-lightbox" style="display:none;" onclick="fhCloseLightbox(event);">
        <button type="button" class="fh-lightbox-close" onclick="fhCloseLightbox(event, true);" aria-label="Close preview">&#10005;</button>
        <figure class="fh-lightbox-fig" onclick="event.stopPropagation();">
            <img id="fhLightboxImg" class="fh-lightbox-img" src="" alt="" />
            <figcaption id="fhLightboxCap" class="fh-lightbox-cap"></figcaption>
        </figure>
    </div>

    <!-- CONTACT INFO MODAL (opened from the header avatar / contact info) -->
    <asp:Panel ID="pnlUserDetailsModal" runat="server" CssClass="modal-overlay" Visible="false">
        <div class="modal-pop-card">
            <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #e0e8e2; padding-bottom:12px; margin-bottom:16px;">
                <h3 style="margin:0; color:#173f2c; font-size:18px;">Contact Info</h3>
                <asp:LinkButton ID="btnCloseDetails" runat="server" OnClick="btnCloseDetails_Click" Style="color:#888; text-decoration:none; font-size:20px; font-weight:bold; cursor:pointer;">&#10005;</asp:LinkButton>
            </div>
            <div style="background:#f9fbf9; border:1px solid #e0e8e2; border-radius:8px; padding:14px; margin-bottom:18px; display:grid; grid-template-columns:1fr 1fr; gap:10px; font-size:13px; color:#243328;">
                <div><strong>Full Name:</strong> <asp:Label ID="lblDetailName" runat="server" /></div>
                <div><strong>Account Type:</strong> <asp:Label ID="lblDetailUserType" runat="server" /></div>
                <div><strong>Email:</strong> <asp:Label ID="lblDetailEmail" runat="server" /></div>
                <div><strong>Contact:</strong> <asp:Label ID="lblDetailContact" runat="server" /></div>
                <div style="grid-column:span 2;"><strong>Rating Score:</strong> &#11088; <asp:Label ID="lblDetailRating" runat="server" /> / 5.0</div>
            </div>
            <div style="text-align:right;">
                <asp:Button ID="btnCloseModalBtn" runat="server" Text="Close" OnClick="btnCloseDetails_Click" CausesValidation="false" Style="background:#173f2c; color:white; border:none; padding:8px 18px; border-radius:6px; font-weight:600; cursor:pointer;" />
            </div>
        </div>
    </asp:Panel>

    <!-- Rating Modal (shown after a project completes, as before) -->
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

    <script type="text/javascript">
    (function () {
        var TAID = '<%= txtMessage.ClientID %>';
        var SNDID = '<%= btnSend.ClientID %>';

        // ---------- Composer wiring (idempotent via onX assignment) ----------
        function wireComposer() {
            var ta = document.getElementById(TAID);
            var send = document.getElementById(SNDID);
            if (ta && send) {
                ta.onkeydown = function (e) { return fhComposerKeydown(e, send.id); };
                ta.oninput = function () { fhAutoGrow(ta); };
                send.onclick = function () { if (!fhGuardSend(send)) return false; return true; };
            }
        }

        // ---------- Image lightbox ----------
        window.fhOpenLightbox = function (img) {
            var box = document.getElementById('fhLightbox');
            var full = document.getElementById('fhLightboxImg');
            var cap = document.getElementById('fhLightboxCap');
            if (!box || !full) return;
            full.src = img.getAttribute('data-full') || img.src;
            full.alt = img.getAttribute('data-name') || '';
            if (cap) cap.textContent = img.getAttribute('data-name') || '';
            box.style.display = 'flex';
        };
        window.fhCloseLightbox = function (ev, force) {
            // Close on backdrop click or the X; ignore clicks on the image itself.
            var box = document.getElementById('fhLightbox');
            if (!box) return;
            if (force || !ev || ev.target === box) {
                box.style.display = 'none';
                var full = document.getElementById('fhLightboxImg');
                if (full) full.src = '';
            }
        };
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                var box = document.getElementById('fhLightbox');
                if (box && box.style.display !== 'none') window.fhCloseLightbox(null, true);
            }
        });

        // ---------- Scroll-follow (open at latest; follow only when near bottom) ----------
        var wasNearBottom = true;
        function isNearBottom(el) { return (el.scrollHeight - el.scrollTop - el.clientHeight) < 120; }
        function rememberScroll() {
            var b = document.getElementById('fhMessages');
            if (b) wasNearBottom = isNearBottom(b);
        }
        function followIfNeeded() {
            var b = document.getElementById('fhMessages');
            if (b && wasNearBottom && window.scrollPopupToBottom) scrollPopupToBottom();
        }
        function attachScrollTracker() {
            var b = document.getElementById('fhMessages');
            if (b) { b.onscroll = function () { wasNearBottom = isNearBottom(b); }; }
        }

        // ---------- Lifecycle wiring ----------
        function initAll() { wireComposer(); attachScrollTracker(); }
        document.addEventListener('DOMContentLoaded', function () { initAll(); wasNearBottom = true; followIfNeeded(); });
        if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_beginRequest(function () { rememberScroll(); });
            prm.add_endRequest(function () { initAll(); followIfNeeded(); });
        }
    })();
    </script>

</asp:Content>

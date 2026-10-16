<%@ Page Title="Select Proposal"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="SelectProposal.aspx.cs"
    Inherits="FreeHubProject.SelectProposal" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <style type="text/css">
        /* ===== Proposal list redesign (compact horizontal cards) =====
           Uses FreeHUB's existing green/white palette and the default 13px text size. */

        /* Two containers: scrollable proposals list on the left, tips on the right.
           minmax(0,1fr) lets the left column shrink so its cards never force a
           horizontal scrollbar; a slightly narrower tips column gives the list room. */
        /* ===== Fixed middle: static header/filters + Tips, only the list scrolls =====
           This page's main content is a NON-scrolling flex column that fills the space
           between the fixed site header and footer (it overrides the shared
           .freehub-main-content overflow-y:auto). The breadcrumb/heading/description and
           the message are fixed at the top; the two-column .pl-layout fills the rest; and
           within the left column only .pl-list scrolls. The Tips column is in the
           non-scrolling area, so it stays put too. */
        .freehub-main-content.sp-main {
            height: 100%;
            min-height: 0;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        /* Static top band: breadcrumb/heading/description + status message. */
        .sp-main .pl-header-row,
        .sp-main .post-status { flex: 0 0 auto; }

        /* The two-column region fills the remaining height. */
        .pl-layout {
            display: grid; grid-template-columns: minmax(0, 1fr) 260px; gap: 20px;
            align-items: stretch;
            flex: 1 1 auto; min-height: 0;
        }
        /* LEFT column: static "Proposals (N)" + filters on top, scrollable list below. */
        .pl-list-col { display: flex; flex-direction: column; min-height: 0; min-width: 0; }

        /* LEFT container: the proposals list scrolls inside its own box so the page
           doesn't grow endlessly and the tips panel stays visible beside it. */
        .pl-list {
            /* The list is the ONLY vertically scrollable section. Its height is driven
               by the flex column (.pl-list-col) that fills the fixed middle below the
               static heading/filters, so it extends to just above the footer and
               scrolls its own overflow while everything else stays stationary. */
            flex: 1 1 auto;
            min-height: 0;
            overflow-y: auto;
            overflow-x: hidden;
            padding-right: 8px; /* room so cards don't sit under the scrollbar */
        }
        /* Thin green/white themed scrollbar to match FreeHUB. */
        .pl-list { scrollbar-width: thin; scrollbar-color: #2e7d56 #eef3ef; }
        .pl-list::-webkit-scrollbar { width: 8px; }
        .pl-list::-webkit-scrollbar-track { background: #eef3ef; border-radius: 8px; }
        .pl-list::-webkit-scrollbar-thumb {
            background: linear-gradient(180deg, #2e7d56, #72c94b);
            border-radius: 8px; border: 2px solid #eef3ef;
        }
        .pl-list::-webkit-scrollbar-thumb:hover { background: #2e7d56; }

        /* Pill-style status filter tabs */
        .pl-tabs {
            display: flex; gap: 8px; margin-bottom: 16px; flex-wrap: wrap;
        }
        /* Pills inline on the "Proposals (N)" row — pushed to the right of the heading,
           wrapping neatly on narrow screens. */
        .pl-tabs-inline {
            margin-bottom: 0; justify-content: flex-end; align-items: center;
            flex: 1 1 auto; margin-left: auto;
        }
        .pl-tab {
            display: inline-flex; align-items: center; gap: 8px;
            height: 38px; padding: 0 15px; border-radius: 25px;
            background: #f3f6f4; color: #2e7d56; border: 1px solid #e2e8e4;
            font-size: 13px; font-weight: 600; text-decoration: none; cursor: pointer;
            white-space: nowrap; width: auto; overflow: visible; line-height: 1;
            transition: background 0.2s ease, color 0.2s ease, border-color 0.2s ease;
        }
        .pl-tab:hover { background: #eaf6ee; color: #12833f; }
        /* Count badge sits inside each tab (rendered as inline HTML in the LinkButton Text) */
        .pl-tab .pl-tab-count {
            display: inline-flex; align-items: center; justify-content: center;
            min-width: 20px; height: 20px; padding: 0 6px; border-radius: 50%; margin-left: 2px;
            background: #e2e8e4; color: #5a6e62; font-size: 12px; font-weight: 700;
            transition: background 0.2s ease, color 0.2s ease;
        }
        /* Active tab — FreeHUB green (text stays white & fully visible) */
        .pl-tab.pl-tab-active { background: #2e7d56; color: #ffffff; border-color: #2e7d56; }
        .pl-tab.pl-tab-active:hover { background: #276b4a; color: #ffffff; }
        .pl-tab.pl-tab-active .pl-tab-count { background: rgba(255,255,255,.25); color: #ffffff; }

        /* Empty-state card (shown when the selected filter has no proposals) */
        .pl-empty {
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            text-align: center;
            min-height: 240px;
            background: #ffffff; border: 1px solid #e8ece9; border-radius: 14px;
            box-shadow: 0 1px 3px rgba(16, 40, 28, 0.06);
            padding: 36px 24px;
        }
        .pl-empty-icon {
            width: 92px; height: 92px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 18px;
            background: #e5f4ea; color: #2e7d56; font-size: 40px;
        }
        .pl-empty-title { margin: 0 0 8px; color: #173f2c; font-size: 20px; font-weight: 700; }
        .pl-empty-text { margin: 0; color: #7b878d; font-size: 14px; }

        /* Card: left zone (freelancer) | divider | right zone (meta + status + actions) */
        .pl-card {
            display: flex;
            align-items: stretch;
            gap: 24px;
            background: #ffffff;
            border: 1px solid #e8ece9;
            border-radius: 14px;
            padding: 18px 22px;
            margin-bottom: 14px;
            box-shadow: 0 1px 3px rgba(16, 40, 28, 0.06);
        }
        .pl-card:hover { box-shadow: 0 6px 16px rgba(16, 40, 28, 0.10); }

        /* LEFT zone: row 1 = avatar + name; row 2 = project badge below the avatar. */
        .pl-left { display: flex; flex-direction: column; align-items: flex-start; gap: 10px; flex: 1 1 260px; min-width: 0; }
        /* Row 1: avatar and name side by side, vertically centred. */
        .pl-identity { display: flex; align-items: center; gap: 14px; min-width: 0; width: 100%; }
        .pl-avatar {
            width: 48px; height: 48px; border-radius: 50%; flex-shrink: 0;
            background: #2e7d56; color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-weight: bold; font-size: 15px;
        }
        .pl-name { color: #10261c; font-size: 16px; font-weight: 700; min-width: 0;
                   white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        /* Light-green project badge with folder icon (project shown once, here) */
        .pl-project-badge {
            display: inline-flex; align-items: center; gap: 7px;
            align-self: flex-start; max-width: 100%;
            padding: 6px 12px; border-radius: 8px;
            background: #e5f4ea; color: #2e7d56;
            font-size: 13px; font-weight: 600;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }
        .pl-project-badge strong { color: #173f2c; font-weight: 700; }
        .pl-folder { font-size: 14px; flex-shrink: 0; }

        /* RIGHT zone: separated by a soft left border, stacked vertically */
        .pl-right {
            flex: 0 0 auto; display: flex; flex-direction: column; gap: 14px;
            padding-left: 24px; border-left: 1px solid #eef2ef; min-width: 0;
        }

        /* Meta fields row (Proposed Rate | Estimated Time | Submitted) */
        .pl-meta { display: flex; align-items: center; gap: 26px; }
        .pl-field { display: flex; align-items: center; gap: 10px; }
        .pl-field-text { display: flex; flex-direction: column; }
        .pl-label { color: #8a949a; font-size: 12px; white-space: nowrap; }
        /* Values shown IN FULL — no truncation. */
        .pl-value { color: #10261c; font-size: 14px; font-weight: 700; white-space: nowrap; }

        /* Round pastel icon chips */
        .pl-icon {
            width: 34px; height: 34px; border-radius: 50%; flex-shrink: 0;
            display: inline-flex; align-items: center; justify-content: center; font-size: 15px;
        }
        .pl-icon-rate { background: #e5f4ea; }
        .pl-icon-time { background: #e6f0ff; }
        .pl-icon-date { background: #f3e8ff; }

        /* Compact status badge — only as wide as its icon + label + padding (never
           stretched across the card). Sits inline on the same row as the action buttons.
           Hidden for Pending (no badge, like the reference). */
        .pl-status-badge {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 8px 14px; border-radius: 20px;
            font-size: 13px; font-weight: 700; white-space: nowrap;
            flex: 0 0 auto; align-self: center;
        }
        .pl-status-tick { font-size: 14px; display: inline-flex; align-items: center; }
        /* Per-status compact badge colours (icon inherits the text colour). */
        .pl-badge-approved { color: #087d43; background: #e3f3e9; }   /* ✓ green */
        .pl-badge-pending  { color: #b45309; background: #fef3c7; }   /* ◷ orange */
        .pl-badge-rejected { color: #b91c1c; background: #fde8e8; }   /* ✕ red */
        .pl-badge-review   { color: #1d4ed8; background: #e6effe; }   /* ⌛ blue (Under Review / In Review) */
        .pl-badge-withdrawn{ color: #4b5563; background: #e5e7eb; }
        .pl-badge-default  { color: #4b5563; background: #eef2f5; }

        /* One horizontal row: compact status badge + action buttons grouped together,
           vertically centred, directly under the proposal details, with consistent gaps.
           Replaces the old full-width status bar and separate button row. Right-aligned
           within the card's right section; wraps neatly on narrow cards. */
        .pl-actions { display: flex; align-items: center; justify-content: flex-end; gap: 12px; flex-wrap: wrap; }
        .pl-btn {
            display: inline-flex; align-items: center; justify-content: center; gap: 7px;
            padding: 10px 20px; border-radius: 24px; font-size: 13px; font-weight: 700;
            cursor: pointer; white-space: nowrap; border: 1px solid transparent;
        }
        .pl-btn-view { background: #ffffff; color: #173f2c; border: 1.5px solid #2e7d56; }
        .pl-btn-view:hover { background: #eaf6ee; }
        .pl-btn-delete { background: #e03b4b; color: #ffffff; border: 1px solid #e03b4b; }
        .pl-btn-delete:hover { background: #c82333; }
        .pl-btn-select { background: #2e7d56; color: #ffffff; border: 1px solid #2e7d56; }
        .pl-btn-select:hover { opacity: .93; }

        /* "Proposals (N)" heading row — heading on the left, filter pills on the right.
           Static within the left column (never scrolls). */
        .pl-list-heading {
            flex: 0 0 auto;
            display: flex; align-items: center; justify-content: space-between;
            gap: 12px; flex-wrap: wrap; min-height: 38px; margin-bottom: 15px;
        }
        /* Tips card's top edge aligns with the top of the filter row: both grid columns
           start at the same Y, so no spacer is needed. */
        .pl-tips-spacer { display: none; }

        /* RIGHT container: tips stacked vertically. It sits in the non-scrolling middle,
           so it stays stationary while the proposal list scrolls (no sticky needed). */
        .pl-tips { align-self: start; }

        /* ===== Responsive ===== */
        /* Tablet/narrow: the two card zones stack; the left-border divider moves to top. */
        @media (max-width: 1100px) {
            .pl-card { flex-direction: column; align-items: stretch; gap: 16px; }
            .pl-left { flex: 1 1 auto; }
            .pl-right {
                flex: 1 1 auto; padding-left: 0; border-left: none;
                padding-top: 16px; border-top: 1px solid #eef2ef;
            }
            .pl-meta { flex-wrap: wrap; gap: 18px 26px; }
        }
        /* Below this width the two containers stack: list on top, tips below. The
           fixed-middle model is released so the page flows and scrolls naturally. */
        @media (max-width: 900px) {
            .freehub-main-content.sp-main { height: auto; overflow: visible; display: block; }
            .pl-layout { grid-template-columns: 1fr; display: grid; flex: none; }
            .pl-list-col { display: block; }
            .pl-list { flex: none; max-height: 60vh; }
            .pl-tips { align-self: auto; }
        }
        /* Mobile: buttons full width, meta items wrap. */
        @media (max-width: 640px) {
            .pl-actions { flex-wrap: wrap; }
            .pl-actions .pl-btn { flex: 1 1 auto; }
        }

        /* NOTE: column-bottom alignment, the page-content height overshoot and the
           footer gap are now fixed once in the shared stylesheet (StyleSheet1.css)
           for every .freehub-dashboard-layout page, so the per-page .sp-layout
           override that used to live here has been removed. */
    </style>

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content sp-main">

            <!-- HEADER -->
            <div class="pl-header-row" style="margin-bottom:18px;">
                <div class="post-breadcrumb">
                    <a href="<%= ResolveUrl("~/Dashboard.aspx") %>" class="breadcrumb-link">Dashboard</a> <span>/</span>
                    <a href="<%= ResolveUrl("~/MyProjects.aspx") %>" class="breadcrumb-link">My Projects</a> <span>/</span>
                    <strong>Proposals</strong>
                </div>
                <h1 style="color:#173f2c; margin-top:5px;">
                    <%= IsFreelancerView() ? "My Proposals" : "Select Proposal" %>
                </h1>
                <p style="color:#666; font-size:14px; margin:0;">
                    <%= IsFreelancerView() ? "View your submitted proposals and their status." : "Review proposals received and select the best fit for your project." %>
                </p>
            </div>

            <!-- MESSAGE -->
            <asp:Panel ID="pnlMessage" runat="server" CssClass="post-status" Visible="false">
                <asp:Label ID="lblProposalMessage" runat="server" />
            </asp:Panel>

            <!-- PROPOSALS + TIPS LAYOUT -->
            <div class="pl-layout">

                <!-- PROPOSALS LIST (left column: static heading+filters, scrollable list) -->
                <div class="pl-list-col">
                    <!-- "Proposals (N)" heading on the left, status filter pills on the
                         right — on the same horizontal row (matches the reference). -->
                    <div class="pl-list-heading">
                        <h3 style="color:#173f2c; margin:0;">Proposals (<asp:Label ID="lblProposalCount" runat="server" Text="0" />)</h3>

                        <!-- STATUS FILTER TABS — each tab's label + count badge is set
                             server-side on the LinkButton Text so counts survive postbacks. -->
                        <asp:Panel ID="pnlFilterTabs" runat="server" CssClass="pl-tabs pl-tabs-inline">
                            <asp:LinkButton ID="lnkTabAll" runat="server" CssClass="pl-tab"
                                CommandName="All" OnCommand="FilterTab_Command" CausesValidation="false" />
                            <asp:LinkButton ID="lnkTabPending" runat="server" CssClass="pl-tab"
                                CommandName="Pending" OnCommand="FilterTab_Command" CausesValidation="false" />
                            <asp:LinkButton ID="lnkTabApproved" runat="server" CssClass="pl-tab"
                                CommandName="Approved" OnCommand="FilterTab_Command" CausesValidation="false" />
                            <asp:LinkButton ID="lnkTabRejected" runat="server" CssClass="pl-tab"
                                CommandName="Rejected" OnCommand="FilterTab_Command" CausesValidation="false" />
                        </asp:Panel>
                    </div>

                    <!-- Scrollable list container — hidden when empty so no blank scrollbar shows -->
                    <asp:Panel ID="pnlListWrap" runat="server" CssClass="pl-list">
                    <asp:Repeater ID="rptProposals" runat="server" OnItemCommand="rptProposals_ItemCommand">
                        <ItemTemplate>
                            <%-- Compact horizontal proposal card. No cover letter / proposal
                                 content is shown here — it opens only via "View Proposal". --%>
                            <div class="pl-card">

                                <!-- LEFT: row 1 = avatar + name (side by side);
                                     row 2 = project badge below the avatar, left-aligned to it. -->
                                <div class="pl-left">
                                    <div class="pl-identity">
                                        <div class="pl-avatar">
                                            <%# Eval("freelancerName").ToString().Substring(0,1).ToUpper() %><%# Eval("freelancerName").ToString().Contains(" ") ? Eval("freelancerName").ToString().Split(' ')[1].Substring(0,1).ToUpper() : "" %>
                                        </div>
                                        <strong class="pl-name"><%# Server.HtmlEncode(Convert.ToString(Eval("freelancerName"))) %></strong>
                                    </div>
                                    <span class="pl-project-badge">
                                        <span class="pl-folder" aria-hidden="true">&#128193;</span>
                                        Project: <strong><%# Server.HtmlEncode(TitleHelper.TitleCase(Convert.ToString(Eval("projectTitle")))) %></strong>
                                    </span>
                                </div>

                                <!-- RIGHT: meta fields row on top, then status + action buttons -->
                                <div class="pl-right">

                                    <div class="pl-meta">
                                        <!-- Proposed rate (ZAR) -->
                                        <div class="pl-field pl-rate">
                                            <span class="pl-icon pl-icon-rate" aria-hidden="true">&#128176;</span>
                                            <span class="pl-field-text">
                                                <span class="pl-label">Proposed Rate</span>
                                                <strong class="pl-value">R<%# Convert.ToDecimal(Eval("proposedRate")).ToString("N2") %></strong>
                                            </span>
                                        </div>

                                        <!-- Estimated time -->
                                        <div class="pl-field pl-time">
                                            <span class="pl-icon pl-icon-time" aria-hidden="true">&#128336;</span>
                                            <span class="pl-field-text">
                                                <span class="pl-label">Estimated Time</span>
                                                <strong class="pl-value"><%# Server.HtmlEncode(Convert.ToString(Eval("estimatedCompletionTime"))) %></strong>
                                            </span>
                                        </div>

                                        <!-- Submitted date -->
                                        <div class="pl-field pl-date">
                                            <span class="pl-icon pl-icon-date" aria-hidden="true">&#128197;</span>
                                            <span class="pl-field-text">
                                                <span class="pl-label">Submitted</span>
                                                <strong class="pl-value"><%# Convert.ToDateTime(Eval("date")).ToString("dd MMM yyyy") %></strong>
                                            </span>
                                        </div>
                                    </div>

                                    <!-- One row: compact status badge + action buttons (badge left, buttons right). -->
                                    <div class="pl-actions">
                                        <%-- Compact status badge: per-status icon + label, width fits content. --%>
                                        <span class='<%# "pl-status-badge " + GetStatusClass(Eval("status")) %>'>
                                            <span class="pl-status-tick" aria-hidden="true"><%# GetStatusIcon(Eval("status")) %></span>
                                            <%# Server.HtmlEncode(GetStatusLabel(Eval("status"))) %>
                                        </span>

                                        <%-- Employer-only "Select Proposal" for Pending proposals (unchanged business rule) --%>
                                        <asp:Button ID="btnSelect" runat="server"
                                            CommandName="ApproveProposal"
                                            CommandArgument='<%# Eval("proposalID") %>'
                                            Text="Select Proposal"
                                            CssClass="pl-btn pl-btn-select"
                                            Visible='<%# Eval("status").ToString() == "Pending" && !IsFreelancerView() %>' />

                                        <%-- View Proposal: opens the full proposal (ReviewProposal.aspx), for both roles --%>
                                        <asp:Button ID="btnViewProposal" runat="server"
                                            CommandName="ViewProposal"
                                            CommandArgument='<%# Eval("proposalID") %>'
                                            Text="&#128065; View Proposal"
                                            CssClass="pl-btn pl-btn-view" />

                                        <%-- Delete: freelancer-only, same confirmation + rule as before --%>
                                        <asp:Button ID="btnDeleteProposal" runat="server"
                                            CommandName="DeleteProposal"
                                            CommandArgument='<%# Eval("proposalID") %>'
                                            Text="&#128465; Delete"
                                            CssClass="pl-btn pl-btn-delete"
                                            Visible='<%# IsFreelancerView() %>'
                                            OnClientClick="return fhConfirm(this, 'Are you sure you want to delete this proposal? It will also be removed from the employer.', 'Delete Proposal');" />
                                    </div>

                                </div>

                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    </asp:Panel><%-- /.pl-list (pnlListWrap) --%>

                    <!-- EMPTY STATE (shown directly below the filter tabs when the selected
                         filter has zero proposals; mutually exclusive with the list) -->
                    <asp:Panel ID="pnlNoProposals" runat="server" Visible="false" CssClass="pl-empty">
                        <div class="pl-empty-icon" aria-hidden="true">&#128196;</div>
                        <h3 class="pl-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="No Proposals" /></h3>
                        <p class="pl-empty-text"><asp:Literal ID="litEmptyText" runat="server" Text="Proposals will appear here." /></p>
                    </asp:Panel>
                </div>

                <!-- TIPS PANEL (right container) -->
                <div class="pl-tips">
                    <%-- Spacer that matches the "Proposals (N)" heading row on the left so the
                         Tips card's TOP EDGE aligns exactly with the first proposal card. --%>
                    <div class="pl-tips-spacer" aria-hidden="true"></div>
                    <% if (IsFreelancerView()) { %>
                    <%-- FREELANCER: tips for improving the chance of proposal approval.
                         Slightly tighter padding so all five tips fit without a scrollbar. --%>
                    <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:18px 20px; margin-bottom:15px;">
                        <h4 style="color:#173f2c; margin-bottom:10px;">Tips to Improve Your Chances of Proposal Approval</h4>
                        <ul style="list-style:none; padding:0; margin:0;">
                            <li style="padding:7px 0; font-size:13px; color:#555; border-bottom:1px solid #f0f0f0;"><strong style="color:#173f2c;">Personalise your proposal</strong> &ndash; Show that you understand the project's requirements.</li>
                            <li style="padding:7px 0; font-size:13px; color:#555; border-bottom:1px solid #f0f0f0;"><strong style="color:#173f2c;">Highlight your skills</strong> &ndash; Mention relevant experience and previous work.</li>
                            <li style="padding:7px 0; font-size:13px; color:#555; border-bottom:1px solid #f0f0f0;"><strong style="color:#173f2c;">Offer competitive rates</strong> &ndash; Set fair prices that reflect your skills.</li>
                            <li style="padding:7px 0; font-size:13px; color:#555; border-bottom:1px solid #f0f0f0;"><strong style="color:#173f2c;">Be realistic</strong> &ndash; Suggest achievable deadlines and deliverables.</li>
                            <li style="padding:7px 0; font-size:13px; color:#555;"><strong style="color:#173f2c;">Keep it professional</strong> &ndash; Write clearly, confidently, and avoid errors.</li>
                        </ul>
                    </div>
                    <%-- Freelancers do NOT see the "Next Step" card (removed for this role). --%>
                    <% } else { %>
                    <%-- EMPLOYER: original tips + Next Step card, unchanged. --%>
                    <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:20px; margin-bottom:15px;">
                        <h4 style="color:#173f2c; margin-bottom:12px;">Tips for Choosing the Right Freelancer</h4>
                        <ul style="list-style:none; padding:0; margin:0;">
                            <li style="padding:8px 0; font-size:13px; color:#555; border-bottom:1px solid #f0f0f0;">Review cover letters and understand the freelancer's approach.</li>
                            <li style="padding:8px 0; font-size:13px; color:#555; border-bottom:1px solid #f0f0f0;">Compare proposed rates and delivery times.</li>
                            <li style="padding:8px 0; font-size:13px; color:#555; border-bottom:1px solid #f0f0f0;">Check ratings, reviews and past work.</li>
                            <li style="padding:8px 0; font-size:13px; color:#555;">Choose the proposal that best fits your needs and budget.</li>
                        </ul>
                    </div>

                    <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:20px; margin-bottom:15px;">
                        <h4 style="color:#173f2c; margin-bottom:8px;">Need Help?</h4>
                        <p style="font-size:13px; color:#666; margin-bottom:12px;">If you need assistance in choosing the right freelancer, our support team is here.</p>
                        <a href="StartChat.aspx?help=1&userId=1" style="display:inline-block;color:#2e7d56;border:1px solid #2e7d56;padding:8px 16px;border-radius:20px;font-size:12px;text-decoration:none;">Contact Support</a>
                    </div>

                    <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:20px;">
                        <h4 style="color:#173f2c; margin-bottom:8px;">Next Step</h4>
                        <p style="font-size:13px; color:#666;">After selecting a proposal, you can review the details before approving.</p>
                    </div>
                    <% } %>
                </div>

            </div>

        </section>

    </div>

</asp:Content>

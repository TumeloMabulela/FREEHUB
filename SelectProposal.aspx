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
        .pl-layout { display: grid; grid-template-columns: minmax(0, 1fr) 260px; gap: 20px; align-items: start; }

        /* LEFT container: the proposals list scrolls inside its own box so the page
           doesn't grow endlessly and the tips panel stays visible beside it. */
        .pl-list {
            max-height: calc(100vh - 230px);
            min-height: 320px;
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

        /* Approval filter tabs */
        .pl-tabs {
            display: flex; gap: 8px; margin-bottom: 16px; flex-wrap: wrap;
        }
        .pl-tab {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 9px 16px; border-radius: 22px;
            background: #f3f6f4; color: #5a6e62; border: 1px solid #e2e8e4;
            font-size: 13px; font-weight: 600; text-decoration: none; cursor: pointer;
            white-space: nowrap; width: auto; overflow: visible; line-height: 1.2;
        }
        .pl-tab:hover { background: #eaf6ee; color: #12833f; }
        /* Count badge sits inside each tab (rendered as inline HTML in the LinkButton Text) */
        .pl-tab .pl-tab-count {
            display: inline-flex; align-items: center; justify-content: center;
            min-width: 22px; padding: 2px 7px; border-radius: 11px; margin-left: 2px;
            background: #e2e8e4; color: #5a6e62; font-size: 12px; font-weight: 700;
        }
        /* Active tab — FreeHUB green (text stays white & fully visible) */
        .pl-tab.pl-tab-active { background: #2e7d56; color: #ffffff; border-color: #2e7d56; }
        .pl-tab.pl-tab-active:hover { background: #276b4a; color: #ffffff; }
        .pl-tab.pl-tab-active .pl-tab-count { background: rgba(255,255,255,.25); color: #ffffff; }

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

        /* LEFT zone: avatar + name + project badge */
        .pl-left { display: flex; align-items: flex-start; gap: 14px; flex: 1 1 260px; min-width: 0; }
        .pl-avatar {
            width: 48px; height: 48px; border-radius: 50%; flex-shrink: 0;
            background: #2e7d56; color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-weight: bold; font-size: 15px;
        }
        .pl-freelancer-text { min-width: 0; display: flex; flex-direction: column; gap: 8px; }
        .pl-name { color: #10261c; font-size: 16px; font-weight: 700;
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

        /* Full-width status bar (shown for Approved/Rejected/Withdrawn; hidden for Pending) */
        .pl-status-bar {
            display: flex; align-items: center; gap: 8px;
            padding: 10px 16px; border-radius: 10px;
            font-size: 13px; font-weight: 700;
        }
        .pl-status-tick { font-size: 14px; }
        .pl-status-bar.pl-badge-pending { display: none; }   /* no bar for Pending, like the reference */
        .pl-badge-approved { color: #1e7a46; background: #e5f4ea; }
        .pl-badge-rejected { color: #721c24; background: #f8d7da; }
        .pl-badge-withdrawn{ color: #4b5563; background: #e5e7eb; }
        .pl-badge-default  { color: #4b5563; background: #eef2f5; }

        /* Action buttons row (right-aligned, pill buttons) */
        .pl-actions { display: flex; align-items: center; justify-content: flex-end; gap: 12px; }
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

        /* RIGHT container: tips stacked vertically, sticky so they stay in view. */
        .pl-tips { position: sticky; top: 90px; }

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
        /* Below this width the two containers stack: list on top, tips below. */
        @media (max-width: 900px) {
            .pl-layout { grid-template-columns: 1fr; }
            .pl-list { max-height: 60vh; }
            .pl-tips { position: static; }
        }
        /* Mobile: buttons full width, meta items wrap. */
        @media (max-width: 640px) {
            .pl-actions { flex-wrap: wrap; }
            .pl-actions .pl-btn { flex: 1 1 auto; }
        }
    </style>

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <!-- HEADER -->
            <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:20px;">
                <div>
                    <div class="post-breadcrumb">
                        <a href="<%= ResolveUrl("~/Dashboard.aspx") %>" class="breadcrumb-link">Dashboard</a> <span>/</span>
                        <a href="<%= ResolveUrl("~/MyProjects.aspx") %>" class="breadcrumb-link">My Projects</a> <span>/</span>
                        <strong>Proposals</strong>
                    </div>
                    <h1 style="color:#173f2c; margin-top:5px;">
                        <%= IsFreelancerView() ? "My Proposals" : "Select Proposal" %>
                    </h1>
                    <p style="color:#666; font-size:14px;">
                        <%= IsFreelancerView() ? "View your submitted proposals and their status." : "Review proposals received and select the best fit for your project." %>
                    </p>
                </div>
                <a href="MyProjects.aspx" style="display:inline-block;color:#fff;background-color:#173f2c;text-decoration:none;font-size:13px;font-weight:500;padding:10px 20px;border-radius:6px;white-space:nowrap;">&#8592; Back to Project</a>
            </div>

            <!-- MESSAGE -->
            <asp:Panel ID="pnlMessage" runat="server" CssClass="post-status" Visible="false">
                <asp:Label ID="lblProposalMessage" runat="server" />
            </asp:Panel>

            <!-- NO PROPOSALS -->
            <asp:Panel ID="pnlNoProposals" runat="server" Visible="false" CssClass="no-projects-message">
                <h3>No proposals received yet</h3>
                <p>Once freelancers submit proposals for your projects, they will appear here for you to review.</p>
            </asp:Panel>

            <!-- PROPOSALS + TIPS LAYOUT -->
            <div class="pl-layout">

                <!-- PROPOSALS LIST -->
                <div>
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
                        <h3 style="color:#173f2c;">Proposals (<asp:Label ID="lblProposalCount" runat="server" Text="0" />)</h3>
                    </div>

                    <!-- APPROVAL FILTER TABS (employer only).
                         Each tab's label + count is set entirely via the LinkButton's Text
                         server-side (no child server controls) so the text/counts can never
                         be lost across postbacks. -->
                    <asp:Panel ID="pnlFilterTabs" runat="server" CssClass="pl-tabs">
                        <asp:LinkButton ID="lnkTabPending" runat="server" CssClass="pl-tab"
                            CommandName="Pending" OnCommand="FilterTab_Command" CausesValidation="false" />
                        <asp:LinkButton ID="lnkTabApproved" runat="server" CssClass="pl-tab"
                            CommandName="Approved" OnCommand="FilterTab_Command" CausesValidation="false" />
                        <asp:LinkButton ID="lnkTabRejected" runat="server" CssClass="pl-tab"
                            CommandName="Rejected" OnCommand="FilterTab_Command" CausesValidation="false" />
                    </asp:Panel>

                    <!-- Scrollable list container (left) -->
                    <div class="pl-list">
                    <asp:Repeater ID="rptProposals" runat="server" OnItemCommand="rptProposals_ItemCommand">
                        <ItemTemplate>
                            <%-- Compact horizontal proposal card. No cover letter / proposal
                                 content is shown here — it opens only via "View Proposal". --%>
                            <div class="pl-card">

                                <!-- LEFT: avatar + name + project badge (project shown once, in the badge) -->
                                <div class="pl-left">
                                    <div class="pl-avatar">
                                        <%# Eval("freelancerName").ToString().Substring(0,1).ToUpper() %><%# Eval("freelancerName").ToString().Contains(" ") ? Eval("freelancerName").ToString().Split(' ')[1].Substring(0,1).ToUpper() : "" %>
                                    </div>
                                    <div class="pl-freelancer-text">
                                        <strong class="pl-name"><%# Server.HtmlEncode(Convert.ToString(Eval("freelancerName"))) %></strong>
                                        <span class="pl-project-badge">
                                            <span class="pl-folder" aria-hidden="true">&#128193;</span>
                                            Project: <strong><%# Server.HtmlEncode(Convert.ToString(Eval("projectTitle"))) %></strong>
                                        </span>
                                    </div>
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

                                    <!-- Status bar (full width, like the Approved bar in the reference) -->
                                    <div class='<%# "pl-status-bar " + GetStatusClass(Eval("status")) %>'>
                                        <span class="pl-status-tick" aria-hidden="true"><%# Eval("status").ToString() == "Approved" ? "&#9989;" : "" %></span>
                                        <%# Server.HtmlEncode(Convert.ToString(Eval("status"))) %>
                                    </div>

                                    <!-- Action buttons row -->
                                    <div class="pl-actions">
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
                    </div><!-- /.pl-list -->
                </div>

                <!-- TIPS PANEL (right container) -->
                <div class="pl-tips">
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
                        <a href="mailto:support@freehub.co.za" style="display:inline-block;color:#2e7d56;border:1px solid #2e7d56;padding:8px 16px;border-radius:20px;font-size:12px;text-decoration:none;">Contact Support</a>
                    </div>

                    <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:20px;">
                        <h4 style="color:#173f2c; margin-bottom:8px;">Next Step</h4>
                        <p style="font-size:13px; color:#666;">After selecting a proposal, you can review the details before approving.</p>
                    </div>
                </div>

            </div>

        </section>

    </div>

</asp:Content>

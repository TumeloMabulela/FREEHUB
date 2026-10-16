<%@ Page Title="Dashboard - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="Dashboard.aspx.cs"
    Inherits="FreeHubProject.Dashboard" %>

<asp:Content ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">
    <style>
        /* Dashboard Layout */
        /* Dashboard-only sub-shell: the container fills the scrollable middle
           (.page-content) and becomes a flex column so the welcome section can stay
           pinned at the top while only the content below it scrolls. The horizontal
           max-width/centre and gutters are preserved via the inner parts. */
        .dashboard-container {
            height: 100%;
            display: flex;
            flex-direction: column;
            min-height: 0;      /* allow the inner scroll child to shrink and scroll */
        }

        /* Fixed (non-scrolling) top band: the banner + welcome section. Shares the
           page background and keeps the same 1200px centred width + side gutters as
           the content below, so the welcome text stays aligned with the stat cards. */
        .dashboard-topband {
            flex: 0 0 auto;
            width: 100%;
            /* Left-aligned to the content area (no centred max-width wrapper), with a
               comfortable ~28px gutter on both sides so the content uses the available
               width next to the sidebar. */
            margin: 0;
            padding: 16px 28px 0;
            box-sizing: border-box;
        }

        /* The only scrollable region on the Dashboard: everything from the stat cards
           down. Fills the remaining height between the welcome band and the fixed
           footer; keeps the same centred width + gutters. */
        .dashboard-scroll {
            flex: 1 1 auto;
            min-height: 0;
            overflow-y: auto;
            overflow-x: hidden;
            width: 100%;
            /* Left-aligned (no centred max-width wrapper); ~28px side gutters so stats and
               sections sit close to the content area's left edge and use the full width. */
            margin: 0;
            padding: 16px 28px 24px;
            box-sizing: border-box;
        }

        .dashboard-welcome {
            /* Welcome text on the left, four compact overview cards on the far right,
               vertically aligned. Cards wrap below the text on narrow screens. */
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 14px 20px;
        }
        .welcome-text { min-width: 0; flex: 0 1 auto; }

        /* Heading + role badge share one horizontal line, badge vertically centred
           and immediately after the name. Wraps naturally on narrow screens. */
        .dashboard-welcome .welcome-heading-row {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 4px;
        }

        .dashboard-welcome h1 {
            font-size: 28px;
            color: #173f2c;
            margin: 0;
        }

        .dashboard-welcome p {
            color: #5a6e5f;
            font-size: 15px;
            margin: 0;
        }

        .dashboard-welcome .role-badge {
            display: inline-block;
            background-color: #e8f5e0;
            color: #2d6b3f;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 13px;
            font-weight: 600;
        }

        /* Stats Cards */
        .dashboard-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 35px;
        }

        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            border: 1px solid #e8ece8;
        }

        .stat-card .stat-label {
            font-size: 13px;
            color: #5a6e5f;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }

        .stat-card .stat-value {
            font-size: 26px;
            font-weight: 700;
            color: #173f2c;
        }

        .stat-card .stat-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            margin-bottom: 12px;
        }

        .stat-icon.green { background-color: #e8f5e0; color: #2d6b3f; }
        .stat-icon.blue { background-color: #e0f0ff; color: #1a6bc4; }
        .stat-icon.orange { background-color: #fff3e0; color: #c47a1a; }
        .stat-icon.purple { background-color: #f3e8ff; color: #7b2dc4; }

        /* Dashboard Sections */
        .dashboard-section {
            margin-bottom: 35px;
        }

        .dashboard-section h2 {
            font-size: 20px;
            color: #173f2c;
            margin-bottom: 16px;
        }

        /* Active Projects Panel & Table */
        .active-projects-card {
            background: white;
            border-radius: 12px;
            border: 1px solid #e8ece8;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            padding: 24px;
            overflow-x: auto;
        }

        .active-projects-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
            text-align: left;
        }

        .active-projects-table th {
            padding: 12px 10px;
            border-bottom: 2px solid #e8ece8;
            color: #5a6e5f;
            font-weight: 600;
        }

        .active-projects-table td {
            padding: 14px 10px;
            border-bottom: 1px solid #f0f2f0;
            color: #243328;
            vertical-align: middle;
        }

        .active-projects-table tr:last-child td {
            border-bottom: none;
        }

        .btn-submit-work {
            background-color: #173f2c;
            color: white;
            padding: 8px 16px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            display: inline-block;
            transition: background-color 0.2s, transform 0.1s;
        }

        .btn-submit-work:hover {
            background-color: #1f5438;
            color: white;
            transform: translateY(-1px);
        }

        /* Quick Actions */
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
        }

        .action-card {
            display: flex;
            align-items: center;
            gap: 14px;
            background: white;
            border-radius: 10px;
            padding: 18px 20px;
            text-decoration: none;
            color: #243328;
            border: 1px solid #e8ece8;
            transition: all 0.2s;
            box-shadow: 0 2px 6px rgba(0,0,0,0.04);
        }

        .action-card:hover {
            border-color: #b7d68c;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            transform: translateY(-2px);
        }

        .action-card .action-icon {
            width: 42px;
            height: 42px;
            border-radius: 10px;
            background-color: #173f2c;
            color: #b7d68c;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            flex-shrink: 0;
        }

        .action-card .action-text h4 {
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 2px;
        }

        .action-card .action-text p {
            font-size: 12px;
            color: #5a6e5f;
        }

        /* Recent Activity */
        .activity-list {
            background: white;
            border-radius: 12px;
            border: 1px solid #e8ece8;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            overflow: hidden;
        }

        .activity-item {
            padding: 16px 24px;
            border-bottom: 1px solid #f0f2f0;
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .activity-item:last-child {
            border-bottom: none;
        }

        .activity-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background-color: #b7d68c;
            flex-shrink: 0;
        }

        .activity-item .activity-text {
            flex: 1;
            font-size: 14px;
            color: #243328;
        }

        .activity-item .activity-date {
            font-size: 12px;
            color: #8a9a8e;
        }

        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #5a6e5f;
        }

        .empty-state p {
            margin-top: 8px;
            font-size: 14px;
        }
        /* Success/info banner shown after posting a project or submitting a proposal */
        .dashboard-banner {
            background-color: #e8f5e0;
            color: #1f5130;
            border: 1px solid #b7dfc0;
            border-radius: 10px;
            padding: 16px 20px;
            margin: 0 auto 25px;
            font-size: 15px;
            line-height: 1.6;
            max-width: 420px;
            text-align: center;
        }

        /* ============================================================
           EMPLOYER DASHBOARD (approved mockup). Scoped via .emp-dash-* / .emp-*
           so no other page is affected. Uses the FreeHUB teal-to-green gradient,
           white cards, pale grey background, slate headings, muted secondary text.
           ============================================================ */
        /* Compact overview cards sitting on the far right of the welcome row. */
        .emp-dash-stats {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            justify-content: flex-end;
            flex: 1 1 auto;
            min-width: 0;
        }
        .emp-stat-card {
            display: flex; align-items: center; gap: 10px;
            background: #fff; border: 1px solid #e6ece8; border-radius: 10px;
            padding: 10px 14px; box-shadow: 0 1px 3px rgba(16,40,28,0.05);
            min-width: 150px;
        }
        .emp-stat-icon {
            width: 36px; height: 36px; border-radius: 9px; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center; font-size: 17px;
            background: #e3f3e9; color: #0f7a44;
        }
        .emp-stat-label { font-size: 12px; color: #64748b; margin-bottom: 1px; white-space: nowrap; }
        .emp-stat-value { font-size: 19px; font-weight: 700; color: #1e293b; line-height: 1.1; white-space: nowrap; }

        /* Three-column grid:
             col 1 = Quick Actions (~28%, spans both rows, full height)
             col 2 = My Projects (row 1) + Upcoming Deadlines (row 2)
             col 3 = Recent Activity (row 1) + Need assistance? (row 2)
           Row 1 is the flexible/equal-height row; row 2 (deadlines/help) is auto. */
        .emp-dash-grid {
            display: grid;
            grid-template-columns: minmax(0, 28fr) minmax(0, 40fr) minmax(0, 32fr);
            grid-template-rows: minmax(0, 1fr) auto;
            gap: 20px;
            align-items: stretch;
        }
        .emp-card-quick     { grid-column: 1; grid-row: 1 / span 2; }
        .emp-card-projects  { grid-column: 2; grid-row: 1; }
        .emp-card-activity  { grid-column: 3; grid-row: 1; }
        .emp-card-deadlines { grid-column: 2; grid-row: 2; }
        .emp-card-help      { grid-column: 3; grid-row: 2; }

        /* Quick Actions: vertical list stacked naturally from the top (NOT stretched to
           fill the card). Consistent ~52px rows with ~10px gaps; all visible, no scroll. */
        .emp-quick-body { display: block; }
        .emp-quick-list { display: flex; flex-direction: column; gap: 10px; }
        .emp-quick-row {
            display: flex; align-items: center; gap: 12px;
            min-height: 52px; padding: 0 10px; border-radius: 8px;
            text-decoration: none; color: #1e293b;
            transition: background 0.15s;
        }
        .emp-quick-row:hover { background: #eef7f1; }
        .emp-quick-ic {
            width: 34px; height: 34px; border-radius: 8px; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center; font-size: 16px;
            background: #e3f3e9; color: #0f7a44; font-weight: 700;
        }
        .emp-quick-label { flex: 1 1 auto; font-size: 14px; font-weight: 600; }
        .emp-quick-chev { color: #94a3b8; font-size: 18px; flex-shrink: 0; }

        .emp-card {
            background: #fff; border: 1px solid #e6ece8; border-radius: 12px;
            box-shadow: 0 1px 3px rgba(16,40,28,0.05);
            display: flex; flex-direction: column; min-height: 0;
        }
        .emp-card-head {
            flex: 0 0 auto;
            display: flex; align-items: center; justify-content: space-between;
            padding: 18px 20px 12px; border-bottom: 1px solid #f0f3f1;
        }
        .emp-card-head h2 { font-size: 17px; font-weight: 700; color: #1e293b; margin: 0; }
        .emp-view-all { font-size: 13px; font-weight: 600; color: #0f7a44; text-decoration: none; }
        .emp-view-all:hover { text-decoration: underline; }

        /* Lists scroll inside their card; headings (.emp-card-head) stay visible. */
        .emp-card-body { padding: 8px 20px 16px; }
        .emp-scroll {
            overflow-y: auto; overflow-x: hidden; min-height: 0; max-height: 300px;
            scrollbar-width: thin; scrollbar-color: #2e7d56 #eef3ef;
        }
        .emp-scroll::-webkit-scrollbar { width: 8px; }
        .emp-scroll::-webkit-scrollbar-track { background: #eef3ef; border-radius: 8px; }
        .emp-scroll::-webkit-scrollbar-thumb { background: linear-gradient(180deg, #2e7d56, #72c94b); border-radius: 8px; border: 2px solid #eef3ef; }

        /* My Projects rows */
        .emp-project-row { padding: 14px 0; border-bottom: 1px solid #f0f3f1; }
        .emp-project-row:last-child { border-bottom: none; }
        .emp-project-main { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 8px; }
        .emp-project-title { margin: 0; font-size: 14.5px; font-weight: 700; color: #1e293b; overflow-wrap: anywhere; }
        .emp-project-meta { display: flex; align-items: center; gap: 12px; }
        .emp-project-budget { font-size: 14px; font-weight: 700; color: #1e293b; white-space: nowrap; }
        .emp-proposal-count { font-size: 12.5px; color: #64748b; }
        .emp-progress { flex: 1 1 auto; height: 8px; background: #e5e7eb; border-radius: 5px; overflow: hidden; min-width: 80px; }
        .emp-progress-bar {
            height: 100%; border-radius: 5px;
            background: linear-gradient(90deg, #148D98 0%, #2DA66E 55%, #70C843 100%);
        }
        .emp-progress-pct { font-size: 12.5px; font-weight: 700; color: #334155; white-space: nowrap; }

        /* Status badges */
        .emp-badge { display: inline-block; padding: 3px 10px; border-radius: 12px; font-size: 11.5px; font-weight: 700; white-space: nowrap; }
        .emp-badge-open      { color: #1e7a46; background: #e5f4ea; }
        .emp-badge-progress  { color: #1d6fd1; background: #e6f0ff; }
        .emp-badge-review    { color: #b45309; background: #fef3c7; }
        .emp-badge-completed { color: #155724; background: #d4edda; }
        .emp-badge-cancelled { color: #b4232e; background: #fdeaea; }
        .emp-badge-default   { color: #4b5563; background: #eef2f5; }

        /* Recent Activity */
        .emp-activity-item { display: flex; gap: 12px; padding: 12px 0; border-bottom: 1px solid #f0f3f1; }
        .emp-activity-item:last-child { border-bottom: none; }
        .emp-activity-dot { width: 10px; height: 10px; border-radius: 50%; margin-top: 5px; flex-shrink: 0;
            background: linear-gradient(135deg, #148D98, #70C843); }
        .emp-activity-text { display: flex; flex-direction: column; min-width: 0; }
        .emp-activity-desc { font-size: 13.5px; color: #334155; }
        .emp-activity-date { font-size: 11.5px; color: #94a3b8; margin-top: 2px; }

        /* Upcoming Deadlines */
        .emp-deadline-item { display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 12px 0; border-bottom: 1px solid #f0f3f1; }
        .emp-deadline-item:last-child { border-bottom: none; }
        .emp-deadline-main { display: flex; flex-direction: column; min-width: 0; }
        .emp-deadline-title { font-size: 13.5px; color: #1e293b; overflow-wrap: anywhere; }
        .emp-deadline-sub { font-size: 11.5px; color: #94a3b8; }
        .emp-deadline-date { font-size: 12.5px; font-weight: 700; color: #b45309; background: #fef3c7; padding: 5px 10px; border-radius: 10px; white-space: nowrap; }

        /* Help & Support card */
        .emp-card-help { background: #f3faf5; border-color: #d7ecde; }
        .emp-help-inner { padding: 22px 20px; }
        .emp-help-icon { width: 40px; height: 40px; border-radius: 50%; background: #e3f3e9; color: #0f7a44; display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: 700; margin-bottom: 12px; }
        .emp-help-inner h3 { font-size: 16px; font-weight: 700; color: #1e293b; margin: 0 0 6px; }
        .emp-help-inner p { font-size: 13px; color: #64748b; margin: 0 0 14px; }
        .emp-help-btn {
            display: inline-block; padding: 9px 18px; border-radius: 8px; font-size: 13px; font-weight: 700;
            text-decoration: none; color: #0f7a44; background: #fff; border: 1.5px solid #2e7d56;
        }
        .emp-help-btn:hover { background: #eaf6ee; }

        .emp-empty { padding: 24px 8px; text-align: center; color: #94a3b8; font-size: 13px; }
        .emp-empty p { margin: 0; }

        /* Responsive: overview cards wrap below the welcome text; the 3-column grid
           collapses to a single column with cards flowing naturally. */
        @media (max-width: 1050px) {
            .dashboard-welcome { align-items: flex-start; }
            .emp-dash-stats { justify-content: flex-start; }
            .emp-dash-grid { grid-template-columns: 1fr; grid-template-rows: none; }
            .emp-card-quick, .emp-card-projects, .emp-card-activity,
            .emp-card-deadlines, .emp-card-help {
                grid-column: auto; grid-row: auto;
            }
            .emp-scroll { max-height: 320px; }
        }
        @media (max-width: 560px) {
            .emp-stat-card { flex: 1 1 100%; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="dashboard-container">

        <!-- FIXED TOP BAND: banner + welcome section stay pinned below the header;
             only .dashboard-scroll below this scrolls. -->
        <div class="dashboard-topband">

            <!-- Success/Info banner (shown after posting a project or submitting a proposal) -->
            <asp:Panel ID="pnlDashboardMessage" runat="server" Visible="false"
                CssClass="dashboard-banner">
                <asp:Literal ID="litDashboardMessage" runat="server" />
            </asp:Panel>

            <!-- Welcome Section: text on the left, four compact overview cards on the
                 far right (employer). Quick Actions live in the left column below. -->
            <div class="dashboard-welcome">
                <div class="welcome-text">
                    <div class="welcome-heading-row">
                        <h1>Welcome back, <asp:Literal ID="litFirstName" runat="server" /></h1>
                        <span class="role-badge"><asp:Literal ID="litRole" runat="server" /></span>
                    </div>
                    <p>Here's an overview of your FreeHUB activity.</p>
                </div>

                <!-- OVERVIEW STAT CARDS (employer) — compact row beside the welcome text.
                     Live values; nothing hardcoded. -->
                <asp:Panel ID="pnlEmployerStats" runat="server" Visible="false" CssClass="emp-dash-stats">
                    <div class="emp-stat-card">
                        <div class="emp-stat-icon">&#128193;</div>
                        <div class="emp-stat-body">
                            <div class="emp-stat-label">Active Projects</div>
                            <div class="emp-stat-value"><asp:Literal ID="litActiveCount" runat="server" Text="0" /></div>
                        </div>
                    </div>
                    <div class="emp-stat-card">
                        <div class="emp-stat-icon">&#128101;</div>
                        <div class="emp-stat-body">
                            <div class="emp-stat-label">Proposals Received</div>
                            <div class="emp-stat-value"><asp:Literal ID="litProposalsReceived" runat="server" Text="0" /></div>
                        </div>
                    </div>
                    <div class="emp-stat-card">
                        <div class="emp-stat-icon">&#9989;</div>
                        <div class="emp-stat-body">
                            <div class="emp-stat-label">Completed Projects</div>
                            <div class="emp-stat-value"><asp:Literal ID="litCompletedCount" runat="server" Text="0" /></div>
                        </div>
                    </div>
                    <div class="emp-stat-card">
                        <div class="emp-stat-icon">&#128176;</div>
                        <div class="emp-stat-body">
                            <div class="emp-stat-label">Wallet Balance</div>
                            <div class="emp-stat-value">R<asp:Literal ID="litBalanceEmp" runat="server" /></div>
                        </div>
                    </div>
                </asp:Panel>
            </div>

        </div><%-- /.dashboard-topband --%>

        <!-- SCROLLABLE CONTENT: stats, quick actions, recent activity, etc. -->
        <div class="dashboard-scroll">

        <!-- ============================================================
             EMPLOYER DASHBOARD (matches the approved mockup). All values are
             live from the existing employer queries — nothing hardcoded.
             ============================================================ -->
        <asp:Panel ID="pnlEmployerDash" runat="server" Visible="false">

            <!-- MAIN THREE-COLUMN GRID: Quick Actions | My Projects+Deadlines | Activity+Help -->
            <div class="emp-dash-grid">

                <!-- LEFT: Quick Actions (full-height vertical list; all visible, no scroll) -->
                <div class="emp-card emp-card-quick">
                    <div class="emp-card-head"><h2>Quick Actions</h2></div>
                    <div class="emp-card-body emp-quick-body">

                        <asp:Panel ID="pnlEmployerQuick" runat="server" Visible="false" CssClass="emp-quick-list">
                            <a href="PostProject.aspx" class="emp-quick-row">
                                <span class="emp-quick-ic">&#43;</span>
                                <span class="emp-quick-label">Post a Project</span>
                                <span class="emp-quick-chev">&#8250;</span>
                            </a>
                            <a href="SelectProposal.aspx" class="emp-quick-row">
                                <span class="emp-quick-ic">&#128101;</span>
                                <span class="emp-quick-label">View Proposals</span>
                                <span class="emp-quick-chev">&#8250;</span>
                            </a>
                            <a href="ViewProgress.aspx" class="emp-quick-row">
                                <span class="emp-quick-ic">&#128200;</span>
                                <span class="emp-quick-label">View Progress</span>
                                <span class="emp-quick-chev">&#8250;</span>
                            </a>
                            <a href="MyProjects.aspx" class="emp-quick-row">
                                <span class="emp-quick-ic">&#128193;</span>
                                <span class="emp-quick-label">My Projects</span>
                                <span class="emp-quick-chev">&#8250;</span>
                            </a>
                            <a href="StartChat.aspx" class="emp-quick-row">
                                <span class="emp-quick-ic">&#9993;</span>
                                <span class="emp-quick-label">Messages</span>
                                <span class="emp-quick-chev">&#8250;</span>
                            </a>
                            <a href="Wallet.aspx" class="emp-quick-row">
                                <span class="emp-quick-ic">&#128176;</span>
                                <span class="emp-quick-label">Manage Wallet</span>
                                <span class="emp-quick-chev">&#8250;</span>
                            </a>
                            <a href="Help.aspx" class="emp-quick-row">
                                <span class="emp-quick-ic">&#63;</span>
                                <span class="emp-quick-label">Help &amp; Support</span>
                                <span class="emp-quick-chev">&#8250;</span>
                            </a>
                        </asp:Panel>

                        <asp:Panel ID="pnlFreelancerQuick" runat="server" Visible="false" CssClass="emp-quick-list">
                            <a href="BrowseProjects.aspx" class="emp-quick-row">
                                <span class="emp-quick-ic">&#128269;</span>
                                <span class="emp-quick-label">Browse Projects</span>
                                <span class="emp-quick-chev">&#8250;</span>
                            </a>
                            <a href="SelectProposal.aspx" class="emp-quick-row">
                                <span class="emp-quick-ic">&#128221;</span>
                                <span class="emp-quick-label">My Proposals</span>
                                <span class="emp-quick-chev">&#8250;</span>
                            </a>
                            <a href="ViewProgress.aspx" class="emp-quick-row">
                                <span class="emp-quick-ic">&#128200;</span>
                                <span class="emp-quick-label">View Progress</span>
                                <span class="emp-quick-chev">&#8250;</span>
                            </a>
                            <a href="StartChat.aspx" class="emp-quick-row">
                                <span class="emp-quick-ic">&#9993;</span>
                                <span class="emp-quick-label">Messages</span>
                                <span class="emp-quick-chev">&#8250;</span>
                            </a>
                            <a href="Wallet.aspx" class="emp-quick-row">
                                <span class="emp-quick-ic">&#128176;</span>
                                <span class="emp-quick-label">Manage Wallet</span>
                                <span class="emp-quick-chev">&#8250;</span>
                            </a>
                            <a href="Help.aspx" class="emp-quick-row">
                                <span class="emp-quick-ic">&#63;</span>
                                <span class="emp-quick-label">Help &amp; Support</span>
                                <span class="emp-quick-chev">&#8250;</span>
                            </a>
                        </asp:Panel>

                    </div>
                </div>

                <!-- MIDDLE: My Projects -->
                <div class="emp-card emp-card-projects">
                    <div class="emp-card-head">
                        <h2>My Projects</h2>
                        <a href="MyProjects.aspx" class="emp-view-all">View All &#8594;</a>
                    </div>
                    <div class="emp-card-body emp-scroll">
                        <asp:Repeater ID="rptEmpProjects" runat="server">
                            <ItemTemplate>
                                <div class="emp-project-row">
                                    <div class="emp-project-main">
                                        <h4 class="emp-project-title"><%# Server.HtmlEncode(Convert.ToString(Eval("Title"))) %></h4>
                                        <span class='<%# "emp-badge " + Eval("StatusClass") %>'><%# Server.HtmlEncode(Convert.ToString(Eval("Status"))) %></span>
                                    </div>
                                    <div class="emp-project-meta">
                                        <div class="emp-project-budget"><%# Eval("BudgetFormatted") %></div>
                                        <%# Convert.ToInt32(Eval("Progress")) > 0
                                            ? "<div class=\"emp-progress\"><div class=\"emp-progress-bar\" style=\"width:" + Eval("Progress") + "%\"></div></div><span class=\"emp-progress-pct\">" + Eval("Progress") + "%</span>"
                                            : "<span class=\"emp-proposal-count\">" + Eval("ProposalCount") + " proposal(s)</span>" %>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Panel ID="pnlEmpNoProjects" runat="server" Visible="false" CssClass="emp-empty">
                            <p>You haven't posted any projects yet. Use <strong>Post a Project</strong> to get started.</p>
                        </asp:Panel>
                    </div>
                </div>

                <!-- RIGHT: Recent Activity -->
                <div class="emp-card emp-card-activity">
                    <div class="emp-card-head"><h2>Recent Activity</h2></div>
                    <div class="emp-card-body emp-scroll">
                        <asp:Repeater ID="rptEmpActivity" runat="server">
                            <ItemTemplate>
                                <div class="emp-activity-item">
                                    <div class="emp-activity-dot"></div>
                                    <div class="emp-activity-text">
                                        <span class="emp-activity-desc"><%# Eval("Description") %></span>
                                        <span class="emp-activity-date"><%# Eval("DateFormatted") %></span>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Panel ID="pnlEmpNoActivity" runat="server" Visible="false" CssClass="emp-empty">
                            <p>No recent activity yet.</p>
                        </asp:Panel>
                    </div>
                </div>

                <!-- LEFT (row 2): Upcoming Deadlines -->
                <div class="emp-card emp-card-deadlines">
                    <div class="emp-card-head"><h2>Upcoming Deadlines</h2></div>
                    <div class="emp-card-body emp-scroll">
                        <asp:Repeater ID="rptEmpDeadlines" runat="server">
                            <ItemTemplate>
                                <div class="emp-deadline-item">
                                    <div class="emp-deadline-main">
                                        <strong class="emp-deadline-title"><%# Server.HtmlEncode(Convert.ToString(Eval("Title"))) %></strong>
                                        <span class="emp-deadline-sub">Project deadline</span>
                                    </div>
                                    <span class="emp-deadline-date">&#128197; <%# Convert.ToDateTime(Eval("Deadline")).ToString("dd MMM yyyy") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Panel ID="pnlEmpNoDeadlines" runat="server" Visible="false" CssClass="emp-empty">
                            <p>No upcoming deadlines.</p>
                        </asp:Panel>
                    </div>
                </div>

                <!-- RIGHT (row 2): Help & Support -->
                <div class="emp-card emp-card-help">
                    <div class="emp-help-inner">
                        <div class="emp-help-icon">&#63;</div>
                        <h3>Need assistance?</h3>
                        <p>Visit Help &amp; Support for guidance.</p>
                        <a href="Help.aspx" class="emp-help-btn">Get Help</a>
                    </div>
                </div>

            </div>

        </asp:Panel>

        <!-- ============================================================
             FREELANCER DASHBOARD (unchanged generic stats + quick actions).
             Hidden for employers (who get the mockup layout above).
             ============================================================ -->
        <asp:Panel ID="pnlFreelancerDash" runat="server">

        <!-- Stats -->
        <div class="dashboard-stats">

            <div class="stat-card">
                <div class="stat-icon green">&#9733;</div>
                <div class="stat-label">Rating</div>
                <div class="stat-value"><asp:Literal ID="litRating" runat="server" /></div>
            </div>

            <div class="stat-card">
                <div class="stat-icon blue">&#9776;</div>
                <div class="stat-label">
                    <asp:Literal ID="litProjectsLabel" runat="server" />
                </div>
                <div class="stat-value"><asp:Literal ID="litProjectsCount" runat="server" /></div>
            </div>

            <div class="stat-card">
                <div class="stat-icon orange">&#9993;</div>
                <div class="stat-label">
                    <asp:Literal ID="litProposalsLabel" runat="server" />
                </div>
                <div class="stat-value"><asp:Literal ID="litProposalsCount" runat="server" /></div>
            </div>

            <div class="stat-card">
                <div class="stat-icon purple">&#8377;</div>
                <div class="stat-label">Wallet Balance</div>
                <div class="stat-value">R <asp:Literal ID="litBalance" runat="server" /></div>
            </div>

        </div>

        <!-- Active Projects Section (Freelancer Only) -->
        <asp:Panel ID="pnlFreelancerActiveProjects" runat="server" Visible="false" CssClass="dashboard-section">
            <h2>Active Projects In Progress</h2>
            <div class="active-projects-card">
                <asp:Repeater ID="rptFreelancerActiveProjects" runat="server">
                    <HeaderTemplate>
                        <table class="active-projects-table">
                            <thead>
                                <tr>
                                    <th>Project Title</th>
                                    <th>Employer</th>
                                    <th>Agreed Budget</th>
                                    <th>Deadline</th>
                                    <th style="text-align: right;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td style="font-weight: 600;"><%# TitleHelper.TitleCase(Convert.ToString(Eval("Title"))) %></td>
                            <td><%# Eval("EmployerName") %></td>
                            <td style="font-weight: bold; color: #173f2c;">
                                R<%# Convert.ToDecimal(Eval("Budget")).ToString("N2") %>
                            </td>
                            <td><%# Convert.ToDateTime(Eval("Deadline")).ToString("dd MMM yyyy") %></td>
                            <td style="text-align: right;">
                                <a href='SubmitWork.aspx?projectId=<%# Eval("ProjectId") %>' class="btn-submit-work">
                                    Submit Work 🚀
                                </a>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                            </tbody>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>

                <asp:Label ID="lblNoActiveProjects" runat="server" Visible="false" Text="You have no active projects currently in progress." Style="color: #5a6e5f; font-size: 14px; display: block; text-align: center; padding: 20px 0;"></asp:Label>
            </div>
        </asp:Panel>

        <!-- Quick Actions -->
        <div class="dashboard-section">
            <h2>Quick Actions</h2>
            <div class="quick-actions">

                <asp:Panel ID="pnlFreelancerActions" runat="server" Visible="false">
                    <a href="BrowseProjects.aspx" class="action-card">
                        <div class="action-icon">&#128269;</div>
                        <div class="action-text">
                            <h4>Browse Projects</h4>
                            <p>Find new opportunities</p>
                        </div>
                    </a>
                </asp:Panel>

                <asp:Panel ID="pnlEmployerActions" runat="server" Visible="false">
                    <a href="PostProject.aspx" class="action-card">
                        <div class="action-icon">&#43;</div>
                        <div class="action-text">
                            <h4>Post a Project</h4>
                            <p>Create a new listing</p>
                        </div>
                    </a>
                </asp:Panel>

                <a href="MyProjects.aspx" class="action-card">
                    <div class="action-icon">&#128188;</div>
                    <div class="action-text">
                        <h4>My Projects</h4>
                        <p>View your projects</p>
                    </div>
                </a>

                <a href="Wallet.aspx" class="action-card">
                    <div class="action-icon">&#128176;</div>
                    <div class="action-text">
                        <h4>Wallet</h4>
                        <p>Manage your funds</p>
                    </div>
                </a>

                <a href="Notifications.aspx" class="action-card">
                    <div class="action-icon">&#128276;</div>
                    <div class="action-text">
                        <h4>Notifications</h4>
                        <p>Check your alerts</p>
                    </div>
                </a>

                <a href="ManageProfile.aspx" class="action-card">
                    <div class="action-icon">&#9881;</div>
                    <div class="action-text">
                        <h4>Profile Settings</h4>
                        <p>Update your info</p>
                    </div>
                </a>

            </div>
        </div>

        <!-- Recent Activity -->
        <div class="dashboard-section">
            <h2>Recent Activity</h2>
            <div class="activity-list">
                <asp:Repeater ID="rptActivity" runat="server">
                    <ItemTemplate>
                        <div class="activity-item">
                            <div class="activity-dot"></div>
                            <span class="activity-text"><%# Eval("Description") %></span>
                            <span class="activity-date"><%# Eval("DateFormatted") %></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoActivity" runat="server" Visible="false">
                    <div class="empty-state">
                        <p>No recent activity yet. Start by browsing projects or updating your profile.</p>
                    </div>
                </asp:Panel>
            </div>
        </div>

        </asp:Panel><%-- /#pnlFreelancerDash --%>

        </div><%-- /.dashboard-scroll --%>

    </div>

</asp:Content>
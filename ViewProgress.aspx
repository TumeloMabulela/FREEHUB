<%@ Page Title="View Progress"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="ViewProgress.aspx.cs"
    Inherits="FreeHubProject.ViewProgress" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style type="text/css">
        /* ===== ViewProgress fixed-middle layout (matches My Proposals / SelectProposal).
           The page's main content is a NON-scrolling flex column filling the space between
           the fixed site header and footer. The breadcrumb/heading/description/message and
           the "Project Progress List (N)" + filter row stay fixed; only the progress-card
           list (.vp-list) scrolls. The right-side Progress Overview + Upcoming Deadlines
           sit in the non-scrolling area, so they stay put too, top-aligned to the filters.
           Scoped via .vp-* so nothing else on the site is affected. ===== */

        .freehub-main-content.vp-main {
            height: 100%;
            min-height: 0;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        .vp-main .view-progress-page {
            display: flex;
            flex-direction: column;
            min-height: 0;
            flex: 1 1 auto;
        }
        /* Static top band: breadcrumb/heading/description + status message. */
        .vp-main .notification-heading,
        .vp-main .vp-status-msg { flex: 0 0 auto; }

        /* The two-column region fills the remaining height. */
        .vp-layout {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 24px;
            align-items: stretch;
            flex: 1 1 auto;
            min-height: 0;
        }
        /* LEFT column: static heading+filters on top, scrollable list below. */
        .vp-list-col { display: flex; flex-direction: column; min-height: 0; min-width: 0; }

        /* "Project Progress List (N)" heading on the left, status filter pills on the
           right — same horizontal row. Static (never scrolls). */
        .vp-list-heading {
            flex: 0 0 auto;
            display: flex; align-items: center; justify-content: space-between;
            gap: 12px; flex-wrap: wrap; min-height: 38px; margin-bottom: 14px;
        }
        .vp-list-heading h3 { font-size: 16px; font-weight: 700; color: #111827; margin: 0; }

        /* STATUS FILTER TABS — same pill style as SelectProposal's proposal filters.
           Inline on the heading row, pushed to the right. */
        .vp-tabs { display: flex; gap: 8px; flex-wrap: wrap; margin: 0; align-items: center; }
        .vp-tab {
            display: inline-flex; align-items: center; gap: 8px;
            height: 38px; padding: 0 15px; border-radius: 25px;
            background: #f3f6f4; color: #2e7d56; border: 1px solid #e2e8e4;
            font-size: 13px; font-weight: 600; text-decoration: none; cursor: pointer;
            white-space: nowrap; line-height: 1;
            transition: background 0.2s ease, color 0.2s ease, border-color 0.2s ease;
        }
        .vp-tab:hover { background: #eaf6ee; color: #12833f; }
        .vp-tab .vp-tab-count {
            display: inline-flex; align-items: center; justify-content: center;
            min-width: 20px; height: 20px; padding: 0 6px; border-radius: 50%; margin-left: 2px;
            background: #e2e8e4; color: #5a6e62; font-size: 12px; font-weight: 700;
            transition: background 0.2s ease, color 0.2s ease;
        }
        .vp-tab.vp-tab-active { background: #2e7d56; color: #ffffff; border-color: #2e7d56; }
        .vp-tab.vp-tab-active:hover { background: #276b4a; color: #ffffff; }
        .vp-tab.vp-tab-active .vp-tab-count { background: rgba(255,255,255,.25); color: #ffffff; }

        /* INDEPENDENT PROJECT-LIST SCROLLBAR — the ONLY scrollable section. Fills the
           remaining height of the left column (flex), so it extends to just above the
           footer and scrolls its own overflow while everything else stays stationary. */
        .vp-list {
            flex: 1 1 auto;
            min-height: 0;
            overflow-y: auto;
            overflow-x: hidden;
            padding-right: 8px; /* keep cards clear of the scrollbar */
        }
        /* Slim green/white scrollbar — identical to BrowseProjects/SelectProposal. */
        .vp-list { scrollbar-width: thin; scrollbar-color: #2e7d56 #eef3ef; }
        .vp-list::-webkit-scrollbar { width: 8px; }
        .vp-list::-webkit-scrollbar-track { background: #eef3ef; border-radius: 8px; }
        .vp-list::-webkit-scrollbar-thumb {
            background: linear-gradient(180deg, #2e7d56, #72c94b);
            border-radius: 8px; border: 2px solid #eef3ef;
        }
        .vp-list::-webkit-scrollbar-thumb:hover { background: #2e7d56; }

        /* UPCOMING DEADLINES card — the card itself stays fixed; only the entry list
           inside it scrolls. The heading is pinned at the top. */
        .vp-deadlines-card { display: flex; flex-direction: column; min-height: 0; }
        .vp-deadlines-list {
            /* Bounded height so the card never grows indefinitely and fits above the
               fixed footer; the entries scroll once they exceed this height. */
            max-height: 240px;
            overflow-y: auto;
            overflow-x: hidden;
            padding-right: 6px; /* keep entries clear of the scrollbar */
            /* Same slim green/white scrollbar as the project progress list. */
            scrollbar-width: thin; scrollbar-color: #2e7d56 #eef3ef;
        }
        .vp-deadlines-list::-webkit-scrollbar { width: 8px; }
        .vp-deadlines-list::-webkit-scrollbar-track { background: #eef3ef; border-radius: 8px; }
        .vp-deadlines-list::-webkit-scrollbar-thumb {
            background: linear-gradient(180deg, #2e7d56, #72c94b);
            border-radius: 8px; border: 2px solid #eef3ef;
        }
        .vp-deadlines-list::-webkit-scrollbar-thumb:hover { background: #2e7d56; }
        /* Last entry: no trailing border/gap so the list bottom looks clean. */
        .vp-deadlines-list .vp-deadline-item:last-child { border-bottom: none; margin-bottom: 0; padding-bottom: 0; }

        /* RIGHT column: Progress Overview + Upcoming Deadlines, stationary in the
           non-scrolling middle. align-self:start keeps the Progress Overview top edge
           aligned with the filter row (both grid columns start at the same Y). */
        .vp-side {
            align-self: start;
            display: flex; flex-direction: column; gap: 20px;
            min-height: 0;
        }

        /* EMPTY STATE — centred inside the list area, FreeHUB palette. */
        .vp-empty {
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            text-align: center; min-height: 240px;
            background: #ffffff; border: 1px solid #e8ece9; border-radius: 14px;
            box-shadow: 0 1px 3px rgba(16, 40, 28, 0.06); padding: 36px 24px;
        }
        .vp-empty-icon {
            width: 92px; height: 92px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 18px; background: #e5f4ea; color: #2e7d56; font-size: 40px;
        }
        .vp-empty-title { margin: 0 0 8px; color: #173f2c; font-size: 20px; font-weight: 700; }
        .vp-empty-text { margin: 0; color: #7b878d; font-size: 14px; }

        /* ===== Responsive ===== */
        /* Below 900px the fixed-middle model is released to natural flow: the whole page
           scrolls, the right panels drop under the list. */
        @media (max-width: 900px) {
            .freehub-main-content.vp-main { height: auto; overflow: visible; display: block; }
            .vp-main .view-progress-page { display: block; flex: none; }
            .vp-layout { grid-template-columns: 1fr; display: grid; flex: none; }
            .vp-list-col { display: block; }
            .vp-list { flex: none; max-height: 60vh; }
            .vp-side { align-self: auto; }
        }
    </style>

    <div class="freehub-dashboard-layout">
        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content vp-main">
            <div class="view-progress-page">

                <!-- BREADCRUMB & HEADING (static) -->
                <div class="notification-heading" style="margin-bottom: 18px;">
                    <div class="notification-breadcrumb">
                        <a href="<%= ResolveUrl("~/Dashboard.aspx") %>" class="breadcrumb-link">Dashboard</a> <span>›</span>
                        <a href="<%= ResolveUrl("~/MyProjects.aspx") %>" class="breadcrumb-link">Projects</a> <span>›</span>
                        <strong>View Progress (<asp:Literal ID="litUserRoleHeader" runat="server" />)</strong>
                    </div>
                    <h1>View Progress</h1>
                    <p style="color: #6b7280; font-size: 14px; margin: 0;">Track the real-time progress of your projects in one place.</p>
                </div>

                <!-- STATUS MESSAGE (static) -->
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="vp-status-msg" style="padding: 12px 16px; border-radius: 8px; margin-bottom: 18px; font-size: 14px;">
                    <asp:Label ID="lblMessage" runat="server" />
                </asp:Panel>

                <!-- MAIN GRID LAYOUT (fills remaining height) -->
                <div class="vp-layout">

                    <!-- LEFT COLUMN: static heading+filters, then scrollable list -->
                    <div class="vp-list-col">

                        <!-- "Project Progress List (N)" on the left; filter pills on the
                             right — same row (matches My Proposals). Static. -->
                        <div class="vp-list-heading">
                            <h3>Project Progress List (<asp:Literal ID="litListCount" runat="server" Text="0" />)</h3>

                            <!-- STATUS FILTER TABS: All Projects | In Progress | Completed.
                                 Each tab's label + count is set entirely from code-behind on
                                 the LinkButton Text so it survives postbacks. "In Progress" is
                                 the default selected tab (set server-side). -->
                            <asp:Panel ID="pnlFilterTabs" runat="server" CssClass="vp-tabs">
                                <asp:LinkButton ID="lnkTabAll" runat="server" CssClass="vp-tab"
                                    CommandName="All" OnCommand="FilterTab_Command" CausesValidation="false" />
                                <asp:LinkButton ID="lnkTabInProgress" runat="server" CssClass="vp-tab"
                                    CommandName="InProgress" OnCommand="FilterTab_Command" CausesValidation="false" />
                                <asp:LinkButton ID="lnkTabCompleted" runat="server" CssClass="vp-tab"
                                    CommandName="Completed" OnCommand="FilterTab_Command" CausesValidation="false" />
                            </asp:Panel>
                        </div>

                        <!-- Independent scrollable list container (hidden when empty). -->
                        <asp:Panel ID="pnlListWrap" runat="server" CssClass="vp-list">
                        <asp:Repeater ID="rptProgressProjects" runat="server" OnItemCommand="rptProgressProjects_ItemCommand">
                            <ItemTemplate>
                                <div style="background: #fff; border: 1px solid #e5e7eb; border-radius: 12px; padding: 20px; margin-bottom: 14px;">
                                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px; gap: 12px;">
                                        <div style="min-width: 0;">
                                            <h4 style="font-size: 15px; font-weight: 700; color: #111827; margin: 0 0 4px; overflow-wrap: anywhere; word-break: break-word;"><%# TitleHelper.TitleCase(Convert.ToString(Eval("Title"))) %></h4>
                                            <span style="font-size: 13px; color: #6b7280;"><%# Eval("PartnerLabel") %>: <%# Eval("PartnerName") %></span>
                                        </div>
                                        <span style='<%# GetStatusBadgeStyle(Eval("Status").ToString()) %>'><%# Eval("Status") %></span>
                                    </div>

                                    <!-- Progress Bar -->
                                    <div style="margin: 16px 0 12px;">
                                        <div style="display: flex; justify-content: space-between; font-size: 12px; color: #6b7280; margin-bottom: 4px;">
                                            <span>Progress</span>
                                            <span style="font-weight: 600; color: #111827;"><%# Eval("ProgressPercent") %>%</span>
                                        </div>
                                        <div style="background: #e5e7eb; height: 8px; border-radius: 4px; overflow: hidden;">
                                            <div style='<%# "background: " + GetProgressBarColor(Eval("Status").ToString()) + "; width: " + Eval("ProgressPercent") + "%; height: 100%; border-radius: 4px;" %>'></div>
                                        </div>
                                    </div>

                                    <!-- WORKFLOW ACTION BUTTONS -->
                                    <div style="display: flex; gap: 10px; margin-bottom: 12px; align-items: center;">
                                        
                                        <!-- FREELANCER: Start Project Button (Visible if Assigned/Approved & Not Started/Open) -->
                                        <asp:Button ID="btnStartProj" runat="server" Text="▶ Start Project" CommandName="StartProject" CommandArgument='<%# Eval("ProjectId") %>'
                                            Visible='<%# UserType == "Freelancer" && Eval("Status").ToString() == "In Progress" && Convert.ToInt32(Eval("IsStarted")) == 0 %>'
                                            style="background: #059669; color: #fff; border: none; padding: 6px 14px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer;" />

                                        <!-- FREELANCER: Submit Work Button -->
                                        <asp:Button ID="btnSubmitWork" runat="server" Text="📁 Submit Work" CommandName="GoToSubmitWork" CommandArgument='<%# Eval("ProjectId") %>'
                                            Visible='<%# UserType == "Freelancer" && (Eval("Status").ToString() == "In Progress" || Eval("Status").ToString() == "Under Review") %>'
                                            style="background: #2563eb; color: #fff; border: none; padding: 6px 14px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer;" />

                                        <!-- EMPLOYER: Review Work / Approve / Reject Buttons -->
                                        <asp:Button ID="btnReview" runat="server" Text="🔍 Review Work" CommandName="ReviewWork" CommandArgument='<%# Eval("ProjectId") %>'
                                            Visible='<%# UserType == "Employer" && Eval("Status").ToString() == "Under Review" %>'
                                            style="background: #d97706; color: #fff; border: none; padding: 6px 14px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer;" />

                                    </div>

                                    <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid #f3f4f6; padding-top: 12px; font-size: 12px; color: #6b7280;">
                                        <span>📅 Budget: R<%# Convert.ToDecimal(Eval("Budget")).ToString("N2") %> &nbsp;&nbsp;|&nbsp;&nbsp; Deadline: <%# Convert.ToDateTime(Eval("Deadline")).ToString("dd MMM yyyy") %></span>
                                        <asp:LinkButton ID="btnDetails" runat="server" CommandName="ViewDetails" CommandArgument='<%# Eval("ProjectId") %>' style="color: #2563eb; text-decoration: none; font-weight: 600;">View Details ›</asp:LinkButton>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        </asp:Panel><%-- /.vp-list (pnlListWrap) --%>

                        <!-- EMPTY STATE: centred inside the list area, shown when the selected
                             filter has no projects (mutually exclusive with the list). The
                             heading/description are set per filter + role in code-behind. -->
                        <asp:Panel ID="pnlNoProjects" runat="server" Visible="false" CssClass="vp-empty">
                            <div class="vp-empty-icon" aria-hidden="true">📊</div>
                            <h3 class="vp-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="No projects found." /></h3>
                            <p class="vp-empty-text"><asp:Literal ID="litEmptyText" runat="server" Text="Your projects will appear here when they become available." /></p>
                        </asp:Panel>
                    </div>

                    <!-- RIGHT COLUMN: PROGRESS BREAKDOWN & DEADLINES (static, top-aligned) -->
                    <div class="vp-side">
                        
                        <!-- Progress Overview Widget -->
                        <div style="background: #fff; border: 1px solid #e5e7eb; border-radius: 12px; padding: 20px; text-align: center;">
                            <h3 style="font-size: 15px; font-weight: 700; color: #111827; text-align: left; margin: 0 0 16px;">Progress Overview</h3>
                            
                            <div style="width: 120px; height: 120px; border: 10px solid #e5e7eb; border-top-color: #137333; border-right-color: #137333; border-radius: 50%; margin: 0 auto 16px; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                                <span style="font-size: 22px; font-weight: 700; color: #111827;"><asp:Literal ID="litPieAvg" runat="server" Text="0%" /></span>
                                <span style="font-size: 11px; color: #6b7280;">Average</span>
                            </div>

                            <div style="text-align: left; display: flex; flex-direction: column; gap: 8px; border-top: 1px solid #f3f4f6; padding-top: 14px; font-size: 13px;">
                                <div style="display: flex; justify-content: space-between; align-items: center;">
                                    <span style="display: flex; align-items: center; gap: 6px;"><span style="width: 8px; height: 8px; background: #137333; border-radius: 50%;"></span> Completed</span>
                                    <span style="font-weight: 600; color: #374151;"><asp:Literal ID="litCountCompleted" runat="server" Text="0" /></span>
                                </div>
                                <div style="display: flex; justify-content: space-between; align-items: center;">
                                    <span style="display: flex; align-items: center; gap: 6px;"><span style="width: 8px; height: 8px; background: #2563eb; border-radius: 50%;"></span> In Progress / Review</span>
                                    <span style="font-weight: 600; color: #374151;"><asp:Literal ID="litCountInProgress" runat="server" Text="0" /></span>
                                </div>
                            </div>
                        </div>

                        <!-- Upcoming Deadlines Widget — heading fixed, entries scroll inside -->
                        <div class="vp-deadlines-card" style="background: #fff; border: 1px solid #e5e7eb; border-radius: 12px; padding: 20px;">
                            <h3 style="font-size: 15px; font-weight: 700; color: #111827; margin: 0 0 14px; flex: 0 0 auto;">Upcoming Deadlines</h3>

                            <!-- Only this list scrolls; the card and heading stay put. -->
                            <div class="vp-deadlines-list">
                            <asp:Repeater ID="rptDeadlines" runat="server">
                                <ItemTemplate>
                                    <div class="vp-deadline-item" style="display: flex; justify-content: space-between; align-items: center; padding-bottom: 10px; margin-bottom: 10px; border-bottom: 1px solid #f3f4f6;">
                                        <div>
                                            <strong style="font-size: 13px; color: #111827; display: block;"><%# TitleHelper.TitleCase(Convert.ToString(Eval("Title"))) %></strong>
                                            <small style="color: #6b7280; font-size: 11px;">Due: <%# Convert.ToDateTime(Eval("Deadline")).ToString("dd MMM yyyy") %></small>
                                        </div>
                                        <span style='<%# GetDeadlineBadgeStyle(Eval("Status").ToString(), Eval("Deadline")) %>'><%# GetDeadlineLabel(Eval("Status").ToString(), Eval("Deadline")) %></span>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                            </div>
                        </div>

                    </div>

                </div>

            </div>
        </section>
    </div>
</asp:Content>

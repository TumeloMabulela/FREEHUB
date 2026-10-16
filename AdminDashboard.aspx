<%@ Page Title="Admin Dashboard"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="AdminDashboard.aspx.cs"
    Inherits="FreeHubProject.AdminDashboard" %>

<asp:Content ID="AdminDashHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="<%= ResolveUrl("~/AdminDashboard.css") %>?v=1" rel="stylesheet" type="text/css" />
</asp:Content>

<asp:Content ID="AdminDashContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="ad-shell">

        <!-- ============================================================
             CONTEXTUAL SIDEBAR (secondary tools — NOT a copy of the top nav)
             ============================================================ -->
        <aside class="ad-sidebar">

            <a href="Default.aspx" class="ad-back">
                <span class="ad-back-circle" aria-hidden="true">&#8592;</span>
                <span>Back to site</span>
            </a>

            <!-- Quick Actions (sidebar) -->
            <div class="ad-side-section">
                <div class="ad-side-title"><span class="ad-side-ic" aria-hidden="true">&#9889;</span> Quick Actions</div>
                <a href="AdminDisputes.aspx" class="ad-side-link">
                    <span class="ad-side-link-ic ad-ic-green" aria-hidden="true">&#128196;</span>
                    <span>New dispute</span>
                </a>
                <a href="AdminRefunds.aspx" class="ad-side-link">
                    <span class="ad-side-link-ic ad-ic-blue" aria-hidden="true">&#128179;</span>
                    <span>Process refund</span>
                </a>
                <a href="AdminWithdrawals.aspx" class="ad-side-link">
                    <span class="ad-side-link-ic ad-ic-orange" aria-hidden="true">&#127974;</span>
                    <span>Process withdrawal</span>
                </a>
                <a href="AdminInbox.aspx" class="ad-side-link">
                    <span class="ad-side-link-ic ad-ic-purple" aria-hidden="true">&#9993;</span>
                    <span>Open support inbox</span>
                </a>
            </div>

            <!-- Filters (operate on the Recent Activity feed via querystring) -->
            <div class="ad-side-section">
                <div class="ad-side-title"><span class="ad-side-ic" aria-hidden="true">&#128269;</span> Filters</div>
                <a id="fltAll" runat="server" href="AdminDashboard.aspx?filter=all" class="ad-filter">
                    <span class="ad-dot ad-dot-green"></span>
                    <span class="ad-filter-label">All requests</span>
                    <span class="ad-filter-count"><asp:Literal ID="litCountAll" runat="server" Text="0" /></span>
                </a>
                <a id="fltOpen" runat="server" href="AdminDashboard.aspx?filter=open" class="ad-filter">
                    <span class="ad-dot ad-dot-amber"></span>
                    <span class="ad-filter-label">Open only</span>
                    <span class="ad-filter-count"><asp:Literal ID="litCountOpen" runat="server" Text="0" /></span>
                </a>
                <a id="fltResolved" runat="server" href="AdminDashboard.aspx?filter=resolved" class="ad-filter">
                    <span class="ad-dot ad-dot-grey"></span>
                    <span class="ad-filter-label">Resolved</span>
                    <span class="ad-filter-count"><asp:Literal ID="litCountResolved" runat="server" Text="0" /></span>
                </a>
            </div>

            <!-- Status Summary (live counts) -->
            <div class="ad-side-section">
                <div class="ad-side-title"><span class="ad-side-ic" aria-hidden="true">&#128202;</span> Status Summary</div>
                <div class="ad-summary">
                    <span class="ad-dot ad-dot-green"></span>
                    <span class="ad-summary-label">Open disputes</span>
                    <span class="ad-summary-val"><asp:Literal ID="litSumDisputes" runat="server" Text="0" /></span>
                </div>
                <div class="ad-summary">
                    <span class="ad-dot ad-dot-amber"></span>
                    <span class="ad-summary-label">Pending refunds</span>
                    <span class="ad-summary-val"><asp:Literal ID="litSumRefunds" runat="server" Text="0" /></span>
                </div>
                <div class="ad-summary">
                    <span class="ad-dot ad-dot-purple"></span>
                    <span class="ad-summary-label">Pending withdrawals</span>
                    <span class="ad-summary-val"><asp:Literal ID="litSumWithdrawals" runat="server" Text="0" /></span>
                </div>
            </div>

        </aside>

        <!-- ============================================================
             MAIN CONTENT
             ============================================================ -->
        <main class="ad-main">

            <!-- Header row: welcome + date/time card -->
            <div class="ad-header">
                <div class="ad-header-text">
                    <div class="ad-eyebrow">WELCOME BACK, <asp:Literal ID="litAdminName" runat="server" /></div>
                    <h1 class="ad-title"><span class="ad-navy">Admin</span> <span class="ad-green">Control Panel</span></h1>
                    <p class="ad-desc">Manage disputes, refunds, withdrawals and support messages all in one place.</p>
                </div>
                <div class="ad-datecard">
                    <span class="ad-datecard-ic" aria-hidden="true">&#128197;</span>
                    <div class="ad-datecard-text">
                        <span class="ad-datecard-date"><asp:Literal ID="litTodayDate" runat="server" /></span>
                        <span class="ad-datecard-time"><asp:Literal ID="litTodayTime" runat="server" /></span>
                    </div>
                </div>
            </div>

            <!-- Four statistics cards -->
            <div class="ad-stats">

                <div class="ad-stat ad-stat-green">
                    <div class="ad-stat-ic" aria-hidden="true">&#128196;</div>
                    <div class="ad-stat-num"><asp:Literal ID="litOpenDisputes" runat="server" Text="0" /></div>
                    <div class="ad-stat-ttl">Open disputes</div>
                    <div class="ad-stat-sub">Requires your attention</div>
                    <a href="AdminDisputes.aspx" class="ad-stat-btn">Manage disputes <span aria-hidden="true">&#8594;</span></a>
                </div>

                <div class="ad-stat ad-stat-blue">
                    <div class="ad-stat-ic" aria-hidden="true">&#128179;</div>
                    <div class="ad-stat-num"><asp:Literal ID="litPendingRefunds" runat="server" Text="0" /></div>
                    <div class="ad-stat-ttl">Pending refunds</div>
                    <div class="ad-stat-sub"><asp:Literal ID="litRefundSub" runat="server" /></div>
                    <a href="AdminRefunds.aspx" class="ad-stat-btn">Review refunds <span aria-hidden="true">&#8594;</span></a>
                </div>

                <div class="ad-stat ad-stat-orange">
                    <div class="ad-stat-ic" aria-hidden="true">&#127974;</div>
                    <div class="ad-stat-num"><asp:Literal ID="litPendingWithdrawals" runat="server" Text="0" /></div>
                    <div class="ad-stat-ttl">Pending withdrawals</div>
                    <div class="ad-stat-sub"><asp:Literal ID="litWithdrawalSub" runat="server" /></div>
                    <a href="AdminWithdrawals.aspx" class="ad-stat-btn">Review withdrawals <span aria-hidden="true">&#8594;</span></a>
                </div>

                <div class="ad-stat ad-stat-purple">
                    <div class="ad-stat-ic" aria-hidden="true">&#9993;</div>
                    <div class="ad-stat-num"><asp:Literal ID="litUnreadHelp" runat="server" Text="0" /></div>
                    <div class="ad-stat-ttl">Unread support messages</div>
                    <div class="ad-stat-sub"><asp:Literal ID="litHelpSub" runat="server" /></div>
                    <a href="AdminInbox.aspx" class="ad-stat-btn">Open support inbox <span aria-hidden="true">&#8594;</span></a>
                </div>

            </div>

            <!-- Recent Activity (60%) + Quick Actions (40%) -->
            <div class="ad-lower">

                <section class="ad-panel ad-activity">
                    <div class="ad-panel-head">
                        <h2 class="ad-panel-title"><span class="ad-panel-ic" aria-hidden="true">&#128336;</span> Recent Activity</h2>
                        <a href="AdminDisputes.aspx" class="ad-viewall">View all <span aria-hidden="true">&#8594;</span></a>
                    </div>

                    <div class="ad-table-wrap">
                        <table class="ad-table">
                            <thead>
                                <tr>
                                    <th>Type</th>
                                    <th>Description</th>
                                    <th>User</th>
                                    <th>Date</th>
                                    <th>Status</th>
                                    <th class="ad-th-actions">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptActivity" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td>
                                                <span class='ad-type <%# TypeBadgeClass(Eval("type")) %>'>
                                                    <%# Server.HtmlEncode(Convert.ToString(Eval("type"))) %>
                                                </span>
                                            </td>
                                            <td class="ad-td-desc">
                                                <%# Server.HtmlEncode(Convert.ToString(Eval("description"))) %>
                                                <span class="ad-ref">#<%# Server.HtmlEncode(Convert.ToString(Eval("refId"))) %></span>
                                            </td>
                                            <td><%# Server.HtmlEncode(Convert.ToString(Eval("userName"))) %></td>
                                            <td class="ad-td-date"><%# FormatActivityDate(Eval("activityDate")) %></td>
                                            <td>
                                                <span class='ad-badge <%# StatusBadgeClass(Eval("status")) %>'>
                                                    <%# Server.HtmlEncode(Convert.ToString(Eval("status"))) %>
                                                </span>
                                            </td>
                                            <td class="ad-td-actions">
                                                <a href='<%# ActivityActionUrl(Eval("type"), Eval("refId")) %>'
                                                   class="ad-row-action" title="Review">&#8942;</a>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>

                        <asp:Panel ID="pnlActivityEmpty" runat="server" CssClass="ad-empty" Visible="false">
                            <div class="ad-empty-ic" aria-hidden="true">&#128203;</div>
                            <h3>No recent activity</h3>
                            <p>Disputes, refunds and withdrawals will appear here as they come in.</p>
                        </asp:Panel>
                    </div>
                </section>

                <section class="ad-panel ad-quick">
                    <div class="ad-panel-head">
                        <h2 class="ad-panel-title"><span class="ad-panel-ic" aria-hidden="true">&#9889;</span> Quick Actions</h2>
                    </div>

                    <div class="ad-quick-grid">
                        <a href="AdminDisputes.aspx" class="ad-quick-card">
                            <span class="ad-quick-ic ad-ic-green" aria-hidden="true">&#128196;</span>
                            <span class="ad-quick-ttl">Manage disputes</span>
                            <span class="ad-quick-sub">View and resolve dispute cases.</span>
                            <span class="ad-quick-arrow" aria-hidden="true">&#8594;</span>
                        </a>
                        <a href="AdminRefunds.aspx" class="ad-quick-card">
                            <span class="ad-quick-ic ad-ic-blue" aria-hidden="true">&#128179;</span>
                            <span class="ad-quick-ttl">Process refunds</span>
                            <span class="ad-quick-sub">Approve or decline refund requests.</span>
                            <span class="ad-quick-arrow" aria-hidden="true">&#8594;</span>
                        </a>
                        <a href="AdminWithdrawals.aspx" class="ad-quick-card">
                            <span class="ad-quick-ic ad-ic-orange" aria-hidden="true">&#127974;</span>
                            <span class="ad-quick-ttl">Process withdrawals</span>
                            <span class="ad-quick-sub">Review withdrawal requests.</span>
                            <span class="ad-quick-arrow" aria-hidden="true">&#8594;</span>
                        </a>
                        <a href="AdminInbox.aspx" class="ad-quick-card">
                            <span class="ad-quick-ic ad-ic-purple" aria-hidden="true">&#9993;</span>
                            <span class="ad-quick-ttl">View support inbox</span>
                            <span class="ad-quick-sub">Respond to user messages.</span>
                            <span class="ad-quick-arrow" aria-hidden="true">&#8594;</span>
                        </a>
                    </div>
                </section>

            </div>

        </main>

    </div>

</asp:Content>

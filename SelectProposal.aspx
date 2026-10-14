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

        /* One horizontal card per proposal. overflow-x:hidden + shrinkable children
           guarantee the card never pushes a horizontal scrollbar. */
        .pl-card {
            display: flex;
            align-items: center;
            gap: 12px;
            background: #ffffff;
            border: 1px solid #e8ece9;
            border-radius: 12px;
            padding: 14px 16px;
            margin-bottom: 12px;
            box-shadow: 0 1px 3px rgba(16, 40, 28, 0.06);
            overflow: hidden;
        }
        .pl-card:hover { box-shadow: 0 6px 16px rgba(16, 40, 28, 0.10); }

        /* Freelancer block — shrinkable */
        .pl-freelancer { display: flex; align-items: center; gap: 10px; flex: 1 1 150px; min-width: 0; }
        .pl-avatar {
            width: 42px; height: 42px; border-radius: 50%; flex-shrink: 0;
            background: #2e7d56; color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-weight: bold; font-size: 14px;
        }
        .pl-freelancer-text { min-width: 0; display: flex; flex-direction: column; }
        .pl-name { color: #173f2c; font-size: 13px; font-weight: 700;
                   white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .pl-role { color: #7b878d; font-size: 12px; }

        /* A labelled field (label on top, value below) — all shrinkable */
        .pl-field { display: flex; align-items: center; gap: 8px; min-width: 0; }
        .pl-field-text { display: flex; flex-direction: column; min-width: 0; }
        .pl-label { color: #8a949a; font-size: 11px; white-space: nowrap; }
        .pl-value { color: #173f2c; font-size: 13px; font-weight: 700;
                    white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        .pl-project { flex: 1 1 110px; display: flex; flex-direction: column; gap: 2px; min-width: 0; }
        .pl-project-name { color: #173f2c; font-size: 13px; font-weight: 700;
                           white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        .pl-rate { flex: 1 1 auto; min-width: 0; }
        .pl-rate .pl-value { color: #10261c; }
        .pl-time { flex: 0 1 auto; min-width: 0; }
        .pl-date { flex: 0 1 auto; min-width: 0; }

        /* Round pastel icon chips (smaller to save width) */
        .pl-icon {
            width: 30px; height: 30px; border-radius: 50%; flex-shrink: 0;
            display: inline-flex; align-items: center; justify-content: center; font-size: 14px;
        }
        .pl-icon-rate { background: #e5f4ea; }
        .pl-icon-time { background: #e6f0ff; }
        .pl-icon-date { background: #f3e8ff; }

        /* Status badge */
        .pl-status-wrap { flex: 0 0 auto; }
        .pl-badge {
            display: inline-block; padding: 5px 10px; border-radius: 14px;
            font-size: 11px; font-weight: 700; text-align: center; white-space: nowrap;
        }
        .pl-badge-pending  { color: #8a5a00; background: #fff3cd; }
        .pl-badge-approved { color: #155724; background: #d4edda; }
        .pl-badge-rejected { color: #721c24; background: #f8d7da; }
        .pl-badge-withdrawn{ color: #4b5563; background: #e5e7eb; }
        .pl-badge-default  { color: #4b5563; background: #eef2f5; }

        /* Action buttons (compact so they fit without overflow) */
        .pl-actions { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
        .pl-btn {
            display: inline-flex; align-items: center; justify-content: center;
            padding: 8px 12px; border-radius: 20px; font-size: 12px; font-weight: 600;
            cursor: pointer; white-space: nowrap; border: 1px solid transparent;
        }
        .pl-btn-view {
            background: #ffffff; color: #2e7d56; border: 1.5px solid #2e7d56;
        }
        .pl-btn-view:hover { background: #eaf6ee; }
        .pl-btn-delete { background: #dc3545; color: #ffffff; border: 1px solid #dc3545; }
        .pl-btn-delete:hover { background: #c82333; }
        .pl-btn-select { background: #2e7d56; color: #ffffff; border: 1px solid #2e7d56; }
        .pl-btn-select:hover { opacity: .93; }

        /* RIGHT container: tips stacked vertically, sticky so they stay in view. */
        .pl-tips { position: sticky; top: 90px; }

        /* ===== Responsive ===== */
        /* Tablet: let the card wrap neatly */
        @media (max-width: 1100px) {
            .pl-card { flex-wrap: wrap; }
            .pl-freelancer { flex: 1 1 100%; }
            .pl-project { flex: 1 1 100%; }
            .pl-actions { margin-left: 0; flex: 1 1 100%; }
        }
        /* Below this width the two columns stack: list on top, tips below. */
        @media (max-width: 900px) {
            .pl-layout { grid-template-columns: 1fr; }
            .pl-list { max-height: 60vh; }
            .pl-tips { position: static; }
        }
        /* Mobile: stack everything vertically, buttons full width */
        @media (max-width: 640px) {
            .pl-card { flex-direction: column; align-items: stretch; gap: 12px; }
            .pl-field, .pl-freelancer { flex: 1 1 100%; }
            .pl-actions { flex-direction: column; align-items: stretch; }
            .pl-btn { width: 100%; }
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

                    <!-- Scrollable list container (left) -->
                    <div class="pl-list">
                    <asp:Repeater ID="rptProposals" runat="server" OnItemCommand="rptProposals_ItemCommand">
                        <ItemTemplate>
                            <%-- Compact horizontal proposal card. No cover letter / proposal
                                 content is shown here — it opens only via "View Proposal". --%>
                            <div class="pl-card">

                                <!-- Freelancer: avatar + name + role -->
                                <div class="pl-freelancer">
                                    <div class="pl-avatar">
                                        <%# Eval("freelancerName").ToString().Substring(0,1).ToUpper() %><%# Eval("freelancerName").ToString().Contains(" ") ? Eval("freelancerName").ToString().Split(' ')[1].Substring(0,1).ToUpper() : "" %>
                                    </div>
                                    <div class="pl-freelancer-text">
                                        <strong class="pl-name"><%# Server.HtmlEncode(Convert.ToString(Eval("freelancerName"))) %></strong>
                                        <span class="pl-role">Freelancer</span>
                                    </div>
                                </div>

                                <!-- Project name (bold, no description) -->
                                <div class="pl-field pl-project">
                                    <span class="pl-label">Project</span>
                                    <strong class="pl-project-name"><%# Server.HtmlEncode(Convert.ToString(Eval("projectTitle"))) %></strong>
                                </div>

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

                                <!-- Status badge -->
                                <div class="pl-field pl-status-wrap">
                                    <span class='<%# "pl-badge " + GetStatusClass(Eval("status")) %>'><%# Server.HtmlEncode(Convert.ToString(Eval("status"))) %></span>
                                </div>

                                <!-- Actions -->
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

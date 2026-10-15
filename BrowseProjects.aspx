<%@ Page Title="Browse Projects"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="BrowseProjects.aspx.cs"
    Inherits="FreeHubProject.BrowseProjects" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">
</asp:Content>

<asp:Content ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <style type="text/css">
        /* ===== Dashboard-style fixed sub-layout for Browse Projects =====
           The shared fixed shell pins the header/footer and gives .page-content a
           definite flex height (the viewport minus header/footer).

           ROOT-CAUSE FIX: the shared .freehub-dashboard-layout uses `min-height:100%`,
           which does NOT give it a definite height — so a child's `height:100%` could
           not resolve and the content grew, pushing the list behind the footer and
           making .page-content scroll (the browser scrollbar). Here we give THIS page's
           layout wrapper a DEFINITE `height:100%` so the whole chain
           (.page-content -> layout -> main -> project-content -> list) is height-bound
           and only the project list scrolls. Scoped via .browse-shell/.browse-main so
           no other page is affected. */
        .freehub-dashboard-layout.browse-shell {
            height: 100%;       /* definite height (parent .page-content is definite) */
            min-height: 0;
            overflow: hidden;   /* the layout row itself never scrolls */
        }
        /* .freehub-main-content.browse-main (two classes) matches the shared
           ".freehub-dashboard-layout > .freehub-main-content" specificity and, coming
           later in the cascade, wins — so overflow:hidden overrides the shared
           overflow-y:auto and the main column no longer scrolls (only the list does). */
        .freehub-main-content.browse-main {
            display: flex;
            flex-direction: column;
            min-height: 0;      /* let the scroll child shrink instead of growing */
            height: 100%;       /* fill the .page-content middle exactly */
            overflow: hidden;   /* no page-content scroll; the list scrolls instead */
        }

        /* (Sidebar height/no-scroll is handled globally in StyleSheet1.css.) */

        /* Fixed top band: the header row (heading + inline filters) and the
           project-count status line stay stationary; only the list scrolls. */
        .browse-main .browse-header-row,
        .browse-main .filter-message {
            flex: 0 0 auto;
        }

        /* ===== Compact header row: heading left, filters inline on the right ===== */
        .browse-main .browse-header-row {
            display: flex;
            align-items: flex-end;              /* dropdowns/buttons line up with heading baseline */
            justify-content: space-between;
            gap: 24px;
            flex-wrap: wrap;                    /* wrap neatly on smaller screens */
            margin-bottom: 10px;
        }
        /* Heading keeps its left alignment but no longer reserves full-width spacing. */
        .browse-main .browse-header-row .post-page-heading {
            margin-bottom: 0;
            flex: 0 1 auto;
            min-width: 0;
        }
        /* Filters move inline to the right: drop the white card box (bg/border/padding)
           and size the control row to its content. Labels stay above each dropdown. */
        .browse-main .browse-filters {
            background: none;
            border: none;
            padding: 0;
            align-items: end;
            gap: 10px;
            grid-template-columns: repeat(3, minmax(110px, 150px)) auto auto;
        }
        /* Keep the project-count tight to the list, left-aligned. */
        .browse-main .filter-message {
            margin: 0 0 8px;
        }

        /* Responsive: stack the heading above the filters, filters wrap. */
        @media screen and (max-width: 1100px) {
            .browse-main .browse-header-row {
                flex-direction: column;
                align-items: stretch;
            }
            .browse-main .browse-filters {
                grid-template-columns: 1fr 1fr;
            }
        }

        /* The two-column region fills the remaining space; min-height:0 lets its
           inner columns scroll rather than push the layout taller. */
        .browse-main .browse-layout {
            flex: 1 1 auto;
            min-height: 0;
        }

        /* Stacked layout: stop pinning so the content flows and the shell's
           .page-content scrolls naturally (prevents clipping on small screens). */
        @media screen and (max-width: 1100px) {
            .freehub-dashboard-layout.browse-shell {
                height: auto;
                overflow: visible;
            }
            .freehub-main-content.browse-main {
                display: block;
                height: auto;
                overflow: visible;
            }
            .browse-main .browse-layout { min-height: 0; }
        }
    </style>

    <div class="freehub-dashboard-layout browse-shell">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content browse-main">

            <!-- HEADER ROW: heading on the left, filters inline on the right -->
            <div class="browse-header-row">

            <!-- PAGE HEADING -->
            <div class="post-page-heading">
                <h1>Browse Projects</h1>
                <p>Find projects that match your skills and interests.</p>
            </div>

            <!-- FILTERS -->
            <div class="browse-filters">

                <div class="filter-group">
                    <label>Category</label>
                    <asp:DropDownList ID="ddlCategory" runat="server" CssClass="filter-dropdown">
                        <asp:ListItem Value="">All Categories</asp:ListItem>
                        <asp:ListItem>Web Development</asp:ListItem>
                        <asp:ListItem>Software Development</asp:ListItem>
                        <asp:ListItem>Mobile Development</asp:ListItem>
                        <asp:ListItem>UI/UX Design</asp:ListItem>
                        <asp:ListItem>Graphic Design</asp:ListItem>
                        <asp:ListItem>Digital Marketing</asp:ListItem>
                        <asp:ListItem>Writing</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="filter-group">
                    <label>Budget Range</label>
                    <asp:DropDownList ID="ddlBudget" runat="server" CssClass="filter-dropdown">
                        <asp:ListItem Value="">All Budgets</asp:ListItem>
                        <asp:ListItem Value="1000-5000">R1,000 - R5,000</asp:ListItem>
                        <asp:ListItem Value="5000-10000">R5,000 - R10,000</asp:ListItem>
                        <asp:ListItem Value="10000-20000">R10,000 - R20,000</asp:ListItem>
                        <asp:ListItem Value="20000-999999">R20,000+</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="filter-group">
                    <label>Date Posted</label>
                    <asp:DropDownList ID="ddlDate" runat="server" CssClass="filter-dropdown">
                        <asp:ListItem Value="">Any Time</asp:ListItem>
                        <asp:ListItem Value="1">Today</asp:ListItem>
                        <asp:ListItem Value="7">Last 7 Days</asp:ListItem>
                        <asp:ListItem Value="30">Last 30 Days</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <asp:Button ID="btnFilter" runat="server" Text="Filter"
                    CssClass="filter-button" OnClick="btnFilter_Click" />
                <asp:Button ID="btnReset" runat="server" Text="Reset"
                    CssClass="reset-button" OnClick="btnReset_Click" />
            </div>

            </div><%-- /.browse-header-row --%>

            <!-- STATUS / PROJECT COUNT (above the project list) -->
            <asp:Label ID="lblFilterMessage" runat="server" CssClass="filter-message" />

            <!-- PROJECT LIST -->
            <div class="browse-layout">

                <!-- LEFT: PROJECT LIST -->
                <section class="projects-column">

                    <asp:Panel ID="pnlNoProjects" runat="server" Visible="false" CssClass="no-projects-message">
                        <h3>No projects available</h3>
                        <p>There are no open projects at the moment. Check back later or ask an employer to post a project.</p>
                    </asp:Panel>

                    <asp:Repeater ID="rptProjects" runat="server" OnItemCommand="rptProjects_ItemCommand">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnSelectProject" runat="server"
                                CssClass="project-card"
                                CommandName="SelectProject"
                                CommandArgument='<%# Eval("projectID") %>'>

                                <span class="project-info">
                                    <span class="project-name"><%# TitleHelper.TitleCase(Convert.ToString(Eval("title"))) %></span>
                                    <span class="project-category"><%# Eval("category") %></span>
                                    <span class="project-meta">
                                        Posted <%# TimeHelper.ToSast(Eval("dateCreated")).ToString("dd MMM yyyy") %>
                                    </span>
                                </span>
                                <span class="project-budget">
                                    <span>R<%# Convert.ToDecimal(Eval("budget")).ToString("N0") %></span>
                                    <small><%# Eval("budgetType").ToString() == "Fixed" ? "Fixed Price" : Eval("budgetType").ToString() == "Hourly" ? "Hourly Rate" : Eval("budgetType") %></small>
                                </span>

                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>

                </section>

                <!-- RIGHT: PROJECT DETAILS -->
                <section class="details-column">

                    <!-- Empty state -->
                    <asp:Panel ID="pnlNoSelection" runat="server" CssClass="no-selection-panel">
                        <h3>Select a project</h3>
                        <p>Click on a project from the list to view its full details, budget, deadline and employer information.</p>
                    </asp:Panel>

                    <!-- Project details (hidden until selected) -->
                    <asp:Panel ID="pnlProjectDetails" runat="server" Visible="false">

                        <!-- TWO-COLUMN HEADER: name + date (left ~40%), info grid (right ~60%) -->
                        <div class="pd-header">

                            <div class="pd-header-left">
                                <h2><asp:Label ID="lblProjectTitle" runat="server" /></h2>
                                <p class="posted-information">
                                    <asp:Label ID="lblPosted" runat="server" />
                                </p>
                            </div>

                            <!-- PROJECT INFO GRID (Budget | Deadline / Category | Experience) -->
                            <div class="details-grid">
                                <div class="detail-box">
                                    <div>
                                        <small>Budget</small>
                                        <strong><asp:Label ID="lblBudget" runat="server" /></strong>
                                    </div>
                                </div>
                                <div class="detail-box">
                                    <div>
                                        <small>Deadline</small>
                                        <strong><asp:Label ID="lblDeadline" runat="server" /></strong>
                                    </div>
                                </div>
                                <div class="detail-box">
                                    <div>
                                        <small>Category</small>
                                        <strong><asp:Label ID="lblCategory" runat="server" /></strong>
                                    </div>
                                </div>
                                <div class="detail-box">
                                    <div>
                                        <small>Experience Level</small>
                                        <strong><asp:Label ID="lblExperience" runat="server" /></strong>
                                    </div>
                                </div>
                            </div>

                        </div>

                        <div class="details-line"></div>

                        <h3>About the Project</h3>
                        <p class="details-description">
                            <asp:Label ID="lblDescription" runat="server" />
                        </p>

                        <div class="details-line"></div>

                        <!-- EMPLOYER -->
                        <div class="employer-section">
                            <h3>About the employer</h3>
                            <div class="employer-row">
                                <div class="employer-avatar">
                                    <asp:Label ID="lblEmployerInitials" runat="server" />
                                </div>
                                <div class="employer-information">
                                    <strong><asp:Label ID="lblEmployerName" runat="server" /></strong>
                                    <%-- Verified badge: shown only when the employer meets the
                                         verification condition (set server-side); hidden otherwise
                                         so unverified employers are not labelled as verified. --%>
                                    <asp:Panel ID="pnlEmployerVerified" runat="server" Visible="false" CssClass="employer-verified">
                                        <span class="employer-verified-tick" aria-hidden="true">&#10004;</span>
                                        <asp:Label ID="lblEmployerRating" runat="server" />
                                    </asp:Panel>
                                </div>
                            </div>
                        </div>

                        <!-- ACTIONS -->
                        <div class="project-actions">
                            <asp:Button ID="btnSubmitProposal" runat="server"
                                Text="Submit Proposal" CssClass="submit-button"
                                OnClick="btnSubmitProposal_Click" />
                            <asp:Button ID="btnViewDetails" runat="server"
                                Text="View Details &amp; Comment" CssClass="save-button"
                                OnClick="btnViewDetails_Click" />
                        </div>

                        <!-- COMMENTS SECTION - View on Project Details page -->

                        <asp:Label ID="lblProjectMessage" runat="server" CssClass="project-message" />

                    </asp:Panel>

                </section>

            </div>

        </section>

    </div>

    <script type="text/javascript">
        // Preserve the LEFT project-list scroll position across postbacks (e.g. when a
        // project is selected), so selecting a project doesn't jump the list back to top.
        (function () {
            var KEY = "fh_browse_list_scroll";
            function listEl() { return document.querySelector(".projects-column"); }

            // Restore after each render.
            function restore() {
                var el = listEl();
                if (!el) return;
                var v = sessionStorage.getItem(KEY);
                if (v !== null) el.scrollTop = parseInt(v, 10) || 0;
            }

            // Save continuously as the user scrolls, and right before any postback.
            function wire() {
                var el = listEl();
                if (!el) return;
                el.addEventListener("scroll", function () {
                    sessionStorage.setItem(KEY, el.scrollTop);
                });
            }

            if (document.readyState === "loading") {
                document.addEventListener("DOMContentLoaded", function () { wire(); restore(); });
            } else { wire(); restore(); }

            // ASP.NET WebForms: save just before the form posts back.
            document.addEventListener("submit", function () {
                var el = listEl();
                if (el) sessionStorage.setItem(KEY, el.scrollTop);
            }, true);
        })();
    </script>

</asp:Content>

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
        .dashboard-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 40px 20px;
        }

        .dashboard-welcome {
            margin-bottom: 35px;
        }

        .dashboard-welcome h1 {
            font-size: 28px;
            color: #173f2c;
            margin-bottom: 6px;
        }

        .dashboard-welcome p {
            color: #5a6e5f;
            font-size: 15px;
        }

        .dashboard-welcome .role-badge {
            display: inline-block;
            background-color: #e8f5e0;
            color: #2d6b3f;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 13px;
            font-weight: 600;
            margin-top: 8px;
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

        /* Quick Actions */
        .dashboard-section {
            margin-bottom: 35px;
        }

        .dashboard-section h2 {
            font-size: 20px;
            color: #173f2c;
            margin-bottom: 16px;
        }

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
    </style>
</asp:Content>

<asp:Content ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="dashboard-container">

        <!-- Welcome Section -->
        <div class="dashboard-welcome">
            <h1>Welcome back, <asp:Literal ID="litFirstName" runat="server" /></h1>
            <p>Here's an overview of your FreeHUB activity.</p>
            <span class="role-badge"><asp:Literal ID="litRole" runat="server" /></span>
        </div>

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

    </div>

</asp:Content>

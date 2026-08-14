<%@ Page Title="Notifications"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="Notifications.aspx.cs"
    Inherits="FreeHubProject.Notifications" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="freehub-dashboard-layout">
        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">
            <div class="notifications-page">
                <div class="notification-heading">
                    <div class="notification-breadcrumb">
                        Dashboard <span>›</span> Notifications
                    </div>
                    <h1>Notifications</h1>
                    <p>View your latest system alerts and updates.</p>
                </div>

                <!-- Status Panel 
                <asp:Panel ID="pnlNotificationStatus" runat="server" CssClass="notification-status" Visible="false">
                    <asp:Label ID="lblNotificationStatus" runat="server"></asp:Label>
                </asp:Panel>
                    -->
                <!-- TWO-CONTAINER LAYOUT -->
                <div class="notification-layout">

                    <!-- CONTAINER 1: NOTIFICATION SELECTION LIST -->
                    <div class="notification-list-panel">
                        <!-- Filter Tabs with Live Badges -->
                        <div class="notification-tabs">
                            <asp:Button ID="btnAll" runat="server" Text="All" CssClass="notification-tab" OnClick="btnAll_Click" />
                            <asp:Button ID="btnUnread" runat="server" Text="Unread" CssClass="notification-tab" OnClick="btnUnread_Click" />
                            <asp:Button ID="btnArchived" runat="server" Text="Archived" CssClass="notification-tab" OnClick="btnArchived_Click" />
                        </div>

                        <!-- Repeater List -->
                      <!-- Repeater List -->
<!-- Repeater List -->
<!-- Repeater List -->
<asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
    <ItemTemplate>
        <asp:LinkButton ID="btnSelectNotification" runat="server" CssClass="notification-item" CommandName="SelectNotification" CommandArgument='<%# Eval("Id") %>' Style="display: flex; align-items: center; justify-content: space-between; width: 100%; text-decoration: none; padding: 12px; background: #fff; border: 1px solid #e5e7eb; border-radius: 8px; margin-bottom: 8px;">
            
            <!-- Left Side: Icon and Title -->
            <div style="display: flex; align-items: center; gap: 12px; flex: 1; overflow: hidden;">
                <span class="notification-icon"><%# Eval("Icon") %></span>
                <span class="notification-information" style="text-align: left; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: #1f2937;">
    <strong><%# Eval("Title") %></strong>
</span>
            </div>

            <!-- Right Side: Timestamp and Arrow -->
            <div style="display: flex; align-items: center; gap: 8px; flex-shrink: 0; margin-left: 12px;">
                <span class="notification-time">
                    <small style="color: #6b7280; font-size: 11px;"><%# Eval("Time") %></small>
                </span>
                <span class="notification-arrow" style="font-weight: bold; color: #9ca3af;">›</span>
            </div>
        </asp:LinkButton>
    </ItemTemplate>
</asp:Repeater>       
                        <asp:Label ID="lblNoNotifications" runat="server" CssClass="no-notifications" Visible="false" Text="No notifications found."></asp:Label>
                    </div>

                    <!-- CONTAINER 2: SELECTED NOTIFICATION DISPLAY -->
                    <div class="notification-details-panel">
                        <div class="notification-details">
                            <div class="details-title">
                                <h3>Notification Details</h3>
                                <asp:Label ID="lblReadStatus" runat="server" CssClass="unread-badge" Text="Select one"></asp:Label>
                            </div>

                            <asp:Panel ID="pnlSelectedNotification" runat="server" Visible="false">
    <div class="selected-notification">
        <span class="selected-notification-icon">
            <asp:Label ID="lblSelectedIcon" runat="server"></asp:Label>
        </span>
        <div>
            <h3><asp:Label ID="lblSelectedTitle" runat="server"></asp:Label></h3>
            <p><asp:Label ID="lblSelectedDescription" runat="server"></asp:Label></p>
            <small><asp:Label ID="lblSelectedTime" runat="server"></asp:Label></small>
        </div>
    </div>

    <div class="notification-preview">
        <asp:Label ID="lblSelectedPreview" runat="server"></asp:Label>
    </div>

    <!-- Dynamic Action Buttons -->
    <asp:Button ID="btnViewMessage" runat="server" Text="View Message" CssClass="view-message-button" OnClick="btnViewMessage_Click" Visible="false" />
    <asp:Button ID="btnViewProject" runat="server" Text="View Project" CssClass="view-message-button" OnClick="btnViewProject_Click" Visible="false" style="background:#276738; margin-top:8px;" />

    <div class="notification-actions" style="margin-top: 12px;">
        <asp:Button ID="btnToggleRead" runat="server" Text="Mark as Read" CssClass="mark-read-button" OnClick="btnToggleRead_Click" />
        <asp:Button ID="btnToggleArchive" runat="server" Text="Archive" CssClass="archive-button" OnClick="btnToggleArchive_Click" />
    </div>
</asp:Panel>

                            <asp:Label ID="lblSelectNotification" runat="server" CssClass="select-notification-text" Text="Select a notification from the list to view its details."></asp:Label>
                        </div>
                    </div>

                </div>
            </div>
        </section>
    </div>
</asp:Content>
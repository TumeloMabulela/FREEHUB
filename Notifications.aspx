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


        <!-- Status message -->

        <asp:Panel ID="pnlNotificationStatus"
            runat="server"
            CssClass="notification-status"
            Visible="false">

            <asp:Label ID="lblNotificationStatus"
                runat="server">
            </asp:Label>

        </asp:Panel>


        <div class="notification-layout">

                    <!-- CONTAINER 1: NOTIFICATION SELECTION LIST -->
                    <div class="notification-list-panel">
                        <!-- Filter Tabs with Live Badges -->
                        <div class="notification-tabs">
                            <asp:Button ID="btnAll" runat="server" Text="All" CssClass="notification-tab" OnClick="btnAll_Click" />
                            <asp:Button ID="btnUnread" runat="server" Text="Unread" CssClass="notification-tab" OnClick="btnUnread_Click" />
                            <asp:Button ID="btnArchived" runat="server" Text="Archived" CssClass="notification-tab" OnClick="btnArchived_Click" />
                        </div>


                <!-- Notification list -->

                <asp:Repeater ID="rptNotifications"
                    runat="server"
                    OnItemCommand="rptNotifications_ItemCommand">

                    <ItemTemplate>

                        <asp:LinkButton ID="btnSelectNotification"
                            runat="server"
                            CssClass="notification-item"
                            CommandName="SelectNotification"
                            CommandArgument='<%# Eval("Id") %>'>


                            <span class="notification-icon">

                                <%# Eval("Icon") %>

                            </span>


                            <span class="notification-information">

                                <strong>

                                    <%# Eval("Title") %>

                                </strong>


                                <small>

                                    <%# Eval("Description") %>

                                </small>

                            </span>


                            <span class="notification-time">

                                <%# Eval("Time") %>

                            </span>


                            <span class="notification-arrow">

                                ›

                            </span>


                        </asp:LinkButton>

                    </ItemTemplate>

                </asp:Repeater>


                <asp:Label ID="lblNoNotifications"
                    runat="server"
                    CssClass="no-notifications"
                    Visible="false"
                    Text="No notifications found.">
                </asp:Label>


            </div>

                    <!-- CONTAINER 2: SELECTED NOTIFICATION DISPLAY -->
                    <div class="notification-details-panel">
                        <div class="notification-details">
                            <div class="details-title">
                                <h3>Notification Details</h3>
                                <asp:Label ID="lblReadStatus" runat="server" CssClass="unread-badge" Text="Select one"></asp:Label>
                            </div>


                    <asp:Panel ID="pnlSelectedNotification"
                        runat="server"
                        Visible="false">


                        <div class="selected-notification">

                            <span class="selected-notification-icon">

                                <asp:Label ID="lblSelectedIcon"
                                    runat="server">
                                </asp:Label>

                            </span>


                            <div>

                                <h3>

                                    <asp:Label ID="lblSelectedTitle"
                                        runat="server">
                                    </asp:Label>

                                </h3>


                                <p>

                                    <asp:Label ID="lblSelectedDescription"
                                        runat="server">
                                    </asp:Label>

                                </p>


                                <small>

                                    <asp:Label ID="lblSelectedTime"
                                        runat="server">
                                    </asp:Label>

                                </small>

                            </div>

                        </div>


                        <div class="notification-preview">

                            <asp:Label ID="lblSelectedPreview"
                                runat="server">
                            </asp:Label>

                        </div>


                        <!-- Opens StartChat.aspx -->

                        <asp:Button ID="btnViewMessage"
                            runat="server"
                            Text="View Message"
                            CssClass="view-message-button"
                            OnClick="btnViewMessage_Click" />


                        <div class="notification-actions">

                            <asp:Button ID="btnMarkRead"
                                runat="server"
                                Text="Mark as Read"
                                CssClass="mark-read-button"
                                OnClick="btnMarkRead_Click" />


                            <asp:Button ID="btnArchive"
                                runat="server"
                                Text="Archive"
                                CssClass="archive-button"
                                OnClick="btnArchive_Click" />

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
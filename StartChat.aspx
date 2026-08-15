<%@ Page Title="Messages"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="StartChat.aspx.cs"
    Inherits="FreeHubProject.StartChat" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="HeadContent"
    runat="server">
</asp:Content>


<asp:Content ID="Content2"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="start-chat-page">

        <!-- Page heading -->

        <div class="chat-page-heading">

            <div class="chat-breadcrumb">
                Dashboard
                <span>›</span>
                Messages
                <span>›</span>
                Start Chat
            </div>

            <h1>Start Chat</h1>

            <p>
                Select a user and begin a conversation.
            </p>

        </div>


        <!-- Status message -->

        <asp:Panel ID="pnlStatus"
            runat="server"
            CssClass="chat-status"
            Visible="false">

            <asp:Label ID="lblStatus"
                runat="server">
            </asp:Label>

        </asp:Panel>


        <!-- Main chat layout -->

        <div class="start-chat-layout">


            <!-- LEFT: Users -->

            <div class="chat-users-panel">


                <!-- Search -->

                <div class="user-search-area">

                    <asp:TextBox ID="txtSearch"
                        runat="server"
                        CssClass="user-search-box"
                        placeholder="Search users..."
                        AutoPostBack="true"
                        OnTextChanged="txtSearch_TextChanged">
                    </asp:TextBox>


                    <asp:Button ID="btnSearch"
                        runat="server"
                        Text="Search"
                        CssClass="search-user-button"
                        OnClick="btnSearch_Click" />

                </div>


                <!-- User list -->

                <asp:Repeater ID="rptUsers"
                    runat="server"
                    OnItemCommand="rptUsers_ItemCommand">

                    <ItemTemplate>

                        <asp:LinkButton ID="btnSelectUser"
                            runat="server"
                            CssClass="chat-user-item"
                            CommandName="SelectUser"
                            CommandArgument='<%# Eval("Name") %>'>

                            <span class="user-initials">

                                <%# Eval("Initials") %>

                            </span>


                            <span class="user-information">

                                <strong>
                                    <%# Eval("Name") %>
                                </strong>

                                <small>
                                    <%# Eval("Status") %>
                                </small>

                            </span>


                            <span class="select-user-arrow">
                                ›
                            </span>

                        </asp:LinkButton>

                    </ItemTemplate>

                </asp:Repeater>


                <!-- Selected user -->

                <div class="selected-user-card">

                    <h4>
                        Selected User
                    </h4>


                    <asp:Panel ID="pnlSelectedUser"
                        runat="server"
                        Visible="false">

                        <div class="selected-user-details">

                            <span class="selected-user-initials">

                                <asp:Label ID="lblSelectedInitials"
                                    runat="server">
                                </asp:Label>

                            </span>


                            <div>

                                <h3>

                                    <asp:Label ID="lblSelectedName"
                                        runat="server">
                                    </asp:Label>

                                </h3>


                                <p>

                                    <asp:Label ID="lblSelectedRole"
                                        runat="server">
                                    </asp:Label>

                                </p>


                                <small>

                                    <asp:Label ID="lblSelectedLocation"
                                        runat="server">
                                    </asp:Label>

                                </small>

                            </div>

                        </div>


                        <asp:Button ID="btnStartChat"
                            runat="server"
                            Text="Start Chat"
                            CssClass="start-chat-button"
                            OnClick="btnStartChat_Click" />

                    </asp:Panel>


                    <asp:Label ID="lblNoUser"
                        runat="server"
                        Text="Select a user to start a conversation."
                        CssClass="no-user-selected">
                    </asp:Label>

                </div>


            </div>



            <!-- RIGHT: Conversation -->

            <div class="conversation-panel">


                <!-- Chat header -->

                <div class="conversation-header">


                    <div class="conversation-user">

                        <span class="conversation-initials">

                            <asp:Label ID="lblChatInitials"
                                runat="server"
                                Text="CH">
                            </asp:Label>

                        </span>


                        <div>

                            <h3>

                                <asp:Label ID="lblChatName"
                                    runat="server"
                                    Text="No chat selected">
                                </asp:Label>

                            </h3>


                            <small>

                                <asp:Label ID="lblChatStatus"
                                    runat="server"
                                    Text="Select a user and click Start Chat">
                                </asp:Label>

                            </small>

                        </div>

                    </div>


                    <div class="conversation-actions">

                        <asp:Button ID="btnViewProfile"
                            runat="server"
                            Text="View Profile"
                            CssClass="view-profile-button"
                            OnClick="btnViewProfile_Click"
                            CausesValidation="false" />


                        <asp:Button ID="btnEndChat"
                            runat="server"
                            Text="End Chat"
                            CssClass="end-chat-button"
                            OnClick="btnEndChat_Click"
                            CausesValidation="false" />

                    </div>


                </div>


                <!-- Messages -->

                <div class="chat-messages">

                    <asp:PlaceHolder ID="phMessages"
                        runat="server">
                    </asp:PlaceHolder>

                </div>


                <!-- Message input -->

                <div class="message-send-area">


                    <asp:TextBox ID="txtMessage"
                        runat="server"
                        CssClass="chat-message-input"
                        placeholder="Type your message...">
                    </asp:TextBox>


                    <asp:Button ID="btnSend"
                        runat="server"
                        Text="Send"
                        CssClass="send-message-button"
                        OnClick="btnSend_Click" />

                </div>


                <div class="message-help">

                    Press Enter to send

                </div>


            </div>


        </div>


    </div>

    </div>
</asp:Content>
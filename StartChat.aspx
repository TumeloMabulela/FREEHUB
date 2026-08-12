<%@ Page Title="Messages"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="StartChat.aspx.cs"
    Inherits="FreeHubProject.StartChat" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .chat-container {
            display: grid;
            grid-template-columns: 340px 1fr;
            gap: 20px;
            background: #ffffff;
            border-radius: 12px;
            padding: 16px;
            font-family: Arial, sans-serif;
        }

        /* Success Alert */
        .chat-alert-success {
            background-color: #eaf7ed;
            color: #276738;
            padding: 10px 16px;
            border-radius: 8px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 16px;
            border: 1px solid #c7e8d0;
        }

        /* LEFT PANEL: CONVERSATIONS LIST */
        .chat-list-panel {
            border-right: 1px solid #f0f0f0;
            padding-right: 16px;
        }

        .chat-search-row {
            display: flex;
            gap: 8px;
            margin-bottom: 16px;
        }

        .chat-search-input {
            flex: 1;
            padding: 10px 14px;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            font-size: 13px;
            background: #fafafa;
        }

        .chat-filter-btn {
            background: #ffffff;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 8px 12px;
            cursor: pointer;
            color: #666;
        }

        .chat-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px;
            border-radius: 10px;
            text-decoration: none;
            color: inherit;
            margin-bottom: 8px;
            border: 1px solid transparent;
            transition: all 0.2s ease;
        }

        .chat-item.active {
            background-color: #f3f5fd;
            border-color: #a8b8f8;
        }

        .avatar-circle {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 14px;
            flex-shrink: 0;
        }

        .avatar-rt { background-color: #d8f3dc; color: #2d6a4f; }
        .avatar-mt { background-color: #f3e8ff; color: #7e22ce; }
        .avatar-mu { background-color: #fef3c7; color: #b45309; }
        .avatar-ml { background-color: #dcfce7; color: #15803d; }

        .chat-item-info {
            flex: 1;
            overflow: hidden;
        }

        .chat-item-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2px;
        }

        .chat-item-name {
            font-weight: 600;
            font-size: 14px;
            color: #111827;
        }

        .chat-item-time {
            font-size: 11px;
            color: #9ca3af;
        }

        .chat-item-preview {
            font-size: 12px;
            color: #6b7280;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            background-color: #22c55e;
            border-radius: 50%;
            display: inline-block;
            margin-right: 4px;
        }

        /* RIGHT PANEL: CONVERSATION THREAD */
        .chat-thread-panel {
            display: flex;
            flex-direction: column;
            border: 1px solid #f0f0f0;
            border-radius: 12px;
            padding: 16px;
            background: #ffffff;
        }

        .thread-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-bottom: 12px;
            border-bottom: 1px solid #f0f0f0;
            margin-bottom: 16px;
        }

        .thread-header-user {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .thread-header-title {
            font-size: 16px;
            font-weight: 700;
            color: #111827;
        }

        .thread-header-sub {
            font-size: 12px;
            color: #6b7280;
            display: flex;
            align-items: center;
        }

        .thread-actions {
            display: flex;
            gap: 12px;
            color: #6b7280;
            font-size: 18px;
            cursor: pointer;
        }

        .thread-messages {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 16px;
            padding: 8px 0;
            min-height: 380px;
            max-height: 480px;
            overflow-y: auto;
        }

        .date-divider {
            text-align: center;
            margin: 8px 0;
        }

        .date-divider span {
            background-color: #f3f4f6;
            color: #9ca3af;
            font-size: 11px;
            padding: 4px 12px;
            border-radius: 12px;
        }

        /* Message Bubbles */
        .msg-row {
            display: flex;
            gap: 10px;
            max-width: 75%;
        }

        .msg-row.received {
            align-self: flex-start;
        }

        .msg-row.sent {
            align-self: flex-end;
            flex-direction: row-reverse;
        }

        .msg-bubble-received {
            background-color: #f1f3f9;
            color: #1f2937;
            padding: 12px 16px;
            border-radius: 4px 16px 16px 16px;
            font-size: 13px;
            line-height: 1.4;
        }

        .msg-bubble-sent {
            background-color: #eaf7ed;
            color: #111827;
            padding: 12px 16px;
            border-radius: 16px 4px 16px 16px;
            font-size: 13px;
            line-height: 1.4;
        }

        .msg-meta {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 4px;
            font-size: 10px;
            color: #9ca3af;
            margin-top: 4px;
        }

        .ticks-blue {
            color: #2563eb;
            font-size: 11px;
        }

        /* Input Area */
        .thread-input-container {
            margin-top: 16px;
            border-top: 1px solid #f0f0f0;
            padding-top: 12px;
        }

        .thread-input-row {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .attach-btn {
            background: none;
            border: 1px solid #e0e0e0;
            border-radius: 50%;
            width: 38px;
            height: 38px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #6b7280;
            cursor: pointer;
            font-size: 16px;
        }

        .message-input {
            flex: 1;
            padding: 10px 16px;
            border: 1px solid #e0e0e0;
            border-radius: 20px;
            font-size: 13px;
            outline: none;
        }

        .send-btn-gradient {
            background: linear-gradient(135deg, #059669 0%, #2563eb 100%);
            color: #ffffff;
            border: none;
            border-radius: 20px;
            padding: 8px 18px;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .status-sent-text {
            font-size: 11px;
            color: #9ca3af;
            text-align: right;
            margin-top: 4px;
            padding-right: 8px;
        }
    </style>

    <script type="text/javascript">
function handleEnterKey(e, buttonId) {
    var key = e.keyCode || e.which;
    if (key === 13) {
        e.preventDefault();
        var btn = document.getElementById(buttonId);
        if (btn) { btn.click(); }
        return false;
    }
    return true;
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- Success Alert Panel -->
    <asp:Panel ID="pnlStatus" runat="server" CssClass="chat-alert-success" Visible="false">
        <span>✔</span>
        <asp:Label ID="lblStatus" runat="server"></asp:Label>
    </asp:Panel>

    <div class="chat-container">

        <!-- LEFT CONTAINER: CONVERSATION LIST -->
        <div class="chat-list-panel">
            <div class="chat-search-row">
                <asp:TextBox ID="txtSearch" runat="server" CssClass="chat-search-input" placeholder="Search conversations..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                <button type="button" class="chat-filter-btn">⚙</button>
            </div>

            <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                <ItemTemplate>
                    <asp:LinkButton ID="btnSelectUser" runat="server" CssClass='<%# Convert.ToInt32(Eval("UserID")) == SelectedOtherUserId ? "chat-item active" : "chat-item" %>' CommandName="SelectUser" CommandArgument='<%# Eval("UserID") %>'>
                        <div class='<%# "avatar-circle " + GetAvatarClass(Eval("Initials").ToString()) %>'>
                            <%# Eval("Initials") %>
                        </div>
                        <div class="chat-item-info">
                            <div class="chat-item-header">
                                <span class="chat-item-name"><%# Eval("Name") %></span>
                                <span class="chat-item-time"><%# Eval("LastTime") %></span>
                            </div>
                            <div class="chat-item-preview"><%# Eval("LastMessage") %></div>
                        </div>
                    </asp:LinkButton>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Label ID="lblNoUsers" runat="server" Visible="false" Text="No active conversations." CssClass="chat-item-preview" style="padding:10px; display:block;"></asp:Label>
        </div>

        <!-- RIGHT CONTAINER: MESSAGES THREAD -->
        <div class="chat-thread-panel">
            <div class="thread-header">
                <div class="thread-header-user">
                    <div class="avatar-circle avatar-rt">
                        <asp:Label ID="lblChatInitials" runat="server" Text="RT"></asp:Label>
                    </div>
                    <div>
                        <div class="thread-header-title">
                            <asp:Label ID="lblChatName" runat="server" Text="Select a conversation"></asp:Label>
                        </div>
                        <div class="thread-header-sub">
                            <span class="status-dot"></span> Online
                        </div>
                    </div>
                </div>
                <div class="thread-actions">
                    <span>⋮</span>
                    <span>ⓘ</span>
                </div>
            </div>

            <!-- Messages Thread Container -->
            <div class="thread-messages">
                <div class="date-divider">
                    <span>Today</span>
                </div>
                <asp:PlaceHolder ID="phMessages" runat="server"></asp:PlaceHolder>
            </div>

            <!-- Input Controls -->
            <div class="thread-input-container">
                <div class="thread-input-row">
                    <button type="button" class="attach-btn">📎</button>
                    <asp:TextBox ID="txtMessage" runat="server" CssClass="message-input" placeholder="Type your message..." onkeydown="return handleEnterKey(event, '<%= btnSend.ClientID %>');"></asp:TextBox>
                    <asp:Button ID="btnSend" runat="server" Text="Send 🚀" CssClass="send-btn-gradient" OnClick="btnSend_Click" />
                </div>
                <div class="status-sent-text">Sent ✓</div>
            </div>
        </div>

    </div>

    <!-- Rating Popup Modal -->
    <asp:Panel ID="pnlRatingModal" runat="server" CssClass="freehub-modal-overlay" Visible="false">
        <div class="freehub-modal-card">
            <div class="modal-header">
                <h2>Project Completed!</h2>
                <p>Messaging for this project has ended. Please rate your experience.</p>
            </div>
            <div class="modal-body">
                <label>Rating (1 to 5 Stars):</label>
                <asp:DropDownList ID="ddlRatingStars" runat="server" CssClass="rating-dropdown">
                    <asp:ListItem Text="5 Stars - Excellent" Value="5" Selected="True" />
                    <asp:ListItem Text="4 Stars - Very Good" Value="4" />
                    <asp:ListItem Text="3 Stars - Good" Value="3" />
                    <asp:ListItem Text="2 Stars - Fair" Value="2" />
                    <asp:ListItem Text="1 Star - Poor" Value="1" />
                </asp:DropDownList>
                <br /><br />
                <label>Feedback Comment (Optional):</label>
                <asp:TextBox ID="txtRatingComment" runat="server" TextMode="MultiLine" Rows="3" CssClass="rating-comment-input" placeholder="Write a short review..."></asp:TextBox>
            </div>
            <div class="modal-footer">
                <asp:Button ID="btnSubmitRating" runat="server" Text="Submit Rating" CssClass="submit-rating-button" OnClick="btnSubmitRating_Click" />
                <asp:Button ID="btnCloseModal" runat="server" Text="Close" CssClass="close-modal-button" OnClick="btnCloseModal_Click" CausesValidation="false" />
            </div>
        </div>
    </asp:Panel>

</asp:Content>
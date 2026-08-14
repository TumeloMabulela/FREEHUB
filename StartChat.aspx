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

        /* LEFT PANEL: CONVERSATIONS & USER SEARCH */
        .chat-list-panel {
            border-right: 1px solid #f0f0f0;
            padding-right: 16px;
        }

        .chat-search-row {
            display: flex;
            gap: 8px;
            margin-bottom: 12px;
        }

        .chat-search-input {
            flex: 1;
            padding: 10px 14px;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            font-size: 13px;
            background: #fafafa;
        }

        .chat-search-btn {
            background: #173f2c;
            color: #ffffff;
            border: none;
            border-radius: 8px;
            padding: 8px 14px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
        }

        /* Search Results Panel */
        .search-results-box {
            background: #f9fbf9;
            border: 1px solid #e0e8e2;
            border-radius: 8px;
            margin-bottom: 16px;
            max-height: 200px;
            overflow-y: auto;
        }

        .search-result-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 12px;
            text-decoration: none;
            color: #243328;
            border-bottom: 1px solid #f0f0f0;
            transition: background 0.2s;
        }

        .search-result-item:hover {
            background: #eef5f0;
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
            text-decoration: none;
            color: inherit;
            cursor: pointer;
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

        /* Message Bubbles & Read Receipts */
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
            color: #2563eb !important;
            font-weight: bold;
        }

        .ticks-gray {
            color: #9ca3af;
        }

        /* File Upload Input Controls */
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

        .file-upload-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .attach-btn-label {
            background: #f0f2f0;
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
            transition: background 0.2s;
        }

        .attach-btn-label:hover {
            background: #e2e8e4;
        }

        .file-upload-hidden {
            display: none;
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
            background: #173f2c;
            color: #ffffff;
            border: none;
            border-radius: 20px;
            padding: 10px 20px;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .attachment-preview {
            font-size: 12px;
            color: #15803d;
            margin-top: 6px;
            padding-left: 8px;
        }

        /* WhatsApp Style Details & Shared Files Modal */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(0, 0, 0, 0.45);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
        }

        .modal-pop-card {
            background: #ffffff;
            width: 90%;
            max-width: 480px;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            position: relative;
        }

        /* CONSISTENT WEBSITE RATING MODAL STYLES */
        .rating-dropdown, .rating-comment-input {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 13px;
            margin-top: 6px;
            outline: none;
            background: #f9fafb;
        }

        .rating-dropdown:focus, .rating-comment-input:focus {
            border-color: #173f2c;
            background: #fff;
        }

        .submit-rating-button {
            background-color: #173f2c;
            color: #ffffff;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            transition: background 0.2s;
        }

        .submit-rating-button:hover {
            background-color: #112d20;
        }

        .close-modal-button {
            background-color: #e5e7eb;
            color: #374151;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            margin-left: 8px;
            transition: background 0.2s;
        }

        .close-modal-button:hover {
            background-color: #d1d5db;
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

        function showSelectedFileName(input) {
            var label = document.getElementById('<%= lblAttachedFileName.ClientID %>');
            if (input.files && input.files[0]) {
                label.innerText = "📎 Attached: " + input.files[0].name;
            } else {
                label.innerText = "";
            }
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

        <!-- LEFT CONTAINER: CONVERSATION LIST & USER SEARCH -->
        <div class="chat-list-panel">
            
            <!-- User Search Control -->
            <div class="chat-search-row">
                <asp:TextBox ID="txtSearch" runat="server" CssClass="chat-search-input" placeholder="Search system users..." />
                <asp:Button ID="btnSearchUser" runat="server" Text="Search 🔍" CssClass="chat-search-btn" OnClick="btnSearchUser_Click" />
            </div>

            <!-- Search Results Dropdown List -->
            <asp:Panel ID="pnlSearchResults" runat="server" CssClass="search-results-box" Visible="false">
                <div style="padding: 8px 12px; font-size: 11px; font-weight: bold; color: #5a6e5f; background: #eef5f0;">MATCHING SYSTEM USERS:</div>
                <asp:Repeater ID="rptSearchResults" runat="server" OnItemCommand="rptSearchResults_ItemCommand">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnSelectSearchResult" runat="server" CssClass="search-result-item" CommandName="StartChatWithUser" CommandArgument='<%# Eval("userID") %>'>
                            <div>
                                <strong style="display: block; font-size: 13px; color: #173f2c;"><%# Eval("firstName") %> <%# Eval("lastName") %></strong>
                                <small style="color: #6b7280; font-size: 11px;"><%# Eval("email") %></small>
                            </div>
                            <span style="background: #e8f5e0; color: #2d6b3f; padding: 2px 6px; border-radius: 8px; font-size: 10px; font-weight: 600;"><%# Eval("userType") %></span>
                        </asp:LinkButton>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Label ID="lblNoUsersFound" runat="server" Visible="false" Text="No users found." Style="display: block; padding: 10px; text-align: center; color: #9ca3af; font-size: 12px;" />
            </asp:Panel>

            <!-- Conversations List Repeater -->
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

            <asp:Label ID="lblNoUsers" runat="server" Visible="false" Text="No active conversations." CssClass="chat-item-preview" Style="padding:10px; display:block;"></asp:Label>
        </div>

        <!-- RIGHT CONTAINER: MESSAGES THREAD -->
        <div class="chat-thread-panel">
            <div class="thread-header">
                <!-- CLICKABLE WHATSAPP STYLE HEADER PROFILE -->
                <asp:LinkButton ID="btnOpenHeaderModal" runat="server" CssClass="thread-header-user" OnClick="btnToggleDetails_Click" title="View Profile & Shared Files">
                    <div class="avatar-circle avatar-rt">
                        <asp:Label ID="lblChatInitials" runat="server" Text="--"></asp:Label>
                    </div>
                    <div>
                        <div class="thread-header-title">
                            <asp:Label ID="lblChatName" runat="server" Text="Select a conversation"></asp:Label>
                        </div>
                        <div class="thread-header-sub">
                            <span class="status-dot"></span>
                            <asp:Label ID="lblPartnerStatus" runat="server" Text="Offline"></asp:Label>
                        </div>
                    </div>
                </asp:LinkButton>

                <div class="thread-actions">
                    <asp:LinkButton ID="btnInfoIcon" runat="server" OnClick="btnToggleDetails_Click" Style="text-decoration: none; color: inherit;" title="View Profile & Shared Files">
                        <span>ⓘ</span>
                    </asp:LinkButton>
                </div>
            </div>

            <!-- Messages Thread Container -->
            <div class="thread-messages">
                <div class="date-divider">
                    <span>Today</span>
                </div>
                <asp:Repeater ID="rptMessages" runat="server">
                    <ItemTemplate>
                        <div class='<%# Convert.ToInt32(Eval("senderID")) == CurrentUserId ? "msg-row sent" : "msg-row received" %>'>
                            <div class='<%# Convert.ToInt32(Eval("senderID")) == CurrentUserId ? "msg-bubble-sent" : "msg-bubble-received" %>'>
                                <%# Eval("content") %>

                                <!-- Attachment Link (If present) -->
                                <asp:PlaceHolder ID="phAttachment" runat="server" Visible='<%# Eval("attachmentUrl") != DBNull.Value && !string.IsNullOrEmpty(Eval("attachmentUrl").ToString()) %>'>
                                    <div style="margin-top: 6px; padding-top: 4px; border-top: 1px solid rgba(0,0,0,0.1);">
                                        <a href='<%# ResolveUrl(Eval("attachmentUrl").ToString()) %>' target="_blank" style="color: #059669; font-weight: bold; text-decoration: underline; font-size: 11px;">
                                            📎 View Attached File
                                        </a>
                                    </div>
                                </asp:PlaceHolder>

                                <div class="msg-meta">
                                    <span><%# Convert.ToDateTime(Eval("timeStamp")).ToString("HH:mm") %></span>
                                    
                                    <asp:PlaceHolder ID="phReadReceipt" runat="server" Visible='<%# Convert.ToInt32(Eval("senderID")) == CurrentUserId %>'>
                                        <span class='<%# Eval("status").ToString() == "Read" ? "ticks-blue" : "ticks-gray" %>'>
                                            <%# Eval("status").ToString() == "Read" ? "✓✓" : "✓" %>
                                        </span>
                                    </asp:PlaceHolder>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <!-- Input Controls with Functional File Attachment -->
            <div class="thread-input-container">
                <div class="thread-input-row">
                    <div class="file-upload-wrapper">
                        <label for="<%= fileUploadControl.ClientID %>" class="attach-btn-label" title="Attach file">📎</label>
                        <asp:FileUpload ID="fileUploadControl" runat="server" CssClass="file-upload-hidden" onchange="showSelectedFileName(this);" />
                    </div>

                    <asp:TextBox ID="txtMessage" runat="server" CssClass="message-input" placeholder="Type your message..." onkeydown="return handleEnterKey(event, '<%= btnSend.ClientID %>');"></asp:TextBox>
                    <asp:Button ID="btnSend" runat="server" Text="Send 🚀" CssClass="send-btn-gradient" OnClick="btnSend_Click" />
                </div>
                
                <asp:Label ID="lblAttachedFileName" runat="server" CssClass="attachment-preview"></asp:Label>
            </div>
        </div>

    </div>

    <!-- WHATSAPP STYLE CONTACT DETAILS & SHARED FILES MODAL -->
    <asp:Panel ID="pnlUserDetailsModal" runat="server" CssClass="modal-overlay" Visible="false">
        <div class="modal-pop-card">
            
            <!-- Modal Header -->
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e0e8e2; padding-bottom: 12px; margin-bottom: 16px;">
                <h3 style="margin: 0; color: #173f2c; font-size: 18px;">Contact Info & Shared Files</h3>
                <asp:LinkButton ID="btnCloseDetails" runat="server" OnClick="btnCloseDetails_Click" Style="color: #888; text-decoration: none; font-size: 20px; font-weight: bold; cursor: pointer;">✕</asp:LinkButton>
            </div>

            <!-- User Profile Details -->
            <div style="background: #f9fbf9; border: 1px solid #e0e8e2; border-radius: 8px; padding: 14px; margin-bottom: 18px; display: grid; grid-template-columns: 1fr 1fr; gap: 10px; font-size: 13px; color: #243328;">
                <div><strong>Full Name:</strong> <asp:Label ID="lblDetailName" runat="server" /></div>
                <div><strong>Account Type:</strong> <asp:Label ID="lblDetailUserType" runat="server" /></div>
                <div><strong>Email:</strong> <asp:Label ID="lblDetailEmail" runat="server" /></div>
                <div><strong>Contact:</strong> <asp:Label ID="lblDetailContact" runat="server" /></div>
                <div style="grid-column: span 2;"><strong>Rating Score:</strong> ⭐ <asp:Label ID="lblDetailRating" runat="server" /> / 5.0</div>
            </div>

            <!-- Shared Files History -->
            <div style="border-top: 1px solid #e0e8e2; padding-top: 14px;">
                <strong style="color: #173f2c; font-size: 14px; display: block; margin-bottom: 8px;">Shared Files History</strong>
                
                <div style="max-height: 180px; overflow-y: auto; border: 1px solid #f0f0f0; border-radius: 6px; padding: 8px;">
                    <asp:Repeater ID="rptSharedFiles" runat="server">
                        <HeaderTemplate>
                            <ul style="list-style: none; padding: 0; margin: 0;">
                        </HeaderTemplate>
                        <ItemTemplate>
                            <li style="padding: 8px; border-bottom: 1px solid #f0f0f0; font-size: 12px; display: flex; justify-content: space-between; align-items: center;">
                                <span style="color: #243328; font-weight: 500;">📎 <%# System.IO.Path.GetFileName(Eval("attachmentUrl").ToString()) %></span>
                                <div>
                                    <small style="color: #888; margin-right: 10px;"><%# Convert.ToDateTime(Eval("timeStamp")).ToString("dd MMM yyyy, HH:mm") %></small>
                                    <a href='<%# ResolveUrl(Eval("attachmentUrl").ToString()) %>' target="_blank" style="color: #059669; font-weight: bold; text-decoration: underline;">Download</a>
                                </div>
                            </li>
                        </ItemTemplate>
                        <FooterTemplate>
                            </ul>
                        </FooterTemplate>
                    </asp:Repeater>

                    <asp:Label ID="lblNoSharedFiles" runat="server" Visible="false" Text="No shared files in this conversation yet." Style="font-size: 13px; color: #888; display: block; text-align: center; padding: 12px 0;" />
                </div>
            </div>

            <div style="text-align: right; margin-top: 18px;">
                <asp:Button ID="btnCloseModalBtn" runat="server" Text="Close" OnClick="btnCloseDetails_Click" CausesValidation="false" Style="background: #173f2c; color: white; border: none; padding: 8px 18px; border-radius: 6px; font-weight: 600; cursor: pointer;" />
            </div>

        </div>
    </asp:Panel>

    <!-- Rating Popup Modal -->
    <asp:Panel ID="pnlRatingModal" runat="server" CssClass="modal-overlay" Visible="false">
        <div class="modal-pop-card">
            <div class="modal-header" style="border-bottom: 1px solid #e5e7eb; padding-bottom: 12px; margin-bottom: 16px;">
                <h3 style="margin: 0; color: #173f2c; font-size: 18px;">Project completed</h3>
                <p style="margin: 4px 0 0 0; font-size: 13px; color: #6b7280;">Messaging has ended. Please rate your experience.</p>
            </div>
            <div class="modal-body" style="font-size: 13px; color: #374151;">
                <label style="font-weight: 600; display: block; color: #173f2c;">Rating (1 to 5 Stars):</label>
                <asp:DropDownList ID="ddlRatingStars" runat="server" CssClass="rating-dropdown">
                    <asp:ListItem Text="5 Stars - Excellent" Value="5" Selected="True" />
                    <asp:ListItem Text="4 Stars - Very Good" Value="4" />
                    <asp:ListItem Text="3 Stars - Good" Value="3" />
                    <asp:ListItem Text="2 Stars - Fair" Value="2" />
                    <asp:ListItem Text="1 Star - Poor" Value="1" />
                </asp:DropDownList>
                <br /><br />
                <label style="font-weight: 600; display: block; color: #173f2c;">Feedback Comment (Optional):</label>
                <asp:TextBox ID="txtRatingComment" runat="server" TextMode="MultiLine" Rows="3" CssClass="rating-comment-input" placeholder="Write a short review..."></asp:TextBox>
            </div>
            <div class="modal-footer" style="margin-top: 20px; text-align: right;">
                <asp:Button ID="btnSubmitRating" runat="server" Text="Submit Rating" CssClass="submit-rating-button" OnClick="btnSubmitRating_Click" />
                <asp:Button ID="btnCloseModal" runat="server" Text="Close" CssClass="close-modal-button" OnClick="btnCloseModal_Click" CausesValidation="false" />
            </div>
        </div>
    </asp:Panel>

</asp:Content>
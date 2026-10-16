<%@ Page Title="Admin - Support Inbox"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="AdminInbox.aspx.cs"
    Inherits="FreeHubProject.AdminInbox" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="H" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-page { display:flex; }
        .admin-main { flex:1; padding:24px 28px; min-width:0; }
        .admin-main h1 { color:#1b5e20; margin:0 0 16px; font-size:24px; }
        .inbox-wrap { display:flex; gap:16px; align-items:flex-start; }
        .inbox-list { width:300px; background:#fff; border:1px solid #e2e8e4; border-radius:10px; overflow:hidden; }
        .inbox-list .conv { display:block; width:100%; text-align:left; border:none; background:none; border-bottom:1px solid #eee; padding:12px 14px; cursor:pointer; }
        .inbox-list .conv:hover { background:#f3f8f4; }
        .inbox-list .conv.active { background:#e8f5e9; }
        .conv-name { font-weight:600; color:#1b2a20; font-size:14px; }
        .conv-last { color:#5a5a5a; font-size:12px; margin-top:2px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; max-width:230px; }
        .conv-badge { background:#ef4444; color:#fff; border-radius:10px; padding:1px 7px; font-size:11px; float:right; }
        .inbox-thread { flex:1; background:#fff; border:1px solid #e2e8e4; border-radius:10px; display:flex; flex-direction:column; min-height:480px; }
        .thread-head { padding:12px 16px; border-bottom:1px solid #eee; font-weight:600; color:#1b5e20; }
        .thread-body { flex:1; padding:16px; overflow-y:auto; max-height:460px; }
        .bubble { max-width:70%; padding:8px 12px; border-radius:12px; margin-bottom:10px; font-size:13px; line-height:1.35; }
        .bubble.them { background:#f1f1f1; color:#222; }
        .bubble.me { background:#1b5e20; color:#fff; margin-left:auto; }
        .bubble .t { display:block; font-size:10px; opacity:.7; margin-top:4px; }
        .thread-input { display:flex; gap:8px; padding:12px 16px; border-top:1px solid #eee; }
        .thread-input textarea { flex:1; resize:none; height:40px; padding:8px 10px; border:1px solid #cdd6cf; border-radius:8px; font-family:inherit; font-size:13px; }
        .thread-input .send { background:#1b5e20; color:#fff; border:none; padding:0 18px; border-radius:8px; cursor:pointer; }
        .empty-note { color:#5a5a5a; padding:40px; text-align:center; }
    </style>
</asp:Content>

<asp:Content ID="C" ContentPlaceHolderID="MainContent" runat="server">
    <div class="admin-page">
        <uc:Sidebar runat="server" ID="SidebarControl" />
        <main class="admin-main">
            <h1>Support Inbox</h1>
            <div class="inbox-wrap">
                <div class="inbox-list">
                    <asp:Repeater ID="rptConversations" runat="server" OnItemCommand="rptConversations_ItemCommand">
                        <ItemTemplate>
                            <asp:LinkButton runat="server" CssClass='<%# "conv" + (Convert.ToInt32(Eval("UserID")) == SelectedUserId ? " active" : "") %>'
                                CommandName="Open" CommandArgument='<%# Eval("UserID") %>'>
                                <span class="conv-name"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %>
                                    <%# Convert.ToInt32(Eval("UnreadCount")) > 0 ? "<span class='conv-badge'>" + Eval("UnreadCount") + "</span>" : "" %>
                                </span>
                                <span class="conv-last"><%# Server.HtmlEncode(Convert.ToString(Eval("LastMessage"))) %></span>
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Label ID="lblNoConvos" runat="server" Visible="false"
                        Text="No support messages yet. When a user presses Help, their message appears here." />
                </div>

                <div class="inbox-thread">
                    <asp:Panel ID="pnlThread" runat="server" Visible="false">
                        <div class="thread-head"><asp:Literal ID="litThreadName" runat="server" /></div>
                        <div class="thread-body">
                            <asp:Repeater ID="rptMessages" runat="server">
                                <ItemTemplate>
                                    <div class='<%# IsFromAdmin(Eval("senderID")) ? "bubble me" : "bubble them" %>'>
                                        <%# Server.HtmlEncode(Convert.ToString(Eval("content"))) %>
                                        <span class="t"><%# Convert.ToDateTime(Eval("timeStamp")).AddHours(2).ToString("dd MMM, hh:mm tt") %></span>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        <div class="thread-input">
                            <asp:TextBox ID="txtReply" runat="server" TextMode="MultiLine" placeholder="Type a reply to the user..." />
                            <asp:Button ID="btnSend" runat="server" CssClass="send" Text="Send" OnClick="btnSend_Click" />
                        </div>
                    </asp:Panel>
                    <asp:Panel ID="pnlNoThread" runat="server">
                        <div class="empty-note">Select a conversation on the left to view and reply.</div>
                    </asp:Panel>
                </div>
            </div>
        </main>
    </div>
</asp:Content>

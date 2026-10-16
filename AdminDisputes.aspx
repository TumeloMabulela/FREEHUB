<%@ Page Title="Admin - Disputes"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="AdminDisputes.aspx.cs"
    Inherits="FreeHubProject.AdminDisputes" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="H" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-page { display:flex; }
        .admin-main { flex:1; padding:28px 32px; min-width:0; }
        .admin-main h1 { color:#1b5e20; margin:0 0 16px; font-size:24px; }
        .admin-msg { padding:10px 14px; border-radius:8px; margin-bottom:16px; }
        .admin-msg.ok { background:#e8f5e9; color:#1b5e20; }
        .admin-msg.err { background:#fdecea; color:#b71c1c; }
        table.admin-tbl { width:100%; border-collapse:collapse; background:#fff; border:1px solid #e2e8e4; border-radius:8px; overflow:hidden; }
        table.admin-tbl th { background:#1b5e20; color:#fff; text-align:left; padding:10px 12px; font-size:13px; }
        table.admin-tbl td { padding:10px 12px; border-top:1px solid #eee; font-size:13px; vertical-align:top; }
        .st { display:inline-block; padding:2px 8px; border-radius:10px; font-size:12px; }
        .st.Open { background:#fff3e0; color:#e65100; }
        .st.InReview { background:#e3f2fd; color:#1565c0; }
        .st.Resolved { background:#e8f5e9; color:#2e7d32; }
        .st.Closed { background:#eceff1; color:#455a64; }
        .resolve-box { display:flex; gap:6px; align-items:center; flex-wrap:wrap; }
        .resolve-box select, .resolve-box input { padding:6px 8px; border:1px solid #cdd6cf; border-radius:6px; font-size:12px; }
        .resolve-box .go { background:#1b5e20; color:#fff; border:none; padding:7px 12px; border-radius:6px; cursor:pointer; font-size:12px; }
    </style>
</asp:Content>

<asp:Content ID="C" ContentPlaceHolderID="MainContent" runat="server">
    <div class="admin-page">
        <uc:Sidebar runat="server" ID="SidebarControl" />
        <main class="admin-main">
            <h1>Dispute Resolution</h1>
            <asp:Panel ID="pnlMsg" runat="server" Visible="false"><div class="admin-msg ok"><asp:Literal ID="litMsg" runat="server" /></div></asp:Panel>

            <asp:Repeater ID="rptDisputes" runat="server" OnItemCommand="rptDisputes_ItemCommand">
                <HeaderTemplate>
                    <table class="admin-tbl">
                        <tr>
                            <th>#</th><th>Raised By</th><th>Reason</th><th>Description</th>
                            <th>Date</th><th>Status</th><th>Resolve</th>
                        </tr>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("disputeID") %></td>
                        <td><%# Server.HtmlEncode(Convert.ToString(Eval("raisedByName"))) %></td>
                        <td><%# Server.HtmlEncode(Convert.ToString(Eval("reason"))) %></td>
                        <td style="max-width:260px;"><%# Server.HtmlEncode(Convert.ToString(Eval("disputeDescription"))) %></td>
                        <td><%# Convert.ToDateTime(Eval("dateCreated")).ToString("dd MMM yyyy") %></td>
                        <td><span class='st <%# Convert.ToString(Eval("status")).Replace(" ","") %>'><%# Eval("status") %></span>
                            <%# FormatAdminNote(Eval("adminComment")) %></td>
                        <td>
                            <div class="resolve-box">
                                <asp:DropDownList ID="ddlStatus" runat="server">
                                    <asp:ListItem>Open</asp:ListItem>
                                    <asp:ListItem Value="In Review">In Review</asp:ListItem>
                                    <asp:ListItem>Resolved</asp:ListItem>
                                    <asp:ListItem>Closed</asp:ListItem>
                                </asp:DropDownList>
                                <asp:TextBox ID="txtComment" runat="server" placeholder="Note to user" />
                                <asp:Button ID="btnResolve" runat="server" CssClass="go" Text="Update"
                                    CommandName="Resolve" CommandArgument='<%# Eval("disputeID") %>' />
                            </div>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate></table></FooterTemplate>
            </asp:Repeater>
            <asp:Label ID="lblEmpty" runat="server" Visible="false" Text="No disputes have been raised yet." />
        </main>
    </div>
</asp:Content>

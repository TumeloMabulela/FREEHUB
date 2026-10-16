<%@ Page Title="Admin - Withdrawals"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="AdminWithdrawals.aspx.cs"
    Inherits="FreeHubProject.AdminWithdrawals" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="H" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-page { display:flex; }
        .admin-main { flex:1; padding:28px 32px; min-width:0; }
        .admin-main h1 { color:#1b5e20; margin:0 0 16px; font-size:24px; }
        .admin-msg { padding:10px 14px; border-radius:8px; margin-bottom:16px; background:#e8f5e9; color:#1b5e20; }
        table.admin-tbl { width:100%; border-collapse:collapse; background:#fff; border:1px solid #e2e8e4; border-radius:8px; overflow:hidden; }
        table.admin-tbl th { background:#1b5e20; color:#fff; text-align:left; padding:10px 12px; font-size:13px; }
        table.admin-tbl td { padding:10px 12px; border-top:1px solid #eee; font-size:13px; }
        .st { display:inline-block; padding:2px 8px; border-radius:10px; font-size:12px; }
        .st.Pending { background:#fff3e0; color:#e65100; }
        .st.Completed { background:#e8f5e9; color:#2e7d32; }
        .st.Failed { background:#fdecea; color:#b71c1c; }
        .btn-ok { background:#1b5e20; color:#fff; border:none; padding:6px 12px; border-radius:6px; cursor:pointer; font-size:12px; margin-right:6px; }
        .btn-no { background:#b71c1c; color:#fff; border:none; padding:6px 12px; border-radius:6px; cursor:pointer; font-size:12px; }
        .reason-overlay { position:fixed; inset:0; background:rgba(0,0,0,.45); display:flex; align-items:center; justify-content:center; z-index:1000; }
        .reason-modal { background:#fff; border-radius:12px; padding:22px 24px; width:420px; max-width:92%; box-shadow:0 10px 30px rgba(0,0,0,.2); }
        .reason-modal h3 { margin:0 0 6px; color:#b71c1c; }
        .reason-modal p { margin:0 0 12px; color:#5a5a5a; font-size:13px; }
        .reason-text { width:100%; box-sizing:border-box; min-height:80px; padding:10px; border:1px solid #cdd6cf; border-radius:8px; font-family:inherit; font-size:13px; resize:vertical; }
        .reason-err { display:block; color:#b71c1c; font-size:12px; margin-top:6px; }
        .reason-actions { display:flex; justify-content:flex-end; gap:8px; margin-top:16px; }
        .btn-cancel { background:#eceff1; color:#333; border:none; padding:8px 14px; border-radius:6px; cursor:pointer; font-size:13px; }
    </style>
</asp:Content>

<asp:Content ID="C" ContentPlaceHolderID="MainContent" runat="server">
    <div class="admin-page">
        <uc:Sidebar runat="server" ID="SidebarControl" />
        <main class="admin-main">
            <h1>Withdrawal Requests</h1>
            <asp:Panel ID="pnlMsg" runat="server" Visible="false"><div class="admin-msg"><asp:Literal ID="litMsg" runat="server" /></div></asp:Panel>

            <asp:Repeater ID="rpt" runat="server" OnItemCommand="rpt_ItemCommand">
                <HeaderTemplate>
                    <table class="admin-tbl">
                        <tr><th>Ref</th><th>User</th><th>Destination</th><th>Amount</th><th>Date</th><th>Status</th><th>Action</th></tr>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Server.HtmlEncode(Convert.ToString(Eval("reference"))) %></td>
                        <td><%# Server.HtmlEncode(Convert.ToString(Eval("ownerName"))) %></td>
                        <td><%# Server.HtmlEncode(Convert.ToString(Eval("itemDescription"))) %></td>
                        <td>R <%# Convert.ToDecimal(Eval("transactionAmount")).ToString("N2") %></td>
                        <td><%# Convert.ToDateTime(Eval("transactionDate")).ToString("dd MMM yyyy") %></td>
                        <td><span class='st <%# Eval("transactionStatus") %>'><%# Eval("transactionStatus") %></span></td>
                        <td>
                            <%# IsPending(Eval("transactionStatus")) ? "" : "<span style='color:#9aa5a0;font-size:12px;'>Processed</span>" %>
                            <asp:Button ID="btnApprove" runat="server" CssClass="btn-ok" Text="Approve"
                                CommandName="Approve" CommandArgument='<%# Eval("transactionID") %>'
                                Visible='<%# IsPending(Eval("transactionStatus")) %>' />
                            <asp:Button ID="btnReject" runat="server" CssClass="btn-no" Text="Reject &amp; refund"
                                CommandName="AskReject" CommandArgument='<%# Eval("transactionID") %>'
                                Visible='<%# IsPending(Eval("transactionStatus")) %>' />
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate></table></FooterTemplate>
            </asp:Repeater>
            <asp:Label ID="lblEmpty" runat="server" Visible="false" Text="No withdrawal requests found." />

            <!-- Rejection reason modal -->
            <asp:Panel ID="pnlReject" runat="server" Visible="false" CssClass="reason-overlay">
                <div class="reason-modal">
                    <h3>Reject withdrawal</h3>
                    <p>Please provide a reason. The amount is returned to the user's wallet and the user is told why it was declined.</p>
                    <asp:TextBox ID="txtReason" runat="server" TextMode="MultiLine" CssClass="reason-text"
                        placeholder="e.g. The banking details provided could not be verified." />
                    <asp:Label ID="lblReasonErr" runat="server" CssClass="reason-err" Visible="false"
                        Text="A reason is required to reject." />
                    <div class="reason-actions">
                        <asp:Button ID="btnCancelReject" runat="server" CssClass="btn-cancel" Text="Cancel"
                            OnClick="btnCancelReject_Click" CausesValidation="false" />
                        <asp:Button ID="btnConfirmReject" runat="server" CssClass="btn-no" Text="Confirm rejection"
                            OnClick="btnConfirmReject_Click" />
                    </div>
                    <asp:HiddenField ID="hfRejectTxnId" runat="server" />
                </div>
            </asp:Panel>
        </main>
    </div>
</asp:Content>

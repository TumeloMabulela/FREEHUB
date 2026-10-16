<%@ Page Title="Refunds"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="Refunds.aspx.cs"
    Inherits="FreeHubProject.Refunds" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="RefundsHead"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <link href="<%= ResolveUrl("~/Refunds.css?v=4") %>"
          rel="stylesheet"
          type="text/css" />

</asp:Content>

<asp:Content ID="RefundsContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="refunds-page">

        <!-- LEFT SIDEBAR -->
        <uc:Sidebar runat="server" ID="SidebarControl" />

        <!-- MAIN CONTENT -->
        <main class="refunds-main">

            <!-- PAGE HEADER -->
            <div class="refunds-header">

                <div>

                    <h1>
                        Refunds
                    </h1>

                    <div class="refunds-breadcrumb">

                        <a href="Wallet.aspx" class="breadcrumb-link">
                            Wallet
                        </a>

                        <span>&#8250;</span>

                        <strong>
                            Refunds
                        </strong>

                    </div>

                    <p>
                        View and manage returned wallet funds.
                    </p>

                </div>

                <!-- SUMMARY CARDS (beside the page heading) -->
                <section class="refunds-summary-grid">

                <div class="refunds-summary-item">

                    <span class="refunds-summary-icon refunds-total-icon">
                        &#8617;
                    </span>

                    <div>

                        <small>
                            Total Refunded
                        </small>

                        <asp:Label
                            ID="lblTotalRefunded"
                            runat="server"
                            CssClass="refunds-summary-value"
                            Text="R0.00">
                        </asp:Label>

                    </div>

                </div>

                <div class="refunds-summary-item">

                    <span class="refunds-summary-icon refunds-pending-icon">
                        &#9203;
                    </span>

                    <div>

                        <small>
                            Pending Refunds
                        </small>

                        <asp:Label
                            ID="lblPendingRefunds"
                            runat="server"
                            CssClass="refunds-summary-value"
                            Text="R0.00">
                        </asp:Label>

                    </div>

                </div>

                <div class="refunds-summary-item">

                    <span class="refunds-summary-icon refunds-completed-icon">
                        &#10004;
                    </span>

                    <div>

                        <small>
                            Completed Refunds
                        </small>

                        <asp:Label
                            ID="lblCompletedCount"
                            runat="server"
                            CssClass="refunds-summary-value"
                            Text="0">
                        </asp:Label>

                    </div>

                </div>

                </section>

            </div>


            <!-- MESSAGE -->
            <asp:Panel
                ID="pnlMessage"
                runat="server"
                CssClass="refunds-message"
                Visible="false">

                <asp:Label
                    ID="lblMessage"
                    runat="server">
                </asp:Label>

            </asp:Panel>


            <div class="refunds-layout">

                <!-- REFUND REQUEST FORM -->
                <section class="refunds-form-card">

                    <h2>
                        Request a Refund
                    </h2>

                    <p class="refunds-form-description">
                        Submit a refund request for a completed transaction.
                        Refunds are reviewed and processed by an administrator.
                    </p>


                    <!-- TRANSACTION REFERENCE -->
                    <div class="refunds-field">

                        <label>
                            Transaction Reference
                        </label>

                        <asp:TextBox
                            ID="txtTransactionRef"
                            runat="server"
                            CssClass="refunds-input"
                            placeholder="e.g. FUND-A1B2C3D4">
                        </asp:TextBox>

                        <small>
                            Enter the reference of the transaction you want refunded.
                        </small>

                    </div>


                    <!-- REFUND AMOUNT -->
                    <div class="refunds-field">

                        <label>
                            Refund Amount (ZAR)
                        </label>

                        <div class="refunds-amount-box">

                            <span>R</span>

                            <asp:TextBox
                                ID="txtRefundAmount"
                                runat="server"
                                CssClass="refunds-amount-input"
                                TextMode="Number"
                                placeholder="0.00">
                            </asp:TextBox>

                        </div>

                        <small>
                            Enter the amount to be refunded (partial or full).
                        </small>

                    </div>


                    <!-- REASON -->
                    <div class="refunds-field">

                        <label>
                            Reason for Refund
                        </label>

                        <asp:DropDownList
                            ID="ddlReason"
                            runat="server"
                            CssClass="refunds-dropdown">

                            <asp:ListItem
                                Text="Select a reason"
                                Value="">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Service not delivered"
                                Value="Service not delivered">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Duplicate payment"
                                Value="Duplicate payment">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Incorrect amount charged"
                                Value="Incorrect amount charged">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Project cancelled"
                                Value="Project cancelled">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Other"
                                Value="Other">
                            </asp:ListItem>

                        </asp:DropDownList>

                    </div>


                    <!-- ADDITIONAL DETAILS -->
                    <div class="refunds-field">

                        <label>
                            Additional Details (Optional)
                        </label>

                        <asp:TextBox
                            ID="txtDetails"
                            runat="server"
                            CssClass="refunds-textarea"
                            TextMode="MultiLine"
                            Rows="4"
                            placeholder="Provide any additional information to support your refund request...">
                        </asp:TextBox>

                    </div>


                    <asp:Button
                        ID="btnSubmitRefund"
                        runat="server"
                        Text="Submit Refund Request"
                        CssClass="refunds-submit-button"
                        CausesValidation="false"
                        OnClick="btnSubmitRefund_Click" />

                </section>


                <!-- RIGHT COLUMN -->
                <aside class="refunds-right-column">

                    <!-- RECENT REFUNDS -->
                    <section class="refunds-side-card">

                        <div class="refunds-side-heading">

                            <h3>
                                Recent Refunds
                            </h3>

                            <asp:Button
                                ID="btnViewAll"
                                runat="server"
                                Text="View All"
                                CssClass="refunds-view-all"
                                CausesValidation="false"
                                OnClick="btnViewAll_Click" />

                        </div>

                        <div class="refunds-history-list">

                        <asp:Repeater
                            ID="rptRefunds"
                            runat="server">

                            <ItemTemplate>

                                <div class="refunds-history-item">

                                    <div>

                                        <strong>
                                            <%# TimeHelper.ToSast(
                                                    Eval("TransactionDate")
                                                ).ToString("dd MMM yyyy") %>
                                        </strong>

                                        <small>
                                            <%# Server.HtmlEncode(
                                                Convert.ToString(
                                                    Eval("Description")
                                                )
                                            ) %>
                                        </small>

                                    </div>

                                    <div class="refunds-history-right">

                                        <strong class="refunds-history-amount">
                                            + R<%# Convert.ToDecimal(
                                                Eval("Amount")
                                            ).ToString("N2") %>
                                        </strong>

                                        <span class='<%# GetRefundStatusClass(
                                            Convert.ToString(Eval("Status"))
                                        ) %>'>

                                            <%# Server.HtmlEncode(
                                                Convert.ToString(
                                                    Eval("Status")
                                                )
                                            ) %>

                                        </span>

                                    </div>

                                </div>

                            </ItemTemplate>

                        </asp:Repeater>

                        <asp:Panel
                            ID="pnlNoRefunds"
                            runat="server"
                            CssClass="refunds-empty-history"
                            Visible="false">

                            <div class="refunds-empty-icon">
                                &#8617;
                            </div>

                            <strong>
                                No refund requests
                            </strong>

                            <p>
                                Your refund history will appear here.
                            </p>

                        </asp:Panel>

                        </div>
                        <!-- /refunds-history-list -->

                    </section>

                </aside>

            </div>

        </main>

    </div>

</asp:Content>

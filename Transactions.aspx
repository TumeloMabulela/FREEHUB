<%@ Page Title="View Transactions"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="Transactions.aspx.cs"
    Inherits="FreeHubProject.Transactions" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="TransactionsHead"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <link href="<%= ResolveUrl("~/Transactions.css?v=20") %>"
          rel="stylesheet"
          type="text/css" />

</asp:Content>


<asp:Content ID="TransactionsContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="transactions-page">

        <!-- SIDEBAR -->
        <uc:Sidebar runat="server" ID="SidebarControl" />


        <!-- MAIN -->
        <main class="transactions-main">

            <div class="transactions-header">

                <div>

                    <h1>
                        View Transactions
                    </h1>

                    <div class="transactions-breadcrumb">

                        <a href="Wallet.aspx" class="breadcrumb-link">
                            Wallet
                        </a>

                        <span>›</span>

                        <strong>
                            Transactions
                        </strong>

                    </div>

                    <p>
                        View and track all your wallet transactions.
                    </p>

                </div>


                <section class="transactions-balance-card">

                    <div>

                        <small>
                            Current Wallet Balance
                        </small>

                        <asp:Label
                            ID="lblCurrentBalance"
                            runat="server"
                            CssClass="transactions-balance-value"
                            Text="R0.00">
                        </asp:Label>

                    </div>

                    <span class="transactions-wallet-icon">
                        &#128176;
                    </span>

                </section>

            </div>


            <asp:Panel
                ID="pnlMessage"
                runat="server"
                CssClass="tx-message"
                Visible="false">

                <asp:Label
                    ID="lblMessage"
                    runat="server">
                </asp:Label>

            </asp:Panel>


            <!-- FILTER -->
            <section class="transactions-filter-card">

                <div class="transactions-filter-field">

                    <label>
                        Transaction Type
                    </label>

                    <asp:DropDownList
                        ID="ddlTransactionType"
                        runat="server"
                        CssClass="transactions-filter-control">

                        <asp:ListItem
                            Text="All Transactions"
                            Value="All">
                        </asp:ListItem>

                        <asp:ListItem
                            Text="Credit"
                            Value="Credit">
                        </asp:ListItem>

                        <asp:ListItem
                            Text="Withdrawal"
                            Value="Withdrawal">
                        </asp:ListItem>

                        <asp:ListItem
                            Text="Debit"
                            Value="Debit">
                        </asp:ListItem>

                        <asp:ListItem
                            Text="Refund"
                            Value="Refund">
                        </asp:ListItem>

                    </asp:DropDownList>

                </div>


                <div class="transactions-filter-field">

                    <label>
                        From Date
                    </label>

                    <asp:TextBox
                        ID="txtFromDate"
                        runat="server"
                        TextMode="Date"
                        CssClass="transactions-filter-control">
                    </asp:TextBox>

                </div>


                <div class="transactions-filter-field">

                    <label>
                        To Date
                    </label>

                    <asp:TextBox
                        ID="txtToDate"
                        runat="server"
                        TextMode="Date"
                        CssClass="transactions-filter-control">
                    </asp:TextBox>

                </div>


                <asp:Button
                    ID="btnFilter"
                    runat="server"
                    Text="Filter"
                    CssClass="transactions-filter-button"
                    CausesValidation="false"
                    OnClick="btnFilter_Click" />


                <asp:Button
                    ID="btnClear"
                    runat="server"
                    Text="Clear"
                    CssClass="transactions-clear-button"
                    CausesValidation="false"
                    OnClick="btnClear_Click" />

            </section>


            <div class="transactions-content-grid">

                <!-- HISTORY -->
                <section class="transactions-history-card">

                    <div class="transactions-history-heading">

                        <h2>
                            Transaction History
                        </h2>

                        <asp:Label
                            ID="lblTransactionCount"
                            runat="server"
                            Text="0 transactions">
                        </asp:Label>

                    </div>


                    <div class="transactions-table-wrapper">

                        <table class="transactions-table">

                            <thead>

                                <tr>

                                    <th>Date</th>
                                    <th>Description</th>
                                    <th>Type</th>
                                    <th>Amount</th>
                                    <th>Status</th>
                                    <th>Action</th>

                                </tr>

                            </thead>

                            <tbody>

                                <asp:Repeater
                                    ID="rptTransactions"
                                    runat="server"
                                    OnItemCommand="rptTransactions_ItemCommand">

                                    <ItemTemplate>

                                        <tr>

                                            <td>
                                                <%# Eval("DisplayDate") %>
                                            </td>

                                            <td>
                                                <%# Eval("Description") %>
                                            </td>

                                            <td>

                                                <span class='<%# Eval("TypeCssClass") %>'>

                                                    <%# Eval("Type") %>

                                                </span>

                                            </td>

                                            <td>

                                                <span class='<%# Eval("AmountCssClass") %>'>

                                                    <%# Eval("DisplayAmount") %>

                                                </span>

                                            </td>

                                            <td>

                                                <span class='<%# Eval("StatusCssClass") %>'>

                                                    <%# Eval("Status") %>

                                                </span>

                                            </td>

                                            <td>

                                                <asp:LinkButton
                                                    ID="btnViewDetails"
                                                    runat="server"
                                                    Text="&#128065;"
                                                    CssClass="transaction-view-button"
                                                    CommandName="ViewDetails"
                                                    CommandArgument='<%# Eval("TransactionId") %>'
                                                    CausesValidation="false">
                                                </asp:LinkButton>

                                            </td>

                                        </tr>

                                    </ItemTemplate>

                                </asp:Repeater>

                            </tbody>

                        </table>

                    </div>


                    <asp:Panel
                        ID="pnlNoTransactions"
                        runat="server"
                        CssClass="transactions-empty-state"
                        Visible="false">

                        <div class="transactions-empty-icon">
                            &#128203;
                        </div>

                        <strong>
                            No transactions found
                        </strong>

                        <p>
                            Funding and withdrawal transactions
                            will appear here.
                        </p>

                    </asp:Panel>

                </section>


                <!-- DETAILS -->
                <aside class="transactions-details-card">

                    <div class="transactions-details-heading">

                        <h3>
                            Transaction Details
                        </h3>

                        <asp:LinkButton
                            ID="btnCloseDetails"
                            runat="server"
                            Text="�"
                            CssClass="transactions-close-button"
                            CausesValidation="false"
                            OnClick="btnCloseDetails_Click">
                        </asp:LinkButton>

                    </div>


                    <asp:Panel
                        ID="pnlEmptyDetails"
                        runat="server"
                        CssClass="transactions-empty-details">

                        <div class="transactions-empty-details-icon">
                            &#128269;
                        </div>

                        <strong>
                            Select a transaction
                        </strong>

                        <p>
                            Click the view button to see
                            transaction information.
                        </p>

                    </asp:Panel>


                    <asp:Panel
                        ID="pnlSelectedDetails"
                        runat="server"
                        Visible="false">

                        <div class="transactions-selected-summary">

                            <span
                                id="detailsIcon"
                                runat="server"
                                class="transactions-details-icon">

                                &#128176;

                            </span>

                            <div>

                                <strong>

                                    <asp:Label
                                        ID="lblDetailsTitle"
                                        runat="server">
                                    </asp:Label>

                                </strong>

                                <asp:Label
                                    ID="lblDetailsType"
                                    runat="server"
                                    CssClass="transactions-details-type">
                                </asp:Label>

                            </div>

                            <asp:Label
                                ID="lblDetailsStatus"
                                runat="server">
                            </asp:Label>

                        </div>


                        <div class="transactions-detail-row">

                            <span>Amount</span>

                            <asp:Label
                                ID="lblDetailsAmount"
                                runat="server">
                            </asp:Label>

                        </div>


                        <div class="transactions-detail-row">

                            <span>Date</span>

                            <asp:Label
                                ID="lblDetailsDate"
                                runat="server">
                            </asp:Label>

                        </div>


                        <div class="transactions-detail-row">

                            <span>Transaction ID</span>

                            <asp:Label
                                ID="lblDetailsId"
                                runat="server">
                            </asp:Label>

                        </div>


                        <div class="transactions-detail-row">

                            <span>Reference</span>

                            <asp:Label
                                ID="lblDetailsReference"
                                runat="server">
                            </asp:Label>

                        </div>


                        <div class="transactions-detail-row">

                            <span>Payment Method</span>

                            <asp:Label
                                ID="lblDetailsPaymentMethod"
                                runat="server">
                            </asp:Label>

                        </div>


                        <div class="transactions-description-row">

                            <span>Description</span>

                            <asp:Label
                                ID="lblDetailsDescription"
                                runat="server">
                            </asp:Label>

                        </div>


                        <asp:Button
                            ID="btnDownloadReceipt"
                            runat="server"
                            Text="? Download Receipt"
                            CssClass="transactions-download-button"
                            CausesValidation="false"
                            OnClick="btnDownloadReceipt_Click" />

                    </asp:Panel>

                </aside>

            </div>


            <section class="transactions-help-card">

                <div class="transactions-help-icon">
                    i
                </div>

                <div>




                    <strong>
                        Need help?
                    </strong>

                    <p>
                        Contact support if you have questions
                        about a transaction.
                    </p>

                </div>

                <a href="Default.aspx"
                   class="transactions-support-button">

                    Contact Support

                </a>

            </section>

        </main>

    </div>

</asp:Content>
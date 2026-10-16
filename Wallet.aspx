<%@ Page Title="Manage Wallet"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="Wallet.aspx.cs"
    Inherits="FreeHubProject.Wallet" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="WalletHead"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <link href="<%= ResolveUrl("~/Wallet.css?v=21") %>"
          rel="stylesheet"
          type="text/css" />

</asp:Content>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="wallet-page-layout">

        <!-- LEFT SIDEBAR -->
        <uc:Sidebar runat="server" ID="SidebarControl" />

        <!-- MAIN CONTENT -->
        <main class="wallet-main-content">

            <!-- PAGE HEADING -->
            <div class="wallet-heading-row">

                <div>

                    <h1>
                        <span class="wallet-h1-navy">Manage</span>
                        <span class="wallet-h1-green">Wallet</span>
                    </h1>

                    <div class="wallet-breadcrumb">

                        <a href="Wallet.aspx" class="breadcrumb-link">
                            Wallet
                        </a>

                        <span>&#8250;</span>

                        <strong>
                            Manage Wallet
                        </strong>

                    </div>

                </div>

            </div>

            <!-- STATUS MESSAGE -->
            <asp:Panel
                ID="pnlWalletMessage"
                runat="server"
                CssClass="wallet-message-panel"
                Visible="false">

                <asp:Label
                    ID="lblWalletMessage"
                    runat="server">
                </asp:Label>

            </asp:Panel>

            <!-- WALLET OVERVIEW (four pastel balance cards) -->
            <section class="wallet-overview-section">

                <div class="wallet-overview-grid">

                    <div class="wallet-overview-item ov-available">

                        <span class="overview-icon available-icon">
                            &#128178;
                        </span>

                        <div>

                            <small>
                                Available Balance
                            </small>

                            <asp:Label
                                ID="lblAvailableBalance"
                                runat="server"
                                CssClass="wallet-overview-amount available-amount"
                                Text="R0.00">
                            </asp:Label>

                        </div>

                    </div>

                    <div class="wallet-overview-item ov-hold">

                        <span class="overview-icon hold-icon">
                            &#9203;
                        </span>

                        <div>

                            <small>
                                On Hold
                            </small>

                            <asp:Label
                                ID="lblOnHoldBalance"
                                runat="server"
                                CssClass="wallet-overview-amount hold-amount"
                                Text="R0.00">
                            </asp:Label>

                        </div>

                    </div>

                    <div class="wallet-overview-item ov-pending">

                        <span class="overview-icon withdrawal-icon">
                            &#128228;
                        </span>

                        <div>

                            <small>
                                Pending Withdrawals
                            </small>

                            <asp:Label
                                ID="lblPendingWithdrawals"
                                runat="server"
                                CssClass="wallet-overview-amount withdrawal-amount"
                                Text="R0.00">
                            </asp:Label>

                        </div>

                    </div>

                    <div class="wallet-overview-item ov-total">

                        <span class="overview-icon total-icon">
                            &#128142;
                        </span>

                        <div>

                            <small>
                                Total Balance
                            </small>

                            <asp:Label
                                ID="lblTotalBalance"
                                runat="server"
                                CssClass="wallet-overview-amount total-amount"
                                Text="R0.00">
                            </asp:Label>

                        </div>

                    </div>

                </div>

            </section>

            <!-- WALLET ACTIONS (full-width horizontal row) -->
            <div class="wallet-middle-layout">

                <!-- WALLET ACTIONS -->
                <section class="wallet-card wallet-actions-card">

                    <h2>
                        <span class="wallet-h2-ic" aria-hidden="true">&#9889;</span>
                        Wallet Actions
                    </h2>

                    <p class="wallet-card-description">
                        Choose what you would like to do.
                    </p>

                    <div class="wallet-actions-grid">

                        <asp:Panel ID="pnlFundWalletAction" runat="server">
                        <asp:LinkButton
                            ID="btnFundWallet"
                            runat="server"
                            CssClass="wallet-action-item"
                            CausesValidation="false"
                            OnClick="btnFundWallet_Click">

                            <span class="wallet-action-icon fund-icon">
                                &#10133;
                            </span>

                            <span class="wallet-action-information">

                                <strong>
                                    Fund Wallet
                                </strong>

                            </span>

                            <span class="wallet-action-arrow">
                                &#8250;
                            </span>

                        </asp:LinkButton>
                        </asp:Panel>

                        <asp:LinkButton
                            ID="btnWithdrawFunds"
                            runat="server"
                            CssClass="wallet-action-item"
                            CausesValidation="false"
                            OnClick="btnWithdrawFunds_Click">

                            <span class="wallet-action-icon withdraw-icon">
                                &#128228;
                            </span>

                            <span class="wallet-action-information">

                                <strong>
                                    Withdraw Funds
                                </strong>

                            </span>

                            <span class="wallet-action-arrow">
                                &#8250;
                            </span>

                        </asp:LinkButton>

                        <asp:LinkButton
                            ID="btnViewTransactions"
                            runat="server"
                            CssClass="wallet-action-item"
                            CausesValidation="false"
                            OnClick="btnViewTransactions_Click">

                            <span class="wallet-action-icon transactions-icon">
                                &#128203;
                            </span>

                            <span class="wallet-action-information">

                                <strong>
                                    View Transactions
                                </strong>

                            </span>

                            <span class="wallet-action-arrow">
                                &#8250;
                            </span>

                        </asp:LinkButton>

                        <asp:LinkButton
                            ID="btnPayouts"
                            runat="server"
                            CssClass="wallet-action-item"
                            CausesValidation="false"
                            OnClick="btnPayouts_Click">

                            <span class="wallet-action-icon payouts-icon">
                                &#128184;
                            </span>

                            <span class="wallet-action-information">

                                <strong>
                                    Payouts
                                </strong>

                            </span>

                            <span class="wallet-action-arrow">
                                &#8250;
                            </span>

                        </asp:LinkButton>

                        <asp:LinkButton
                            ID="btnDisputes"
                            runat="server"
                            CssClass="wallet-action-item"
                            CausesValidation="false"
                            OnClick="btnDisputes_Click">

                            <span class="wallet-action-icon disputes-icon">
                                &#9888;
                            </span>

                            <span class="wallet-action-information">

                                <strong>
                                    Disputes
                                </strong>

                            </span>

                            <span class="wallet-action-arrow">
                                &#8250;
                            </span>

                        </asp:LinkButton>

                        <asp:LinkButton
                            ID="btnRefunds"
                            runat="server"
                            CssClass="wallet-action-item"
                            CausesValidation="false"
                            OnClick="btnRefunds_Click">

                            <span class="wallet-action-icon refunds-icon">
                                &#8617;
                            </span>

                            <span class="wallet-action-information">

                                <strong>
                                    Refunds
                                </strong>

                            </span>

                            <span class="wallet-action-arrow">
                                &#8250;
                            </span>

                        </asp:LinkButton>

                    </div>

                </section>

            <!-- RECENT TRANSACTIONS (right column) -->
            <section class="wallet-card wallet-transactions-card">

                <div class="wallet-transactions-heading">

                    <h2>
                        <span class="wallet-h2-ic" aria-hidden="true">&#128336;</span>
                        Recent Transactions
                    </h2>

                    <asp:Button
                        ID="btnViewAllTop"
                        runat="server"
                        Text="View All &#8594;"
                        CssClass="wallet-view-all-link"
                        CausesValidation="false"
                        OnClick="btnViewTransactions_Click" />

                </div>

                <div class="wallet-table-wrapper">

                    <table class="wallet-transactions-table">

                        <thead>

                            <tr>

                                <th>Date</th>
                                <th>Type</th>
                                <th class="tx-amount-col">Amount</th>
                                <th>Status</th>

                            </tr>

                        </thead>

                        <tbody>

                            <asp:Repeater
                                ID="rptTransactions"
                                runat="server"
                                OnItemCommand="rptTransactions_ItemCommand">

                                <ItemTemplate>

                                    <tr>

                                        <td class="tx-date-cell">

                                            <%-- Date doubles as the row's "open transaction" link,
                                                 preserving the existing ViewTransaction command. --%>
                                            <asp:LinkButton
                                                ID="btnViewTransaction"
                                                runat="server"
                                                CssClass="tx-date-link"
                                                CommandName="ViewTransaction"
                                                CommandArgument='<%# Eval("TransactionId") %>'
                                                CausesValidation="false"
                                                Text='<%# TimeHelper.ToSast(Eval("TransactionDate")).ToString("dd MMM yyyy, hh:mm tt") %>'>
                                            </asp:LinkButton>

                                        </td>

                                        <td>

                                            <span class='<%# GetTransactionTypeClass(Convert.ToString(Eval("Type"))) %>'>

                                                <%# Server.HtmlEncode(
                                                    Convert.ToString(
                                                        Eval("Type")
                                                    )
                                                ) %>

                                            </span>

                                        </td>

                                        <td class='tx-amount-col <%# GetAmountClass(Convert.ToString(Eval("Type"))) %>'>

                                            <%# FormatTransactionAmount(
                                                Convert.ToDecimal(Eval("Amount")),
                                                Convert.ToString(Eval("Type"))
                                            ) %>

                                        </td>

                                        <td>

                                            <span class='<%# GetStatusClass(Convert.ToString(Eval("Status"))) %>'>

                                                <%# Server.HtmlEncode(
                                                    Convert.ToString(
                                                        Eval("Status")
                                                    )
                                                ) %>

                                            </span>

                                        </td>

                                    </tr>

                                </ItemTemplate>

                            </asp:Repeater>

                        </tbody>

                    </table>

                </div>

                <!-- REPEATER DOES NOT SUPPORT EMPTYDATATEMPLATE -->
                <asp:Panel
                    ID="pnlNoTransactions"
                    runat="server"
                    CssClass="wallet-empty-transactions"
                    Visible="false">

                    <div class="wallet-empty-icon">
                        &#128237;
                    </div>

                    <strong>
                        No transactions available
                    </strong>

                    <p>
                        Your wallet transactions will appear here.
                    </p>

                </asp:Panel>

                <asp:Button
                    ID="btnViewAllTransactions"
                    runat="server"
                    Text="View All Transactions &#8250;"
                    CssClass="wallet-bottom-view-button"
                    CausesValidation="false"
                    OnClick="btnViewTransactions_Click" />

            </section>

            </div>
            <!-- /wallet-middle-layout -->

        </main>

    </div>

</asp:Content>
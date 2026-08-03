<%@ Page Title="Manage Wallet"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="Wallet.aspx.cs"
    Inherits="FreeHubProject.Wallet" %>

<asp:Content ID="WalletHead"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <link href="<%= ResolveUrl("~/Wallet.css?v=4") %>"
          rel="stylesheet"
          type="text/css" />

</asp:Content>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="wallet-page-layout">

        <!-- LEFT SIDEBAR -->
        <aside class="wallet-sidebar">

            <div class="wallet-sidebar-section">

                <a href="Dashboard.aspx"
                   class="wallet-sidebar-link">

                    <span class="wallet-sidebar-icon">⌂</span>
                    <span>Dashboard</span>

                </a>

                <a href="CompletedProjects.aspx"
                   class="wallet-sidebar-link">

                    <span class="wallet-sidebar-icon">▣</span>
                    <span>My Projects</span>

                </a>

                <a href="Proposals.aspx"
                   class="wallet-sidebar-link">

                    <span class="wallet-sidebar-icon">▤</span>
                    <span>Proposals</span>

                </a>

                <a href="Messages.aspx"
                   class="wallet-sidebar-link">

                    <span class="wallet-sidebar-icon">✉</span>
                    <span>Messages</span>

                </a>

                <a href="BrowseProjects.aspx"
                   class="wallet-sidebar-link">

                    <span class="wallet-sidebar-icon">♙</span>
                    <span>Freelancers</span>

                </a>

                <a href="Contracts.aspx"
                   class="wallet-sidebar-link">

                    <span class="wallet-sidebar-icon">▧</span>
                    <span>Contracts</span>

                </a>

                <a href="Wallet.aspx"
                   class="wallet-sidebar-link wallet-active-link">

                    <span class="wallet-sidebar-icon">▱</span>
                    <span>Wallet</span>

                    <span class="wallet-sidebar-arrow">
                        ⌄
                    </span>

                </a>

                <div class="wallet-submenu">

                    <a href="Wallet.aspx"
                       class="wallet-submenu-active">

                        Manage Wallet

                    </a>

                    <a href="Transactions.aspx">
                        Transactions
                    </a>

                    <a href="Payouts.aspx">
                        Payouts
                    </a>

                    <a href="FundWallet.aspx">
                        Fund Wallet
                    </a>

                    <a href="WithdrawFunds.aspx">
                        Withdraw Funds
                    </a>

                </div>

                <a href="Disputes.aspx"
                   class="wallet-sidebar-link">

                    <span class="wallet-sidebar-icon">◉</span>
                    <span>Disputes</span>

                </a>

                <a href="Refunds.aspx"
                   class="wallet-sidebar-link">

                    <span class="wallet-sidebar-icon">↻</span>
                    <span>Refunds</span>

                </a>

                <a href="Reports.aspx"
                   class="wallet-sidebar-link">

                    <span class="wallet-sidebar-icon">▤</span>
                    <span>Reports</span>

                </a>

            </div>

            <div class="wallet-sidebar-section wallet-account-section">

                <a href="Profile.aspx"
                   class="wallet-sidebar-link">

                    <span class="wallet-sidebar-icon">⚙</span>
                    <span>Profile Settings</span>

                </a>

                <a href="Settings.aspx"
                   class="wallet-sidebar-link">

                    <span class="wallet-sidebar-icon">⚙</span>
                    <span>Account Settings</span>

                </a>

                <a href="HelpSupport.aspx"
                   class="wallet-sidebar-link">

                    <span class="wallet-sidebar-icon">?</span>
                    <span>Help &amp; Support</span>

                </a>

            </div>

        </aside>

        <!-- MAIN CONTENT -->
        <main class="wallet-main-content">

            <!-- PAGE HEADING -->
            <div class="wallet-heading-row">

                <div>

                    <h1>
                        Manage Wallet
                    </h1>

                    <div class="wallet-breadcrumb">

                        Wallet

                        <span>›</span>

                        <strong>
                            Manage Wallet
                        </strong>

                    </div>

                    <p>
                        View your wallet balance, manage funds
                        and access wallet actions.
                    </p>

                </div>

                <section class="wallet-current-balance">

                    <div>

                        <small>
                            Current Wallet Balance
                        </small>

                        <asp:Label
                            ID="lblCurrentWalletBalance"
                            runat="server"
                            CssClass="wallet-current-balance-value"
                            Text="R0.00">
                        </asp:Label>

                    </div>

                    <span class="wallet-balance-icon">
                        ▱
                    </span>

                </section>

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

            <!-- WALLET OVERVIEW -->
            <section class="wallet-card wallet-overview-card">

                <h2>
                    Wallet Overview
                </h2>

                <div class="wallet-overview-grid">

                    <div class="wallet-overview-item">

                        <span class="overview-icon available-icon">
                            ▱
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

                    <div class="wallet-overview-item">

                        <span class="overview-icon hold-icon">
                            ◷
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

                    <div class="wallet-overview-item">

                        <span class="overview-icon withdrawal-icon">
                            ↑
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

                    <div class="wallet-overview-item">

                        <span class="overview-icon total-icon">
                            ◉
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

            <!-- ACTIONS AND SUMMARY -->
            <div class="wallet-middle-layout">

                <!-- WALLET ACTIONS -->
                <section class="wallet-card wallet-actions-card">

                    <h2>
                        Wallet Actions
                    </h2>

                    <p class="wallet-card-description">
                        Choose what you would like to do.
                    </p>

                    <div class="wallet-actions-grid">

                        <asp:LinkButton
                            ID="btnFundWallet"
                            runat="server"
                            CssClass="wallet-action-item"
                            OnClick="btnFundWallet_Click">

                            <span class="wallet-action-icon fund-icon">
                                ▱
                            </span>

                            <span class="wallet-action-information">

                                <strong>
                                    Fund Wallet
                                </strong>

                                <small>
                                    Add money to your wallet using
                                    supported payment methods.
                                </small>

                            </span>

                            <span class="wallet-action-arrow">
                                ›
                            </span>

                        </asp:LinkButton>

                        <asp:LinkButton
                            ID="btnWithdrawFunds"
                            runat="server"
                            CssClass="wallet-action-item"
                            OnClick="btnWithdrawFunds_Click">

                            <span class="wallet-action-icon withdraw-icon">
                                ↓
                            </span>

                            <span class="wallet-action-information">

                                <strong>
                                    Withdraw Funds
                                </strong>

                                <small>
                                    Withdraw your earnings to
                                    your bank account.
                                </small>

                            </span>

                            <span class="wallet-action-arrow">
                                ›
                            </span>

                        </asp:LinkButton>

                        <asp:LinkButton
                            ID="btnViewTransactions"
                            runat="server"
                            CssClass="wallet-action-item"
                            OnClick="btnViewTransactions_Click">

                            <span class="wallet-action-icon transactions-icon">
                                ☷
                            </span>

                            <span class="wallet-action-information">

                                <strong>
                                    View Transactions
                                </strong>

                                <small>
                                    View your complete transaction
                                    history and activity.
                                </small>

                            </span>

                            <span class="wallet-action-arrow">
                                ›
                            </span>

                        </asp:LinkButton>

                        <asp:LinkButton
                            ID="btnPayouts"
                            runat="server"
                            CssClass="wallet-action-item"
                            OnClick="btnPayouts_Click">

                            <span class="wallet-action-icon payouts-icon">
                                ▣
                            </span>

                            <span class="wallet-action-information">

                                <strong>
                                    Payouts
                                </strong>

                                <small>
                                    Manage payouts to freelancers
                                    and contractors.
                                </small>

                            </span>

                            <span class="wallet-action-arrow">
                                ›
                            </span>

                        </asp:LinkButton>

                        <asp:LinkButton
                            ID="btnDisputes"
                            runat="server"
                            CssClass="wallet-action-item"
                            OnClick="btnDisputes_Click">

                            <span class="wallet-action-icon disputes-icon">
                                ◈
                            </span>

                            <span class="wallet-action-information">

                                <strong>
                                    Disputes
                                </strong>

                                <small>
                                    Manage and track wallet-related
                                    disputes.
                                </small>

                            </span>

                            <span class="wallet-action-arrow">
                                ›
                            </span>

                        </asp:LinkButton>

                        <asp:LinkButton
                            ID="btnRefunds"
                            runat="server"
                            CssClass="wallet-action-item"
                            OnClick="btnRefunds_Click">

                            <span class="wallet-action-icon refunds-icon">
                                ↻
                            </span>

                            <span class="wallet-action-information">

                                <strong>
                                    Refunds
                                </strong>

                                <small>
                                    View and manage returned
                                    wallet funds.
                                </small>

                            </span>

                            <span class="wallet-action-arrow">
                                ›
                            </span>

                        </asp:LinkButton>

                    </div>

                </section>

                <!-- WALLET SUMMARY -->
                <aside class="wallet-card wallet-summary-card">

                    <h2>
                        Wallet Summary
                    </h2>

                    <div class="wallet-summary-line">

                        <span>
                            Available Balance
                        </span>

                        <asp:Label
                            ID="lblSummaryAvailable"
                            runat="server"
                            CssClass="summary-green"
                            Text="R0.00">
                        </asp:Label>

                    </div>

                    <div class="wallet-summary-line">

                        <span>
                            On Hold
                        </span>

                        <asp:Label
                            ID="lblSummaryOnHold"
                            runat="server"
                            CssClass="summary-orange"
                            Text="R0.00">
                        </asp:Label>

                    </div>

                    <div class="wallet-summary-line">

                        <span>
                            Pending Withdrawals
                        </span>

                        <asp:Label
                            ID="lblSummaryPending"
                            runat="server"
                            CssClass="summary-blue"
                            Text="R0.00">
                        </asp:Label>

                    </div>

                    <div class="wallet-summary-total">

                        <span>
                            Total Balance
                        </span>

                        <asp:Label
                            ID="lblSummaryTotal"
                            runat="server"
                            CssClass="summary-total-value"
                            Text="R0.00">
                        </asp:Label>

                    </div>

                    <asp:Button
                        ID="btnSummaryFundWallet"
                        runat="server"
                        Text="Fund Wallet"
                        CssClass="wallet-fund-button"
                        OnClick="btnFundWallet_Click" />

                </aside>

            </div>

            <!-- RECENT TRANSACTIONS -->
            <section class="wallet-card wallet-transactions-card">

                <div class="wallet-transactions-heading">

                    <h2>
                        Recent Transactions
                    </h2>

                    <asp:Button
                        ID="btnViewAllTop"
                        runat="server"
                        Text="View All"
                        CssClass="wallet-view-all-link"
                        OnClick="btnViewTransactions_Click" />

                </div>

                <div class="wallet-table-wrapper">

                    <table class="wallet-transactions-table">

                        <thead>

                            <tr>

                                <th></th>
                                <th>Date</th>
                                <th>Description</th>
                                <th>Type</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th>Reference</th>
                                <th></th>

                            </tr>

                        </thead>

                        <tbody>

                            <asp:Repeater
                                ID="rptTransactions"
                                runat="server">

                                <ItemTemplate>

                                    <tr>

                                        <td>

                                            <span class='<%# GetTransactionIconClass(Convert.ToString(Eval("Type"))) %>'>

                                                <%# GetTransactionIcon(Convert.ToString(Eval("Type"))) %>

                                            </span>

                                        </td>

                                        <td>

                                            <%# Convert.ToDateTime(Eval("TransactionDate"))
                                                .ToString("dd MMM yyyy, hh:mm tt") %>

                                        </td>

                                        <td>

                                            <%# Server.HtmlEncode(
                                                Convert.ToString(
                                                    Eval("Description")
                                                )
                                            ) %>

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

                                        <td class='<%# GetAmountClass(Convert.ToString(Eval("Type"))) %>'>

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

                                        <td>

                                            <%# Server.HtmlEncode(
                                                Convert.ToString(
                                                    Eval("Reference")
                                                )
                                            ) %>

                                        </td>

                                        <td>

                                            <asp:LinkButton
                                                ID="btnViewTransaction"
                                                runat="server"
                                                CssClass="transaction-view-button"
                                                Text="◉"
                                                CommandArgument='<%# Eval("Reference") %>'
                                                OnCommand="ViewTransaction_Command">
                                            </asp:LinkButton>

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
                        ▤
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
                    Text="View All Transactions ›"
                    CssClass="wallet-bottom-view-button"
                    OnClick="btnViewTransactions_Click" />

            </section>

        </main>

    </div>

</asp:Content>
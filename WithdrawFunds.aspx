<%@ Page Title="Withdraw Funds"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="WithdrawFunds.aspx.cs"
    Inherits="FreeHubProject.WithdrawFunds" %>

<asp:Content ID="WithdrawFundsHead"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <link href="<%= ResolveUrl("~/WithdrawFunds.css?v=1") %>"
          rel="stylesheet"
          type="text/css" />

</asp:Content>

<asp:Content ID="WithdrawFundsContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="withdraw-page">

        <!-- LEFT SIDEBAR -->
        <aside class="withdraw-sidebar">

            <a href="Dashboard.aspx"
               class="withdraw-menu-link">

                <span>¦</span>
                Dashboard

            </a>

            <a href="CompletedProjects.aspx"
               class="withdraw-menu-link">

                <span>?</span>
                My Projects

            </a>

            <a href="BrowseProjects.aspx"
               class="withdraw-menu-link">

                <span>?</span>
                Freelancers

            </a>

            <a href="SelectProposal.aspx"
               class="withdraw-menu-link">

                <span>?</span>
                Proposals

            </a>

            <a href="Messages.aspx"
               class="withdraw-menu-link">

                <span>?</span>
                Messages

            </a>

            <a href="Contracts.aspx"
               class="withdraw-menu-link">

                <span>?</span>
                Contracts

            </a>

            <a href="Wallet.aspx"
               class="withdraw-menu-link withdraw-menu-active">

                <span>?</span>
                Wallet

            </a>

            <div class="withdraw-submenu">

                <a href="Wallet.aspx">
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

                <a href="WithdrawFunds.aspx"
                   class="withdraw-submenu-active">

                    Withdraw Funds

                </a>

            </div>

            <a href="Disputes.aspx"
               class="withdraw-menu-link">

                <span>?</span>
                Disputes

            </a>

            <a href="Refunds.aspx"
               class="withdraw-menu-link">

                <span>?</span>
                Refunds

            </a>

            <a href="Reports.aspx"
               class="withdraw-menu-link">

                <span>?</span>
                Reports

            </a>

            <div class="withdraw-divider"></div>

            <a href="Default.aspx"
               class="withdraw-menu-link">

                <span>?</span>
                Profile Settings

            </a>

            <a href="Default.aspx"
               class="withdraw-menu-link">

                <span>?</span>
                Account Settings

            </a>

            <a href="Default.aspx"
               class="withdraw-menu-link">

                <span>?</span>
                Help &amp; Support

            </a>

        </aside>


        <!-- MAIN CONTENT -->
        <main class="withdraw-main">

            <!-- PAGE HEADER -->
            <div class="withdraw-header">

                <div>

                    <h1>
                        Withdraw Funds
                    </h1>

                    <div class="withdraw-breadcrumb">

                        Wallet

                        <span>›</span>

                        <strong>
                            Withdraw Funds
                        </strong>

                    </div>

                    <p>
                        Withdraw your earnings to your preferred
                        bank account securely.
                    </p>

                </div>


                <div class="withdraw-balance-card">

                    <div>

                        <small>
                            Current Wallet Balance
                        </small>

                        <asp:Label
                            ID="lblCurrentBalance"
                            runat="server"
                            CssClass="withdraw-balance-value"
                            Text="R0.00">
                        </asp:Label>

                    </div>

                    <span class="withdraw-wallet-icon">
                        ?
                    </span>

                </div>

            </div>


            <!-- MESSAGE -->
            <asp:Panel
                ID="pnlMessage"
                runat="server"
                CssClass="withdraw-message"
                Visible="false">

                <asp:Label
                    ID="lblMessage"
                    runat="server">
                </asp:Label>

            </asp:Panel>


            <div class="withdraw-layout">

                <!-- WITHDRAWAL FORM -->
                <section class="withdraw-form-card">

                    <h2>
                        Withdraw Funds
                    </h2>


                    <div class="withdraw-available-box">

                        <small>
                            Available Balance
                        </small>

                        <asp:Label
                            ID="lblAvailableBalance"
                            runat="server"
                            CssClass="withdraw-available-value"
                            Text="R0.00">
                        </asp:Label>

                    </div>


                    <!-- AMOUNT -->
                    <div class="withdraw-field">

                        <label>
                            Enter Amount (ZAR)
                        </label>

                        <div class="withdraw-amount-box">

                            <span>R</span>

                            <asp:TextBox
                                ID="txtAmount"
                                runat="server"
                                CssClass="withdraw-amount-input"
                                TextMode="Number"
                                placeholder="0.00">
                            </asp:TextBox>

                        </div>

                        <small>
                            Minimum withdrawal amount is R100.00.
                        </small>

                    </div>


                    <!-- BANK ACCOUNT -->
                    <div class="withdraw-field">

                        <label>
                            Select Bank Account
                        </label>

                        <asp:DropDownList
                            ID="ddlBankAccount"
                            runat="server"
                            CssClass="withdraw-dropdown">

                            <asp:ListItem
                                Text="Choose account"
                                Value="">
                            </asp:ListItem>

                        </asp:DropDownList>

                    </div>


                    <!-- METHOD -->
                    <div class="withdraw-field">

                        <label>
                            Withdrawal Method
                        </label>

                        <div class="withdraw-method-card">

                            <span class="withdraw-method-icon">
                                ?
                            </span>

                            <div>

                                <strong>
                                    Bank Transfer
                                </strong>

                                <small>
                                    Transfer to your selected bank account.
                                </small>

                            </div>

                        </div>

                    </div>


                    <!-- SUMMARY -->
                    <section class="withdraw-summary">

                        <h3>
                            Withdrawal Summary
                        </h3>

                        <div class="withdraw-summary-row">

                            <span>
                                Withdrawal Amount
                            </span>

                            <asp:Label
                                ID="lblSummaryAmount"
                                runat="server"
                                Text="R0.00">
                            </asp:Label>

                        </div>

                        <div class="withdraw-summary-row">

                            <span>
                                Service Fee
                            </span>

                            <asp:Label
                                ID="lblServiceFee"
                                runat="server"
                                Text="R0.00">
                            </asp:Label>

                        </div>

                        <div class="withdraw-summary-total">

                            <span>
                                You Will Receive
                            </span>

                            <asp:Label
                                ID="lblYouWillReceive"
                                runat="server"
                                Text="R0.00">
                            </asp:Label>

                        </div>

                    </section>


                    <asp:Button
                        ID="btnContinue"
                        runat="server"
                        Text="Continue"
                        CssClass="withdraw-continue-button"
                        OnClick="btnContinue_Click" />

                </section>


                <!-- RIGHT SIDE -->
                <aside class="withdraw-right-column">

                    <!-- IMPORTANT INFORMATION -->
                    <section class="withdraw-side-card">

                        <div class="withdraw-side-heading">

                            <h3>
                                Important Information
                            </h3>

                            <span>
                                ?
                            </span>

                        </div>

                        <ul class="withdraw-information-list">

                            <li>
                                Withdrawals remain pending until
                                approved by an administrator.
                            </li>

                            <li>
                                Approved withdrawals are processed
                                within 1–3 business days.
                            </li>

                            <li>
                                Make sure your bank details are correct.
                            </li>

                            <li>
                                Minimum withdrawal amount is R100.00.
                            </li>

                        </ul>

                    </section>


                    <!-- RECENT WITHDRAWALS -->
                    <section class="withdraw-side-card">

                        <div class="withdraw-side-heading">

                            <h3>
                                Recent Withdrawals
                            </h3>

                            <asp:Button
                                ID="btnViewAll"
                                runat="server"
                                Text="View All"
                                CssClass="withdraw-view-all"
                                CausesValidation="false"
                                OnClick="btnViewAll_Click" />

                        </div>


                        <asp:Repeater
                            ID="rptWithdrawals"
                            runat="server">

                            <ItemTemplate>

                                <div class="withdraw-history-item">

                                    <div>

                                        <strong>
                                            <%# Convert.ToDateTime(
                                                    Eval("RequestDate")
                                                ).ToString("dd MMM yyyy") %>
                                        </strong>

                                        <small>
                                            To <%# Server.HtmlEncode(
                                                Convert.ToString(
                                                    Eval("BankAccount")
                                                )
                                            ) %>
                                        </small>

                                    </div>

                                    <div class="withdraw-history-right">

                                        <strong>
                                            - R<%# Convert.ToDecimal(
                                                Eval("Amount")
                                            ).ToString("N2") %>
                                        </strong>

                                        <span class="withdraw-pending-status">

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
                            ID="pnlNoWithdrawals"
                            runat="server"
                            CssClass="withdraw-empty-history"
                            Visible="false">

                            <div class="withdraw-empty-icon">
                                ?
                            </div>

                            <strong>
                                No withdrawal requests
                            </strong>

                            <p>
                                Your recent withdrawal requests
                                will appear here.
                            </p>

                        </asp:Panel>

                    </section>

                </aside>

            </div>

        </main>

    </div>


    <script type="text/javascript">

        function updateWithdrawalSummary() {

            var amountBox =
                document.getElementById(
                    "<%= txtAmount.ClientID %>"
                );

            var amount =
                parseFloat(amountBox.value);

            if (isNaN(amount) || amount < 0) {
                amount = 0;
            }

            var fee = 0;

            var receive =
                amount - fee;

            document.getElementById(
                "<%= lblSummaryAmount.ClientID %>"
            ).innerText =
                "R" +
                amount.toLocaleString(
                    "en-ZA",
                    {
                        minimumFractionDigits: 2,
                        maximumFractionDigits: 2
                    }
                );

            document.getElementById(
                "<%= lblServiceFee.ClientID %>"
            ).innerText =
                "R" +
                fee.toLocaleString(
                    "en-ZA",
                    {
                        minimumFractionDigits: 2,
                        maximumFractionDigits: 2
                    }
                );

            document.getElementById(
                "<%= lblYouWillReceive.ClientID %>"
            ).innerText =
                "R" +
                receive.toLocaleString(
                    "en-ZA",
                    {
                        minimumFractionDigits: 2,
                        maximumFractionDigits: 2
                    }
                );
        }


        document.addEventListener(
            "DOMContentLoaded",
            function () {

                var amountBox =
                    document.getElementById(
                        "<%= txtAmount.ClientID %>"
                    );

                if (amountBox) {

                    amountBox.addEventListener(
                        "input",
                        updateWithdrawalSummary
                    );
                }
            }
        );

    </script>

</asp:Content>
<%@ Page Title="Fund Wallet"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="FundWallet.aspx.cs"
    Inherits="FreeHubProject.FundWallet" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="FundWalletHead"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <link href="<%= ResolveUrl("~/FundWallet.css?v=10") %>"
          rel="stylesheet"
          type="text/css" />

</asp:Content>

<asp:Content ID="FundWalletContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="fw-page">

        <!-- SIDEBAR -->
        <uc:Sidebar runat="server" ID="SidebarControl" />


        <!-- MAIN AREA -->
        <main class="fw-main">

            <!-- HEADER -->
            <div class="fw-header">

                <div>

                    <h1>Fund Wallet</h1>

                    <div class="fw-breadcrumb">

                        <a href="Wallet.aspx" class="breadcrumb-link">
                            Wallet
                        </a>

                        <span>›</span>

                        <strong>Fund Wallet</strong>

                    </div>

                    <p>
                        Add money to your wallet using one
                        of the available payment methods.
                    </p>

                </div>

                <div class="fw-balance-card">

                    <div>

                        <small>
                            Current Wallet Balance
                        </small>

                        <asp:Label
                            ID="lblCurrentBalance"
                            runat="server"
                            CssClass="fw-balance-value"
                            Text="R0.00">
                        </asp:Label>

                    </div>

                    <span class="fw-wallet-icon">
                        &#128176;
                    </span>

                </div>

            </div>


            <!-- MESSAGE -->
            <asp:Panel
                ID="pnlMessage"
                runat="server"
                Visible="false"
                CssClass="fw-message">

                <asp:Label
                    ID="lblMessage"
                    runat="server">
                </asp:Label>

            </asp:Panel>


            <div class="fw-layout">

                <!-- FORM CARD -->
                <section class="fw-form-card">

                    <!-- AMOUNT -->
                    <div class="fw-section">

                        <h2>
                            1. Enter Amount
                        </h2>

                        <p>
                            Enter the amount you want to add
                            to your wallet.
                        </p>

                        <label class="fw-label">
                            Amount (ZAR)
                        </label>

                        <div class="fw-amount-box">

                            <span>R</span>

                            <asp:TextBox
                                ID="txtAmount"
                                runat="server"
                                CssClass="fw-amount-input"
                                TextMode="Number"
                                placeholder="0.00">
                            </asp:TextBox>

                        </div>

                        <div class="fw-quick-grid">

                            <asp:Button
                                ID="btn500"
                                runat="server"
                                Text="R500"
                                CssClass="fw-quick-button"
                                CausesValidation="false"
                                OnClick="btn500_Click" />

                            <asp:Button
                                ID="btn1000"
                                runat="server"
                                Text="R1,000"
                                CssClass="fw-quick-button"
                                CausesValidation="false"
                                OnClick="btn1000_Click" />

                            <asp:Button
                                ID="btn2500"
                                runat="server"
                                Text="R2,500"
                                CssClass="fw-quick-button"
                                CausesValidation="false"
                                OnClick="btn2500_Click" />

                            <asp:Button
                                ID="btn5000"
                                runat="server"
                                Text="R5,000"
                                CssClass="fw-quick-button"
                                CausesValidation="false"
                                OnClick="btn5000_Click" />

                            <asp:Button
                                ID="btnOther"
                                runat="server"
                                Text="Other"
                                CssClass="fw-quick-button"
                                CausesValidation="false"
                                OnClick="btnOther_Click" />

                        </div>

                    </div>


                    <!-- PAYMENT METHOD -->
                    <div class="fw-section">

                        <h2>
                            2. Select Payment Method
                        </h2>

                        <p>
                            Choose your preferred payment method.
                        </p>

                        <asp:RadioButtonList
                            ID="rblPaymentMethod"
                            runat="server"
                            CssClass="fw-payment-list"
                            RepeatLayout="Flow">

                            <asp:ListItem
                                Text="Bank Transfer"
                                Value="Bank Transfer"
                                Selected="True">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Instant EFT"
                                Value="Instant EFT">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Credit / Debit Card"
                                Value="Card">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="PayShap"
                                Value="PayShap">
                            </asp:ListItem>

                        </asp:RadioButtonList>

                    </div>


                    <asp:Button
                        ID="btnProceed"
                        runat="server"
                        Text="Proceed to Payment"
                        CssClass="fw-proceed-button"
                        CausesValidation="false"
                        OnClick="btnProceed_Click" />

                    <div class="fw-secure-text">
                        ? Your payment details are secure and encrypted.
                    </div>

                </section>


                <!-- RIGHT COLUMN -->
                <aside class="fw-right-column">

                    <section class="fw-side-card">

                        <div class="fw-side-heading">

                            <h3>How It Works</h3>

                            <span>i</span>

                        </div>

                        <div class="fw-step-row">

                            <span>1</span>

                            <p>
                                Enter the amount you want to add.
                            </p>

                        </div>

                        <div class="fw-step-row">

                            <span>2</span>

                            <p>
                                Select your preferred payment method.
                            </p>

                        </div>

                        <div class="fw-step-row">

                            <span>3</span>

                            <p>
                                Confirm and complete your payment.
                            </p>

                        </div>

                        <div class="fw-step-row">

                            <span>4</span>

                            <p>
                                Your wallet is updated after confirmation.
                            </p>

                        </div>

                    </section>


                    <section class="fw-side-card">

                        <div class="fw-side-heading">

                            <h3>Recent Top-ups</h3>

                            <asp:Button
                                ID="btnViewAll"
                                runat="server"
                                Text="View All"
                                CssClass="fw-view-all"
                                CausesValidation="false"
                                OnClick="btnViewAll_Click" />

                        </div>

                        <asp:Panel
                            ID="pnlRecentTopUps"
                            runat="server"
                            CssClass="fw-empty-topups">

                            <div class="fw-empty-icon">
                                &#128203;
                            </div>

                            <strong>
                                No recent top-ups
                            </strong>

                            <p>
                                Your wallet funding history will appear here.
                            </p>

                        </asp:Panel>

                    </section>

                </aside>

            </div>

        </main>

    </div>

</asp:Content>
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

    <link href="<%= ResolveUrl("~/FundWallet.css?v=11") %>"
          rel="stylesheet"
          type="text/css" />

    <style type="text/css">
        /* Required-field star beside the label. */
        .fw-required {
            color: #d4474f;
            margin-left: 2px;
            font-weight: bold;
        }
        /* Compact validation message shown beside the label (not under the input). */
        .fw-amount-error {
            margin-left: 8px;
            color: #d4474f;
            font-size: 12px;
            font-weight: 600;
        }
        .fw-amount-error:empty { display: none; }
        /* Red highlight when the amount is invalid. */
        .fw-amount-input.input-invalid {
            border-color: #d4474f !important;
            box-shadow: 0 0 0 1px #d4474f;
        }
    </style>

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

                        <span>&#8250;</span>

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
                            <span class="fw-required">*</span>
                            <asp:Label ID="lblAmountError" runat="server" CssClass="fw-amount-error" EnableViewState="false"></asp:Label>
                        </label>

                        <div class="fw-amount-box">

                            <span>R</span>

                            <%-- Text input (not type=number) with numeric hints so no
                                 spinner, range, "e", "+", "-", comma or decimal point can be
                                 entered. Whole-rand integers only; JS enforces, C# re-validates. --%>
                            <asp:TextBox
                                ID="txtAmount"
                                runat="server"
                                CssClass="fw-amount-input"
                                TextMode="SingleLine"
                                MaxLength="8"
                                inputmode="numeric"
                                pattern="[0-9]*"
                                autocomplete="off"
                                placeholder="0">
                            </asp:TextBox>

                        </div>

                        <div class="fw-quick-grid">

                            <asp:Button
                                ID="btn500"
                                runat="server"
                                Text="R500"
                                CssClass="fw-quick-button"
                                CausesValidation="false"
                                OnClientClick="setQuickAmount(500); return false;"
                                OnClick="btn500_Click" />

                            <asp:Button
                                ID="btn1000"
                                runat="server"
                                Text="R1,000"
                                CssClass="fw-quick-button"
                                CausesValidation="false"
                                OnClientClick="setQuickAmount(1000); return false;"
                                OnClick="btn1000_Click" />

                            <asp:Button
                                ID="btn2500"
                                runat="server"
                                Text="R2,500"
                                CssClass="fw-quick-button"
                                CausesValidation="false"
                                OnClientClick="setQuickAmount(2500); return false;"
                                OnClick="btn2500_Click" />

                            <asp:Button
                                ID="btn5000"
                                runat="server"
                                Text="R5,000"
                                CssClass="fw-quick-button"
                                CausesValidation="false"
                                OnClientClick="setQuickAmount(5000); return false;"
                                OnClick="btn5000_Click" />

                            <asp:Button
                                ID="btnOther"
                                runat="server"
                                Text="Other"
                                CssClass="fw-quick-button"
                                CausesValidation="false"
                                OnClientClick="setOtherAmount(); return false;"
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
                        Your payment details are secure and encrypted.
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

    <script type="text/javascript">

        var FW_MAX_DEPOSIT = 20000000;

        function getAmountInput() {
            return document.getElementById('<%= txtAmount.ClientID %>');
        }

        function getAmountError() {
            return document.getElementById('<%= lblAmountError.ClientID %>');
        }

        function fwSetError(msg) {
            var err = getAmountError();
            var input = getAmountInput();
            if (err) err.innerText = msg || '';
            if (input) {
                if (msg) input.classList.add('input-invalid');
                else input.classList.remove('input-invalid');
            }
        }

        // Quick buttons set a whole-rand integer (no decimals).
        function setQuickAmount(amount) {
            var input = getAmountInput();
            if (input) {
                input.value = String(Math.round(amount));
                fwSetError('');
                input.focus();
            }
        }

        function setOtherAmount() {
            var input = getAmountInput();
            if (input) {
                input.value = '';
                fwSetError('');
                input.focus();
            }
        }

        // ============================================================
        // Amount: whole-rand integers only (digits 0-9). No negative sign,
        // no comma, no decimal point, no "e". Does NOT auto-fill the max —
        // if the value exceeds the limit the error is shown instead.
        // ============================================================
        (function () {
            var input = getAmountInput();
            if (!input) return;

            // Block any non-digit key (allow control/navigation keys).
            input.addEventListener('keydown', function (e) {
                var key = e.keyCode || e.which;
                var allowed = [8, 9, 13, 46, 37, 38, 39, 40, 35, 36];
                if (allowed.indexOf(key) !== -1) return;
                if (e.ctrlKey || e.metaKey) return;
                var isTopDigit = key >= 48 && key <= 57;
                var isNumpadDigit = key >= 96 && key <= 105;
                if (!isTopDigit && !isNumpadDigit) e.preventDefault();
            });

            function sanitize() {
                var original = input.value;
                var digits = original.replace(/[^0-9]/g, '');
                if (digits.length > 1) digits = digits.replace(/^0+/, '');
                if (digits !== original) input.value = digits;

                if (digits !== '' && parseInt(digits, 10) > FW_MAX_DEPOSIT) {
                    fwSetError('Maximum amount per deposit is R20 000 000.');
                } else {
                    fwSetError('');
                }
            }

            input.addEventListener('input', sanitize);
            input.addEventListener('paste', function () { setTimeout(sanitize, 0); });
            input.addEventListener('blur', sanitize);
        })();

    </script>

</asp:Content>
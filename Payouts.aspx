<%@ Page Title="Payouts"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="Payouts.aspx.cs"
    Inherits="FreeHubProject.Payouts" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="PayoutsHead"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <link href="<%= ResolveUrl("~/Payouts.css?v=1") %>"
          rel="stylesheet"
          type="text/css" />

</asp:Content>

<asp:Content ID="PayoutsContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="payouts-page">

        <!-- LEFT SIDEBAR -->
        <uc:Sidebar runat="server" ID="SidebarControl" />

        <!-- MAIN CONTENT -->
        <main class="payouts-main">

            <!-- PAGE HEADER -->
            <div class="payouts-header">

                <div>

                    <h1>
                        Payouts
                    </h1>

                    <div class="payouts-breadcrumb">

                        <a href="Wallet.aspx" class="breadcrumb-link">
                            Wallet
                        </a>

                        <span>&#8250;</span>

                        <strong>
                            Payouts
                        </strong>

                    </div>

                    <p>
                        Manage payouts to freelancers and track escrow funds.
                    </p>

                </div>

                <div class="payouts-balance-card">

                    <div>

                        <small>
                            Current Wallet Balance
                        </small>

                        <asp:Label
                            ID="lblCurrentBalance"
                            runat="server"
                            CssClass="payouts-balance-value"
                            Text="R0.00">
                        </asp:Label>

                    </div>

                    <span class="payouts-wallet-icon">
                        &#128179;
                    </span>

                </div>

            </div>


            <!-- MESSAGE -->
            <asp:Panel
                ID="pnlMessage"
                runat="server"
                CssClass="payouts-message"
                Visible="false">

                <asp:Label
                    ID="lblMessage"
                    runat="server">
                </asp:Label>

            </asp:Panel>


            <!-- SUMMARY CARDS -->
            <section class="payouts-summary-grid">

                <div class="payouts-summary-item">

                    <span class="payouts-summary-icon payouts-total-icon">
                        &#8594;
                    </span>

                    <div>

                        <small>
                            Total Paid Out
                        </small>

                        <asp:Label
                            ID="lblTotalPaidOut"
                            runat="server"
                            CssClass="payouts-summary-value"
                            Text="R0.00">
                        </asp:Label>

                    </div>

                </div>

                <div class="payouts-summary-item">

                    <span class="payouts-summary-icon payouts-escrow-icon">
                        &#9203;
                    </span>

                    <div>

                        <small>
                            In Escrow
                        </small>

                        <asp:Label
                            ID="lblInEscrow"
                            runat="server"
                            CssClass="payouts-summary-value"
                            Text="R0.00">
                        </asp:Label>

                    </div>

                </div>

                <div class="payouts-summary-item">

                    <span class="payouts-summary-icon payouts-completed-icon">
                        &#10004;
                    </span>

                    <div>

                        <small>
                            Completed Payouts
                        </small>

                        <asp:Label
                            ID="lblCompletedCount"
                            runat="server"
                            CssClass="payouts-summary-value"
                            Text="0">
                        </asp:Label>

                    </div>

                </div>

            </section>


            <div class="payouts-layout">

                <!-- PAYOUT HISTORY TABLE -->
                <section class="payouts-table-card">

                    <div class="payouts-table-heading">

                        <h2>
                            Payout History
                        </h2>

                        <asp:Label
                            ID="lblPayoutCount"
                            runat="server"
                            CssClass="payouts-count-label"
                            Text="0 payouts">
                        </asp:Label>

                    </div>

                    <div class="payouts-table-wrapper">

                        <table class="payouts-table">

                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Description</th>
                                    <th>Type</th>
                                    <th>Amount</th>
                                    <th>Status</th>
                                    <th>Reference</th>
                                </tr>
                            </thead>

                            <tbody>

                                <asp:Repeater
                                    ID="rptPayouts"
                                    runat="server">

                                    <ItemTemplate>

                                        <tr>

                                            <td>
                                                <%# Convert.ToDateTime(Eval("TransactionDate")).ToString("dd MMM yyyy") %>
                                            </td>

                                            <td>
                                                <%# Server.HtmlEncode(Convert.ToString(Eval("Description"))) %>
                                            </td>

                                            <td>
                                                <span class='<%# GetTypeClass(Convert.ToString(Eval("Type"))) %>'>
                                                    <%# Server.HtmlEncode(Convert.ToString(Eval("Type"))) %>
                                                </span>
                                            </td>

                                            <td class='<%# GetAmountClass(Convert.ToString(Eval("Type"))) %>'>
                                                <%# FormatAmount(Convert.ToDecimal(Eval("Amount")), Convert.ToString(Eval("Type"))) %>
                                            </td>

                                            <td>
                                                <span class='<%# GetStatusClass(Convert.ToString(Eval("Status"))) %>'>
                                                    <%# Server.HtmlEncode(Convert.ToString(Eval("Status"))) %>
                                                </span>
                                            </td>

                                            <td>
                                                <%# Server.HtmlEncode(Convert.ToString(Eval("Reference"))) %>
                                            </td>

                                        </tr>

                                    </ItemTemplate>

                                </asp:Repeater>

                            </tbody>

                        </table>

                    </div>

                    <asp:Panel
                        ID="pnlNoPayouts"
                        runat="server"
                        CssClass="payouts-empty-state"
                        Visible="false">

                        <div class="payouts-empty-icon">
                            &#8594;
                        </div>

                        <strong>
                            No payouts yet
                        </strong>

                        <p>
                            Payouts to freelancers will appear here
                            when projects are completed.
                        </p>

                    </asp:Panel>

                </section>


                <!-- RIGHT COLUMN -->
                <aside class="payouts-right-column">

                    <!-- ESCROW PROJECTS -->
                    <section class="payouts-side-card">

                        <div class="payouts-side-heading">

                            <h3>
                                Funds in Escrow
                            </h3>

                            <span>&#9432;</span>

                        </div>

                        <asp:Repeater
                            ID="rptEscrowProjects"
                            runat="server"
                            OnItemCommand="rptEscrowProjects_ItemCommand">

                            <ItemTemplate>

                                <div class="payouts-escrow-item">

                                    <div>

                                        <strong>
                                            <%# Server.HtmlEncode(Convert.ToString(Eval("Title"))) %>
                                        </strong>

                                        <small>
                                            <%# Server.HtmlEncode(Convert.ToString(Eval("FreelancerName"))) %>
                                            &#8226; Posted <%# Convert.ToDateTime(Eval("DateCreated")).ToString("dd MMM yyyy") %>
                                        </small>

                                    </div>

                                    <div class="payouts-escrow-right">

                                        <strong>
                                            R<%# Convert.ToDecimal(Eval("Budget")).ToString("N2") %>
                                        </strong>

                                        <asp:LinkButton
                                            ID="btnRelease"
                                            runat="server"
                                            CssClass="payouts-release-button"
                                            Text="Release Funds"
                                            CommandName="ReleaseFunds"
                                            CommandArgument='<%# Eval("ProjectID") %>'
                                            CausesValidation="false"
                                            OnClientClick='<%# "return showReleaseModal(this, \"" + Server.HtmlEncode(Convert.ToString(Eval("Title"))) + "\", \"R" + Convert.ToDecimal(Eval("Budget")).ToString("N2") + "\", \"" + Eval("FreelancerName") + "\");" %>'>
                                        </asp:LinkButton>

                                    </div>

                                </div>

                            </ItemTemplate>

                        </asp:Repeater>

                        <asp:Panel
                            ID="pnlNoEscrow"
                            runat="server"
                            CssClass="payouts-empty-escrow"
                            Visible="false">

                            <strong>
                                No funds in escrow
                            </strong>

                            <p>
                                When you post a project, the budget is held
                                in escrow until completion.
                            </p>

                        </asp:Panel>

                    </section>


                    <!-- HOW PAYOUTS WORK -->
                    <section class="payouts-side-card">

                        <div class="payouts-side-heading">

                            <h3>
                                How Payouts Work
                            </h3>

                            <span>&#9432;</span>

                        </div>

                        <ul class="payouts-info-list">

                            <li>
                                Project budget is held in escrow
                                when you post a project.
                            </li>

                            <li>
                                Freelancer completes the work and
                                submits for review.
                            </li>

                            <li>
                                You approve the work and the
                                payout is released.
                            </li>

                            <li>
                                Freelancer receives 90% of the budget.
                                10% platform fee applies.
                            </li>

                            <li>
                                Payouts are processed immediately
                                upon approval.
                            </li>

                        </ul>

                    </section>

                </aside>

            </div>

        </main>

    </div>


    <!-- RELEASE FUNDS MODAL -->
    <div id="releaseModal" class="payouts-modal-overlay" style="display:none;">
        <div class="payouts-modal">
            <div class="payouts-modal-header">
                <h3>Release Funds</h3>
                <button type="button" class="payouts-modal-close" onclick="hideReleaseModal()">&#10005;</button>
            </div>
            <div class="payouts-modal-body">
                <div class="payouts-modal-icon">&#8594;</div>
                <p class="payouts-modal-text">
                    You are about to release funds for this project. This action cannot be undone.
                </p>
                <div class="payouts-modal-details">
                    <div class="payouts-modal-row">
                        <span>Project</span>
                        <strong id="modalProjectName"></strong>
                    </div>
                    <div class="payouts-modal-row">
                        <span>Freelancer</span>
                        <strong id="modalFreelancerName"></strong>
                    </div>
                    <div class="payouts-modal-row">
                        <span>Amount</span>
                        <strong id="modalAmount"></strong>
                    </div>
                    <div class="payouts-modal-row">
                        <span>Platform Fee (10%)</span>
                        <strong id="modalFee"></strong>
                    </div>
                    <div class="payouts-modal-row payouts-modal-total">
                        <span>Freelancer Receives</span>
                        <strong id="modalNetPayout"></strong>
                    </div>
                </div>
            </div>
            <div class="payouts-modal-footer">
                <button type="button" class="payouts-modal-cancel" onclick="hideReleaseModal()">Cancel</button>
                <button type="button" class="payouts-modal-confirm" id="btnConfirmRelease">Release Funds</button>
            </div>
        </div>
    </div>


    <script type="text/javascript">

        var pendingButton = null;

        function showReleaseModal(btn, projectName, amount, freelancerName) {
            pendingButton = btn;

            document.getElementById('modalProjectName').innerText = projectName;
            document.getElementById('modalFreelancerName').innerText = freelancerName || 'Assigned Freelancer';
            document.getElementById('modalAmount').innerText = amount;

            // Calculate fee and net
            var numAmount = parseFloat(amount.replace('R', '').replace(/\s/g, '').replace(',', '.'));
            var fee = (numAmount * 0.10).toFixed(2);
            var net = (numAmount - parseFloat(fee)).toFixed(2);

            document.getElementById('modalFee').innerText = 'R' + formatNumber(fee);
            document.getElementById('modalNetPayout').innerText = 'R' + formatNumber(net);

            document.getElementById('releaseModal').style.display = 'flex';
            return false;
        }

        function hideReleaseModal() {
            document.getElementById('releaseModal').style.display = 'none';
            pendingButton = null;
        }

        function formatNumber(num) {
            var parts = parseFloat(num).toFixed(2).split('.');
            parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
            return parts.join(',');
        }

        document.addEventListener('DOMContentLoaded', function () {
            var confirmBtn = document.getElementById('btnConfirmRelease');
            if (confirmBtn) {
                confirmBtn.addEventListener('click', function () {
                    if (pendingButton) {
                        document.getElementById('releaseModal').style.display = 'none';
                        __doPostBack(pendingButton.name, '');
                    }
                });
            }
        });

    </script>

</asp:Content>

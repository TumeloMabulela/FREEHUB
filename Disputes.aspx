<%@ Page Title="Disputes"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="Disputes.aspx.cs"
    Inherits="FreeHubProject.Disputes" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="DisputesHead"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <link href="<%= ResolveUrl("~/Disputes.css?v=1") %>"
          rel="stylesheet"
          type="text/css" />

</asp:Content>

<asp:Content ID="DisputesContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="disputes-page">

        <!-- LEFT SIDEBAR -->
        <uc:Sidebar runat="server" ID="SidebarControl" />

        <!-- MAIN CONTENT -->
        <main class="disputes-main">

            <!-- PAGE HEADER -->
            <div class="disputes-header">

                <div>

                    <h1>
                        Disputes
                    </h1>

                    <div class="disputes-breadcrumb">

                        <a href="Wallet.aspx" class="breadcrumb-link">
                            Wallet
                        </a>

                        <span>&#8250;</span>

                        <strong>
                            Disputes
                        </strong>

                    </div>

                    <p>
                        Manage and track wallet-related disputes.
                    </p>

                </div>

                <div class="disputes-balance-card">

                    <div>

                        <small>
                            Current Wallet Balance
                        </small>

                        <asp:Label
                            ID="lblCurrentBalance"
                            runat="server"
                            CssClass="disputes-balance-value"
                            Text="R0.00">
                        </asp:Label>

                    </div>

                    <span class="disputes-wallet-icon">
                        &#128179;
                    </span>

                </div>

            </div>


            <!-- MESSAGE -->
            <asp:Panel
                ID="pnlMessage"
                runat="server"
                CssClass="disputes-message"
                Visible="false">

                <asp:Label
                    ID="lblMessage"
                    runat="server">
                </asp:Label>

            </asp:Panel>


            <!-- SUMMARY CARDS -->
            <section class="disputes-summary-grid">

                <div class="disputes-summary-item">

                    <span class="disputes-summary-icon disputes-open-icon">
                        &#9888;
                    </span>

                    <div>

                        <small>
                            Open Disputes
                        </small>

                        <asp:Label
                            ID="lblOpenCount"
                            runat="server"
                            CssClass="disputes-summary-value"
                            Text="0">
                        </asp:Label>

                    </div>

                </div>

                <div class="disputes-summary-item">

                    <span class="disputes-summary-icon disputes-review-icon">
                        &#9203;
                    </span>

                    <div>

                        <small>
                            In Review
                        </small>

                        <asp:Label
                            ID="lblInReviewCount"
                            runat="server"
                            CssClass="disputes-summary-value"
                            Text="0">
                        </asp:Label>

                    </div>

                </div>

                <div class="disputes-summary-item">

                    <span class="disputes-summary-icon disputes-resolved-icon">
                        &#10004;
                    </span>

                    <div>

                        <small>
                            Resolved
                        </small>

                        <asp:Label
                            ID="lblResolvedCount"
                            runat="server"
                            CssClass="disputes-summary-value"
                            Text="0">
                        </asp:Label>

                    </div>

                </div>

            </section>


            <div class="disputes-layout">

                <!-- DISPUTE FORM -->
                <section class="disputes-form-card">

                    <h2>
                        Create a Dispute
                    </h2>

                    <p class="disputes-form-description">
                        Submit a dispute for a transaction or project issue.
                        Disputes are reviewed by an administrator.
                    </p>


                    <!-- DISPUTE TYPE -->
                    <div class="disputes-field">

                        <label>
                            Dispute Type
                        </label>

                        <asp:DropDownList
                            ID="ddlDisputeType"
                            runat="server"
                            CssClass="disputes-dropdown">

                            <asp:ListItem
                                Text="Select dispute type"
                                Value="">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Transaction Dispute"
                                Value="Transaction">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Project Dispute"
                                Value="Project">
                            </asp:ListItem>

                        </asp:DropDownList>

                    </div>


                    <!-- TRANSACTION / PROJECT REFERENCE -->
                    <div class="disputes-field">

                        <label>
                            Reference ID
                        </label>

                        <asp:TextBox
                            ID="txtReferenceId"
                            runat="server"
                            CssClass="disputes-input"
                            placeholder="e.g. Transaction ID or Project ID">
                        </asp:TextBox>

                        <small>
                            Enter the transaction or project ID related to this dispute.
                        </small>

                    </div>


                    <!-- REASON -->
                    <div class="disputes-field">

                        <label>
                            Reason for Dispute
                        </label>

                        <asp:DropDownList
                            ID="ddlReason"
                            runat="server"
                            CssClass="disputes-dropdown">

                            <asp:ListItem
                                Text="Select a reason"
                                Value="">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Unauthorized transaction"
                                Value="Unauthorized transaction">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Service not received"
                                Value="Service not received">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Incorrect charge"
                                Value="Incorrect charge">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Quality of work unsatisfactory"
                                Value="Quality of work unsatisfactory">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Freelancer unresponsive"
                                Value="Freelancer unresponsive">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Payment not received"
                                Value="Payment not received">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Other"
                                Value="Other">
                            </asp:ListItem>

                        </asp:DropDownList>

                    </div>


                    <!-- DESCRIPTION -->
                    <div class="disputes-field">

                        <label>
                            Description
                        </label>

                        <asp:TextBox
                            ID="txtDescription"
                            runat="server"
                            CssClass="disputes-textarea"
                            TextMode="MultiLine"
                            Rows="5"
                            placeholder="Describe the issue in detail. Include dates, amounts, and any relevant information...">
                        </asp:TextBox>

                    </div>


                    <asp:Button
                        ID="btnSubmitDispute"
                        runat="server"
                        Text="Submit Dispute"
                        CssClass="disputes-submit-button"
                        CausesValidation="false"
                        OnClick="btnSubmitDispute_Click" />

                </section>


                <!-- RIGHT COLUMN -->
                <aside class="disputes-right-column">

                    <!-- DISPUTE GUIDELINES -->
                    <section class="disputes-side-card">

                        <div class="disputes-side-heading">

                            <h3>
                                Dispute Guidelines
                            </h3>

                            <span>
                                &#9432;
                            </span>

                        </div>

                        <ul class="disputes-info-list">

                            <li>
                                Disputes are reviewed within
                                3-5 business days.
                            </li>

                            <li>
                                Provide accurate reference IDs
                                to expedite the review process.
                            </li>

                            <li>
                                Include all relevant details
                                in your description.
                            </li>

                            <li>
                                An administrator may contact you
                                for additional information.
                            </li>

                            <li>
                                Resolved disputes cannot be
                                reopened.
                            </li>

                        </ul>

                    </section>


                    <!-- RECENT DISPUTES -->
                    <section class="disputes-side-card">

                        <div class="disputes-side-heading">

                            <h3>
                                Recent Disputes
                            </h3>

                            <asp:Button
                                ID="btnViewAll"
                                runat="server"
                                Text="View All"
                                CssClass="disputes-view-all"
                                CausesValidation="false"
                                OnClick="btnViewAll_Click" />

                        </div>

                        <asp:Repeater
                            ID="rptDisputes"
                            runat="server">

                            <ItemTemplate>

                                <div class="disputes-history-item">

                                    <div>

                                        <strong>
                                            <%# Convert.ToDateTime(
                                                    Eval("DateCreated")
                                                ).ToString("dd MMM yyyy") %>
                                        </strong>

                                        <small>
                                            <%# Server.HtmlEncode(
                                                Convert.ToString(
                                                    Eval("Reason")
                                                )
                                            ) %>
                                        </small>

                                    </div>

                                    <div class="disputes-history-right">

                                        <span class='<%# GetDisputeStatusClass(
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
                            ID="pnlNoDisputes"
                            runat="server"
                            CssClass="disputes-empty-history"
                            Visible="false">

                            <div class="disputes-empty-icon">
                                &#9888;
                            </div>

                            <strong>
                                No disputes filed
                            </strong>

                            <p>
                                Your dispute history will appear here.
                            </p>

                        </asp:Panel>

                    </section>

                </aside>

            </div>

        </main>

    </div>

</asp:Content>

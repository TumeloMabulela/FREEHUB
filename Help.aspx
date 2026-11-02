<%@ Page Title="Help & Support - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="Help.aspx.cs"
    Inherits="FreeHubProject.Help" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style type="text/css">
        .help-topics { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 14px; margin-bottom: 26px; }
        .help-topic-card {
            background: #fff; border: 1px solid #e8ece9; border-radius: 12px; padding: 18px;
        }
        .help-topic-card h3 { color: #173f2c; font-size: 15px; margin: 0 0 6px; }
        .help-topic-card p { color: #5a6e62; font-size: 13px; line-height: 1.6; margin: 0; }
        .help-topic-card a { color: #2e7d56; font-weight: 600; text-decoration: none; }
        .help-form-card {
            background: #fff; border: 1px solid #e8ece9; border-radius: 12px; padding: 22px; max-width: 640px;
        }
        .help-form-card h2 { color: #173f2c; font-size: 17px; margin: 0 0 4px; }
        .help-form-card .help-sub { color: #6b7280; font-size: 13px; margin: 0 0 16px; }
        .help-field { margin-bottom: 14px; }
        .help-field label { display: block; color: #394047; font-size: 13px; font-weight: 600; margin-bottom: 5px; }
    </style>

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <div class="post-page-heading">
                <div class="post-breadcrumb">
                    <a href="<%= ResolveUrl("~/Dashboard.aspx") %>" class="breadcrumb-link">Dashboard</a> <span>/</span>
                    <strong>Help &amp; Support</strong>
                </div>
                <h1>Help &amp; Support</h1>
                <p>Find guidance on common topics, or send our support team a request below.</p>
            </div>

            <div style="max-width: 820px;">

                <!-- SUPPORT TOPICS -->
                <div class="help-topics">
                    <div class="help-topic-card">
                        <h3>Getting Started</h3>
                        <p>Set up your profile and learn how FreeHUB works.</p>
                    </div>
                    <div class="help-topic-card">
                        <h3>Projects &amp; Proposals</h3>
                        <p>Posting projects, submitting proposals and tracking progress.</p>
                    </div>
                    <div class="help-topic-card">
                        <h3>Payments &amp; Wallet</h3>
                        <p>Funding your wallet, viewing transactions and withdrawing earnings.</p>
                    </div>
                </div>

                <!-- SUPPORT REQUEST FORM -->
                <div class="help-form-card">

                    <h2>Submit a Support Request</h2>
                    <p class="help-sub">Describe your issue and our support team will review it.</p>

                    <!-- Confirmation (shown after a successful submission) -->
                    <asp:Panel ID="pnlConfirm" runat="server" Visible="false" CssClass="post-status post-success">
                        <asp:Label ID="lblConfirm" runat="server" />
                    </asp:Panel>

                    <!-- Error / validation message -->
                    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="post-status post-error">
                        <asp:Label ID="lblError" runat="server" />
                    </asp:Panel>

                    <asp:Panel ID="pnlForm" runat="server">

                        <div class="help-field">
                            <label>Topic <span style="color:#dc3545;">*</span></label>
                            <asp:DropDownList ID="ddlTopic" runat="server" CssClass="post-input">
                                <asp:ListItem Value="">Select a topic</asp:ListItem>
                                <asp:ListItem>Account</asp:ListItem>
                                <asp:ListItem>Projects &amp; Proposals</asp:ListItem>
                                <asp:ListItem>Payments &amp; Wallet</asp:ListItem>
                                <asp:ListItem>Withdrawals</asp:ListItem>
                                <asp:ListItem>Other</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="help-field">
                            <label>Subject <span style="color:#dc3545;">*</span></label>
                            <asp:TextBox ID="txtSubject" runat="server" CssClass="post-input" MaxLength="150"
                                placeholder="Brief summary of your issue" />
                        </div>

                        <div class="help-field">
                            <label>Message <span style="color:#dc3545;">*</span></label>
                            <asp:TextBox ID="txtMessage" runat="server" CssClass="post-textarea"
                                TextMode="MultiLine" Rows="6" data-fh-format="true"
                                placeholder="Describe your issue in detail..." />
                        </div>

                        <asp:Button ID="btnSubmit" runat="server" Text="Submit Request"
                            CssClass="post-submit-button" OnClick="btnSubmit_Click" />

                    </asp:Panel>

                </div>

            </div>

        </section>

    </div>

    <%-- Shared paragraph-formatting helper (same as Project Description). --%>
    <script src="<%= ResolveUrl("~/fhText.js") %>?v=1" type="text/javascript"></script>

</asp:Content>

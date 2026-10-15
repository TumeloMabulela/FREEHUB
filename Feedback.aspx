<%@ Page Title="Feedback & Suggestions - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="Feedback.aspx.cs"
    Inherits="FreeHubProject.Feedback" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style type="text/css">
        .fb-card {
            background: #fff; border: 1px solid #e8ece9; border-radius: 12px; padding: 22px; max-width: 640px;
        }
        .fb-card h2 { color: #173f2c; font-size: 17px; margin: 0 0 4px; }
        .fb-card .fb-sub { color: #6b7280; font-size: 13px; margin: 0 0 16px; }
        .fb-field { margin-bottom: 14px; }
        .fb-field label { display: block; color: #394047; font-size: 13px; font-weight: 600; margin-bottom: 5px; }
    </style>

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <div class="post-page-heading">
                <div class="post-breadcrumb">
                    <a href="<%= ResolveUrl("~/Dashboard.aspx") %>" class="breadcrumb-link">Dashboard</a> <span>/</span>
                    <strong>Feedback &amp; Suggestions</strong>
                </div>
                <h1>Feedback &amp; Suggestions</h1>
                <p>Tell us what's working well and how we can make FreeHUB better.</p>
            </div>

            <div style="max-width: 820px;">

                <div class="fb-card">

                    <h2>Share Your Feedback</h2>
                    <p class="fb-sub">Your input helps us improve the platform.</p>

                    <asp:Panel ID="pnlConfirm" runat="server" Visible="false" CssClass="post-status post-success">
                        <asp:Label ID="lblConfirm" runat="server" />
                    </asp:Panel>

                    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="post-status post-error">
                        <asp:Label ID="lblError" runat="server" />
                    </asp:Panel>

                    <asp:Panel ID="pnlForm" runat="server">

                        <div class="fb-field">
                            <label>Category <span style="color:#dc3545;">*</span></label>
                            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="post-input">
                                <asp:ListItem Value="">Select a category</asp:ListItem>
                                <asp:ListItem>General Feedback</asp:ListItem>
                                <asp:ListItem>Feature Suggestion</asp:ListItem>
                                <asp:ListItem>Usability</asp:ListItem>
                                <asp:ListItem>Bug Report</asp:ListItem>
                                <asp:ListItem>Other</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="fb-field">
                            <label>Your Message <span style="color:#dc3545;">*</span></label>
                            <asp:TextBox ID="txtMessage" runat="server" CssClass="post-textarea"
                                TextMode="MultiLine" Rows="6" data-fh-format="true"
                                placeholder="Share your feedback or suggestion..." />
                        </div>

                        <asp:Button ID="btnSubmit" runat="server" Text="Submit Feedback"
                            CssClass="post-submit-button" OnClick="btnSubmit_Click" />

                    </asp:Panel>

                </div>

            </div>

        </section>

    </div>

    <%-- Shared paragraph-formatting helper (same as Project Description). --%>
    <script src="<%= ResolveUrl("~/fhText.js") %>?v=1" type="text/javascript"></script>

</asp:Content>

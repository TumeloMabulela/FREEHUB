<%@ Page Title="Submit Proposal - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="SubmitProposal.aspx.cs"
    Inherits="FreeHubProject.SubmitProposal" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <!-- BREADCRUMB -->
            <div class="post-page-heading">
                <div class="post-breadcrumb">
                    Dashboard <span>/</span> Browse Projects <span>/</span> Submit Proposal
                </div>
                <h1>Submit Proposal</h1>
                <p>Send your proposal to the employer for this project.</p>
            </div>

            <!-- MESSAGE -->
            <asp:Panel ID="pnlMessage" runat="server" CssClass="post-status" Visible="false">
                <asp:Label ID="lblMessage" runat="server" />
            </asp:Panel>

            <div class="post-content-grid">

                <!-- PROPOSAL FORM -->
                <div class="post-form-card">

                    <!-- PROJECT SUMMARY -->
                    <div class="proposal-project-summary">
                        <h3>
                            <asp:Label ID="lblProjectTitle" runat="server" Text="Project Title" />
                        </h3>
                        <div class="proposal-project-meta">
                            <span>Budget: <strong><asp:Label ID="lblProjectBudget" runat="server" /></strong></span>
                            <span>Deadline: <strong><asp:Label ID="lblProjectDeadline" runat="server" /></strong></span>
                            <span>Category: <strong><asp:Label ID="lblProjectCategory" runat="server" /></strong></span>
                        </div>
                    </div>

                    <div class="post-card-title">
                        <h2>Your Proposal</h2>
                        <p>Tell the employer why you're the best fit for this project.</p>
                    </div>

                    <!-- COVER LETTER -->
                    <div class="post-field">
                        <label>Cover Letter <span>*</span></label>
                        <asp:TextBox ID="txtCoverLetter" runat="server"
                            CssClass="post-textarea" TextMode="MultiLine" Rows="8"
                            placeholder="Introduce yourself, explain your relevant experience, and describe how you would approach this project..." />
                    </div>

                    <!-- PROPOSED RATE -->
                    <div class="post-two-columns">
                        <div class="post-field">
                            <label>Proposed Rate (ZAR) <span>*</span></label>
                            <div class="budget-input-box">
                                <span>R</span>
                                <asp:TextBox ID="txtProposedRate" runat="server"
                                    CssClass="budget-input" TextMode="Number"
                                    placeholder="12000" />
                            </div>
                        </div>

                        <div class="post-field">
                            <label>Estimated Completion Time <span>*</span></label>
                            <asp:TextBox ID="txtCompletionTime" runat="server"
                                CssClass="post-input"
                                placeholder="e.g. 15 days, 2 weeks, 1 month" />
                        </div>
                    </div>

                    <!-- BUTTONS -->
                    <div class="post-buttons">
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel"
                            CssClass="post-cancel-button" CausesValidation="false"
                            OnClick="btnCancel_Click" />

                        <asp:Button ID="btnSubmitProposal" runat="server"
                            Text="Submit Proposal"
                            CssClass="post-submit-button"
                            OnClick="btnSubmitProposal_Click" />
                    </div>

                </div>

                <!-- RIGHT TIPS -->
                <div class="post-help-column">
                    <div class="post-help-card">
                        <h3>Tips for a Strong Proposal</h3>

                        <div class="help-tip">
                            <div class="help-icon">&#9998;</div>
                            <div>
                                <strong>Personalize your cover letter</strong>
                                <p>Reference the specific project and explain why you're interested.</p>
                            </div>
                        </div>

                        <div class="help-tip">
                            <div class="help-icon">R</div>
                            <div>
                                <strong>Set a competitive rate</strong>
                                <p>Research market rates and price your skills fairly.</p>
                            </div>
                        </div>

                        <div class="help-tip">
                            <div class="help-icon">&#9201;</div>
                            <div>
                                <strong>Be realistic with timelines</strong>
                                <p>Give yourself enough time to deliver quality work.</p>
                            </div>
                        </div>

                        <div class="help-tip">
                            <div class="help-icon">&#9733;</div>
                            <div>
                                <strong>Highlight relevant experience</strong>
                                <p>Mention similar projects you have completed successfully.</p>
                            </div>
                        </div>
                    </div>
                </div>

            </div>

        </section>

    </div>

</asp:Content>

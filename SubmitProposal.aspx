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
                            <label>Estimated Completion Time (days) <span>*</span></label>
                            <asp:TextBox ID="txtCompletionTime" runat="server"
                                CssClass="post-input"
                                TextMode="Number" min="1" step="1"
                                placeholder="Enter number of days, e.g. 15"
                                onkeydown="return blockNonNumericKeys(event);"
                                oninput="updateDurationPreview();" />
                            <small id="durationPreview" style="display:block; margin-top:6px; color:#2e7d56; font-size:12px;"></small>
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

    <script type="text/javascript">

        // Allow only digits (and control keys) in the completion-time field.
        function blockNonNumericKeys(e) {
            var key = e.keyCode || e.which;
            // Allow: backspace, tab, enter, delete, arrows, home, end
            var control = [8, 9, 13, 46, 37, 38, 39, 40, 35, 36];
            if (control.indexOf(key) !== -1) return true;
            // Allow Ctrl/Cmd combos (copy/paste/select-all)
            if (e.ctrlKey || e.metaKey) return true;
            // Allow digits 0-9 (top row and numpad)
            if ((key >= 48 && key <= 57) || (key >= 96 && key <= 105)) return true;
            e.preventDefault();
            return false;
        }

        // Convert a number of days into a friendly weeks/months description.
        function describeDuration(days) {
            days = parseInt(days, 10);
            if (isNaN(days) || days <= 0) return "";
            if (days < 7) {
                return days + (days === 1 ? " day" : " days");
            }
            if (days < 30) {
                var weeks = days / 7;
                var w = (Math.round(weeks * 10) / 10);
                return days + " days (about " + w + (w === 1 ? " week)" : " weeks)");
            }
            if (days < 365) {
                var months = days / 30;
                var m = (Math.round(months * 10) / 10);
                return days + " days (about " + m + (m === 1 ? " month)" : " months)");
            }
            var years = days / 365;
            var y = (Math.round(years * 10) / 10);
            return days + " days (about " + y + (y === 1 ? " year)" : " years)");
        }

        function updateDurationPreview() {
            var input = document.getElementById('<%= txtCompletionTime.ClientID %>');
            var preview = document.getElementById('durationPreview');
            if (!input || !preview) return;
            var text = describeDuration(input.value);
            preview.innerText = text ? ("Estimated: " + text) : "";
        }

        if (window.addEventListener) {
            window.addEventListener('load', updateDurationPreview);
        } else {
            window.attachEvent('onload', updateDurationPreview);
        }

    </script>

</asp:Content>

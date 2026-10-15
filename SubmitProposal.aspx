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

    <style type="text/css">
        /* ===== Submit Proposal fixed-middle layout (matches My Proposals / SelectProposal).
           The main content is a NON-scrolling flex column filling the space between the
           fixed site header and footer. Breadcrumb/heading/description + status message stay
           fixed; only the proposal form card scrolls. The Tips card sits in the non-scrolling
           area, top-aligned to the form. Scoped via .sp2-* so nothing else is affected. ===== */

        .freehub-main-content.sp2-main {
            height: 100%;
            min-height: 0;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        .sp2-main .post-page-heading,
        .sp2-main .post-status { flex: 0 0 auto; }

        /* Two-column region fills the remaining height. */
        .sp2-layout {
            display: grid; grid-template-columns: minmax(0, 1fr) 300px; gap: 24px;
            align-items: stretch; flex: 1 1 auto; min-height: 0;
        }

        /* LEFT: the proposal form card is the ONLY scrollable section. */
        .sp2-form-card {
            background: #fff; border: 1px solid #e8ece9; border-radius: 14px;
            padding: 24px 26px; box-shadow: 0 1px 3px rgba(16,40,28,0.06);
            display: flex; flex-direction: column; min-height: 0;
            overflow-y: auto; overflow-x: hidden;
            scrollbar-width: thin; scrollbar-color: #2e7d56 #eef3ef;
        }
        .sp2-form-card::-webkit-scrollbar { width: 8px; }
        .sp2-form-card::-webkit-scrollbar-track { background: #eef3ef; border-radius: 8px; }
        .sp2-form-card::-webkit-scrollbar-thumb { background: linear-gradient(180deg, #2e7d56, #72c94b); border-radius: 8px; border: 2px solid #eef3ef; }
        .sp2-form-card::-webkit-scrollbar-thumb:hover { background: #2e7d56; }

        /* Project summary (light-green, rounded) — unchanged content, tidy alignment. */
        .sp2-summary { background: #eaf6ee; border: 1px solid #d7ecde; border-radius: 12px; padding: 16px 18px; margin-bottom: 20px; }
        .sp2-summary h3 { margin: 0 0 8px; color: #173f2c; font-size: 16px; font-weight: 700; }
        .sp2-summary-meta { display: flex; flex-wrap: wrap; gap: 8px 24px; color: #4b5f52; font-size: 13px; }
        .sp2-summary-meta strong { color: #173f2c; }

        .sp2-card-title { margin-bottom: 16px; }
        .sp2-card-title h2 { margin: 0 0 4px; color: #173f2c; font-size: 18px; font-weight: 700; }
        .sp2-card-title p { margin: 0; color: #7b878d; font-size: 13px; }

        .sp2-field { margin-bottom: 18px; }
        /* Label row: validation message sits IMMEDIATELY to the right of the label (not
           pushed to the far edge), vertically centred, wrapping neatly if long. */
        .sp2-label-row { display: flex; align-items: center; justify-content: flex-start; column-gap: 10px; row-gap: 4px; flex-wrap: wrap; margin-bottom: 8px; }
        .sp2-label-row label { margin: 0; flex-shrink: 0; font-size: 13px; font-weight: 700; color: #374638; }
        .sp2-label-row label span { color: #dc2626; }
        .sp2-msg { position: static; display: inline-block; margin: 0; font-size: 12px; font-weight: 600; line-height: 1.4; text-align: left; }
        .sp2-msg.err { color: #dc2626; }
        .sp2-msg.ok  { color: #15803d; }

        .sp2-input, .sp2-textarea {
            width: 100%; padding: 12px 14px; border: 1px solid #d1d9d3; border-radius: 8px;
            font-size: 14px; font-family: Arial, Helvetica, sans-serif; box-sizing: border-box;
            transition: border-color 0.2s;
        }
        .sp2-input { min-height: 46px; }
        .sp2-input:focus, .sp2-textarea:focus { outline: none; border-color: #b7d68c; }
        .sp2-textarea { min-height: 190px; resize: vertical; line-height: 1.6; }
        .sp2-input.input-invalid, .sp2-textarea.input-invalid { border-color: #dc2626; }

        /* Char counter at the bottom-right of the textarea. */
        .sp2-counter { display: block; margin-top: 6px; text-align: right; color: #6b7280; font-size: 12px; }

        /* Two equal columns for Rate + Date. */
        .sp2-two { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }

        /* Rate with attached non-editable R prefix (text input, no spinners). */
        .sp2-rate-wrap { display: flex; align-items: stretch; }
        .sp2-rate-prefix { display: inline-flex; align-items: center; padding: 0 14px; background: #eef3ef; border: 1px solid #d1d9d3; border-right: none; border-radius: 8px 0 0 8px; color: #3d5a47; font-weight: 700; }
        .sp2-rate-input { border-top-left-radius: 0 !important; border-bottom-left-radius: 0 !important; }

        /* Date field: native date input (calendar icon vertically centred by the browser). */
        .sp2-date-input { min-height: 46px; }
        .sp2-duration { display: block; margin-top: 6px; color: #2e7d56; font-size: 12px; font-weight: 600; }

        /* Buttons: Cancel left, Submit right. */
        .sp2-buttons { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-top: 22px; }
        .sp2-cancel { height: 40px; padding: 0 20px; background: #fff; border: 1.5px solid #2e7d56; border-radius: 8px; color: #173f2c; font-size: 14px; font-weight: 700; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; }
        .sp2-cancel:hover { background: #eaf6ee; }
        .sp2-submit { height: 40px; padding: 0 22px; background: #0f7a44; color: #fff; border: none; border-radius: 8px; font-size: 14px; font-weight: 700; cursor: pointer; transition: background 0.2s; }
        .sp2-submit:hover { background: #0c6639; }
        .sp2-submit:disabled { opacity: .7; cursor: default; }

        /* RIGHT: Tips card, stationary, top-aligned to the form. */
        .sp2-tips { align-self: start; }

        /* ===== Responsive: release to natural flow below 900px ===== */
        @media (max-width: 900px) {
            .freehub-main-content.sp2-main { height: auto; overflow: visible; display: block; }
            .sp2-layout { grid-template-columns: 1fr; display: grid; flex: none; }
            .sp2-form-card { overflow: visible; max-height: none; }
            .sp2-tips { align-self: auto; }
        }
        @media (max-width: 640px) {
            .sp2-two { grid-template-columns: 1fr; gap: 0; }
        }
    </style>

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content sp2-main">

            <!-- BREADCRUMB & HEADING (static) -->
            <div class="post-page-heading">
                <div class="post-breadcrumb">
                    <a href="<%= ResolveUrl("~/Dashboard.aspx") %>" class="breadcrumb-link">Dashboard</a> <span>/</span>
                    <a href="<%= ResolveUrl("~/BrowseProjects.aspx") %>" class="breadcrumb-link">Browse Projects</a> <span>/</span>
                    <strong>Submit Proposal</strong>
                </div>
                <h1>Submit Proposal</h1>
                <p>Send your proposal to the employer for this project.</p>
            </div>

            <!-- MESSAGE (static) -->
            <asp:Panel ID="pnlMessage" runat="server" CssClass="post-status" Visible="false">
                <asp:Label ID="lblMessage" runat="server" />
            </asp:Panel>

            <!-- TWO-COLUMN LAYOUT (fills remaining height) -->
            <div class="sp2-layout">

                <!-- LEFT: scrollable proposal form -->
                <div class="sp2-form-card">

                    <!-- PROJECT SUMMARY -->
                    <div class="sp2-summary">
                        <h3><asp:Label ID="lblProjectTitle" runat="server" Text="Project Title" /></h3>
                        <div class="sp2-summary-meta">
                            <span>Budget: <strong><asp:Label ID="lblProjectBudget" runat="server" /></strong></span>
                            <span>Deadline: <strong><asp:Label ID="lblProjectDeadline" runat="server" /></strong></span>
                            <span>Category: <strong><asp:Label ID="lblProjectCategory" runat="server" /></strong></span>
                        </div>
                    </div>

                    <div class="sp2-card-title">
                        <h2>Your Proposal</h2>
                        <p>Tell the employer why you're the best fit for this project.</p>
                    </div>

                    <!-- COVER LETTER (full width) -->
                    <div class="sp2-field">
                        <div class="sp2-label-row">
                            <label>Cover Letter <span>*</span></label>
                            <asp:Label ID="lblCoverError" runat="server" CssClass="sp2-msg err" />
                        </div>
                        <%-- Reuses the Project Description paragraph formatting: data-fh-format
                             normalises single-Enter paragraphs + one blank line between them
                             (via fhText.js), the same working approach used on Post a Project. --%>
                        <asp:TextBox ID="txtCoverLetter" runat="server"
                            CssClass="sp2-textarea" TextMode="MultiLine" Rows="8"
                            data-fh-format="true"
                            placeholder="Introduce yourself, explain your relevant experience, and describe how you would approach this project..." />
                        <span class="sp2-counter"><span id="clCount">0</span> / 800 characters</span>
                    </div>

                    <!-- RATE + DATE (two equal columns) -->
                    <div class="sp2-two">
                        <div class="sp2-field">
                            <div class="sp2-label-row">
                                <label>Proposed Rate (ZAR) <span>*</span></label>
                                <asp:Label ID="lblRateError" runat="server" CssClass="sp2-msg err" />
                            </div>
                            <div class="sp2-rate-wrap">
                                <span class="sp2-rate-prefix">R</span>
                                <asp:TextBox ID="txtProposedRate" runat="server"
                                    CssClass="sp2-input sp2-rate-input" MaxLength="6"
                                    inputmode="numeric" pattern="[0-9]*" autocomplete="off"
                                    placeholder="e.g. 12000" />
                            </div>
                        </div>

                        <div class="sp2-field">
                            <div class="sp2-label-row">
                                <label>Estimated Completion Date <span>*</span></label>
                                <asp:Label ID="lblDateError" runat="server" CssClass="sp2-msg err" />
                            </div>
                            <asp:TextBox ID="txtCompletionDate" runat="server"
                                CssClass="sp2-input sp2-date-input" TextMode="Date" />
                            <small id="durationPreview" class="sp2-duration"></small>
                            <%-- Hidden field holds the computed number of days (for the
                                 existing days-based database storage). --%>
                            <asp:HiddenField ID="hfCompletionDays" runat="server" />
                        </div>
                    </div>

                    <!-- BUTTONS: Cancel left, Submit right -->
                    <div class="sp2-buttons">
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel"
                            CssClass="sp2-cancel" CausesValidation="false"
                            OnClick="btnCancel_Click" />

                        <asp:Button ID="btnSubmitProposal" runat="server"
                            Text="Submit Proposal"
                            CssClass="sp2-submit"
                            OnClick="btnSubmitProposal_Click" />
                    </div>

                </div>

                <!-- RIGHT: Tips card (static, top-aligned) -->
                <div class="sp2-tips">
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

    <%-- Shared paragraph-formatting helper (same as Project Description). --%>
    <script src="<%= ResolveUrl("~/fhText.js") %>?v=1" type="text/javascript"></script>

    <script type="text/javascript">
        (function () {
            var cl = document.getElementById('<%= txtCoverLetter.ClientID %>');
            var clCount = document.getElementById('clCount');
            var clMsg = document.getElementById('<%= lblCoverError.ClientID %>');

            var rate = document.getElementById('<%= txtProposedRate.ClientID %>');
            var rateMsg = document.getElementById('<%= lblRateError.ClientID %>');

            var dateInp = document.getElementById('<%= txtCompletionDate.ClientID %>');
            var dateMsg = document.getElementById('<%= lblDateError.ClientID %>');
            var durPrev = document.getElementById('durationPreview');
            var hfDays = document.getElementById('<%= hfCompletionDays.ClientID %>');

            var submitBtn = document.getElementById('<%= btnSubmitProposal.ClientID %>');

            var CL_MIN = 200, CL_MAX = 800;
            var RATE_MIN = 1, RATE_MAX = 200000;

            function setMsg(el, text, ok) {
                if (!el) return;
                el.innerText = text || '';
                el.className = 'sp2-msg ' + (text ? (ok ? 'ok' : 'err') : 'err');
            }
            function mark(el, invalid) {
                if (!el) return;
                if (invalid) el.classList.add('input-invalid'); else el.classList.remove('input-invalid');
            }

            // Local YYYY-MM-DD for today (no UTC conversion), used as the date min.
            function todayLocalISO() {
                var d = new Date();
                var m = String(d.getMonth() + 1).padStart(2, '0');
                var day = String(d.getDate()).padStart(2, '0');
                return d.getFullYear() + '-' + m + '-' + day;
            }
            function startOfLocalDay(d) { return new Date(d.getFullYear(), d.getMonth(), d.getDate()); }

            // ----- Cover Letter: live counter + 200/800 enforcement + beside-label msg -----
            function validateCover(showEmpty) {
                if (!cl) return false;
                var val = (cl.value || '');
                if (val.length > CL_MAX) { val = val.slice(0, CL_MAX); cl.value = val; }
                var len = val.trim().length;
                if (clCount) clCount.innerText = val.length;
                if (val.trim().length === 0) {
                    if (showEmpty) { setMsg(clMsg, 'Minimum 200 characters required.', false); mark(cl, true); }
                    else { setMsg(clMsg, '', false); mark(cl, false); }
                    return false;
                }
                if (len < CL_MIN) { setMsg(clMsg, 'Minimum 200 characters required.', false); mark(cl, true); return false; }
                if (len > CL_MAX) { setMsg(clMsg, 'Maximum 800 characters allowed.', false); mark(cl, true); return false; }
                setMsg(clMsg, 'Valid cover letter.', true); mark(cl, false); return true;
            }
            if (cl) {
                cl.setAttribute('maxlength', CL_MAX);
                cl.addEventListener('input', function () { validateCover(false); });
                cl.addEventListener('blur', function () { validateCover(true); });
                cl.addEventListener('paste', function () { setTimeout(function () { validateCover(false); }, 0); });
            }

            // ----- Proposed Rate: digits only, 1..200000, beside-label msg -----
            function sanitizeRate() {
                if (!rate) return;
                var v = (rate.value || '').replace(/[^0-9]/g, '').replace(/^0+(?=\d)/, '');
                if (v !== '' && parseInt(v, 10) > RATE_MAX) v = String(RATE_MAX);
                if (rate.value !== v) rate.value = v;
            }
            function validateRate(showEmpty) {
                if (!rate) return false;
                var raw = (rate.value || '').trim();
                if (raw === '') {
                    if (showEmpty) { setMsg(rateMsg, 'Proposed rate is required.', false); mark(rate, true); }
                    else { setMsg(rateMsg, '', false); mark(rate, false); }
                    return false;
                }
                if (!/^[0-9]+$/.test(raw)) { setMsg(rateMsg, 'Enter a valid positive amount.', false); mark(rate, true); return false; }
                var n = parseInt(raw, 10);
                if (n < RATE_MIN) { setMsg(rateMsg, 'Minimum amount is R1.00.', false); mark(rate, true); return false; }
                if (n > RATE_MAX) { setMsg(rateMsg, 'Maximum allowed is R200,000.00.', false); mark(rate, true); return false; }
                setMsg(rateMsg, 'Valid proposed rate.', true); mark(rate, false); return true;
            }
            if (rate) {
                rate.addEventListener('keydown', function (e) {
                    var k = e.keyCode || e.which;
                    var ctrl = [8, 9, 13, 46, 37, 38, 39, 40, 35, 36];
                    if (ctrl.indexOf(k) !== -1) return;
                    if (e.ctrlKey || e.metaKey) return;
                    var digit = (k >= 48 && k <= 57) || (k >= 96 && k <= 105);
                    if (!digit) e.preventDefault();   // blocks . , - letters etc.
                });
                rate.addEventListener('input', function () { sanitizeRate(); validateRate(false); });
                rate.addEventListener('blur', function () { validateRate(true); });
                rate.addEventListener('paste', function () { setTimeout(function () { sanitizeRate(); validateRate(false); }, 0); });
            }

            // ----- Completion Date: future-only, compute days (local), beside-label msg -----
            function validateDate(showEmpty) {
                if (!dateInp) return false;
                var val = (dateInp.value || '').trim();
                if (durPrev) durPrev.innerText = '';
                if (hfDays) hfDays.value = '';
                if (val === '') {
                    if (showEmpty) { setMsg(dateMsg, 'Please select a completion date.', false); mark(dateInp, true); }
                    else { setMsg(dateMsg, '', false); mark(dateInp, false); }
                    return false;
                }
                // Parse YYYY-MM-DD as a LOCAL date (avoid UTC shift).
                var parts = val.split('-');
                if (parts.length !== 3) { setMsg(dateMsg, 'Please select a completion date.', false); mark(dateInp, true); return false; }
                var sel = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
                var today = startOfLocalDay(new Date());
                if (sel < today) { setMsg(dateMsg, 'Past dates are not allowed.', false); mark(dateInp, true); return false; }
                var days = Math.round((sel - today) / 86400000);
                if (hfDays) hfDays.value = String(days);
                if (durPrev) durPrev.innerText = 'Estimated duration: ' + days + (days === 1 ? ' day' : ' days');
                setMsg(dateMsg, 'Valid completion date.', true); mark(dateInp, false); return true;
            }
            if (dateInp) {
                dateInp.setAttribute('min', todayLocalISO());   // disable past dates, dynamic
                dateInp.addEventListener('input', function () { validateDate(false); });
                dateInp.addEventListener('change', function () { validateDate(true); });
                dateInp.addEventListener('blur', function () { validateDate(true); });
            }

            // ----- Submit: run all validations; block + disable to prevent double-post -----
            if (submitBtn) {
                submitBtn.addEventListener('click', function (e) {
                    var okCl = validateCover(true);
                    var okRate = validateRate(true);
                    var okDate = validateDate(true);
                    if (!(okCl && okRate && okDate)) {
                        e.preventDefault();
                        return false;
                    }
                    // Valid: disable to prevent duplicate submissions. ASP.NET still posts
                    // because we re-enable via the __doPostBack already queued.
                    var btn = this;
                    setTimeout(function () { btn.disabled = true; btn.value = 'Submitting...'; }, 0);
                });
            }

            // Reflect any values retained after a server postback.
            validateCover(false);
            validateRate(false);
            validateDate(false);
        })();
    </script>

</asp:Content>

<%@ Page Title="Create Freelancer Profile - FreeHUB"
    Language="C#"
    AutoEventWireup="true"
    CodeBehind="CreateFreelancerProfile.aspx.cs"
    Inherits="FreeHubProject.CreateFreelancerProfile" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Create Freelancer Profile - FreeHUB</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { height: 100%; }
        body { font-family: Arial, Helvetica, sans-serif; background-color: #eef5ef; color: #243328; line-height: 1.6; overflow: hidden; }

        /* ===== Three-region fixed shell: header / scrollable middle / footer ===== */
        .cfp-shell { display: flex; flex-direction: column; height: 100vh; height: 100dvh; overflow: hidden; }

        .top-nav { flex: 0 0 auto; width: 100%; background: linear-gradient(90deg, #148b97 0%, #2fa86d 50%, #72c94b 100%); padding: 0 30px; display: flex; align-items: center; justify-content: space-between; min-height: 65px; }
        .top-nav .logo { color: white; text-decoration: none; font-size: 26px; font-weight: bold; letter-spacing: 1px; }
        .top-nav .logo span { color: #b7d68c; }
        .top-nav .nav-btn { color: white; background: none; border: 1px solid rgba(255,255,255,0.3); padding: 8px 18px; border-radius: 6px; cursor: pointer; font-size: 14px; text-decoration: none; transition: all 0.2s; }
        .top-nav .nav-btn:hover { background: rgba(255,255,255,0.1); border-color: rgba(255,255,255,0.6); }

        /* The middle fills the space between the fixed top-nav and footer. It no longer
           scrolls itself — only the form fields (.form-scroll) inside the white card do,
           so the heading/description/Back button stay stationary. */
        .cfp-middle { flex: 1 1 auto; min-height: 0; overflow: hidden; display: flex; }

        .cfp-footer { flex: 0 0 auto; background: linear-gradient(90deg, #148b97 0%, #2fa86d 50%, #72c94b 100%); color: #eafff0; padding: 14px 30px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 10px; font-size: 12px; }
        .cfp-footer .cfp-foot-logo { color: #fff; font-size: 18px; font-weight: bold; }
        .cfp-footer .cfp-foot-logo span { color: #d7f0b8; }
        .cfp-footer a { color: #eafff0; text-decoration: none; }

        /* The container fills the middle and lays its children out as a flex column so
           the heading/description stay fixed and the white card can host the scroller. */
        .container { max-width: 880px; width: 100%; margin: 0 auto; padding: 28px 20px; display: flex; flex-direction: column; min-height: 0; }
        .container h1 { flex: 0 0 auto; font-size: 26px; color: #173f2c; margin-bottom: 4px; text-align: center; }
        .container > p { flex: 0 0 auto; color: #5a6e5f; font-size: 14px; margin-bottom: 20px; text-align: center; }

        /* The white card fills the remaining height: the Back button is pinned at its top
           (Section A) and the form fields below it scroll (Section B). */
        .create-form { background: white; border-radius: 14px; padding: 24px 32px; border: 1px solid #e8ece8; box-shadow: 0 10px 30px rgba(16,40,28,0.06); display: flex; flex-direction: column; min-height: 0; flex: 1 1 auto; }

        /* Section A inside the card: Back button stays stationary. */
        .create-form > .back-link { flex: 0 0 auto; }

        /* Section B: the ONLY scrollable region — all form fields + actions. Slim green
           scrollbar on its right edge; no horizontal scroll. */
        .form-scroll {
            flex: 1 1 auto; min-height: 0;
            overflow-y: auto; overflow-x: hidden;
            padding-right: 8px; /* keep fields clear of the scrollbar */
            scrollbar-width: thin; scrollbar-color: #2e7d56 #eef3ef;
        }
        .form-scroll::-webkit-scrollbar { width: 8px; }
        .form-scroll::-webkit-scrollbar-track { background: #eef3ef; border-radius: 8px; }
        .form-scroll::-webkit-scrollbar-thumb { background: linear-gradient(180deg, #2e7d56, #72c94b); border-radius: 8px; border: 2px solid #eef3ef; }
        .form-scroll::-webkit-scrollbar-thumb:hover { background: #2e7d56; }

        .form-field { margin-bottom: 20px; }
        /* Label row: label and its validation message sit together on one line,
           left-aligned, with a small gap; wraps naturally on narrow screens. */
        .label-row { display: flex; align-items: baseline; justify-content: flex-start; gap: 10px; flex-wrap: wrap; margin-bottom: 6px; }
        .form-field label { font-size: 13px; font-weight: 600; color: #374638; }
        .form-field label span { color: #dc2626; }
        .field-error { color: #dc2626; font-size: 12px; font-weight: 600; text-align: left; }

        .form-input { width: 100%; padding: 12px 14px; border: 1px solid #d1d9d3; border-radius: 8px; font-size: 14px; transition: border-color 0.2s; min-height: 46px; }
        .form-input:focus { outline: none; border-color: #b7d68c; }
        .form-textarea { width: 100%; padding: 12px 14px; border: 1px solid #d1d9d3; border-radius: 8px; font-size: 14px; resize: vertical; min-height: 180px; font-family: Arial, sans-serif; line-height: 1.6; }
        .form-textarea:focus { outline: none; border-color: #b7d68c; }
        /* Controlled vertical resize for shared paragraph-formatting textareas. */
        textarea[data-fh-format='true'] { resize: vertical; max-height: 400px; overflow-y: auto; }
        /* Red outline on an invalid field (added by JS / after server validation). */
        .input-invalid { border-color: #dc2626 !important; }

        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
        .readonly-input { background-color: #f5f5f5; cursor: not-allowed; }

        /* Permanent helper text / character counter below inputs. */
        .field-footer { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-top: 6px; }
        .field-hint { color: #6b7280; font-size: 12px; }
        .char-counter { color: #6b7280; font-size: 12px; white-space: nowrap; }

        /* Compact pill: width fits the icon + label only (never stretched). As a flex
           child of the column .create-form it would otherwise stretch full-width, so
           align-self:flex-start + width:fit-content keep it left-aligned and compact. */
        .back-link { display: inline-flex; align-items: center; justify-content: flex-start; gap: 12px; align-self: flex-start; width: fit-content; max-width: 100%; white-space: nowrap; color: #0f5132; text-decoration: none; font-size: 15px; font-weight: 700; margin-bottom: 22px; padding: 8px 16px 8px 8px; border: none; border-radius: 50px; background-color: #eaf6ee; }
        .back-link:hover { background-color: #dcefe3; }
        .back-link::before { content: "\2190"; width: 34px; height: 34px; border-radius: 50%; background-color: #0f5132; color: #fff; display: inline-flex; align-items: center; justify-content: center; font-size: 16px; flex-shrink: 0; }

        /* ===== Hourly rate: attached non-editable R prefix + digits-only box ===== */
        .hr-rate-wrap { display: flex; align-items: stretch; }
        .hr-rate-prefix { display: inline-flex; align-items: center; padding: 0 14px; background: #eef3ef; border: 1px solid #d1d9d3; border-right: none; border-radius: 8px 0 0 8px; color: #3d5a47; font-weight: 700; }
        .hr-rate-input { flex: 1 1 auto; min-width: 0; border-top-left-radius: 0 !important; border-bottom-left-radius: 0 !important; }
        .hr-rate-help { display: block; margin-top: 6px; color: #6b7280; font-size: 12px; }
        .hr-rate-help .nowrap { white-space: nowrap; }

        /* ===== Centred compact action buttons ===== */
        .form-actions { display: flex; justify-content: center; gap: 12px; margin-top: 26px; }
        .btn-submit { height: 36px; padding: 0 16px; background-color: #0f7a44; color: white; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: background 0.2s; }
        .btn-submit:hover { background-color: #0c6639; }
        .btn-cancel { height: 36px; padding: 0 16px; background: #fff; border: 1px solid #0f7a44; border-radius: 8px; font-size: 14px; cursor: pointer; color: #0f7a44; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; }
        .btn-cancel:hover { background: #eaf6ee; }

        .msg { margin-top: 16px; font-size: 14px; text-align: center; }
        .msg-error { color: #dc2626; }
        .msg-success { color: #0f7a44; }

        /* Mobile: paired fields stack. */
        @media (max-width: 640px) {
            .form-row { grid-template-columns: 1fr; gap: 0; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

      <div class="cfp-shell">

        <!-- FIXED HEADER -->
        <div class="top-nav">
            <a href="ChooseRole.aspx" class="logo">Free<span>HUB</span></a>
            <asp:LinkButton ID="btnLogout" runat="server" CssClass="nav-btn" OnClick="btnLogout_Click">Logout</asp:LinkButton>
        </div>

        <!-- SCROLLABLE MIDDLE -->
        <div class="cfp-middle">
          <div class="container">

            <h1>Create Freelancer Profile</h1>
            <p>Showcase your skills and start finding projects.</p>

            <div class="create-form">

                <a href="ChooseRole.aspx" class="back-link">Back to Choose Role</a>

                <!-- SECTION B: scrollable form fields (only this scrolls) -->
                <div class="form-scroll">

                <!-- First / Last name -->
                <div class="form-row">
                    <div class="form-field">
                        <div class="label-row"><label>First Name</label></div>
                        <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-input readonly-input" ReadOnly="true" />
                    </div>
                    <div class="form-field">
                        <div class="label-row"><label>Last Name</label></div>
                        <asp:TextBox ID="txtLastName" runat="server" CssClass="form-input readonly-input" ReadOnly="true" />
                    </div>
                </div>

                <!-- Skills (full width) -->
                <div class="form-field">
                    <div class="label-row">
                        <label>Skills <span>*</span></label>
                        <asp:Label ID="lblSkillsError" runat="server" CssClass="field-error" />
                    </div>
                    <asp:TextBox ID="txtSkills" runat="server" CssClass="form-input" placeholder="e.g. Web Design, JavaScript, React" />
                </div>

                <!-- Work Experience (full width, enlarged) -->
                <div class="form-field">
                    <div class="label-row">
                        <label>Work Experience <span>*</span></label>
                        <asp:Label ID="lblExperienceError" runat="server" CssClass="field-error" />
                    </div>
                    <asp:TextBox ID="txtExperience" runat="server" CssClass="form-textarea" TextMode="MultiLine"
                        data-fh-format="true"
                        placeholder="Describe your employment, coursework, skills or personal projects..." />
                    <div class="field-footer">
                        <span class="field-hint">30&#8211;700 characters</span>
                        <span class="char-counter"><span id="expCount">0</span> / 700</span>
                    </div>
                </div>

                <!-- Portfolio / Hourly Rate -->
                <div class="form-row">
                    <div class="form-field">
                        <div class="label-row"><label>Portfolio Links</label></div>
                        <asp:TextBox ID="txtPortfolio" runat="server" CssClass="form-input" placeholder="e.g. https://portfolio.com" />
                    </div>
                    <div class="form-field">
                        <div class="label-row">
                            <label>Hourly Rate (ZAR) <span>*</span></label>
                            <asp:Label ID="lblRateError" runat="server" CssClass="field-error" />
                        </div>
                        <div class="hr-rate-wrap">
                            <span class="hr-rate-prefix">R</span>
                            <asp:TextBox ID="txtHourlyRate" runat="server" CssClass="form-input hr-rate-input"
                                placeholder="e.g. 250" MaxLength="4" inputmode="numeric" pattern="[0-9]*" />
                        </div>
                        <small class="hr-rate-help">Digits only. Maximum hourly rate: <span class="nowrap">R2&#160;000</span>.</small>
                    </div>
                </div>

                <!-- Centred compact buttons -->
                <div class="form-actions">
                    <asp:Button ID="btnSubmit" runat="server" Text="Create Profile" CssClass="btn-submit" OnClick="btnSubmit_Click" />
                    <a href="ChooseRole.aspx" class="btn-cancel">Cancel</a>
                </div>

                <asp:Label ID="lblMessage" runat="server" CssClass="msg" />

                </div><%-- /.form-scroll (Section B) --%>

            </div>
          </div>
        </div>

        <!-- FIXED FOOTER -->
        <div class="cfp-footer">
            <span class="cfp-foot-logo">Free<span>HUB</span></span>
            <span>&copy; 2026 FreeHUB. All rights reserved.</span>
        </div>

      </div>

    <script type="text/javascript">
        (function () {
            var exp = document.getElementById('<%= txtExperience.ClientID %>');
            var count = document.getElementById('expCount');
            var rate = document.getElementById('<%= txtHourlyRate.ClientID %>');

            // Live character counter for Work Experience (consistent on type/paste/postback).
            function updateCount() {
                if (!exp || !count) return;
                var len = (exp.value || '').length;
                count.innerText = len;
            }
            if (exp) {
                exp.addEventListener('input', updateCount);
                exp.addEventListener('paste', function () { setTimeout(updateCount, 0); });
                updateCount(); // reflect any value retained after a postback
            }

            // Hourly rate: digits only, capped at 2000, enforced on type and paste.
            function sanitizeRate() {
                if (!rate) return;
                var v = (rate.value || '').replace(/[^0-9]/g, '').replace(/^0+(?=\d)/, '');
                if (v !== '' && parseInt(v, 10) > 2000) v = '2000';
                if (rate.value !== v) rate.value = v;
            }
            if (rate) {
                rate.addEventListener('keydown', function (e) {
                    var k = e.keyCode || e.which;
                    var ctrl = [8, 9, 13, 46, 37, 38, 39, 40, 35, 36];
                    if (ctrl.indexOf(k) !== -1) return;
                    if (e.ctrlKey || e.metaKey) return;
                    var digit = (k >= 48 && k <= 57) || (k >= 96 && k <= 105);
                    if (!digit) e.preventDefault();
                });
                rate.addEventListener('input', sanitizeRate);
                rate.addEventListener('paste', function () { setTimeout(sanitizeRate, 0); });
            }
        })();
    </script>

    <%-- Shared paragraph-formatting helper (same as Project Description). --%>
    <script src="<%= ResolveUrl("~/fhText.js") %>?v=1" type="text/javascript"></script>

    </form>
</body>
</html>

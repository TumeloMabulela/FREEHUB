<%@ Page Title="Post Project"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="PostProject.aspx.cs"
    Inherits="FreeHubProject.PostProject" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />


        <!-- MAIN CONTENT -->

        <section class="freehub-main-content">


            <!-- PAGE TITLE -->

            <div class="post-page-heading">

                <div class="post-breadcrumb">

                    <a href="<%= ResolveUrl("~/Dashboard.aspx") %>" class="post-breadcrumb-link">Dashboard</a>

                    <span>/</span>

                    <a href="<%= ResolveUrl("~/MyProjects.aspx") %>" class="post-breadcrumb-link">My Projects</a>

                    <span>/</span>

                    <span class="post-breadcrumb-current">Post Project</span>

                </div>


                <h1>

                    Post a New Project

                </h1>


                <p>

                    Provide clear project information to find the right freelancer.

                </p>

            </div>


            <!-- STATUS MESSAGE -->

            <asp:Panel
                ID="pnlProjectStatus"
                runat="server"
                CssClass="post-status"
                Visible="false">

                <asp:Label
                    ID="lblProjectStatus"
                    runat="server">
                </asp:Label>

            </asp:Panel>


            <!-- PROJECT FORM -->

            <div class="post-content-grid">


                <div class="post-form-card">


                    <div class="post-card-title">

                        <h2>

                            Project Details

                        </h2>


                        <p>

                            Tell freelancers what you need.

                        </p>

                    </div>


                    <!-- PROJECT TITLE -->

                    <div class="post-field">

                        <label>

                            Project Title

                            <span>*</span>

                            <asp:Label ID="lblErrTitle" runat="server" CssClass="post-field-error" EnableViewState="false"></asp:Label>

                        </label>


                        <asp:TextBox
                            ID="txtProjectTitle"
                            runat="server"
                            CssClass="post-input"
                            placeholder="Example: Build a responsive e-commerce website">
                        </asp:TextBox>

                    </div>


                    <!-- CATEGORY AND EXPERIENCE -->

                    <div class="post-two-columns">


                        <div class="post-field">

                            <label>

                                Category

                                <span>*</span>

                                <asp:Label ID="lblErrCategory" runat="server" CssClass="post-field-error" EnableViewState="false"></asp:Label>

                            </label>


                            <asp:DropDownList
                                ID="ddlCategory"
                                runat="server"
                                CssClass="post-input"
                                onchange="toggleOtherCategory();">

                                <asp:ListItem
                                    Text="Select a category"
                                    Value="">
                                </asp:ListItem>

                                <asp:ListItem
                                    Text="Web Development"
                                    Value="Web Development">
                                </asp:ListItem>

                                <asp:ListItem
                                    Text="Software Development"
                                    Value="Software Development">
                                </asp:ListItem>

                                <asp:ListItem
                                    Text="Mobile Development"
                                    Value="Mobile Development">
                                </asp:ListItem>

                                <asp:ListItem
                                    Text="UI/UX Design"
                                    Value="UI/UX Design">
                                </asp:ListItem>

                                <asp:ListItem
                                    Text="Graphic Design"
                                    Value="Graphic Design">
                                </asp:ListItem>

                                <asp:ListItem
                                    Text="Digital Marketing"
                                    Value="Digital Marketing">
                                </asp:ListItem>

                                <asp:ListItem
                                    Text="Other"
                                    Value="Other">
                                </asp:ListItem>

                            </asp:DropDownList>


                            <!-- OTHER CATEGORY (shown only when "Other" is selected) -->

                            <asp:Panel
                                ID="pnlOtherCategory"
                                runat="server"
                                CssClass="post-other-category"
                                style="margin-top:10px; display:none;">

                                <asp:TextBox
                                    ID="txtOtherCategory"
                                    runat="server"
                                    CssClass="post-input"
                                    placeholder="Please specify the category">
                                </asp:TextBox>

                                <asp:Label ID="lblErrOtherCategory" runat="server" CssClass="post-field-error post-field-error-block" EnableViewState="false"></asp:Label>

                            </asp:Panel>

                        </div>


                        <div class="post-field">

                            <label>

                                Experience Level

                                <span>*</span>

                                <asp:Label ID="lblErrExperience" runat="server" CssClass="post-field-error" EnableViewState="false"></asp:Label>

                            </label>


                            <asp:DropDownList
                                ID="ddlExperience"
                                runat="server"
                                CssClass="post-input">

                                <asp:ListItem
                                    Text="Select experience level"
                                    Value="">
                                </asp:ListItem>

                                <asp:ListItem
                                    Text="Beginner"
                                    Value="Beginner">
                                </asp:ListItem>

                                <asp:ListItem
                                    Text="Intermediate"
                                    Value="Intermediate">
                                </asp:ListItem>

                                <asp:ListItem
                                    Text="Expert"
                                    Value="Expert">
                                </asp:ListItem>

                            </asp:DropDownList>

                        </div>

                    </div>


                    <!-- DESCRIPTION -->

                    <div class="post-field">

                        <label>

                            Project Description

                            <span>*</span>

                            <asp:Label ID="lblErrDescription" runat="server" CssClass="post-field-error" EnableViewState="false"></asp:Label>

                        </label>


                        <asp:TextBox
                            ID="txtDescription"
                            runat="server"
                            CssClass="post-textarea"
                            TextMode="MultiLine"
                            Rows="7"
                            data-fh-format="true"
                            placeholder="Example: I need a responsive e-commerce website with a product catalogue, shopping cart, and secure checkout. Please include the key features, any design preferences, deliverables, and the timeline you expect. (At least 50 characters.)">
                        </asp:TextBox>

                        <p class="field-description">
                            Minimum 50 characters.
                            <span id="descCharCount" style="font-weight:600;">0</span>/50 entered.
                        </p>

                    </div>


                    <!-- BUDGET -->

                    <div class="post-budget-area">


                        <div class="post-field">

                            <label>

                                Budget Type

                                <span>*</span>

                                <asp:Label ID="lblErrBudgetType" runat="server" CssClass="post-field-error" EnableViewState="false"></asp:Label>

                            </label>


                            <asp:RadioButtonList
                                ID="rblBudgetType"
                                runat="server"
                                CssClass="post-budget-options"
                                RepeatDirection="Horizontal">

                                <asp:ListItem
                                    Text="Fixed Price"
                                    Value="Fixed"
                                    Selected="True">
                                </asp:ListItem>

                                <asp:ListItem
                                    Text="Hourly"
                                    Value="Hourly">
                                </asp:ListItem>

                            </asp:RadioButtonList>

                        </div>


                        <div class="post-field">

                            <label>

                                Budget Amount

                                <span>*</span>

                                <asp:Label ID="lblErrBudget" runat="server" CssClass="post-field-error" EnableViewState="false"></asp:Label>

                            </label>


                            <div id="budgetInputBox" class="budget-input-box">

                                <span>R</span>


                                <%-- Text input (not type=number) so browsers can't inject
                                     e, +, -, or a decimal point. Digits 0-9 only, max 6 chars
                                     (200000). JS enforces live; C# re-validates on the server. --%>
                                <asp:TextBox
                                    ID="txtBudget"
                                    runat="server"
                                    CssClass="budget-input"
                                    TextMode="SingleLine"
                                    MaxLength="6"
                                    placeholder="25000"
                                    autocomplete="off"
                                    inputmode="numeric"
                                    pattern="[0-9]*">
                                </asp:TextBox>

                            </div>

                        </div>


                        <div class="post-field">

                            <label>

                                Deadline

                                <span>*</span>

                                <asp:Label ID="lblErrDeadline" runat="server" CssClass="post-field-error" EnableViewState="false"></asp:Label>

                            </label>


                            <asp:TextBox
                                ID="txtDeadline"
                                runat="server"
                                CssClass="post-input"
                                TextMode="Date">
                            </asp:TextBox>

                        </div>

                    </div>


                    <!-- REQUIRED SKILLS -->

                    <div class="post-field">

                        <label>

                            Required Skills

                            <span>*</span>

                            <asp:Label ID="lblErrSkills" runat="server" CssClass="post-field-error" EnableViewState="false"></asp:Label>

                        </label>


                        <p class="field-description">

                            Select the skills needed to complete this project.

                        </p>


                        <asp:CheckBoxList
                            ID="cblSkills"
                            runat="server"
                            CssClass="post-skills"
                            RepeatDirection="Horizontal"
                            RepeatLayout="Flow">

                            <asp:ListItem
                                Text="HTML"
                                Value="HTML">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="CSS"
                                Value="CSS">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="JavaScript"
                                Value="JavaScript">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="C#"
                                Value="C#">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="ASP.NET"
                                Value="ASP.NET">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="SQL"
                                Value="SQL">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="UI/UX Design"
                                Value="UI/UX Design">
                            </asp:ListItem>

                        </asp:CheckBoxList>

                    </div>


                    <!-- ATTACHMENTS -->

                    <div class="post-field">

                        <label>

                            Attachments

                            <small>

                                Optional

                            </small>

                        </label>


                        <div class="post-upload-box">

                            <div class="upload-symbol">

                                ↑

                            </div>


                            <strong>

                                Upload project files

                            </strong>


                            <p>

                                Add a PDF or image (JPG, JPEG, PNG, GIF, WEBP).

                            </p>


                            <asp:FileUpload
                                ID="fileAttachment"
                                runat="server"
                                CssClass="post-file-upload"
                                accept=".pdf,.jpg,.jpeg,.png,.gif,.webp,application/pdf,image/*" />

                        </div>


                        <asp:Label
                            ID="lblAttachment"
                            runat="server"
                            CssClass="selected-file">
                        </asp:Label>

                    </div>


                    <!-- BUTTONS -->

                    <div class="post-buttons">


                        <asp:Button
                            ID="btnCancel"
                            runat="server"
                            Text="Cancel"
                            CssClass="post-cancel-button"
                            CausesValidation="false"
                            OnClick="btnCancel_Click" />


                        <div class="post-right-buttons">


                            <!-- EDIT PROJECT -->

                            <asp:Button
                                ID="btnEditProject"
                                runat="server"
                                Text="✎ Edit Project"
                                CssClass="post-edit-button"
                                CausesValidation="false"
                                OnClick="btnEditProject_Click" />


                            <!-- PREVIEW -->

                            <asp:Button
                                ID="btnPreview"
                                runat="server"
                                Text="Preview"
                                CssClass="post-preview-button"
                                CausesValidation="false"
                                OnClick="btnPreview_Click" />


                            <!-- POST OR SAVE -->

                            <asp:Button
                                ID="btnSubmitProject"
                                runat="server"
                                Text="Post Project"
                                CssClass="post-submit-button"
                                OnClick="btnSubmitProject_Click" />

                        </div>

                    </div>

                </div>


                <!-- RIGHT SIDE -->

                <div class="post-help-column">


                    <div class="post-help-card">

                        <h3>

                            Tips for a Great Project

                        </h3>


                        <div class="help-tip">

                            <div class="help-icon">

                                ✓

                            </div>


                            <div>

                                <strong>

                                    Be specific

                                </strong>


                                <p>

                                    Explain the project clearly and include important requirements.

                                </p>

                            </div>

                        </div>


                        <div class="help-tip">

                            <div class="help-icon">

                                R

                            </div>


                            <div>

                                <strong>

                                    Set a fair budget

                                </strong>


                                <p>

                                    A realistic budget attracts skilled freelancers.

                                </p>

                            </div>

                        </div>


                        <div class="help-tip">

                            <div class="help-icon">

                                ★

                            </div>


                            <div>

                                <strong>

                                    Select key skills

                                </strong>


                                <p>

                                    Choose the skills that are essential for the project.

                                </p>

                            </div>

                        </div>


                        <div class="help-tip">

                            <div class="help-icon">

                                ◷

                            </div>


                            <div>

                                <strong>

                                    Choose a deadline

                                </strong>


                                <p>

                                    Give freelancers enough time to deliver quality work.

                                </p>

                            </div>

                        </div>

                    </div>


                </div>

            </div>


            <!-- PROJECT PREVIEW -->

            <asp:Panel
                ID="pnlPreview"
                runat="server"
                CssClass="full-project-preview"
                Visible="false">


                <div class="preview-heading">

                    <h2>

                        Project Preview

                    </h2>


                    <span>

                        Review your information before posting.

                    </span>

                </div>


                <div class="preview-grid">


                    <div>

                        <strong>

                            Project Title

                        </strong>


                        <asp:Label
                            ID="lblPreviewTitle"
                            runat="server">
                        </asp:Label>

                    </div>


                    <div>

                        <strong>

                            Category

                        </strong>


                        <asp:Label
                            ID="lblPreviewCategory"
                            runat="server">
                        </asp:Label>

                    </div>


                    <div>

                        <strong>

                            Description

                        </strong>


                        <asp:Label
                            ID="lblPreviewDescription"
                            runat="server">
                        </asp:Label>

                    </div>


                    <div>

                        <strong>

                            Budget

                        </strong>


                        <asp:Label
                            ID="lblPreviewBudget"
                            runat="server">
                        </asp:Label>

                    </div>


                    <div>

                        <strong>

                            Deadline

                        </strong>


                        <asp:Label
                            ID="lblPreviewDeadline"
                            runat="server">
                        </asp:Label>

                    </div>


                    <div>

                        <strong>

                            Experience

                        </strong>


                        <asp:Label
                            ID="lblPreviewExperience"
                            runat="server">
                        </asp:Label>

                    </div>


                    <div>

                        <strong>

                            Required Skills

                        </strong>


                        <asp:Label
                            ID="lblPreviewSkills"
                            runat="server">
                        </asp:Label>

                    </div>

                </div>

            </asp:Panel>

        </section>

    </div>


    <!-- VALIDATION POP-UP (budget too low / exceeding limit, missing fields, etc.)
         Reuses the master page's modal styling for a consistent look. -->
    <div id="ppValidationModal" class="fh-modal-overlay" style="display:none;">
        <div class="fh-modal">
            <div class="fh-modal-icon" style="background:#fef3c7; color:#d97706;">&#33;</div>
            <h3 id="ppValidationTitle">Please check your details</h3>
            <p id="ppValidationMessage"></p>
            <button type="button" class="fh-modal-btn-primary" style="background:#2b68c2;" onclick="ppHideValidation();">OK</button>
        </div>
    </div>


    <!-- SUCCESS POP-UP (after a project is posted). Server fills the message and
         un-hides this panel; the two buttons navigate to Dashboard or My Projects. -->
    <asp:Panel ID="pnlSuccessModal" runat="server" CssClass="fh-modal-overlay" Visible="false"
               style="display:flex;">
        <div class="fh-modal">
            <div class="fh-modal-icon" style="background:#2e7d56; color:#fff;">&#10003;</div>
            <h3>Project Posted</h3>
            <p><asp:Literal ID="litSuccessMessage" runat="server"></asp:Literal></p>
            <asp:Button ID="btnGoDashboard" runat="server" Text="Go to Dashboard"
                        CssClass="fh-modal-btn-primary" style="background:#2e7d56;"
                        CausesValidation="false" OnClick="btnGoDashboard_Click" />
            <br />
            <asp:Button ID="btnGoMyProjects" runat="server" Text="View My Projects"
                        CssClass="fh-modal-btn-cancel" CausesValidation="false"
                        OnClick="btnGoMyProjects_Click" />
        </div>
    </asp:Panel>


    <style type="text/css">
        /* Compact inline validation message shown beside a field label.
           Hidden until it has text so it never disrupts the layout. */
        .post-field-error {
            margin-left: 8px;
            color: #d4474f;
            font-size: 11px;
            font-weight: 600;
        }
        .post-field-error:empty { display: none; }
        /* For the "Other category" message that sits under its input instead of a label. */
        .post-field-error-block {
            display: block;
            margin-left: 0;
            margin-top: 6px;
        }
        /* Red highlight for an invalid field's border. */
        .post-input.input-invalid,
        .post-textarea.input-invalid {
            border-color: #d4474f !important;
        }
        .budget-input-box.input-invalid {
            border-color: #d4474f !important;
        }
        .post-budget-options.input-invalid {
            border-color: #d4474f !important;
        }
    </style>

    <script src="<%= ResolveUrl("~/fhText.js") %>?v=1" type="text/javascript"></script>

    <script type="text/javascript">

        function toggleOtherCategory() {
            var ddl = document.getElementById('<%= ddlCategory.ClientID %>');
            var panel = document.getElementById('<%= pnlOtherCategory.ClientID %>');
            if (!ddl || !panel) return;
            panel.style.display = (ddl.value === 'Other') ? 'block' : 'none';
        }

        // Restore the correct state on load (e.g. after a validation postback).
        if (window.addEventListener) {
            window.addEventListener('load', toggleOtherCategory);
        } else {
            window.attachEvent('onload', toggleOtherCategory);
        }

        // ============================================================
        // Validation pop-up (shared) — used for budget limit messages and
        // the summary shown when Post is clicked with invalid fields.
        // ============================================================
        function ppShowValidation(message, title) {
            var m = document.getElementById('ppValidationMessage');
            var t = document.getElementById('ppValidationTitle');
            if (m) m.innerHTML = message || 'Please review the highlighted fields.';
            if (t) t.innerText = title || 'Please check your details';
            var modal = document.getElementById('ppValidationModal');
            if (modal) modal.style.display = 'flex';
        }
        function ppHideValidation() {
            var modal = document.getElementById('ppValidationModal');
            if (modal) modal.style.display = 'none';
        }
        // Close when clicking the dark overlay.
        document.addEventListener('click', function (e) {
            if (e.target && e.target.id === 'ppValidationModal') ppHideValidation();
        });

        var MIN_DESCRIPTION = 50;

        // ============================================================
        // Project Description: live character counter + 50-char minimum.
        // ============================================================
        (function () {
            var desc = document.getElementById('<%= txtDescription.ClientID %>');
            var count = document.getElementById('descCharCount');
            var descErr = document.getElementById('<%= lblErrDescription.ClientID %>');
            if (!desc) return;

            function update() {
                var len = desc.value.trim().length;
                if (count) count.innerText = len;
                // Clear the inline error once the minimum is met.
                if (len >= MIN_DESCRIPTION) {
                    if (descErr) descErr.innerText = '';
                    desc.classList.remove('input-invalid');
                }
            }
            desc.addEventListener('input', update);
            desc.addEventListener('blur', update);
            update();
        })();

        // ============================================================
        // Budget Amount: whole-number rand only, 0..200000, live checks.
        // ============================================================
        (function () {
            var MAX_BUDGET = 200000;

            var budget = document.getElementById('<%= txtBudget.ClientID %>');
            var budgetBox = document.getElementById('budgetInputBox');
            var budgetErr = document.getElementById('<%= lblErrBudget.ClientID %>');

            if (!budget) return;

            function setBudgetError(msg) {
                if (budgetErr) budgetErr.innerText = msg || '';
                if (budgetBox) {
                    if (msg) budgetBox.classList.add('input-invalid');
                    else budgetBox.classList.remove('input-invalid');
                }
            }

            // Strip everything that is not a digit. Do NOT clamp/auto-fill the maximum:
            // if the user types more than the limit we keep their digits and show the
            // validation error so they must correct it themselves.
            function sanitize() {
                var original = budget.value;
                var digits = original.replace(/[^0-9]/g, '');

                // Drop leading zeros (normalise "007" -> "7"). Empty stays empty.
                if (digits.length > 1) digits = digits.replace(/^0+/, '');

                // Only strip non-digits here; the length/limit is validated, not clamped.
                if (digits !== original) budget.value = digits;

                if (digits !== '' && parseInt(digits, 10) > MAX_BUDGET) {
                    setBudgetError('Maximum budget allowed is R200 000.00');
                } else {
                    // Clear the error once the value is valid again.
                    setBudgetError('');
                }
            }

            // Block non-digit keys up front (allow control/navigation keys).
            budget.addEventListener('keydown', function (e) {
                var key = e.keyCode || e.which;
                var allowed = [8, 9, 13, 46, 37, 38, 39, 40, 35, 36]; // bksp, tab, enter, del, arrows, home, end
                if (allowed.indexOf(key) !== -1) return;
                if (e.ctrlKey || e.metaKey) return; // allow copy/paste/select-all shortcuts
                var isTopDigit = key >= 48 && key <= 57;
                var isNumpadDigit = key >= 96 && key <= 105;
                if (!isTopDigit && !isNumpadDigit) {
                    e.preventDefault();
                }
            });

            budget.addEventListener('input', sanitize);
            budget.addEventListener('paste', function () {
                // Let the paste land, then sanitize + clamp (handles "R1,000.50" etc.).
                setTimeout(sanitize, 0);
            });
            budget.addEventListener('blur', sanitize);
        })();

        // ============================================================
        // Clear a field's inline error + red border as soon as it's corrected.
        // ============================================================
        (function () {
            function bindClear(ctrlId, errId, invalidTarget) {
                var ctrl = document.getElementById(ctrlId);
                var err = document.getElementById(errId);
                if (!ctrl) return;
                var evt = (ctrl.tagName === 'SELECT') ? 'change' : 'input';
                ctrl.addEventListener(evt, function () {
                    var hasValue = (ctrl.value && ctrl.value.toString().trim() !== '');
                    if (hasValue) {
                        if (err) err.innerText = '';
                        var target = invalidTarget ? document.getElementById(invalidTarget) : ctrl;
                        if (target) target.classList.remove('input-invalid');
                    }
                });
            }

            bindClear('<%= txtProjectTitle.ClientID %>', '<%= lblErrTitle.ClientID %>');
            bindClear('<%= ddlCategory.ClientID %>', '<%= lblErrCategory.ClientID %>');
            bindClear('<%= txtOtherCategory.ClientID %>', '<%= lblErrOtherCategory.ClientID %>');
            bindClear('<%= ddlExperience.ClientID %>', '<%= lblErrExperience.ClientID %>');
            bindClear('<%= txtDescription.ClientID %>', '<%= lblErrDescription.ClientID %>');
            bindClear('<%= txtDeadline.ClientID %>', '<%= lblErrDeadline.ClientID %>');
        })();

        // ============================================================
        // Auto-save draft: keeps what you've typed so you can leave the
        // page and continue later. Stored in the browser (localStorage),
        // per user, and cleared once the project is posted or cancelled.
        // No server/database involvement.
        // ============================================================
        (function () {
            // Scope the draft to the logged-in user so drafts don't leak between accounts.
            var DRAFT_KEY = 'fh_postproject_draft_<%= (Session["UserID"] ?? "guest").ToString() %>';

            // Map of logical name -> control id. Text/select fields.
            var fields = {
                title: '<%= txtProjectTitle.ClientID %>',
                category: '<%= ddlCategory.ClientID %>',
                otherCategory: '<%= txtOtherCategory.ClientID %>',
                experience: '<%= ddlExperience.ClientID %>',
                description: '<%= txtDescription.ClientID %>',
                budget: '<%= txtBudget.ClientID %>',
                deadline: '<%= txtDeadline.ClientID %>'
            };
            var budgetTypeName = '<%= rblBudgetType.UniqueID %>';          // radio group name
            var skillsContainerId = '<%= cblSkills.ClientID %>';            // checkbox list container
            var successModal = document.getElementById('<%= pnlSuccessModal.ClientID %>');

            function el(id) { return document.getElementById(id); }

            // If the project was just posted successfully, the success modal is rendered.
            // Clear the draft and stop — nothing to restore.
            if (successModal) {
                try { localStorage.removeItem(DRAFT_KEY); } catch (e) { }
                return;
            }

            function collect() {
                var data = {};
                for (var k in fields) {
                    var c = el(fields[k]);
                    if (c) data[k] = c.value;
                }
                // Budget type (radio group).
                var radios = document.getElementsByName(budgetTypeName);
                for (var i = 0; i < radios.length; i++) {
                    if (radios[i].checked) { data.budgetType = radios[i].value; break; }
                }
                // Skills (checkbox list) -> list of checked values/labels.
                var container = el(skillsContainerId);
                if (container) {
                    var boxes = container.getElementsByTagName('input');
                    var checked = [];
                    for (var j = 0; j < boxes.length; j++) {
                        if (boxes[j].type === 'checkbox' && boxes[j].checked) checked.push(boxes[j].id);
                    }
                    data.skills = checked;
                }
                return data;
            }

            function save() {
                try { localStorage.setItem(DRAFT_KEY, JSON.stringify(collect())); } catch (e) { }
            }

            function restore() {
                var raw;
                try { raw = localStorage.getItem(DRAFT_KEY); } catch (e) { return; }
                if (!raw) return;
                var data;
                try { data = JSON.parse(raw); } catch (e) { return; }

                // Only fill fields that are currently empty, so a validation postback
                // (which keeps the server's values) is never overwritten.
                for (var k in fields) {
                    var c = el(fields[k]);
                    if (c && (c.value === '' || c.value == null) && data[k]) {
                        c.value = data[k];
                    }
                }
                if (data.budgetType) {
                    var radios = document.getElementsByName(budgetTypeName);
                    for (var i = 0; i < radios.length; i++) {
                        if (radios[i].value === data.budgetType && !anyRadioChecked(radios)) {
                            radios[i].checked = true;
                        }
                    }
                }
                if (data.skills && data.skills.length) {
                    for (var s = 0; s < data.skills.length; s++) {
                        var box = el(data.skills[s]);
                        if (box && box.type === 'checkbox') box.checked = true;
                    }
                }

                // Reflect restored state in dependent UI (e.g. "Other" category box) + counters.
                if (typeof toggleOtherCategory === 'function') toggleOtherCategory();
                var desc = el(fields.description);
                if (desc) { var ev = new Event('input'); desc.dispatchEvent(ev); }
            }

            function anyRadioChecked(radios) {
                for (var i = 0; i < radios.length; i++) if (radios[i].checked) return true;
                return false;
            }

            // Restore on load, then attach savers to every field.
            restore();

            // Save on any change within the form card (covers text, selects, radios, checkboxes).
            var scope = document.querySelector('.post-form-card') || document;
            scope.addEventListener('input', save, true);
            scope.addEventListener('change', save, true);

            // Clear the draft when the user cancels (Cancel posts back and clears the form).
            var cancelBtn = el('<%= btnCancel.ClientID %>');
            if (cancelBtn) cancelBtn.addEventListener('click', function () {
                try { localStorage.removeItem(DRAFT_KEY); } catch (e) { }
            });
        })();

    </script>

</asp:Content>
<%@ Page Title="Choose Role - FreeHUB"
    Language="C#"
    AutoEventWireup="true"
    CodeBehind="ChooseRole.aspx.cs"
    Inherits="FreeHubProject.ChooseRole" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Choose Role - FreeHUB</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Arial, Helvetica, sans-serif;
            background-color: #f5f7f5;
            color: #243328;
            line-height: 1.6;
            min-height: 100vh;
        }

        /* Minimal nav */
        .choose-nav {
            width: 100%;
            background-color: #173f2c;
            padding: 0 30px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            min-height: 65px;
        }

        .choose-nav .logo {
            color: white;
            text-decoration: none;
            font-size: 26px;
            font-weight: bold;
            letter-spacing: 1px;
        }

        .choose-nav .logo span { color: #b7d68c; }

        .choose-nav .logout-btn {
            color: white;
            background: none;
            border: 1px solid rgba(255,255,255,0.3);
            padding: 8px 18px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            transition: all 0.2s;
        }

        .choose-nav .logout-btn:hover {
            background: rgba(255,255,255,0.1);
            border-color: rgba(255,255,255,0.6);
        }

        /* Main content */
        .choose-role-container {
            max-width: 820px;
            margin: 60px auto;
            padding: 0 20px;
            text-align: center;
        }

        .choose-role-container h1 {
            font-size: 28px;
            color: #173f2c;
            margin-bottom: 8px;
        }

        .choose-role-container > p {
            color: #5a6e5f;
            font-size: 15px;
            margin-bottom: 40px;
        }

        .role-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 24px;
            margin-bottom: 30px;
        }

        .role-card {
            background: white;
            border-radius: 14px;
            padding: 32px 24px;
            border: 2px solid #e8ece8;
            text-align: center;
            transition: all 0.2s;
        }

        .role-card:hover {
            border-color: #b7d68c;
            box-shadow: 0 6px 20px rgba(0,0,0,0.08);
        }

        .role-card .role-icon {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background-color: #e8f5e0;
            color: #2d6b3f;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            margin: 0 auto 16px;
        }

        .role-card h3 {
            font-size: 20px;
            color: #173f2c;
            margin-bottom: 10px;
        }

        .role-card p {
            color: #5a6e5f;
            font-size: 14px;
            margin-bottom: 18px;
            line-height: 1.5;
        }

        .role-status {
            display: inline-block;
            padding: 4px 14px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 18px;
        }

        .role-status.active { background-color: #e8f5e0; color: #2d6b3f; }
        .role-status.deactivated { background-color: #fff3e0; color: #c47a1a; }
        .role-status.not-created { background-color: #e0f0ff; color: #1a6bc4; }

        .role-btn {
            display: inline-block;
            padding: 12px 28px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            border: none;
            transition: all 0.2s;
            width: 100%;
            max-width: 260px;
        }

        .role-btn.btn-green { background-color: #173f2c; color: white; }
        .role-btn.btn-green:hover { background-color: #1f5438; }
        .role-btn.btn-orange { background-color: #f59e0b; color: white; }
        .role-btn.btn-orange:hover { background-color: #d97706; }
        .role-btn.btn-blue { background-color: #2563eb; color: white; }
        .role-btn.btn-blue:hover { background-color: #1d4ed8; }

        /* Message */
        .choose-message {
            padding: 14px 20px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 14px;
            text-align: left;
        }

        .choose-message.info { background-color: #fff3e0; border: 1px solid #f59e0b; color: #92400e; }
        .choose-message.success { background-color: #e8f5e0; border: 1px solid #86efac; color: #166534; }
        .choose-message.error { background-color: #fee2e2; border: 1px solid #fca5a5; color: #991b1b; }

        /* Creation form */
        .create-form {
            background: white;
            border-radius: 12px;
            padding: 30px;
            margin-top: 30px;
            border: 1px solid #e8ece8;
            text-align: left;
        }

        .create-form h3 {
            color: #173f2c;
            margin-bottom: 20px;
            font-size: 18px;
        }

        .form-field {
            margin-bottom: 16px;
        }

        .form-field label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #374638;
            margin-bottom: 6px;
        }

        .form-field label span { color: #dc2626; }

        .form-input {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #d1d9d3;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.2s;
        }

        .form-input:focus { outline: none; border-color: #b7d68c; }

        .form-textarea {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #d1d9d3;
            border-radius: 8px;
            font-size: 14px;
            resize: vertical;
            min-height: 80px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .form-submit {
            background-color: #173f2c;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 10px;
            transition: background 0.2s;
        }

        .form-submit:hover { background-color: #1f5438; }

        .form-cancel {
            background: none;
            border: 1px solid #d1d9d3;
            padding: 12px 30px;
            border-radius: 8px;
            font-size: 14px;
            cursor: pointer;
            margin-left: 10px;
            transition: all 0.2s;
        }

        .form-cancel:hover { border-color: #173f2c; }

        /* Progress Steps */
        .progress-steps {
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 36px;
            gap: 0;
        }

        .step {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
        }

        .step-circle {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: #e8ece8;
            color: #888;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            font-weight: 700;
            border: 2px solid #d1d9d3;
            transition: all 0.3s;
        }

        .step.active .step-circle {
            background: #173f2c;
            color: white;
            border-color: #173f2c;
        }

        .step.completed .step-circle {
            background: #16a34a;
            color: white;
            border-color: #16a34a;
        }

        .step-label {
            font-size: 12px;
            color: #888;
            font-weight: 500;
            white-space: nowrap;
        }

        .step.active .step-label { color: #173f2c; font-weight: 600; }
        .step.completed .step-label { color: #16a34a; font-weight: 600; }

        .step-line {
            width: 60px;
            height: 3px;
            background: #e0e0e0;
            margin: 0 8px;
            margin-bottom: 28px;
            border-radius: 2px;
        }

        .step-line.completed { background: #16a34a; }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <!-- Minimal Navigation: Logo + Logout only -->
        <div class="choose-nav">
            <a href="ChooseRole.aspx" class="logo">Free<span>HUB</span></a>
            <asp:LinkButton ID="btnLogout" runat="server" CssClass="logout-btn" OnClick="btnLogout_Click">Logout</asp:LinkButton>
        </div>

        <div class="choose-role-container">

            <!-- Progress Indicator (only for new users) -->
            <asp:Panel ID="pnlProgressIndicator" runat="server" Visible="false">
            <div class="progress-steps">
                <div class="step completed">
                    <div class="step-circle">&#10003;</div>
                    <span class="step-label">Create Account</span>
                </div>
                <div class="step-line completed"></div>
                <div class="step active">
                    <div class="step-circle">2</div>
                    <span class="step-label">Choose Role</span>
                </div>
                <div class="step-line"></div>
                <div class="step">
                    <div class="step-circle">3</div>
                    <span class="step-label">Complete Profile</span>
                </div>
            </div>
            </asp:Panel>

            <h1>Choose How to Continue</h1>
            <p>Select which profile you'd like to use on FreeHUB.</p>

            <!-- Message panel -->
            <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                <div class="choose-message info">
                    <asp:Label ID="lblMessage" runat="server" />
                </div>
            </asp:Panel>

            <div class="role-cards">

                <!-- Freelancer Card -->
                <div class="role-card">
                    <div class="role-icon">&#128187;</div>
                    <h3>Freelancer</h3>

                    <asp:Panel ID="pnlFreelancerActive" runat="server" Visible="false">
                        <span class="role-status active">Active</span>
                        <p>Your freelancer profile is active and visible to employers.</p>
                        <asp:Button ID="btnContinueFreelancer" runat="server" Text="Continue as Freelancer"
                            CssClass="role-btn btn-green" OnClick="btnContinueFreelancer_Click" CausesValidation="false" />
                    </asp:Panel>

                    <asp:Panel ID="pnlFreelancerDeactivated" runat="server" Visible="false">
                        <span class="role-status deactivated">Deactivated</span>
                        <p>Your freelancer profile is deactivated. Reactivate it to continue.</p>
                        <asp:Button ID="btnReactivateFreelancer" runat="server" Text="Reactivate Freelancer Profile"
                            CssClass="role-btn btn-orange"
                            OnClientClick="return showReactivateConfirm(this, 'Freelancer');"
                            OnClick="btnReactivateFreelancer_Click" CausesValidation="false" />
                    </asp:Panel>

                    <asp:Panel ID="pnlFreelancerNotCreated" runat="server" Visible="false">
                        <span class="role-status not-created">Not Created</span>
                        <p>You don't have a freelancer profile yet. Create one to start finding work.</p>
                        <asp:Button ID="btnCreateFreelancer" runat="server" Text="Create Freelancer Profile"
                            CssClass="role-btn btn-blue" OnClick="btnShowCreateFreelancer_Click" CausesValidation="false" />
                    </asp:Panel>
                </div>

                <!-- Employer Card -->
                <div class="role-card">
                    <div class="role-icon">&#127970;</div>
                    <h3>Employer</h3>

                    <asp:Panel ID="pnlEmployerActive" runat="server" Visible="false">
                        <span class="role-status active">Active</span>
                        <p>Your employer profile is active. You can post projects and hire freelancers.</p>
                        <asp:Button ID="btnContinueEmployer" runat="server" Text="Continue as Employer"
                            CssClass="role-btn btn-green" OnClick="btnContinueEmployer_Click" CausesValidation="false" />
                    </asp:Panel>

                    <asp:Panel ID="pnlEmployerDeactivated" runat="server" Visible="false">
                        <span class="role-status deactivated">Deactivated</span>
                        <p>Your employer profile is deactivated. Reactivate it to continue.</p>
                        <asp:Button ID="btnReactivateEmployer" runat="server" Text="Reactivate Employer Profile"
                            CssClass="role-btn btn-orange"
                            OnClientClick="return showReactivateConfirm(this, 'Employer');"
                            OnClick="btnReactivateEmployer_Click" CausesValidation="false" />
                    </asp:Panel>

                    <asp:Panel ID="pnlEmployerNotCreated" runat="server" Visible="false">
                        <span class="role-status not-created">Not Created</span>
                        <p>You don't have an employer profile yet. Create one to start hiring talent.</p>
                        <asp:Button ID="btnCreateEmployer" runat="server" Text="Create Employer Profile"
                            CssClass="role-btn btn-blue" OnClick="btnShowCreateEmployer_Click" CausesValidation="false" />
                    </asp:Panel>
                </div>

            </div>

            <!-- Freelancer Creation Form -->
            <asp:Panel ID="pnlCreateFreelancer" runat="server" Visible="false">
                <div class="create-form">
                    <h3>Create Freelancer Profile</h3>

                    <div class="form-row">
                        <div class="form-field">
                            <label>First Name <span>*</span></label>
                            <asp:TextBox ID="txtFreelancerFirstName" runat="server" CssClass="form-input"
                                placeholder="Enter your first name" />
                        </div>
                        <div class="form-field">
                            <label>Last Name <span>*</span></label>
                            <asp:TextBox ID="txtFreelancerLastName" runat="server" CssClass="form-input"
                                placeholder="Enter your last name" />
                        </div>
                    </div>

                    <div class="form-field">
                        <label>Profile Picture</label>
                        <asp:FileUpload ID="fuFreelancerPicture" runat="server" CssClass="form-input" />
                    </div>

                    <div class="form-field">
                        <label>Bio / About Me</label>
                        <asp:TextBox ID="txtFreelancerBio" runat="server" CssClass="form-textarea"
                            TextMode="MultiLine" Rows="3" placeholder="Tell employers about yourself..." />
                    </div>

                    <div class="form-row">
                        <div class="form-field">
                            <label>Location / City</label>
                            <asp:TextBox ID="txtFreelancerLocation" runat="server" CssClass="form-input"
                                placeholder="e.g. Johannesburg, SA" />
                        </div>
                        <div class="form-field">
                            <label>Preferred Language</label>
                            <asp:DropDownList ID="ddlFreelancerLanguage" runat="server" CssClass="form-input">
                                <asp:ListItem Text="Select Language" Value="" />
                                <asp:ListItem Text="English" Value="English" />
                                <asp:ListItem Text="Afrikaans" Value="Afrikaans" />
                                <asp:ListItem Text="Zulu" Value="Zulu" />
                                <asp:ListItem Text="Xhosa" Value="Xhosa" />
                                <asp:ListItem Text="Sotho" Value="Sotho" />
                                <asp:ListItem Text="Tswana" Value="Tswana" />
                                <asp:ListItem Text="Tsonga" Value="Tsonga" />
                                <asp:ListItem Text="Venda" Value="Venda" />
                                <asp:ListItem Text="Ndebele" Value="Ndebele" />
                                <asp:ListItem Text="Swati" Value="Swati" />
                                <asp:ListItem Text="Other" Value="Other" />
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="form-field">
                        <label>Skills <span>*</span></label>
                        <asp:TextBox ID="txtSkills" runat="server" CssClass="form-input"
                            placeholder="e.g. Web Design, JavaScript, React" />
                    </div>

                    <div class="form-field">
                        <label>Work Experience</label>
                        <asp:TextBox ID="txtExperience" runat="server" CssClass="form-textarea"
                            TextMode="MultiLine" Rows="3" placeholder="Describe your experience..." />
                    </div>

                    <div class="form-row">
                        <div class="form-field">
                            <label>Portfolio Links</label>
                            <asp:TextBox ID="txtPortfolio" runat="server" CssClass="form-input"
                                placeholder="e.g. https://portfolio.com" />
                        </div>
                        <div class="form-field">
                            <label>Hourly Rate (ZAR) <span>*</span></label>
                            <asp:TextBox ID="txtHourlyRate" runat="server" CssClass="form-input"
                                TextMode="Number" placeholder="e.g. 250" />
                        </div>
                    </div>

                    <asp:Button ID="btnSubmitFreelancer" runat="server" Text="Create Profile"
                        CssClass="form-submit" OnClick="btnSubmitFreelancer_Click" />
                    <asp:Button ID="btnCancelFreelancer" runat="server" Text="Cancel"
                        CssClass="form-cancel" OnClick="btnCancelCreate_Click" CausesValidation="false" />
                </div>
            </asp:Panel>

            <!-- Employer Creation Form -->
            <asp:Panel ID="pnlCreateEmployer" runat="server" Visible="false">
                <div class="create-form">
                    <h3>Create Employer Profile</h3>

                    <div class="form-row">
                        <div class="form-field">
                            <label>First Name <span>*</span></label>
                            <asp:TextBox ID="txtEmployerFirstName" runat="server" CssClass="form-input"
                                placeholder="Enter your first name" />
                        </div>
                        <div class="form-field">
                            <label>Last Name <span>*</span></label>
                            <asp:TextBox ID="txtEmployerLastName" runat="server" CssClass="form-input"
                                placeholder="Enter your last name" />
                        </div>
                    </div>

                    <div class="form-field">
                        <label>Profile Picture</label>
                        <asp:FileUpload ID="fuEmployerPicture" runat="server" CssClass="form-input" />
                    </div>

                    <div class="form-field">
                        <label>Bio / About Me</label>
                        <asp:TextBox ID="txtEmployerBio" runat="server" CssClass="form-textarea"
                            TextMode="MultiLine" Rows="3" placeholder="Tell freelancers about yourself..." />
                    </div>

                    <div class="form-row">
                        <div class="form-field">
                            <label>Location / City</label>
                            <asp:TextBox ID="txtEmployerLocation" runat="server" CssClass="form-input"
                                placeholder="e.g. Cape Town, SA" />
                        </div>
                        <div class="form-field">
                            <label>Preferred Language</label>
                            <asp:DropDownList ID="ddlEmployerLanguage" runat="server" CssClass="form-input">
                                <asp:ListItem Text="Select Language" Value="" />
                                <asp:ListItem Text="English" Value="English" />
                                <asp:ListItem Text="Afrikaans" Value="Afrikaans" />
                                <asp:ListItem Text="Zulu" Value="Zulu" />
                                <asp:ListItem Text="Xhosa" Value="Xhosa" />
                                <asp:ListItem Text="Sotho" Value="Sotho" />
                                <asp:ListItem Text="Tswana" Value="Tswana" />
                                <asp:ListItem Text="Tsonga" Value="Tsonga" />
                                <asp:ListItem Text="Venda" Value="Venda" />
                                <asp:ListItem Text="Ndebele" Value="Ndebele" />
                                <asp:ListItem Text="Swati" Value="Swati" />
                                <asp:ListItem Text="Other" Value="Other" />
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="form-field">
                        <label>Company Name <span>*</span></label>
                        <asp:TextBox ID="txtCompanyName" runat="server" CssClass="form-input"
                            placeholder="Your company or business name" />
                    </div>

                    <div class="form-row">
                        <div class="form-field">
                            <label>Industry <span>*</span></label>
                            <asp:DropDownList ID="ddlIndustry" runat="server" CssClass="form-input">
                                <asp:ListItem Text="Select Industry" Value="" />
                                <asp:ListItem Text="Information Technology" Value="Information Technology" />
                                <asp:ListItem Text="Finance" Value="Finance" />
                                <asp:ListItem Text="Marketing" Value="Marketing" />
                                <asp:ListItem Text="Education" Value="Education" />
                                <asp:ListItem Text="Healthcare" Value="Healthcare" />
                                <asp:ListItem Text="Other" Value="Other" />
                            </asp:DropDownList>
                        </div>
                        <div class="form-field">
                            <label>Contact Email</label>
                            <asp:TextBox ID="txtContactEmail" runat="server" CssClass="form-input"
                                placeholder="business@example.com" />
                        </div>
                    </div>

                    <div class="form-field">
                        <label>Company Description <span>*</span></label>
                        <asp:TextBox ID="txtCompanyDesc" runat="server" CssClass="form-textarea"
                            TextMode="MultiLine" Rows="3" placeholder="What does your company do?" />
                    </div>

                    <asp:Button ID="btnSubmitEmployer" runat="server" Text="Create Profile"
                        CssClass="form-submit" OnClick="btnSubmitEmployer_Click" />
                    <asp:Button ID="btnCancelEmployer" runat="server" Text="Cancel"
                        CssClass="form-cancel" OnClick="btnCancelCreate_Click" CausesValidation="false" />
                </div>
            </asp:Panel>

        </div>
    </form>

    <!-- Modal styles (same as Site1.Master) -->
    <style>
        .fh-modal-overlay {
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.45);
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .fh-modal {
            background: white;
            border-radius: 16px;
            padding: 36px 32px 28px;
            text-align: center;
            max-width: 320px;
            width: 90%;
            box-shadow: 0 12px 40px rgba(0,0,0,0.2);
            animation: fhModalIn 0.2s ease;
        }

        @keyframes fhModalIn {
            from { transform: scale(0.9); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }

        .fh-modal-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: #e8f5e0;
            color: #173f2c;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            font-weight: bold;
            margin: 0 auto 16px;
        }

        .fh-modal h3 {
            font-size: 18px;
            color: #1a1a1a;
            margin-bottom: 8px;
            font-weight: 700;
        }

        .fh-modal p {
            font-size: 13px;
            color: #5a5a5a;
            margin-bottom: 22px;
            line-height: 1.5;
        }

        .fh-modal-btn-confirm {
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            background: #173f2c;
            color: white;
            transition: background 0.2s;
        }

        .fh-modal-btn-confirm:hover { background: #1f5438; }

        .fh-modal-btn-cancel {
            background: none;
            border: none;
            color: #5a5a5a;
            font-size: 14px;
            cursor: pointer;
            margin-top: 12px;
            padding: 8px 16px;
        }

        .fh-modal-btn-cancel:hover { color: #1a1a1a; }
    </style>

    <script type="text/javascript">
        var pendingBtn = null;

        function showReactivateConfirm(btn, role) {
            pendingBtn = btn;
            var existing = document.getElementById('fhConfirmModal');
            if (existing) existing.remove();

            var overlay = document.createElement('div');
            overlay.id = 'fhConfirmModal';
            overlay.className = 'fh-modal-overlay';
            overlay.innerHTML =
                '<div class="fh-modal">' +
                    '<div class="fh-modal-icon">?</div>' +
                    '<h3>Reactivate Profile</h3>' +
                    '<p>Are you sure you want to reactivate<br/>your ' + role + ' profile?</p>' +
                    '<button type="button" class="fh-modal-btn-confirm" id="fhConfirmYes">Yes, Reactivate</button>' +
                    '<br/><button type="button" class="fh-modal-btn-cancel" id="fhConfirmNo">Cancel</button>' +
                '</div>';

            document.body.appendChild(overlay);

            document.getElementById('fhConfirmNo').onclick = function () { overlay.remove(); };
            document.getElementById('fhConfirmYes').onclick = function () {
                overlay.remove();
                // Trigger the postback
                __doPostBack(pendingBtn.name, '');
            };

            overlay.onclick = function(e) { if (e.target === overlay) overlay.remove(); };

            return false;
        }

        // Update progress indicator when create form is visible (Step 3)
        (function() {
            var freelancerForm = document.getElementById('<%= pnlCreateFreelancer.ClientID %>');
            var employerForm = document.getElementById('<%= pnlCreateEmployer.ClientID %>');
            
            if ((freelancerForm && freelancerForm.style.display !== 'none' && freelancerForm.offsetParent !== null) ||
                (employerForm && employerForm.style.display !== 'none' && employerForm.offsetParent !== null)) {
                // Move to step 3
                var steps = document.querySelectorAll('.step');
                var lines = document.querySelectorAll('.step-line');
                if (steps.length >= 3 && lines.length >= 2) {
                    steps[1].className = 'step completed';
                    steps[1].querySelector('.step-circle').innerHTML = '&#10003;';
                    lines[1].className = 'step-line completed';
                    steps[2].className = 'step active';
                }
            }
        })();
    </script>
</body>
</html>

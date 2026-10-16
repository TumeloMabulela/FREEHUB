<%@ Page Title="My Profile - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="ManageProfile.aspx.cs"
    Inherits="FreeHubProject.ManageProfile" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <style type="text/css">
        /* ===== Profile page: fixed-middle layout (matches SelectProposal). Scoped via
           .mp2-* so no other page is affected. The main content is a NON-scrolling flex
           column; breadcrumb/heading stay fixed; the two-column region fills the rest; and
           only the Profile Details card BODY scrolls. The right-column Actions + Privacy
           cards are stationary. Reuses FreeHUB colours, white cards, green buttons. ===== */
        .freehub-main-content.mp2-main {
            height: 100%; min-height: 0; display: flex; flex-direction: column; overflow: hidden;
        }
        .mp2-main .post-page-heading,
        .mp2-main .post-status { flex: 0 0 auto; }

        .mp2-layout {
            display: grid; grid-template-columns: minmax(0, 70fr) minmax(0, 30fr); gap: 22px;
            align-items: stretch; flex: 1 1 auto; min-height: 0;
        }

        /* Generic card shell. */
        .mp2-card {
            background: #fff; border: 1px solid #e8ece9; border-radius: 14px;
            box-shadow: 0 1px 3px rgba(16,40,28,0.06);
            display: flex; flex-direction: column; min-height: 0;
        }
        .mp2-card-head {
            flex: 0 0 auto; padding: 20px 24px 14px; border-bottom: 1px solid #f0f3f1;
        }
        .mp2-card-head h2 { margin: 0; font-size: 18px; font-weight: 700; color: #173f2c; }
        .mp2-card-head p { margin: 4px 0 0; font-size: 13px; color: #7b878d; }

        /* LEFT: Profile Details — heading fixed, this body is the ONLY scroller. */
        .mp2-details-body {
            flex: 1 1 auto; min-height: 0; overflow-y: auto; overflow-x: hidden;
            padding: 18px 24px 22px;
            scrollbar-width: thin; scrollbar-color: #2e7d56 #eef3ef;
        }
        .mp2-details-body::-webkit-scrollbar { width: 8px; }
        .mp2-details-body::-webkit-scrollbar-track { background: #eef3ef; border-radius: 8px; }
        .mp2-details-body::-webkit-scrollbar-thumb { background: linear-gradient(180deg, #2e7d56, #72c94b); border-radius: 8px; border: 2px solid #eef3ef; }

        /* Identity row — now in its own stationary section (flex-shrink:0) between the
           card heading and the scrollable body, with the divider below it. */
        .mp2-identity-fixed { flex: 0 0 auto; padding: 18px 24px; border-bottom: 1px solid #f0f3f1; }
        .mp2-identity { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
        .mp2-avatar {
            width: 54px; height: 54px; border-radius: 50%; flex-shrink: 0;
            background: #2e7d56; color: #fff; display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 18px;
        }
        .mp2-identity-name { font-size: 18px; font-weight: 700; color: #10261c; }
        .mp2-role-badge { display: inline-block; background: #e8f5e0; color: #2d6b3f; padding: 4px 12px; border-radius: 12px; font-size: 12.5px; font-weight: 700; }
        .mp2-status-badge { display: inline-flex; align-items: center; gap: 6px; padding: 4px 12px; border-radius: 12px; font-size: 12.5px; font-weight: 700; }
        .mp2-status-active   { background: #e5f4ea; color: #1e7a46; }
        .mp2-status-inactive { background: #fef3c7; color: #b45309; }
        .mp2-status-default  { background: #eef2f5; color: #4b5563; }
        .mp2-status-dot { width: 8px; height: 8px; border-radius: 50%; background: currentColor; }

        /* Section groups + read-only field grid */
        .mp2-section-title { font-size: 15px; font-weight: 700; color: #173f2c; margin: 22px 0 12px; }
        .mp2-section-title:first-of-type { margin-top: 0; }
        /* Extra separation between Personal Information and the company/freelancer section:
           ~28px gap applied to the section container (its inner title's top margin is
           neutralised so the gap doesn't compound). Inter-field spacing is unchanged. */
        .mp2-section-gap { margin-top: 28px; }
        .mp2-section-gap > .mp2-section-title { margin-top: 0; }
        .mp2-field-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px 24px; }
        .mp2-field { min-width: 0; }
        .mp2-field.mp2-field-full { grid-column: 1 / -1; }
        .mp2-field-label { font-size: 12px; color: #8a949a; margin-bottom: 3px; }
        .mp2-field-value { font-size: 14px; color: #243328; overflow-wrap: anywhere; white-space: pre-line; line-height: 1.55; }
        .mp2-field-value.muted { color: #9aa6a0; font-style: italic; }

        /* RIGHT column: Actions + Privacy stacked, stationary, top-aligned. */
        .mp2-side { display: flex; flex-direction: column; gap: 18px; align-self: start; min-height: 0; }
        .mp2-actions-body { padding: 18px 20px 20px; }
        .mp2-act-btn {
            display: flex; align-items: center; justify-content: center; gap: 8px;
            width: 100%; height: 44px; border-radius: 8px; font-size: 14px; font-weight: 700;
            cursor: pointer; text-decoration: none; border: 1.5px solid transparent;
            margin-bottom: 12px; box-sizing: border-box; font-family: inherit;
        }
        .mp2-act-btn:last-child { margin-bottom: 0; }
        .mp2-act-primary { background: #0f7a44; color: #fff; border-color: #0f7a44; }
        .mp2-act-primary:hover { background: #0c6639; }
        .mp2-act-warn { background: #fff; color: #b45309; border-color: #e0a53f; }
        .mp2-act-warn:hover { background: #fff8ec; }
        .mp2-act-danger { background: #fff; color: #dc2626; border-color: #e8a4a4; }
        .mp2-act-danger:hover { background: #fdecec; }
        .mp2-actions-note { border-top: 1px solid #f0f3f1; margin-top: 16px; padding-top: 14px; }
        .mp2-actions-note p { margin: 0 0 8px; font-size: 12.5px; color: #64748b; line-height: 1.5; }
        .mp2-actions-note p:last-child { margin-bottom: 0; }

        /* Privacy card */
        .mp2-privacy { display: flex; gap: 14px; padding: 18px 20px; align-items: flex-start; }
        .mp2-privacy-icon { width: 40px; height: 40px; border-radius: 50%; flex-shrink: 0; background: #e3f3e9; color: #0f7a44; display: flex; align-items: center; justify-content: center; font-size: 18px; }
        .mp2-privacy h3 { margin: 0 0 4px; font-size: 15px; font-weight: 700; color: #173f2c; }
        .mp2-privacy p { margin: 0; font-size: 12.5px; color: #64748b; line-height: 1.5; }

        /* Edit / deactivation mode cards fill the available height and scroll internally. */
        .mp2-mode-card { flex: 1 1 auto; min-height: 0; }
        .mp2-mode-body { flex: 1 1 auto; min-height: 0; overflow-y: auto; overflow-x: hidden; padding: 18px 24px 22px;
            scrollbar-width: thin; scrollbar-color: #2e7d56 #eef3ef; }
        .mp2-mode-body::-webkit-scrollbar { width: 8px; }
        .mp2-mode-body::-webkit-scrollbar-track { background: #eef3ef; border-radius: 8px; }
        .mp2-mode-body::-webkit-scrollbar-thumb { background: linear-gradient(180deg, #2e7d56, #72c94b); border-radius: 8px; border: 2px solid #eef3ef; }
        .mp2-mode-actions { flex: 0 0 auto; display: flex; gap: 12px; padding: 14px 24px; border-top: 1px solid #f0f3f1; }

        /* Required-field marker + note (edit form only). */
        .mp2-req { color: #dc2626; font-weight: 700; }
        .mp2-required-note { margin: 0 0 16px; font-size: 12.5px; color: #64748b; }

        @media (max-width: 900px) {
            .freehub-main-content.mp2-main { height: auto; overflow: visible; display: block; }
            .mp2-layout { grid-template-columns: 1fr; display: grid; flex: none; }
            .mp2-details-body, .mp2-mode-body { max-height: 60vh; }
            .mp2-side { align-self: auto; }
            .mp2-field-grid { grid-template-columns: 1fr; }
        }
    </style>

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content mp2-main">

            <!-- BREADCRUMB & HEADING (static) -->
            <div class="post-page-heading">
                <div class="post-breadcrumb">
                    <a href="<%= ResolveUrl("~/Dashboard.aspx") %>" class="breadcrumb-link">Dashboard</a> <span>/</span>
                    <strong>Profile</strong>
                </div>
                <h1>My Profile</h1>
                <p>View your personal information and <asp:Literal ID="litRoleWord" runat="server" Text="employer" /> details.</p>
            </div>

            <!-- MESSAGE (kept for compatibility; action results use the global popup) -->
            <asp:Panel ID="pnlMessage" runat="server" CssClass="post-status" Visible="false">
                <asp:Label ID="lblMessage" runat="server" />
            </asp:Panel>

            <div class="mp2-layout">

                <!-- ======================= LEFT COLUMN ======================= -->
                <!-- READ-ONLY OVERVIEW (default) -->
                <asp:Panel ID="pnlOverview" runat="server" CssClass="mp2-card">
                    <div class="mp2-card-head"><h2>Profile Details</h2></div>

                    <!-- Identity row: stationary (does NOT scroll); sits between the card
                         heading and the scrollable details body. -->
                    <div class="mp2-identity-fixed">
                        <div class="mp2-identity">
                            <div class="mp2-avatar"><asp:Literal ID="litInitials" runat="server" /></div>
                            <div style="display:flex; align-items:center; gap:12px; flex-wrap:wrap;">
                                <span class="mp2-identity-name"><asp:Literal ID="litFullName" runat="server" /></span>
                                <span class="mp2-role-badge"><asp:Literal ID="litRoleBadge" runat="server" /></span>
                                <asp:Literal ID="litStatusBadge" runat="server" />
                            </div>
                        </div>
                    </div>

                    <!-- Only the information below the identity row scrolls. -->
                    <div class="mp2-details-body">

                        <!-- Personal Information -->
                        <div class="mp2-section-title">Personal Information</div>
                        <div class="mp2-field-grid">
                            <div class="mp2-field">
                                <div class="mp2-field-label">First Name</div>
                                <div class="mp2-field-value"><asp:Literal ID="litFirstNameVal" runat="server" /></div>
                            </div>
                            <div class="mp2-field">
                                <div class="mp2-field-label">Last Name</div>
                                <div class="mp2-field-value"><asp:Literal ID="litLastNameVal" runat="server" /></div>
                            </div>
                            <div class="mp2-field">
                                <div class="mp2-field-label">Email Address</div>
                                <div class="mp2-field-value"><asp:Literal ID="litEmailVal" runat="server" /></div>
                            </div>
                            <div class="mp2-field">
                                <div class="mp2-field-label">Contact Number</div>
                                <div class="mp2-field-value"><asp:Literal ID="litContactVal" runat="server" /></div>
                            </div>
                        </div>

                        <!-- Employer Details (read-only) -->
                        <asp:Panel ID="pnlEmployerView" runat="server" Visible="false" CssClass="mp2-section-gap">
                            <div class="mp2-section-title">Employer Details</div>
                            <div class="mp2-field-grid">
                                <div class="mp2-field">
                                    <div class="mp2-field-label">Company Name</div>
                                    <div class="mp2-field-value"><asp:Literal ID="litCompanyVal" runat="server" /></div>
                                </div>
                                <div class="mp2-field">
                                    <div class="mp2-field-label">Industry</div>
                                    <div class="mp2-field-value"><asp:Literal ID="litIndustryVal" runat="server" /></div>
                                </div>
                                <div class="mp2-field mp2-field-full">
                                    <div class="mp2-field-label">Company Description</div>
                                    <div class="mp2-field-value"><asp:Literal ID="litCompanyDescVal" runat="server" /></div>
                                </div>
                            </div>
                        </asp:Panel>

                        <!-- Freelancer Details (read-only) -->
                        <asp:Panel ID="pnlFreelancerView" runat="server" Visible="false" CssClass="mp2-section-gap">
                            <div class="mp2-section-title">Freelancer Details</div>
                            <div class="mp2-field-grid">
                                <div class="mp2-field mp2-field-full">
                                    <div class="mp2-field-label">Skills</div>
                                    <div class="mp2-field-value"><asp:Literal ID="litSkillsVal" runat="server" /></div>
                                </div>
                                <div class="mp2-field mp2-field-full">
                                    <div class="mp2-field-label">Work Experience</div>
                                    <div class="mp2-field-value"><asp:Literal ID="litExperienceVal" runat="server" /></div>
                                </div>
                                <div class="mp2-field">
                                    <div class="mp2-field-label">Portfolio Links</div>
                                    <div class="mp2-field-value"><asp:Literal ID="litPortfolioVal" runat="server" /></div>
                                </div>
                                <div class="mp2-field">
                                    <div class="mp2-field-label">Hourly Rate (ZAR)</div>
                                    <div class="mp2-field-value"><asp:Literal ID="litRateVal" runat="server" /></div>
                                </div>
                            </div>
                        </asp:Panel>

                    </div>
                </asp:Panel>

                <!-- EDIT MODE: Update Profile (existing fields/IDs/handlers preserved) -->
                <asp:Panel ID="pnlUpdateProfile" runat="server" Visible="false" CssClass="mp2-card mp2-mode-card">
                    <div class="mp2-card-head">
                        <h2>Update Profile</h2>
                        <p>Keep your information up to date.</p>
                    </div>
                    <div class="mp2-mode-body">

                        <!-- Required-fields note (fields marked * below are server-validated). -->
                        <p class="mp2-required-note">Fields marked with <span class="mp2-req">*</span> are required.</p>

                        <div class="post-two-columns">
                            <div class="post-field">
                                <div class="label-row"><label>First Name <span class="mp2-req">*</span></label>
                                    <asp:Label ID="lblErrFirstName" runat="server" CssClass="field-error" EnableViewState="false" /></div>
                                <asp:TextBox ID="txtFirstName" runat="server" CssClass="post-input" required="required" aria-required="true" />
                            </div>
                            <div class="post-field">
                                <div class="label-row"><label>Last Name <span class="mp2-req">*</span></label>
                                    <asp:Label ID="lblErrLastName" runat="server" CssClass="field-error" EnableViewState="false" /></div>
                                <asp:TextBox ID="txtLastName" runat="server" CssClass="post-input" required="required" aria-required="true" />
                            </div>
                        </div>

                        <div class="post-field">
                            <label>Email Address</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="post-input" ReadOnly="true" />
                        </div>

                        <div class="post-field">
                            <label>Contact Number</label>
                            <asp:TextBox ID="txtContactNumber" runat="server" CssClass="post-input"
                                placeholder="e.g. 0712345678" />
                        </div>

                        <!-- Freelancer-specific fields -->
                        <asp:Panel ID="pnlFreelancerFields" runat="server" Visible="false">
                            <h3 style="margin-top:20px; margin-bottom:10px; color:#173f2c;">Freelancer Details</h3>

                            <div class="post-field">
                                <div class="label-row"><label>Skills <span class="mp2-req">*</span></label>
                                    <asp:Label ID="lblErrSkills" runat="server" CssClass="field-error" EnableViewState="false" /></div>
                                <asp:TextBox ID="txtUpdateSkills" runat="server" CssClass="post-input"
                                    placeholder="e.g. Web Design, JavaScript, React" required="required" aria-required="true" />
                            </div>

                            <div class="post-field">
                                <div class="label-row"><label>Work Experience <span class="mp2-req">*</span></label>
                                    <asp:Label ID="lblErrExperience" runat="server" CssClass="field-error" EnableViewState="false" /></div>
                                <asp:TextBox ID="txtUpdateExperience" runat="server" CssClass="post-textarea"
                                    TextMode="MultiLine" Rows="4" data-fh-format="true" required="required" aria-required="true" />
                                <div class="field-footer">
                                    <span class="field-hint">30&#8211;700 characters</span>
                                </div>
                            </div>

                            <div class="post-field">
                                <div class="label-row"><label>Portfolio Links <span class="mp2-req">*</span></label>
                                    <asp:Label ID="lblErrPortfolio" runat="server" CssClass="field-error" EnableViewState="false" /></div>
                                <asp:TextBox ID="txtUpdatePortfolio" runat="server" CssClass="post-input" required="required" aria-required="true" />
                            </div>

                            <div class="post-field">
                                <div class="label-row"><label>Hourly Rate (ZAR) <span class="mp2-req">*</span></label>
                                    <asp:Label ID="lblErrRate" runat="server" CssClass="field-error" EnableViewState="false" /></div>
                                <div class="hr-rate-wrap">
                                    <span class="hr-rate-prefix">R</span>
                                    <asp:TextBox ID="txtUpdateRate" runat="server" CssClass="post-input hr-rate-input"
                                        MaxLength="4" inputmode="numeric" pattern="[0-9]*" required="required" aria-required="true" />
                                </div>
                                <small class="hr-rate-help">Digits only. Maximum hourly rate: R2 000.</small>
                            </div>
                        </asp:Panel>

                        <!-- Employer-specific fields -->
                        <asp:Panel ID="pnlEmployerFields" runat="server" Visible="false">
                            <h3 style="margin-top:20px; margin-bottom:10px; color:#173f2c;">Employer Details</h3>

                            <div class="post-field">
                                <div class="label-row"><label>Company Name <span class="mp2-req">*</span></label>
                                    <asp:Label ID="lblErrCompany" runat="server" CssClass="field-error" EnableViewState="false" /></div>
                                <asp:TextBox ID="txtUpdateCompanyName" runat="server" CssClass="post-input" required="required" aria-required="true" />
                            </div>

                            <div class="post-field">
                                <div class="label-row"><label>Industry <span class="mp2-req">*</span></label>
                                    <asp:Label ID="lblErrIndustry" runat="server" CssClass="field-error" EnableViewState="false" /></div>
                                <asp:DropDownList ID="ddlUpdateIndustry" runat="server" CssClass="post-input" aria-required="true">
                                    <asp:ListItem Text="Select Industry" Value="" />
                                    <asp:ListItem Text="Information Technology" Value="Information Technology" />
                                    <asp:ListItem Text="Finance" Value="Finance" />
                                    <asp:ListItem Text="Marketing" Value="Marketing" />
                                    <asp:ListItem Text="Education" Value="Education" />
                                    <asp:ListItem Text="Healthcare" Value="Healthcare" />
                                    <asp:ListItem Text="Other" Value="Other" />
                                </asp:DropDownList>
                            </div>

                            <div class="post-field">
                                <div class="label-row"><label>Company Description <span class="mp2-req">*</span></label>
                                    <asp:Label ID="lblErrDescription" runat="server" CssClass="field-error" EnableViewState="false" /></div>
                                <asp:TextBox ID="txtUpdateDescription" runat="server" CssClass="post-textarea"
                                    TextMode="MultiLine" Rows="4" data-fh-format="true" required="required" aria-required="true" />
                                <div class="field-footer">
                                    <span class="field-hint">30&#8211;700 characters</span>
                                </div>
                            </div>
                        </asp:Panel>

                    </div>
                    <div class="mp2-mode-actions">
                        <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel"
                            CssClass="post-cancel-button" CausesValidation="false" OnClick="btnCancelEdit_Click" />
                        <asp:Button ID="btnSaveProfile" runat="server" Text="&#9998; Save Changes"
                            CssClass="post-submit-button" OnClick="btnSaveProfile_Click" />
                    </div>
                </asp:Panel>

                <!-- DEACTIVATE PROFILE MODE (existing checkbox + modal + handler preserved) -->
                <asp:Panel ID="pnlDeactivateProfile" runat="server" Visible="false" CssClass="mp2-card mp2-mode-card">
                    <div class="mp2-card-head">
                        <h2>Deactivate <asp:Literal ID="litHeadingRole" runat="server" /> Profile</h2>
                        <p>Deactivating your <asp:Literal ID="litSubtitleRole" runat="server" /> profile will hide it from other users. You can reactivate it anytime.</p>
                    </div>
                    <div class="mp2-mode-body">
                        <div class="deactivate-warning">
                            <strong>This action will:</strong>
                            <ul>
                                <li>Hide your profile from search results</li>
                                <li>Pause ongoing proposals</li>
                                <li>Prevent new job offers</li>
                                <li>Keep your account and data safe</li>
                            </ul>
                        </div>
                        <div class="post-field">
                            <asp:CheckBox ID="chkConfirmDeactivateProfile" runat="server"
                                onclick="toggleDeactivateProfileBtn();" />
                            <label style="display:inline; margin-left:8px;">
                                Yes, I understand the consequences of deactivating my profile.
                            </label>
                        </div>
                    </div>
                    <div class="mp2-mode-actions">
                        <asp:Button ID="btnCancelDeactivateProfile" runat="server" Text="Cancel"
                            CssClass="post-cancel-button" CausesValidation="false" OnClick="btnCancelEdit_Click" />
                        <asp:Button ID="btnDeactivateProfile" runat="server" Text="&#9888; Deactivate Profile"
                            CssClass="deactivate-button"
                            style="opacity:0.5; cursor:not-allowed;"
                            OnClientClick="return showDeactivateProfileModal();"
                            OnClick="btnDeactivateProfile_Click" />
                    </div>
                </asp:Panel>

                <!-- DEACTIVATE ACCOUNT MODE (existing checkbox + modal + handler preserved) -->
                <asp:Panel ID="pnlDeactivateAccount" runat="server" Visible="false" CssClass="mp2-card mp2-mode-card">
                    <div class="mp2-card-head">
                        <h2>Deactivate Account</h2>
                        <p>Deactivating your account will disable access to FreeHUB. You can reactivate it anytime by logging in.</p>
                    </div>
                    <div class="mp2-mode-body">
                        <div class="deactivate-warning deactivate-danger">
                            <strong>This action will:</strong>
                            <ul>
                                <li>Disable your account access</li>
                                <li>Hide your profile and data from others</li>
                                <li>Cancel ongoing activities</li>
                                <li>Keep your data safe for reactivation</li>
                            </ul>
                        </div>
                        <div class="post-field">
                            <asp:CheckBox ID="chkConfirmDeactivateAccount" runat="server"
                                onclick="toggleDeactivateAccountBtn();" />
                            <label style="display:inline; margin-left:8px;">
                                Yes, I understand the consequences of deactivating my account.
                            </label>
                        </div>
                    </div>
                    <div class="mp2-mode-actions">
                        <asp:Button ID="btnCancelDeactivateAccount" runat="server" Text="Cancel"
                            CssClass="post-cancel-button" CausesValidation="false" OnClick="btnCancelEdit_Click" />
                        <asp:Button ID="btnDeactivateAccount" runat="server" Text="&#9888; Deactivate Account"
                            CssClass="deactivate-button deactivate-account-button"
                            style="opacity:0.5; cursor:not-allowed;"
                            OnClientClick="return showDeactivateAccountModal();"
                            OnClick="btnDeactivateAccount_Click" />
                    </div>
                </asp:Panel>

                <!-- ======================= RIGHT COLUMN ======================= -->
                <div class="mp2-side">

                    <!-- Profile Actions -->
                    <div class="mp2-card">
                        <div class="mp2-card-head">
                            <h2>Profile Actions</h2>
                            <p>Manage your profile and account.</p>
                        </div>
                        <div class="mp2-actions-body">
                            <asp:Button ID="btnActUpdate" runat="server" Text="&#9998; Update Profile"
                                CssClass="mp2-act-btn mp2-act-primary" CausesValidation="false" OnClick="btnActUpdate_Click" />
                            <asp:Button ID="btnActDeactivateProfile" runat="server" Text="&#8856; Deactivate Profile"
                                CssClass="mp2-act-btn mp2-act-warn" CausesValidation="false" OnClick="btnActDeactivateProfile_Click" />
                            <asp:Button ID="btnActDeactivateAccount" runat="server" Text="&#8856; Deactivate Account"
                                CssClass="mp2-act-btn mp2-act-danger" CausesValidation="false" OnClick="btnActDeactivateAccount_Click" />

                            <div class="mp2-actions-note">
                                <p><strong>Deactivate Profile</strong> affects your current role profile.</p>
                                <p><strong>Deactivate Account</strong> affects your entire FreeHUB account.</p>
                            </div>
                        </div>
                    </div>

                    <!-- Privacy -->
                    <div class="mp2-card">
                        <div class="mp2-privacy">
                            <div class="mp2-privacy-icon" aria-hidden="true">&#128737;</div>
                            <div>
                                <h3>Privacy</h3>
                                <p>Your contact details are shown here for your account management.</p>
                            </div>
                        </div>
                    </div>

                </div>

            </div>

        </section>

    </div>

    <script type="text/javascript">
        var currentUserRole = '<%= Session["UserType"] as string ?? "User" %>';

        function toggleDeactivateProfileBtn() {
            var chk = document.getElementById('<%= chkConfirmDeactivateProfile.ClientID %>');
            var btn = document.getElementById('<%= btnDeactivateProfile.ClientID %>');
            if (!chk || !btn) return;
            if (chk.checked) { btn.style.opacity = '1'; btn.style.cursor = 'pointer'; }
            else { btn.style.opacity = '0.5'; btn.style.cursor = 'not-allowed'; }
        }

        function toggleDeactivateAccountBtn() {
            var chk = document.getElementById('<%= chkConfirmDeactivateAccount.ClientID %>');
            var btn = document.getElementById('<%= btnDeactivateAccount.ClientID %>');
            if (!chk || !btn) return;
            if (chk.checked) { btn.style.opacity = '1'; btn.style.cursor = 'pointer'; }
            else { btn.style.opacity = '0.5'; btn.style.cursor = 'not-allowed'; }
        }

        function showDeactivateProfileModal() {
            var chk = document.getElementById('<%= chkConfirmDeactivateProfile.ClientID %>');
            if (!chk.checked) {
                fhAlert('Please tick the checkbox to confirm you understand the consequences.', 'Confirmation Required');
                return false;
            }
            var existing = document.getElementById('fhDeactivateModal');
            if (existing) existing.remove();

            var title, message;
            if (currentUserRole === 'Freelancer') {
                title = 'Deactivate Freelancer Profile';
                message = 'Your freelancer reputation takes time to build. Employers trust profiles with proven track records and strong ratings.<br/><br/>' +
                    'If you deactivate now, your proposals will be withdrawn and employers will not be able to discover your skills.<br/><br/>' +
                    '<strong>Are you sure you want to give up your visibility?</strong>';
            } else {
                title = 'Deactivate Employer Profile';
                message = 'Talented freelancers are actively looking at your projects right now. Deactivating means your open listings will be cancelled and you will lose potential candidates.<br/><br/>' +
                    'Your project history and team connections will be paused until you return.<br/><br/>' +
                    '<strong>Are you sure you want to stop hiring?</strong>';
            }

            var overlay = document.createElement('div');
            overlay.id = 'fhDeactivateModal';
            overlay.className = 'fh-modal-overlay';
            overlay.innerHTML =
                '<div class="fh-modal">' +
                    '<div class="fh-modal-icon" style="background:#fef3c7; color:#b45309;">&#8856;</div>' +
                    '<h3>' + title + '</h3>' +
                    '<p>' + message + '</p>' +
                    '<button type="button" class="fh-modal-btn-primary" id="fhDeactivateYes">Yes, Deactivate</button>' +
                    '<br/><button type="button" class="fh-modal-btn-cancel" id="fhDeactivateNo">No, keep my profile</button>' +
                '</div>';

            document.body.appendChild(overlay);
            document.getElementById('fhDeactivateNo').onclick = function () { overlay.remove(); };
            document.getElementById('fhDeactivateYes').onclick = function () {
                overlay.remove();
                __doPostBack('<%= btnDeactivateProfile.UniqueID %>', '');
            };
            overlay.onclick = function (e) { if (e.target === overlay) overlay.remove(); };
            return false;
        }

        function showDeactivateAccountModal() {
            var chk = document.getElementById('<%= chkConfirmDeactivateAccount.ClientID %>');
            if (!chk.checked) {
                fhAlert('Please tick the checkbox to confirm you understand the consequences.', 'Confirmation Required');
                return false;
            }
            var existing = document.getElementById('fhDeleteModal');
            if (existing) existing.remove();

            var overlay = document.createElement('div');
            overlay.id = 'fhDeleteModal';
            overlay.className = 'fh-modal-overlay';
            overlay.innerHTML =
                '<div class="fh-modal">' +
                    '<div class="fh-modal-icon" style="background:#fee2e2; color:#dc2626;">&#8856;</div>' +
                    '<h3>Wait, are you sure?</h3>' +
                    '<p>Your FreeHUB account holds your entire history: your reputation, ratings, wallet balance, and professional connections.<br/><br/>' +
                    'Once deactivated, all your projects will be cancelled, your wallet will be frozen, and you will be logged out immediately.<br/><br/>' +
                    '<strong>You can always take a break by deactivating just your profile instead.</strong><br/><br/>' +
                    '<span style="color:#dc2626; font-weight:600;">Do you still want to deactivate your entire account?</span></p>' +
                    '<button type="button" class="fh-modal-btn-primary" id="fhDeleteYes">Yes, Deactivate Account</button>' +
                    '<br/><button type="button" class="fh-modal-btn-cancel" id="fhDeleteNo">No, keep my account</button>' +
                '</div>';

            document.body.appendChild(overlay);
            document.getElementById('fhDeleteNo').onclick = function () { overlay.remove(); };
            document.getElementById('fhDeleteYes').onclick = function () {
                overlay.remove();
                __doPostBack('<%= btnDeactivateAccount.UniqueID %>', '');
            };
            overlay.onclick = function (e) { if (e.target === overlay) overlay.remove(); };
            return false;
        }
    </script>

    <%-- Shared paragraph-formatting helper (same as Project Description). --%>
    <script src="<%= ResolveUrl("~/fhText.js") %>?v=1" type="text/javascript"></script>

</asp:Content>

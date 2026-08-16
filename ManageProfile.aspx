<%@ Page Title="Manage Profile - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="ManageProfile.aspx.cs"
    Inherits="FreeHubProject.ManageProfile" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <div class="profile-manage-page">

                <div class="post-page-heading">
                    <div class="post-breadcrumb">
                        Dashboard <span>/</span> Settings <span>/</span> Manage Profile
                    </div>
                    <h1>Manage Profile</h1>
                    <p>Update your information, deactivate your profile or account.</p>
                    <p style="margin-top:10px; font-size:15px; color:#243328;">
                        Currently logged in as:
                        <span style="display:inline-block; background:#e8f5e0; color:#173f2c; padding:5px 16px; border-radius:12px; font-weight:700; font-size:14px;">
                            <asp:Literal ID="litLoggedInRole" runat="server" />
                        </span>
                    </p>
                </div>

                <!-- MESSAGE -->
                <asp:Panel ID="pnlMessage" runat="server" CssClass="post-status" Visible="false">
                    <asp:Label ID="lblMessage" runat="server" />
                </asp:Panel>

                <!-- TABS -->
                <div class="profile-tabs">
                    <asp:Button ID="btnTabUpdate" runat="server" Text="Update Profile"
                        CssClass="profile-tab active-tab" OnClick="btnTabUpdate_Click" CausesValidation="false" />
                    <asp:Button ID="btnTabDeactivateProfile" runat="server" Text="Deactivate Profile"
                        CssClass="profile-tab" OnClick="btnTabDeactivateProfile_Click" CausesValidation="false" />
                    <asp:Button ID="btnTabDeactivateAccount" runat="server" Text="Deactivate Account"
                        CssClass="profile-tab" OnClick="btnTabDeactivateAccount_Click" CausesValidation="false" />
                </div>

                <!-- A500: UPDATE PROFILE -->
                <asp:Panel ID="pnlUpdateProfile" runat="server" CssClass="profile-section">
                    <h2>Update Profile</h2>
                    <p>Keep your information up to date.</p>

                    <div class="post-two-columns">
                        <div class="post-field">
                            <label>First Name <span>*</span></label>
                            <asp:TextBox ID="txtFirstName" runat="server" CssClass="post-input" />
                        </div>
                        <div class="post-field">
                            <label>Last Name <span>*</span></label>
                            <asp:TextBox ID="txtLastName" runat="server" CssClass="post-input" />
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
                            <label>Skills <span>*</span></label>
                            <asp:TextBox ID="txtUpdateSkills" runat="server" CssClass="post-input"
                                placeholder="e.g. Web Design, JavaScript, React" />
                        </div>

                        <div class="post-field">
                            <label>Work Experience</label>
                            <asp:TextBox ID="txtUpdateExperience" runat="server" CssClass="post-textarea"
                                TextMode="MultiLine" Rows="4" />
                        </div>

                        <div class="post-field">
                            <label>Portfolio Links</label>
                            <asp:TextBox ID="txtUpdatePortfolio" runat="server" CssClass="post-input" />
                        </div>

                        <div class="post-field">
                            <label>Hourly Rate (ZAR)</label>
                            <asp:TextBox ID="txtUpdateRate" runat="server" CssClass="post-input" TextMode="Number" />
                        </div>
                    </asp:Panel>

                    <!-- Employer-specific fields -->
                    <asp:Panel ID="pnlEmployerFields" runat="server" Visible="false">
                        <h3 style="margin-top:20px; margin-bottom:10px; color:#173f2c;">Employer Details</h3>

                        <div class="post-field">
                            <label>Company Name <span>*</span></label>
                            <asp:TextBox ID="txtUpdateCompanyName" runat="server" CssClass="post-input" />
                        </div>

                        <div class="post-field">
                            <label>Industry</label>
                            <asp:DropDownList ID="ddlUpdateIndustry" runat="server" CssClass="post-input">
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
                            <label>Company Description</label>
                            <asp:TextBox ID="txtUpdateDescription" runat="server" CssClass="post-textarea"
                                TextMode="MultiLine" Rows="4" />
                        </div>
                    </asp:Panel>

                    <asp:Button ID="btnSaveProfile" runat="server" Text="Save Changes"
                        CssClass="post-submit-button" OnClick="btnSaveProfile_Click" />
                </asp:Panel>

                <!-- A400: DEACTIVATE PROFILE -->
                <asp:Panel ID="pnlDeactivateProfile" runat="server" CssClass="profile-section" Visible="false">
                    <h2>Deactivate <asp:Literal ID="litHeadingRole" runat="server" /> Profile</h2>
                    <p>Deactivating your <asp:Literal ID="litSubtitleRole" runat="server" /> profile will hide it from other users. You can reactivate it anytime.</p>

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

                    <asp:Button ID="btnDeactivateProfile" runat="server" Text="Deactivate Profile"
                        CssClass="deactivate-button"
                        style="opacity:0.5; cursor:not-allowed;"
                        OnClientClick="return showDeactivateProfileModal();"
                        OnClick="btnDeactivateProfile_Click" />
                </asp:Panel>

                <!-- A600: DEACTIVATE ACCOUNT -->
                <asp:Panel ID="pnlDeactivateAccount" runat="server" CssClass="profile-section" Visible="false">
                    <h2>Deactivate Account</h2>
                    <p>Deactivating your account will disable access to FreeHUB. You can reactivate it anytime by logging in.</p>

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

                    <asp:Button ID="btnDeactivateAccount" runat="server" Text="Deactivate Account"
                        CssClass="deactivate-button deactivate-account-button"
                        style="opacity:0.5; cursor:not-allowed;"
                        OnClientClick="return showDeactivateAccountModal();"
                        OnClick="btnDeactivateAccount_Click" />
                </asp:Panel>

            </div>

        </section>

    </div>

    <script type="text/javascript">
        var currentUserRole = '<%= Session["UserType"] as string ?? "User" %>';

        function toggleDeactivateProfileBtn() {
            var chk = document.getElementById('<%= chkConfirmDeactivateProfile.ClientID %>');
            var btn = document.getElementById('<%= btnDeactivateProfile.ClientID %>');
            if (chk.checked) {
                btn.style.opacity = '1';
                btn.style.cursor = 'pointer';
            } else {
                btn.style.opacity = '0.5';
                btn.style.cursor = 'not-allowed';
            }
        }

        }

        function toggleDeactivateAccountBtn() {
            var chk = document.getElementById('<%= chkConfirmDeactivateAccount.ClientID %>');
            var btn = document.getElementById('<%= btnDeactivateAccount.ClientID %>');
        function showDeactivateProfileModal() {
            // Check checkbox first
            var chk = document.getElementById('<%= chkConfirmDeactivateProfile.ClientID %>');
            if (!chk.checked) {
                alert('Please tick the checkbox to confirm you understand the consequences.');
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
                    '<div class="fh-modal-icon" style="background:#fee2e2; color:#dc2626;">&#9888;</div>' +
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
            overlay.onclick = function(e) { if (e.target === overlay) overlay.remove(); };
            return false;
        }

            overlay.onclick = function(e) { if (e.target === overlay) overlay.remove(); };
            return false;
        }

        function showDeactivateAccountModal() {
            var chk = document.getElementById('<%= chkConfirmDeactivateAccount.ClientID %>');
        function showDeactivateAccountModal() {
            var chk = document.getElementById('<%= chkConfirmDeactivateAccount.ClientID %>');
            if (!chk.checked) {
                alert('Please tick the checkbox to confirm you understand the consequences.');
                return false;
            }

            var existing = document.getElementById('fhDeleteModal');
            if (existing) existing.remove();

            var overlay = document.createElement('div');
            overlay.id = 'fhDeleteModal';
            overlay.className = 'fh-modal-overlay';
            overlay.innerHTML =
                '<div class="fh-modal">' +
                    '<div class="fh-modal-icon" style="background:#fee2e2; color:#dc2626;">&#9888;</div>' +
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
            overlay.onclick = function(e) { if (e.target === overlay) overlay.remove(); };
            return false;
        }

            overlay.onclick = function(e) { if (e.target === overlay) overlay.remove(); };
            return false;
        }
    </script>

</asp:Content>

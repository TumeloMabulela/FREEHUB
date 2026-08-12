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
                    <h2>Deactivate Profile</h2>
                    <p>Deactivating your profile will hide it from other users. You can reactivate it anytime.</p>

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
                        <asp:CheckBox ID="chkConfirmDeactivateProfile" runat="server" />
                        <label style="display:inline; margin-left:8px;">
                            Yes, I understand the consequences of deactivating my profile.
                        </label>
                    </div>

                    <asp:Button ID="btnDeactivateProfile" runat="server" Text="Deactivate Profile"
                        CssClass="deactivate-button" OnClick="btnDeactivateProfile_Click" />
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
                        <asp:CheckBox ID="chkConfirmDeactivateAccount" runat="server" />
                        <label style="display:inline; margin-left:8px;">
                            Yes, I understand the consequences of deactivating my account.
                        </label>
                    </div>

                    <asp:Button ID="btnDeactivateAccount" runat="server" Text="Deactivate Account"
                        CssClass="deactivate-button deactivate-account-button"
                        OnClick="btnDeactivateAccount_Click" />
                </asp:Panel>

            </div>

        </section>

    </div>

</asp:Content>

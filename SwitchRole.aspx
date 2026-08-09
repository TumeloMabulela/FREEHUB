<%@ Page Title="Switch Role - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="SwitchRole.aspx.cs"
    Inherits="FreeHubProject.SwitchRole" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="SwitchRoleHead"
    ContentPlaceHolderID="HeadContent"
    runat="server">
</asp:Content>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <div class="switch-role-page">

                <h1>Switch Role</h1>
                <p class="switch-role-description">
                    You are currently acting as: 
                    <strong><asp:Label ID="lblCurrentRole" runat="server" /></strong>
                </p>

                <!-- MESSAGE -->
                <asp:Panel ID="pnlMessage" runat="server" CssClass="post-status" Visible="false">
                    <asp:Label ID="lblMessage" runat="server" />
                </asp:Panel>

                <div class="switch-role-options">

                    <!-- FREELANCER OPTION -->
                    <div class="role-card">
                        <div class="role-card-icon">&#128188;</div>
                        <h2>Freelancer</h2>
                        <p>Find work, submit proposals, and get hired for projects.</p>
                        <ul class="role-features">
                            <li>Browse and apply to projects</li>
                            <li>Submit proposals to employers</li>
                            <li>Get rated after completing work</li>
                            <li>Withdraw earnings to your bank</li>
                        </ul>
                        <asp:Button ID="btnSwitchFreelancer" runat="server"
                            Text="Switch to Freelancer"
                            CssClass="role-switch-button freelancer-button"
                            OnClick="btnSwitchFreelancer_Click" />
                    </div>

                    <!-- EMPLOYER OPTION -->
                    <div class="role-card">
                        <div class="role-card-icon">&#128101;</div>
                        <h2>Employer</h2>
                        <p>Post projects, hire freelancers, and manage your team.</p>
                        <ul class="role-features">
                            <li>Post projects with budgets and deadlines</li>
                            <li>Review and approve proposals</li>
                            <li>Rate freelancers after completion</li>
                            <li>Fund your wallet for payments</li>
                        </ul>
                        <asp:Button ID="btnSwitchEmployer" runat="server"
                            Text="Switch to Employer"
                            CssClass="role-switch-button employer-button"
                            OnClick="btnSwitchEmployer_Click" />
                    </div>

                </div>

                <!-- CREATE PROFILE SECTION (shown when switching to a role without a profile) -->
                <asp:Panel ID="pnlCreateFreelancerProfile" runat="server" Visible="false" CssClass="create-profile-section">
                    <h2>Create Freelancer Profile</h2>
                    <p>Complete your freelancer profile to start finding work.</p>

                    <div class="post-field">
                        <label>Skills <span>*</span></label>
                        <asp:TextBox ID="txtSkills" runat="server" CssClass="post-input"
                            placeholder="e.g. Web Design, JavaScript, React, CSS" />
                    </div>

                    <div class="post-field">
                        <label>Work Experience</label>
                        <asp:TextBox ID="txtExperience" runat="server" CssClass="post-textarea"
                            TextMode="MultiLine" Rows="4"
                            placeholder="Describe your work experience..." />
                    </div>

                    <div class="post-field">
                        <label>Portfolio Links</label>
                        <asp:TextBox ID="txtPortfolioLinks" runat="server" CssClass="post-input"
                            placeholder="e.g. https://behance.net/yourname" />
                    </div>

                    <div class="post-field">
                        <label>Hourly Rate (ZAR) <span>*</span></label>
                        <asp:TextBox ID="txtHourlyRate" runat="server" CssClass="post-input"
                            TextMode="Number" placeholder="350" />
                    </div>

                    <asp:Button ID="btnCreateFreelancerProfile" runat="server"
                        Text="Create Freelancer Profile"
                        CssClass="post-submit-button"
                        OnClick="btnCreateFreelancerProfile_Click" />
                </asp:Panel>

                <asp:Panel ID="pnlCreateEmployerProfile" runat="server" Visible="false" CssClass="create-profile-section">
                    <h2>Create Employer Profile</h2>
                    <p>Complete your employer profile to start posting projects.</p>

                    <div class="post-field">
                        <label>Company Name <span>*</span></label>
                        <asp:TextBox ID="txtCompanyName" runat="server" CssClass="post-input"
                            placeholder="Your company name" />
                    </div>

                    <div class="post-field">
                        <label>Industry <span>*</span></label>
                        <asp:DropDownList ID="ddlIndustry" runat="server" CssClass="post-input">
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
                        <label>Company Description <span>*</span></label>
                        <asp:TextBox ID="txtCompanyDescription" runat="server" CssClass="post-textarea"
                            TextMode="MultiLine" Rows="4"
                            placeholder="Describe your company..." />
                    </div>

                    <div class="post-field">
                        <label>Contact Email</label>
                        <asp:TextBox ID="txtContactEmail" runat="server" CssClass="post-input"
                            TextMode="Email" placeholder="contact@company.co.za" />
                    </div>

                    <asp:Button ID="btnCreateEmployerProfile" runat="server"
                        Text="Create Employer Profile"
                        CssClass="post-submit-button"
                        OnClick="btnCreateEmployerProfile_Click" />
                </asp:Panel>

            </div>

        </section>

    </div>

</asp:Content>

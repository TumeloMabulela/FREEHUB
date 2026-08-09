<%@ Page Title="Edit Project - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="EditProject.aspx.cs"
    Inherits="FreeHubProject.EditProject" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <div class="post-page-heading">
                <div class="post-breadcrumb">
                    Dashboard <span>/</span> My Projects <span>/</span> Edit Project
                </div>
                <h1>Edit Project</h1>
                <p>Update your project details below and save the changes.</p>
            </div>

            <!-- MESSAGE -->
            <asp:Panel ID="pnlMessage" runat="server" CssClass="post-status" Visible="false">
                <asp:Label ID="lblMessage" runat="server" />
            </asp:Panel>

            <div class="post-content-grid">

                <div class="post-form-card">

                    <!-- PROJECT TITLE & CATEGORY -->
                    <div class="post-two-columns">
                        <div class="post-field">
                            <label>Project Title <span>*</span></label>
                            <asp:TextBox ID="txtProjectTitle" runat="server" CssClass="post-input" />
                        </div>
                        <div class="post-field">
                            <label>Category <span>*</span></label>
                            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="post-input">
                                <asp:ListItem Text="Select a category" Value="" />
                                <asp:ListItem Text="Web Development" Value="Web Development" />
                                <asp:ListItem Text="Software Development" Value="Software Development" />
                                <asp:ListItem Text="Mobile Development" Value="Mobile Development" />
                                <asp:ListItem Text="UI/UX Design" Value="UI/UX Design" />
                                <asp:ListItem Text="Graphic Design" Value="Graphic Design" />
                                <asp:ListItem Text="Digital Marketing" Value="Digital Marketing" />
                            </asp:DropDownList>
                        </div>
                    </div>

                    <!-- DESCRIPTION -->
                    <div class="post-field">
                        <label>Project Description <span>*</span></label>
                        <asp:TextBox ID="txtDescription" runat="server" CssClass="post-textarea"
                            TextMode="MultiLine" Rows="6" />
                    </div>

                    <!-- BUDGET -->
                    <div class="post-two-columns">
                        <div class="post-field">
                            <label>Budget Type <span>*</span></label>
                            <asp:RadioButtonList ID="rblBudgetType" runat="server"
                                CssClass="post-budget-options" RepeatDirection="Horizontal">
                                <asp:ListItem Text="Fixed Price" Value="Fixed" Selected="True" />
                                <asp:ListItem Text="Hourly" Value="Hourly" />
                            </asp:RadioButtonList>
                        </div>
                        <div class="post-field">
                            <label>Budget Amount (ZAR) <span>*</span></label>
                            <div class="budget-input-box">
                                <span>R</span>
                                <asp:TextBox ID="txtBudget" runat="server" CssClass="budget-input" TextMode="Number" />
                            </div>
                        </div>
                    </div>

                    <!-- DEADLINE & EXPERIENCE -->
                    <div class="post-two-columns">
                        <div class="post-field">
                            <label>Project Deadline <span>*</span></label>
                            <asp:TextBox ID="txtDeadline" runat="server" CssClass="post-input" TextMode="Date" />
                        </div>
                        <div class="post-field">
                            <label>Experience Level <span>*</span></label>
                            <asp:DropDownList ID="ddlExperience" runat="server" CssClass="post-input">
                                <asp:ListItem Text="Select level" Value="" />
                                <asp:ListItem Text="Beginner" Value="Beginner" />
                                <asp:ListItem Text="Intermediate" Value="Intermediate" />
                                <asp:ListItem Text="Expert" Value="Expert" />
                            </asp:DropDownList>
                        </div>
                    </div>

                    <!-- SKILLS -->
                    <div class="post-field">
                        <label>Skills &amp; Expertise</label>
                        <asp:TextBox ID="txtSkills" runat="server" CssClass="post-input"
                            placeholder="e.g. HTML, CSS, JavaScript, React" />
                    </div>

                    <!-- BUTTONS -->
                    <div class="post-buttons">
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel"
                            CssClass="post-cancel-button" CausesValidation="false"
                            OnClick="btnCancel_Click" />
                        <asp:Button ID="btnSaveChanges" runat="server" Text="Save Changes"
                            CssClass="post-submit-button" OnClick="btnSaveChanges_Click" />
                    </div>

                </div>

                <!-- TIPS -->
                <div class="post-help-column">
                    <div class="post-help-card">
                        <h3>Tips for Editing Projects</h3>
                        <div class="help-tip">
                            <div class="help-icon">&#9998;</div>
                            <div><strong>Be Clear &amp; Specific</strong><p>Update your project title and description to attract the right talent.</p></div>
                        </div>
                        <div class="help-tip">
                            <div class="help-icon">R</div>
                            <div><strong>Set a Realistic Budget</strong><p>Ensure your budget reflects the scope of the work.</p></div>
                        </div>
                        <div class="help-tip">
                            <div class="help-icon">&#9201;</div>
                            <div><strong>Adjust Deadline</strong><p>Give enough time for quality work to be delivered.</p></div>
                        </div>
                        <div class="help-tip">
                            <div class="help-icon">&#9733;</div>
                            <div><strong>Review Before Saving</strong><p>Double-check all details before updating your project.</p></div>
                        </div>
                    </div>
                </div>

            </div>

        </section>

    </div>

</asp:Content>

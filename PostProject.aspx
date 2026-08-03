<%@ Page Title="Post Project"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="PostProject.aspx.cs"
    Inherits="FreeHubProject.PostProject" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="freehub-dashboard-layout">

        <!-- LEFT SIDEBAR -->

        <aside class="freehub-sidebar">

            <div class="sidebar-section">

                <a href="Default.aspx"
                   class="sidebar-item">

                    <span class="sidebar-icon">⌂</span>
                    <span>Dashboard</span>

                </a>


                <a href="BrowseProjects.aspx"
                   class="sidebar-item">

                    <span class="sidebar-icon">⌕</span>
                    <span>Find Work</span>

                </a>


                <a href="PostProject.aspx"
                   class="sidebar-item active-sidebar-item">

                    <span class="sidebar-icon">▣</span>
                    <span>My Projects</span>

                </a>


                <a href="Proposals.aspx"
                   class="sidebar-item">

                    <span class="sidebar-icon">▤</span>
                    <span>Proposals</span>

                </a>


                <a href="StartChat.aspx"
                   class="sidebar-item">

                    <span class="sidebar-icon">✉</span>
                    <span>Messages</span>

                </a>


                <a href="Wallet.aspx"
                   class="sidebar-item">

                    <span class="sidebar-icon">▱</span>
                    <span>Wallet</span>

                </a>

            </div>


            <div class="sidebar-heading">

                PROFILE

            </div>


            <div class="sidebar-section">

                <a href="Profile.aspx"
                   class="sidebar-item">

                    <span class="sidebar-icon">♙</span>
                    <span>Profile</span>

                </a>


                <a href="Settings.aspx"
                   class="sidebar-item">

                    <span class="sidebar-icon">⚙</span>
                    <span>Settings</span>

                </a>


                <a href="HelpSupport.aspx"
                   class="sidebar-item">

                    <span class="sidebar-icon">?</span>
                    <span>Help &amp; Support</span>

                </a>

            </div>

        </aside>


        <!-- MAIN CONTENT -->

        <section class="freehub-main-content">


            <!-- PAGE TITLE -->

            <div class="post-page-heading">

                <div class="post-breadcrumb">

                    Dashboard

                    <span>/</span>

                    My Projects

                    <span>/</span>

                    Post Project

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

                            </label>


                            <asp:DropDownList
                                ID="ddlCategory"
                                runat="server"
                                CssClass="post-input">

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

                            </asp:DropDownList>

                        </div>


                        <div class="post-field">

                            <label>

                                Experience Level

                                <span>*</span>

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

                        </label>


                        <asp:TextBox
                            ID="txtDescription"
                            runat="server"
                            CssClass="post-textarea"
                            TextMode="MultiLine"
                            Rows="7"
                            placeholder="Describe the project, important requirements and expected results...">
                        </asp:TextBox>

                    </div>


                    <!-- BUDGET -->

                    <div class="post-budget-area">


                        <div class="post-field">

                            <label>

                                Budget Type

                                <span>*</span>

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

                            </label>


                            <div class="budget-input-box">

                                <span>R</span>


                                <asp:TextBox
                                    ID="txtBudget"
                                    runat="server"
                                    CssClass="budget-input"
                                    TextMode="Number"
                                    placeholder="25000">
                                </asp:TextBox>

                            </div>

                        </div>


                        <div class="post-field">

                            <label>

                                Deadline

                                <span>*</span>

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

                                Add documents, images or project requirements.

                            </p>


                            <asp:FileUpload
                                ID="fileAttachment"
                                runat="server"
                                CssClass="post-file-upload" />

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


                    <div class="post-secure-card">


                        <div class="secure-icon">

                            ✓

                        </div>


                        <h3>

                            Secure Project Posting

                        </h3>


                        <p>

                            Your project information is protected and only visible to registered FreeHUB users.

                        </p>


                        <asp:Button
                            ID="btnLearnMore"
                            runat="server"
                            Text="Learn More"
                            CssClass="post-learn-button"
                            CausesValidation="false"
                            OnClick="btnLearnMore_Click" />

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

</asp:Content>
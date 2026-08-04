<%@ Page Title="Project Details"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="ProjectDetails.aspx.cs"
    Inherits="FreeHubProject.ProjectDetails" %>

<asp:Content ID="ProjectDetailsHead"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <link href="<%= ResolveUrl("~/ProjectDetails.css?v=1") %>"
          rel="stylesheet"
          type="text/css" />

</asp:Content>

<asp:Content ID="ProjectDetailsContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="pd-page">

        <!-- LEFT SIDEBAR -->
        <aside class="pd-sidebar">

            <a href="Dashboard.aspx"
               class="pd-menu-item">

                <span class="pd-menu-icon">¦</span>
                <span>Dashboard</span>

            </a>

            <a href="BrowseProjects.aspx"
               class="pd-menu-item pd-menu-active">

                <span class="pd-menu-icon">?</span>
                <span>Browse Projects</span>

            </a>

            <a href="SelectProposal.aspx"
               class="pd-menu-item">

                <span class="pd-menu-icon">?</span>
                <span>My Proposals</span>

            </a>

            <a href="Messages.aspx"
               class="pd-menu-item">

                <span class="pd-menu-icon">?</span>
                <span>Messages</span>

            </a>

            <a href="Wallet.aspx"
               class="pd-menu-item">

                <span class="pd-menu-icon">?</span>
                <span>Wallet</span>

            </a>

            <a href="SavedProjects.aspx"
               class="pd-menu-item">

                <span class="pd-menu-icon">?</span>
                <span>Saved Projects</span>

            </a>

            <div class="pd-sidebar-divider"></div>

            <div class="pd-sidebar-title">
                ACCOUNT
            </div>

            <a href="Default.aspx"
               class="pd-menu-item">

                <span class="pd-menu-icon">?</span>
                <span>Profile</span>

            </a>

            <a href="Default.aspx"
               class="pd-menu-item">

                <span class="pd-menu-icon">?</span>
                <span>Settings</span>

            </a>

            <a href="Default.aspx"
               class="pd-menu-item">

                <span class="pd-menu-icon">?</span>
                <span>Help &amp; Support</span>

            </a>

            <a href="PostProject.aspx"
               class="pd-mode-button">

                <span>?</span>

                <div>
                    <strong>Switch to</strong>
                    <small>Employer Mode</small>
                </div>

                <span>›</span>

            </a>

        </aside>


        <!-- MAIN CONTENT -->
        <main class="pd-main">

            <!-- BREADCRUMB -->
            <div class="pd-breadcrumb">

                <a href="Dashboard.aspx">
                    Dashboard
                </a>

                <span>›</span>

                <a href="BrowseProjects.aspx">
                    Projects
                </a>

                <span>›</span>

                <strong>
                    Project Details
                </strong>

            </div>


            <!-- PROJECT HEADING -->
            <div class="pd-heading-row">

                <div>

                    <div class="pd-title-row">

                        <h1>
                            E-commerce Website Redesign
                        </h1>

                        <span class="pd-open-badge">
                            Open
                        </span>

                    </div>

                    <p>
                        Project posted by
                        <strong>John Smith</strong>
                        <span>•</span>
                        Posted 2 hours ago
                    </p>

                </div>

                <a href="BrowseProjects.aspx"
                   class="pd-back-button">

                    ? Back to Projects

                </a>

            </div>


            <asp:Panel
                ID="pnlMessage"
                runat="server"
                CssClass="pd-message"
                Visible="false">

                <asp:Label
                    ID="lblMessage"
                    runat="server">
                </asp:Label>

            </asp:Panel>


            <!-- PROJECT INFORMATION -->
            <div class="pd-project-grid">

                <section class="pd-project-card">

                    <div class="pd-description-area">

                        <h2>
                            Project Description
                        </h2>

                        <p>
                            We need a modern and user-friendly redesign
                            of our existing e-commerce website. The goal
                            is to improve UI/UX, increase conversion rate,
                            and ensure mobile responsiveness. The project
                            includes front-end and back-end development.
                        </p>


                        <div class="pd-project-features">

                            <div class="pd-feature">

                                <span class="pd-feature-icon">
                                    ?
                                </span>

                                <div>

                                    <small>
                                        Category
                                    </small>

                                    <strong>
                                        Web Development
                                    </strong>

                                </div>

                            </div>


                            <div class="pd-feature">

                                <span class="pd-feature-icon">
                                    ?
                                </span>

                                <div>

                                    <small>
                                        Experience Level
                                    </small>

                                    <strong>
                                        Intermediate Level
                                    </strong>

                                </div>

                            </div>


                            <div class="pd-feature">

                                <span class="pd-feature-icon">
                                    ?
                                </span>

                                <div>

                                    <small>
                                        Project Type
                                    </small>

                                    <strong>
                                        Fixed Price
                                    </strong>

                                </div>

                            </div>

                        </div>

                    </div>


                    <div class="pd-project-summary">

                        <div class="pd-summary-row">

                            <span>Budget</span>

                            <strong class="pd-budget">
                                R8,000 - R15,000
                            </strong>

                        </div>

                        <div class="pd-summary-row">

                            <span>Project Deadline</span>

                            <strong>
                                30 May 2024
                            </strong>

                        </div>

                        <div class="pd-summary-row">

                            <span>Time Remaining</span>

                            <strong>
                                21 days
                            </strong>

                        </div>

                        <div class="pd-summary-row">

                            <span>Proposals</span>

                            <strong>
                                8
                            </strong>

                        </div>

                        <div class="pd-summary-row">

                            <span>Project ID</span>

                            <strong>
                                #PJ10078
                            </strong>

                        </div>

                    </div>

                </section>


                <!-- EMPLOYER CARD -->
                <aside class="pd-employer-card">

                    <h3>
                        About the Employer
                    </h3>

                    <div class="pd-employer-profile">

                        <div class="pd-employer-avatar">
                            JS
                        </div>

                        <div>

                            <strong>
                                John Smith
                                <span>?</span>
                            </strong>

                            <small>
                                Member since Mar 2022
                            </small>

                            <p>
                                ? 4.8 (18 reviews)
                            </p>

                        </div>

                    </div>

                    <a href="Default.aspx"
                       class="pd-view-profile-button">

                        View Profile

                    </a>

                </aside>

            </div>


            <!-- COMMENTS AND FORM -->
            <div class="pd-discussion-grid">

                <!-- COMMENTS -->
                <section class="pd-comments-card">

                    <div class="pd-comments-heading">

                        <h2>

                            Comments

                            <asp:Label
                                ID="lblCommentCount"
                                runat="server"
                                Text="(0)">
                            </asp:Label>

                        </h2>


                        <asp:DropDownList
                            ID="ddlCommentSort"
                            runat="server"
                            CssClass="pd-sort-dropdown"
                            AutoPostBack="true"
                            OnSelectedIndexChanged="ddlCommentSort_SelectedIndexChanged">

                            <asp:ListItem
                                Text="Newest First"
                                Value="Newest">
                            </asp:ListItem>

                            <asp:ListItem
                                Text="Oldest First"
                                Value="Oldest">
                            </asp:ListItem>

                        </asp:DropDownList>

                    </div>


                    <asp:Repeater
                        ID="rptComments"
                        runat="server"
                        OnItemCommand="rptComments_ItemCommand">

                        <ItemTemplate>

                            <article class='<%# Convert.ToBoolean(Eval("IsCurrentUser"))
                                ? "pd-comment pd-own-comment"
                                : "pd-comment" %>'>

                                <div class="pd-comment-avatar">

                                    <%# Eval("Initials") %>

                                </div>


                                <div class="pd-comment-content">

                                    <div class="pd-comment-meta">

                                        <strong>
                                            <%# Server.HtmlEncode(
                                                Convert.ToString(
                                                    Eval("AuthorName")
                                                )
                                            ) %>
                                        </strong>

                                        <span
                                            class="pd-you-badge"
                                            style='<%# Convert.ToBoolean(Eval("IsCurrentUser"))
                                                ? ""
                                                : "display:none;" %>'>

                                            You

                                        </span>

                                        <small>
                                            • <%# Eval("DisplayTime") %>
                                        </small>

                                    </div>


                                    <div
                                        class="pd-reply-reference"
                                        style='<%# string.IsNullOrWhiteSpace(
                                            Convert.ToString(Eval("ReplyToName"))
                                        )
                                            ? "display:none;"
                                            : "" %>'>

                                        Replying to
                                        <strong>
                                            <%# Server.HtmlEncode(
                                                Convert.ToString(
                                                    Eval("ReplyToName")
                                                )
                                            ) %>
                                        </strong>

                                    </div>


                                    <p>
                                        <%# Server.HtmlEncode(
                                            Convert.ToString(
                                                Eval("CommentText")
                                            )
                                        ) %>
                                    </p>


                                    <asp:LinkButton
                                        ID="btnReply"
                                        runat="server"
                                        Text="Reply"
                                        CssClass="pd-reply-button"
                                        CommandName="ReplyComment"
                                        CommandArgument='<%# Eval("CommentId") %>'
                                        CausesValidation="false">
                                    </asp:LinkButton>

                                </div>

                            </article>

                        </ItemTemplate>

                    </asp:Repeater>


                    <asp:Panel
                        ID="pnlNoComments"
                        runat="server"
                        CssClass="pd-no-comments"
                        Visible="false">

                        <div>?</div>

                        <strong>
                            No comments yet
                        </strong>

                        <p>
                            Be the first person to comment on this project.
                        </p>

                    </asp:Panel>

                </section>


                <!-- COMMENT FORM -->
                <aside class="pd-comment-column">

                    <section class="pd-add-comment-card">

                        <h3>
                            Add a Comment
                        </h3>


                        <asp:Panel
                            ID="pnlReplyingTo"
                            runat="server"
                            CssClass="pd-replying-box"
                            Visible="false">

                            <div>

                                Replying to

                                <asp:Label
                                    ID="lblReplyingTo"
                                    runat="server">
                                </asp:Label>

                            </div>

                            <asp:LinkButton
                                ID="btnCancelReply"
                                runat="server"
                                Text="×"
                                CssClass="pd-cancel-reply"
                                CausesValidation="false"
                                OnClick="btnCancelReply_Click">
                            </asp:LinkButton>

                        </asp:Panel>


                        <asp:HiddenField
                            ID="hfReplyToCommentId"
                            runat="server"
                            Value="" />


                        <asp:TextBox
                            ID="txtComment"
                            runat="server"
                            TextMode="MultiLine"
                            Rows="8"
                            MaxLength="1000"
                            CssClass="pd-comment-textbox"
                            placeholder="Write your comment..."
                            onkeyup="updateCommentCount(this)">
                        </asp:TextBox>


                        <div class="pd-comment-toolbar">

                            <div>

                                <button type="button"
                                        onclick="insertFormatting('bold')">

                                    <strong>B</strong>

                                </button>

                                <button type="button"
                                        onclick="insertFormatting('italic')">

                                    <em>I</em>

                                </button>

                                <button type="button"
                                        onclick="insertFormatting('list')">

                                    ?

                                </button>

                            </div>

                            <span>

                                <span id="commentCharacterCount">
                                    0
                                </span>

                                /1000

                            </span>

                        </div>


                        <asp:Button
                            ID="btnPostComment"
                            runat="server"
                            Text="Post Comment"
                            CssClass="pd-post-comment-button"
                            OnClick="btnPostComment_Click" />


                        <div class="pd-community-note">

                            ? Be respectful and follow our
                            community guidelines.

                        </div>

                    </section>


                    <!-- GUIDELINES -->
                    <section class="pd-guidelines-card">

                        <h3>
                            Discussion Guidelines
                        </h3>

                        <ul>

                            <li>
                                ? Be respectful and professional
                            </li>

                            <li>
                                ? Stay on topic
                            </li>

                            <li>
                                ? No spamming or self-promotion
                            </li>

                            <li>
                                ? Protect your privacy and others'
                            </li>

                        </ul>

                    </section>

                </aside>

            </div>

        </main>

    </div>


    <script type="text/javascript">

        function updateCommentCount(textBox) {

            var counter =
                document.getElementById(
                    "commentCharacterCount"
                );

            if (counter) {
                counter.innerText =
                    textBox.value.length;
            }
        }


        function insertFormatting(type) {

            var textBox =
                document.getElementById(
                    "<%= txtComment.ClientID %>"
                );

            if (!textBox) {
                return;
            }

            var start =
                textBox.selectionStart || 0;

            var end =
                textBox.selectionEnd || 0;

            var selectedText =
                textBox.value.substring(
                    start,
                    end
                );

            var replacement =
                selectedText;

            if (type === "bold") {
                replacement =
                    "**" + selectedText + "**";
            }
            else if (type === "italic") {
                replacement =
                    "*" + selectedText + "*";
            }
            else if (type === "list") {
                replacement =
                    "• " + selectedText;
            }

            textBox.value =
                textBox.value.substring(0, start) +
                replacement +
                textBox.value.substring(end);

            textBox.focus();

            updateCommentCount(textBox);
        }


        document.addEventListener(
            "DOMContentLoaded",
            function () {

                var textBox =
                    document.getElementById(
                        "<%= txtComment.ClientID %>"
                    );

                if (textBox) {
                    updateCommentCount(textBox);
                }
            }
        );

    </script>

</asp:Content>
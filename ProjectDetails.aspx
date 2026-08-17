<%@ Page Title="Project Details - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="ProjectDetails.aspx.cs"
    Inherits="FreeHubProject.ProjectDetails" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <!-- BREADCRUMB & HEADER -->
            <div class="pd-header">
                <div class="post-breadcrumb">
                    Dashboard <span>/</span> Projects <span>/</span> Project Details
                </div>
                <div class="pd-title-row" style="display:flex; justify-content:space-between; align-items:flex-start;">
                    <div>
                        <h1><asp:Label ID="lblTitle" runat="server" /></h1>
                        <p class="pd-posted">
                            Project posted by <strong><asp:Label ID="lblEmployerName" runat="server" /></strong>
                            &bull; Posted <asp:Label ID="lblPosted" runat="server" />
                        </p>
                    </div>
                    <a href="BrowseProjects.aspx" style="display:inline-block;color:#fff;background-color:#2e7d56;text-decoration:none;font-size:13px;font-weight:500;padding:10px 20px;border-radius:6px;white-space:nowrap;">&#8592; Back to Projects</a>
                </div>
            </div>

            <!-- PROJECT INFO CARD -->
            <div class="pd-info-card">
                <div class="pd-description">
                    <h3>Project Description</h3>
                    <p><asp:Label ID="lblDescription" runat="server" /></p>
                    <div class="pd-meta-row">
                        <span>Category: <strong><asp:Label ID="lblCategory" runat="server" /></strong></span>
                        <span>Experience: <strong><asp:Label ID="lblExperience" runat="server" /></strong></span>
                        <span>Budget Type: <strong><asp:Label ID="lblBudgetType" runat="server" /></strong></span>
                    </div>
                </div>
                <div class="pd-stats">
                    <div class="pd-stat">
                        <small>Budget</small>
                        <strong><asp:Label ID="lblBudget" runat="server" /></strong>
                    </div>
                    <div class="pd-stat">
                        <small>Deadline</small>
                        <strong><asp:Label ID="lblDeadline" runat="server" /></strong>
                    </div>
                    <div class="pd-stat">
                        <small>Status</small>
                        <strong><asp:Label ID="lblStatus" runat="server" /></strong>
                    </div>
                </div>
            </div>

            <!-- MESSAGE -->
            <asp:Panel ID="pnlMessage" runat="server" CssClass="post-status" Visible="false">
                <asp:Label ID="lblMessage" runat="server" />
            </asp:Panel>

            <!-- COMMENTS LAYOUT -->
            <div class="pd-comments-layout">

                <!-- LEFT: COMMENTS LIST -->
                <div class="pd-comments-list">
                    <h3>Comments (<asp:Label ID="lblCommentCount" runat="server" Text="0" />)</h3>

                    <asp:Repeater ID="rptComments" runat="server" OnItemCommand="rptComments_ItemCommand">
                        <ItemTemplate>
                            <div class="comment-item">
                                <div class="comment-avatar" style="background-color:<%# GetAvatarColor(Container.ItemIndex) %>">
                                    <%# Eval("authorName").ToString().Length > 0 ? Eval("authorName").ToString().Substring(0,1).ToUpper() : "?" %>
                                </div>
                                <div class="comment-body">
                                    <div>
                                        <a href='ViewProfile.aspx?id=<%# Eval("userID") %>' style="color:#173f2c; text-decoration:none; font-weight:bold;"><%# Eval("authorName") %></a>
                                        <small class="comment-role"><%# Eval("userType") %></small>
                                        <small class="comment-time">&bull; <%# GetTimeAgo(Convert.ToDateTime(Eval("commentDate"))) %></small>
                                    </div>
                                    <p><%# Eval("commentText") %></p>
                                    <asp:LinkButton ID="btnReply" runat="server"
                                        CommandName="ReplyComment"
                                        CommandArgument='<%# Eval("authorName") %>'
                                        style="color:#2e7d56; font-size:12px; text-decoration:none; cursor:pointer;">
                                        Reply
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnEditComment" runat="server"
                                        CommandName="EditComment"
                                        CommandArgument='<%# Eval("commentID") + "|" + Eval("commentText") %>'
                                        Visible='<%# Convert.ToInt32(Eval("userID")) == Convert.ToInt32(Session["UserID"]) %>'
                                        style="color:#856404; font-size:12px; text-decoration:none; cursor:pointer; margin-left:12px;">
                                        Edit
                                    </asp:LinkButton>
                                </div>
                                <asp:LinkButton ID="btnDelete" runat="server"
                                    CommandName="DeleteComment"
                                    CommandArgument='<%# Eval("commentID") %>'
                                    CssClass="delete-comment-btn"
                                    Visible='<%# Convert.ToInt32(Eval("userID")) == Convert.ToInt32(Session["UserID"]) %>'
                                    OnClientClick="return confirm('Are you sure you want to delete this comment?');">
                                    &#128465;
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlNoComments" runat="server" CssClass="no-comments">
                        <p>No comments yet. Be the first to start the discussion!</p>
                    </asp:Panel>
                </div>

                <!-- RIGHT: ADD COMMENT -->
                <div class="pd-add-comment">
                    <h3>Add a Comment</h3>
                    <asp:Panel ID="pnlReplyingTo" runat="server" Visible="false" style="background:#edf5f0; padding:8px 12px; border-radius:6px; margin-bottom:10px; font-size:13px; color:#2e7d56;">
                        Replying to <strong><asp:Label ID="lblReplyingTo" runat="server" /></strong>
                        <asp:LinkButton ID="btnCancelReply" runat="server" OnClick="btnCancelReply_Click" style="color:#dc3545; margin-left:10px; font-size:12px;">Cancel</asp:LinkButton>
                    </asp:Panel>
                    <asp:TextBox ID="txtComment" runat="server" CssClass="post-textarea"
                        TextMode="MultiLine" Rows="5" placeholder="Write your comment..." />
                    <asp:Button ID="btnPostComment" runat="server" Text="Post Comment"
                        CssClass="post-submit-button" OnClick="btnPostComment_Click"
                        style="width:100%; margin-top:10px;" />
                    <p class="comment-guidelines">Be respectful and follow our community guidelines.</p>

                    <div class="discussion-guidelines">
                        <h4>Discussion Guidelines</h4>
                        <ul>
                            <li>Be respectful and professional</li>
                            <li>Stay on topic</li>
                            <li>No spamming or self-promotion</li>
                            <li>Protect your privacy and others'</li>
                        </ul>
                    </div>
                </div>

            </div>

        </section>

    </div>

</asp:Content>

<%@ Page Title="Select Proposal"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="SelectProposal.aspx.cs"
    Inherits="FreeHubProject.SelectProposal" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <div class="post-page-heading">
                <div class="post-breadcrumb">
                    Dashboard <span>/</span> My Projects <span>/</span> Proposals
                </div>
                <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                    <div>
                        <h1>Proposals Received</h1>
                        <p>Review proposals submitted by freelancers for your projects.</p>
                    </div>
                    <a href="MyProjects.aspx" style="display:inline-block;color:#fff;background-color:#173f2c;text-decoration:none;font-size:13px;font-weight:500;padding:10px 20px;border-radius:6px;white-space:nowrap;">&#8592; Back to Projects</a>
                </div>
            </div>

            <!-- MESSAGE -->
            <asp:Panel ID="pnlMessage" runat="server" CssClass="post-status" Visible="false">
                <asp:Label ID="lblProposalMessage" runat="server" />
            </asp:Panel>

            <!-- NO PROPOSALS -->
            <asp:Panel ID="pnlNoProposals" runat="server" Visible="false" CssClass="no-projects-message">
                <h3>No proposals received yet</h3>
                <p>Once freelancers submit proposals for your projects, they will appear here for you to review.</p>
            </asp:Panel>

            <!-- PROPOSALS LIST -->
            <asp:Repeater ID="rptProposals" runat="server" OnItemCommand="rptProposals_ItemCommand">
                <ItemTemplate>
                    <div class="proposal-card">
                        <div class="proposal-card-left">
                            <div class="comment-avatar" style="background-color:#2e7d56; width:45px; height:45px; font-size:16px;">
                                <%# Eval("freelancerName").ToString().Length > 0 ? Eval("freelancerName").ToString().Substring(0,1).ToUpper() : "?" %>
                            </div>
                            <div class="proposal-info">
                                <h3><%# Eval("freelancerName") %></h3>
                                <p class="proposal-project-name">Project: <%# Eval("projectTitle") %></p>
                                <p class="proposal-cover"><%# Eval("coverLetter").ToString().Length > 150 ? Eval("coverLetter").ToString().Substring(0, 150) + "..." : Eval("coverLetter") %></p>
                                <small class="comment-time">Submitted <%# Convert.ToDateTime(Eval("date")).ToString("dd MMM yyyy") %></small>
                            </div>
                        </div>
                        <div class="proposal-card-right">
                            <div class="proposal-rate">
                                <small>Proposed Rate</small>
                                <strong>R<%# Convert.ToDecimal(Eval("proposedRate")).ToString("N0") %></strong>
                            </div>
                            <div class="proposal-time">
                                <small>Estimated Time</small>
                                <strong><%# Eval("estimatedCompletionTime") %></strong>
                            </div>
                            <div class="proposal-status-badge" style="color:<%# Eval("status").ToString() == "Approved" ? "#155724" : Eval("status").ToString() == "Rejected" ? "#721c24" : "#856404" %>; background:<%# Eval("status").ToString() == "Approved" ? "#d4edda" : Eval("status").ToString() == "Rejected" ? "#f8d7da" : "#fff3cd" %>; padding:4px 10px; border-radius:12px; font-size:12px;">
                                <%# Eval("status") %>
                            </div>
                            <asp:Button ID="btnApprove" runat="server"
                                CommandName="ApproveProposal"
                                CommandArgument='<%# Eval("proposalID") %>'
                                Text="Approve"
                                Visible='<%# Eval("status").ToString() == "Pending" %>'
                                style="background-color:#2e7d56;color:#fff;border:none;padding:8px 16px;border-radius:20px;font-size:13px;cursor:pointer;" />
                            <asp:Button ID="btnReject" runat="server"
                                CommandName="RejectProposal"
                                CommandArgument='<%# Eval("proposalID") %>'
                                Text="Reject"
                                Visible='<%# Eval("status").ToString() == "Pending" %>'
                                OnClientClick="return confirm('Are you sure you want to reject this proposal?');"
                                style="background-color:#dc3545;color:#fff;border:none;padding:8px 16px;border-radius:20px;font-size:13px;cursor:pointer;" />
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

        </section>

    </div>

</asp:Content>

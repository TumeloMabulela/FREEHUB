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

            <!-- HEADER -->
            <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:20px;">
                <div>
                    <div class="post-breadcrumb">
                        Dashboard <span>/</span> My Projects <span>/</span> Proposals
                    </div>
                    <h1 style="color:#173f2c; margin-top:5px;">
                        <%= IsFreelancerView() ? "My Proposals" : "Select Proposal" %>
                    </h1>
                    <p style="color:#666; font-size:14px;">
                        <%= IsFreelancerView() ? "View your submitted proposals and their status." : "Review proposals received and select the best fit for your project." %>
                    </p>
                </div>
                <a href="MyProjects.aspx" style="display:inline-block;color:#fff;background-color:#2e7d56;text-decoration:none;font-size:13px;font-weight:500;padding:10px 20px;border-radius:6px;white-space:nowrap;">&#8592; Back to Project</a>
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

            <!-- PROPOSALS + TIPS LAYOUT -->
            <div style="display:grid; grid-template-columns:1fr 280px; gap:25px;">

                <!-- PROPOSALS LIST -->
                <div>
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
                        <h3 style="color:#173f2c;">Proposals (<asp:Label ID="lblProposalCount" runat="server" Text="0" />)</h3>
                    </div>

                    <asp:Repeater ID="rptProposals" runat="server" OnItemCommand="rptProposals_ItemCommand">
                        <ItemTemplate>
                            <div style="display:flex; justify-content:space-between; align-items:flex-start; background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:20px; margin-bottom:12px;">
                                <!-- LEFT: Avatar + Info -->
                                <div style="display:flex; gap:15px; flex:1;">
                                    <div style="width:45px;height:45px;border-radius:50%;background-color:#2e7d56;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:bold;font-size:16px;flex-shrink:0;">
                                        <%# Eval("freelancerName").ToString().Substring(0,1).ToUpper() %><%# Eval("freelancerName").ToString().Contains(" ") ? Eval("freelancerName").ToString().Split(' ')[1].Substring(0,1).ToUpper() : "" %>
                                    </div>
                                    <div>
                                        <strong style="color:#173f2c; font-size:15px;"><%# Eval("freelancerName") %></strong>
                                        <p style="color:#555; font-size:13px; margin-top:6px; line-height:1.5;">
                                            <%# Eval("coverLetter").ToString().Length > 180 ? Eval("coverLetter").ToString().Substring(0, 180) + "..." : Eval("coverLetter") %>
                                        </p>
                                        <small style="color:#2e7d56; font-size:12px;">Project: <%# Eval("projectTitle") %></small>
                                    </div>
                                </div>
                                <!-- RIGHT: Rate + Buttons -->
                                <div style="display:flex; flex-direction:column; align-items:flex-end; gap:8px; min-width:150px;">
                                    <div>
                                        <small style="color:#888; font-size:11px;">Proposed Rate</small><br/>
                                        <strong style="color:#173f2c;">R<%# Convert.ToDecimal(Eval("proposedRate")).ToString("N0") %></strong>
                                    </div>
                                    <div>
                                        <small style="color:#888; font-size:11px;">Estimated Time</small><br/>
                                        <strong style="color:#173f2c;"><%# Eval("estimatedCompletionTime") %></strong>
                                    </div>
                                    <div>
                                        <small style="color:#888; font-size:11px;">Submitted</small><br/>
                                        <small><%# Convert.ToDateTime(Eval("date")).ToString("dd MMM yyyy") %></small>
                                    </div>
                                    <asp:Button ID="btnSelect" runat="server"
                                        CommandName="ApproveProposal"
                                        CommandArgument='<%# Eval("proposalID") %>'
                                        Text="Select Proposal"
                                        Visible='<%# Eval("status").ToString() == "Pending" && !IsFreelancerView() %>'
                                        style="background-color:#2e7d56;color:#fff;border:none;padding:8px 16px;border-radius:20px;font-size:13px;font-weight:500;cursor:pointer;margin-top:4px;" />
                                    <asp:Button ID="btnViewDetails" runat="server"
                                        CommandName="ViewDetails"
                                        CommandArgument='<%# Eval("proposalID") %>'
                                        Text="View Details"
                                        Visible='<%# !IsFreelancerView() %>'
                                        style="background-color:#fff;color:#173f2c;border:1px solid #ccc;padding:7px 14px;border-radius:20px;font-size:12px;cursor:pointer;" />
                                    <span style="display:inline-block;padding:3px 10px;border-radius:10px;font-size:11px;color:<%# Eval("status").ToString() == "Approved" ? "#155724" : Eval("status").ToString() == "Rejected" ? "#721c24" : "#856404" %>;background:<%# Eval("status").ToString() == "Approved" ? "#d4edda" : Eval("status").ToString() == "Rejected" ? "#f8d7da" : "#fff3cd" %>; <%# Eval("status").ToString() == "Pending" ? "display:none;" : "" %>">
                                        <%# Eval("status") %>
                                    </span>
                                    <asp:Button ID="btnReadAll" runat="server"
                                        CommandName="ReadAll"
                                        CommandArgument='<%# Eval("proposalID") %>'
                                        Text="Read Full Proposal"
                                        Visible='<%# IsFreelancerView() %>'
                                        style="background-color:#fff;color:#173f2c;border:1px solid #ccc;padding:7px 14px;border-radius:20px;font-size:12px;cursor:pointer;" />
                                    <asp:Button ID="btnDeleteProposal" runat="server"
                                        CommandName="DeleteProposal"
                                        CommandArgument='<%# Eval("proposalID") %>'
                                        Text="Delete"
                                        Visible='<%# IsFreelancerView() %>'
                                        OnClientClick="return confirm('Are you sure you want to delete this proposal? It will also be removed from the employer.');"
                                        style="background-color:#dc3545;color:#fff;border:none;padding:7px 14px;border-radius:20px;font-size:12px;cursor:pointer;" />
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <!-- RIGHT: TIPS PANEL -->
                <div>
                    <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:20px; margin-bottom:15px;">
                        <h4 style="color:#173f2c; margin-bottom:12px;">Tips for Choosing the Right Freelancer</h4>
                        <ul style="list-style:none; padding:0; margin:0;">
                            <li style="padding:8px 0; font-size:13px; color:#555; border-bottom:1px solid #f0f0f0;">Review cover letters and understand the freelancer's approach.</li>
                            <li style="padding:8px 0; font-size:13px; color:#555; border-bottom:1px solid #f0f0f0;">Compare proposed rates and delivery times.</li>
                            <li style="padding:8px 0; font-size:13px; color:#555; border-bottom:1px solid #f0f0f0;">Check ratings, reviews and past work.</li>
                            <li style="padding:8px 0; font-size:13px; color:#555;">Choose the proposal that best fits your needs and budget.</li>
                        </ul>
                    </div>

                    <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:20px; margin-bottom:15px;">
                        <h4 style="color:#173f2c; margin-bottom:8px;">Need Help?</h4>
                        <p style="font-size:13px; color:#666; margin-bottom:12px;">If you need assistance in choosing the right freelancer, our support team is here.</p>
                        <a href="mailto:support@freehub.co.za" style="display:inline-block;color:#2e7d56;border:1px solid #2e7d56;padding:8px 16px;border-radius:20px;font-size:12px;text-decoration:none;">Contact Support</a>
                    </div>

                    <div style="background:#fff; border:1px solid #e8ece9; border-radius:10px; padding:20px;">
                        <h4 style="color:#173f2c; margin-bottom:8px;">Next Step</h4>
                        <p style="font-size:13px; color:#666;">After selecting a proposal, you can review the details before approving.</p>
                    </div>
                </div>

            </div>

        </section>

    </div>

</asp:Content>

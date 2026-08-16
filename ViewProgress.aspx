<%@ Page Title="View Progress"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="ViewProgress.aspx.cs"
    Inherits="FreeHubProject.ViewProgress" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="freehub-dashboard-layout">
        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">
            <div class="view-progress-page">
                
                <!-- BREADCRUMB & HEADING -->
                <div class="notification-heading" style="margin-bottom: 24px;">
                    <div class="notification-breadcrumb">
                        Dashboard <span>›</span> Projects <span>›</span> View Progress (<asp:Literal ID="litUserRoleHeader" runat="server" />)
                    </div>
                    <h1>View Progress</h1>
                    <p style="color: #6b7280; font-size: 14px;">Track the real-time progress of your projects in one place.</p>
                </div>

                <!-- STATUS MESSAGE -->
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" style="padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-size: 14px;">
                    <asp:Label ID="lblMessage" runat="server" />
                </asp:Panel>

                <!-- STATS CARDS SECTION -->
                <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px;">
                    <div style="background: #fff; padding: 20px; border-radius: 12px; border: 1px solid #e5e7eb; display: flex; align-items: center; gap: 16px;">
                        <div style="background: #e6f4ea; color: #137333; width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 20px;">💼</div>
                        <div>
                            <small style="color: #6b7280; font-size: 12px; font-weight: 600;">Total Projects</small>
                            <h3 style="font-size: 22px; margin: 2px 0 0; color: #111827;"><asp:Literal ID="litStatTotal" runat="server" Text="0" /></h3>
                        </div>
                    </div>

                    <div style="background: #fff; padding: 20px; border-radius: 12px; border: 1px solid #e5e7eb; display: flex; align-items: center; gap: 16px;">
                        <div style="background: #e8f0fe; color: #1a73e8; width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 20px;">📊</div>
                        <div>
                            <small style="color: #6b7280; font-size: 12px; font-weight: 600;">Completed</small>
                            <h3 style="font-size: 22px; margin: 2px 0 0; color: #111827;"><asp:Literal ID="litStatCompleted" runat="server" Text="0" /></h3>
                        </div>
                    </div>

                    <div style="background: #fff; padding: 20px; border-radius: 12px; border: 1px solid #e5e7eb; display: flex; align-items: center; gap: 16px;">
                        <div style="background: #fef7e0; color: #b06000; width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 20px;">⏳</div>
                        <div>
                            <small style="color: #6b7280; font-size: 12px; font-weight: 600;">In Progress / Review</small>
                            <h3 style="font-size: 22px; margin: 2px 0 0; color: #111827;"><asp:Literal ID="litStatActive" runat="server" Text="0" /></h3>
                        </div>
                    </div>

                    <div style="background: #fff; padding: 20px; border-radius: 12px; border: 1px solid #e5e7eb; display: flex; align-items: center; gap: 16px;">
                        <div style="background: #f3e8ff; color: #7e22ce; width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 20px;">📈</div>
                        <div>
                            <small style="color: #6b7280; font-size: 12px; font-weight: 600;">Avg. Completion</small>
                            <h3 style="font-size: 22px; margin: 2px 0 0; color: #111827;"><asp:Literal ID="litStatAvgCompletion" runat="server" Text="0%" /></h3>
                        </div>
                    </div>
                </div>

                <!-- MAIN GRID LAYOUT -->
                <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px;">

                    <!-- LEFT COLUMN: PROJECTS LIST WITH WORKFLOW BUTTONS -->
                    <div style="display: flex; flex-direction: column; gap: 16px;">
                        <h3 style="font-size: 16px; font-weight: 700; color: #111827; margin-bottom: -8px;">Project Progress List</h3>

                        <asp:Repeater ID="rptProgressProjects" runat="server" OnItemCommand="rptProgressProjects_ItemCommand">
                            <ItemTemplate>
                                <div style="background: #fff; border: 1px solid #e5e7eb; border-radius: 12px; padding: 20px; margin-bottom: 4px;">
                                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px;">
                                        <div>
                                            <h4 style="font-size: 15px; font-weight: 700; color: #111827; margin: 0 0 4px;"><%# Eval("Title") %></h4>
                                            <span style="font-size: 13px; color: #6b7280;"><%# Eval("PartnerLabel") %>: <%# Eval("PartnerName") %></span>
                                        </div>
                                        <span style='<%# GetStatusBadgeStyle(Eval("Status").ToString()) %>'><%# Eval("Status") %></span>
                                    </div>

                                    <!-- Progress Bar -->
                                    <div style="margin: 16px 0 12px;">
                                        <div style="display: flex; justify-content: space-between; font-size: 12px; color: #6b7280; margin-bottom: 4px;">
                                            <span>Progress</span>
                                            <span style="font-weight: 600; color: #111827;"><%# Eval("ProgressPercent") %>%</span>
                                        </div>
                                        <div style="background: #e5e7eb; height: 8px; border-radius: 4px; overflow: hidden;">
                                            <div style='<%# "background: " + GetProgressBarColor(Eval("Status").ToString()) + "; width: " + Eval("ProgressPercent") + "%; height: 100%; border-radius: 4px;" %>'></div>
                                        </div>
                                    </div>

                                    <!-- WORKFLOW ACTION BUTTONS -->
                                    <div style="display: flex; gap: 10px; margin-bottom: 12px; align-items: center;">
                                        
                                        <!-- FREELANCER: Start Project Button (Visible if Assigned/Approved & Not Started/Open) -->
                                        <asp:Button ID="btnStartProj" runat="server" Text="▶ Start Project" CommandName="StartProject" CommandArgument='<%# Eval("ProjectId") %>'
                                            Visible='<%# UserType == "Freelancer" && Eval("Status").ToString() == "In Progress" && Convert.ToInt32(Eval("IsStarted")) == 0 %>'
                                            style="background: #059669; color: #fff; border: none; padding: 6px 14px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer;" />

                                        <!-- FREELANCER: Submit Work Button -->
                                        <asp:Button ID="btnSubmitWork" runat="server" Text="📁 Submit Work" CommandName="GoToSubmitWork" CommandArgument='<%# Eval("ProjectId") %>'
                                            Visible='<%# UserType == "Freelancer" && (Eval("Status").ToString() == "In Progress" || Eval("Status").ToString() == "Under Review") %>'
                                            style="background: #2563eb; color: #fff; border: none; padding: 6px 14px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer;" />

                                        <!-- EMPLOYER: Review Work / Approve / Reject Buttons -->
                                        <asp:Button ID="btnReview" runat="server" Text="🔍 Review Work & Approve/Reject" CommandName="ReviewWork" CommandArgument='<%# Eval("ProjectId") %>'
                                            Visible='<%# UserType == "Employer" && Eval("Status").ToString() == "Under Review" %>'
                                            style="background: #d97706; color: #fff; border: none; padding: 6px 14px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer;" />

                                    </div>

                                    <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid #f3f4f6; padding-top: 12px; font-size: 12px; color: #6b7280;">
                                        <span>📅 Budget: R<%# Convert.ToDecimal(Eval("Budget")).ToString("N2") %> &nbsp;&nbsp;|&nbsp;&nbsp; Deadline: <%# Convert.ToDateTime(Eval("Deadline")).ToString("dd MMM yyyy") %></span>
                                        <asp:LinkButton ID="btnDetails" runat="server" CommandName="ViewDetails" CommandArgument='<%# Eval("ProjectId") %>' style="color: #2563eb; text-decoration: none; font-weight: 600;">View Details ›</asp:LinkButton>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <asp:Label ID="lblNoProjects" runat="server" CssClass="no-projects-message" Visible="false" Text="No active projects found to track progress." style="text-align:center; padding:30px; color:#6b7280; background:#fff; border-radius:12px; border:1px solid #e5e7eb;" />

                        <div style="text-align: center; margin-top: 8px;">
                            <asp:Button ID="btnViewAllProjects" runat="server" Text="View All Projects" OnClick="btnViewAllProjects_Click" 
                                style="background: #fff; border: 1px solid #d1d5db; color: #374151; padding: 10px 24px; border-radius: 8px; font-weight: 600; cursor: pointer;" />
                        </div>
                    </div>

                    <!-- RIGHT COLUMN: PROGRESS BREAKDOWN & DEADLINES -->
                    <div style="display: flex; flex-direction: column; gap: 20px;">
                        
                        <!-- Progress Overview Widget -->
                        <div style="background: #fff; border: 1px solid #e5e7eb; border-radius: 12px; padding: 20px; text-align: center;">
                            <h3 style="font-size: 15px; font-weight: 700; color: #111827; text-align: left; margin-bottom: 16px;">Progress Overview</h3>
                            
                            <div style="width: 120px; height: 120px; border: 10px solid #e5e7eb; border-top-color: #137333; border-right-color: #137333; border-radius: 50%; margin: 0 auto 16px; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                                <span style="font-size: 22px; font-weight: 700; color: #111827;"><asp:Literal ID="litPieAvg" runat="server" Text="0%" /></span>
                                <span style="font-size: 11px; color: #6b7280;">Average</span>
                            </div>

                            <div style="text-align: left; display: flex; flex-direction: column; gap: 8px; border-top: 1px solid #f3f4f6; padding-top: 14px; font-size: 13px;">
                                <div style="display: flex; justify-content: space-between; align-items: center;">
                                    <span style="display: flex; align-items: center; gap: 6px;"><span style="width: 8px; height: 8px; background: #137333; border-radius: 50%;"></span> Completed</span>
                                    <span style="font-weight: 600; color: #374151;"><asp:Literal ID="litCountCompleted" runat="server" Text="0" /></span>
                                </div>
                                <div style="display: flex; justify-content: space-between; align-items: center;">
                                    <span style="display: flex; align-items: center; gap: 6px;"><span style="width: 8px; height: 8px; background: #2563eb; border-radius: 50%;"></span> In Progress / Review</span>
                                    <span style="font-weight: 600; color: #374151;"><asp:Literal ID="litCountInProgress" runat="server" Text="0" /></span>
                                </div>
                            </div>
                        </div>

                        <!-- Upcoming Deadlines Widget -->
                        <div style="background: #fff; border: 1px solid #e5e7eb; border-radius: 12px; padding: 20px;">
                            <h3 style="font-size: 15px; font-weight: 700; color: #111827; margin-bottom: 14px;">Upcoming Deadlines</h3>

                            <asp:Repeater ID="rptDeadlines" runat="server">
                                <ItemTemplate>
                                    <div style="display: flex; justify-content: space-between; align-items: center; padding-bottom: 10px; margin-bottom: 10px; border-bottom: 1px solid #f3f4f6;">
                                        <div>
                                            <strong style="font-size: 13px; color: #111827; display: block;"><%# Eval("Title") %></strong>
                                            <small style="color: #6b7280; font-size: 11px;">Due: <%# Convert.ToDateTime(Eval("Deadline")).ToString("dd MMM yyyy") %></small>
                                        </div>
                                        <span style='<%# GetDeadlineBadgeStyle(Eval("Status").ToString(), Eval("Deadline")) %>'><%# GetDeadlineLabel(Eval("Status").ToString(), Eval("Deadline")) %></span>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                    </div>

                </div>

            </div>
        </section>
    </div>
</asp:Content>
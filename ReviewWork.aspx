<%@ Page Title="Review Work - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="ReviewWork.aspx.cs"
    Inherits="FreeHubProject.ReviewWork" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="freehub-dashboard-layout">
        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">
            <div class="review-work-container" style="max-width: 800px; margin: 30px auto; background: #ffffff; padding: 32px; border-radius: 12px; border: 1px solid #e8ece8; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
                
                <h2 style="color: #173f2c; margin-bottom: 8px;">Review Submitted Work</h2>
                <p style="color: #5a6e5f; margin-bottom: 24px; font-size: 14px;">Review the freelancer's submission and approve to complete the project and release payment.</p>

                <!-- Status Banner -->
                <asp:Panel ID="pnlStatus" runat="server" Visible="false" Style="padding: 12px 16px; border-radius: 8px; margin-bottom: 24px; font-size: 14px;">
                    <asp:Label ID="lblStatus" runat="server"></asp:Label>
                </asp:Panel>

                <!-- Project & Submission Info -->
                <div style="background: #f9fbf9; border: 1px solid #e0e8e2; padding: 20px; border-radius: 10px; margin-bottom: 24px;">
                    <div style="display: flex; justify-content: space-between; margin-bottom: 12px;">
                        <span style="font-size: 13px; color: #5a6e5f; text-transform: uppercase;">Project Title</span>
                        <span style="font-size: 13px; color: #5a6e5f; text-transform: uppercase;">Agreed Budget</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px;">
                        <h3 style="color: #173f2c; font-size: 18px; margin: 0;"><asp:Label ID="lblProjectTitle" runat="server" /></h3>
                        <span style="font-size: 20px; font-weight: bold; color: #173f2c;"><asp:Label ID="lblProjectBudget" runat="server" /></span>
                    </div>

                    <div style="border-top: 1px solid #e0e8e2; padding-top: 16px;">
                        <strong style="color: #243328; display: block; margin-bottom: 6px; font-size: 14px;">Freelancer:</strong>
                        <p style="margin-bottom: 16px; font-size: 14px; color: #374638;"><asp:Label ID="lblFreelancerName" runat="server" /></p>

                        <strong style="color: #243328; display: block; margin-bottom: 6px; font-size: 14px;">Submission Details & Deliverable Links:</strong>
                        <div style="background: white; border: 1px solid #d1d9d3; padding: 14px; border-radius: 8px; font-size: 14px; white-space: pre-line; color: #243328; margin-bottom: 12px;">
                            <asp:Label ID="lblSubmissionContent" runat="server" />
                        </div>
                    </div>
                </div>

                <!-- Rating Section (Mandatory upon Approval) -->
                <asp:Panel ID="pnlRating" runat="server" Style="margin-bottom: 24px;">
                    <h4 style="color: #173f2c; margin-bottom: 8px;">Rate & Review Freelancer</h4>
                    <p style="color: #5a6e5f; font-size: 13px; margin-bottom: 12px;">Leave feedback for the freelancer before completing the project.</p>

                    <div style="margin-bottom: 16px;">
                        <label style="font-weight: 600; font-size: 13px; color: #374638; display: block; margin-bottom: 6px;">Star Rating (1 - 5)</label>
                        <asp:DropDownList ID="ddlRatingScore" runat="server" Style="padding: 10px; border-radius: 8px; border: 1px solid #d1d9d3; width: 100%; max-width: 200px;">
                            <asp:ListItem Text="⭐⭐⭐⭐⭐ (5 - Excellent)" Value="5" Selected="True" />
                            <asp:ListItem Text="⭐⭐⭐⭐ (4 - Good)" Value="4" />
                            <asp:ListItem Text="⭐⭐⭐ (3 - Average)" Value="3" />
                            <asp:ListItem Text="⭐⭐ (2 - Poor)" Value="2" />
                            <asp:ListItem Text="⭐ (1 - Terrible)" Value="1" />
                        </asp:DropDownList>
                    </div>

                    <div>
                        <label style="font-weight: 600; font-size: 13px; color: #374638; display: block; margin-bottom: 6px;">Feedback Comment</label>
                        <asp:TextBox ID="txtRatingComment" runat="server" TextMode="MultiLine" Rows="3" Style="width: 100%; padding: 10px; border-radius: 8px; border: 1px solid #d1d9d3; font-size: 14px;" placeholder="Great communication, delivered on time..." />
                    </div>
                </asp:Panel>

                <!-- Actions -->
                <div style="display: flex; gap: 12px;">
                    <asp:Button ID="btnApproveWork" runat="server" Text="Approve Work & Release Payment 💳" OnClick="btnApproveWork_Click" Style="background-color: #173f2c; color: white; border: none; padding: 12px 24px; border-radius: 8px; font-weight: 600; cursor: pointer;" />
                    <asp:Button ID="btnRequestRevision" runat="server" Text="Request Revision / Reject" OnClick="btnRequestRevision_Click" Style="background-color: #d97706; color: white; border: none; padding: 12px 24px; border-radius: 8px; font-weight: 600; cursor: pointer;" />
                    <asp:Button ID="btnCancel" runat="server" Text="Back to My Projects" OnClick="btnCancel_Click" CausesValidation="false" Style="background: none; border: 1px solid #d1d9d3; padding: 12px 24px; border-radius: 8px; cursor: pointer;" />
                </div>

            </div>
        </section>
    </div>
</asp:Content>
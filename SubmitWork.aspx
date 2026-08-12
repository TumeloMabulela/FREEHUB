<%@ Page Title="Submit Project Work"
    Language="C me"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="SubmitWork.aspx.cs"
    Inherits="FreeHubProject.SubmitWork" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="freehub-dashboard-layout">
        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">
            <div class="submit-work-container" style="max-width: 700px; margin: 30px auto; background: #ffffff; padding: 30px; border-radius: 12px; border: 1px solid #e0e0e0;">
                
                <h2>Submit Completed Work</h2>
                <p style="color: #666; margin-bottom: 20px;">Submit your final work, links, or notes to the employer for review.</p>

                <!-- Status Message -->
                <asp:Panel ID="pnlStatus" runat="server" Visible="false" Style="padding: 12px; border-radius: 6px; margin-bottom: 20px;">
                    <asp:Label ID="lblStatus" runat="server"></asp:Label>
                </asp:Panel>

                <div class="form-group" style="margin-bottom: 16px;">
                    <label style="font-weight: bold; display: block; margin-bottom: 6px;">Project Title</label>
                    <asp:TextBox ID="txtProjectTitle" runat="server" CssClass="form-control" ReadOnly="true" Style="width: 100%; padding: 10px; border-radius: 6px; border: 1px solid #ccc; background: #f9f9f9;"></asp:TextBox>
                </div>

                <div class="form-group" style="margin-bottom: 16px;">
                    <label style="font-weight: bold; display: block; margin-bottom: 6px;">Work Deliverable Links / URLs <span style="color:red;">*</span></label>
                    <asp:TextBox ID="txtDeliverableLinks" runat="server" CssClass="form-control" placeholder="e.g. GitHub repository, Google Drive link, Figma design link" Style="width: 100%; padding: 10px; border-radius: 6px; border: 1px solid #ccc;"></asp:TextBox>
                </div>

                <div class="form-group" style="margin-bottom: 20px;">
                    <label style="font-weight: bold; display: block; margin-bottom: 6px;">Submission Notes / Comments <span style="color:red;">*</span></label>
                    <asp:TextBox ID="txtSubmissionNotes" runat="server" TextMode="MultiLine" Rows="5" CssClass="form-control" placeholder="Explain what was completed, instructions for the employer, etc." Style="width: 100%; padding: 10px; border-radius: 6px; border: 1px solid #ccc;"></asp:TextBox>
                </div>

                <div style="display: flex; gap: 12px;">
                    <asp:Button ID="btnSubmitWork" runat="server" Text="Submit Work for Review 🚀" OnClick="btnSubmitWork_Click" Style="background: #173f2c; color: white; border: none; padding: 12px 24px; border-radius: 6px; font-weight: bold; cursor: pointer;" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click" CausesValidation="false" Style="background: #ccc; color: #333; border: none; padding: 12px 24px; border-radius: 6px; cursor: pointer;" />
                </div>

            </div>
        </section>
    </div>
</asp:Content>
<%@ Page Title="Verify Email - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="VerifyEmail.aspx.cs"
    Inherits="FreeHubProject.VerifyEmail" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <section class="verify-page" style="min-height: 80vh; display: flex; align-items: center; justify-content: center; padding: 40px 20px;">
        <div style="max-width: 460px; width: 100%; text-align: center; background: white; padding: 40px 30px; border-radius: 14px; border: 1px solid #e8ece8; box-shadow: 0 4px 16px rgba(0,0,0,0.06);">

            <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
                <div style="width: 60px; height: 60px; border-radius: 50%; background: #e8f5e0; color: #16a34a; display: flex; align-items: center; justify-content: center; font-size: 28px; margin: 0 auto 20px;">&#10003;</div>
                <h2 style="color: #173f2c; margin-bottom: 10px;">Email Verified!</h2>
                <p style="color: #555; font-size: 14px; line-height: 1.6; margin-bottom: 24px;">
                    Your email has been verified successfully. You can now log in to your account.
                </p>
                <a href="Login.aspx" style="display: inline-block; background: #173f2c; color: white; padding: 12px 32px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 14px;">Go to Login</a>
            </asp:Panel>

            <asp:Panel ID="pnlError" runat="server" Visible="false">
                <div style="width: 60px; height: 60px; border-radius: 50%; background: #fee2e2; color: #dc2626; display: flex; align-items: center; justify-content: center; font-size: 28px; margin: 0 auto 20px;">&#10007;</div>
                <h2 style="color: #173f2c; margin-bottom: 10px;">Verification Failed</h2>
                <p style="color: #555; font-size: 14px; line-height: 1.6; margin-bottom: 24px;">
                    <asp:Label ID="lblError" runat="server" />
                </p>
                <a href="Login.aspx" style="display: inline-block; background: #173f2c; color: white; padding: 12px 32px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 14px;">Go to Login</a>
            </asp:Panel>

        </div>
    </section>

</asp:Content>

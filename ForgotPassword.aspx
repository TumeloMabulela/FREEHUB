<%@ Page Title="Forgot Password - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="ForgotPassword.aspx.cs"
    Inherits="FreeHubProject.ForgotPassword" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <section style="min-height: 80vh; display: flex; align-items: center; justify-content: center; padding: 40px 20px;">
        <div style="max-width: 440px; width: 100%; background: white; padding: 40px 30px; border-radius: 14px; border: 1px solid #e8ece8; box-shadow: 0 4px 16px rgba(0,0,0,0.06);">

            <h2 style="color: #173f2c; font-size: 22px; margin-bottom: 8px; text-align: center;">Forgot your password?</h2>
            <p style="color: #666; font-size: 14px; text-align: center; margin-bottom: 28px; line-height: 1.5;">
                Enter your email address and we'll send you a link to reset your password.
            </p>

            <div style="margin-bottom: 18px;">
                <label style="display: block; font-size: 13px; font-weight: 600; color: #374638; margin-bottom: 6px;">Email Address</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="form-input"
                    placeholder="Enter your email address" style="width: 100%; padding: 12px 14px; border: 1px solid #d1d9d3; border-radius: 8px; font-size: 14px;" />
            </div>

            <asp:Button ID="btnSendReset" runat="server" Text="Send Reset Link"
                OnClick="btnSendReset_Click"
                style="width: 100%; padding: 14px; background: #173f2c; color: white; border: none; border-radius: 8px; font-size: 15px; font-weight: 600; cursor: pointer;" />

            <asp:Label ID="lblMessage" runat="server" style="display: block; margin-top: 16px; font-size: 14px; text-align: center;" />

            <p style="text-align: center; margin-top: 24px; font-size: 13px; color: #666;">
                Remember your password? <a href="Login.aspx" style="color: #2563eb; text-decoration: none; font-weight: 600;">Log In</a>
            </p>

        </div>
    </section>

</asp:Content>

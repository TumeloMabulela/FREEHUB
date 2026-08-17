<%@ Page Title="Reset Password - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="ResetPassword.aspx.cs"
    Inherits="FreeHubProject.ResetPassword" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <section style="min-height: 80vh; display: flex; align-items: center; justify-content: center; padding: 40px 20px;">
        <div style="max-width: 440px; width: 100%; background: white; padding: 40px 30px; border-radius: 14px; border: 1px solid #e8ece8; box-shadow: 0 4px 16px rgba(0,0,0,0.06);">

            <!-- Reset Form -->
            <asp:Panel ID="pnlReset" runat="server">
                <h2 style="color: #173f2c; font-size: 22px; margin-bottom: 8px; text-align: center;">Create new password</h2>
                <p style="color: #666; font-size: 14px; text-align: center; margin-bottom: 28px; line-height: 1.5;">
                    Enter your new password below.
                </p>

                <div style="margin-bottom: 18px;">
                    <label style="display: block; font-size: 13px; font-weight: 600; color: #374638; margin-bottom: 6px;">New Password</label>
                    <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password"
                        placeholder="Enter new password" style="width: 100%; padding: 12px 14px; border: 1px solid #d1d9d3; border-radius: 8px; font-size: 14px;" />
                </div>

                <div style="margin-bottom: 18px;">
                    <label style="display: block; font-size: 13px; font-weight: 600; color: #374638; margin-bottom: 6px;">Confirm New Password</label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password"
                        placeholder="Confirm new password" style="width: 100%; padding: 12px 14px; border: 1px solid #d1d9d3; border-radius: 8px; font-size: 14px;" />
                </div>

                <asp:Button ID="btnResetPassword" runat="server" Text="Reset Password"
                    OnClick="btnResetPassword_Click"
                    style="width: 100%; padding: 14px; background: #173f2c; color: white; border: none; border-radius: 8px; font-size: 15px; font-weight: 600; cursor: pointer;" />

                <asp:Label ID="lblMessage" runat="server" style="display: block; margin-top: 16px; font-size: 14px; text-align: center;" />
            </asp:Panel>

            <!-- Success Message -->
            <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
                <div style="text-align: center;">
                    <div style="width: 60px; height: 60px; border-radius: 50%; background: #e8f5e0; color: #16a34a; display: flex; align-items: center; justify-content: center; font-size: 28px; margin: 0 auto 20px;">&#10003;</div>
                    <h2 style="color: #173f2c; margin-bottom: 10px;">Password Reset!</h2>
                    <p style="color: #555; font-size: 14px; line-height: 1.6; margin-bottom: 24px;">
                        Your password has been updated successfully. You can now log in with your new password.
                    </p>
                    <a href="Login.aspx" style="display: inline-block; background: #173f2c; color: white; padding: 12px 32px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 14px;">Go to Login</a>
                </div>
            </asp:Panel>

            <!-- Invalid Token -->
            <asp:Panel ID="pnlInvalid" runat="server" Visible="false">
                <div style="text-align: center;">
                    <div style="width: 60px; height: 60px; border-radius: 50%; background: #fee2e2; color: #dc2626; display: flex; align-items: center; justify-content: center; font-size: 28px; margin: 0 auto 20px;">&#10007;</div>
                    <h2 style="color: #173f2c; margin-bottom: 10px;">Link Expired</h2>
                    <p style="color: #555; font-size: 14px; line-height: 1.6; margin-bottom: 24px;">
                        This reset link is invalid or has expired. Please request a new one.
                    </p>
                    <a href="ForgotPassword.aspx" style="display: inline-block; background: #173f2c; color: white; padding: 12px 32px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 14px;">Request New Link</a>
                </div>
            </asp:Panel>

        </div>
    </section>

</asp:Content>

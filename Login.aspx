<%@ Page Title="Log In - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="Login.aspx.cs"
    Inherits="FreeHubProject.Login" %>

<asp:Content ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">
</asp:Content>

<asp:Content ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <section class="fssb-login-page">

        <div class="fssb-login-container">

            <!-- LEFT FREEHUB BRAND CARD -->

            <div class="fssb-brand-card">

                <div class="brand-logo-icon">
                    ➤
                </div>

                <h1>
                    FreeHub
                </h1>

                <p>
                    CONNECTING FREELANCERS
                </p>

            </div>


            <!-- RIGHT LOGIN FORM -->

            <div class="fssb-login-form-area">

                <div class="fssb-login-form">

                    <h2>
                        LOG IN
                    </h2>


                    <!-- USERNAME OR EMAIL -->

                    <div class="fssb-input-group">

                        <asp:TextBox
                            ID="txtLoginEmail"
                            runat="server"
                            CssClass="fssb-login-input"
                            placeholder="Username or Email">
                        </asp:TextBox>

                    </div>


                    <!-- PASSWORD -->

                    <div class="fssb-input-group password-input-group">

                        <asp:TextBox
                            ID="txtLoginPassword"
                            runat="server"
                            TextMode="Password"
                            CssClass="fssb-login-input"
                            placeholder="Enter password">
                        </asp:TextBox>

                        <span class="password-eye">
                            ●
                        </span>

                    </div>


                    <!-- REMEMBER AND FORGOT PASSWORD -->

                    <div class="fssb-login-options">

                        <label class="fssb-remember">

                            <asp:CheckBox
                                ID="chkRemember"
                                runat="server" />

                            <span>
                                Remember me
                            </span>

                        </label>


                        <a href="#"
                            class="fssb-forgot-password">

                            Forgot Password?

                        </a>

                    </div>


                    <!-- LOGIN BUTTON -->

                    <asp:Button
                        ID="btnLogin"
                        runat="server"
                        Text="LOG IN"
                        CssClass="fssb-login-button"
                        OnClick="btnLogin_Click" />


                    <!-- MESSAGE -->

                    <asp:Label
                        ID="lblLoginMessage"
                        runat="server"
                        CssClass="fssb-login-message">
                    </asp:Label>


                    <!-- REGISTER -->

                    <p class="fssb-register-question">

                        Don't have an account?

                        <a href="Register.aspx">
                            Sign up
                        </a>

                    </p>

                </div>

            </div>

        </div>

    </section>

</asp:Content>
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

                        <button type="button" class="password-eye" onclick="toggleLoginPassword()" aria-label="Show password">
                            <svg class="eye-show" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                            <svg class="eye-hide" style="display:none;" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
                        </button>

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

    <style>
        .password-input-group {
            position: relative;
        }

        .password-eye {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: rgba(255,255,255,0.7);
            padding: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .password-eye:hover {
            color: white;
        }
    </style>

    <script type="text/javascript">
        function toggleLoginPassword() {
            var field = document.getElementById('<%= txtLoginPassword.ClientID %>');
            var btn = document.querySelector('.password-eye');
            var eyeShow = btn.querySelector('.eye-show');
            var eyeHide = btn.querySelector('.eye-hide');

            if (field.type === 'password') {
                field.type = 'text';
                eyeShow.style.display = 'none';
                eyeHide.style.display = 'block';
            } else {
                field.type = 'password';
                eyeShow.style.display = 'block';
                eyeHide.style.display = 'none';
            }
        }
    </script>

</asp:Content>
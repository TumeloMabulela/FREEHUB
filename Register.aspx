<%@ Page Title="Register - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="Register.aspx.cs"
    Inherits="FreeHubProject.Register" %>

<asp:Content ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">
</asp:Content>


<asp:Content ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <section class="register-page">

        <div class="register-container">

            <!-- LEFT SIDE -->

            <div class="register-information">

                <p class="register-small-title">
                    JOIN FREEHUB
                </p>

                <h1>
                    Create your account and start connecting.
                </h1>

                <p class="register-description">
                    Join a platform where talented freelancers and
                    employers can connect, collaborate and build
                    successful projects together.
                </p>

                <div class="register-benefits">

                    <div class="benefit-item">

                        <div class="benefit-icon">
                            ✓
                        </div>

                        <div>
                            <h3>
                                Find opportunities
                            </h3>

                            <p>
                                Discover projects that match your skills.
                            </p>
                        </div>

                    </div>


                    <div class="benefit-item">

                        <div class="benefit-icon">
                            ✓
                        </div>

                        <div>
                            <h3>
                                Connect with talent
                            </h3>

                            <p>
                                Find skilled freelancers for your projects.
                            </p>
                        </div>

                    </div>


                    <div class="benefit-item">

                        <div class="benefit-icon">
                            ✓
                        </div>

                        <div>
                            <h3>
                                Build your reputation
                            </h3>

                            <p>
                                Complete projects and receive ratings.
                            </p>
                        </div>

                    </div>

                </div>

            </div>


            <!-- RIGHT SIDE -->

            <div class="register-card">

                <div class="register-card-heading">

                    <h2>
                        Create an account
                    </h2>

                    <p>
                        Get started with FreeHUB in seconds.
                    </p>

                </div>


                <!-- FORM -->

                <div class="register-form">

                    <p class="required-note">
                        Fields marked with
                        <span class="required-star">*</span>
                        are required.
                    </p>

                    <div class="form-row">

                        <div class="form-group">

                            <label>
                                First Name
                                <span class="required-star">*</span>
                            </label>

                            <asp:TextBox
                                ID="txtFirstName"
                                runat="server"
                                CssClass="form-input"
                                placeholder="Enter your first name">
                            </asp:TextBox>

                        </div>


                        <div class="form-group">

                            <label>
                                Last Name
                                <span class="required-star">*</span>
                            </label>

                            <asp:TextBox
                                ID="txtLastName"
                                runat="server"
                                CssClass="form-input"
                                placeholder="Enter your last name">
                            </asp:TextBox>

                        </div>

                    </div>


                    <div class="form-group">

                        <label>
                            Email Address
                            <span class="required-star">*</span>
                        </label>

                        <asp:TextBox
                            ID="txtEmail"
                            runat="server"
                            TextMode="Email"
                            CssClass="form-input"
                            placeholder="Enter your email address">
                        </asp:TextBox>

                    </div>


                    <div class="form-group">

                        <label>
                            Password
                            <span class="required-star">*</span>
                        </label>

                        <div style="position:relative;">
                            <asp:TextBox
                                ID="txtPassword"
                                runat="server"
                                TextMode="Password"
                                CssClass="form-input"
                                placeholder="Create a password"
                                style="padding-right:44px;">
                            </asp:TextBox>
                            <button type="button" class="reg-eye-toggle" onclick="toggleRegPassword('txtPassword', this)" aria-label="Show password">
                                <svg class="eye-show" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                <svg class="eye-hide" style="display:none;" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
                            </button>
                        </div>

                    </div>


                    <div class="form-group">

                        <label>
                            Confirm Password
                            <span class="required-star">*</span>
                        </label>

                        <div style="position:relative;">
                            <asp:TextBox
                                ID="txtConfirmPassword"
                                runat="server"
                                TextMode="Password"
                                CssClass="form-input"
                                placeholder="Confirm your password"
                                style="padding-right:44px;">
                            </asp:TextBox>
                            <button type="button" class="reg-eye-toggle" onclick="toggleRegPassword('txtConfirmPassword', this)" aria-label="Show password">
                                <svg class="eye-show" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                <svg class="eye-hide" style="display:none;" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
                            </button>
                        </div>

                    </div>


                    <div class="terms-row">

                        <asp:CheckBox
                            ID="chkTerms"
                            runat="server" />

                        <span>
                            I agree to the
                            <a href="TermsAndConditions.aspx" target="_blank">
                                Terms and Conditions
                            </a>
                            and
                            <a href="PrivacyPolicy.aspx" target="_blank">
                                Privacy Policy
                            </a>.
                            <span class="required-star">*</span>
                        </span>

                    </div>


                    <asp:Button
                        ID="btnRegister"
                        runat="server"
                        Text="Create Account"
                        CssClass="create-account-button"
                        OnClick="btnRegister_Click" />


                    <asp:Label
                        ID="lblMessage"
                        runat="server"
                        CssClass="register-message">
                    </asp:Label>


                    <p class="login-question">

                        Already have an account?

                        <a href="Login.aspx">
                            Log In
                        </a>

                    </p>

                </div>

            </div>

        </div>

    </section>

    <style>
        /* ===== Fit the Sign Up page within the fixed-shell middle (between the fixed
           header and footer) so there's no page scrollbar at standard desktop sizes.
           The shared .register-page set min-height:760px + 85px vertical padding, far
           taller than the available middle, which forced the overflow. Here we fill
           the middle, centre both columns, and compress the card/benefit spacing to
           professional-but-tight values. All page-scoped (register-* classes). ===== */

        .register-page {
            min-height: 100%;          /* fill the shell middle, not a fixed 760px */
            height: 100%;              /* bound to the shell middle so nothing overflows it */
            padding: 12px 8%;          /* was 85px 8% */
            box-sizing: border-box;
            display: flex;
            align-items: center;       /* vertically centre the two columns */
            justify-content: center;
            overflow: hidden;          /* content below is sized to fit, so no scroll here */
        }

        /* Keep both columns vertically centred and aligned. */
        .register-container { align-items: center; gap: 56px; }

        /* LEFT: trim vertical rhythm so the three benefits + intro fit compactly. */
        .register-information { padding: 0; }
        .register-information h1 { font-size: 42px; margin-bottom: 16px; }
        .register-small-title { margin-bottom: 12px; }
        .register-description { font-size: 16px; line-height: 1.6; margin-bottom: 22px; }
        .register-benefits { gap: 16px; }

        /* RIGHT: a more compact card so the whole form clears the footer.
           Trimmed ~20–30px of vertical height vs. the previous pass. */
        .register-card { padding: 16px 30px; }
        .register-card-heading { margin-bottom: 10px; }
        .register-card-heading h2 { font-size: 28px; }

        .form-row { gap: 14px; }
        .form-group { margin-bottom: 9px; }
        .form-group label { margin-bottom: 4px; }

        /* Consistent ~45px input height (padding 12px + 1px borders + ~19px line). */
        .form-input { padding: 12px 14px; }

        .required-note { margin-bottom: 6px; }
        .terms-row { margin: 2px 0 12px; }
        .create-account-button { padding: 13px; }
        .login-question { margin-top: 10px; margin-bottom: 0; }

        /* Responsive: on stacked (narrow) layouts the content legitimately needs more
           room, so stop forcing full-middle height and let it flow / scroll naturally
           rather than clip. */
        @media screen and (max-width: 1000px) {
            .register-page {
                min-height: 100%;
                height: auto;
                display: block;
                padding: 40px 6%;
                overflow: visible;   /* allow natural scrolling when stacked */
            }
        }

        /* Red asterisk marking compulsory fields */
        .required-star {
            color: #dc3545;
            font-weight: 700;
            margin-left: 2px;
        }

        .required-note {
            font-size: 13px;
            color: #666;
            /* margin-bottom set in the compact overrides above */
        }

        /* Suppress the browser's NATIVE password reveal/clear controls (Edge/IE inject
           their own eye via ::-ms-reveal once a password field has text) so each field
           shows ONLY the custom .reg-eye-toggle icon. */
        .register-form input::-ms-reveal,
        .register-form input::-ms-clear {
            display: none;
            width: 0;
            height: 0;
        }

        .reg-eye-toggle {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: #666;
            padding: 4px;
            display: flex;
            align-items: center;
        }
        .reg-eye-toggle:hover { color: #173f2c; }
    </style>

    <script type="text/javascript">
        function toggleRegPassword(fieldId, btn) {
            var field = document.getElementById('<%= txtPassword.ClientID %>');
            if (fieldId === 'txtConfirmPassword') {
                field = document.getElementById('<%= txtConfirmPassword.ClientID %>');
            }
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
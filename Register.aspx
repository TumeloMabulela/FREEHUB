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

                    <div class="form-group">

                        <label>
                            Email Address
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
                        </label>

                        <asp:TextBox
                            ID="txtPassword"
                            runat="server"
                            TextMode="Password"
                            CssClass="form-input"
                            placeholder="Create a password">
                        </asp:TextBox>

                    </div>


                    <div class="form-group">

                        <label>
                            Confirm Password
                        </label>

                        <asp:TextBox
                            ID="txtConfirmPassword"
                            runat="server"
                            TextMode="Password"
                            CssClass="form-input"
                            placeholder="Confirm your password">
                        </asp:TextBox>

                    </div>


                    <div class="terms-row">

                        <asp:CheckBox
                            ID="chkTerms"
                            runat="server" />

                        <span>
                            I agree to the
                            <a href="#">
                                Terms and Conditions
                            </a>
                            and
                            <a href="#">
                                Privacy Policy
                            </a>.
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




</asp:Content>
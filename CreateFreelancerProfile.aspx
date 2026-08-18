<%@ Page Title="Create Freelancer Profile - FreeHUB"
    Language="C#"
    AutoEventWireup="true"
    CodeBehind="CreateFreelancerProfile.aspx.cs"
    Inherits="FreeHubProject.CreateFreelancerProfile" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Create Freelancer Profile - FreeHUB</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, Helvetica, sans-serif; background-color: #f5f7f5; color: #243328; line-height: 1.6; min-height: 100vh; }

        .top-nav { width: 100%; background: linear-gradient(90deg, #148b97 0%, #2fa86d 50%, #72c94b 100%); padding: 0 30px; display: flex; align-items: center; justify-content: space-between; min-height: 65px; }
        .top-nav .logo { color: white; text-decoration: none; font-size: 26px; font-weight: bold; letter-spacing: 1px; }
        .top-nav .logo span { color: #b7d68c; }
        .top-nav .nav-btn { color: white; background: none; border: 1px solid rgba(255,255,255,0.3); padding: 8px 18px; border-radius: 6px; cursor: pointer; font-size: 14px; text-decoration: none; transition: all 0.2s; }
        .top-nav .nav-btn:hover { background: rgba(255,255,255,0.1); border-color: rgba(255,255,255,0.6); }

        /* Progress */
        .progress-steps { display: flex; align-items: center; justify-content: center; margin: 36px 0 24px; gap: 0; }
        .step { display: flex; flex-direction: column; align-items: center; gap: 8px; }
        .step-circle { width: 38px; height: 38px; border-radius: 50%; background: #e8ece8; color: #888; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: 700; border: 2px solid #d1d9d3; }
        .step.active .step-circle { background: #173f2c; color: white; border-color: #173f2c; }
        .step.completed .step-circle { background: #16a34a; color: white; border-color: #16a34a; }
        .step-label { font-size: 12px; color: #888; font-weight: 500; white-space: nowrap; }
        .step.active .step-label { color: #173f2c; font-weight: 600; }
        .step.completed .step-label { color: #16a34a; font-weight: 600; }
        .step-line { width: 60px; height: 3px; background: #e0e0e0; margin: 0 8px; margin-bottom: 28px; border-radius: 2px; }
        .step-line.completed { background: #16a34a; }

        .container { max-width: 600px; margin: 0 auto; padding: 0 20px 60px; }
        .container h1 { font-size: 24px; color: #173f2c; margin-bottom: 6px; text-align: center; }
        .container > p { color: #5a6e5f; font-size: 14px; margin-bottom: 30px; text-align: center; }

        .create-form { background: white; border-radius: 14px; padding: 32px 28px; border: 1px solid #e8ece8; }
        .form-field { margin-bottom: 18px; }
        .form-field label { display: block; font-size: 13px; font-weight: 600; color: #374638; margin-bottom: 6px; }
        .form-field label span { color: #dc2626; }
        .form-input { width: 100%; padding: 11px 14px; border: 1px solid #d1d9d3; border-radius: 8px; font-size: 14px; transition: border-color 0.2s; }
        .form-input:focus { outline: none; border-color: #b7d68c; }
        .form-textarea { width: 100%; padding: 11px 14px; border: 1px solid #d1d9d3; border-radius: 8px; font-size: 14px; resize: vertical; min-height: 100px; font-family: Arial, sans-serif; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .readonly-input { background-color: #f5f5f5; cursor: not-allowed; }
        .form-actions { display: flex; gap: 12px; margin-top: 24px; }
        .btn-submit { flex: 1; background-color: #173f2c; color: white; padding: 14px; border: none; border-radius: 8px; font-size: 15px; font-weight: 600; cursor: pointer; transition: background 0.2s; }
        .btn-submit:hover { background-color: #1f5438; }
        .btn-cancel { flex: 0; background: none; border: 1px solid #d1d9d3; padding: 14px 24px; border-radius: 8px; font-size: 14px; cursor: pointer; color: #555; transition: all 0.2s; }
        .btn-cancel:hover { border-color: #173f2c; color: #173f2c; }
        .msg { margin-top: 14px; font-size: 14px; text-align: center; }
        .msg-error { color: #dc2626; }
        .msg-success { color: #16a34a; }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <div class="top-nav">
            <a href="ChooseRole.aspx" class="logo">Free<span>HUB</span></a>
            <a href="ChooseRole.aspx" class="nav-btn">&#8592; Back</a>
        </div>

        <div class="container">

            <div class="progress-steps">
                <div class="step completed"><div class="step-circle">&#10003;</div><span class="step-label">Create Account</span></div>
                <div class="step-line completed"></div>
                <div class="step completed"><div class="step-circle">&#10003;</div><span class="step-label">Choose Role</span></div>
                <div class="step-line completed"></div>
                <div class="step active"><div class="step-circle">3</div><span class="step-label">Complete Profile</span></div>
            </div>

            <h1>Create Freelancer Profile</h1>
            <p>Fill in your details to start finding work on FreeHUB.</p>

            <div class="create-form">

                <div class="form-row">
                    <div class="form-field">
                        <label>First Name</label>
                        <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-input readonly-input" ReadOnly="true" />
                    </div>
                    <div class="form-field">
                        <label>Last Name</label>
                        <asp:TextBox ID="txtLastName" runat="server" CssClass="form-input readonly-input" ReadOnly="true" />
                    </div>
                </div>

                <div class="form-field">
                    <label>Profile Picture</label>
                    <asp:FileUpload ID="fuProfilePic" runat="server" CssClass="form-input" />
                </div>

                <div class="form-field">
                    <label>Bio / About Me</label>
                    <asp:TextBox ID="txtBio" runat="server" CssClass="form-textarea" TextMode="MultiLine" Rows="3" placeholder="Tell employers about yourself..." />
                </div>

                <div class="form-row">
                    <div class="form-field">
                        <label>Location / City</label>
                        <asp:TextBox ID="txtLocation" runat="server" CssClass="form-input" placeholder="e.g. Johannesburg, SA" />
                    </div>
                    <div class="form-field">
                        <label>Preferred Language</label>
                        <asp:DropDownList ID="ddlLanguage" runat="server" CssClass="form-input">
                            <asp:ListItem Text="Select Language" Value="" />
                            <asp:ListItem Text="English" Value="English" />
                            <asp:ListItem Text="Afrikaans" Value="Afrikaans" />
                            <asp:ListItem Text="Zulu" Value="Zulu" />
                            <asp:ListItem Text="Xhosa" Value="Xhosa" />
                            <asp:ListItem Text="Sotho" Value="Sotho" />
                            <asp:ListItem Text="Tswana" Value="Tswana" />
                            <asp:ListItem Text="Other" Value="Other" />
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="form-field">
                    <label>Skills <span>*</span></label>
                    <asp:TextBox ID="txtSkills" runat="server" CssClass="form-input" placeholder="e.g. Web Design, JavaScript, React" />
                </div>

                <div class="form-field">
                    <label>Work Experience</label>
                    <asp:TextBox ID="txtExperience" runat="server" CssClass="form-textarea" TextMode="MultiLine" Rows="3" placeholder="Describe your experience..." />
                </div>

                <div class="form-row">
                    <div class="form-field">
                        <label>Portfolio Links</label>
                        <asp:TextBox ID="txtPortfolio" runat="server" CssClass="form-input" placeholder="e.g. https://portfolio.com" />
                    </div>
                    <div class="form-field">
                        <label>Hourly Rate (ZAR) <span>*</span></label>
                        <asp:TextBox ID="txtHourlyRate" runat="server" CssClass="form-input" TextMode="Number" placeholder="e.g. 250" />
                    </div>
                </div>

                <div class="form-actions">
                    <asp:Button ID="btnSubmit" runat="server" Text="Create Profile" CssClass="btn-submit" OnClick="btnSubmit_Click" />
                    <a href="ChooseRole.aspx" class="btn-cancel">Cancel</a>
                </div>

                <asp:Label ID="lblMessage" runat="server" CssClass="msg" />

            </div>
        </div>

    </form>
</body>
</html>

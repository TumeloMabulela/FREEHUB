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

        .container { max-width: 600px; margin: 40px auto; padding: 0 20px 60px; }
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
        .back-link { display: inline-flex; align-items: center; gap: 6px; color: #173f2c; text-decoration: none; font-size: 14px; font-weight: 600; margin-bottom: 24px; padding: 10px 18px; border: 1px solid #d1d9d3; border-radius: 8px; }
        .back-link:hover { border-color: #173f2c; }
        .form-actions { display: flex; gap: 12px; margin-top: 24px; }
        .btn-submit { flex: 1; background-color: #173f2c; color: white; padding: 14px; border: none; border-radius: 8px; font-size: 15px; font-weight: 600; cursor: pointer; transition: background 0.2s; }
        .btn-submit:hover { background-color: #1f5438; }
        .btn-cancel { flex: 0; background: none; border: 1px solid #d1d9d3; padding: 14px 24px; border-radius: 8px; font-size: 14px; cursor: pointer; color: #555; text-decoration: none; display: flex; align-items: center; }
        .btn-cancel:hover { border-color: #173f2c; color: #173f2c; }
        .msg { margin-top: 14px; font-size: 14px; text-align: center; }
        .msg-error { color: #dc2626; }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <div class="top-nav">
            <a href="ChooseRole.aspx" class="logo">Free<span>HUB</span></a>
            <asp:LinkButton ID="btnLogout" runat="server" CssClass="nav-btn" OnClick="btnLogout_Click">Logout</asp:LinkButton>
        </div>

        <div class="container">

            <h1>Create Freelancer Profile</h1>
            <p>Fill in your details to start finding work on FreeHUB.</p>

            <div class="create-form">

                <a href="ChooseRole.aspx" class="back-link">&#8592; Back to Choose Role</a>

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

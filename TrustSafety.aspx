<%@ Page Title="Trust & Safety - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="TrustSafety.aspx.cs"
    Inherits="FreeHubProject.TrustSafety" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style type="text/css">
        .ts-section {
            background: #fff; border: 1px solid #e8ece9; border-radius: 12px;
            padding: 20px 22px; margin-bottom: 16px;
        }
        .ts-section h2 { color: #173f2c; font-size: 16px; margin: 0 0 10px; display: flex; align-items: center; gap: 10px; }
        .ts-section p { color: #5a6e62; font-size: 13px; line-height: 1.65; margin: 0 0 10px; }
        .ts-section ul { margin: 0; padding-left: 20px; color: #5a6e62; font-size: 13px; line-height: 1.7; }
        .ts-icon {
            width: 30px; height: 30px; border-radius: 8px; background: #e5f4ea; color: #2e7d56;
            display: inline-flex; align-items: center; justify-content: center; font-size: 15px; flex-shrink: 0;
        }
        .ts-cta {
            display: inline-block; margin-top: 4px; color: #2e7d56; border: 1.5px solid #2e7d56;
            padding: 8px 16px; border-radius: 22px; font-size: 13px; font-weight: 600; text-decoration: none;
        }
        .ts-cta:hover { background: #eaf6ee; }
    </style>

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <div class="post-page-heading">
                <div class="post-breadcrumb">
                    <a href="<%= ResolveUrl("~/Dashboard.aspx") %>" class="breadcrumb-link">Dashboard</a> <span>/</span>
                    <strong>Trust &amp; Safety</strong>
                </div>
                <h1>Trust &amp; Safety</h1>
                <p>How FreeHUB helps keep your account, projects and payments secure.</p>
            </div>

            <div style="max-width: 820px;">

                <div class="ts-section">
                    <h2><span class="ts-icon">&#128274;</span> Account Security</h2>
                    <p>Protect your FreeHUB account by keeping your login details private and choosing a strong, unique password.</p>
                    <ul>
                        <li>Never share your password with anyone, including people claiming to be support staff.</li>
                        <li>Log out when using shared or public devices.</li>
                        <li>Keep your profile contact details up to date so important notices reach you.</li>
                    </ul>
                </div>

                <div class="ts-section">
                    <h2><span class="ts-icon">&#128179;</span> Safe Project Transactions &amp; Escrow Protection</h2>
                    <p>Payments on FreeHUB flow through your in-platform wallet rather than directly between users. Funds are managed within the platform while work is in progress, so both sides are protected until a project reaches its agreed outcome.</p>
                    <ul>
                        <li>Keep all project agreements, payments and communication on FreeHUB.</li>
                        <li>Review a project's budget, deadline and scope before accepting or funding work.</li>
                        <li>Use your Wallet's transaction history to confirm every payment and withdrawal.</li>
                    </ul>
                </div>

                <div class="ts-section">
                    <h2><span class="ts-icon">&#9888;</span> Spotting Suspicious Activity</h2>
                    <p>Be cautious of anything that tries to move you off-platform or pressure you into quick payments. Common warning signs include:</p>
                    <ul>
                        <li>Requests to pay or be paid outside FreeHUB.</li>
                        <li>Offers that seem too good to be true, or urgent demands for upfront fees.</li>
                        <li>Messages asking for your password, banking login or verification codes.</li>
                        <li>Links to unfamiliar websites or requests to download unexpected files.</li>
                    </ul>
                </div>

                <div class="ts-section">
                    <h2><span class="ts-icon">&#128737;</span> Reporting &amp; Dispute Resolution</h2>
                    <p>If something goes wrong with a project or payment, you can raise a dispute for an administrator to review. You can also report a freelancer from the Ratings page after working with them.</p>
                    <a class="ts-cta" href="<%= ResolveUrl("~/Disputes.aspx") %>">Open Dispute Resolution</a>
                </div>

            </div>

        </section>

    </div>

</asp:Content>

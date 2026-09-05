<%@ Page Title="Privacy Policy - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="PrivacyPolicy.aspx.cs"
    Inherits="FreeHubProject.PrivacyPolicy" %>

<asp:Content ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">
    <style>
        .legal-page {
            max-width: 900px;
            margin: 40px auto;
            padding: 40px;
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
            color: #1f2937;
            line-height: 1.7;
        }

        .legal-page h1 {
            color: #173f2c;
            margin-bottom: 6px;
        }

        .legal-page .legal-updated {
            color: #6b7280;
            font-size: 0.9rem;
            margin-bottom: 28px;
        }

        .legal-page h2 {
            color: #173f2c;
            font-size: 1.2rem;
            margin-top: 28px;
            margin-bottom: 8px;
        }

        .legal-page p,
        .legal-page li {
            color: #374151;
            word-break: break-word;
        }

        .legal-page ul {
            padding-left: 22px;
        }

        .legal-back {
            display: inline-block;
            margin-top: 32px;
            color: #173f2c;
            font-weight: 600;
            text-decoration: none;
        }

        .legal-back:hover {
            text-decoration: underline;
        }
    </style>
</asp:Content>


<asp:Content ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <section class="legal-page">

        <h1>Privacy Policy</h1>
        <p class="legal-updated">Last updated: 18 August 2026</p>

        <p>
            This Privacy Policy explains how FreeHUB collects, uses, and protects
            your personal information when you use our platform. By using FreeHUB,
            you consent to the practices described below.
        </p>

        <h2>1. Information We Collect</h2>
        <ul>
            <li>
                <strong>Account information:</strong> your first name, last name,
                email address, and password.
            </li>
            <li>
                <strong>Profile information:</strong> details you add when creating a
                Freelancer or Employer profile, such as bio, location, preferred
                language, and profile picture.
            </li>
            <li>
                <strong>Activity information:</strong> projects you post, proposals
                you submit, messages, comments, and payment activity on the platform.
            </li>
        </ul>

        <h2>2. How We Use Your Information</h2>
        <ul>
            <li>To create and manage your account and profiles.</li>
            <li>To match Freelancers with Employers and enable project work.</li>
            <li>To process wallet funding, payments, refunds, and payouts.</li>
            <li>To communicate with you about your account and activity.</li>
            <li>To keep the platform secure and prevent misuse.</li>
        </ul>

        <h2>3. Sharing of Information</h2>
        <p>
            We do not sell your personal information. Certain profile and project
            details are visible to other users where necessary for the platform to
            function, for example a Freelancer's public profile is visible to
            Employers. Information under one account is kept separate between your
            Employer and Freelancer profiles where the platform requires it.
        </p>

        <h2>4. Data Security</h2>
        <p>
            We take reasonable measures to protect your information. However, no
            method of transmission or storage is completely secure, and you use the
            platform at your own risk.
        </p>

        <h2>5. Your Rights</h2>
        <p>
            You can view and update your profile information at any time, and you may
            deactivate your account. For requests relating to your personal data,
            contact us using the details below.
        </p>

        <h2>6. Changes to This Policy</h2>
        <p>
            We may update this Privacy Policy from time to time. Continued use of
            FreeHUB after changes take effect constitutes acceptance of the updated
            policy.
        </p>

        <h2>7. Contact</h2>
        <p>
            For any questions about this Privacy Policy, contact us at
            <a href="mailto:support@freehub.co.za">support@freehub.co.za</a>.
        </p>

        <a class="legal-back" href="Register.aspx">&#8249; Back to Registration</a>

    </section>

</asp:Content>

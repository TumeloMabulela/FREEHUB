<%@ Page Title="Terms and Conditions - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="TermsAndConditions.aspx.cs"
    Inherits="FreeHubProject.TermsAndConditions" %>

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

        <h1>Terms and Conditions</h1>
        <p class="legal-updated">Last updated: 18 August 2026</p>

        <p>
            Welcome to FreeHUB. These Terms and Conditions ("Terms") govern your
            access to and use of the FreeHUB platform, including creating an account,
            posting projects, submitting proposals, and processing payments. By
            registering for or using FreeHUB, you agree to be bound by these Terms.
            If you do not agree, please do not use the platform.
        </p>

        <h2>1. Eligibility</h2>
        <p>
            You must be at least 18 years old and legally able to enter into a
            binding contract to use FreeHUB. By creating an account you confirm that
            the information you provide is accurate and kept up to date.
        </p>

        <h2>2. Accounts and Roles</h2>
        <p>
            A single FreeHUB account may hold an Employer profile, a Freelancer
            profile, or both. You are responsible for maintaining the confidentiality
            of your login credentials and for all activity that occurs under your
            account.
        </p>

        <h2>3. Projects and Proposals</h2>
        <ul>
            <li>Employers may post projects describing the work required.</li>
            <li>Freelancers may submit proposals for open projects.</li>
            <li>
                You may not submit a proposal to a project posted under your own
                account.
            </li>
            <li>
                All project details, deliverables, and timelines are agreed between
                the Employer and the Freelancer.
            </li>
        </ul>

        <h2>4. Payments</h2>
        <p>
            Payments made through FreeHUB, including funding a wallet, releasing
            payment for completed work, refunds, and payouts, are subject to the
            processes shown on the platform. FreeHUB is not responsible for disputes
            arising outside of the platform's payment flow.
        </p>

        <h2>5. Acceptable Use</h2>
        <p>
            You agree not to use FreeHUB for any unlawful, fraudulent, or abusive
            purpose, and not to post content that is misleading, infringing, or
            harmful to others.
        </p>

        <h2>6. Termination</h2>
        <p>
            You may deactivate your account at any time. FreeHUB may suspend or
            terminate accounts that violate these Terms or that are used in a way
            that harms the platform or its users.
        </p>

        <h2>7. Changes to These Terms</h2>
        <p>
            We may update these Terms from time to time. Continued use of FreeHUB
            after changes take effect constitutes acceptance of the updated Terms.
        </p>

        <h2>8. Contact</h2>
        <p>
            For any questions about these Terms, contact us at
            <a href="mailto:support@freehub.co.za">support@freehub.co.za</a>.
        </p>

        <a class="legal-back" href="Register.aspx">&#8249; Back to Registration</a>

    </section>

</asp:Content>

<%@ Page Title="FAQs - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="FAQs.aspx.cs"
    Inherits="FreeHubProject.FAQs" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style type="text/css">
        /* Scoped FAQ styling — reuses FreeHUB's green/white palette. */
        .faq-category { margin-bottom: 26px; }
        .faq-category > h2 {
            color: #173f2c; font-size: 17px; font-weight: 700; margin: 0 0 12px;
        }
        .faq-item {
            background: #fff; border: 1px solid #e8ece9; border-radius: 10px;
            margin-bottom: 10px; overflow: hidden;
        }
        .faq-item > summary {
            list-style: none; cursor: pointer; padding: 14px 18px;
            font-size: 14px; font-weight: 600; color: #27364a;
            display: flex; align-items: center; justify-content: space-between; gap: 12px;
        }
        .faq-item > summary::-webkit-details-marker { display: none; }
        .faq-item > summary::after {
            content: "\002B"; color: #2e7d56; font-size: 18px; font-weight: 700; flex-shrink: 0;
        }
        .faq-item[open] > summary::after { content: "\2212"; }
        .faq-item > summary:hover { color: #12833f; }
        .faq-answer {
            padding: 0 18px 16px; color: #5a6e62; font-size: 13px; line-height: 1.6;
        }
    </style>

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <div class="post-page-heading">
                <div class="post-breadcrumb">
                    <a href="<%= ResolveUrl("~/Dashboard.aspx") %>" class="breadcrumb-link">Dashboard</a> <span>/</span>
                    <strong>FAQs</strong>
                </div>
                <h1>Frequently Asked Questions</h1>
                <p>Answers to common questions about accounts, projects, proposals, payments and withdrawals.</p>
            </div>

            <div style="max-width: 820px;">

                <!-- ACCOUNTS -->
                <div class="faq-category">
                    <h2>Accounts</h2>
                    <details class="faq-item">
                        <summary>How do I create a FreeHUB account?</summary>
                        <div class="faq-answer">Sign up from the home page with your name, email and a password. After registering you can choose to set up a Freelancer or Employer profile.</div>
                    </details>
                    <details class="faq-item">
                        <summary>Can I be both a freelancer and an employer?</summary>
                        <div class="faq-answer">Yes. One account can hold both a Freelancer and an Employer profile. Use Switch Role in the profile menu to move between them.</div>
                    </details>
                    <details class="faq-item">
                        <summary>How do I update my profile details?</summary>
                        <div class="faq-answer">Open the profile menu in the top-right corner and select Profile to edit your personal details, skills, portfolio and hourly rate.</div>
                    </details>
                </div>

                <!-- PROJECTS -->
                <div class="faq-category">
                    <h2>Projects</h2>
                    <details class="faq-item">
                        <summary>How do employers post a project?</summary>
                        <div class="faq-answer">Employers use Post a Project to add a title, description, category, budget and deadline. The project then appears for freelancers to browse.</div>
                    </details>
                    <details class="faq-item">
                        <summary>Why can't I see my own projects when browsing?</summary>
                        <div class="faq-answer">Projects you posted under your Employer profile are hidden from your Freelancer browsing view so you don't apply to your own work. Other freelancers still see them.</div>
                    </details>
                    <details class="faq-item">
                        <summary>How do I track a project's progress?</summary>
                        <div class="faq-answer">Use View Progress to see the status of each active project, from in progress through to completion.</div>
                    </details>
                </div>

                <!-- PROPOSALS -->
                <div class="faq-category">
                    <h2>Proposals</h2>
                    <details class="faq-item">
                        <summary>How do I submit a proposal?</summary>
                        <div class="faq-answer">Open a project from Browse Projects and choose Submit Proposal. Add a cover letter, your proposed rate and an estimated completion time.</div>
                    </details>
                    <details class="faq-item">
                        <summary>Can I submit more than one proposal per project?</summary>
                        <div class="faq-answer">No. Each freelancer can submit one proposal per project. You can delete a pending proposal and submit a new one if needed.</div>
                    </details>
                    <details class="faq-item">
                        <summary>How do employers choose a proposal?</summary>
                        <div class="faq-answer">Employers review the proposals received for a project and approve the one that best fits their needs and budget.</div>
                    </details>
                </div>

                <!-- PAYMENTS -->
                <div class="faq-category">
                    <h2>Payments</h2>
                    <details class="faq-item">
                        <summary>How do I add funds to my wallet?</summary>
                        <div class="faq-answer">Open Wallet and use Fund Wallet to add money to your FreeHUB balance.</div>
                    </details>
                    <details class="faq-item">
                        <summary>Where can I see my payment history?</summary>
                        <div class="faq-answer">Your wallet's Transactions view lists all credits, debits, withdrawals and refunds.</div>
                    </details>
                </div>

                <!-- WITHDRAWALS -->
                <div class="faq-category">
                    <h2>Withdrawals</h2>
                    <details class="faq-item">
                        <summary>How do I withdraw my earnings?</summary>
                        <div class="faq-answer">From your Wallet, choose Withdraw Funds, enter the amount and your banking details to request a withdrawal.</div>
                    </details>
                    <details class="faq-item">
                        <summary>How long do withdrawals take?</summary>
                        <div class="faq-answer">Withdrawal requests are reviewed before being processed. You can see each request's status in your wallet.</div>
                    </details>
                </div>

            </div>

        </section>

    </div>

</asp:Content>

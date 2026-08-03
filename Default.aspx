<%@ Page Title="Home - FreeHUB"
Language="C#"
MasterPageFile="~/Site1.Master"
AutoEventWireup="true"
CodeBehind="Default.aspx.cs"
Inherits="FreeHubProject.Default" %>

<asp:Content ID="HeadContent"
ContentPlaceHolderID="HeadContent"
runat="server">

</asp:Content>

<asp:Content ID="MainContent"
ContentPlaceHolderID="MainContent"
runat="server">

```
<!-- HERO SECTION -->

<section class="home-hero">

    <div class="hero-content">

        <p class="hero-small-title">
            FIND WORK. HIRE TALENT. BUILD SUCCESS.
        </p>

        <h1>
            The easier way to connect
            <span>talent and opportunity.</span>
        </h1>

        <p class="hero-description">

            FreeHUB connects skilled freelancers
            with employers looking for reliable
            and talented professionals.

        </p>

        <div class="hero-buttons">

            <a href="BrowseProjects.aspx"
                class="primary-button">

                Find Work

            </a>

            <a href="Register.aspx"
                class="secondary-button">

                Hire Talent

            </a>

        </div>

    </div>


    <div class="hero-card">

        <div class="hero-card-top">

            <div class="profile-circle">
                FH
            </div>

            <div>

                <h3>
                    Find your next opportunity
                </h3>

                <p>
                    Thousands of projects are waiting.
                </p>

            </div>

        </div>


        <div class="opportunity-item">

            <div class="opportunity-icon">
                &lt;/&gt;
            </div>

            <div>

                <h4>
                    Website Developer
                </h4>

                <p>
                    Remote · Fixed project
                </p>

            </div>

        </div>


        <div class="opportunity-item">

            <div class="opportunity-icon">
                ✦
            </div>

            <div>

                <h4>
                    Graphic Designer
                </h4>

                <p>
                    Remote · Flexible hours
                </p>

            </div>

        </div>


        <div class="opportunity-item">

            <div class="opportunity-icon">
                ✎
            </div>

            <div>

                <h4>
                    Content Writer
                </h4>

                <p>
                    Remote · Contract work
                </p>

            </div>

        </div>

    </div>

</section>



<!-- STATISTICS -->

<section class="statistics-section">

    <div class="statistics-container">

        <div class="statistic">

            <h2>
                10K+
            </h2>

            <p>
                Freelancers
            </p>

        </div>


        <div class="statistic">

            <h2>
                5K+
            </h2>

            <p>
                Projects Posted
            </p>

        </div>


        <div class="statistic">

            <h2>
                3K+
            </h2>

            <p>
                Employers
            </p>

        </div>


        <div class="statistic">

            <h2>
                95%
            </h2>

            <p>
                Success Rate
            </p>

        </div>

    </div>

</section>



<!-- HOW IT WORKS -->

<section class="how-it-works">

    <div class="section-heading">

        <p>
            SIMPLE AND EASY
        </p>

        <h2>
            How FreeHUB works
        </h2>

        <span>
            Connect, collaborate and complete
            projects in a few simple steps.
        </span>

    </div>


    <div class="steps-container">

        <div class="step-card">

            <div class="step-number">
                1
            </div>

            <h3>
                Create an Account
            </h3>

            <p>
                Register and choose whether
                you want to work as a freelancer
                or hire as an employer.
            </p>

        </div>


        <div class="step-card">

            <div class="step-number">
                2
            </div>

            <h3>
                Connect
            </h3>

            <p>
                Freelancers browse projects while
                employers search for skilled
                professionals.
            </p>

        </div>


        <div class="step-card">

            <div class="step-number">
                3
            </div>

            <h3>
                Work Together
            </h3>

            <p>
                Communicate through FreeHUB,
                track progress and complete
                successful projects.
            </p>

        </div>


        <div class="step-card">

            <div class="step-number">
                4
            </div>

            <h3>
                Build Your Reputation
            </h3>

            <p>
                Rate completed projects and
                build a trusted professional
                reputation.
            </p>

        </div>

    </div>

</section>



<!-- USER TYPE SECTION -->

<section class="user-type-section">

    <div class="user-type-container">


        <div class="user-type-card freelancer-card">

            <p class="user-label">
                FOR FREELANCERS
            </p>

            <h2>
                Find projects that
                match your skills.
            </h2>

            <p>

                Showcase your experience,
                submit proposals, communicate
                with employers and grow your
                professional reputation.

            </p>

            <a href="BrowseProjects.aspx"
                class="card-link">

                Browse Projects →

            </a>

        </div>



        <div class="user-type-card employer-card">

            <p class="user-label">
                FOR EMPLOYERS
            </p>

            <h2>
                Find skilled people
                for your projects.
            </h2>

            <p>

                Post projects, review proposals,
                select qualified freelancers and
                manage your work from one place.

            </p>

            <a href="PostProject.aspx"
                class="card-link">

                Post a Project →

            </a>

        </div>


    </div>

</section>



<!-- CALL TO ACTION -->

<section class="home-call-to-action">

    <div>

        <p>
            START TODAY
        </p>

        <h2>
            Ready to get started?
        </h2>

        <span>
            Join FreeHUB and start building
            valuable professional connections.
        </span>

    </div>

    <a href="Register.aspx"
        class="cta-button">

        Create Your Account

    </a>

</section>
```

</asp:Content>

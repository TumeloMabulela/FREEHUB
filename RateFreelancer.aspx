<%@ Page Title="Rate Freelancer"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="RateFreelancer.aspx.cs"
    Inherits="FreeHubProject.RateFreelancer" %>

<asp:Content ID="RateFreelancerHead"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <link href="<%= ResolveUrl("~/RateFreelancer.css?v=1") %>"
          rel="stylesheet"
          type="text/css" />

</asp:Content>


<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="rate-page-layout">

        <!-- LEFT SIDEBAR -->
        <aside class="rate-sidebar">

            <div class="rate-sidebar-section">

                <a href="Dashboard.aspx"
                   class="rate-sidebar-item">

                    <span class="rate-sidebar-icon">⌂</span>
                    <span>Dashboard</span>

                </a>


                <a href="BrowseProjects.aspx"
                   class="rate-sidebar-item">

                    <span class="rate-sidebar-icon">⌕</span>
                    <span>Find Work</span>

                </a>


                <div class="rate-menu-title">
                    MY PROJECTS
                </div>


                <a href="ReviewProposal.aspx"
                   class="rate-sidebar-item">

                    <span class="rate-sidebar-icon">▣</span>
                    <span>Active Projects</span>

                </a>


                <a href="CompletedProjects.aspx"
                   class="rate-sidebar-item rate-sidebar-active">

                    <span class="rate-sidebar-icon">✓</span>
                    <span>Completed Projects</span>

                </a>


                <a href="CancelledProjects.aspx"
                   class="rate-sidebar-item">

                    <span class="rate-sidebar-icon">×</span>
                    <span>Cancelled Projects</span>

                </a>


                <a href="Proposals.aspx"
                   class="rate-sidebar-item">

                    <span class="rate-sidebar-icon">▤</span>
                    <span>Proposals</span>

                </a>


                <a href="Messages.aspx"
                   class="rate-sidebar-item">

                    <span class="rate-sidebar-icon">✉</span>
                    <span>Messages</span>

                </a>


                <a href="Wallet.aspx"
                   class="rate-sidebar-item">

                    <span class="rate-sidebar-icon">▱</span>
                    <span>Wallet</span>

                </a>

            </div>


            <div class="rate-sidebar-heading">
                ACCOUNT
            </div>


            <div class="rate-sidebar-section">

                <a href="Profile.aspx"
                   class="rate-sidebar-item">

                    <span class="rate-sidebar-icon">♙</span>
                    <span>Profile</span>

                </a>


                <a href="Settings.aspx"
                   class="rate-sidebar-item">

                    <span class="rate-sidebar-icon">⚙</span>
                    <span>Settings</span>

                </a>


                <a href="Notifications.aspx"
                   class="rate-sidebar-item">

                    <span class="rate-sidebar-icon">◯</span>
                    <span>Notification Settings</span>

                </a>


                <a href="HelpSupport.aspx"
                   class="rate-sidebar-item">

                    <span class="rate-sidebar-icon">?</span>
                    <span>Help &amp; Support</span>

                </a>

            </div>


            <div class="rate-support-card">

                <h4>Need Help?</h4>

                <p>
                    Our support team is here to help you.
                </p>

                <asp:Button
                    ID="btnContactSupport"
                    runat="server"
                    Text="◔ Contact Support"
                    CssClass="rate-support-button"
                    CausesValidation="false"
                    OnClick="btnContactSupport_Click" />

            </div>

        </aside>


        <!-- MAIN CONTENT -->
        <main class="rate-main-content">

            <!-- BREADCRUMB -->
            <div class="rate-breadcrumb">

                My Projects

                <span>›</span>

                Completed Projects

                <span>›</span>

                <strong>
                    E-commerce Website Redesign
                </strong>

            </div>


            <!-- PAGE HEADING -->
            <div class="rate-heading">

                <h1>
                    Rate Freelancer
                </h1>

                <p>
                    Your feedback helps build a trusted community.
                    Please rate your experience working with this freelancer.
                </p>

            </div>


            <div class="rate-content-layout">

                <!-- MAIN RATING AREA -->
                <section class="rate-main-panel">

                    <!-- PROJECT COMPLETED BANNER -->
                    <div class="rate-completed-banner">

                        <div class="rate-completed-icon">
                            ✓
                        </div>

                        <div>

                            <strong>
                                Project Completed
                            </strong>

                            <p>
                                You marked this project as completed
                                on 25 May 2024.
                            </p>

                        </div>

                    </div>


                    <!-- PROJECT AND FREELANCER SUMMARY -->
                    <section class="rate-card">

                        <h2>
                            Project &amp; Freelancer Summary
                        </h2>


                        <div class="rate-summary-card">

                            <div class="rate-project-summary">

                                <div class="rate-project-icon">
                                    ▣
                                </div>

                                <div>

                                    <h3>
                                        E-commerce Website Redesign
                                    </h3>

                                    <p>
                                        📅 Completed on: 25 May 2024
                                    </p>

                                    <p>
                                        💰 Total Amount: R12,000
                                    </p>

                                </div>

                            </div>


                            <div class="rate-freelancer-summary">

                                <small>
                                    Freelancer
                                </small>


                                <div class="rate-freelancer-row">

                                    <div class="rate-avatar">
                                        RT
                                    </div>


                                    <div class="rate-freelancer-info">

                                        <div class="rate-name-row">

                                            <strong>
                                                Freelancer Name
                                            </strong>

                                            <span>
                                                Top Rated Freelancer
                                            </span>

                                        </div>

                                        <p>
                                            ◉ South Africa
                                        </p>

                                    </div>


                                    <asp:Button
                                        ID="btnViewProfile"
                                        runat="server"
                                        Text="View Profile"
                                        CssClass="rate-view-profile-button"
                                        CausesValidation="false"
                                        OnClick="btnViewProfile_Click" />

                                </div>

                            </div>

                        </div>

                    </section>


                    <!-- RATING FORM -->
                    <section class="rate-card">

                        <h2>
                            Your Rating
                        </h2>


                        <div class="rating-label-row">

                            <label>
                                Overall Rating
                                <span>*</span>
                            </label>

                            <asp:Label
                                ID="lblSelectedRating"
                                runat="server"
                                CssClass="selected-rating-text"
                                Text="No rating selected">
                            </asp:Label>

                        </div>


                        <div class="star-rating">

                            <button type="button"
                                    class="rating-star"
                                    data-value="1"
                                    onclick="selectRating(1)">
                                ★
                            </button>

                            <button type="button"
                                    class="rating-star"
                                    data-value="2"
                                    onclick="selectRating(2)">
                                ★
                            </button>

                            <button type="button"
                                    class="rating-star"
                                    data-value="3"
                                    onclick="selectRating(3)">
                                ★
                            </button>

                            <button type="button"
                                    class="rating-star"
                                    data-value="4"
                                    onclick="selectRating(4)">
                                ★
                            </button>

                            <button type="button"
                                    class="rating-star"
                                    data-value="5"
                                    onclick="selectRating(5)">
                                ★
                            </button>

                        </div>


                        <asp:HiddenField
                            ID="hfRating"
                            runat="server"
                            Value="0" />


                        <p class="rating-instruction">
                            Click a star to rate
                            (1 = Poor, 5 = Excellent)
                        </p>


                        <div class="rating-comment-group">

                            <label>
                                Comment
                                <span>(Optional)</span>
                            </label>


                            <asp:TextBox
                                ID="txtComment"
                                runat="server"
                                TextMode="MultiLine"
                                Rows="5"
                                MaxLength="500"
                                CssClass="rating-comment-box"
                                placeholder="Share your experience working with this freelancer..."
                                onkeyup="updateCharacterCount(this)">
                            </asp:TextBox>


                            <div class="rating-character-count">

                                <span id="characterCount">
                                    0
                                </span>

                                /500 characters

                            </div>

                        </div>


                        <div class="rating-actions">

                            <asp:Button
                                ID="btnCancel"
                                runat="server"
                                Text="Cancel"
                                CssClass="rating-cancel-button"
                                CausesValidation="false"
                                OnClick="btnCancel_Click" />


                            <asp:Button
                                ID="btnSubmitRating"
                                runat="server"
                                Text="☆ Submit Rating"
                                CssClass="rating-submit-button"
                                OnClick="btnSubmitRating_Click" />

                        </div>


                        <asp:Panel
                            ID="pnlRatingMessage"
                            runat="server"
                            CssClass="rating-message-panel"
                            Visible="false">

                            <asp:Label
                                ID="lblRatingMessage"
                                runat="server">
                            </asp:Label>

                        </asp:Panel>

                    </section>


                    <!-- INFORMATION BOX -->
                    <div class="rating-information-box">

                        <div class="rating-information-icon">
                            i
                        </div>

                        <p>
                            Once submitted, your rating will be used
                            to update the freelancer's reputation score.
                        </p>

                    </div>

                </section>


                <!-- RIGHT PANEL -->
                <aside class="rate-right-panel">

                    <!-- ABOUT RATINGS -->
                    <section class="rating-side-card">

                        <h3>
                            About Ratings
                        </h3>


                        <div class="rating-tip">

                            <span class="rating-tip-icon green-tip">
                                ♧
                            </span>

                            <p>
                                Your honest feedback helps build
                                a strong and trustworthy community.
                            </p>

                        </div>


                        <div class="rating-tip">

                            <span class="rating-tip-icon yellow-tip">
                                ▥
                            </span>

                            <p>
                                Freelancers with higher ratings
                                tend to get more projects and
                                better opportunities.
                            </p>

                        </div>


                        <div class="rating-tip">

                            <span class="rating-tip-icon blue-tip">
                                ▣
                            </span>

                            <p>
                                All ratings are private and
                                reviewed for quality.
                            </p>

                        </div>

                    </section>


                    <!-- RATING GUIDELINES -->
                    <section class="rating-side-card">

                        <h3>
                            Rating Guidelines
                        </h3>

                        <ul class="rating-guidelines">

                            <li>✓ Be honest and fair</li>

                            <li>✓ Focus on your experience</li>

                            <li>✓ Avoid personal information</li>

                            <li>✓ Keep comments professional</li>

                        </ul>

                    </section>


                    <!-- REPORT -->
                    <section class="rating-side-card">

                        <h3>
                            Need Help?
                        </h3>

                        <p class="rating-help-text">
                            If you have an issue with this
                            freelancer, you can report them.
                        </p>

                        <asp:Button
                            ID="btnReportFreelancer"
                            runat="server"
                            Text="⚠ Report Freelancer"
                            CssClass="report-freelancer-button"
                            CausesValidation="false"
                            OnClick="btnReportFreelancer_Click" />

                    </section>

                </aside>

            </div>

        </main>

    </div>


    <script type="text/javascript">

        function selectRating(value) {

            var stars =
                document.querySelectorAll(".rating-star");

            for (var i = 0; i < stars.length; i++) {

                var starValue =
                    parseInt(
                        stars[i].getAttribute("data-value")
                    );

                if (starValue <= value) {

                    stars[i].classList.add("selected-star");

                } else {

                    stars[i].classList.remove("selected-star");

                }
            }


            document.getElementById(
                "<%= hfRating.ClientID %>"
            ).value = value;


            var ratingText = "";

            switch (value) {

                case 1:
                    ratingText = "1 Star - Poor";
                    break;

                case 2:
                    ratingText = "2 Stars - Fair";
                    break;

                case 3:
                    ratingText = "3 Stars - Good";
                    break;

                case 4:
                    ratingText = "4 Stars - Very Good";
                    break;

                case 5:
                    ratingText = "5 Stars - Excellent";
                    break;
            }


            document.getElementById(
                "<%= lblSelectedRating.ClientID %>"
            ).innerText = ratingText;
        }


        function updateCharacterCount(textBox) {

            document.getElementById(
                "characterCount"
            ).innerText =
                textBox.value.length;
        }

    </script>

</asp:Content>
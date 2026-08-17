<%@ Page Title="View Profile - FreeHUB"
    Language="C#"
    MasterPageFile="~/Site1.Master"
    AutoEventWireup="true"
    CodeBehind="ViewProfile.aspx.cs"
    Inherits="FreeHubProject.ViewProfile" %>

<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="freehub-dashboard-layout">

        <uc:Sidebar runat="server" ID="SidebarControl" />

        <section class="freehub-main-content">

            <div style="max-width:600px; margin:0 auto; padding:30px;">

                <a href="javascript:history.back()" style="display:inline-block;color:#fff;background-color:#2e7d56;text-decoration:none;font-size:13px;font-weight:500;padding:8px 16px;border-radius:6px;margin-bottom:20px;">&#8592; Back</a>

                <asp:Panel ID="pnlProfile" runat="server">

                    <!-- PROFILE CARD -->
                    <div style="background:#fff; border:1px solid #e8ece9; border-radius:12px; padding:30px; text-align:center;">

                        <div style="width:70px;height:70px;border-radius:50%;background-color:#2e7d56;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:bold;font-size:24px;margin:0 auto 15px;">
                            <asp:Label ID="lblInitials" runat="server" />
                        </div>

                        <h2 style="color:#173f2c; margin-bottom:5px;"><asp:Label ID="lblFullName" runat="server" /></h2>
                        <span style="display:inline-block;padding:4px 12px;border-radius:12px;font-size:12px;background:#edf5f0;color:#2e7d56;margin-bottom:10px;">
                            <asp:Label ID="lblUserType" runat="server" />
                        </span>
                        <p style="color:#888; font-size:13px;">Member since <asp:Label ID="lblDateJoined" runat="server" /></p>
                        <p style="color:#f39c12; font-size:14px; margin-top:8px;">&#11088; <asp:Label ID="lblRating" runat="server" Text="0.0" /> rating</p>

                    </div>

                    <!-- DETAILS -->
                    <div style="background:#fff; border:1px solid #e8ece9; border-radius:12px; padding:25px; margin-top:15px;">

                        <asp:Panel ID="pnlFreelancerInfo" runat="server" Visible="false">
                            <h3 style="color:#173f2c; margin-bottom:12px;">Freelancer Details</h3>
                            <p style="font-size:14px; color:#555;"><strong>Skills:</strong> <asp:Label ID="lblSkills" runat="server" /></p>
                            <p style="font-size:14px; color:#555; margin-top:8px;"><strong>Experience:</strong> <asp:Label ID="lblExperience" runat="server" /></p>
                            <p style="font-size:14px; color:#555; margin-top:8px;"><strong>Hourly Rate:</strong> R<asp:Label ID="lblRate" runat="server" /></p>
                        </asp:Panel>

                        <asp:Panel ID="pnlEmployerInfo" runat="server" Visible="false">
                            <h3 style="color:#173f2c; margin-bottom:12px;">Employer Details</h3>
                            <p style="font-size:14px; color:#555;"><strong>Company:</strong> <asp:Label ID="lblCompany" runat="server" /></p>
                            <p style="font-size:14px; color:#555; margin-top:8px;"><strong>Industry:</strong> <asp:Label ID="lblIndustry" runat="server" /></p>
                            <p style="font-size:14px; color:#555; margin-top:8px;"><strong>Description:</strong> <asp:Label ID="lblDescription" runat="server" /></p>
                        </asp:Panel>

                    </div>

                </asp:Panel>

                <asp:Label ID="lblError" runat="server" CssClass="post-status post-error" Visible="false" />

            </div>

        </section>

    </div>

</asp:Content>

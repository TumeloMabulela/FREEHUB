using System;

namespace FreeHubProject
{
    public partial class MyProjects : System.Web.UI.Page
    {
        protected string SelectedView
        {
            get
            {
                string view =
                    Request.QueryString["view"];

                if (string.Equals(
                    view,
                    "Completed",
                    StringComparison.OrdinalIgnoreCase))
                {
                    return "Completed";
                }

                if (string.Equals(
                    view,
                    "Cancelled",
                    StringComparison.OrdinalIgnoreCase))
                {
                    return "Cancelled";
                }

                return "Active";
            }
        }


        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProjectCounts();
                LoadSelectedSection();
            }
        }


        private void LoadProjectCounts()
        {
            lblActiveCount.Text =
                GetSessionCount(
                    "ActiveProjectCount",
                    1
                ).ToString();

            lblCompletedCount.Text =
                GetSessionCount(
                    "CompletedProjectCount",
                    0
                ).ToString();

            lblCancelledCount.Text =
                GetSessionCount(
                    "CancelledProjectCount",
                    0
                ).ToString();
        }


        private void LoadSelectedSection()
        {
            switch (SelectedView)
            {
                case "Completed":

                    lblSectionTitle.Text =
                        "Completed Projects";

                    lblProjectStatus.Text =
                        "Completed";

                    lblProjectStatus.CssClass =
                        "my-project-status completed-project-status";

                    pnlProjectList.Visible =
                        GetSessionCount(
                            "CompletedProjectCount",
                            0
                        ) > 0;

                    break;


                case "Cancelled":

                    lblSectionTitle.Text =
                        "Cancelled Projects";

                    lblProjectStatus.Text =
                        "Cancelled";

                    lblProjectStatus.CssClass =
                        "my-project-status cancelled-project-status";

                    pnlProjectList.Visible =
                        GetSessionCount(
                            "CancelledProjectCount",
                            0
                        ) > 0;

                    break;


                default:

                    lblSectionTitle.Text =
                        "Active Projects";

                    lblProjectStatus.Text =
                        "Active";

                    lblProjectStatus.CssClass =
                        "my-project-status active-project-status";

                    pnlProjectList.Visible =
                        true;

                    break;
            }

            pnlEmptyProjects.Visible =
                !pnlProjectList.Visible;
        }


        protected string GetTabClass(
            string viewName)
        {
            return string.Equals(
                SelectedView,
                viewName,
                StringComparison.OrdinalIgnoreCase)
                    ? "my-projects-tab my-projects-tab-active"
                    : "my-projects-tab";
        }


        protected string GetMiniMenuClass(
            string viewName)
        {
            return string.Equals(
                SelectedView,
                viewName,
                StringComparison.OrdinalIgnoreCase)
                    ? "my-projects-mini-active"
                    : "";
        }


        private int GetSessionCount(
            string sessionName,
            int defaultValue)
        {
            object value =
                Session[sessionName];

            if (value == null)
            {
                Session[sessionName] =
                    defaultValue;

                return defaultValue;
            }

            int count;

            return int.TryParse(
                value.ToString(),
                out count
            )
                ? count
                : defaultValue;
        }
    }
}
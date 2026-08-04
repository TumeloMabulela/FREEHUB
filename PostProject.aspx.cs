using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class PostProject : System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;

            if (!IsPostBack)
            {
                pnlPreview.Visible = false;

                btnEditProject.Visible =
                    Session["ProjectPosted"] != null;
            }
        }


        // POST PROJECT OR SAVE CHANGES

        protected void btnSubmitProject_Click(
            object sender,
            EventArgs e)
        {
            if (!ValidateProject())
            {
                return;
            }


            SaveProjectToSession();


            if (Session["ProjectPosted"] == null)
            {
                Session["ProjectPosted"] = true;

                ShowMessage(
                    "Project posted successfully."
                );
            }
            else
            {
                ShowMessage(
                    "Project changes saved successfully."
                );
            }


            btnEditProject.Visible = true;

            btnSubmitProject.Text =
                "Save Changes";
        }


        // EDIT PROJECT

        protected void btnEditProject_Click(
            object sender,
            EventArgs e)
        {
            if (Session["ProjectPosted"] == null)
            {
                ShowMessage(
                    "Please post a project before editing it."
                );

                return;
            }


            LoadProjectFromSession();


            btnSubmitProject.Text =
                "Save Changes";


            ShowMessage(
                "You can now edit the project details."
            );
        }


        // PREVIEW

        protected void btnPreview_Click(
            object sender,
            EventArgs e)
        {
            lblPreviewTitle.Text =
                txtProjectTitle.Text;


            lblPreviewCategory.Text =
                ddlCategory.SelectedValue;


            lblPreviewDescription.Text =
                txtDescription.Text;


            lblPreviewBudget.Text =
                "R" +
                txtBudget.Text +
                " - " +
                rblBudgetType.SelectedItem.Text;


            lblPreviewDeadline.Text =
                txtDeadline.Text;


            lblPreviewExperience.Text =
                ddlExperience.SelectedValue;


            List<string> selectedSkills =
                new List<string>();


            foreach (
                ListItem skill
                in cblSkills.Items)
            {
                if (skill.Selected)
                {
                    selectedSkills.Add(
                        skill.Text
                    );
                }
            }


            lblPreviewSkills.Text =
                selectedSkills.Count > 0
                ? string.Join(
                    ", ",
                    selectedSkills
                )
                : "No skills selected";


            pnlPreview.Visible = true;


            ShowMessage(
                "Project preview generated."
            );
        }


        // CANCEL

        protected void btnCancel_Click(
            object sender,
            EventArgs e)
        {
            ClearProjectForm();


            pnlPreview.Visible = false;


            ShowMessage(
                "Project form cleared."
            );
        }


        // LEARN MORE

        protected void btnLearnMore_Click(
            object sender,
            EventArgs e)
        {
            ShowMessage(
                "FreeHUB protects your project information and shares it only with registered users."
            );
        }


        // VALIDATE PROJECT

        private bool ValidateProject()
        {
            if (
                string.IsNullOrWhiteSpace(
                    txtProjectTitle.Text
                )
            )
            {
                ShowMessage(
                    "Please enter the project title."
                );

                return false;
            }


            if (
                string.IsNullOrWhiteSpace(
                    ddlCategory.SelectedValue
                )
            )
            {
                ShowMessage(
                    "Please select a project category."
                );

                return false;
            }


            if (
                string.IsNullOrWhiteSpace(
                    ddlExperience.SelectedValue
                )
            )
            {
                ShowMessage(
                    "Please select an experience level."
                );

                return false;
            }


            if (
                string.IsNullOrWhiteSpace(
                    txtDescription.Text
                )
            )
            {
                ShowMessage(
                    "Please enter the project description."
                );

                return false;
            }


            if (
                string.IsNullOrWhiteSpace(
                    txtBudget.Text
                )
            )
            {
                ShowMessage(
                    "Please enter the project budget."
                );

                return false;
            }


            if (
                string.IsNullOrWhiteSpace(
                    txtDeadline.Text
                )
            )
            {
                ShowMessage(
                    "Please select a project deadline."
                );

                return false;
            }


            bool skillSelected = false;


            foreach (
                ListItem skill
                in cblSkills.Items)
            {
                if (skill.Selected)
                {
                    skillSelected = true;

                    break;
                }
            }


            if (!skillSelected)
            {
                ShowMessage(
                    "Please select at least one required skill."
                );

                return false;
            }


            return true;
        }


        // SAVE PROJECT

        private void SaveProjectToSession()
        {
            Session["ProjectTitle"] =
                txtProjectTitle.Text.Trim();


            Session["ProjectCategory"] =
                ddlCategory.SelectedValue;


            Session["ProjectExperience"] =
                ddlExperience.SelectedValue;


            Session["ProjectDescription"] =
                txtDescription.Text.Trim();


            Session["ProjectBudgetType"] =
                rblBudgetType.SelectedValue;


            Session["ProjectBudget"] =
                txtBudget.Text.Trim();


            Session["ProjectDeadline"] =
                txtDeadline.Text;


            List<string> skills =
                new List<string>();


            foreach (
                ListItem skill
                in cblSkills.Items)
            {
                if (skill.Selected)
                {
                    skills.Add(
                        skill.Value
                    );
                }
            }


            Session["ProjectSkills"] =
                skills;


            if (
                fileAttachment.HasFile
            )
            {
                Session["ProjectAttachment"] =
                    fileAttachment.FileName;


                lblAttachment.Text =
                    "Selected file: " +
                    fileAttachment.FileName;
            }
        }


        // LOAD PROJECT

        private void LoadProjectFromSession()
        {
            txtProjectTitle.Text =
                Session["ProjectTitle"]?.ToString();


            ddlCategory.SelectedValue =
                Session["ProjectCategory"]?.ToString()
                ?? "";


            ddlExperience.SelectedValue =
                Session["ProjectExperience"]?.ToString()
                ?? "";


            txtDescription.Text =
                Session["ProjectDescription"]?.ToString();


            rblBudgetType.SelectedValue =
                Session["ProjectBudgetType"]?.ToString()
                ?? "Fixed";


            txtBudget.Text =
                Session["ProjectBudget"]?.ToString();


            txtDeadline.Text =
                Session["ProjectDeadline"]?.ToString();


            List<string> savedSkills =
                Session["ProjectSkills"]
                as List<string>;


            foreach (
                ListItem skill
                in cblSkills.Items)
            {
                skill.Selected =
                    savedSkills != null &&
                    savedSkills.Contains(
                        skill.Value
                    );
            }


            if (
                Session["ProjectAttachment"]
                != null
            )
            {
                lblAttachment.Text =
                    "Current file: " +

                    Session[
                        "ProjectAttachment"
                    ].ToString();
            }
        }


        // CLEAR FORM

        private void ClearProjectForm()
        {
            txtProjectTitle.Text = "";

            ddlCategory.SelectedIndex = 0;

            ddlExperience.SelectedIndex = 0;

            txtDescription.Text = "";

            rblBudgetType.SelectedValue =
                "Fixed";

            txtBudget.Text = "";

            txtDeadline.Text = "";

            lblAttachment.Text = "";


            foreach (
                ListItem skill
                in cblSkills.Items)
            {
                skill.Selected = false;
            }
        }


        // SHOW STATUS

        private void ShowMessage(
            string message)
        {
            pnlProjectStatus.Visible = true;

            lblProjectStatus.Text =
                message;
        }
    }
}
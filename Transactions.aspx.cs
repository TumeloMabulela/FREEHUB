using System;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class Transactions :
        System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;

            if (!IsPostBack)
            {
                pnlMessage.Visible = false;

                ddlTransactionType.SelectedValue =
                    "All";

                txtFromDate.Text = "";
                txtToDate.Text = "";

                string requestedType =
                    Request.QueryString["type"];

                if (!string.IsNullOrWhiteSpace(
                    requestedType))
                {
                    ListItem item =
                        ddlTransactionType.Items
                            .FindByValue(
                                requestedType
                            );

                    if (item != null)
                    {
                        ddlTransactionType.SelectedValue =
                            requestedType;
                    }
                }

                LoadWalletBalance();
                LoadTransactions();
                HideDetails();
            }
        }


        private void LoadWalletBalance()
        {
            decimal balance =
                GetSessionDecimal(
                    "AvailableBalance"
                );

            lblCurrentBalance.Text =
                FormatCurrency(balance);
        }


        private void LoadTransactions()
        {
            DataTable source =
                TransactionStore.GetTransactions(
                    Session
                );

            DataTable displayTable =
                CreateDisplayTable();

            string selectedType =
                ddlTransactionType.SelectedValue;

            DateTime fromDate;
            DateTime toDate;

            bool hasFromDate =
                DateTime.TryParse(
                    txtFromDate.Text,
                    out fromDate
                );

            bool hasToDate =
                DateTime.TryParse(
                    txtToDate.Text,
                    out toDate
                );

            DataView sortedView =
                source.DefaultView;

            sortedView.Sort =
                "TransactionDate DESC";

            foreach (DataRowView rowView in sortedView)
            {
                DataRow row =
                    rowView.Row;

                string type =
                    Convert.ToString(
                        row["Type"]
                    );

                DateTime transactionDate =
                    Convert.ToDateTime(
                        row["TransactionDate"]
                    );

                if (selectedType != "All" &&
                    !string.Equals(
                        selectedType,
                        type,
                        StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                if (hasFromDate &&
                    transactionDate.Date < fromDate.Date)
                {
                    continue;
                }

                if (hasToDate &&
                    transactionDate.Date > toDate.Date)
                {
                    continue;
                }

                decimal amount =
                    Convert.ToDecimal(
                        row["Amount"]
                    );

                string status =
                    Convert.ToString(
                        row["Status"]
                    );

                DataRow displayRow =
                    displayTable.NewRow();

                displayRow["TransactionId"] =
                    row["TransactionId"];

                displayRow["DisplayDate"] =
                    transactionDate.ToString(
                        "dd MMM yyyy, hh:mm tt"
                    );

                displayRow["Description"] =
                    row["Description"];

                displayRow["Type"] =
                    type;

                displayRow["DisplayAmount"] =
                    FormatTransactionAmount(
                        amount,
                        type
                    );

                displayRow["Status"] =
                    status;

                displayRow["TypeCssClass"] =
                    GetTypeCssClass(type);

                displayRow["AmountCssClass"] =
                    GetAmountCssClass(type);

                displayRow["StatusCssClass"] =
                    GetStatusCssClass(status);

                displayTable.Rows.Add(
                    displayRow
                );
            }

            rptTransactions.DataSource =
                displayTable;

            rptTransactions.DataBind();

            pnlNoTransactions.Visible =
                displayTable.Rows.Count == 0;

            lblTransactionCount.Text =
                displayTable.Rows.Count +
                (
                    displayTable.Rows.Count == 1
                        ? " transaction"
                        : " transactions"
                );
        }


        protected void btnFilter_Click(
            object sender,
            EventArgs e)
        {
            pnlMessage.Visible = false;

            LoadTransactions();
            HideDetails();
        }


        protected void btnClear_Click(
            object sender,
            EventArgs e)
        {
            ddlTransactionType.SelectedValue =
                "All";

            txtFromDate.Text = "";
            txtToDate.Text = "";

            pnlMessage.Visible = false;

            LoadTransactions();
            HideDetails();
        }


        protected void rptTransactions_ItemCommand(
            object source,
            RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewDetails")
            {
                return;
            }

            string transactionId =
                Convert.ToString(
                    e.CommandArgument
                );

            DataRow transaction =
                TransactionStore.FindTransaction(
                    Session,
                    transactionId
                );

            if (transaction == null)
            {
                ShowMessage(
                    "The transaction could not be found.",
                    false
                );

                return;
            }

            ShowDetails(transaction);
        }


        private void ShowDetails(
            DataRow transaction)
        {
            string transactionId =
                Convert.ToString(
                    transaction["TransactionId"]
                );

            string type =
                Convert.ToString(
                    transaction["Type"]
                );

            string status =
                Convert.ToString(
                    transaction["Status"]
                );

            decimal amount =
                Convert.ToDecimal(
                    transaction["Amount"]
                );

            ViewState["SelectedTransactionId"] =
                transactionId;

            pnlEmptyDetails.Visible = false;
            pnlSelectedDetails.Visible = true;

            lblDetailsTitle.Text =
                Convert.ToString(
                    transaction["Title"]
                );

            lblDetailsType.Text =
                type;

            lblDetailsAmount.Text =
                FormatTransactionAmount(
                    amount,
                    type
                );

            lblDetailsAmount.CssClass =
                GetAmountCssClass(type);

            lblDetailsDate.Text =
                Convert.ToDateTime(
                    transaction["TransactionDate"]
                ).ToString(
                    "dd MMM yyyy, hh:mm tt"
                );

            lblDetailsId.Text =
                transactionId;

            lblDetailsReference.Text =
                Convert.ToString(
                    transaction["Reference"]
                );

            lblDetailsPaymentMethod.Text =
                Convert.ToString(
                    transaction["PaymentMethod"]
                );

            lblDetailsDescription.Text =
                Convert.ToString(
                    transaction["Description"]
                );

            lblDetailsStatus.Text =
                status;

            lblDetailsStatus.CssClass =
                GetStatusCssClass(status);

            if (string.Equals(
                type,
                "Credit",
                StringComparison.OrdinalIgnoreCase))
            {
                detailsIcon.InnerText = "↓";

                detailsIcon.Attributes["class"] =
                    "transactions-details-icon transaction-credit-icon";
            }
            else
            {
                detailsIcon.InnerText = "↑";

                detailsIcon.Attributes["class"] =
                    "transactions-details-icon transaction-debit-icon";
            }
        }


        protected void btnCloseDetails_Click(
            object sender,
            EventArgs e)
        {
            HideDetails();
        }


        private void HideDetails()
        {
            ViewState["SelectedTransactionId"] =
                null;

            pnlEmptyDetails.Visible = true;
            pnlSelectedDetails.Visible = false;
        }


        protected void btnDownloadReceipt_Click(
            object sender,
            EventArgs e)
        {
            string transactionId =
                Convert.ToString(
                    ViewState["SelectedTransactionId"]
                );

            if (string.IsNullOrWhiteSpace(
                transactionId))
            {
                ShowMessage(
                    "Select a transaction first.",
                    false
                );

                return;
            }

            DataRow transaction =
                TransactionStore.FindTransaction(
                    Session,
                    transactionId
                );

            if (transaction == null)
            {
                ShowMessage(
                    "The transaction could not be found.",
                    false
                );

                return;
            }

            string type =
                Convert.ToString(
                    transaction["Type"]
                );

            decimal amount =
                Convert.ToDecimal(
                    transaction["Amount"]
                );

            StringBuilder receipt =
                new StringBuilder();

            receipt.AppendLine(
                "FREEHUB TRANSACTION RECEIPT"
            );

            receipt.AppendLine(
                "--------------------------------"
            );

            receipt.AppendLine(
                "Transaction ID: " +
                transaction["TransactionId"]
            );

            receipt.AppendLine(
                "Reference: " +
                transaction["Reference"]
            );

            receipt.AppendLine(
                "Date: " +
                Convert.ToDateTime(
                    transaction["TransactionDate"]
                ).ToString(
                    "dd MMM yyyy, hh:mm tt"
                )
            );

            receipt.AppendLine(
                "Type: " +
                type
            );

            receipt.AppendLine(
                "Amount: " +
                FormatTransactionAmount(
                    amount,
                    type
                )
            );

            receipt.AppendLine(
                "Status: " +
                transaction["Status"]
            );

            receipt.AppendLine(
                "Payment Method: " +
                transaction["PaymentMethod"]
            );

            receipt.AppendLine(
                "Description: " +
                transaction["Description"]
            );

            Response.Clear();

            Response.ContentType =
                "text/plain";

            Response.AddHeader(
                "content-disposition",
                "attachment;filename=" +
                transactionId +
                "-receipt.txt"
            );

            Response.Write(
                receipt.ToString()
            );

            Response.Flush();

            HttpContext.Current
                .ApplicationInstance
                .CompleteRequest();
        }


        private DataTable CreateDisplayTable()
        {
            DataTable table =
                new DataTable();

            table.Columns.Add(
                "TransactionId",
                typeof(string)
            );

            table.Columns.Add(
                "DisplayDate",
                typeof(string)
            );

            table.Columns.Add(
                "Description",
                typeof(string)
            );

            table.Columns.Add(
                "Type",
                typeof(string)
            );

            table.Columns.Add(
                "DisplayAmount",
                typeof(string)
            );

            table.Columns.Add(
                "Status",
                typeof(string)
            );

            table.Columns.Add(
                "TypeCssClass",
                typeof(string)
            );

            table.Columns.Add(
                "AmountCssClass",
                typeof(string)
            );

            table.Columns.Add(
                "StatusCssClass",
                typeof(string)
            );

            return table;
        }


        private decimal GetSessionDecimal(
            string sessionName)
        {
            object value =
                Session[sessionName];

            if (value == null)
            {
                return 0.00m;
            }

            decimal amount;

            return decimal.TryParse(
                value.ToString(),
                out amount
            )
                ? amount
                : 0.00m;
        }


        private string FormatCurrency(
            decimal amount)
        {
            return
                "R" +
                amount.ToString("N2");
        }


        private string FormatTransactionAmount(
            decimal amount,
            string type)
        {
            bool positive =
                string.Equals(
                    type,
                    "Credit",
                    StringComparison.OrdinalIgnoreCase
                ) ||
                string.Equals(
                    type,
                    "Refund",
                    StringComparison.OrdinalIgnoreCase
                );

            return
                (positive ? "+ " : "- ") +
                FormatCurrency(
                    Math.Abs(amount)
                );
        }


        private string GetTypeCssClass(
            string type)
        {
            if (string.Equals(
                type,
                "Credit",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    "transaction-type transaction-credit-type";
            }

            if (string.Equals(
                type,
                "Withdrawal",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    "transaction-type transaction-withdrawal-type";
            }

            if (string.Equals(
                type,
                "Refund",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    "transaction-type transaction-refund-type";
            }

            return
                "transaction-type transaction-debit-type";
        }


        private string GetAmountCssClass(
            string type)
        {
            if (string.Equals(
                type,
                "Credit",
                StringComparison.OrdinalIgnoreCase) ||
                string.Equals(
                    type,
                    "Refund",
                    StringComparison.OrdinalIgnoreCase))
            {
                return
                    "transaction-credit-amount";
            }

            return
                "transaction-debit-amount";
        }


        private string GetStatusCssClass(
            string status)
        {
            if (string.Equals(
                status,
                "Completed",
                StringComparison.OrdinalIgnoreCase) ||
                string.Equals(
                    status,
                    "Approved",
                    StringComparison.OrdinalIgnoreCase))
            {
                return
                    "transaction-status transaction-completed";
            }

            if (string.Equals(
                status,
                "Rejected",
                StringComparison.OrdinalIgnoreCase) ||
                string.Equals(
                    status,
                    "Failed",
                    StringComparison.OrdinalIgnoreCase))
            {
                return
                    "transaction-status transaction-rejected";
            }

            return
                "transaction-status transaction-pending";
        }


        private void ShowMessage(
            string message,
            bool success)
        {
            pnlMessage.Visible = true;

            lblMessage.Text =
                message;

            pnlMessage.CssClass =
                success
                    ? "tx-message tx-message-success"
                    : "tx-message tx-message-error";
        }
    }
}
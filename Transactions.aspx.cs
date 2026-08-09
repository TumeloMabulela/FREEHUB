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

                string requestedTxn =
                    Request.QueryString["txn"];

                if (!string.IsNullOrWhiteSpace(
                    requestedTxn))
                {
                    int txnId;
                    if (int.TryParse(requestedTxn, out txnId))
                    {
                        DataRow transaction =
                            DatabaseHelper.GetTransactionById(txnId);

                        if (transaction != null)
                        {
                            ShowDetails(transaction);
                        }
                    }
                }
            }
        }


        private void LoadWalletBalance()
        {
            int walletID = 0;
            if (Session["WalletID"] != null)
                walletID = Convert.ToInt32(Session["WalletID"]);

            decimal balance = 0.00m;

            if (walletID > 0)
            {
                balance =
                    DatabaseHelper.GetWalletBalance(walletID);

                Session["AvailableBalance"] = balance;
            }

            lblCurrentBalance.Text =
                FormatCurrency(balance);
        }


        private void LoadTransactions()
        {
            int walletID = 0;
            if (Session["WalletID"] != null)
                walletID = Convert.ToInt32(Session["WalletID"]);

            DataTable source = new DataTable();

            if (walletID > 0)
            {
                source =
                    DatabaseHelper.GetTransactionsByWallet(
                        walletID
                    );
            }

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

            foreach (DataRow row in source.Rows)
            {
                string type =
                    Convert.ToString(
                        row["transactionType"]
                    );

                DateTime transactionDate =
                    Convert.ToDateTime(
                        row["transactionDate"]
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
                        row["transactionAmount"]
                    );

                string status =
                    Convert.ToString(
                        row["transactionStatus"]
                    );

                DataRow displayRow =
                    displayTable.NewRow();

                displayRow["TransactionId"] =
                    Convert.ToString(row["transactionID"]);

                displayRow["DisplayDate"] =
                    transactionDate.ToString(
                        "dd MMM yyyy, hh:mm tt"
                    );

                displayRow["Description"] =
                    Convert.ToString(row["itemDescription"]);

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

            int txnId;
            if (!int.TryParse(transactionId, out txnId))
            {
                ShowMessage(
                    "The transaction could not be found.",
                    false
                );
                return;
            }

            DataRow transaction =
                DatabaseHelper.GetTransactionById(txnId);

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
                    transaction["transactionID"]
                );

            string type =
                Convert.ToString(
                    transaction["transactionType"]
                );

            string status =
                Convert.ToString(
                    transaction["transactionStatus"]
                );

            decimal amount =
                Convert.ToDecimal(
                    transaction["transactionAmount"]
                );

            ViewState["SelectedTransactionId"] =
                transactionId;

            pnlEmptyDetails.Visible = false;
            pnlSelectedDetails.Visible = true;

            lblDetailsTitle.Text =
                Convert.ToString(
                    transaction["itemDescription"]
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
                    transaction["transactionDate"]
                ).ToString(
                    "dd MMM yyyy, hh:mm tt"
                );

            lblDetailsId.Text =
                transactionId;

            lblDetailsReference.Text =
                Convert.ToString(
                    transaction["reference"]
                );

            lblDetailsPaymentMethod.Text =
                Convert.ToString(
                    transaction["paymentMethod"]
                );

            lblDetailsDescription.Text =
                Convert.ToString(
                    transaction["itemDescription"]
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

            int txnId;
            if (!int.TryParse(transactionId, out txnId))
            {
                ShowMessage(
                    "The transaction could not be found.",
                    false
                );
                return;
            }

            DataRow transaction =
                DatabaseHelper.GetTransactionById(txnId);

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
                    transaction["transactionType"]
                );

            decimal amount =
                Convert.ToDecimal(
                    transaction["transactionAmount"]
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
                transaction["transactionID"]
            );

            receipt.AppendLine(
                "Reference: " +
                transaction["reference"]
            );

            receipt.AppendLine(
                "Date: " +
                Convert.ToDateTime(
                    transaction["transactionDate"]
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
                transaction["transactionStatus"]
            );

            receipt.AppendLine(
                "Payment Method: " +
                transaction["paymentMethod"]
            );

            receipt.AppendLine(
                "Description: " +
                transaction["itemDescription"]
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
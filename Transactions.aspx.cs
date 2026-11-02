using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
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
            // IF user is not logged in, stop executing this page
            if (!AuthHelper.RequireLogin(this)) return;

            // IF this is the first page load (not a button click), load data
            if (!IsPostBack)
            {
                pnlMessage.Visible = false;

                ddlTransactionType.SelectedValue =
                    "All";

                txtFromDate.Text = "";
                txtToDate.Text = "";

                string requestedType =
                    Request.QueryString["type"];

                // IF the field is empty or contains only whitespace
                if (!string.IsNullOrWhiteSpace(
                    requestedType))
                {
                    ListItem item =
                        ddlTransactionType.Items
                            .FindByValue(
                                requestedType
                            );

                    // IF the value exists and is not null
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

                // IF the field is empty or contains only whitespace
                if (!string.IsNullOrWhiteSpace(
                    requestedTxn))
                {
                    int txnId;
                    if (int.TryParse(requestedTxn, out txnId))
                    {
                        DataRow transaction =
                            DatabaseHelper.GetTransactionById(txnId);

                        // IF the value exists and is not null
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
            // IF the value exists and is not null
            if (Session["WalletID"] != null)
                walletID = Convert.ToInt32(Session["WalletID"]);

            decimal balance = 0.00m;

            if (walletID > 0)
            {
                balance =
                    DatabaseHelper.GetWalletBalance(walletID);

                Session["AvailableBalance"] = balance;
            }
        }


        private void LoadTransactions()
        {
            int walletID = 0;
            // IF the value exists and is not null
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

            // IF the value is null (not found or not set)
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

            // IF the field is empty or contains only whitespace
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

            // IF the value is null (not found or not set)
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

            // Build the receipt as individual lines, then render them to a PDF.
            var lines = new List<string>
            {
                "FREEHUB TRANSACTION RECEIPT",
                "--------------------------------",
                "",
                "Transaction ID: " + Convert.ToString(transaction["transactionID"]),
                "Reference: " + Convert.ToString(transaction["reference"]),
                "Date: " + Convert.ToDateTime(transaction["transactionDate"]).ToString("dd MMM yyyy, hh:mm tt"),
                "Type: " + type,
                "Amount: " + FormatTransactionAmount(amount, type),
                "Status: " + Convert.ToString(transaction["transactionStatus"]),
                "Payment Method: " + Convert.ToString(transaction["paymentMethod"]),
                "Description: " + Convert.ToString(transaction["itemDescription"]),
                "",
                "--------------------------------",
                "Generated " + DateTime.Now.ToString("dd MMM yyyy, hh:mm tt"),
                "Thank you for using FreeHUB."
            };

            byte[] pdf = BuildReceiptPdf(lines);

            Response.Clear();
            Response.ContentType = "application/pdf";
            Response.AddHeader(
                "content-disposition",
                "attachment;filename=" + transactionId + "-receipt.pdf");
            Response.BinaryWrite(pdf);
            Response.Flush();

            HttpContext.Current
                .ApplicationInstance
                .CompleteRequest();
        }

        /// <summary>
        /// Builds a minimal, valid single-page PDF (A4) containing the given lines
        /// of text using the built-in Helvetica font. No external library needed.
        /// </summary>
        private static byte[] BuildReceiptPdf(List<string> lines)
        {
            // Build the page content stream: start text at (56, 780), 14pt leading.
            var content = new StringBuilder();
            content.Append("BT\n/F1 12 Tf\n14 TL\n56 780 Td\n");
            for (int i = 0; i < lines.Count; i++)
            {
                content.Append("(").Append(EscapePdfText(lines[i])).Append(") Tj\n");
                content.Append("T*\n"); // next line
            }
            content.Append("ET");

            byte[] contentBytes = Encoding.ASCII.GetBytes(content.ToString());

            // Five PDF objects: catalog, pages, page, font, content stream.
            var objects = new List<string>
            {
                "<< /Type /Catalog /Pages 2 0 R >>",
                "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
                "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] " +
                    "/Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>",
                "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
                "<< /Length " + contentBytes.Length + " >>\nstream\n" +
                    content + "\nendstream"
            };

            var pdf = new StringBuilder();
            pdf.Append("%PDF-1.4\n");

            var offsets = new List<int>();
            for (int i = 0; i < objects.Count; i++)
            {
                offsets.Add(Encoding.ASCII.GetByteCount(pdf.ToString()));
                pdf.Append(i + 1).Append(" 0 obj\n").Append(objects[i]).Append("\nendobj\n");
            }

            int xrefPos = Encoding.ASCII.GetByteCount(pdf.ToString());
            pdf.Append("xref\n0 ").Append(objects.Count + 1).Append("\n");
            pdf.Append("0000000000 65535 f \n");
            foreach (int off in offsets)
            {
                pdf.Append(off.ToString("D10")).Append(" 00000 n \n");
            }
            pdf.Append("trailer\n<< /Size ").Append(objects.Count + 1)
               .Append(" /Root 1 0 R >>\nstartxref\n")
               .Append(xrefPos).Append("\n%%EOF");

            return Encoding.ASCII.GetBytes(pdf.ToString());
        }

        /// <summary>Escapes characters that are special inside a PDF text string.</summary>
        private static string EscapePdfText(string text)
        {
            // IF the string is empty or null
            if (string.IsNullOrEmpty(text)) return "";
            // Replace the Rand sign and any non-ASCII with safe equivalents, since
            // the base Helvetica font / our encoding only covers ASCII reliably.
            var sb = new StringBuilder();
            foreach (char c in text)
            {
                if (c == '\\' || c == '(' || c == ')')
                {
                    sb.Append('\\').Append(c);
                }
                else if (c == 'R' || c <= 0x7E)
                {
                    sb.Append(c);
                }
                else if (c == '\u00A0')
                {
                    sb.Append(' ');
                }
                else
                {
                    // Drop other non-ASCII glyphs (e.g. stray symbols) to keep the
                    // stream valid; amounts already use "R" + digits.
                    sb.Append('?');
                }
            }
            return sb.ToString();
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

            // IF the value is null (not found or not set)
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
            if (success) MessageHelper.Success(this, message);
            else MessageHelper.Error(this, message);
        }
    }
}

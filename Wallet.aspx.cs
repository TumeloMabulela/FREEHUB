using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class Wallet : System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlWalletMessage.Visible = false;

                LoadWalletInformation();
                LoadTransactions();
            }
        }


        private void LoadWalletInformation()
        {
            decimal availableBalance =
                GetSessionAmount("AvailableBalance");

            decimal onHoldBalance =
                GetSessionAmount("OnHoldBalance");

            decimal pendingWithdrawals =
                GetSessionAmount("PendingWithdrawals");

            decimal totalBalance =
                availableBalance +
                onHoldBalance +
                pendingWithdrawals;


            string availableText =
                FormatCurrency(availableBalance);

            string onHoldText =
                FormatCurrency(onHoldBalance);

            string pendingText =
                FormatCurrency(pendingWithdrawals);

            string totalText =
                FormatCurrency(totalBalance);


            lblCurrentWalletBalance.Text =
                availableText;

            lblAvailableBalance.Text =
                availableText;

            lblOnHoldBalance.Text =
                onHoldText;

            lblPendingWithdrawals.Text =
                pendingText;

            lblTotalBalance.Text =
                totalText;


            lblSummaryAvailable.Text =
                availableText;

            lblSummaryOnHold.Text =
                onHoldText;

            lblSummaryPending.Text =
                pendingText;

            lblSummaryTotal.Text =
                totalText;
        }


        private decimal GetSessionAmount(
            string sessionName)
        {
            object sessionValue =
                Session[sessionName];

            if (sessionValue == null)
            {
                return 0.00m;
            }

            decimal amount;

            bool validAmount =
                decimal.TryParse(
                    sessionValue.ToString(),
                    out amount
                );

            if (!validAmount)
            {
                return 0.00m;
            }

            return amount;
        }


        private string FormatCurrency(
            decimal amount)
        {
            return
                "R" +
                amount.ToString("N2");
        }


        private void LoadTransactions()
        {
            List<WalletTransaction> transactions =
                Session["WalletTransactions"]
                as List<WalletTransaction>;

            if (transactions == null)
            {
                transactions =
                    new List<WalletTransaction>();
            }

            rptTransactions.DataSource =
                transactions;

            rptTransactions.DataBind();

            pnlNoTransactions.Visible =
                transactions.Count == 0;

            btnViewAllTransactions.Visible =
                transactions.Count > 0;

            btnViewAllTop.Visible =
                transactions.Count > 0;
        }


        public string FormatTransactionAmount(
            decimal amount,
            string transactionType)
        {
            bool isCredit =
                string.Equals(
                    transactionType,
                    "Credit",
                    StringComparison.OrdinalIgnoreCase
                );

            string sign =
                isCredit
                    ? "+"
                    : "-";

            return
                sign +
                " R" +
                Math.Abs(amount).ToString("N2");
        }


        public string GetAmountClass(
            string transactionType)
        {
            if (string.Equals(
                transactionType,
                "Credit",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    "transaction-credit-amount";
            }

            return
                "transaction-debit-amount";
        }


        public string GetTransactionIcon(
            string transactionType)
        {
            if (string.Equals(
                transactionType,
                "Credit",
                StringComparison.OrdinalIgnoreCase))
            {
                return "↓";
            }

            if (string.Equals(
                transactionType,
                "Withdrawal",
                StringComparison.OrdinalIgnoreCase))
            {
                return "◷";
            }

            if (string.Equals(
                transactionType,
                "Refund",
                StringComparison.OrdinalIgnoreCase))
            {
                return "↻";
            }

            return "↑";
        }


        public string GetTransactionIconClass(
            string transactionType)
        {
            string baseClass =
                "transaction-icon ";

            if (string.Equals(
                transactionType,
                "Credit",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "credit-transaction";
            }

            if (string.Equals(
                transactionType,
                "Withdrawal",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "pending-transaction";
            }

            if (string.Equals(
                transactionType,
                "Refund",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "refund-transaction";
            }

            return
                baseClass +
                "debit-transaction";
        }


        public string GetTransactionTypeClass(
            string transactionType)
        {
            string baseClass =
                "transaction-type ";

            if (string.Equals(
                transactionType,
                "Credit",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "credit-type";
            }

            if (string.Equals(
                transactionType,
                "Withdrawal",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "withdrawal-type";
            }

            if (string.Equals(
                transactionType,
                "Refund",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "refund-type";
            }

            return
                baseClass +
                "debit-type";
        }


        public string GetStatusClass(
            string status)
        {
            string baseClass =
                "transaction-status ";

            if (string.Equals(
                status,
                "Completed",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "completed-status";
            }

            if (string.Equals(
                status,
                "Failed",
                StringComparison.OrdinalIgnoreCase))
            {
                return
                    baseClass +
                    "failed-status";
            }

            return
                baseClass +
                "pending-status";
        }


        protected void btnFundWallet_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "FundWallet.aspx"
            );
        }


        protected void btnWithdrawFunds_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "WithdrawFunds.aspx"
            );
        }


        protected void btnViewTransactions_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "Transactions.aspx"
            );
        }


        protected void btnPayouts_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "Payouts.aspx"
            );
        }


        protected void btnDisputes_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "Disputes.aspx"
            );
        }


        protected void btnRefunds_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "Refunds.aspx"
            );
        }


        protected void ViewTransaction_Command(
            object sender,
            CommandEventArgs e)
        {
            string transactionReference =
                Convert.ToString(
                    e.CommandArgument
                );

            if (string.IsNullOrWhiteSpace(
                transactionReference))
            {
                ShowMessage(
                    "The selected transaction reference is invalid.",
                    false
                );

                return;
            }

            Response.Redirect(
                "TransactionDetails.aspx?reference=" +
                Server.UrlEncode(
                    transactionReference
                )
            );
        }


        private void ShowMessage(
            string message,
            bool success)
        {
            pnlWalletMessage.Visible = true;

            lblWalletMessage.Text =
                message;

            pnlWalletMessage.CssClass =
                success
                    ? "wallet-message-panel wallet-success-message"
                    : "wallet-message-panel wallet-warning-message";
        }
    }


    [Serializable]
    public class WalletTransaction
    {
        public DateTime TransactionDate
        {
            get;
            set;
        }

        public string Description
        {
            get;
            set;
        }

        public string Type
        {
            get;
            set;
        }

        public decimal Amount
        {
            get;
            set;
        }

        public string Status
        {
            get;
            set;
        }

        public string Reference
        {
            get;
            set;
        }
    }
}
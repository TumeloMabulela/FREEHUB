using System;

namespace FreeHubProject
{
    public partial class FundWallet : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;

            // Role check - Employer only
            string userType = Session["UserType"] as string ?? "";
            if (userType.Equals("Freelancer", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("Wallet.aspx");
                return;
            }

            if (!IsPostBack)
            {
                pnlMessage.Visible = false;
                LoadWalletBalance();
            }
        }

        private void LoadWalletBalance()
        {
            decimal balance =
                GetSessionDecimal("AvailableBalance");

            lblCurrentBalance.Text =
                FormatCurrency(balance);
        }

        protected void btn500_Click(object sender, EventArgs e)
        {
            SetAmount(500.00m);
        }

        protected void btn1000_Click(object sender, EventArgs e)
        {
            SetAmount(1000.00m);
        }

        protected void btn2500_Click(object sender, EventArgs e)
        {
            SetAmount(2500.00m);
        }

        protected void btn5000_Click(object sender, EventArgs e)
        {
            SetAmount(5000.00m);
        }

        protected void btnOther_Click(object sender, EventArgs e)
        {
            txtAmount.Text = "";

            ShowMessage(
                "Enter your preferred amount.",
                true
            );
        }

        private void SetAmount(decimal amount)
        {
            txtAmount.Text =
                amount.ToString("0.00");

            ShowMessage(
                FormatCurrency(amount) + " selected.",
                true
            );
        }

        protected void btnProceed_Click(object sender, EventArgs e)
        {
            decimal amount;

            bool amountIsValid =
                decimal.TryParse(
                    txtAmount.Text.Trim(),
                    out amount
                );

            if (!amountIsValid || amount <= 0)
            {
                ShowMessage(
                    "Please enter a valid amount.",
                    false
                );

                return;
            }

            if (rblPaymentMethod.SelectedIndex == -1)
            {
                ShowMessage(
                    "Please select a payment method.",
                    false
                );

                return;
            }

            string paymentMethod =
                rblPaymentMethod.SelectedValue;

            // Get wallet ID from session
            int walletID = 0;
            if (Session["WalletID"] != null)
                walletID = Convert.ToInt32(Session["WalletID"]);

            if (walletID == 0)
            {
                ShowMessage(
                    "Wallet not found. Please log in again.",
                    false
                );
                return;
            }

            // Get current balance from DB
            decimal currentBalance =
                DatabaseHelper.GetWalletBalance(walletID);

            decimal newBalance =
                currentBalance + amount;

            // Update wallet balance in DB
            DatabaseHelper.UpdateWalletBalance(
                walletID, newBalance);

            // Save transaction to DB
            string reference =
                TransactionStore.CreateReference("FUND");

            DatabaseHelper.AddTransaction(
                walletID,
                "Funds added using " + paymentMethod,
                "Credit",
                amount,
                "Completed",
                reference,
                paymentMethod
            );

            // Update session to reflect new balance
            Session["AvailableBalance"] = newBalance;

            // Also keep in-memory transaction store in sync
            TransactionStore.AddTransaction(
                Session,
                "Wallet Funded",
                "Funds added using " + paymentMethod,
                "Credit",
                amount,
                "Completed",
                reference,
                paymentMethod
            );

            lblCurrentBalance.Text =
                FormatCurrency(newBalance);

            txtAmount.Text = "";

            ShowMessage(
                "Wallet funded successfully with " +
                FormatCurrency(amount) +
                ". New balance: " +
                FormatCurrency(newBalance) +
                ".",
                true
            );
        }

        protected void btnViewAll_Click(object sender, EventArgs e)
        {
            Response.Redirect(
                "Transactions.aspx"
            );
        }

        private decimal GetSessionDecimal(string sessionName)
        {
            object value =
                Session[sessionName];

            if (value == null)
            {
                return 0.00m;
            }

            decimal amount;

            bool valid =
                decimal.TryParse(
                    value.ToString(),
                    out amount
                );

            return valid
                ? amount
                : 0.00m;
        }

        private string FormatCurrency(decimal amount)
        {
            return
                "R" +
                amount.ToString("N2");
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
                    ? "fw-message fw-success"
                    : "fw-message fw-error";
        }
    }
}
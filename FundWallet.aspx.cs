using System;
using System.Globalization;

namespace FreeHubProject
{
    public partial class FundWallet : System.Web.UI.Page
    {
        // Maximum amount allowed per single deposit to avoid overflow / large-number errors.
        private const decimal MaxDepositAmount = 20000000m;
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

        // Quick-amount buttons. In normal use the client-side addQuickAmount() handles
        // these and returns false (no postback). These server handlers are a no-JS
        // fallback: they ADD the amount to the current field value and enforce the same
        // maximum, so the additive behaviour and limits hold even without JavaScript.
        protected void btn500_Click(object sender, EventArgs e)
        {
            AddAmount(500.00m);
        }

        protected void btn1000_Click(object sender, EventArgs e)
        {
            AddAmount(1000.00m);
        }

        protected void btn2500_Click(object sender, EventArgs e)
        {
            AddAmount(2500.00m);
        }

        protected void btn5000_Click(object sender, EventArgs e)
        {
            AddAmount(5000.00m);
        }

        protected void btn100000_Click(object sender, EventArgs e)
        {
            AddAmount(100000.00m);
        }

        // Reads the current whole-rand amount from the field (0 if blank/invalid),
        // adds the given delta, and writes it back — unless the new total would exceed
        // the maximum, in which case the field is left unchanged and the error is shown.
        private void AddAmount(decimal delta)
        {
            lblAmountError.Text = "";

            string raw = (txtAmount.Text ?? "").Trim();
            decimal current = 0m;
            if (raw.Length > 0)
            {
                // Only accept whole-rand digits; ignore anything invalid (treat as 0).
                string digits = System.Text.RegularExpressions.Regex.Replace(raw, "[^0-9]", "");
                if (digits.Length > 0)
                    decimal.TryParse(digits, NumberStyles.None, CultureInfo.InvariantCulture, out current);
            }

            decimal next = current + delta;

            if (next > MaxDepositAmount)
            {
                // Keep the current value; do not let repeated adds exceed the maximum.
                lblAmountError.Text =
                    "The maximum amount per deposit is " + FormatCurrency(MaxDepositAmount) + ".";
                txtAmount.CssClass = "fw-amount-input input-invalid";
                return;
            }

            // Whole-rand integer, no decimal part, invariant culture.
            txtAmount.Text = decimal.Truncate(next).ToString("0", CultureInfo.InvariantCulture);
            txtAmount.CssClass = "fw-amount-input";

            ShowMessage(FormatCurrency(next) + " entered.", true);
        }

        protected void btnProceed_Click(object sender, EventArgs e)
        {
            lblAmountError.Text = "";

            // Amount must be whole-rand digits only: no sign, comma, decimal or letters.
            string amountRaw = (txtAmount.Text ?? "").Trim();
            decimal amount;

            if (amountRaw.Length == 0)
            {
                lblAmountError.Text = "Please enter an amount.";
                txtAmount.CssClass = "fw-amount-input input-invalid";
                return;
            }
            if (!System.Text.RegularExpressions.Regex.IsMatch(amountRaw, "^[0-9]+$"))
            {
                lblAmountError.Text = "Enter whole rand amounts only (digits 0-9, no commas or decimals).";
                txtAmount.CssClass = "fw-amount-input input-invalid";
                return;
            }
            if (!decimal.TryParse(amountRaw, NumberStyles.None, CultureInfo.InvariantCulture, out amount)
                || amount <= 0)
            {
                lblAmountError.Text = "Please enter an amount greater than zero.";
                txtAmount.CssClass = "fw-amount-input input-invalid";
                return;
            }

            if (amount > MaxDepositAmount)
            {
                lblAmountError.Text =
                    "The maximum amount per deposit is " + FormatCurrency(MaxDepositAmount) + ".";
                txtAmount.CssClass = "fw-amount-input input-invalid";
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
            // Inside btnProceed_Click, right after updating the wallet balance and adding the transaction:
            string formattedAmount = FormatCurrency(amount);
            string fundNotification = $"{formattedAmount} has been added into your account";
            int currentUserId = Convert.ToInt32(Session["UserID"]);
            NotificationHelper.CreateNotification(currentUserId, "Payment", fundNotification);
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

        /// <summary>
        /// Parses a user-entered money amount in a culture-independent way.
        /// Accepts values that use either "." or "," as the decimal separator and
        /// tolerates thousands separators (e.g. "1,000", "1 000", "20000000.00").
        /// </summary>
        private static bool TryParseAmount(string input, out decimal amount)
        {
            amount = 0m;

            if (string.IsNullOrWhiteSpace(input))
                return false;

            // Strip currency symbols and whitespace.
            string cleaned = input.Trim()
                .Replace("R", "")
                .Replace("r", "")
                .Replace(" ", "")
                .Replace("\u00A0", ""); // non-breaking space

            if (cleaned.Length == 0)
                return false;

            int lastComma = cleaned.LastIndexOf(',');
            int lastDot = cleaned.LastIndexOf('.');

            if (lastComma >= 0 && lastDot >= 0)
            {
                // Both present: the right-most one is the decimal separator,
                // the other is a thousands separator to be removed.
                if (lastComma > lastDot)
                {
                    cleaned = cleaned.Replace(".", "");
                    cleaned = cleaned.Replace(",", ".");
                }
                else
                {
                    cleaned = cleaned.Replace(",", "");
                }
            }
            else if (lastComma >= 0)
            {
                // Only commas are present.
                int commaCount = cleaned.Length - cleaned.Replace(",", "").Length;
                int digitsAfterLastComma = cleaned.Length - lastComma - 1;

                // Multiple commas => grouping separators (e.g. "1,000,000").
                // A single comma followed by exactly 3 digits => grouping (e.g. "1,000").
                // Otherwise the comma is a decimal separator (e.g. "500,00" or "500,5").
                if (commaCount > 1 || digitsAfterLastComma == 3)
                    cleaned = cleaned.Replace(",", "");
                else
                    cleaned = cleaned.Replace(",", ".");
            }
            // Only dots (or no separator) is already invariant-friendly.

            return decimal.TryParse(
                cleaned,
                NumberStyles.Number,
                CultureInfo.InvariantCulture,
                out amount);
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
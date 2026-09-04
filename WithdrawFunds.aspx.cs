using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;

namespace FreeHubProject
{
    public partial class WithdrawFunds : System.Web.UI.Page
    {
        protected void Page_Load(
            object sender,
            EventArgs e)
        {
            if (!AuthHelper.RequireLogin(this)) return;

            if (!IsPostBack)
            {
                pnlMessage.Visible = false;

                LoadBalances();
                LoadBankAccounts();
                LoadWithdrawals();
            }
        }


        private void LoadBalances()
        {
            decimal availableBalance = 0.00m;

            int walletID = 0;
            if (Session["WalletID"] != null)
                walletID = Convert.ToInt32(Session["WalletID"]);

            if (walletID > 0)
            {
                availableBalance =
                    DatabaseHelper.GetWalletBalance(walletID);

                Session["AvailableBalance"] =
                    availableBalance;
            }
            else
            {
                availableBalance =
                    GetSessionDecimal("AvailableBalance");
            }

            string formattedBalance =
                FormatCurrency(
                    availableBalance
                );

            lblCurrentBalance.Text =
                formattedBalance;

            lblAvailableBalance.Text =
                formattedBalance;
        }


        private void LoadBankAccounts()
        {
            ddlBankAccount.Items.Clear();

            ddlBankAccount.Items.Add(
                new ListItem(
                    "Choose account",
                    ""
                )
            );

            List<BankAccountOption> accounts =
                Session["BankAccounts"]
                as List<BankAccountOption>;

            if (accounts == null ||
                accounts.Count == 0)
            {
                ddlBankAccount.Items.Add(
                    new ListItem(
                        "Primary Bank Account",
                        "Primary Bank Account"
                    )
                );

                return;
            }

            foreach (
                BankAccountOption account
                in accounts)
            {
                ddlBankAccount.Items.Add(
                    new ListItem(
                        account.DisplayName,
                        account.DisplayName
                    )
                );
            }
        }


        private void LoadWithdrawals()
        {
            List<WithdrawalRequest> withdrawals =
                GetWithdrawalList();

            withdrawals.Sort(
                delegate (
                    WithdrawalRequest first,
                    WithdrawalRequest second)
                {
                    return
                        second.RequestDate.CompareTo(
                            first.RequestDate
                        );
                }
            );

            rptWithdrawals.DataSource =
                withdrawals;

            rptWithdrawals.DataBind();

            pnlNoWithdrawals.Visible =
                withdrawals.Count == 0;

            btnViewAll.Visible =
                withdrawals.Count > 0;
        }


        protected void btnContinue_Click(
            object sender,
            EventArgs e)
        {
            decimal withdrawalAmount;

            bool amountIsValid =
                decimal.TryParse(
                    txtAmount.Text.Trim(),
                    out withdrawalAmount
                );

            if (!amountIsValid ||
                withdrawalAmount <= 0)
            {
                ShowMessage(
                    "Please enter a valid withdrawal amount.",
                    false
                );

                return;
            }

            if (withdrawalAmount < 100.00m)
            {
                ShowMessage(
                    "The minimum withdrawal amount is R100.00.",
                    false
                );

                return;
            }

            if (string.IsNullOrWhiteSpace(
                ddlBankAccount.SelectedValue))
            {
                ShowMessage(
                    "Please select a bank account.",
                    false
                );

                return;
            }

            string selectedBankAccount =
                ddlBankAccount
                    .SelectedItem
                    .Text;

            // Get wallet ID
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

            // Get current balance from DB (single source of truth)
            decimal dbBalance =
                DatabaseHelper.GetWalletBalance(walletID);

            if (withdrawalAmount > dbBalance)
            {
                ShowMessage(
                    "You do not have enough available funds.",
                    false
                );
                return;
            }

            decimal newAvailableBalance =
                dbBalance - withdrawalAmount;

            // Update wallet balance in DB
            DatabaseHelper.UpdateWalletBalance(
                walletID, newAvailableBalance);

            // Save transaction to DB
            string withdrawalId =
                TransactionStore.CreateReference("WD");

            DatabaseHelper.AddTransaction(
                walletID,
                "Withdrawal to " + selectedBankAccount,
                "Withdrawal",
                withdrawalAmount,
                "Pending",
                withdrawalId,
                "Bank Transfer"
            );

            // Update session
            Session["AvailableBalance"] =
                newAvailableBalance;

            decimal currentPendingAmount =
                GetSessionDecimal("PendingWithdrawals");

            decimal newPendingAmount =
                currentPendingAmount + withdrawalAmount;

            Session["PendingWithdrawals"] =
                newPendingAmount;

            // Save withdrawal request in session list
            List<WithdrawalRequest> withdrawals =
                GetWithdrawalList();

            WithdrawalRequest request =
                new WithdrawalRequest
                {
                    WithdrawalId =
                        withdrawalId,

                    RequestDate =
                        DateTime.Now,

                    Amount =
                        withdrawalAmount,

                    BankAccount =
                        selectedBankAccount,

                    Status =
                        "Pending",

                    AdminComment =
                        "",

                    ProcessedDate =
                        null
                };

            withdrawals.Add(request);

            Session["WithdrawalRequests"] =
                withdrawals;

            // Keep in-memory transaction store in sync
            TransactionStore.AddTransaction(
                Session,
                "Withdrawal Request",
                "Withdrawal to " + selectedBankAccount,
                "Withdrawal",
                withdrawalAmount,
                "Pending",
                withdrawalId,
                "Bank Transfer"
            );

            Session["LastWithdrawalAmount"] =
                withdrawalAmount;

            Session["LastWithdrawalTransactionId"] =
                withdrawalId;

            LoadBalances();
            LoadWithdrawals();


            txtAmount.Text =
                "";

            ddlBankAccount.SelectedIndex =
                0;

            lblSummaryAmount.Text =
                "R0.00";

            lblServiceFee.Text =
                "R0.00";

            lblYouWillReceive.Text =
                "R0.00";


            ShowMessage(
                "Withdrawal request submitted. " +
                FormatCurrency(withdrawalAmount) +
                " has been deducted from your available balance. " +
                "The withdrawal is pending administrator approval.",
                true
            );

            // Inside btnContinue_Click right after successful processing:
            string formattedWithdrawal = FormatCurrency(withdrawalAmount);
            string withdrawMsg = $"{formattedWithdrawal} has been withdrawn.";
            int currentUserId = Convert.ToInt32(Session["UserID"]);
            NotificationHelper.CreateNotification(currentUserId, "Payment", withdrawMsg);
        }


        protected void btnViewAll_Click(
            object sender,
            EventArgs e)
        {
            Response.Redirect(
                "Transactions.aspx?type=Withdrawal"
            );
        }


        private List<WithdrawalRequest>
            GetWithdrawalList()
        {
            List<WithdrawalRequest> withdrawals =
                Session["WithdrawalRequests"]
                as List<WithdrawalRequest>;

            if (withdrawals == null)
            {
                withdrawals =
                    new List<WithdrawalRequest>();

                Session["WithdrawalRequests"] =
                    withdrawals;
            }

            return withdrawals;
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

            bool isValid =
                decimal.TryParse(
                    value.ToString(),
                    out amount
                );

            return isValid
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


        private void ShowMessage(
            string message,
            bool success)
        {
            pnlMessage.Visible =
                true;

            lblMessage.Text =
                message;

            pnlMessage.CssClass =
                success
                    ? "withdraw-message withdraw-success"
                    : "withdraw-message withdraw-error";
        }
    }


    [Serializable]
    public class WithdrawalRequest
    {
        public string WithdrawalId
        {
            get;
            set;
        }

        public DateTime RequestDate
        {
            get;
            set;
        }

        public decimal Amount
        {
            get;
            set;
        }

        public string BankAccount
        {
            get;
            set;
        }

        public string Status
        {
            get;
            set;
        }

        public string AdminComment
        {
            get;
            set;
        }

        public DateTime? ProcessedDate
        {
            get;
            set;
        }
    }


    [Serializable]
    public class BankAccountOption
    {
        public string DisplayName
        {
            get;
            set;
        }
    }
}
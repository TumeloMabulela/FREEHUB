using System;
using System.Data;
using System.Web.SessionState;

namespace FreeHubProject
{
    public static class TransactionStore
    {
        private const string TransactionSessionKey =
            "FreeHubTransactions";


        public static DataTable GetTransactions(
            HttpSessionState session)
        {
            DataTable table =
                session[TransactionSessionKey] as DataTable;

            if (table != null)
            {
                return table;
            }

            table = new DataTable();

            table.Columns.Add(
                "TransactionId",
                typeof(string)
            );

            table.Columns.Add(
                "TransactionDate",
                typeof(DateTime)
            );

            table.Columns.Add(
                "Title",
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
                "Amount",
                typeof(decimal)
            );

            table.Columns.Add(
                "Status",
                typeof(string)
            );

            table.Columns.Add(
                "Reference",
                typeof(string)
            );

            table.Columns.Add(
                "PaymentMethod",
                typeof(string)
            );

            session[TransactionSessionKey] =
                table;

            return table;
        }


        public static void AddTransaction(
            HttpSessionState session,
            string title,
            string description,
            string type,
            decimal amount,
            string status,
            string reference,
            string paymentMethod)
        {
            DataTable table =
                GetTransactions(session);

            DataRow row =
                table.NewRow();

            row["TransactionId"] =
                CreateTransactionId();

            row["TransactionDate"] =
                DateTime.Now;

            row["Title"] =
                title ?? "";

            row["Description"] =
                description ?? "";

            row["Type"] =
                type ?? "";

            row["Amount"] =
                Math.Abs(amount);

            row["Status"] =
                status ?? "";

            row["Reference"] =
                reference ?? "";

            row["PaymentMethod"] =
                paymentMethod ?? "";

            table.Rows.Add(row);

            session[TransactionSessionKey] =
                table;
        }


        public static DataRow FindTransaction(
            HttpSessionState session,
            string transactionId)
        {
            DataTable table =
                GetTransactions(session);

            foreach (DataRow row in table.Rows)
            {
                string currentId =
                    Convert.ToString(
                        row["TransactionId"]
                    );

                if (string.Equals(
                    currentId,
                    transactionId,
                    StringComparison.OrdinalIgnoreCase))
                {
                    return row;
                }
            }

            return null;
        }


        public static string CreateReference(
            string prefix)
        {
            return
                prefix +
                "-" +
                Guid.NewGuid()
                    .ToString("N")
                    .Substring(0, 8)
                    .ToUpper();
        }


        private static string CreateTransactionId()
        {
            return
                "TXN-" +
                Guid.NewGuid()
                    .ToString("N")
                    .Substring(0, 12)
                    .ToUpper();
        }
    }
}
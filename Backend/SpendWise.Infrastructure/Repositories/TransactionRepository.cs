using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Transactions;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Repositories
{
    public class TransactionRepository : BaseRepository, ITransactionRepository
    {
        public TransactionRepository(IConfiguration configuration)
            : base(configuration.GetConnectionString("DefaultConnection")
                  ?? throw new ArgumentNullException(nameof(configuration), "Connection string is missing in appsettings."))
        { }

        public async Task<(IEnumerable<Transaction> transactions, int totalCount)> GetTransactionsByUserAsync(int userId, int pageNumber, int pageSize)
        {
            var transactions = new List<Transaction>();
            int totalCount = 0;

            // Sequential execution across multi-result sets via Grid Reader delegate pattern
            await ExecuteReaderAsync("[Ledger].[sp_GetTransactionsByUserPaged]",
                cmd =>
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@PageNumber", pageNumber);
                    cmd.Parameters.AddWithValue("@PageSize", pageSize);
                },
                async reader =>
                {
                    // Result Set 1: Total Row Count
                    if (await reader.ReadAsync())
                    {
                        totalCount = EmptyValuesHandler.GetInt32OrDefault(reader, "TotalCount");
                    }

                    // Result Set 2: Paged Transactions List
                    if (await reader.NextResultAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            transactions.Add(MapToTransaction(reader));
                        }
                    }
                    return default(object); // Dummy return to satisfy core functional signatures
                });

            return (transactions, totalCount);
        }

        // =========================================================================
        // REUSABLE HELPER METHODS & MAPPERS
        // =========================================================================
        private static Transaction MapToTransaction(SqlDataReader reader)
        {
            var transaction = new Transaction(
                EmptyValuesHandler.GetInt32OrDefault(reader, "TransactionID"),
                EmptyValuesHandler.GetInt32OrDefault(reader, "UserID"),
                EmptyValuesHandler.GetStringOrDefault(reader, "Title"),
                EmptyValuesHandler.GetStringOrDefault(reader, "Description"),
                EmptyValuesHandler.GetInt32OrDefault(reader, "WalletID"),
                EmptyValuesHandler.GetDecimalOrDefault(reader, "Amount"),
                EmptyValuesHandler.GetDecimalOrDefault(reader, "AmountInSp"),
                EmptyValuesHandler.GetDateTimeOrDefault(reader, "TransactionDate"),
                EmptyValuesHandler.GetInt32OrDefault(reader, "TransactionType") == 0 ? enTransactionType.Addition : enTransactionType.Dedduction,
                reader.IsDBNull(reader.GetOrdinal("GoalID")) ? -1 : Convert.ToInt32(reader["GoalID"]),
                reader.IsDBNull(reader.GetOrdinal("FixedExpenseID")) ? -1 : Convert.ToInt32(reader["FixedExpenseID"]),
                reader.IsDBNull(reader.GetOrdinal("FixedIncomeID")) ? -1 : Convert.ToInt32(reader["FixedIncomeID"]),
                reader.IsDBNull(reader.GetOrdinal("DebtID")) ? -1 : Convert.ToInt32(reader["DebtID"])
            );

            // Context-driven polymorphism check to link tracking properties inside domain boundaries
            bool isCoreTransaction = transaction.SavingGoalId == -1
                && transaction.DebtId == -1
                && transaction.FixedExpenseId == -1
                && transaction.FixedIncomeId == -1;

            if (isCoreTransaction && transaction.TransactionType == enTransactionType.Addition)
            {
                transaction.IncomeId = transaction.TransactionId;
            }
            else
            {
                transaction.ExpenseId = transaction.TransactionId;
            }

            return transaction;
        }
    }
}
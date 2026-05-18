using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Transactions;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace SpendWise.Infrastructure.Repositories
{
    public class TransactionRepository: ITransactionRepository
    {
        private readonly string _connectionString;
        public TransactionRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                                            ?? throw new ArgumentNullException("Connection string is missing in appsettings.");
        }

        private static Transaction MapToTransaction(SqlDataReader reader)
        {

            var transaction = new Transaction(
                Convert.ToInt32(reader["TransactionID"]),
                Convert.ToInt32(reader["UserID"]),
                reader["Title"].ToString()!,
                reader["Description"].ToString()!,
                Convert.ToInt32(reader["WalletID"]),
                Convert.ToDecimal(reader["Amount"]),
                Convert.ToDecimal(reader["AmountInSp"]),
                Convert.ToDateTime(reader["TransactionDate"]),
                Convert.ToInt32(reader["TransactionType"]) == 0 ? enTransactionType.Addition : enTransactionType.Dedduction,
                reader["GoalID"] != DBNull.Value ? Convert.ToInt32(reader["GoalID"]) : -1,
                reader["FixedExpenseID"] != DBNull.Value ? Convert.ToInt32(reader["FixedExpenseID"]) : -1,
                reader["FixedIncomeID"] != DBNull.Value ? Convert.ToInt32(reader["FixedIncomeID"]) : -1,
                reader["DebtID"] != DBNull.Value ? Convert.ToInt32(reader["DebtID"]) : -1
            );

            bool check = transaction.SavingGoalId == -1
                && transaction.DebtId == -1
                && transaction.FixedExpenseId == -1
                && transaction.FixedIncomeId == -1;

            if (check && transaction.TransactionType == enTransactionType.Addition)
            {
                transaction.IncomeId = transaction.TransactionId;
            }
            else
            {
                transaction.ExpenseId = transaction.TransactionId;
            }

            return transaction;
        }
        public async Task<(IEnumerable<Transaction> transactions, int totalCount)> GetTransactionsByUserAsync(int userId, int pageNumber, int pageSize)
        {
            var transactions = new List<Transaction>();
            int totalCount = 0;

            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_GetTransactionsByUserPaged]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@PageNumber", pageNumber);
                command.Parameters.AddWithValue("@PageSize", pageSize);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    totalCount = Convert.ToInt32(reader["TotalCount"]);
                }

                if (await reader.NextResultAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        transactions.Add(MapToTransaction(reader));
                    }
                }

                return (transactions, totalCount);
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }
    }
}

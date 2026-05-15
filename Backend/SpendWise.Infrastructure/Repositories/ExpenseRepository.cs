using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Expenses;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Repositories
{
    public class ExpenseRepository : IExpenseRepository
    {
        private readonly string _connectionString;

        public ExpenseRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                                            ?? throw new ArgumentNullException("Connection string is missing in appsettings.");
        }

        private static Expense MapToExpense(SqlDataReader reader)
        {
            var expense = new Expense
            {
                ExpenseId = Convert.ToInt32(reader["ExpenseID"]),
                UserId = Convert.ToInt32(reader["UserID"]),
                Title = reader["Title"].ToString()!,
                Amount = Convert.ToDecimal(reader["Amount"]),
                Date = Convert.ToDateTime(reader["Date"]),
                WalletId = Convert.ToInt32(reader["WalletID"]),
                CategoryId = Convert.ToInt32(reader["CategoryID"]),
                Products = reader["Products"] != DBNull.Value ? reader["Products"].ToString()! : string.Empty,
                ExpenseTagId = reader["TagID"] != DBNull.Value ? Convert.ToInt32(reader["TagID"]) : -1
            };

            expense.LinkedTransaction = new Transaction(
                expense.ExpenseId,
                expense.UserId,
                expense.Title,
                reader["Description"] != DBNull.Value ? reader["Description"].ToString()! : string.Empty,
                expense.WalletId,
                expense.Amount,
                Convert.ToDecimal(reader["AmountInSp"]),
                expense.Date,
                enTransactionType.Dedduction
            );

            return expense;
        }

        public async Task<(int ExpenseId, bool IsOverLimit)> AddExpenseAsync(Expense newExpense)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_AddExpenseWithTransaction]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                // Core Data
                command.Parameters.AddWithValue("@UserId", newExpense.UserId);
                command.Parameters.AddWithValue("@WalletId", newExpense.WalletId);
                command.Parameters.AddWithValue("@CategoryId", newExpense.CategoryId);
                command.Parameters.AddWithValue("@Amount", newExpense.Amount);
                command.Parameters.AddWithValue("@Date", newExpense.Date);
                command.Parameters.AddWithValue("@Title", newExpense.Title);

                // Additional Expense Fields
                command.Parameters.AddWithValue("@Products", (object)newExpense.Products ?? DBNull.Value);
                command.Parameters.AddWithValue("@TagId", newExpense.ExpenseTagId > 0 ? (object)newExpense.ExpenseTagId : DBNull.Value);

                // Transaction/Shared Data
                command.Parameters.AddWithValue("@Description", (object)newExpense.LinkedTransaction.Description ?? DBNull.Value);
                command.Parameters.AddWithValue("@AmountInSp", newExpense.LinkedTransaction.AmountInSp);
                command.Parameters.AddWithValue("@TransactionType", (int)enTransactionType.Dedduction);

                // Output parameters
                var outputId = new SqlParameter("@NewExpenseID", SqlDbType.Int) { Direction = ParameterDirection.Output };
                var outputLimit = new SqlParameter("@IsOverLimit", SqlDbType.Bit) { Direction = ParameterDirection.Output };
                command.Parameters.Add(outputId);
                command.Parameters.Add(outputLimit);

                await connection.OpenAsync();
                await command.ExecuteNonQueryAsync();

                return ((int)outputId.Value, (bool)outputLimit.Value);
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<(bool Success, bool IsOverLimit)> UpdateExpenseAsync(Expense newExpense)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_UpdateExpenseWithTransaction]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                // 1. Core ID and Identity
                command.Parameters.AddWithValue("@ExpenseId", newExpense.ExpenseId);
                command.Parameters.AddWithValue("@UserId", newExpense.UserId);

                // 2. Expense Table Data
                command.Parameters.AddWithValue("@WalletId", newExpense.WalletId);
                command.Parameters.AddWithValue("@CategoryId", newExpense.CategoryId);
                command.Parameters.AddWithValue("@Amount", newExpense.Amount);
                command.Parameters.AddWithValue("@Date", newExpense.Date);
                command.Parameters.AddWithValue("@Products", (object)newExpense.Products ?? DBNull.Value);
                command.Parameters.AddWithValue("@TagId", newExpense.ExpenseTagId > 0 ? (object)newExpense.ExpenseTagId : DBNull.Value);

                // 3. Transaction/Shared Data
                command.Parameters.AddWithValue("@Title", newExpense.LinkedTransaction.Title);
                command.Parameters.AddWithValue("@Description", (object)newExpense.LinkedTransaction.Description ?? DBNull.Value);
                command.Parameters.AddWithValue("@AmountInSp", newExpense.LinkedTransaction.AmountInSp);
                command.Parameters.AddWithValue("@TransactionType", (int)enTransactionType.Dedduction);

                // Output parameter for logic
                var outputLimit = new SqlParameter("@IsOverLimit", SqlDbType.Bit) { Direction = ParameterDirection.Output };
                command.Parameters.Add(outputLimit);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                bool success = result != null && int.TryParse(result.ToString(), out int rows) && rows > 0;
                return (success, (bool)outputLimit.Value);
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<bool> DeleteExpenseAsync(int expenseId, int userId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_DeleteExpense]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@ExpenseId", expenseId);
                command.Parameters.AddWithValue("@UserId", userId);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                return result != null && int.TryParse(result.ToString(), out int rows) && rows > 0;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<Expense> GetExpenseAsync(int expenseId, int userId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_GetExpense]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@ExpenseID", expenseId);
                command.Parameters.AddWithValue("@UserID", userId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                return await reader.ReadAsync() ? MapToExpense(reader) : null!;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<(IEnumerable<Expense> expenses, int totalCount)> GetExpensesByUserAsync(int userId, int pageNumber, int pageSize)
        {
            var expenses = new List<Expense>();
            int totalCount = 0;

            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_GetExpensesByUserPaged]", connection)
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
                        expenses.Add(MapToExpense(reader));
                    }
                }

                return (expenses, totalCount);
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<string> GetProductsAsync(int expenseId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_GetProducts]", connection) { CommandType = CommandType.StoredProcedure };
                command.Parameters.AddWithValue("@ExpenseId", expenseId);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();
                return result?.ToString() ?? string.Empty;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }
    }
}
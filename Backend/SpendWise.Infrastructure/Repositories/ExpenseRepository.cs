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
    public class ExpenseRepository : BaseRepository, IExpenseRepository
    {
        public ExpenseRepository(IConfiguration configuration)
            : base(configuration.GetConnectionString("DefaultConnection")
                  ?? throw new ArgumentNullException(nameof(configuration), "Connection string is missing in appsettings."))
        { }

        public async Task<(int ExpenseId, bool IsOverLimit)> AddExpenseAsync(Expense newExpense)
        {
            SqlParameter? outputId = null;
            SqlParameter? outputLimit = null;

            // Using ExecuteScalarAsync while capturing output parameters via lambda closure
            await ExecuteScalarAsync<int>("[Ledger].[sp_AddExpenseWithTransaction]", cmd =>
            {
                cmd.Parameters.AddWithValue("@UserId", newExpense.UserId);
                cmd.Parameters.AddWithValue("@WalletId", newExpense.WalletId);
                cmd.Parameters.AddWithValue("@CategoryId", newExpense.CategoryId);
                cmd.Parameters.AddWithValue("@Amount", newExpense.Amount);
                cmd.Parameters.AddWithValue("@Date", newExpense.Date);
                cmd.Parameters.AddWithValue("@Title", newExpense.Title);

                cmd.Parameters.AddWithValue("@Products", (object)newExpense.Products ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TagId", newExpense.ExpenseTagId > 0 ? newExpense.ExpenseTagId : DBNull.Value);

                cmd.Parameters.AddWithValue("@Description", (object)newExpense.LinkedTransaction.Description ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@AmountInSp", newExpense.LinkedTransaction.AmountInSp);
                cmd.Parameters.AddWithValue("@TransactionType", (int)enTransactionType.Dedduction);

                outputId = new SqlParameter("@NewExpenseID", SqlDbType.Int) { Direction = ParameterDirection.Output };
                outputLimit = new SqlParameter("@IsOverLimit", SqlDbType.Bit) { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outputId);
                cmd.Parameters.Add(outputLimit);
            });

            return ((int)(outputId?.Value ?? -1), (bool)(outputLimit?.Value ?? false));
        }

        public async Task<(int ExpenseId, bool IsOverLimit)> AddExpenseUsingBothWalletsAsync(
            Expense newExpense,
            int primaryWalletId,
            int savingWalletId,
            decimal amountFromPrimaryWallet,
            decimal amountFromSavingWallet)
        {
            SqlParameter? outputId = null;
            SqlParameter? outputLimit = null;

            await ExecuteScalarAsync<int>("[Ledger].[sp_AddExpenseUsingBothWallets]", cmd =>
            {
                cmd.Parameters.AddWithValue("@UserId", newExpense.UserId);
                cmd.Parameters.AddWithValue("@CategoryId", newExpense.CategoryId);
                cmd.Parameters.AddWithValue("@Amount", newExpense.Amount);
                cmd.Parameters.AddWithValue("@Date", newExpense.Date);
                cmd.Parameters.AddWithValue("@Title", newExpense.Title);

                cmd.Parameters.AddWithValue("@PrimaryWalletId", primaryWalletId);
                cmd.Parameters.AddWithValue("@SavingWalletId", savingWalletId);
                cmd.Parameters.AddWithValue("@AmountFromPrimaryWallet", amountFromPrimaryWallet);
                cmd.Parameters.AddWithValue("@AmountFromSavingWallet", amountFromSavingWallet);

                cmd.Parameters.AddWithValue("@Products", (object)newExpense.Products ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TagId", newExpense.ExpenseTagId > 0 ? newExpense.ExpenseTagId : DBNull.Value);

                cmd.Parameters.AddWithValue("@Description", (object)newExpense.LinkedTransaction.Description ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@AmountInSp", newExpense.LinkedTransaction.AmountInSp);
                cmd.Parameters.AddWithValue("@TransactionType", (int)enTransactionType.Dedduction);

                outputId = new SqlParameter("@NewExpenseID", SqlDbType.Int) { Direction = ParameterDirection.Output };
                outputLimit = new SqlParameter("@IsOverLimit", SqlDbType.Bit) { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outputId);
                cmd.Parameters.Add(outputLimit);
            });

            return ((int)(outputId?.Value ?? -1), (bool)(outputLimit?.Value ?? false));
        }

        public async Task<(bool Success, bool IsOverLimit)> UpdateExpenseAsync(Expense newExpense)
        {
            SqlParameter? outputLimit = null;

            var rowsAffected = await ExecuteScalarAsync<int>("[Ledger].[sp_UpdateExpenseWithTransaction]", cmd =>
            {
                cmd.Parameters.AddWithValue("@ExpenseId", newExpense.ExpenseId);
                cmd.Parameters.AddWithValue("@UserId", newExpense.UserId);
                cmd.Parameters.AddWithValue("@WalletId", newExpense.WalletId);
                cmd.Parameters.AddWithValue("@CategoryId", newExpense.CategoryId);
                cmd.Parameters.AddWithValue("@Amount", newExpense.Amount);
                cmd.Parameters.AddWithValue("@Date", newExpense.Date);
                cmd.Parameters.AddWithValue("@Products", (object)newExpense.Products ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TagId", newExpense.ExpenseTagId > 0 ? newExpense.ExpenseTagId : DBNull.Value);

                cmd.Parameters.AddWithValue("@Title", newExpense.LinkedTransaction.Title);
                cmd.Parameters.AddWithValue("@Description", (object)newExpense.LinkedTransaction.Description ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@AmountInSp", newExpense.LinkedTransaction.AmountInSp);
                cmd.Parameters.AddWithValue("@TransactionType", (int)enTransactionType.Dedduction);

                outputLimit = new SqlParameter("@IsOverLimit", SqlDbType.Bit) { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outputLimit);
            });

            return (rowsAffected > 0, (bool)(outputLimit?.Value ?? false));
        }

        public async Task<(bool Success, bool IsOverLimit)> UpdateExpenseUsingBothWalletsAsync(
            Expense newExpense,
            int primaryWalletId,
            decimal amountFromPrimaryWallet,
            decimal amountFromSavingWallet)
        {
            SqlParameter? outputLimit = null;

            var rowsAffected = await ExecuteNonQueryAsync("[Ledger].[sp_UpdateExpenseUsingBothWallets]", cmd =>
            {
                cmd.Parameters.AddWithValue("@ExpenseId", newExpense.ExpenseId);
                cmd.Parameters.AddWithValue("@UserId", newExpense.UserId);
                cmd.Parameters.AddWithValue("@CategoryId", newExpense.CategoryId);
                cmd.Parameters.AddWithValue("@Amount", newExpense.Amount);
                cmd.Parameters.AddWithValue("@Date", newExpense.Date);
                cmd.Parameters.AddWithValue("@Title", newExpense.Title);

                cmd.Parameters.AddWithValue("@PrimaryWalletId", primaryWalletId);
                cmd.Parameters.AddWithValue("@AmountFromPrimaryWallet", amountFromPrimaryWallet);
                cmd.Parameters.AddWithValue("@AmountFromSavingWallet", amountFromSavingWallet);

                cmd.Parameters.AddWithValue("@Products", (object)newExpense.Products ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TagId", newExpense.ExpenseTagId > 0 ? newExpense.ExpenseTagId : DBNull.Value);

                cmd.Parameters.AddWithValue("@Description", (object)newExpense.LinkedTransaction.Description ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@AmountInSp", newExpense.LinkedTransaction.AmountInSp);
                cmd.Parameters.AddWithValue("@TransactionType", (int)enTransactionType.Dedduction);

                outputLimit = new SqlParameter("@IsOverLimit", SqlDbType.Bit) { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outputLimit);
            });

            return (rowsAffected > 0, (bool)(outputLimit?.Value ?? false));
        }

        public async Task<bool> DeleteExpenseAsync(int expenseId, int userId)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Ledger].[sp_DeleteExpense]", cmd =>
            {
                cmd.Parameters.AddWithValue("@ExpenseId", expenseId);
                cmd.Parameters.AddWithValue("@UserId", userId);
            });

            return rowsAffected > 0;
        }

        public async Task<Expense?> GetExpenseAsync(int expenseId, int userId)
        {
            return await ExecuteReaderSingleAsync("[Ledger].[sp_GetExpense]", cmd =>
            {
                cmd.Parameters.AddWithValue("@ExpenseID", expenseId);
                cmd.Parameters.AddWithValue("@UserID", userId);
            }, MapToExpense);
        }

        public async Task<(IEnumerable<Expense> expenses, int totalCount)> GetExpensesByUserAsync(int userId, int pageNumber, int pageSize)
        {
            var expenses = new List<Expense>();
            int totalCount = 0;

            // Handled using an inline custom reader context since it handles multi-result grid structures natively
            await ExecuteReaderAsync("[Ledger].[sp_GetExpensesByUserPaged]",
                cmd =>
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@PageNumber", pageNumber);
                    cmd.Parameters.AddWithValue("@PageSize", pageSize);
                },
                async reader =>
                {
                    // First Result Set: Total Count
                    if (await reader.ReadAsync())
                    {
                        totalCount = EmptyValuesHandler.GetInt32OrDefault(reader, "TotalCount");
                    }

                    // Second Result Set: Paged Expenses list
                    if (await reader.NextResultAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            expenses.Add(MapToExpense(reader));
                        }
                    }
                    return default(object); // Dummy return required by functional mapping delegate signature
                });

            return (expenses, totalCount);
        }

        public async Task<string> GetProductsAsync(int expenseId)
        {
            var result = await ExecuteScalarAsync<object>("[Ledger].[sp_GetProducts]",
                cmd => cmd.Parameters.AddWithValue("@ExpenseId", expenseId));

            return result?.ToString() ?? string.Empty;
        }

        // =========================================================================
        // REUSABLE HELPER METHODS & MAPPERS
        // =========================================================================
        private static Expense MapToExpense(SqlDataReader reader)
        {
            var expense = new Expense
            {
                ExpenseId = EmptyValuesHandler.GetInt32OrDefault(reader, "ExpenseID"),
                UserId = EmptyValuesHandler.GetInt32OrDefault(reader, "UserID"),
                Title = EmptyValuesHandler.GetStringOrDefault(reader, "Title"),
                Amount = EmptyValuesHandler.GetDecimalOrDefault(reader, "Amount"),
                Date = EmptyValuesHandler.GetDateTimeOrDefault(reader, "Date"),
                WalletId = EmptyValuesHandler.GetInt32OrDefault(reader, "WalletID"),
                CategoryId = EmptyValuesHandler.GetInt32OrDefault(reader, "CategoryID"),
                Products = EmptyValuesHandler.GetStringOrDefault(reader, "Products"),
                ExpenseTagId = reader.IsDBNull(reader.GetOrdinal("TagID")) ? -1 : Convert.ToInt32(reader["TagID"])
            };

            expense.LinkedTransaction = new Transaction(
                expense.ExpenseId,
                expense.UserId,
                expense.Title,
                EmptyValuesHandler.GetStringOrDefault(reader, "Description"),
                expense.WalletId,
                expense.Amount,
                EmptyValuesHandler.GetDecimalOrDefault(reader, "AmountInSp"),
                expense.Date,
                enTransactionType.Dedduction,
                -1, -1, -1, -1
            );

            return expense;
        }
    }
}
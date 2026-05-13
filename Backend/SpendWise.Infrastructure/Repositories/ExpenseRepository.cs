using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using SpendWise.Application.Interfaces.Expenses;

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

        public async Task<(int ExpenseId, bool IsOverLimit)> AddExpenseAsync(Expense newExpense, Transaction newTransaction)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_AddExpenseWithTransaction]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                // Expense Parameters
                command.Parameters.AddWithValue("@ExpenseUserId", newExpense.UserId);
                command.Parameters.AddWithValue("@ExpenseWalletId", newExpense.WalletId);
                command.Parameters.AddWithValue("@ExpenseCategoryId", newExpense.CategoryId);
                command.Parameters.AddWithValue("@Products", (object)newExpense.Products ?? DBNull.Value);
                command.Parameters.AddWithValue("@ExpenseAmount", newExpense.Amount);
                command.Parameters.AddWithValue("@ExpenseDate", newExpense.Date);
                command.Parameters.AddWithValue("@ExpenseTagId", newExpense.ExpenseTagId > 0 ? newExpense.ExpenseTagId : DBNull.Value);

                // Transaction Parameters
                command.Parameters.AddWithValue("@TransTitle", newTransaction.Title);
                command.Parameters.AddWithValue("@TransDescription", (object)newTransaction.Description ?? DBNull.Value);
                command.Parameters.AddWithValue("@TransType", (int)newTransaction.TransactionType);
                command.Parameters.AddWithValue("@TransAmountInSp", newTransaction.AmountInSp);
                command.Parameters.AddWithValue("@TransTagId", newTransaction.TransactionTagId > 0 ? newTransaction.TransactionTagId : DBNull.Value);
                command.Parameters.AddWithValue("@TransCategoryId", newTransaction.TransactionCategoryId > 0 ? newTransaction.TransactionCategoryId : DBNull.Value);

                // Define Output Parameters 
                command.Parameters.Add("@NewExpenseID", SqlDbType.Int).Direction = ParameterDirection.Output;
                command.Parameters.Add("@IsOverLimit", SqlDbType.Bit).Direction = ParameterDirection.Output;

                await connection.OpenAsync();

                // Use ExecuteReader to get the result set from the SELECT at the end of the SP
                using var reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    return (
                        ExpenseId: reader.GetInt32(0),
                        IsOverLimit: reader.GetBoolean(1)
                    );
                }

                return (-1, false);
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<(bool Success, bool IsOverLimit)> UpdateExpenseAsync(Expense newExpense, Transaction newTransaction)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_UpdateExpenseWithTransaction]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                // Parameters 
                command.Parameters.AddWithValue("@ExpenseId", newExpense.ExpenseId);
                command.Parameters.AddWithValue("@ExpenseUserId", newExpense.UserId);
                command.Parameters.AddWithValue("@ExpenseWalletId", newExpense.WalletId);
                command.Parameters.AddWithValue("@ExpenseCategoryId", newExpense.CategoryId);
                command.Parameters.AddWithValue("@Products", (object)newExpense.Products ?? DBNull.Value);
                command.Parameters.AddWithValue("@ExpenseAmount", newExpense.Amount);
                command.Parameters.AddWithValue("@ExpenseDate", newExpense.Date);
                command.Parameters.AddWithValue("@ExpenseTagId", newExpense.ExpenseTagId > 0 ? newExpense.ExpenseTagId : DBNull.Value);

                command.Parameters.AddWithValue("@TransTitle", newTransaction.Title);
                command.Parameters.AddWithValue("@TransDescription", (object)newTransaction.Description ?? DBNull.Value);
                command.Parameters.AddWithValue("@TransType", (int)newTransaction.TransactionType);
                command.Parameters.AddWithValue("@TransAmountInSp", newTransaction.AmountInSp);
                command.Parameters.AddWithValue("@TransTagId", newTransaction.TransactionTagId > 0 ? newTransaction.TransactionTagId : DBNull.Value);
                command.Parameters.AddWithValue("@TransCategoryId", newTransaction.TransactionCategoryId > 0 ? newTransaction.TransactionCategoryId : DBNull.Value);

                // Define the Output parameter to match the SP header
                command.Parameters.Add("@IsOverLimit", SqlDbType.Bit).Direction = ParameterDirection.Output;

                await connection.OpenAsync();

                using var reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    int rowsAffected = reader.GetInt32(0);
                    bool isOverLimit = reader.GetBoolean(1);

                    return (Success: rowsAffected > 0, IsOverLimit: isOverLimit);
                }

                return (false, false);
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

                return result != null && int.TryParse(result.ToString(), out int rowsAffected) && rowsAffected > 0;
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

                command.Parameters.AddWithValue("@ExpenseId", expenseId);
                command.Parameters.AddWithValue("@UserId", userId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    var expense = new Expense
                    (
                        Convert.ToInt32(reader["ExpenseID"]),
                        Convert.ToInt32(reader["UserID"]),
                        reader["Title"] != DBNull.Value ? Convert.ToString(reader["Title"])! : string.Empty,
                        Convert.ToDecimal(reader["Amount"]),
                        reader["Products"] != DBNull.Value ? Convert.ToString(reader["Products"])! : string.Empty,
                        reader["TagID"] != DBNull.Value ? Convert.ToInt32(reader["TagID"]) : -1,
                        Convert.ToInt32(reader["CategoryID"]),
                        Convert.ToInt32(reader["WalletID"]),
                        Convert.ToInt32(reader["LinkedTransactionID"]),
                        Convert.ToDateTime(reader["Date"])
                    );

                    return expense;
                }

                return null!;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<(IEnumerable<Expense> projects, int totalCount)> GetExpensesByUserAsync(int userId, int pageNumber, int pageSize)
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
                        var expense = new Expense
                        (
                            Convert.ToInt32(reader["ExpenseID"]),
                            Convert.ToInt32(reader["UserID"]),
                            reader["Title"] != DBNull.Value ? Convert.ToString(reader["Title"])! : string.Empty,
                            Convert.ToDecimal(reader["Amount"]),
                            reader["Products"] != DBNull.Value ? Convert.ToString(reader["Products"])! : string.Empty,
                            reader["TagID"] != DBNull.Value ? Convert.ToInt32(reader["TagID"]) : -1,
                            Convert.ToInt32(reader["CategoryID"]),
                            Convert.ToInt32(reader["WalletID"]),
                            Convert.ToInt32(reader["LinkedTransactionID"]),
                            Convert.ToDateTime(reader["Date"])
                        );

                        expenses.Add(expense);
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
            string products = string.Empty;

            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_GetProducts]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@ExpenseId", expenseId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    if (reader["Products"] != DBNull.Value)
                        products = reader["Products"].ToString()!;
                }

                return products;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }
    }
}
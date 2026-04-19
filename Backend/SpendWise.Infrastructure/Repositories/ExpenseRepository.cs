using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
<<<<<<< HEAD
=======
using SpendWise.Infrastructure.Global; // Added Global Exception Handler
>>>>>>> origin
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using SpendWise.Application.Interfaces.Expenses;

<<<<<<< HEAD
public class ExpenseRepository : IExpenseRepository
{
    private readonly string _connectionString;

    public ExpenseRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")
                                        ?? throw new ArgumentNullException("Connection string is missing in appsettings.");
    }

    public async Task<int> AddExpenseAsync(Expense newExpense, Transaction newTransaction)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("[Ledger].[sp_AddExpenseWithTransaction]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@ExpenseUserId", newExpense.UserId);
            command.Parameters.AddWithValue("@ExpenseWalletId", newExpense.Wallet.WalletId);
            command.Parameters.AddWithValue("@ExpenseCategoryId", newExpense.Category.CategoryId);
            command.Parameters.AddWithValue("@Products", newExpense.Products);
            command.Parameters.AddWithValue("@ExpenseAmount", newExpense.Amount);
            command.Parameters.AddWithValue("@ExpenseDate", newExpense.Date);
            command.Parameters.AddWithValue("@ExpenseTagId", newExpense.ExpenseTag?.Id > 0 ? newExpense.ExpenseTag.Id : DBNull.Value);

            command.Parameters.AddWithValue("@TransTitle", newTransaction.Title);
            command.Parameters.AddWithValue("@TransDescription", string.IsNullOrEmpty(newTransaction.Description) ? DBNull.Value : newTransaction.Description);
            command.Parameters.AddWithValue("@TransType", (int)newTransaction.TransactionType);
            command.Parameters.AddWithValue("@TransTagId", newTransaction.TransactionTag?.Id > 0 ? newTransaction.TransactionTag.Id : DBNull.Value);
            command.Parameters.AddWithValue("@TransCategoryId", newTransaction.TransactionCategory?.CategoryId > 0 ? newTransaction.TransactionCategory.CategoryId : DBNull.Value);

            await connection.OpenAsync();
            var result = await command.ExecuteScalarAsync();
            return Convert.ToInt32(result);
        }
        catch (SqlException ex)
        {
            HandleSqlException(ex);
            throw;
        }
    }

    public async Task<bool> UpdateExpenseAsync(Expense newExpense, Transaction newTransaction)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("[Ledger].[sp_UpdateExpenseWithTransaction]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@ExpenseId", newExpense.ExpenseId);
            command.Parameters.AddWithValue("@ExpenseUserId", newExpense.UserId);
            command.Parameters.AddWithValue("@ExpenseWalletId", newExpense.Wallet.WalletId);
            command.Parameters.AddWithValue("@ExpenseCategoryId", newExpense.Category.CategoryId);
            command.Parameters.AddWithValue("@Products", newExpense.Products);
            command.Parameters.AddWithValue("@ExpenseAmount", newExpense.Amount);
            command.Parameters.AddWithValue("@ExpenseDate", newExpense.Date);
            command.Parameters.AddWithValue("@ExpenseTagId", newExpense.ExpenseTag?.Id > 0 ? newExpense.ExpenseTag.Id : DBNull.Value);

            command.Parameters.AddWithValue("@TransTitle", newTransaction.Title);
            command.Parameters.AddWithValue("@TransDescription", string.IsNullOrEmpty(newTransaction.Description) ? DBNull.Value : newTransaction.Description);
            command.Parameters.AddWithValue("@TransType", (int)newTransaction.TransactionType);
            command.Parameters.AddWithValue("@TransTagId", newTransaction.TransactionTag?.Id > 0 ? newTransaction.TransactionTag.Id : DBNull.Value);
            command.Parameters.AddWithValue("@TransCategoryId", newTransaction.TransactionCategory?.CategoryId > 0 ? newTransaction.TransactionCategory.CategoryId : DBNull.Value);

            await connection.OpenAsync();
            var rowsAffected = await command.ExecuteNonQueryAsync();
            return rowsAffected > 0;
        }
        catch (SqlException ex)
        {
            HandleSqlException(ex);
            throw;
        }
    }

    public async Task<bool> DeleteExpenseAsync(int expenseId)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("[Ledger].[sp_DeleteExpense]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };
            command.Parameters.AddWithValue("@ExpenseId", expenseId);
            await connection.OpenAsync();
            var result = await command.ExecuteScalarAsync();
            return Convert.ToInt32(result) > 0;
        }
        catch (SqlException ex)
        {
            HandleSqlException(ex);
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
                return MapExpenseFromReader(reader);
            }

            return null!;
        }
        catch (SqlException ex)
        {
            HandleSqlException(ex);
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
                    expenses.Add(MapExpenseFromReader(reader));
                }
            }

            return (expenses, totalCount);
        }
        catch (SqlException ex)
        {
            HandleSqlException(ex);
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
                if (reader["Products"] != null)
                    products = reader["Products"].ToString();
            }

            return products;
        }
        catch (SqlException ex)
        {
            HandleSqlException(ex);
            throw;
        }
    }

    private void HandleSqlException(SqlException ex)
    {
        switch (ex.Number)
        {
            case 50001:
                throw new Exception("Access Denied or Wallet Not Found.");
            case 50002:
                throw new InvalidReferenceException("The income record you are trying to update or delete was not found.");
            case 547:
                throw new InvalidReferenceException("A related record is missing. Please ensure all related categories, tags, and wallets exist.");
            case -2:
                throw new TimeoutException("The database took too long to respond. Please try again.");
            default:
                throw new Exception($"An unexpected database error occurred. Code: {ex.Number}");
        }
    }
    private static Expense MapExpenseFromReader(SqlDataReader reader)
    {
        var wallet = new Wallet(
            walletId: Convert.ToInt32(reader["ExpenseWalletID"]),
            balance: Convert.ToDecimal(reader["ExpenseWalletBalance"]),
            userId: Convert.ToInt32(reader["ExpenseUserID"]),
            isSaved: Convert.ToBoolean(reader["IsSavedWallet"])
            );

        var tag = new Tag(
            id: Convert.ToInt32(reader["ExpenseTagID"]),
            ownerId: Convert.ToInt32(reader["ExpenseUserID"]),
            label: Convert.ToString(reader["ExpenseTagName"])
            );

        var category = new Category
        {
            CategoryId = Convert.ToInt32(reader["CategoryID"]),
            Name = Convert.ToString(reader["CategoryName"]),
            Priority = Convert.ToInt32(reader["CategoryPriority"])
        };

        var transaction = new Transaction(
            transactionId: Convert.ToInt32(reader["TransactionID"]),
            userId: Convert.ToInt32(reader["TransUserID"]),
            title: Convert.ToString(reader["Title"]),
            description: Convert.ToString(reader["Description"]),
            amount: Convert.ToDecimal(reader["TransAmount"]),
            transactionDate: Convert.ToDateTime(reader["TransactionDate"]),
            transactionType: (enTransactionType)Convert.ToInt32(reader["TransactionType"]),
            wallet: wallet,
            transactionTag: tag,
            transactionCategory: category,
            savingGoal: null,
            income: null,
            expense: null
            );
        var expense = new Expense(
            expenseId: Convert.ToInt32(reader["IncomeID"]),
            userId: Convert.ToInt32(reader["IncomeUserID"]),
            amount: Convert.ToDecimal(reader["IncomeAmount"]),
            products: Convert.ToString(reader["Products"]),
            date: Convert.ToDateTime(reader["IncomeDate"]),
            wallet: wallet,
            expenseTag: tag,
            category: category,
            linkedTransaction: transaction
            );
        transaction.Expense = expense;

        return expense;
    }
=======
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

        public async Task<int> AddExpenseAsync(Expense newExpense, Transaction newTransaction)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_AddExpenseWithTransaction]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                // Directly mapping the IDs as defined in your Expense.cs domain entity
                command.Parameters.AddWithValue("@ExpenseUserId", newExpense.UserId);
                command.Parameters.AddWithValue("@ExpenseWalletId", newExpense.WalletId);
                command.Parameters.AddWithValue("@ExpenseCategoryId", newExpense.CategoryId);
                command.Parameters.AddWithValue("@Products", string.IsNullOrEmpty(newExpense.Products) ? DBNull.Value : newExpense.Products);
                command.Parameters.AddWithValue("@ExpenseAmount", newExpense.Amount);
                command.Parameters.AddWithValue("@ExpenseDate", newExpense.Date);
                command.Parameters.AddWithValue("@ExpenseTagId", newExpense.ExpenseTagId > 0 ? newExpense.ExpenseTagId : DBNull.Value);

                command.Parameters.AddWithValue("@TransTitle", newTransaction.Title);
                command.Parameters.AddWithValue("@TransDescription", string.IsNullOrEmpty(newTransaction.Description) ? DBNull.Value : newTransaction.Description);
                command.Parameters.AddWithValue("@TransType", (int)newTransaction.TransactionType);
                command.Parameters.AddWithValue("@TransTagId", newTransaction.TransactionTagId > 0 ? newTransaction.TransactionTagId : DBNull.Value);
                command.Parameters.AddWithValue("@TransCategoryId", newTransaction.TransactionCategoryId > 0 ? newTransaction.TransactionCategoryId : DBNull.Value);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                // Clean, one-line evaluation
                return result != null && int.TryParse(result.ToString(), out int insertedId) ? insertedId : -1;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex); // Centralized Exception Handling
                throw;
            }
        }

        public async Task<bool> UpdateExpenseAsync(Expense newExpense, Transaction newTransaction)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_UpdateExpenseWithTransaction]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@ExpenseId", newExpense.ExpenseId);
                command.Parameters.AddWithValue("@ExpenseUserId", newExpense.UserId);
                command.Parameters.AddWithValue("@ExpenseWalletId", newExpense.WalletId);
                command.Parameters.AddWithValue("@ExpenseCategoryId", newExpense.CategoryId);
                command.Parameters.AddWithValue("@Products", string.IsNullOrEmpty(newExpense.Products) ? DBNull.Value : newExpense.Products);
                command.Parameters.AddWithValue("@ExpenseAmount", newExpense.Amount);
                command.Parameters.AddWithValue("@ExpenseDate", newExpense.Date);
                command.Parameters.AddWithValue("@ExpenseTagId", newExpense.ExpenseTagId > 0 ? newExpense.ExpenseTagId : DBNull.Value);

                command.Parameters.AddWithValue("@TransTitle", newTransaction.Title);
                command.Parameters.AddWithValue("@TransDescription", string.IsNullOrEmpty(newTransaction.Description) ? DBNull.Value : newTransaction.Description);
                command.Parameters.AddWithValue("@TransType", (int)newTransaction.TransactionType);
                command.Parameters.AddWithValue("@TransTagId", newTransaction.TransactionTagId > 0 ? newTransaction.TransactionTagId : DBNull.Value);
                command.Parameters.AddWithValue("@TransCategoryId", newTransaction.TransactionCategoryId > 0 ? newTransaction.TransactionCategoryId : DBNull.Value);

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

        // Added userId parameter for IDOR security!
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
                command.Parameters.AddWithValue("@UserId", userId); // Pass to SQL for ownership check

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                // Clean, one-line evaluation
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
                    // Fixed mapping: creating the object directly using IDs, removing the Income copy-paste bug
                    var expense = new Expense
                    {
                        ExpenseId = Convert.ToInt32(reader["ExpenseID"]),
                        UserId = Convert.ToInt32(reader["UserID"]),
                        Amount = Convert.ToDecimal(reader["Amount"]),
                        Products = reader["Products"] != DBNull.Value ? Convert.ToString(reader["Products"])! : string.Empty,
                        Date = Convert.ToDateTime(reader["Date"]),
                        WalletId = Convert.ToInt32(reader["WalletID"]),
                        CategoryId = Convert.ToInt32(reader["CategoryID"])
                    };

                    if (reader["TagID"] != DBNull.Value)
                    {
                        expense.ExpenseTagId = Convert.ToInt32(reader["TagID"]);
                    }
                    else
                    {
                        expense.ExpenseTagId = -1;
                    }

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
                        {
                            ExpenseId = Convert.ToInt32(reader["ExpenseID"]),
                            UserId = Convert.ToInt32(reader["UserID"]),
                            Amount = Convert.ToDecimal(reader["Amount"]),
                            Products = reader["Products"] != DBNull.Value ? Convert.ToString(reader["Products"])! : string.Empty,
                            Date = Convert.ToDateTime(reader["Date"]),
                            WalletId = Convert.ToInt32(reader["WalletID"]),
                            CategoryId = Convert.ToInt32(reader["CategoryID"])
                        };

                        if (reader["TagID"] != DBNull.Value)
                        {
                            expense.ExpenseTagId = Convert.ToInt32(reader["TagID"]);
                        }
                        else
                        {
                            expense.ExpenseTagId = -1;
                        }

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
>>>>>>> origin
}
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Incomes;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using SpendWise.Infrastructure.Global; 
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Repositories
{
    public class IncomeRepository : IIncomeRepository
    {
        private readonly string _connectionString;

        public IncomeRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                                            ?? throw new ArgumentNullException("Connection string is missing in appsettings.");
        }

        public async Task<int> AddIncomeAsync(Income newIncome, Transaction newTransaction)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_AddIncomeWithTransaction]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@IncomeUserId", newIncome.UserId);
                command.Parameters.AddWithValue("@IncomeWalletId", newIncome.WalletId);
                command.Parameters.AddWithValue("@IncomeAmount", newIncome.Amount);
                command.Parameters.AddWithValue("@IncomeDate", newIncome.Date);
                command.Parameters.AddWithValue("@IncomeTagId", newIncome.IncomeTagId > 0 ? newIncome.IncomeTagId : DBNull.Value);

                command.Parameters.AddWithValue("@TransTitle", newTransaction.Title);
                command.Parameters.AddWithValue("@TransDescription", string.IsNullOrEmpty(newTransaction.Description) ? DBNull.Value : newTransaction.Description);
                command.Parameters.AddWithValue("@TransType", (int)newTransaction.TransactionType);
                command.Parameters.AddWithValue("@TransTagId", newTransaction.TransactionTagId > 0 ? newTransaction.TransactionTagId : DBNull.Value);

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

        public async Task<int> UpdateIncomeAsync(Income newIncome, Transaction newTransaction)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_UpdateIncomeWithTransaction]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@IncomeId", newIncome.Id);
                command.Parameters.AddWithValue("@IncomeUserId", newIncome.UserId);
                command.Parameters.AddWithValue("@IncomeWalletId", newIncome.WalletId);
                command.Parameters.AddWithValue("@IncomeAmount", newIncome.Amount);
                command.Parameters.AddWithValue("@IncomeDate", newIncome.Date);
                command.Parameters.AddWithValue("@IncomeTagId", newIncome.IncomeTagId > 0 ? newIncome.IncomeTagId : DBNull.Value);

                command.Parameters.AddWithValue("@TransTitle", newTransaction.Title);
                command.Parameters.AddWithValue("@TransDescription", string.IsNullOrEmpty(newTransaction.Description) ? DBNull.Value : newTransaction.Description);
                command.Parameters.AddWithValue("@TransType", (int)newTransaction.TransactionType);
                command.Parameters.AddWithValue("@TransTagId", newTransaction.TransactionTagId > 0 ? newTransaction.TransactionTagId : DBNull.Value);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                return result != null && int.TryParse(result.ToString(), out int updatedId) ? updatedId : -1;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex); 
                throw;
            }
        }

        public async Task<bool> DeleteIncomeAsync(int incomeId, int userId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_DeleteIncome]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@IncomeId", incomeId);
                command.Parameters.AddWithValue("@UserId", userId); // Pass to SQL for ownership check

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                return result != null && int.TryParse(result.ToString(), out int rowsAffected) && rowsAffected > 0;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex); // Centralized Exception Handling
                throw;
            }
        }

        public async Task<Income> GetIncomeAsync(int incomeId, int userId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_GetIncome]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@IncomeId", incomeId);
                command.Parameters.AddWithValue("@UserId", userId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    var income = new Income
                    {
                        Id = Convert.ToInt32(reader["IncomeID"]),
                        UserId = Convert.ToInt32(reader["IncomeUserID"]),
                        Amount = Convert.ToDecimal(reader["IncomeAmount"]),
                        Date = Convert.ToDateTime(reader["IncomeDate"]),
                        WalletId = Convert.ToInt32(reader["IncomeWalletID"])
                    };

                    // Map ID directly instead of creating a Tag object
                    if (reader["IncomeTagID"] != DBNull.Value)
                    {
                        income.IncomeTagId = Convert.ToInt32(reader["IncomeTagID"]);
                    }

                    if (reader["TransactionID"] != DBNull.Value)
                    {
                        income.LinkedTransaction = new Transaction
                        {
                            TransactionId = Convert.ToInt32(reader["TransactionID"]),
                            UserId = Convert.ToInt32(reader["TransUserID"]),
                            Title = reader["Title"].ToString()!,
                            Description = reader["Description"] != DBNull.Value ? reader["Description"].ToString()! : string.Empty,
                            Amount = Convert.ToDecimal(reader["TransAmount"]),
                            TransactionDate = Convert.ToDateTime(reader["TransactionDate"]),
                            TransactionType = (enTransactionType)Convert.ToInt32(reader["TransactionType"]),
                            WalletId = Convert.ToInt32(reader["TransWalletID"]) // Map ID directly instead of Wallet object
                        };

                        if (reader["TransTagID"] != DBNull.Value)
                        {
                            income.LinkedTransaction.TransactionTagId = Convert.ToInt32(reader["TransTagID"]);
                        }
                    }
                    return income;
                }

                return null!;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<(IEnumerable<Income> projects, int totalCount)> GetIncomeByUserAsync(int userId, int pageNumber, int pageSize)
        {
            var incomes = new List<Income>();
            int totalCount = 0;

            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_GetIncomesByUserPaged]", connection)
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
                        var income = new Income
                        {
                            Id = Convert.ToInt32(reader["IncomeID"]),
                            UserId = Convert.ToInt32(reader["UserID"]),
                            Amount = Convert.ToDecimal(reader["Amount"]),
                            Date = Convert.ToDateTime(reader["Date"]),
                            WalletId = Convert.ToInt32(reader["WalletID"]) 
                        };

                        if (reader["TagID"] != DBNull.Value)
                        {
                            income.IncomeTagId = Convert.ToInt32(reader["TagID"]);
                        }
                        else
                        {
                            income.IncomeTagId = -1;
                        }

                        incomes.Add(income);
                    }
                }

                return (incomes, totalCount);
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }
    }
}
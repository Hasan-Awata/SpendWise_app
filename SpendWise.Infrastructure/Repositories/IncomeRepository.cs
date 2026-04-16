using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Incomes;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
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
                command.Parameters.AddWithValue("@IncomeWalletId", newIncome.Wallet.WalletId);
                command.Parameters.AddWithValue("@IncomeAmount", newIncome.Amount);
                command.Parameters.AddWithValue("@IncomeDate", newIncome.Date);
                command.Parameters.AddWithValue("@IncomeTagId", newIncome.IncomeTag?.Id > 0 ? newIncome.IncomeTag.Id : DBNull.Value);

                command.Parameters.AddWithValue("@TransTitle", newTransaction.Title);
                command.Parameters.AddWithValue("@TransDescription", string.IsNullOrEmpty(newTransaction.Description) ? DBNull.Value : newTransaction.Description);
                command.Parameters.AddWithValue("@TransType", (int)newTransaction.TransactionType);
                command.Parameters.AddWithValue("@TransTagId", newTransaction.TransactionTag?.Id > 0 ? newTransaction.TransactionTag.Id : DBNull.Value);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                if (result != null && int.TryParse(result.ToString(), out int insertedId))
                {
                    return insertedId;
                }

                return -1;
            }
            catch (SqlException ex)
            {
                HandleSqlException(ex);
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
                command.Parameters.AddWithValue("@IncomeWalletId", newIncome.Wallet.WalletId);
                command.Parameters.AddWithValue("@IncomeAmount", newIncome.Amount);
                command.Parameters.AddWithValue("@IncomeDate", newIncome.Date);
                command.Parameters.AddWithValue("@IncomeTagId", newIncome.IncomeTag?.Id > 0 ? newIncome.IncomeTag.Id : DBNull.Value);

                command.Parameters.AddWithValue("@TransTitle", newTransaction.Title);
                command.Parameters.AddWithValue("@TransDescription", string.IsNullOrEmpty(newTransaction.Description) ? DBNull.Value : newTransaction.Description);
                command.Parameters.AddWithValue("@TransType", (int)newTransaction.TransactionType);
                command.Parameters.AddWithValue("@TransTagId", newTransaction.TransactionTag?.Id > 0 ? newTransaction.TransactionTag.Id : DBNull.Value);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                if (result != null && int.TryParse(result.ToString(), out int updatedId))
                {
                    return updatedId;
                }

                return -1;
            }
            catch (SqlException ex)
            {
                HandleSqlException(ex);
                throw;
            }
        }

        public async Task<bool> DeleteIncomeAsync(int incomeId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_DeleteIncome]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };
                command.Parameters.AddWithValue("@IncomeId", incomeId);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                if (result != null && int.TryParse(result.ToString(), out int rowsAffected))
                {
                    return rowsAffected > 0;
                }

                return false;
            }
            catch (SqlException ex)
            {
                HandleSqlException(ex);
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
                        Wallet = new Wallet { WalletId = Convert.ToInt32(reader["IncomeWalletID"]), Balance = Convert.ToDecimal(reader["IncomeWalletBalance"]) }
                    };

                    if (reader["IncomeTagID"] != DBNull.Value)
                    {
                        income.IncomeTag = new Tag { Id = Convert.ToInt32(reader["IncomeTagID"]), Label = reader["IncomeTagName"].ToString()! };
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
                            Wallet = new Wallet { WalletId = Convert.ToInt32(reader["TransWalletID"]), Balance = Convert.ToDecimal(reader["TransWalletBalance"]) }
                        };

                        if (reader["TransTagID"] != DBNull.Value)
                        {
                            income.LinkedTransaction.TransactionTag = new Tag
                            {
                                Id = Convert.ToInt32(reader["TransTagID"]),
                                Label = reader["TransTagName"].ToString()!
                            };
                        }
                    }
                    return income;
                }

                return null!;
            }
            catch (SqlException ex)
            {
                HandleSqlException(ex);
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
                            Wallet = new Wallet { WalletId = Convert.ToInt32(reader["WalletID"]), Balance = Convert.ToDecimal(reader["Balance"]) }
                        };

                        if (reader["TagID"] != DBNull.Value)
                        {
                            income.IncomeTag = new Tag { Id = Convert.ToInt32(reader["TagID"]), Label = reader["TagName"].ToString()! };
                        }
                        incomes.Add(income);
                    }
                }

                return (incomes, totalCount);
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
                    throw new InvalidReferenceException("The specified wallet does not exist.");

                case 50002:
                    throw new InvalidReferenceException("The income record you are trying to update or delete was not found.");

                case 50003:
                    throw new UnauthorizedAccessException("Access Denied: You do not own this wallet.");

                case 547:
                    throw new InvalidReferenceException("A related record is missing. Please ensure all related categories, tags, and wallets exist.");

                case -2:
                    throw new TimeoutException("The database took too long to respond. Please try again.");

                default:
                    throw new Exception($"An unexpected database error occurred. Code: {ex.Number}");
            }
        }
    }
}
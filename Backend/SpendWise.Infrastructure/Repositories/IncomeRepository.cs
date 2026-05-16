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

        private static Income MapToIncome(SqlDataReader reader)
        {
            var income = new Income
            {
                Id = Convert.ToInt32(reader["IncomeID"]),
                UserId = Convert.ToInt32(reader["UserID"]),
                Title = reader["Title"].ToString()!,
                Amount = Convert.ToDecimal(reader["Amount"]),
                Date = Convert.ToDateTime(reader["Date"]),
                WalletId = Convert.ToInt32(reader["WalletID"]),
                IncomeTagId = reader["TagID"] != DBNull.Value ? Convert.ToInt32(reader["TagID"]) : -1,
            };

            income.LinkedTransaction = new Transaction(
                income.Id,
                income.UserId,
                income.Title,
                reader["Description"] != DBNull.Value ? reader["Description"].ToString()! : string.Empty,
                income.WalletId,
                income.Amount,
                Convert.ToDecimal(reader["AmountInSp"]),
                income.Date,
                enTransactionType.Addition
            );

            return income;
        }

        public async Task<int> AddIncomeAsync(Income newIncome)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_AddIncomeWithTransaction]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                // shared parameters
                command.Parameters.AddWithValue("@UserId", newIncome.UserId);
                command.Parameters.AddWithValue("@WalletId", newIncome.WalletId);
                command.Parameters.AddWithValue("@Amount", newIncome.Amount);
                command.Parameters.AddWithValue("@IncomeDate", newIncome.Date);
                command.Parameters.AddWithValue("@Title", newIncome.Title);

                // optional parameters
                command.Parameters.AddWithValue("@Description", (object)newIncome.LinkedTransaction.Description ?? DBNull.Value);
                command.Parameters.AddWithValue("@TagId", newIncome.IncomeTagId > 0 ? (object)newIncome.IncomeTagId : DBNull.Value);

                // Transaction Details
                command.Parameters.AddWithValue("@AmountInSp", newIncome.LinkedTransaction.AmountInSp);
                command.Parameters.AddWithValue("@TransactionType", (int)newIncome.LinkedTransaction.TransactionType);

                // Output parameter setup
                var outputId = new SqlParameter("@NewIncomeID", SqlDbType.Int) { Direction = ParameterDirection.Output };
                command.Parameters.Add(outputId);

                await connection.OpenAsync();

                // Execute the procedure
                await command.ExecuteNonQueryAsync();

                // Retrieve the ID from the Output parameter
                return (int)outputId.Value;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<bool> UpdateIncomeAsync(Income newIncome)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_UpdateIncomeWithTransaction]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                // 1. Core ID and Identity
                command.Parameters.AddWithValue("@IncomeId", newIncome.Id);
                command.Parameters.AddWithValue("@UserId", newIncome.UserId);

                // 2. Income Table Data
                command.Parameters.AddWithValue("@WalletId", newIncome.WalletId);
                command.Parameters.AddWithValue("@TagId", newIncome.IncomeTagId > 0 ? (object)newIncome.IncomeTagId : DBNull.Value);
                command.Parameters.AddWithValue("@Amount", newIncome.Amount);
                command.Parameters.AddWithValue("@IncomeDate", newIncome.Date);

                // 3. Transaction/Shared Data
                command.Parameters.AddWithValue("@Title", newIncome.LinkedTransaction.Title);
                command.Parameters.AddWithValue("@Description", (object)newIncome.LinkedTransaction.Description ?? DBNull.Value);
                command.Parameters.AddWithValue("@TransactionType", (int)newIncome.LinkedTransaction.TransactionType);
                command.Parameters.AddWithValue("@AmountInSp", newIncome.LinkedTransaction.AmountInSp);

                await connection.OpenAsync();

                // Using ExecuteScalar because the procedure ends with 'SELECT 1 AS RowsAffected'
                var result = await command.ExecuteScalarAsync();

                return result != null && int.TryParse(result.ToString(), out int rowsAffected) && rowsAffected > 0;
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

        public async Task<Income> GetIncomeAsync(int incomeId, int userId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_GetIncome]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@IncomeID", incomeId);
                command.Parameters.AddWithValue("@UserID", userId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    var income = MapToIncome(reader);

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

        public async Task<(IEnumerable<Income> incomes, int totalCount)> GetIncomeByUserAsync(int userId, int pageNumber, int pageSize)
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

                // Result Set 1: Total Count
                if (await reader.ReadAsync())
                {
                    totalCount = Convert.ToInt32(reader["TotalCount"]);
                }

                // Result Set 2: Paged Incomes
                if (await reader.NextResultAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        incomes.Add(MapToIncome(reader));
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
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces;
using SpendWise.Domain.Entities;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Repositories
{
    public class FixedIncomeRepository : IFixedIncomeRepository
    {
        private readonly string _connectionString;

        public FixedIncomeRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                                ?? throw new ArgumentNullException("Connection string is missing in appsettings.");
        }

        public async Task<FixedIncome> GetFixedIncomeAsync(int fixedIncomeId, int userId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_GetFixedIncome]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@FixedIncomeId", fixedIncomeId);
                command.Parameters.AddWithValue("@UserId", userId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    return new FixedIncome

                        (Convert.ToInt32(reader["FixedIncomeId"]),
                         Convert.ToInt32(reader["UserId"]),
                          Convert.ToInt32(reader["TagId"]),
                          reader["Title"].ToString()!,
                         Convert.ToDecimal(reader["Amount"]),
                        Convert.ToBoolean(reader["IsMonthly"]),
                        Convert.ToBoolean(reader["IsActive"]),
                        Convert.ToInt32(reader["Days"]),
                         Convert.ToDateTime(reader["LastTime"]));
                   
                }
                return null!;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<IEnumerable<FixedIncome?>> GetFixedIncomesByUserIdAsync(int userId)
        {
            var incomes = new List<FixedIncome>();
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_GetFixedIncomesByUser]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@UserId", userId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                while (await reader.ReadAsync())
                {
                    incomes.Add(new FixedIncome(
                         Convert.ToInt32(reader["FixedIncomeId"]),
                         Convert.ToInt32(reader["UserId"]),
                         Convert.ToInt32(reader["TagId"]),
                         reader["Title"].ToString(),
                         Convert.ToDecimal(reader["Amount"]),
                         Convert.ToBoolean(reader["IsMonthly"]),
                         Convert.ToBoolean(reader["IsActive"]),
                         Convert.ToInt32(reader["Days"]),
                         Convert.ToDateTime(reader["LastTime"])
                    ));
                }
                return incomes;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<int> CreateFixedIncomeAsync(FixedIncome fixedIncome)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_CreateFixedIncome]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                // Parameters from the FixedIncome entity
                command.Parameters.AddWithValue("@UserId", fixedIncome.UserId);
                command.Parameters.AddWithValue("@TagId", fixedIncome.TagId);
                command.Parameters.AddWithValue("@Title", fixedIncome.Title);
                command.Parameters.AddWithValue("@Amount", fixedIncome.Amount);
                command.Parameters.AddWithValue("@IsMonthly", fixedIncome.IsMonthly);
                command.Parameters.AddWithValue("@IsActive", fixedIncome.IsActive);
                command.Parameters.AddWithValue("@Days", fixedIncome.Days);
                command.Parameters.AddWithValue("@LastTime", fixedIncome.LastTime);

                await connection.OpenAsync();

                // Using ExecuteScalar to get the new ID (SCOPE_IDENTITY) from the stored procedure
                var result = await command.ExecuteScalarAsync();

                // If the result is valid, return the ID; otherwise return -1
                return result != null && int.TryParse(result.ToString(), out int insertedId) ? insertedId : -1;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<bool> UpdateFixedIncomeAsync(FixedIncome fixedIncome)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_UpdateFixedIncome]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@FixedIncomeId", fixedIncome.FixedIncomeId);
                command.Parameters.AddWithValue("@UserId", fixedIncome.UserId);
                command.Parameters.AddWithValue("@TagId", fixedIncome.TagId);
                command.Parameters.AddWithValue("@Title", fixedIncome.Title);
                command.Parameters.AddWithValue("@Amount", fixedIncome.Amount);
                command.Parameters.AddWithValue("@IsMonthly", fixedIncome.IsMonthly);
                command.Parameters.AddWithValue("@IsActive", fixedIncome.IsActive);
                command.Parameters.AddWithValue("@Days", fixedIncome.Days);
                command.Parameters.AddWithValue("@LastTime", fixedIncome.LastTime);

                await connection.OpenAsync();
                int rowsAffected = await command.ExecuteNonQueryAsync();
                return rowsAffected > 0;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<bool> DeleteFixedIncomeAsync(int fixedIncomeId, int userId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_DeleteFixedIncome]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@FixedIncomeId", fixedIncomeId);
                command.Parameters.AddWithValue("@UserId", userId);

                await connection.OpenAsync();
                int rowsAffected = await command.ExecuteNonQueryAsync();
                return rowsAffected > 0;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<bool> IsIncomeActive(int fixedIncomeId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("SELECT IsActive FROM [Ledger].[FixedIncomes] WHERE FixedIncomeId = @Id", connection);
                command.Parameters.AddWithValue("@Id", fixedIncomeId);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();
                return result != null && Convert.ToBoolean(result);
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }
    }
}
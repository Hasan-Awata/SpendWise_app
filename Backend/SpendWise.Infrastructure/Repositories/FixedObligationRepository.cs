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
    public class FixedObligationRepository : IFixedObligationRepository
    {
        private readonly string _connectionString;

        public FixedObligationRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                                ?? throw new ArgumentNullException("Connection string is missing in appsettings.");
        }

        public async Task<FixedObligation> GetFixedObligationAsync(int obligationId, int userId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_GetFixedObligation]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@ObligationId", obligationId);
                command.Parameters.AddWithValue("@UserId", userId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    return new FixedObligation(
                        id: Convert.ToInt32(reader["Id"]),
                        ownerId: Convert.ToInt32(reader["OwnerId"]),
                        title: reader["Title"].ToString()!,
                        amount: Convert.ToDecimal(reader["Amount"]),
                        dueDate: Convert.ToDateTime(reader["DueDate"]),
                        isActive: Convert.ToBoolean(reader["IsActive"])
                    );
                }

                return null!;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<IEnumerable<FixedObligation?>> GetFixedObligationsByUserIdAsync(int userId)
        {
            var obligations = new List<FixedObligation>();

            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_GetFixedObligationsByUserId]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@UserId", userId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                while (await reader.ReadAsync())
                {
                    obligations.Add(new FixedObligation(
                        id: Convert.ToInt32(reader["Id"]),
                        ownerId: Convert.ToInt32(reader["OwnerId"]),
                        title: reader["Title"].ToString()!,
                        amount: Convert.ToDecimal(reader["Amount"]),
                        dueDate: Convert.ToDateTime(reader["DueDate"]),
                        isActive: Convert.ToBoolean(reader["IsActive"])
                    ));
                }

                return obligations;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<bool> CreateFixedObligationAsync(FixedObligation fixedObligation)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_CreateFixedObligation]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@OwnerId", fixedObligation.OwnerId);
                command.Parameters.AddWithValue("@Title", fixedObligation.Title);
                command.Parameters.AddWithValue("@Amount", fixedObligation.Amount);
                command.Parameters.AddWithValue("@DueDate", fixedObligation.DueDate);
                command.Parameters.AddWithValue("@IsActive", fixedObligation.IsActive);

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

        public async Task<bool> UpdateFixedObligationAsync(FixedObligation fixedObligation)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_UpdateFixedObligation]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@Id", fixedObligation.Id);
                command.Parameters.AddWithValue("@OwnerId", fixedObligation.OwnerId);
                command.Parameters.AddWithValue("@Title", fixedObligation.Title);
                command.Parameters.AddWithValue("@Amount", fixedObligation.Amount);
                command.Parameters.AddWithValue("@DueDate", fixedObligation.DueDate);
                command.Parameters.AddWithValue("@IsActive", fixedObligation.IsActive);

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

        public async Task<bool> DeleteFixedObligationAsync(int obligationId, int UserID)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Ledger].[sp_DeleteFixedObligation]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@Id", obligationId);
                command.Parameters.AddWithValue("@OwnerId", UserID);

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
    }
}
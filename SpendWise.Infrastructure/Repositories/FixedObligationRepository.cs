using Microsoft.Data.SqlClient;
using SpendWise.Application.Interfaces;
using SpendWise.Domain.Entities;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace SpendWise.Infrastructure.Repositories
{
    public class FixedObligationRepository : IFixedObligationRepository
    {
        public async Task<FixedObligation?> GetFixedObligationAsync(int ObligationId, int UserID)
        {
            FixedObligation? fixedObligation = null;

            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_GetObligation]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserID", UserID);
                    command.Parameters.AddWithValue("@ObligationID", ObligationId);

                    try
                    {
                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                fixedObligation = new FixedObligation((int)reader["ObligationID"], (int)reader["UserID"],
                                                                    (string)reader["Title"], (decimal)reader["Amount"],
                                                                    (DateTime)reader["DueDate"], (bool)reader["IsActive"]
                                );
                            }
                        }
                    }
                    catch (Exception) { }
                }
            }
            return fixedObligation;
        }
        public async Task<IEnumerable<FixedObligation?>> GetFixedObligationsByUserIdAsync(int UserID)
        {
            List<FixedObligation?> Obligations = new List<FixedObligation?>(); // Fixed initialization

            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_GetObligationByUserID]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserID", UserID);

                    try
                    {
                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                FixedObligation fixedObligation = new FixedObligation((int)reader["ObligationID"], (int)reader["UserID"],
                                                                    (string)reader["Title"], (decimal)reader["Amount"],
                                                                    (DateTime)reader["DueDate"], (bool)reader["IsActive"]);
                                Obligations.Add(fixedObligation);
                            }
                        }
                    }
                    catch (Exception)
                    {
                        // Handle exception appropriately based on your needs
                    }
                }
            }

            return Obligations;
        }
        public async Task<bool> CreateFixedObligationAsync(FixedObligation fixedObligation)
        {
            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_CreateObligation]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@UserID", fixedObligation.OwnerId);
                    command.Parameters.AddWithValue("@Title", fixedObligation.Title);
                    command.Parameters.AddWithValue("@Amount", fixedObligation.Amount);
                    command.Parameters.AddWithValue("@DueDate", fixedObligation.DueDate);
                    command.Parameters.AddWithValue("@IsActive", fixedObligation.IsActive);
                    command.Parameters.AddWithValue("@NewID", fixedObligation.Id);

                    try
                    {
                        await connection.OpenAsync();
                        object result = await command.ExecuteScalarAsync();
                        if (result != null && int.TryParse(result.ToString(), out int insertedID))
                            fixedObligation.Id = insertedID;
                    }
                    catch (Exception ex) { return false; }
                }
            }
            return true;
        }
        public async Task<bool> UpdateFixedObligationAsync(FixedObligation fixedObligation)
        {
            int rowsAffected = 0;
            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_UpdateObligation]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@Title", fixedObligation.Title);
                    command.Parameters.AddWithValue("@Amount", fixedObligation.Amount);
                    command.Parameters.AddWithValue("@DueDate", fixedObligation.DueDate);
                    command.Parameters.AddWithValue("@IsActive", fixedObligation.IsActive);
                    command.Parameters.AddWithValue("@ObligationID", fixedObligation.Id);

                    try
                    {
                        await connection.OpenAsync();
                        rowsAffected = await command.ExecuteNonQueryAsync();
                    }
                    catch (Exception)
                    {
                        return false;
                    }
                }
            }
            return (rowsAffected > 0);
        }
        public async Task<bool> DeleteFixedObligationAsync(int obligationId, int UserID)
        {
            int rowsAffected = 0;
            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[pln].[sp_DeleteObligation]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@ObligationID", obligationId);
                    command.Parameters.AddWithValue("@UserID", UserID);

                    try
                    {
                        await connection.OpenAsync();
                        rowsAffected = await command.ExecuteNonQueryAsync();
                    }
                    catch (Exception)
                    {
                        return false;
                    }
                }
            }
            return (rowsAffected > 0);
        }
    }
}

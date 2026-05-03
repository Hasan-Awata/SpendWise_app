using Microsoft.Data.SqlClient;
using SpendWise.Application.Interfaces.SharedDebts;
using SpendWise.Domain.Entities;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Data;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Repositories
{
    public class SharedDebtRepository : ISharedDebtRepository
    {
        public async Task<int> AddDebtAsync(SharedDebt debt)
        {
            int debtId = -1;
            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[debt].[sp_CreateSharedDebt]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    // Matching your class properties exactly
                    command.Parameters.AddWithValue("@CreditorID", debt.CreditorID);
                    command.Parameters.AddWithValue("@DebtorID", debt.DebtorID);
                    command.Parameters.AddWithValue("@Amount", debt.Amount);
                    command.Parameters.AddWithValue("@Title", debt.Title);
                    command.Parameters.AddWithValue("@Status", debt.Status);
                    command.Parameters.AddWithValue("@DueDate", debt.DueDate);

                    try
                    {
                        await connection.OpenAsync();
                        object result = await command.ExecuteScalarAsync();
                        if (result != null && int.TryParse(result.ToString(), out int insertedID))
                        {
                            debtId = insertedID;
                            debt.DebtID = debtId;
                        }
                    }
                    catch (Exception) { return -1; }
                }
            }
            return debtId;
        }

        public async Task<bool> UpdateDebtAsync(SharedDebt debt)
        {
            int rowsAffected = 0;
            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[debt].[sp_UpdateSharedDebt]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@DebtID", debt.DebtID);
                    command.Parameters.AddWithValue("@CreditorID", debt.CreditorID);
                    command.Parameters.AddWithValue("@DebtorID", debt.DebtorID);
                    command.Parameters.AddWithValue("@Amount", debt.Amount);
                    command.Parameters.AddWithValue("@Title", debt.Title);
                    command.Parameters.AddWithValue("@Status", debt.Status);/*CollectionsUtil.CreateCaseInsensitiveHashtable(rowsAffected);*/
                    command.Parameters.AddWithValue("@DueDate", debt.DueDate);

                    try
                    {
                        await connection.OpenAsync();
                        rowsAffected = await command.ExecuteNonQueryAsync();
                    }
                    catch (Exception) { return false; }
                }
            }
            return rowsAffected > 0;
        }

        public async Task<SharedDebt?> GetDebtByIdAsync(int debtId)
        {
            SharedDebt? debt = null;
            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[debt].[sp_GetSharedDebtByID]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@DebtID", debtId);

                    try
                    {
                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                debt = MapToSharedDebt(reader);
                            }
                        }
                    }
                    catch (Exception) { }
                }
            }
            return debt;
        }

        public async Task<IEnumerable<SharedDebt>> GetDebtsOwedToUserAsync(int userId)
        {
            // Where user is the Creditor
            return await GetDebtListAsync("[debt].[sp_GetDebtsOwedToUser]", userId);
        }

        public async Task<IEnumerable<SharedDebt>> GetTheDebtsIHaveToPayAsync(int userId)
        {
            // Where user is the Debtor
            return await GetDebtListAsync("[debt].[sp_GetDebtsIHaveToPay]", userId);
        }

        public async Task<bool> DeleteDebtByIdAsync(int debtId)
        {
            int rowsAffected = 0;
            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[debt].[sp_DeleteSharedDebt]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@DebtID", debtId);

                    try
                    {
                        await connection.OpenAsync();
                        rowsAffected = await command.ExecuteNonQueryAsync();
                    }
                    catch (Exception) { return false; }
                }
            }
            return rowsAffected > 0;
        }

        private async Task<IEnumerable<SharedDebt>> GetDebtListAsync(string procedureName, int userId)
        {
            List<SharedDebt> debts = new List<SharedDebt>();
            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand(procedureName, connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserID", userId);

                    try
                    {
                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                debts.Add(MapToSharedDebt(reader));
                            }
                        }
                    }
                    catch (Exception) { }
                }
            }
            return debts;
        }

        // Using your constructor to map the data
        private SharedDebt MapToSharedDebt(SqlDataReader reader)
        {
            return new SharedDebt(
                (int)reader["DebtID"],
                (int)reader["CreditorID"],
                (int)reader["DebtorID"],
                (decimal)reader["Amount"],
                (string)reader["Title"],
                (string)reader["Status"],
                (DateTime)reader["CreatedAt"],
                (DateTime)reader["DueDate"]
            );
        }

        public async Task<SharedDebt?> GetDebtByTitleAsync(string title)
        {
            SharedDebt? debt = null;

            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[debt].[sp_GetSharedDebtByTitle]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Title", title);

                    try
                    {
                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                debt = MapToSharedDebt(reader);
                            }
                        }
                    }
                    catch (Exception) { }
                }
            }
            return debt;
        }

        public async Task<bool> DeleteDebtByTitleAsync(string title)
        {
            int rowsAffected = 0;
            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[debt].[sp_DeleteSharedDebtByTitle]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Title", title);

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

        public async Task<bool> DebtExistsAsync(int debtId)
        {
            bool exists = false;

            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[debt].[sp_IsSharedDebtExist]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@DebtID", debtId);

                    try
                    {
                        await connection.OpenAsync();
                        object result = await command.ExecuteScalarAsync();
                        if (result != null && int.TryParse(result.ToString(), out int count))
                        {
                            exists = (count > 0);
                        }
                    }
                    catch (Exception)
                    {
                        return false;
                    }
                }
            }
            return exists;
        }
    }
}
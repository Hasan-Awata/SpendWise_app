using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.SharedDebts;
using SpendWise.Domain.Entities;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Repositories
{
    public class SharedDebtRepository : ISharedDebtRepository
    {
        private readonly string _connectionString;

        public SharedDebtRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                                ?? throw new ArgumentNullException("Connection string is missing in appsettings.");
        }

        public async Task<int> AddDebtAsync(SharedDebt debt)
        {
            var result = await ExecuteScalarAsync<int>("[Planning].[sp_AddSharedDebt]", cmd =>
            {
                cmd.Parameters.AddWithValue("@CreditorID", debt.CreditorID);
                cmd.Parameters.AddWithValue("@DebtorID", debt.DebtorID);
                cmd.Parameters.AddWithValue("@Amount", debt.Amount);
                cmd.Parameters.AddWithValue("@Title", debt.Title);
                cmd.Parameters.AddWithValue("@CreatedAt", debt.CreatedAt);
                cmd.Parameters.AddWithValue("@DueDate", debt.DueDate);
                cmd.Parameters.AddWithValue("@CreditorWalletID", debt.CreditorWalletID > 0 ? debt.CreditorWalletID : DBNull.Value);
                cmd.Parameters.AddWithValue("@DebtorWalletID", debt.DebtorWalletID > 0 ? debt.DebtorWalletID : DBNull.Value);
            });

            return result > 0 ? result : -1;
        }

        public async Task<bool> UpdateDebtAsync(SharedDebt debt)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Planning].[sp_UpdateSharedDebt]", cmd =>
            {
                cmd.Parameters.AddWithValue("@DebtID", debt.DebtID);
                cmd.Parameters.AddWithValue("@CreditorID", debt.CreditorID);
                cmd.Parameters.AddWithValue("@DebtorID", debt.DebtorID);
                cmd.Parameters.AddWithValue("@Amount", debt.Amount);
                cmd.Parameters.AddWithValue("@Title", debt.Title);
                cmd.Parameters.AddWithValue("@DueDate", debt.DueDate);
                cmd.Parameters.AddWithValue("@CreditorWalletID", debt.CreditorWalletID > 0 ? debt.CreditorWalletID : DBNull.Value);
                cmd.Parameters.AddWithValue("@DebtorWalletID", debt.DebtorWalletID > 0 ? debt.DebtorWalletID : DBNull.Value);
            });

            return rowsAffected > 0;
        }

        public async Task<bool> DeleteDebtByIdAsync(int debtId)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Planning].[sp_DeleteSharedDebtById]",
                cmd => cmd.Parameters.AddWithValue("@DebtID", debtId));
            return rowsAffected > 0;
        }

        public async Task<bool> DeleteDebtByTitleAsync(string title)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Planning].[sp_DeleteSharedDebtByTitle]",
                cmd => cmd.Parameters.AddWithValue("@Title", title));
            return rowsAffected > 0;
        }

        public async Task<SharedDebt?> GetDebtByIdAsync(int debtId)
        {
            return await ExecuteReaderSingleAsync("[Planning].[sp_GetSharedDebtById]",
                cmd => cmd.Parameters.AddWithValue("@DebtID", debtId), MapToSharedDebt);
        }

        public async Task<SharedDebt?> GetDebtByTitleAsync(string title)
        {
            return await ExecuteReaderSingleAsync("[Planning].[sp_GetSharedDebtByTitle]",
                cmd => cmd.Parameters.AddWithValue("@Title", title), MapToSharedDebt);
        }

        public async Task<IEnumerable<SharedDebt>> GetDebtsOwedToUserAsync(int userId)
        {
            return await ExecuteReaderListAsync("[Planning].[sp_GetSharedDebtsOwedToUser]",
                cmd => cmd.Parameters.AddWithValue("@UserId", userId), MapToSharedDebt);
        }

        public async Task<IEnumerable<SharedDebt>> GetTheDebtsIHaveToPayAsync(int userId)
        {
            return await ExecuteReaderListAsync("[Planning].[sp_GetSharedDebtsIHaveToPay]",
                cmd => cmd.Parameters.AddWithValue("@UserId", userId), MapToSharedDebt);
        }

        public async Task<bool> DebtExistsAsync(int debtId)
        {
            var result = await ExecuteScalarAsync<int>("[Planning].[sp_CheckSharedDebtExists]",
                cmd => cmd.Parameters.AddWithValue("@DebtID", debtId));
            return result > 0;
        }

        public async Task<IEnumerable<SharedDebt>> GetSharedDebtsForUserAsync(int userId)
        {
            return await ExecuteReaderListAsync("[Planning].[sp_GetSharedDebtsForUser]",
                cmd => cmd.Parameters.AddWithValue("@UserID", userId), MapToSharedDebt);
        }

        public async Task<bool> ReturnDebtAmountAsync(SharedDebt debt, decimal amount, string title, string description, decimal amountInSp)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Planning].[sp_ReturnDebtAmount]", cmd =>
            {
                cmd.Parameters.AddWithValue("@DebtID", debt.DebtID);
                cmd.Parameters.AddWithValue("@CreditorID", debt.CreditorID);
                cmd.Parameters.AddWithValue("@DebtorID", debt.DebtorID);
                cmd.Parameters.AddWithValue("@CreditorWalletID", debt.CreditorWalletID);
                cmd.Parameters.AddWithValue("@DebtorWalletID", debt.DebtorWalletID);
                cmd.Parameters.AddWithValue("@Amount", amount);
                cmd.Parameters.AddWithValue("@Title", title);
                cmd.Parameters.AddWithValue("@Description", description);
                cmd.Parameters.AddWithValue("@AmountInSp", amountInSp);
            });

            return rowsAffected > 0;
        }

        public async Task<bool> AcceptDebtAsync(SharedDebt debt, decimal amount, string title, string description, decimal amountInSp)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Planning].[sp_AcceptSharedDebt]", cmd =>
            {
                cmd.Parameters.AddWithValue("@DebtID", debt.DebtID);
                cmd.Parameters.AddWithValue("@CreditorID", debt.CreditorID);
                cmd.Parameters.AddWithValue("@DebtorID", debt.DebtorID);
                cmd.Parameters.AddWithValue("@DueDate", debt.DueDate);
                cmd.Parameters.AddWithValue("@CreditorWalletID", debt.CreditorWalletID);
                cmd.Parameters.AddWithValue("@DebtorWalletID", debt.DebtorWalletID);
                cmd.Parameters.AddWithValue("@Title", title);
                cmd.Parameters.AddWithValue("@Description", description);
                cmd.Parameters.AddWithValue("@AmountInSp", amountInSp);
            });

            return rowsAffected > 0;
        }

        public async Task<bool> RefuseDebtAsync(int debtId)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Planning].[sp_RefuseSharedDebt]",
                cmd => cmd.Parameters.AddWithValue("@DebtID", debtId));
            return rowsAffected > 0;
        }

        // =========================================================================
        // REUSABLE HELPER METHODS & MAPPERS
        // =========================================================================
        private SharedDebt MapToSharedDebt(SqlDataReader reader)
        {
            // Extracted the object mapping to prevent repeating it across 5 different methods
            return new SharedDebt(
                EmptyValuesHandler.GetInt32OrDefault(reader, "DebtID"),
                EmptyValuesHandler.GetInt32OrDefault(reader, "CreditorID"),
                EmptyValuesHandler.GetInt32OrDefault(reader,"DebtorID"),
                EmptyValuesHandler.GetDecimalOrDefault(reader,"Amount"),
                reader["Title"].ToString()!,
                reader["Status"].ToString()!,
                EmptyValuesHandler.GetDateTimeOrDefault(reader,"CreatedAt"),
                EmptyValuesHandler.GetDateTimeOrDefault(reader, "DueDate"),
                EmptyValuesHandler.GetInt32OrDefault(reader, "CreditorWalletID"),
                EmptyValuesHandler.GetInt32OrDefault(reader, "DebtorWalletID"),
                EmptyValuesHandler.GetDecimalOrDefault(reader, "PaidAmount")
            );
        }

        private async Task<T?> ExecuteScalarAsync<T>(string storedProcedure, Action<SqlCommand> addParameters)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand(storedProcedure, connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                addParameters?.Invoke(command);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                if (result != null && result != DBNull.Value)
                {
                    return (T)Convert.ChangeType(result, typeof(T));
                }
                return default;
            }
            catch (SqlException ex)
            {
                HandleCustomSqlException(ex);
                throw;
            }
        }

        private async Task<List<T>> ExecuteReaderListAsync<T>(string storedProcedure, Action<SqlCommand> addParameters, Func<SqlDataReader, T> mapFunc)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand(storedProcedure, connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                addParameters?.Invoke(command);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                var results = new List<T>();
                while (await reader.ReadAsync())
                {
                    results.Add(mapFunc(reader));
                }
                return results;
            }
            catch (SqlException ex)
            {
                HandleCustomSqlException(ex);
                throw;
            }
        }

        private async Task<T?> ExecuteReaderSingleAsync<T>(string storedProcedure, Action<SqlCommand> addParameters, Func<SqlDataReader, T> mapFunc)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand(storedProcedure, connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                addParameters?.Invoke(command);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    return mapFunc(reader);
                }
                return default;
            }
            catch (SqlException ex)
            {
                HandleCustomSqlException(ex);
                throw;
            }
        }

        private void HandleCustomSqlException(SqlException ex)
        {
            // 51000 Range = Business Logic Guards explicitly thrown in SQL
            if (ex.Number >= 51000 && ex.Number < 52000)
            {
                // Throw an exception type that your API layer knows means "Bad Request" (400)
                throw new InvalidOperationException(ex.Message, ex);
            }

            // For 50000 range and all other unhandled SQL exceptions:
            // We just log/handle it here. 
            // The calling method's catch block will re-throw the actual exception using 'throw;'
            SqlExceptionHandler.Handle(ex);
        }
    }
}
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
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_AddSharedDebt]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@CreditorID", debt.CreditorID);
                command.Parameters.AddWithValue("@DebtorID", debt.DebtorID);
                command.Parameters.AddWithValue("@Amount", debt.Amount);
                command.Parameters.AddWithValue("@Title", debt.Title);
                command.Parameters.AddWithValue("@CreatedAt", debt.CreatedAt);
                command.Parameters.AddWithValue("@DueDate", debt.DueDate);
                command.Parameters.AddWithValue("@CreditorWalletID", debt.CreditorWalletID);
                command.Parameters.AddWithValue("@DebtorWalletID", debt.DebtorWalletID);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                return result != null && int.TryParse(result.ToString(), out int insertedId) ? insertedId : -1;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<bool> UpdateDebtAsync(SharedDebt debt)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_UpdateSharedDebt]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@DebtID", debt.DebtID);
                command.Parameters.AddWithValue("@CreditorID", debt.CreditorID);
                command.Parameters.AddWithValue("@DebtorID", debt.DebtorID);
                command.Parameters.AddWithValue("@Amount", debt.Amount);
                command.Parameters.AddWithValue("@Title", debt.Title);
                command.Parameters.AddWithValue("@DueDate", debt.DueDate);
                command.Parameters.AddWithValue("@CreditorWalletID", debt.CreditorWalletID);
                command.Parameters.AddWithValue("@DebtorWalletID", debt.DebtorWalletID);

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

        public async Task<bool> DeleteDebtByIdAsync(int debtId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_DeleteSharedDebtById]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@DebtID", debtId);

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

        public async Task<bool> DeleteDebtByTitleAsync(string title)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_DeleteSharedDebtByTitle]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@Title", title);

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

        public async Task<SharedDebt?> GetDebtByIdAsync(int debtId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_GetSharedDebtById]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@DebtID", debtId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    return new SharedDebt(
                        Convert.ToInt32(reader["DebtID"]),
                        Convert.ToInt32(reader["CreditorID"]),
                        Convert.ToInt32(reader["DebtorID"]),
                        Convert.ToDecimal(reader["Amount"]),
                        reader["Title"].ToString()!,
                        reader["Status"].ToString()!,
                        Convert.ToDateTime(reader["CreatedAt"]),
                        Convert.ToDateTime(reader["DueDate"]),
                        Convert.ToInt32(reader["CreditorWalletID"]),
                        Convert.ToInt32(reader["DebtorWalletID"]),
                        Convert.ToDecimal(reader["PaidAmount"])
                    );
                }

                return null;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<SharedDebt?> GetDebtByTitleAsync(string title)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_GetSharedDebtByTitle]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@Title", title);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    return new SharedDebt(
                        Convert.ToInt32(reader["DebtID"]),
                        Convert.ToInt32(reader["CreditorID"]),
                        Convert.ToInt32(reader["DebtorID"]),
                        Convert.ToDecimal(reader["Amount"]),
                        reader["Title"].ToString()!,
                        reader["Status"].ToString()!,
                        Convert.ToDateTime(reader["CreatedAt"]),
                        Convert.ToDateTime(reader["DueDate"]),
                        Convert.ToInt32(reader["CreditorWalletID"]),
                        Convert.ToInt32(reader["DebtorWalletID"]),
                        Convert.ToDecimal(reader["PaidAmount"])
                    );
                }

                return null;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<IEnumerable<SharedDebt>> GetDebtsOwedToUserAsync(int userId)
        {
            var debts = new List<SharedDebt>();

            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_GetSharedDebtsOwedToUser]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@UserId", userId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                while (await reader.ReadAsync())
                {
                    debts.Add(new SharedDebt(
                        Convert.ToInt32(reader["DebtID"]),
                        Convert.ToInt32(reader["CreditorID"]),
                        Convert.ToInt32(reader["DebtorID"]),
                        Convert.ToDecimal(reader["Amount"]),
                        reader["Title"].ToString()!,
                        reader["Status"].ToString()!,
                        Convert.ToDateTime(reader["CreatedAt"]),
                        Convert.ToDateTime(reader["DueDate"]),
                        Convert.ToInt32(reader["CreditorWalletID"]),
                        Convert.ToInt32(reader["DebtorWalletID"]),
                        Convert.ToDecimal(reader["PaidAmount"])
                    ));
                }

                return debts;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<IEnumerable<SharedDebt>> GetTheDebtsIHaveToPayAsync(int userId)
        {
            var debts = new List<SharedDebt>();

            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_GetSharedDebtsIHaveToPay]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@UserId", userId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                while (await reader.ReadAsync())
                {
                    debts.Add(new SharedDebt(
                        Convert.ToInt32(reader["DebtID"]),
                        Convert.ToInt32(reader["CreditorID"]),
                        Convert.ToInt32(reader["DebtorID"]),
                        Convert.ToDecimal(reader["Amount"]),
                        reader["Title"].ToString()!,
                        reader["Status"].ToString()!,
                        Convert.ToDateTime(reader["CreatedAt"]),
                        Convert.ToDateTime(reader["DueDate"]),
                        Convert.ToInt32(reader["CreditorWalletID"]),
                        Convert.ToInt32(reader["DebtorWalletID"]),
                        Convert.ToDecimal(reader["PaidAmount"])
                    ));
                }

                return debts;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<bool> DebtExistsAsync(int debtId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_CheckSharedDebtExists]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@DebtID", debtId);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                return result != null && Convert.ToInt32(result) > 0;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<IEnumerable<SharedDebt>> GetSharedDebtsForUserAsync(int  userId)
        {
            var debts = new List<SharedDebt>();

            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_GetSharedDebtsForUser]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@UserID", userId);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                while (await reader.ReadAsync())
                {
                    debts.Add(new SharedDebt(
                        Convert.ToInt32(reader["DebtID"]),
                        Convert.ToInt32(reader["CreditorID"]),
                        Convert.ToInt32(reader["DebtorID"]),
                        Convert.ToDecimal(reader["Amount"]),
                        reader["Title"].ToString()!,
                        reader["Status"].ToString()!,
                        Convert.ToDateTime(reader["CreatedAt"]),
                        Convert.ToDateTime(reader["DueDate"]),
                        Convert.ToInt32(reader["CreditorWalletID"]),
                        Convert.ToInt32(reader["DebtorWalletID"]),
                        Convert.ToDecimal(reader["PaidAmount"])
                    ));
                }

                return debts;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<bool> ReturnDebtAmountAsync(SharedDebt debt, decimal amount, string title, string description, decimal amountInSp)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_ReturnDebtAmount]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@DebtID", debt.DebtID);
                command.Parameters.AddWithValue("@CreditorID", debt.CreditorID);
                command.Parameters.AddWithValue("@DebtorID", debt.DebtorID);
                command.Parameters.AddWithValue("@CreditorWalletID", debt.CreditorWalletID);
                command.Parameters.AddWithValue("@DebtorWalletID", debt.DebtorWalletID);
                command.Parameters.AddWithValue("@Amount", amount);
                command.Parameters.AddWithValue("@Title", title);
                command.Parameters.AddWithValue("@Description", description);
                command.Parameters.AddWithValue("@AmountInSp", amountInSp);

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

        public async Task<bool> AcceptDebtAsync(SharedDebt debt, decimal amount, string title, string description, decimal amountInSp)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_AcceptSharedDebt]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@DebtID", debt.DebtID);
                command.Parameters.AddWithValue("@CreditorID", debt.CreditorID);
                command.Parameters.AddWithValue("@DebtorID", debt.DebtorID);
                command.Parameters.AddWithValue("@DueDate", debt.DueDate);
                command.Parameters.AddWithValue("@CreditorWalletID", debt.CreditorWalletID);
                command.Parameters.AddWithValue("@DebtorWalletID", debt.DebtorWalletID);
                command.Parameters.AddWithValue("@Amount", amount);
                command.Parameters.AddWithValue("@Title", title);
                command.Parameters.AddWithValue("@Description", description);
                command.Parameters.AddWithValue("@AmountInSp", amountInSp);

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

        public async Task<bool> RefuseDebtAsync(int debtId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Planning].[sp_RefuseSharedDebt]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@DebtID", debtId);

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
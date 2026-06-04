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
    public class SharedDebtRepository : BaseRepository , ISharedDebtRepository
    {
        private readonly string _connectionString;

        public SharedDebtRepository(IConfiguration configuration)
        : base(configuration.GetConnectionString("DefaultConnection")
                  ?? throw new ArgumentNullException(nameof(configuration), "Connection string is missing in appsettings."))
        { }

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
            return await ExecuteReaderAsync("[Planning].[sp_GetSharedDebtsOwedToUser]",
                cmd => cmd.Parameters.AddWithValue("@UserId", userId), MapToSharedDebt);
        }

        public async Task<IEnumerable<SharedDebt>> GetTheDebtsIHaveToPayAsync(int userId)
        {
            return await ExecuteReaderAsync("[Planning].[sp_GetSharedDebtsIHaveToPay]",
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
            return await ExecuteReaderAsync("[Planning].[sp_GetSharedDebtsForUser]",
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
                EmptyValuesHandler.GetStringOrDefault(reader, "Title"),
                EmptyValuesHandler.GetStringOrDefault(reader, "Status"),
                EmptyValuesHandler.GetDateTimeOrDefault(reader,"CreatedAt"),
                EmptyValuesHandler.GetDateTimeOrDefault(reader, "DueDate"),
                EmptyValuesHandler.GetInt32OrDefault(reader, "CreditorWalletID"),
                EmptyValuesHandler.GetInt32OrDefault(reader, "DebtorWalletID"),
                EmptyValuesHandler.GetDecimalOrDefault(reader, "PaidAmount")
            );
        }
    }
}
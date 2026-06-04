using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.FixedObligations;
using SpendWise.Domain.Entities;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Repositories
{
    public class FixedObligationRepository : BaseRepository, IFixedObligationRepository
    {
        public FixedObligationRepository(IConfiguration configuration)
            : base(configuration.GetConnectionString("DefaultConnection")
                  ?? throw new ArgumentNullException(nameof(configuration), "Connection string is missing in appsettings."))
        { }

        public async Task<FixedObligation?> GetFixedObligationAsync(int obligationId, int userId)
        {
            return await ExecuteReaderSingleAsync("[Planning].[sp_GetFixedExpense]", cmd =>
            {
                cmd.Parameters.AddWithValue("@ExpenseId", obligationId);
                cmd.Parameters.AddWithValue("@UserId", userId);
            }, MapToFixedObligation);
        }

        public async Task<IEnumerable<FixedObligation>> GetFixedObligationsByUserIdAsync(int userId)
        {
            return await ExecuteReaderAsync("[Planning].[sp_GetFixedExpensesByUserId]",
                cmd => cmd.Parameters.AddWithValue("@UserId", userId), MapToFixedObligation);
        }

        public async Task<int> CreateFixedObligationAsync(FixedObligation fixedObligation)
        {
            var result = await ExecuteNonQueryAsync("[Planning].[sp_CreateFixedExpense]", cmd =>
            {
                cmd.Parameters.AddWithValue("@OwnerId", fixedObligation.OwnerId);
                cmd.Parameters.AddWithValue("@Title", fixedObligation.Title);
                cmd.Parameters.AddWithValue("@Amount", fixedObligation.Amount);
                cmd.Parameters.AddWithValue("@DueDate", fixedObligation.DueDate);
                cmd.Parameters.AddWithValue("@IsActive", fixedObligation.IsActive);
            });

            return result > 0 ? result : -1;
        }

        public async Task<bool> UpdateFixedObligationAsync(FixedObligation fixedObligation)
        {
            var rowsAffected = await ExecuteNonQueryAsync("[Planning].[sp_UpdateFixedExpense]", cmd =>
            {
                cmd.Parameters.AddWithValue("@Id", fixedObligation.Id);
                cmd.Parameters.AddWithValue("@OwnerId", fixedObligation.OwnerId);
                cmd.Parameters.AddWithValue("@Title", fixedObligation.Title);
                cmd.Parameters.AddWithValue("@Amount", fixedObligation.Amount);
                cmd.Parameters.AddWithValue("@DueDate", fixedObligation.DueDate);
                cmd.Parameters.AddWithValue("@IsActive", fixedObligation.IsActive);
            });

            return rowsAffected > 0;
        }

        public async Task<bool> DeleteFixedObligationAsync(int obligationId, int userId)
        {
            var rowsAffected = await ExecuteNonQueryAsync("[Planning].[sp_DeleteFixedExpense]", cmd =>
            {
                cmd.Parameters.AddWithValue("@Id", obligationId);
                cmd.Parameters.AddWithValue("@UserId", userId);
            });

            return rowsAffected > 0;
        }

        public async Task<bool> IsObligationActive(int obligationId, int userId)
        {
            var result = await ExecuteScalarAsync<object>("[Planning].[sp_CheckFixedExpenseActive]", cmd =>
            {
                cmd.Parameters.AddWithValue("@ExpenseId", obligationId);
                cmd.Parameters.AddWithValue("@UserId", userId);
            });

            return result != null && Convert.ToBoolean(result);
        }

        // =========================================================================
        // REUSABLE HELPER METHODS & MAPPERS
        // =========================================================================
        private static FixedObligation MapToFixedObligation(SqlDataReader reader)
        {
            return new FixedObligation(
                id: EmptyValuesHandler.GetInt32OrDefault(reader, "FixedExpenseID"),
                ownerId: EmptyValuesHandler.GetInt32OrDefault(reader, "UserID"),
                title: EmptyValuesHandler.GetStringOrDefault(reader, "Title"),
                amount: EmptyValuesHandler.GetDecimalOrDefault(reader, "Amount"),
                dueDate: EmptyValuesHandler.GetDateTimeOrDefault(reader, "DueDate"),
                isActive: EmptyValuesHandler.GetBooleanOrDefault(reader, "IsActive")
            );
        }
    }
}
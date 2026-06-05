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
                cmd.Parameters.AddWithValue("@FixedExpenceId", obligationId);
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
            var result = await ExecuteScalarAsync<int>("[Planning].[sp_CreateFixedExpense]", cmd =>
            {
                cmd.Parameters.AddWithValue("@UserId", fixedObligation.UserId);
                cmd.Parameters.AddWithValue("@WalletId", fixedObligation.WalletId);
                cmd.Parameters.AddWithValue("@Title", fixedObligation.Title);
                cmd.Parameters.AddWithValue("@Amount", fixedObligation.Amount);
                cmd.Parameters.AddWithValue("@IsMonthly", fixedObligation.IsMonthly);
                cmd.Parameters.AddWithValue("@IsActive", fixedObligation.IsActive);
                cmd.Parameters.AddWithValue("@Days", (object?)fixedObligation.Days ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@LastTime", (object?)fixedObligation.LastTime ?? DBNull.Value);
            });

            return result > 0 ? result : -1;
        }

        public async Task<bool> UpdateFixedObligationAsync(FixedObligation fixedObligation)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Planning].[sp_UpdateFixedExpense]", cmd =>
            {
                cmd.Parameters.AddWithValue("@FixedExpenseID", fixedObligation.FixedObligationId);
                cmd.Parameters.AddWithValue("@UserId", fixedObligation.UserId);
                cmd.Parameters.AddWithValue("@WalletId", fixedObligation.WalletId);
                cmd.Parameters.AddWithValue("@Title", fixedObligation.Title);
                cmd.Parameters.AddWithValue("@Amount", fixedObligation.Amount);
                cmd.Parameters.AddWithValue("@IsMonthly", fixedObligation.IsMonthly);
                cmd.Parameters.AddWithValue("@IsActive", fixedObligation.IsActive);
                cmd.Parameters.AddWithValue("@Days", (object?)fixedObligation.Days ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@LastTime", (object?)fixedObligation.LastTime ?? DBNull.Value);
            });

            return rowsAffected > 0;
        }

        public async Task<bool> DeleteFixedObligationAsync(int obligationId, int userId)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Planning].[sp_DeleteFixedExpense]", cmd =>
            {
                cmd.Parameters.AddWithValue("@FixedExpenseID", obligationId);
                cmd.Parameters.AddWithValue("@UserId", userId);
            });

            return rowsAffected > 0;
        }

        public async Task<bool> IsObligationActive(int obligationId, int userId)
        {
            var result = await ExecuteScalarAsync<object>("[Planning].[sp_CheckFixedExpenseActive]", cmd =>
            {
                cmd.Parameters.AddWithValue("@FixedExpenseID", obligationId);
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
         EmptyValuesHandler.GetInt32OrDefault(reader, "FixedExpenseID"), 
            EmptyValuesHandler.GetInt32OrDefault(reader, "UserId"),         
            EmptyValuesHandler.GetInt32OrDefault(reader, "WalletId"),       
             EmptyValuesHandler.GetStringOrDefault(reader, "Title"),         
             EmptyValuesHandler.GetDecimalOrDefault(reader, "Amount"),       
                EmptyValuesHandler.GetBooleanOrDefault(reader, "IsMonthly"),    
             EmptyValuesHandler.GetBooleanOrDefault(reader, "IsActive"),     
    reader.IsDBNull(reader.GetOrdinal("Days")) ? null : (int?)reader.GetInt32(reader.GetOrdinal("Days")), 
    reader.IsDBNull(reader.GetOrdinal("LastTime")) ? null : (DateTime?)reader.GetDateTime(reader.GetOrdinal("LastTime")) 
);
        }
    }
}
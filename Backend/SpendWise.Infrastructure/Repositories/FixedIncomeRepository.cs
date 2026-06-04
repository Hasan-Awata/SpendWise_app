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
    public class FixedIncomeRepository : BaseRepository, IFixedIncomeRepository
    {
        public FixedIncomeRepository(IConfiguration configuration)
            : base(configuration.GetConnectionString("DefaultConnection")
                  ?? throw new ArgumentNullException(nameof(configuration), "Connection string is missing in appsettings.")) { }

        public async Task<FixedIncome?> GetFixedIncomeAsync(int fixedIncomeId, int userId)
        {
            return await ExecuteReaderSingleAsync("[Planning].[sp_GetFixedIncome]", cmd =>
            {
                cmd.Parameters.AddWithValue("@FixedIncomeId", fixedIncomeId);
                cmd.Parameters.AddWithValue("@UserId", userId);
            }, MapToFixedIncome);
        }

        public async Task<IEnumerable<FixedIncome>> GetFixedIncomesByUserIdAsync(int userId)
        {
            return await ExecuteReaderAsync("[Planning].[sp_GetFixedIncomesByUser]",
                cmd => cmd.Parameters.AddWithValue("@UserId", userId), MapToFixedIncome);
        }

        public async Task<int> CreateFixedIncomeAsync(FixedIncome fixedIncome)
        {
            var result = await ExecuteScalarAsync<int>("[Planning].[sp_CreateFixedIncome]", cmd =>
            {
                cmd.Parameters.AddWithValue("@UserId", fixedIncome.UserId);
                cmd.Parameters.AddWithValue("@Title", fixedIncome.Title);
                cmd.Parameters.AddWithValue("@Amount", fixedIncome.Amount);
                cmd.Parameters.AddWithValue("@IsMonthly", fixedIncome.IsMonthly);
                cmd.Parameters.AddWithValue("@IsActive", fixedIncome.IsActive);
                cmd.Parameters.AddWithValue("@Days", (object?)fixedIncome.Days ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@LastTime", (object?)fixedIncome.LastTime ?? DBNull.Value);
            });

            return result > 0 ? result : -1;
        }

        public async Task<bool> UpdateFixedIncomeAsync(FixedIncome fixedIncome)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Planning].[sp_UpdateFixedIncome]", cmd =>
            {
                cmd.Parameters.AddWithValue("@FixedIncomeId", fixedIncome.FixedIncomeId);
                cmd.Parameters.AddWithValue("@UserId", fixedIncome.UserId);
                cmd.Parameters.AddWithValue("@Title", fixedIncome.Title);
                cmd.Parameters.AddWithValue("@Amount", fixedIncome.Amount);
                cmd.Parameters.AddWithValue("@IsMonthly", fixedIncome.IsMonthly);
                cmd.Parameters.AddWithValue("@IsActive", fixedIncome.IsActive);
                cmd.Parameters.AddWithValue("@Days", (object?)fixedIncome.Days ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@LastTime", (object?)fixedIncome.LastTime ?? DBNull.Value);
            });

            return rowsAffected > 0;
        }

        public async Task<bool> DeleteFixedIncomeAsync(int fixedIncomeId, int userId)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Planning].[sp_DeleteFixedIncome]", cmd =>
            {
                cmd.Parameters.AddWithValue("@FixedIncomeId", fixedIncomeId);
                cmd.Parameters.AddWithValue("@UserId", userId);
            });

            return rowsAffected > 0;
        }

        public async Task<bool> IsIncomeActive(int fixedIncomeId, int userId)
        {
            var result = await ExecuteScalarAsync<object>("[Planning].[sp_CheckFixedIncomeActive]", cmd =>
            {
                cmd.Parameters.AddWithValue("@FixedIncomeId", fixedIncomeId);
                cmd.Parameters.AddWithValue("@UserId", userId);
            });

            return result != null && Convert.ToBoolean(result);
        }

        // =========================================================================
        // REUSABLE HELPER METHODS & MAPPERS
        // =========================================================================
        private static FixedIncome MapToFixedIncome(SqlDataReader reader)
        {
            return new FixedIncome
            (
                EmptyValuesHandler.GetInt32OrDefault(reader, "FixedIncomeId"),
                EmptyValuesHandler.GetInt32OrDefault(reader, "UserId"),
                -1,
                EmptyValuesHandler.GetStringOrDefault(reader, "Title"),
                EmptyValuesHandler.GetDecimalOrDefault(reader, "Amount"),
                EmptyValuesHandler.GetBooleanOrDefault(reader, "IsMonthly"),
                EmptyValuesHandler.GetBooleanOrDefault(reader, "IsActive"),
                EmptyValuesHandler.GetInt32OrDefault(reader, "Days"),
                EmptyValuesHandler.GetDateTimeOrDefault(reader, "LastTime")
            );
        }
    }
}
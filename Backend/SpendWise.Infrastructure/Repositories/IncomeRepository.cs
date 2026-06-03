using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Incomes;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Repositories
{
    public class IncomeRepository : BaseRepository, IIncomeRepository
    {
        public IncomeRepository(IConfiguration configuration)
            : base(configuration.GetConnectionString("DefaultConnection")
                  ?? throw new ArgumentNullException(nameof(configuration), "Connection string is missing in appsettings."))
        { }

        public async Task<int> AddIncomeAsync(Income newIncome)
        {
            SqlParameter? outputId = null;

            // Execute using base runner while capturing output parameter via closure
            await ExecuteScalarAsync<object>("[Ledger].[sp_AddIncomeWithTransaction]", cmd =>
            {
                // Shared parameters
                cmd.Parameters.AddWithValue("@UserId", newIncome.UserId);
                cmd.Parameters.AddWithValue("@WalletId", newIncome.WalletId);
                cmd.Parameters.AddWithValue("@Amount", newIncome.Amount);
                cmd.Parameters.AddWithValue("@IncomeDate", newIncome.Date);
                cmd.Parameters.AddWithValue("@Title", newIncome.Title);

                // Optional parameters
                cmd.Parameters.AddWithValue("@Description", (object?)newIncome.LinkedTransaction.Description ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TagId", newIncome.IncomeTagId > 0 ? newIncome.IncomeTagId : DBNull.Value);

                // Transaction Details
                cmd.Parameters.AddWithValue("@AmountInSp", newIncome.LinkedTransaction.AmountInSp);
                cmd.Parameters.AddWithValue("@TransactionType", (int)newIncome.LinkedTransaction.TransactionType);

                // Output parameter setup
                outputId = new SqlParameter("@NewIncomeID", SqlDbType.Int) { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outputId);
            });

            return (int)(outputId?.Value ?? -1);
        }

        public async Task<bool> UpdateIncomeAsync(Income newIncome)
        {
            // Using ExecuteScalar because the procedure returns an explicit status value via SELECT
            var rowsAffected = await ExecuteScalarAsync<int>("[Ledger].[sp_UpdateIncomeWithTransaction]", cmd =>
            {
                // 1. Core ID and Identity
                cmd.Parameters.AddWithValue("@IncomeId", newIncome.Id);
                cmd.Parameters.AddWithValue("@UserId", newIncome.UserId);

                // 2. Income Table Data
                cmd.Parameters.AddWithValue("@WalletId", newIncome.WalletId);
                cmd.Parameters.AddWithValue("@TagId", newIncome.IncomeTagId > 0 ? newIncome.IncomeTagId : DBNull.Value);
                cmd.Parameters.AddWithValue("@Amount", newIncome.Amount);
                cmd.Parameters.AddWithValue("@IncomeDate", newIncome.Date);

                // 3. Transaction/Shared Data
                cmd.Parameters.AddWithValue("@Title", newIncome.LinkedTransaction.Title);
                cmd.Parameters.AddWithValue("@Description", (object?)newIncome.LinkedTransaction.Description ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TransactionType", (int)newIncome.LinkedTransaction.TransactionType);
                cmd.Parameters.AddWithValue("@AmountInSp", newIncome.LinkedTransaction.AmountInSp);
            });

            return rowsAffected > 0;
        }

        public async Task<bool> DeleteIncomeAsync(int incomeId, int userId)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Ledger].[sp_DeleteIncome]", cmd =>
            {
                cmd.Parameters.AddWithValue("@IncomeId", incomeId);
                cmd.Parameters.AddWithValue("@UserId", userId);
            });

            return rowsAffected > 0;
        }

        public async Task<Income?> GetIncomeAsync(int incomeId, int userId)
        {
            return await ExecuteReaderSingleAsync("[Ledger].[sp_GetIncome]", cmd =>
            {
                cmd.Parameters.AddWithValue("@IncomeID", incomeId);
                cmd.Parameters.AddWithValue("@UserID", userId);
            }, MapToIncome);
        }

        public async Task<(IEnumerable<Income> incomes, int totalCount)> GetIncomeByUserAsync(int userId, int pageNumber, int pageSize, int? tagId = null, int? transactionType = null)
        {
            var incomes = new List<Income>();
            int totalCount = 0;

            // Multi-result sets handled sequentially through the custom grid reader delegate
            await ExecuteReaderAsync("[Ledger].[sp_GetIncomesByUserPaged]",
                cmd =>
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@PageNumber", pageNumber);
                    cmd.Parameters.AddWithValue("@PageSize", pageSize);
                    cmd.Parameters.AddWithValue("@TagId", tagId.HasValue ? (object)tagId.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@TransactionType", transactionType.HasValue ? (object)transactionType.Value : DBNull.Value);
                },
                async reader =>
                {
                    // Result Set 1: Total Count
                    if (await reader.ReadAsync())
                    {
                        totalCount = EmptyValuesHandler.GetInt32OrDefault(reader, "TotalCount");
                    }

                    // Result Set 2: Paged Incomes List
                    if (await reader.NextResultAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            incomes.Add(MapToIncome(reader));
                        }
                    }
                    return default(object); // Dummy return to fulfill functional signature mapping constraint
                });

            return (incomes, totalCount);
        }

        // =========================================================================
        // REUSABLE HELPER METHODS & MAPPERS
        // =========================================================================
        private static Income MapToIncome(SqlDataReader reader)
        {
            var income = new Income
            {
                Id = EmptyValuesHandler.GetInt32OrDefault(reader, "IncomeID"),
                UserId = EmptyValuesHandler.GetInt32OrDefault(reader, "UserID"),
                Title = EmptyValuesHandler.GetStringOrDefault(reader, "Title"),
                Amount = EmptyValuesHandler.GetDecimalOrDefault(reader, "Amount"),
                Date = EmptyValuesHandler.GetDateTimeOrDefault(reader, "Date"),
                WalletId = EmptyValuesHandler.GetInt32OrDefault(reader, "WalletID"),
                IncomeTagId = reader.IsDBNull(reader.GetOrdinal("TagID")) ? -1 : Convert.ToInt32(reader["TagID"])
            };

            income.LinkedTransaction = new Transaction(
                income.Id,
                income.UserId,
                income.Title,
                EmptyValuesHandler.GetStringOrDefault(reader, "Description"),
                income.WalletId,
                income.Amount,
                EmptyValuesHandler.GetDecimalOrDefault(reader, "AmountInSp"),
                income.Date,
                enTransactionType.Addition,
                -1, -1, -1, -1
            );

            return income;
        }
    }
}
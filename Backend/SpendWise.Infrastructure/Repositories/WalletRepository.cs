using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Domain.Entities;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Repositories
{
    public class WalletRepository : BaseRepository, IWalletRepository
    {
        public WalletRepository(IConfiguration configuration)
            : base(configuration.GetConnectionString("DefaultConnection")
                  ?? throw new ArgumentNullException(nameof(configuration), "Connection string is missing in appsettings."))
        { }

        public async Task<Wallet?> GetWalletByIdAsync(int walletId, int userId)
        {
            return await ExecuteReaderSingleAsync("[Banking].[sp_GetWalletById]", cmd =>
            {
                cmd.Parameters.AddWithValue("@WalletId", walletId);
                cmd.Parameters.AddWithValue("@UserId", userId);
            }, MapWalletFromReader);
        }

        public async Task<IEnumerable<Wallet>> GetUserWalletsAsync(int userId)
        {
            return await ExecuteReaderAsync("[Banking].[sp_GetUserWallets]",
                cmd => cmd.Parameters.AddWithValue("@UserId", userId), MapWalletFromReader);
        }

        public async Task<IEnumerable<Wallet>> GetWalletsByCurrencyIdAsync(int userId, int currencyId)
        {
            return await ExecuteReaderAsync("[Banking].[sp_GetWalletsByCurrencyId]", cmd =>
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@CurrencyId", currencyId);
            }, MapWalletFromReader);
        }

        public async Task<IEnumerable<Wallet>> GetUserWalletsPairAsync(int userId, int walletId)
        {
            return await ExecuteReaderAsync("[Banking].[sp_GetUserWalletsPair]", cmd =>
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@WalletId", walletId);
            }, MapWalletFromReader);
        }

        public async Task<int> AddWalletAsync(Wallet wallet)
        {
            var insertedId = await ExecuteScalarAsync<int>("[Banking].[sp_AddWallet]", cmd =>
            {
                cmd.Parameters.AddWithValue("@UserId", wallet.UserId);
                cmd.Parameters.AddWithValue("@Balance", wallet.Balance);
                cmd.Parameters.AddWithValue("@IsSaved", wallet.IsSaved);
                cmd.Parameters.AddWithValue("@CurrencyID", wallet.CurrencyId);
            });

            if (insertedId > 0)
            {
                wallet.WalletId = insertedId;
            }

            return wallet.WalletId;
        }

        public async Task<bool> UpdateWalletAsync(Wallet wallet)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Banking].[sp_UpdateWallet]", cmd =>
            {
                cmd.Parameters.AddWithValue("@WalletId", wallet.WalletId);
                cmd.Parameters.AddWithValue("@UserId", wallet.UserId);
                cmd.Parameters.AddWithValue("@CurrencyId", wallet.CurrencyId);
                cmd.Parameters.AddWithValue("@Balance", wallet.Balance);
                cmd.Parameters.AddWithValue("@IsSaved", wallet.IsSaved);
            });

            return rowsAffected > 0;
        }

        public async Task<bool> DeleteWalletAsync(int walletId, int userId)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Banking].[sp_DeleteWallet]", cmd =>
            {
                cmd.Parameters.AddWithValue("@WalletId", walletId);
                cmd.Parameters.AddWithValue("@UserId", userId);
            });

            return rowsAffected > 0;
        }

        // =========================================================================
        // REUSABLE HELPER METHODS & MAPPERS
        // =========================================================================
        private static Wallet MapWalletFromReader(SqlDataReader reader)
        {
            return new Wallet(
                walletId: EmptyValuesHandler.GetInt32OrDefault(reader, "WalletID"),
                currencyId: EmptyValuesHandler.GetInt32OrDefault(reader, "CurrencyID"),
                balance: EmptyValuesHandler.GetDecimalOrDefault(reader, "Balance"),
                userId: EmptyValuesHandler.GetInt32OrDefault(reader, "UserID"),
                isSaved: EmptyValuesHandler.GetBooleanOrDefault(reader, "IsSaved")
            );
        }
    }
}
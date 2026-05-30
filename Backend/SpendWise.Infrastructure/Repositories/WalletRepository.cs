using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Domain.Entities;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

public class WalletRepository : IWalletRepository
{
    private readonly string _connectionString;

    public WalletRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")
                                        ?? throw new ArgumentNullException("Connection string is missing in appsettings.");
    }

    public async Task<Wallet?> GetWalletByIdAsync(int walletId, int userId)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("[Banking].[sp_GetWalletById]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@WalletId", walletId);
            command.Parameters.AddWithValue("@UserId", userId);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();

            if (await reader.ReadAsync())
            {
                return MapWalletFromReader(reader);
            }

            return null;
        }
        catch (SqlException ex)
        {
            SqlExceptionHandler.Handle(ex);
            throw;
        }
    }

    public async Task<IEnumerable<Wallet>> GetUserWalletsAsync(int userId)
    {
        var wallets = new List<Wallet>();

        try
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("[Banking].[sp_GetUserWallets]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@UserId", userId);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                wallets.Add(MapWalletFromReader(reader));
            }

            return wallets;
        }
        catch (SqlException ex)
        {
            SqlExceptionHandler.Handle(ex);
            throw;
        }
    }

    public async Task<IEnumerable<Wallet>> GetWalletsByCurrencyIdAsync(int userId, int currencyId)
    {
        var wallets = new List<Wallet>();

        try
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("[Banking].[sp_GetWalletsByCurrencyId]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@UserId", userId);
            command.Parameters.AddWithValue("@CurrencyId", currencyId);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                wallets.Add(MapWalletFromReader(reader));
            }

            return wallets;
        }
        catch (SqlException ex)
        {
            SqlExceptionHandler.Handle(ex);
            throw;
        }
    }

    public async Task<int> AddWalletAsync(Wallet wallet)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("[Banking].[sp_AddWallet]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@UserId", wallet.UserId);
            command.Parameters.AddWithValue("@Balance", wallet.Balance);
            command.Parameters.AddWithValue("@IsSaved", wallet.IsSaved);
            command.Parameters.AddWithValue("@CurrencyID", wallet.CurrencyId);

            await connection.OpenAsync();
            object? result = await command.ExecuteScalarAsync();

            if (result != null && int.TryParse(result.ToString(), out int insertedID))
            {
                wallet.WalletId = insertedID;
            }
        }
        catch (SqlException ex)
        {
            SqlExceptionHandler.Handle(ex);
            throw;
        }
        return wallet.WalletId;
    }

    public async Task<bool> UpdateWalletAsync(Wallet wallet)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("[Banking].[sp_UpdateWallet]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@WalletId", wallet.WalletId);
            command.Parameters.AddWithValue("@UserId", wallet.UserId);
            command.Parameters.AddWithValue("@CurrencyId", wallet.CurrencyId); 
            command.Parameters.AddWithValue("@Balance", wallet.Balance);
            command.Parameters.AddWithValue("@IsSaved", wallet.IsSaved);

            await connection.OpenAsync();
            object? result = await command.ExecuteScalarAsync();

            return result != null && int.TryParse(result.ToString(), out int rowsAffected) && rowsAffected > 0;
        }
        catch (SqlException ex)
        {
            SqlExceptionHandler.Handle(ex);
            throw;
        }
    }

    public async Task<bool> DeleteWalletAsync(int walletId, int userId)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("[Banking].[sp_DeleteWallet]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@WalletId", walletId);
            command.Parameters.AddWithValue("@UserId", userId);

            await connection.OpenAsync();
            object? result = await command.ExecuteScalarAsync();
            return result != null && int.TryParse(result.ToString(), out int rowsAffected) && rowsAffected > 0;
        }
        catch (SqlException ex)
        {
            SqlExceptionHandler.Handle(ex);
            throw;
        }
    }

    private static Wallet MapWalletFromReader(SqlDataReader reader)
    {
        return new Wallet(
            walletId: Convert.ToInt32(reader["WalletID"]),
            currencyId: Convert.ToInt32(reader["CurrencyID"]),
            balance: Convert.ToDecimal(reader["Balance"]),
            userId: Convert.ToInt32(reader["UserID"]),
            isSaved: Convert.ToBoolean(reader["IsSaved"])
        );
    }
}
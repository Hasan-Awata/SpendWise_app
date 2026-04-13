using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Domain.Entities;
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
        catch (SqlException ex) when (ex.Number == -2)
        {
            throw new TimeoutException("The database took too long to respond while fetching the wallet.");
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
        catch (SqlException ex) when (ex.Number == -2)
        {
            throw new TimeoutException("The database took too long to respond while fetching wallets.");
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
            command.Parameters.AddWithValue("@CurrencyID", wallet.Currency.Id);

            await connection.OpenAsync();
            object result = await command.ExecuteScalarAsync();

            if (result != null && int.TryParse(result.ToString(), out int insertedID))
            {
                wallet.WalletId = insertedID;
            }
        }
        catch (SqlException ex)
        {
            HandleSqlException(ex);
            throw;
        }
        return wallet.WalletId;
    }

    public async Task<int> UpdateWalletAsync(Wallet wallet)
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
            command.Parameters.AddWithValue("@Balance", wallet.Balance);
            command.Parameters.AddWithValue("@CurrencyName", wallet.Currency.CurrencyName);
            command.Parameters.AddWithValue("@ActualValue", wallet.Currency.LiveValue);

            await connection.OpenAsync();
            return await command.ExecuteNonQueryAsync();
        }
        catch (SqlException ex)
        {
            HandleSqlException(ex);
            throw;
        }
    }

    public async Task<bool> DeleteWalletAsync(int walletId)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("[Banking].[sp_DeleteWallet]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@WalletId", walletId);

            await connection.OpenAsync();
            var rowsAffected = await command.ExecuteNonQueryAsync();

            return rowsAffected > 0;
        }
        catch (SqlException ex)
        {
            HandleSqlException(ex);
            throw;
        }
    }

    private void HandleSqlException(SqlException ex)
    {
        switch (ex.Number)
        {
            case 2601:
            case 2627:
                throw new DuplicateResourceException("This user already has a wallet with this currency.");
            case 547:
                throw new InvalidReferenceException("Invalid user, currency, or a negative balance was provided, or you are trying to delete a wallet that has existing transactions.");
            case -2:
                throw new TimeoutException("The database took too long to respond. Please try again.");
            default:
                throw new Exception($"An unexpected database error occurred. Code: {ex.Number}");
        }
    }

    private static Wallet MapWalletFromReader(SqlDataReader reader)
    {
        var currency = new Currency(
            id: Convert.ToInt32(reader["CurrencyID"]),
            currencyName: reader["CurrencyName"].ToString()!,
            livevalue: Convert.ToDecimal(reader["ActualValue"])
        );

        return new Wallet(
            walletId: Convert.ToInt32(reader["WalletID"]),
            currency: currency,
            balance: Convert.ToDecimal(reader["Balance"]),
            userId: Convert.ToInt32(reader["UserID"]),
            isSaved: Convert.ToBoolean(reader["IsSaved"])
        );
    }
}
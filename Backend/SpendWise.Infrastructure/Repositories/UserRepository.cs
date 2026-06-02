using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Users;
using SpendWise.Domain.Entities;
using SpendWise.Infrastructure.Global;
using System;
using System.Data;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Repositories
{
    public class UserRepository : BaseRepository, IUserRepository
    {
        public UserRepository(IConfiguration configuration)
            : base(configuration.GetConnectionString("DefaultConnection")
                  ?? throw new ArgumentNullException(nameof(configuration), "Connection string is missing in appsettings."))
        { }

        public async Task<User?> GetByIdAsync(int id)
        {
            return await ExecuteReaderSingleAsync("[Identity].[sp_GetUserById]",
                cmd => cmd.Parameters.AddWithValue("@UserID", id), MapToUser);
        }

        public async Task<User?> GetByUsernameAsync(string userName)
        {
            return await ExecuteReaderSingleAsync("[Identity].[sp_GetUserByUsername]",
                cmd => cmd.Parameters.AddWithValue("@Username", userName), MapToUser);
        }

        public async Task<bool> IsUsernameExistAsync(string username)
        {
            var result = await ExecuteScalarAsync<object>("[Identity].[sp_CheckUsernameExists]",
                cmd => cmd.Parameters.AddWithValue("@Username", username));

            return result != null && Convert.ToBoolean(result);
        }

        public async Task<int> AddUserAsync(User user)
        {
            var insertedId = await ExecuteScalarAsync<int>("[Identity].[sp_AddUser]", cmd =>
            {
                cmd.Parameters.AddWithValue("@Username", user.UserName);
                cmd.Parameters.AddWithValue("@Password", user.HashedPassword);
                cmd.Parameters.AddWithValue("@FirstName", user.FirstName);
                cmd.Parameters.AddWithValue("@LastName", user.LastName);
            });

            if (insertedId > 0)
            {
                user.Id = insertedId;
                return insertedId;
            }

            return -1;
        }

        public async Task<bool> UpdateRefreshTokenAsync(int userId, string refreshToken, DateTime expiryTime)
        {
            var rowsAffected = await ExecuteNonQueryAsync("[Identity].[sp_UpdateUserRefreshToken]", cmd =>
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@RefreshToken", (object?)refreshToken ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@RefreshTokenExpiryTime", (object?)expiryTime ?? DBNull.Value);
            });

            return rowsAffected > 0;
        }

        // =========================================================================
        // REUSABLE HELPER METHODS & MAPPERS
        // =========================================================================
        private static User MapToUser(SqlDataReader reader)
        {
            return new User(
                ID: EmptyValuesHandler.GetInt32OrDefault(reader, "UserID"),
                userName: EmptyValuesHandler.GetStringOrDefault(reader, "Username"),
                HashedPassword: EmptyValuesHandler.GetStringOrDefault(reader, "Password"),
                FirstName: EmptyValuesHandler.GetStringOrDefault(reader, "FirstName"),
                LastName: EmptyValuesHandler.GetStringOrDefault(reader, "LastName"),
                RefreshToken: EmptyValuesHandler.GetStringOrDefault(reader, "RefreshToken"),
                RefreshTokenExpiryTime: EmptyValuesHandler.GetDateTimeOrDefault(reader, "RefreshTokenExpiryTime")
            );
        }
    }
}
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Users;
using SpendWise.Domain.Entities;
using SpendWise.Infrastructure.Global; 
using System;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly string _connectionString;

        public UserRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                                            ?? throw new ArgumentNullException("Connection string is missing in appsettings.");
        }

        public async Task<User?> GetByIdAsync(int id)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Identity].[sp_GetUserById]", connection)
                {
                    CommandType = System.Data.CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@UserID", id);

                await connection.OpenAsync();
                using SqlDataReader reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    return new User(
                        ID: (int)reader["UserID"],
                        userName: (string)reader["Username"],
                        HashedPassword: (string)reader["Password"],
                        FirstName: (string)reader["FirstName"],
                        LastName: (string)reader["LastName"],
                        RefreshToken: (string)reader["RefreshToken"],
                        RefreshTokenExpiryTime: (DateTime)reader["RefreshTokenExpiryTime"]
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

        public async Task<User?> GetByUsernameAsync(string userName)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Identity].[sp_GetUserByUsername]", connection)
                {
                    CommandType = System.Data.CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@Username", userName);

                await connection.OpenAsync();
                using SqlDataReader reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    return new User(
                        ID: (int)reader["UserID"],
                        userName: (string)reader["Username"],
                        HashedPassword: (string)reader["Password"],
                        FirstName: (string)reader["FirstName"],
                        LastName: (string)reader["LastName"],
                        RefreshToken: (string)reader["RefreshToken"],
                        RefreshTokenExpiryTime: (DateTime)reader["RefreshTokenExpiryTime"]
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

        public async Task<bool> IsUsernameExistAsync(string username)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Identity].[sp_CheckUsernameExists]", connection)
                {
                    CommandType = System.Data.CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@Username", username);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                // Clean scalar boolean evaluation
                return result != null && Convert.ToBoolean(result);
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<int> AddUserAsync(User user)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Identity].[sp_AddUser]", connection)
                {
                    CommandType = System.Data.CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@Username", user.UserName);
                command.Parameters.AddWithValue("@Password", user.HashedPassword);
                command.Parameters.AddWithValue("@FirstName", user.FirstName);
                command.Parameters.AddWithValue("@LastName", user.LastName);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                if (result != null && int.TryParse(result.ToString(), out int insertedID))
                {
                    user.Id = insertedID;
                    return insertedID;
                }

                return -1;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex); 
                throw;
            }
        }

        public async Task<bool> UpdateRefreshTokenAsync(int userId, string refreshToken, DateTime expiryTime)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Identity].[sp_UpdateUserRefreshToken]", connection)
                {
                    CommandType = System.Data.CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@RefreshToken", (object?)refreshToken ?? DBNull.Value);
                command.Parameters.AddWithValue("@RefreshTokenExpiryTime", (object?)expiryTime ?? DBNull.Value);

                await connection.OpenAsync();
                var result = await command.ExecuteNonQueryAsync();

                return result > 0;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }
    }
}
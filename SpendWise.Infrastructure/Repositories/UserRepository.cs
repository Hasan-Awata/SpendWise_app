using Azure;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Users;
using SpendWise.Domain.Entities;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace SpendWise.Infrastructure.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly string _connectionString;
        public UserRepository(IConfiguration configuration)
        {
            _connectionString = DataAccessSettings.ConnectionString
                                ?? throw new ArgumentNullException("Connection string is missing.");
        }
        public async Task<User?> GetByIdAsync(int id)
        {
            User user = null;

            using var connection = new SqlConnection(_connectionString);
            using (SqlCommand command = new SqlCommand("[Identity].[sp_GetUserById]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserID", id);

                    try
                    {
                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                user = new User((string)reader["Username"],
                                                (string)reader["Password"],
                                                (string)reader["FirstName"],
                                                (string)reader["LastName"]);
                            }
                        }
                    }
                    catch (Exception) { }
            }
            return user;
        }
        public async Task<User?> GetByUsernameAsync(string userName)
        {
            User user = null;

            using var connection = new SqlConnection(_connectionString);
            using (SqlCommand command = new SqlCommand("[Identity].[sp_GetUserByUsername]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Username", userName);

                    try
                    {
                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                user = new User((int)reader["UserID"],
                                                (string)reader["Username"],
                                                (string)reader["Password"],
                                                (string)reader["FirstName"],
                                                (string)reader["LastName"]);
                            }
                        }
                    }
                    catch (Exception) { }
            }
            return user;
        }
        public async Task<bool> IsUsernameExistAsync(string username)
        {
            bool found = false;
            using var connection = new SqlConnection(_connectionString);
            using (SqlCommand command = new SqlCommand("[Identity].[sp_CheckUsernameExists]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Username", username);

                    try
                    {
                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            found = reader.HasRows;
                        }
                    }
                    catch (Exception) { }
            }
            return found;
        }
        public async Task<int> AddUserAsync(User user)
        {
            int UserID = -1;

            using var connection = new SqlConnection(_connectionString);
            using (SqlCommand command = new SqlCommand("[Identity].[sp_AddUser]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@NewUserID", user.Id);
                    command.Parameters.AddWithValue("@Username", user.UserName);
                    command.Parameters.AddWithValue("@Password", user.HashedPassword);
                    command.Parameters.AddWithValue("@FirstName", user.FirstName);
                    command.Parameters.AddWithValue("@LastName", user.LastName);

                    try
                    {
                        await connection.OpenAsync();
                        object result = await command.ExecuteScalarAsync();
                    }
                    catch (Exception)
                    {
                        return user.Id;
                    }
                return user.Id;
            }
        }
    }
}
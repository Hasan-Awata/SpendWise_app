using Azure;
using Microsoft.Data.SqlClient;
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
        public async Task<User?> GetByIdAsync(int id)
        {
            User user = null;

            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[usr].[sp_GetUserByID]", connection))
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
                                user = new User((string)reader["UserName"],
                                                (string)reader["HashedPassword"],
                                                (string)reader["FirstName"],
                                                (string)reader["LastName"]);
                            }
                        }
                    }
                    catch (Exception) { }
                }
            }
            return user;
        }
        public async Task<User?> GetByUsernameAsync(string userName)
        {
            User user = null;

            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[usr].[sp_GetByUsername]", connection))
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
                                                (string)reader["UserName"],
                                                (string)reader["Password"],
                                                (string)reader["FirstName"],
                                                (string)reader["LastName"]);
                            }
                        }
                    }
                    catch (Exception) { }
                }
            }
            return user;
        }
        public async Task<bool> IsUsernameExistAsync(string username)
        {
            bool found = false;
            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[usr].[sp_IsUsernameExist]", connection))
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
            }
            return found;
        }
        public async Task<int> AddUserAsync(User user)
        {
            int UserID = -1;

            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[usr].[sp_CreateUser]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@NewID", user.Id);
                    command.Parameters.AddWithValue("@Username", user.UserName);
                    command.Parameters.AddWithValue("@Password", user.HashedPassword);
                    command.Parameters.AddWithValue("@FirstName", user.FirstName);
                    command.Parameters.AddWithValue("@LastName", user.LastName);

                    try
                    {
                        await connection.OpenAsync();
                        object result = await command.ExecuteScalarAsync();
                        if (result != null && int.TryParse(result.ToString(), out int insertedID))
                        {
                            UserID = insertedID;
                            user.Id = UserID;
                        }
                    }
                    catch (Exception)
                    {
                        return UserID;
                    }
                }
                return UserID;
            }
        }
    }
}
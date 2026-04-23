using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Tags;
using SpendWise.Domain.Entities;
using SpendWise.Infrastructure.Global; // Applied Global Exception Handler
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Repositories
{
    public class TagRepository : ITagRepository
    {
        private readonly string _connectionString;

        public TagRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                                            ?? throw new ArgumentNullException("Connection string is missing in appsettings.");
        }

        public async Task<int> AddTagAsync(Tag NewTag)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Config].[sp_CreateTag]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                // Removed @NewID because SQL auto-generates it!
                command.Parameters.AddWithValue("@UserID", NewTag.OwnerId);
                command.Parameters.AddWithValue("@Name", NewTag.Label);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                return result != null && int.TryParse(result.ToString(), out int insertedID) ? insertedID : -1;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex); // Centralized Exception Handling
                throw;
            }
        }

        public async Task<bool> UpdateTagAsync(Tag UpdatedTag)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Config].[sp_UpdateTag]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@Name", UpdatedTag.Label);
                command.Parameters.AddWithValue("@TagID", UpdatedTag.Id);
                command.Parameters.AddWithValue("@UserID", UpdatedTag.OwnerId);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                // Clean, one-line evaluation
                return result != null && int.TryParse(result.ToString(), out int rowsAffected) && rowsAffected > 0;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        // Added userId parameter for IDOR security!
        public async Task<bool> DeleteTagAsync(int TagID, int userId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Config].[sp_DeleteTag]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@TagID", TagID);
                command.Parameters.AddWithValue("@UserID", userId);

                await connection.OpenAsync();
                var result = await command.ExecuteScalarAsync();

                // Clean, one-line evaluation
                return result != null && int.TryParse(result.ToString(), out int rowsAffected) && rowsAffected > 0;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<Tag> GetTagAsync(int TagID, int userId)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Config].[sp_GetTag]", connection)
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@TagID", TagID);
                command.Parameters.AddWithValue("@UserID", userId); 

                await connection.OpenAsync();
                using SqlDataReader reader = await command.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    return new Tag(
                        (int)reader["TagID"],
                        (int)reader["UserID"],
                        (string)reader["Name"]
                    );
                }

                return null!;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }

        public async Task<IEnumerable<Tag?>> GetTagsByUserIdAsync(int UserID)
        {
            var tags = new List<Tag?>();

            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("[Config].[sp_GetTags]", connection) 
                {
                    CommandType = CommandType.StoredProcedure
                };

                command.Parameters.AddWithValue("@UserID", UserID);

                await connection.OpenAsync();
                using SqlDataReader reader = await command.ExecuteReaderAsync();

                while (await reader.ReadAsync())
                {
                    tags.Add(new Tag(
                        (int)reader["TagID"],
                        (int)reader["UserID"],
                        (string)reader["Name"]
                    ));
                }

                return tags;
            }
            catch (SqlException ex)
            {
                SqlExceptionHandler.Handle(ex);
                throw;
            }
        }
    }
}

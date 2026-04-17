using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Tags;
using SpendWise.Domain.Entities;
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
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("[Config].[sp_CreateTag]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@UserID", NewTag.OwnerId);
            command.Parameters.AddWithValue("@Name", NewTag.Label);

            try
            {
                await connection.OpenAsync();
                object result = await command.ExecuteScalarAsync();

                if (result != null && int.TryParse(result.ToString(), out int insertedID))
                {
                    NewTag.Id = insertedID;
                    return insertedID;
                }

                return -1; // Fallback if the SP fails to return the ID but doesn't throw a SQL exception
            }
            catch (SqlException ex)
            {
                HandleSqlException(ex);
                throw; // Satisfies the compiler, though HandleSqlException will throw first
            }
        }

        public async Task<bool> UpdateTagAsync(Tag UpdatedTag)
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("[Config].[sp_UpdateTag]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@Name", UpdatedTag.Label);
            command.Parameters.AddWithValue("@TagID", UpdatedTag.Id);
            command.Parameters.AddWithValue("@UserID", UpdatedTag.OwnerId);

            try
            {
                await connection.OpenAsync();
                int rowsAffected = await command.ExecuteNonQueryAsync();
                return rowsAffected > 0;
            }
            catch (SqlException ex)
            {
                HandleSqlException(ex);
                throw;
            }
        }

        public async Task<bool> DeleteTagAsync(int TagID)
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("[Config].[sp_DeleteTag]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@TagID", TagID);

            try
            {
                await connection.OpenAsync();
                int rowsAffected = await command.ExecuteNonQueryAsync();
                return rowsAffected > 0;
            }
            catch (SqlException ex)
            {
                HandleSqlException(ex);
                throw;
            }
        }

        public async Task<Tag> GetTagAsync(int TagID, int userId)
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("[Config].[sp_GetTag]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@TagID", TagID);

            try
            {
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

                return null;
            }
            catch (SqlException ex)
            {
                HandleSqlException(ex);
                throw;
            }
        }

        public async Task<IEnumerable<Tag?>> GetTagsByUserIdAsync(int UserID)
        {
            var tags = new List<Tag?>();

            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("[Config].[sp_GetTags]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@UserID", UserID);

            try
            {
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
                HandleSqlException(ex);
                throw;
            }
        }

        // ── Helper Method for Mapping SQL Exceptions ─────────────────────────
        private void HandleSqlException(SqlException ex)
        {
            switch (ex.Number)
            {
        // --- Custom Stored Procedure Errors ---
        
        case 50001:
            // Custom duplicate tag error
            throw new DuplicateResourceException(ex.Message); 
            
        case 50002: // Update failed (Not found / No permission)
        case 50003: // Delete failed (Not found / Already deleted)
        case 50004: // Get failed (Not found)
            // Assuming you have a custom exception for missing records. 
            // If not, you can use the standard KeyNotFoundException.
            throw new ResourceNotFoundException(ex.Message); 

        // --- Standard SQL Server Errors ---
        
        case 2601: // Unique Index Violation
        case 2627: // Unique Constraint Violation
            // Fallback just in case a unique constraint catches it before our IF EXISTS
            throw new DuplicateResourceException("A tag with this name already exists.");
            
        case 547: // Foreign Key Constraint Violation
            throw new InvalidReferenceException("A related record is missing, or this tag is currently linked to existing transactions and cannot be modified or deleted.");
            
        case -2: // Timeout
            throw new TimeoutException("The database took too long to respond. Please try again.");
            
        default:
            // Let the global handler catch this as a standard 500 Internal Server Error
            throw new Exception($"An unexpected database error occurred. Code: {ex.Number}", ex);
            }
        }
    }
}

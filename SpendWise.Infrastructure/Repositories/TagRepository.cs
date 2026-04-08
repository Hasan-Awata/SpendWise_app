using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using SpendWise.Application.Interfaces.Tags;
using SpendWise.Domain.Entities;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using static System.Net.Mime.MediaTypeNames;

namespace SpendWise.Infrastructure.Repositories
{
    public class TagRepository : ITagRepository
    {
        public async Task<int> AddTagAsync(Tag NewTag)
        {
            int TagID = -1;

            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[cfg].[sp_CreateTag]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@NewID", NewTag.Id);
                    command.Parameters.AddWithValue("@UserID", NewTag.OwnerId);
                    command.Parameters.AddWithValue("@Name", NewTag.Label);

                    try
                    {
                        await connection.OpenAsync();
                        object result = await command.ExecuteScalarAsync();
                        if (result != null && int.TryParse(result.ToString(), out int insertedID))
                        {
                            TagID = insertedID;
                            NewTag.Id = TagID;
                        }
                    }
                    catch (Exception)
                    {
                        return TagID;
                    }
                }
                return TagID;
            }
        }

        public async Task<bool> UpdateTagAsync(Tag UpdatedTag)
        {
            int rowsAffected = 0;
            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[cfg].[sp_UpdateTag]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@Name", UpdatedTag.Label);
                    command.Parameters.AddWithValue("@TagID", UpdatedTag.Id);
                    command.Parameters.AddWithValue("@UserID", UpdatedTag.OwnerId);

                    try
                    {
                        await connection.OpenAsync();
                        rowsAffected = await command.ExecuteNonQueryAsync();
                    }
                    catch (Exception)
                    {
                        return false;
                    }
                }
            }
            return (rowsAffected > 0);
        }

        public async Task<bool> DeleteTagAsync(int TagID)
        {
            int rowsAffected = 0;
            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[cfg].[sp_DeleteTag]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TagID", TagID);

                    try
                    {
                        await connection.OpenAsync();
                        rowsAffected = await command.ExecuteNonQueryAsync();
                    }
                    catch (Exception)
                    {
                        return false;
                    }
                }
            }
            return (rowsAffected > 0);
        }

        public async Task<Tag> GetTagAsync(int TagID, int userId)
        {
            Tag tag = null;

            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[cfg].[sp_GetTag]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TagID", TagID);

                    try
                    {
                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                tag = new Tag(
                                    (int)reader["TagID"],
                                    (int)reader["UserID"],
                                    (string)reader["Name"]
                                );
                            }
                        }
                    }
                    catch (Exception) { }
                }
            }
            return tag;
        }

        public async Task<IEnumerable<Tag?>> GetTagsByUserIdAsync(int UserID)
        {
            List<Tag?> tags = new List<Tag?>(); // Fixed initialization

            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[cfg].[sp_GetTagsByUserID]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserID", UserID);

                    try
                    {
                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                Tag? tag = new Tag(
                                    (int)reader["TagID"],
                                    (int)reader["UserID"],
                                    (string)reader["Name"]
                                );
                                tags.Add(tag);
                            }
                        }
                    }
                    catch (Exception)
                    {
                        // Handle exception appropriately based on your needs
                    }
                }
            }

            return tags;
        }
    }
}
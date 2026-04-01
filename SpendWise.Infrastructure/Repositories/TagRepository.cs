using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using SpendWise.Application.Interfaces;
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
        public async Task<bool> AddTagAsync(Tag NewTag)
        {
            int TagID = -1;

            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[cfg].[sp_CreateTag]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@UserID", NewTag.OwnerId);
                    command.Parameters.AddWithValue("@CategoryID", NewTag.CategoryId);
                    command.Parameters.AddWithValue("@Name", NewTag.Label);

                    try
                    {
                        connection.Open();
                        object result = command.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int insertedID))
                        {
                            TagID = insertedID;
                            NewTag.Id = TagID;
                        }
                    }
                    catch (Exception ex) { return false; }
                }
                return true;
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

                    command.Parameters.AddWithValue("@CategoryID", UpdatedTag.CategoryId);
                    command.Parameters.AddWithValue("@Name", UpdatedTag.Label);
                    command.Parameters.AddWithValue("@TagID", UpdatedTag.Id);

                    try
                    {
                        connection.Open();
                        rowsAffected = command.ExecuteNonQuery();
                    }
                    catch (Exception ex) {  return false; }
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
                        connection.Open();
                        rowsAffected = command.ExecuteNonQuery();
                    }
                    catch (Exception ex)
                    {
                        return false;
                    }
                }
            }
            return (rowsAffected > 0);
        }
        public async Task<Tag> GetTagAsync(int TagID)
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
                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                tag = new Tag(
                                    (int)reader["TagID"],
                                    (int)reader["CategoryID"],
                                    (int)reader["UserID"],
                                    (string)reader["Name"]
                                    );
                            }
                        }
                    }
                    catch (Exception ex) { }
                }
            }
            return tag;
        }
        public async Task<IEnumerable<Tag?>> GetTagsByUserIdAsync(int UserID)
        {
            List<Tag?> tags = null;

            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[cfg].[sp_GetTagsByUserID]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserID", UserID);

                    try
                    {
                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                Tag? tag = new Tag((int)reader["TagID"], (int)reader["CategoryID"], (int)reader["UserID"], (string)reader["Name"]);
                                tags.Add(tag);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        
                    }
                }
            }

            return tags;
        }
        public async Task<IEnumerable<Tag?>> GetTagsByCategoryIdAsync(int UserID, int CategoryID)
        {
            List<Tag?> tags = null;

            using (SqlConnection connection = new SqlConnection(DataAccessSettings.ConnectionString))
            {
                using (SqlCommand command = new SqlCommand("[cfg].[sp_GetTagsByCategoryID]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserID", UserID);
                    command.Parameters.AddWithValue("@CategoryID", CategoryID);

                    try
                    {
                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                Tag? tag = new Tag((int)reader["TagID"], (int)reader["CategoryID"], (int)reader["UserID"], (string)reader["Name"]);
                                tags.Add(tag);
                            }
                        }
                    }
                    catch (Exception ex)
                    {

                    }
                }
            }

            return tags;
        }
    }
}

using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.Tags;
using SpendWise.Domain.Entities;
using SpendWise.Infrastructure.Global;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Repositories
{
    public class TagRepository : BaseRepository, ITagRepository
    {
        public TagRepository(IConfiguration configuration)
            : base(configuration.GetConnectionString("DefaultConnection")
                  ?? throw new ArgumentNullException(nameof(configuration), "Connection string is missing in appsettings."))
        { }

        public async Task<int> AddTagAsync(Tag newTag)
        {
            var result = await ExecuteScalarAsync<int>("[Config].[sp_CreateTag]", cmd =>
            {
                cmd.Parameters.AddWithValue("@UserID", newTag.OwnerId);
                cmd.Parameters.AddWithValue("@Name", newTag.Label);
            });

            return result > 0 ? result : -1;
        }

        public async Task<bool> UpdateTagAsync(Tag updatedTag)
        {
            var rowsAffected = await ExecuteNonQueryAsync("[Config].[sp_UpdateTag]", cmd =>
            {
                cmd.Parameters.AddWithValue("@Name", updatedTag.Label);
                cmd.Parameters.AddWithValue("@TagID", updatedTag.Id);
                cmd.Parameters.AddWithValue("@UserID", updatedTag.OwnerId);
            });

            return rowsAffected > 0;
        }

        public async Task<bool> DeleteTagAsync(int tagId, int userId)
        {
            var rowsAffected = await ExecuteScalarAsync<int>("[Config].[sp_DeleteTag]", cmd =>
            {
                cmd.Parameters.AddWithValue("@TagID", tagId);
                cmd.Parameters.AddWithValue("@UserID", userId);
            });

            return rowsAffected > 0;
        }

        public async Task<Tag?> GetTagAsync(int tagId, int userId)
        {
            return await ExecuteReaderSingleAsync("[Config].[sp_GetTag]", cmd =>
            {
                cmd.Parameters.AddWithValue("@TagID", tagId);
                cmd.Parameters.AddWithValue("@UserID", userId);
            }, MapToTag);
        }

        public async Task<IEnumerable<Tag>> GetTagsByUserIdAsync(int userId)
        {
            return await ExecuteReaderAsync("[Config].[sp_GetTags]",
                cmd => cmd.Parameters.AddWithValue("@UserID", userId), MapToTag);
        }

        // =========================================================================
        // REUSABLE HELPER METHODS & MAPPERS
        // =========================================================================
        private static Tag MapToTag(SqlDataReader reader)
        {
            return new Tag(
                EmptyValuesHandler.GetInt32OrDefault(reader, "TagID"),
                EmptyValuesHandler.GetInt32OrDefault(reader, "UserID"),
                EmptyValuesHandler.GetStringOrDefault(reader, "Name")
            );
        }
    }
}
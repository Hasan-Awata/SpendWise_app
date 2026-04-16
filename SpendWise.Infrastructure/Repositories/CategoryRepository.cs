using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using SpendWise.Application.Interfaces.ICategory;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Data;
using System.Formats.Tar;
using System.Text;

namespace SpendWise.Infrastructure.Repositories
{
    public class CategoryRepository :ICategoryRepository
    {
     private readonly string _connectionString;

            public CategoryRepository(IConfiguration configuration)
            {
                _connectionString = configuration.GetConnectionString("DefaultConnection")
                    ?? throw new ArgumentNullException("Connection string is missing in appsettings.");
            }

            public async Task<int> AddCategoryAsync(Category category)
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    using (SqlCommand command = new SqlCommand("[pln].[sp_CreateCategory]", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@Name", category.Name);
                        command.Parameters.AddWithValue("@Priority", category.Priority);

                        await connection.OpenAsync();
                        object result = await command.ExecuteScalarAsync();
                        return result != null ? Convert.ToInt32(result) : -1;
                    }
                }
           
            }

            public async Task<bool> UpdateCategoryAsync(Category category)
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    using (SqlCommand command = new SqlCommand("[pln].[sp_UpdateCategory]", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@CategoryId", category.CategoryId);
                        command.Parameters.AddWithValue("@Name", category.Name);
                        command.Parameters.AddWithValue("@Priority", category.Priority);

                        await connection.OpenAsync();
                        return await command.ExecuteNonQueryAsync() > 0;
                    }
                }
            }

            public async Task<bool> DeleteCategoryAsync(int id)
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    using (SqlCommand command = new SqlCommand("[pln].[sp_DeleteCategory]", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@CategoryId", id);

                        await connection.OpenAsync();
                        return await command.ExecuteNonQueryAsync() > 0;
                    }
                }
            }

            public async Task<Category?> GetCategoryByIdAsync(int id)
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    using (SqlCommand command = new SqlCommand("[pln].[sp_GetCategoryByID]", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@CategoryId", id);

                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                return new Category
                                {
                                    CategoryId = (int)reader["CategoryId"],
                                    Name = (string)reader["Name"],
                                    Priority = (int)reader["Priority"]
                                };
                            }
                        }
                    }
                }
                return null;
            }

            public async Task<IEnumerable<Category>> GetAllCategoriesAsync(int userId)
            {
                var list = new List<Category>();
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    using (SqlCommand command = new SqlCommand("[pln].[sp_GetAllCategories]", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@UserID", userId);

                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                list.Add(new Category
                                {
                                    CategoryId = (int)reader["CategoryId"],
                                    Name = (string)reader["Name"],
                                    Priority = (int)reader["Priority"]
                                });
                            }
                        }
                    }
                }
                return list;
            }

            //public async Task<IEnumerable<Category>> GetCategoriesByNameAsync(string name, int userId)
            //{
            //    List<Category> list = new List<Category>();
            //    using (SqlConnection connection = new SqlConnection(_connectionString))
            //    {
            //        using (SqlCommand command = new SqlCommand("[pln].[sp_SearchCategoriesByName]", connection))
            //        {
            //            command.CommandType = CommandType.StoredProcedure;
            //            command.Parameters.AddWithValue("@Name", name);
            //            command.Parameters.AddWithValue("@UserID", userId);

            //            await connection.OpenAsync();
            //            using (SqlDataReader reader = await command.ExecuteReaderAsync())
            //            {
            //                while (await reader.ReadAsync())
            //                {
            //                    list.Add(new Category
            //                    {
            //                        CategoryId = (int)reader["CategoryId"],
            //                        Name = (string)reader["Name"],
            //                        Priority = (int)reader["Priority"]
            //                    });
            //                }
            //            }
            //        }
            //    }
            //    return list;
            //}

            public async Task<Category?> GetCategoryByNameAsync(string name, int userId)
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    using (SqlCommand command = new SqlCommand("[pln].[sp_GetCategoryByName]", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@Name", name);
                        command.Parameters.AddWithValue("@UserID", userId);

                        await connection.OpenAsync();
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                return new Category
                                {
                                    CategoryId = (int)reader["CategoryId"],
                                    Name = (string)reader["Name"],
                                    Priority = (int)reader["Priority"]
                                };
                            }
                        }
                    }
                }
                return null;
            }


        }
}


using SpendWise.Application.DTOs.Category;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;


    namespace SpendWise.Application.Interfaces.Categorys
    {
        public interface ICategory
        {
            // Create
            public Task<int> AddCategoryAsync(CategoryDTO categoryDto);

            // Update
            public Task<bool> UpdateCategoryAsync(CategoryDTO categoryDto);

            // Delete
            public Task<bool> DeleteCategoryAsync(int id);

            // Search & Get
            public Task<Category?> GetCategoryByIdAsync(int id);
            public Task<IEnumerable<Category>?> GetAllCategoriesAsync(int userId);

            // Search by Name
            public Task<IEnumerable<Category>?> SearchCategoriesByNameAsync(string name, int userId);

        }
    }



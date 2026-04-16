using SpendWise.Application.DTOs.Category;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces
{
    public interface ICategoryService
    {
       public Task<bool> AddCategoryAsync(CategoryDTO categoryDto);

        // Updates an existing category based on the provided DTO
        public Task<bool> UpdateCategoryAsync(CategoryDTO categoryDto);

        // Deletes a category by its unique identifier
        public Task<bool> DeleteCategoryAsync(int id);

        // Retrieves a specific category by its ID
        public Task<Domain.Entities.Category?> GetCategoryByIdAsync(int id);

        // Retrieves all categories associated with a specific user
        public Task<IEnumerable<Domain.Entities.Category>> GetAllCategoriesAsync(int userId);

        // Searches for categories by name for a specific user
        public Task<IEnumerable<Domain.Entities.Category>> SearchCategoriesByNameAsync(string name, int userId);

        // Retrieves a single category by its name for a specific user
        public Task<Domain.Entities.Category?> GetCategoryByNameAsync(string name, int userId);
    }
}

using SpendWise.Application.DTOs.Category;
using SpendWise.Application.Interfaces.CategoryBudget;
using SpendWise.Application.Interfaces.ICategory;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Services
{
    public  class CategoryService: ICategoryService

    {
        private readonly ICategoryRepository _categoryRepo;
        public CategoryService(ICategoryRepository categoryRepo)
        {
            _categoryRepo = categoryRepo;

        }
        public async Task<int> AddCategoryAsync(CategoryDTO categoryDto)
        {
            int  IsDone =-1;
            Category NewCategory =new Category(categoryDto.CategoryId ,categoryDto.Name,categoryDto.Priority);

            IsDone =await _categoryRepo.AddCategoryAsync(NewCategory);
            return IsDone;

        }
        public async Task<bool> UpdateCategoryAsync(CategoryDTO categoryDto)
        {
            bool isDone = false;
            Category NewCategory = new Category(categoryDto.CategoryId, categoryDto.Name, categoryDto.Priority);
            isDone =await _categoryRepo.UpdateCategoryAsync(NewCategory);
            return isDone;
        }
        public async Task<bool> DeleteCategoryAsync(int id)
        {
            bool isDone = false;
            isDone =await _categoryRepo.DeleteCategoryAsync(id);
            return isDone;
        }
    
        public async Task<IEnumerable<CategoryResponse>> GetAllCategoriesAsync(int userId)
        {
            var categoryList = new List<Category>();
           categoryList= (List<Category>)await _categoryRepo.GetAllCategoriesAsync(userId);
            return categoryList.Select(item => new CategoryResponse
            {
                CategoryId = item.CategoryId,
                Name = item.Name,
                Priority = item.Priority
            });

        }
        public  async Task<CategoryResponse?> GetCategoryByNameAsync(string name, int userId)
        {
            var category = new Category();
            category=await _categoryRepo.GetCategoryByNameAsync(name,userId);
            if (category != null)  return new CategoryResponse(category);return  null;

           
           
        }
      
        public async Task<CategoryResponse?> GetCategoryByIdAsync(int id)
        {
            Category category =new Category();
            category =await _categoryRepo.GetCategoryByIdAsync(id);
            if(category != null)
            return new CategoryResponse(category);
            return null;
        }

    }
}

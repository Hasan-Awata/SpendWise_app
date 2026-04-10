using SpendWise.Application.DTOs.Category;
using SpendWise.Application.Interfaces.Categorys;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Services
{
    public  class CategoryService: ICategoryService

    {
        //private readonly ICategoryRepository _categoryRepo;

        public async Task<bool> AddCategoryAsync(CategoryDTO categoryDto)
        {
            bool  IsDone =false;
            Category NewCategory =new Category(categoryDto.CategoryId ,categoryDto.Name,categoryDto.Priority,categoryDto.LimitAmount,categoryDto.Percentage,categoryDto.Month,categoryDto.Year,categoryDto.categoryType);

            //IsDone =await _categoryRepo.AddCategoryAsync(NewCategory);
            return IsDone;

        }
        public async Task<bool> UpdateCategoryAsync(CategoryDTO categoryDto)
        {
            bool isDone = false;
            Category NewCategory = new Category(categoryDto.CategoryId, categoryDto.Name, categoryDto.Priority, categoryDto.LimitAmount, categoryDto.Percentage, categoryDto.Month, categoryDto.Year, categoryDto.categoryType);
            //isDone =await _categoryRepo.UpdateCategoryAsync(NewCategory);
            return isDone;
        }
        public async Task<bool> DeleteCategoryAsync(int id)
        {
            bool isDone = false;
            //isDone =await _categoryRepo.DeleteCategoryAsync(id);
            return isDone;
        }
        public async Task<Category?> GetCategoryByIdAsync(int id)
        {
          Category category = null;
            //category= await _categoryRepo.GetCategoryByIdAsync(id);
            return category;
        }
        public async Task<IEnumerable<Category>> GetAllCategoriesAsync(int userId)
        {
            var categoryList = new List<Category>();
           //categoryList=await _categoryRepo.GetAllCategoriesAsync(userId);
           return categoryList;
             
        }
        public  async Task<IEnumerable<Category>> SearchCategoriesByNameAsync(string name, int userId)
        {
            var categoryList = new List<Category>();
            //categoryList=await _categoryRepo.SearchCategoriesByNameAsync(userId);
            return categoryList;
        }
      
        public async Task<Category?> GetCategoryByNameAsync(string name, int userId)
        {
            Category category =null;
            //category =await _categoryRepo.GetCategoryByNameAsync(name,userId);
            return category;

        }

    }
}

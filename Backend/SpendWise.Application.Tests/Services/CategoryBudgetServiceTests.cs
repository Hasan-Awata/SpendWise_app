using Moq;
using SpendWise.Application.Services;
using SpendWise.Application.Interfaces.Categories;
using SpendWise.Application.DTOs.Category;
using SpendWise.Domain.Common;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Constants;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Xunit;

namespace SpendWise.Application.Tests.Services
{
    public class CategoryBudgetServiceTests
    {
        private readonly Mock<ICategoryBudgetRepository> _repo = new();
        private CategoryBudgetService CreateService() => new CategoryBudgetService(_repo.Object);

        private static CategoryBudgetDTO BuildDto(int categoryId = 1, decimal percent = 10m)
            => new CategoryBudgetDTO { CategoryBudgetId = -1, UserId = 30, CategoryId = categoryId, PercentageLimit = percent, StartDate = DateTime.UtcNow.Date, EndDate = DateTime.UtcNow.Date.AddDays(10), IsActive = true };

        [Fact]
        public async Task GetAllUserBudgets_ReturnsEmptyWhenNone()
        {
            var svc = CreateService();
            _repo.Setup(x => x.GetAllUserBudgetsAsync(30)).ReturnsAsync(new List<CategoryBudget>());

            var res = await svc.GetAllUserBudgetsAsync(30);
            Assert.True(res.IsSuccess);
            Assert.Empty(res.Value!);
        }

        [Fact]
        public async Task GetCategoryBudget_NotFound_ReturnsNotFound()
        {
            var svc = CreateService();
            _repo.Setup(x => x.GetCategoryBudgetAsync(30, 5)).ReturnsAsync((CategoryBudget?)null);

            var res = await svc.GetCategoryBudgetAsync(30, 5);
            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.NotFound, res.ErrorType);
        }

        [Fact]
        public async Task SetCategoryBudget_InvalidCategory_ReturnsValidation()
        {
            var svc = CreateService();
            var dto = BuildDto(categoryId: 999);

            var res = await svc.SetCategoryBudgetAsync(dto);
            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Validation, res.ErrorType);
        }

        [Fact]
        public async Task SetCategoryBudget_InvalidPercentOrDates_ReturnsValidation()
        {
            var svc = CreateService();
            var dto = BuildDto(percent: 0m);
            var res = await svc.SetCategoryBudgetAsync(dto);
            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Validation, res.ErrorType);

            dto = BuildDto();
            dto.StartDate = DateTime.UtcNow.Date.AddDays(5);
            dto.EndDate = DateTime.UtcNow.Date;
            var res2 = await svc.SetCategoryBudgetAsync(dto);
            Assert.False(res2.IsSuccess);
            Assert.Equal(enErrorType.Validation, res2.ErrorType);
        }

        [Fact]
        public async Task SetCategoryBudget_RepositoryFails_ReturnsFailure()
        {
            var svc = CreateService();
            var dto = BuildDto();
            _repo.Setup(x => x.SetCategoryBudgetAsync(dto.UserId, It.IsAny<CategoryBudget>())).ReturnsAsync(-1);

            var res = await svc.SetCategoryBudgetAsync(dto);
            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Failure, res.ErrorType);
        }

        [Fact]
        public async Task SetCategoryBudget_Success_ReturnsCreatedBudget()
        {
            var svc = CreateService();
            var dto = BuildDto();
            _repo.Setup(x => x.SetCategoryBudgetAsync(dto.UserId, It.IsAny<CategoryBudget>())).ReturnsAsync(123);

            var res = await svc.SetCategoryBudgetAsync(dto);
            Assert.True(res.IsSuccess);
            Assert.Equal(123, res.Value!.CategoryBudgetId);
        }

        [Fact]
        public async Task UpdateCategoryBudget_ValidationFailures()
        {
            var svc = CreateService();
            var dto = BuildDto(categoryId: 999);
            var res = await svc.UpdateCategoryBudgetAsync(dto);
            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Validation, res.ErrorType);
        }

        [Fact]
        public async Task UpdateCategoryBudget_NotFound_ReturnsNotFound()
        {
            var svc = CreateService();
            var dto = BuildDto();
            _repo.Setup(x => x.GetCategoryBudgetAsync(dto.UserId, dto.CategoryId)).ReturnsAsync((CategoryBudget?)null);

            var res = await svc.UpdateCategoryBudgetAsync(dto);
            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.NotFound, res.ErrorType);
            _repo.Verify(x => x.UpdateCategoryBudgetAsync(It.IsAny<CategoryBudget>()), Times.Never);
        }

        [Fact]
        public async Task UpdateCategoryBudget_RepoFails_ReturnsFailure()
        {
            var svc = CreateService();
            var dto = BuildDto();
            var existing = new CategoryBudget { CategoryBudgetId = 5, UserId = dto.UserId, CategoryId = dto.CategoryId, PercentageLimit = dto.PercentageLimit, PercentageProgress = 0, StartDate = dto.StartDate, EndDate = dto.EndDate, IsActive = dto.IsActive };
            _repo.Setup(x => x.GetCategoryBudgetAsync(dto.UserId, dto.CategoryId)).ReturnsAsync(existing);
            _repo.Setup(x => x.UpdateCategoryBudgetAsync(It.IsAny<CategoryBudget>())).ReturnsAsync(false);

            var res = await svc.UpdateCategoryBudgetAsync(dto);
            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Failure, res.ErrorType);
        }

        [Fact]
        public async Task UpdateCategoryBudget_Success_ReturnsUpdated()
        {
            var svc = CreateService();
            var dto = BuildDto();
            var existing = new CategoryBudget { CategoryBudgetId = 7, UserId = dto.UserId, CategoryId = dto.CategoryId, PercentageLimit = dto.PercentageLimit, PercentageProgress = 0, StartDate = dto.StartDate, EndDate = dto.EndDate, IsActive = dto.IsActive };
            _repo.Setup(x => x.GetCategoryBudgetAsync(dto.UserId, dto.CategoryId)).ReturnsAsync(existing);
            _repo.Setup(x => x.UpdateCategoryBudgetAsync(It.IsAny<CategoryBudget>())).ReturnsAsync(true);

            var res = await svc.UpdateCategoryBudgetAsync(dto);
            Assert.True(res.IsSuccess);
            Assert.Equal(dto.CategoryId, res.Value!.CategoryId);
        }

        [Fact]
        public async Task DeleteCategoryBudget_SuccessAndFailure()
        {
            var svc = CreateService();
            _repo.Setup(x => x.DeleteCategoryBudgetAsync(30, 1)).ReturnsAsync(true);
            var s = await svc.DeleteCategoryBudgetAsync(30, 1);
            Assert.True(s.IsSuccess);

            _repo.Setup(x => x.DeleteCategoryBudgetAsync(30, 2)).ReturnsAsync(false);
            var f = await svc.DeleteCategoryBudgetAsync(30, 2);
            Assert.False(f.IsSuccess);
            Assert.Equal(enErrorType.Failure, f.ErrorType);
        }
    }
}

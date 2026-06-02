using Moq;
using SpendWise.Application.Services;
using SpendWise.Application.Interfaces.Expenses;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Application.Interfaces.ExchangeRate;
using SpendWise.Application.DTOs.Expense;
using System.Linq;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using SpendWise.Domain.Constants;
using SpendWise.Domain.Common;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Xunit;

namespace SpendWise.Application.Tests.Services
{
    public class ExpenseServiceTests
    {
        private readonly Mock<IExpenseRepository> _expenseRepo = new();
        private readonly Mock<IWalletRepository> _walletRepo = new();
        private readonly Mock<IExchangeRateService> _exchange = new();

        private ExpenseService CreateService() => new ExpenseService(_expenseRepo.Object, _walletRepo.Object, _exchange.Object);

        private static ExpenseDTO BuildDto(decimal amount, int categoryId = 1)
        {
            return new ExpenseDTO
            {
                ExpenseId = -1,
                UserId = 10,
                Title = "T",
                WalletId = 100,
                CategoryId = categoryId,
                Amount = amount,
                Date = DateTime.UtcNow,
                Products = new List<ProductDTO> { new ProductDTO { Name = "A", Quantity = 1, Price = amount } }
            };
        }

        private static List<Wallet> BuildWalletPair(decimal primaryBalance, decimal savingBalance, int currencyId = SupportedCurrencies.SyrianPoundId)
        {
            return new List<Wallet>
            {
                new Wallet(1, currencyId, primaryBalance, 10, false),
                new Wallet(2, currencyId, savingBalance, 10, true)
            };
        }

        [Fact]
        public async Task AddExpense_InvalidAmount_ReturnsValidationFailure()
        {
            var svc = CreateService();
            var dto = BuildDto(0m);

            var res = await svc.AddExpenseAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Validation, res.ErrorType);
        }

        [Fact]
        public async Task AddExpense_InvalidCategory_ReturnsValidationFailure()
        {
            var svc = CreateService();
            var dto = BuildDto(10m, categoryId: 999);

            var res = await svc.AddExpenseAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Validation, res.ErrorType);
        }

        [Fact]
        public async Task AddExpense_EmptyProducts_ReturnsValidationFailure()
        {
            var svc = CreateService();
            var dto = BuildDto(10m);
            dto.Products.Clear();

            var res = await svc.AddExpenseAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Validation, res.ErrorType);
        }

        [Fact]
        public async Task AddExpense_ProductPriceMismatch_ReturnsBalanceViolation()
        {
            var svc = CreateService();
            var dto = BuildDto(100m);
            // product total is 100 but amount is 200
            dto.Products = new List<ProductDTO> { new ProductDTO { Name = "X", Quantity = 1, Price = 100m } };
            dto.Amount = 200m;

            var res = await svc.AddExpenseAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.BalanceViolation, res.ErrorType);
        }

        [Fact]
        public async Task AddExpense_MissingWalletPair_ReturnsNotFound()
        {
            var svc = CreateService();
            var dto = BuildDto(10m);

            _walletRepo.Setup(x => x.GetUserWalletsPairAsync(dto.UserId, dto.WalletId))
                .ReturnsAsync(new List<Wallet>());

            var res = await svc.AddExpenseAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.NotFound, res.ErrorType);
        }

        [Fact]
        public async Task AddExpense_InsufficientCombinedFunds_ReturnsBalanceViolation()
        {
            var svc = CreateService();
            var dto = BuildDto(100m);

            _walletRepo.Setup(x => x.GetUserWalletsPairAsync(dto.UserId, dto.WalletId))
                .ReturnsAsync(BuildWalletPair(30m, 20m));

            var res = await svc.AddExpenseAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.BalanceViolation, res.ErrorType);
        }

        [Fact]
        public async Task AddExpense_ExchangeNormalizationFails_ReturnsFailure()
        {
            var svc = CreateService();
            var dto = BuildDto(50m);

            _walletRepo.Setup(x => x.GetUserWalletsPairAsync(dto.UserId, dto.WalletId))
                .ReturnsAsync(BuildWalletPair(100m, 0m, currencyId: 2));

            _exchange.Setup(x => x.NormalizeToSyrianPound(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(), It.IsAny<decimal>()))
                .ReturnsAsync(0m);

            var res = await svc.AddExpenseAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Failure, res.ErrorType);
        }

        [Fact]
        public async Task AddExpense_RepositoryAddFails_ReturnsFailure()
        {
            var svc = CreateService();
            var dto = BuildDto(25m);

            _walletRepo.Setup(x => x.GetUserWalletsPairAsync(dto.UserId, dto.WalletId))
                .ReturnsAsync(BuildWalletPair(100m, 0m));

            _exchange.Setup(x => x.NormalizeToSyrianPound(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(), It.IsAny<decimal>()))
                .ReturnsAsync(2500m);

            _expenseRepo.Setup(x => x.AddExpenseAsync(It.IsAny<Expense>()))
                .ReturnsAsync((-1, false));

            var res = await svc.AddExpenseAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Failure, res.ErrorType);
        }

        [Fact]
        public async Task AddExpense_SuccessFromPrimaryWallet_ReturnsSuccessResponse()
        {
            var svc = CreateService();
            var dto = BuildDto(30m);

            _walletRepo.Setup(x => x.GetUserWalletsPairAsync(dto.UserId, dto.WalletId))
                .ReturnsAsync(BuildWalletPair(100m, 50m, currencyId: 1));

            _exchange.Setup(x => x.NormalizeToSyrianPound("SYP", "damascus", "sell", dto.Amount))
                .ReturnsAsync(30m);

            _expenseRepo.Setup(x => x.AddExpenseAsync(It.IsAny<Expense>()))
                .ReturnsAsync((42, false));

            var res = await svc.AddExpenseAsync(dto);

            Assert.True(res.IsSuccess);
            Assert.Equal(42, res.Value!.ExpenseId);
            Assert.False(res.Value.IsOverLimit);
            Assert.Equal(1, res.Value.CurrencyId);
        }

        [Fact]
        public async Task AddExpense_SuccessUsingBothWallets_ReturnsSuccessResponse()
        {
            var svc = CreateService();
            var dto = BuildDto(100m);

            _walletRepo.Setup(x => x.GetUserWalletsPairAsync(dto.UserId, dto.WalletId))
                .ReturnsAsync(BuildWalletPair(60m, 50m, currencyId: 1));

            _exchange.Setup(x => x.NormalizeToSyrianPound("SYP", "damascus", "sell", dto.Amount))
                .ReturnsAsync(100m);

            _expenseRepo.Setup(x => x.AddExpenseUsingBothWalletsAsync(It.IsAny<Expense>(), It.IsAny<int>(), It.IsAny<int>(), It.IsAny<decimal>(), It.IsAny<decimal>()))
                .ReturnsAsync((99, true));

            var res = await svc.AddExpenseAsync(dto);

            Assert.True(res.IsSuccess);
            Assert.Equal(99, res.Value!.ExpenseId);
            Assert.True(res.Value.IsOverLimit);
        }

        [Fact]
        public async Task UpdateExpense_InvalidAmount_ReturnsValidationFailure()
        {
            var svc = CreateService();
            var dto = BuildDto(0m);

            var res = await svc.UpdateExpenseAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Validation, res.ErrorType);
        }

        [Fact]
        public async Task UpdateExpense_WalletPairMissing_ReturnsNotFound()
        {
            var svc = CreateService();
            var dto = BuildDto(10m);

            _walletRepo.Setup(x => x.GetUserWalletsPairAsync(dto.UserId, dto.WalletId))
                .ReturnsAsync(new List<Wallet>());

            var res = await svc.UpdateExpenseAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.NotFound, res.ErrorType);
        }

        [Fact]
        public async Task UpdateExpense_ExchangeNormalizationFails_ReturnsFailure()
        {
            var svc = CreateService();
            var dto = BuildDto(15m);

            _walletRepo.Setup(x => x.GetUserWalletsPairAsync(dto.UserId, dto.WalletId))
                .ReturnsAsync(BuildWalletPair(100m, 0m, currencyId: 2));

            _exchange.Setup(x => x.NormalizeToSyrianPound(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(), It.IsAny<decimal>()))
                .ReturnsAsync(0m);

            var res = await svc.UpdateExpenseAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Failure, res.ErrorType);
        }

        [Fact]
        public async Task UpdateExpense_RepositoryFails_ReturnsFailure()
        {
            var svc = CreateService();
            var dto = BuildDto(20m);

            _walletRepo.Setup(x => x.GetUserWalletsPairAsync(dto.UserId, dto.WalletId))
                .ReturnsAsync(BuildWalletPair(100m, 0m));

            _exchange.Setup(x => x.NormalizeToSyrianPound(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(), It.IsAny<decimal>()))
                .ReturnsAsync(20m);

            _expenseRepo.Setup(x => x.UpdateExpenseUsingBothWalletsAsync(It.IsAny<Expense>(), It.IsAny<int>(), It.IsAny<decimal>(), It.IsAny<decimal>()))
                .ReturnsAsync((false, false));

            var res = await svc.UpdateExpenseAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Failure, res.ErrorType);
        }

        [Fact]
        public async Task UpdateExpense_Success_ReturnsSuccessResponse()
        {
            var svc = CreateService();
            var dto = BuildDto(40m);

            _walletRepo.Setup(x => x.GetUserWalletsPairAsync(dto.UserId, dto.WalletId))
                .ReturnsAsync(BuildWalletPair(100m, 0m, currencyId: 1));

            _exchange.Setup(x => x.NormalizeToSyrianPound("SYP", "damascus", "sell", dto.Amount))
                .ReturnsAsync(40m);

            _expenseRepo.Setup(x => x.UpdateExpenseUsingBothWalletsAsync(It.IsAny<Expense>(), It.IsAny<int>(), It.IsAny<decimal>(), It.IsAny<decimal>()))
                .ReturnsAsync((true, false));

            var res = await svc.UpdateExpenseAsync(dto);

            Assert.True(res.IsSuccess);
            Assert.Equal(enErrorType.None, res.ErrorType);
            Assert.Equal(dto.Amount, res.Value!.Amount);
        }

        [Fact]
        public async Task DeleteExpense_SuccessAndFailurePaths()
        {
            var svc = CreateService();

            _expenseRepo.Setup(x => x.DeleteExpenseAsync(1, 10)).ReturnsAsync(true);
            var success = await svc.DeleteExpenseAsync(1, 10);
            Assert.True(success.IsSuccess);

            _expenseRepo.Setup(x => x.DeleteExpenseAsync(2, 10)).ReturnsAsync(false);
            var fail = await svc.DeleteExpenseAsync(2, 10);
            Assert.False(fail.IsSuccess);
            Assert.Equal(enErrorType.Failure, fail.ErrorType);
        }

        [Fact]
        public async Task GetExpense_NotFoundAndFound()
        {
            var svc = CreateService();

            _expenseRepo.Setup(x => x.GetExpenseAsync(999, 10)).ReturnsAsync((Expense?)null);
            var nf = await svc.GetExpenseAsync(999, 10);
            Assert.False(nf.IsSuccess);
            Assert.Equal(enErrorType.NotFound, nf.ErrorType);

            var e = new Expense { ExpenseId = 5, UserId = 10, Title = "X", Amount = 5m, WalletId = 1, CategoryId = 1, ExpenseTagId = -1, Products = "[]", Date = DateTime.UtcNow, LinkedTransaction = new Transaction(5,10,"X","",1,5m,5m,DateTime.UtcNow,enTransactionType.Dedduction,-1,-1,-1,-1) };
            _expenseRepo.Setup(x => x.GetExpenseAsync(5, 10)).ReturnsAsync(e);
            var found = await svc.GetExpenseAsync(5, 10);
            Assert.True(found.IsSuccess);
            Assert.Equal(5, found.Value!.ExpenseId);
        }

        [Fact]
        public async Task GetExpensesByUser_ReturnsPagedResponse()
        {
            var svc = CreateService();
            var page = new SpendWise.Application.DTOs.Paged.PageDTO { PageNumber = 1, PageSize = 10 };

            var list = new List<Expense> { new Expense { ExpenseId = 1, UserId = 10, Title = "A", Amount = 1m, WalletId = 1, CategoryId = 1, ExpenseTagId = -1, Products = "[]", Date = DateTime.UtcNow, LinkedTransaction = new Transaction() } };
            _expenseRepo.Setup(x => x.GetExpensesByUserAsync(10, page.PageNumber, page.PageSize)).ReturnsAsync((list, 1));

            var res = await svc.GetExpenseByUserAsync(10, page);
            Assert.True(res.IsSuccess);
            Assert.Equal(1, res.Value!.Data.Count());
        }
    }
}

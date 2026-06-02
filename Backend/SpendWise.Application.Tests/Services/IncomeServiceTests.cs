using Moq;
using SpendWise.Application.Services;
using SpendWise.Application.Interfaces.Incomes;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Application.Interfaces.ExchangeRate;
using SpendWise.Application.DTOs.Income;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using SpendWise.Domain.Constants;
using SpendWise.Domain.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Xunit;

namespace SpendWise.Application.Tests.Services
{
    public class IncomeServiceTests
    {
        private readonly Mock<IIncomeRepository> _incomeRepo = new();
        private readonly Mock<IWalletRepository> _walletRepo = new();
        private readonly Mock<IExchangeRateService> _exchange = new();

        private IncomeService CreateService() => new IncomeService(_incomeRepo.Object, _walletRepo.Object, _exchange.Object);

        private static IncomeDTO BuildDto(decimal amount, int walletId = 1)
        {
            return new IncomeDTO
            {
                Id = -1,
                UserId = 20,
                Title = "I",
                WalletId = walletId,
                Amount = amount,
                Date = DateTime.UtcNow,
                IncomeTagId = -1,
                Description = string.Empty
            };
        }

        private static Wallet BuildWallet(int walletId, decimal balance = 0m, int currencyId = SupportedCurrencies.SyrianPoundId)
            => new Wallet(walletId, currencyId, balance, 20, false);

        [Fact]
        public async Task AddIncome_InvalidAmount_ReturnsValidationFailure()
        {
            var svc = CreateService();
            var dto = BuildDto(0m);

            var res = await svc.AddIncomeAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Validation, res.ErrorType);
        }

        [Fact]
        public async Task AddIncome_WalletNotFound_ReturnsNotFound()
        {
            var svc = CreateService();
            var dto = BuildDto(10m);

            _walletRepo.Setup(x => x.GetWalletByIdAsync(dto.WalletId, dto.UserId)).ReturnsAsync((Wallet?)null);

            var res = await svc.AddIncomeAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.NotFound, res.ErrorType);
        }

        [Fact]
        public async Task AddIncome_RepositoryFails_ReturnsFailure()
        {
            var svc = CreateService();
            var dto = BuildDto(15m);
            var wallet = BuildWallet(dto.WalletId, currencyId: SupportedCurrencies.SyrianPoundId);

            _walletRepo.Setup(x => x.GetWalletByIdAsync(dto.WalletId, dto.UserId)).ReturnsAsync(wallet);
            _incomeRepo.Setup(x => x.AddIncomeAsync(It.IsAny<Income>())).ReturnsAsync(-1);

            var res = await svc.AddIncomeAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Failure, res.ErrorType);
        }

        [Fact]
        public async Task AddIncome_Success_SyrianPound_CurrencyIdSet()
        {
            var svc = CreateService();
            var dto = BuildDto(40m);
            var wallet = BuildWallet(dto.WalletId, currencyId: SupportedCurrencies.SyrianPoundId);

            _walletRepo.Setup(x => x.GetWalletByIdAsync(dto.WalletId, dto.UserId)).ReturnsAsync(wallet);
            _incomeRepo.Setup(x => x.AddIncomeAsync(It.IsAny<Income>())).ReturnsAsync(55);

            var res = await svc.AddIncomeAsync(dto);

            Assert.True(res.IsSuccess);
            Assert.Equal(55, res.Value!.Id);
            Assert.Equal(SupportedCurrencies.SyrianPoundId, res.Value.CurrencyId);
        }

        [Fact]
        public async Task AddIncome_Success_NonSyrianPound_UsesExchangeRate()
        {
            var svc = CreateService();
            var dto = BuildDto(10m, walletId: 2);
            var wallet = BuildWallet(2, currencyId: 2); // USD id in SupportedCurrencies

            _walletRepo.Setup(x => x.GetWalletByIdAsync(dto.WalletId, dto.UserId)).ReturnsAsync(wallet);
            _exchange.Setup(x => x.NormalizeToSyrianPound(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(), dto.Amount)).ReturnsAsync(250m);
            _incomeRepo.Setup(x => x.AddIncomeAsync(It.IsAny<Income>())).ReturnsAsync(77);

            var res = await svc.AddIncomeAsync(dto);

            Assert.True(res.IsSuccess);
            Assert.Equal(77, res.Value!.Id);
            Assert.Equal(2, res.Value.CurrencyId);
            Assert.Equal(250m, res.Value.AmountInSp);
        }

        [Fact]
        public async Task UpdateIncome_InvalidAmount_ReturnsValidationFailure()
        {
            var svc = CreateService();
            var dto = BuildDto(0m);

            var res = await svc.UpdateIncomeAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Validation, res.ErrorType);
        }

        [Fact]
        public async Task UpdateIncome_WalletNotFound_ReturnsNotFound()
        {
            var svc = CreateService();
            var dto = BuildDto(5m);

            _walletRepo.Setup(x => x.GetWalletByIdAsync(dto.WalletId, dto.UserId)).ReturnsAsync((Wallet?)null);

            var res = await svc.UpdateIncomeAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.NotFound, res.ErrorType);
        }

        [Fact]
        public async Task UpdateIncome_RepositoryFails_ReturnsFailure()
        {
            var svc = CreateService();
            var dto = BuildDto(12m);
            var wallet = BuildWallet(dto.WalletId, currencyId: 1);

            _walletRepo.Setup(x => x.GetWalletByIdAsync(dto.WalletId, dto.UserId)).ReturnsAsync(wallet);
            _incomeRepo.Setup(x => x.UpdateIncomeAsync(It.IsAny<Income>())).ReturnsAsync(false);

            var res = await svc.UpdateIncomeAsync(dto);

            Assert.False(res.IsSuccess);
            Assert.Equal(enErrorType.Failure, res.ErrorType);
        }

        [Fact]
        public async Task UpdateIncome_Success_ReturnsSuccessResponse()
        {
            var svc = CreateService();
            var dto = BuildDto(18m);
            var wallet = BuildWallet(dto.WalletId, currencyId: 1);

            _walletRepo.Setup(x => x.GetWalletByIdAsync(dto.WalletId, dto.UserId)).ReturnsAsync(wallet);
            _incomeRepo.Setup(x => x.UpdateIncomeAsync(It.IsAny<Income>())).ReturnsAsync(true);

            var res = await svc.UpdateIncomeAsync(dto);

            Assert.True(res.IsSuccess);
            Assert.Equal(enErrorType.None, res.ErrorType);
            Assert.Equal(dto.Amount, res.Value!.Amount);
        }

        [Fact]
        public async Task DeleteIncome_SuccessAndFailurePaths()
        {
            var svc = CreateService();

            _incomeRepo.Setup(x => x.DeleteIncomeAsync(1, 20)).ReturnsAsync(true);
            var success = await svc.DeleteIncomeAsync(1, 20);
            Assert.True(success.IsSuccess);

            _incomeRepo.Setup(x => x.DeleteIncomeAsync(2, 20)).ReturnsAsync(false);
            var fail = await svc.DeleteIncomeAsync(2, 20);
            Assert.False(fail.IsSuccess);
            Assert.Equal(enErrorType.Failure, fail.ErrorType);
        }

        [Fact]
        public async Task GetIncome_NotFoundAndFound()
        {
            var svc = CreateService();

            _incomeRepo.Setup(x => x.GetIncomeAsync(999, 20)).ReturnsAsync((Income?)null);
            var nf = await svc.GetIncomeAsync(999, 20);
            Assert.False(nf.IsSuccess);
            Assert.Equal(enErrorType.NotFound, nf.ErrorType);

            var income = new Income { Id = 7, UserId = 20, Title = "T", Amount = 7m, WalletId = 1, IncomeTagId = -1, Date = DateTime.UtcNow, LinkedTransaction = new Transaction() };
            _incomeRepo.Setup(x => x.GetIncomeAsync(7, 20)).ReturnsAsync(income);
            var found = await svc.GetIncomeAsync(7, 20);
            Assert.True(found.IsSuccess);
            Assert.Equal(7, found.Value!.Id);
        }

        [Fact]
        public async Task GetIncomeByUser_ReturnsPagedResponse()
        {
            var svc = CreateService();
            var page = new SpendWise.Application.DTOs.Paged.PageDTO { PageNumber = 1, PageSize = 10 };

            var list = new List<Income> { new Income { Id = 1, UserId = 20, Title = "A", Amount = 1m, WalletId = 1, IncomeTagId = -1, Date = DateTime.UtcNow, LinkedTransaction = new Transaction() } };
            _incomeRepo.Setup(x => x.GetIncomeByUserAsync(20, page.PageNumber, page.PageSize)).ReturnsAsync((list, 1));

            var res = await svc.GetIncomeByUserAsync(20, page);
            Assert.True(res.IsSuccess);
            Assert.Equal(1, res.Value!.Data.Count());
        }
    }
}

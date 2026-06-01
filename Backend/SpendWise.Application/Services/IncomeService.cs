using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.Interfaces.ExchangeRate;
using SpendWise.Application.Interfaces.Incomes;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Domain.Common;
using SpendWise.Domain.Constants;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using SpendWise.Domain.ProcessingResults;
using System.Linq;
using System.Threading.Tasks;

namespace SpendWise.Application.Services
{
    public class IncomeService : IIncomeService
    {
        private readonly IIncomeRepository _incomeRepo;
        private readonly IWalletRepository _walletRepo;
        private readonly IExchangeRateService _exchangeRateService;

        public IncomeService(
            IIncomeRepository incomeRepo,
            IWalletRepository walletRepo,
            IExchangeRateService exchangeRateService)
        {
            _incomeRepo = incomeRepo;
            _walletRepo = walletRepo;
            _exchangeRateService = exchangeRateService;
        }

        // Helpers methods --------------------------------------------------
        private Income MapIncomeDTOtoIncomeObject(IncomeDTO incomeDto)
        {
            return new Income
            (
                incomeDto.Id,
                incomeDto.UserId,
                incomeDto.Title,
                incomeDto.Amount,
                incomeDto.Date,
                incomeDto.WalletId,
                incomeDto.IncomeTagId == -1 ? -1 : incomeDto.IncomeTagId,
                MapIncomeDTOtoTransactionObject(incomeDto)
            );
        }

        private Transaction MapIncomeDTOtoTransactionObject(IncomeDTO incomeDto)
        {
            var transaction = new Transaction
            (
                -1,
                incomeDto.UserId,
                incomeDto.Title,
                incomeDto.Description,
                incomeDto.WalletId,
                incomeDto.Amount,
                0.0m, // AmountInSp -> calculated later
                incomeDto.Date,
                enTransactionType.Addition,
                -1,
                -1,
                -1,
                -1
            );

            // Custom attributes
            transaction.TransactionTagId = incomeDto.IncomeTagId == -1 ? -1 : incomeDto.IncomeTagId;

            return transaction;
        }

        private async Task<decimal> CalcAmountInSp(Wallet wallet, decimal amount)
        {
            decimal amountInSp = 0.0m;

            if (wallet.CurrencyId == SupportedCurrencies.SyrianPoundId)
            {
                amountInSp = amount;
            }
            else
            {
                Currency? walletCurrency = SupportedCurrencies.GetById(wallet.CurrencyId);
                if (walletCurrency == null) return 0.0m;

                amountInSp = await _exchangeRateService.NormalizeToSyrianPound(walletCurrency.Code, "damascus", "sell", amount);
            }

            return amountInSp;
        }

        // Reading methods --------------------------------------------------
        public async Task<Result<IncomeResponse>> GetIncomeAsync(int incomeId, int userId)
        {
            var income = await _incomeRepo.GetIncomeAsync(incomeId, userId);

            if (income == null)
                return Result<IncomeResponse>.Failure("Income was not found.", enErrorType.NotFound);

            return Result<IncomeResponse>.Success(new IncomeResponse(income));
        }

        public async Task<Result<PagedResponse<IncomeResponse>>> GetIncomeByUserAsync(int userId, PageDTO pageDto)
        {
            var (incomeList, totalCount) = await _incomeRepo.GetIncomeByUserAsync(userId, pageDto.PageNumber, pageDto.PageSize);
            var incomesResponse = incomeList.Select(item => new IncomeResponse(item)).ToList();

            var data = new PagedResponse<IncomeResponse>(incomesResponse, pageDto.PageNumber, pageDto.PageSize, totalCount);

            return Result<PagedResponse<IncomeResponse>>.Success(data);
        }

        // Writing methods --------------------------------------------------
        public async Task<Result<IncomeResponse>> AddIncomeAsync(IncomeDTO incomeDto)
        {
            // 1 - Input validations --------------------------------------------
            if (incomeDto.Amount <= 0)
                return Result<IncomeResponse>.Failure("Income amount must be greater than zero.", enErrorType.Validation);

            var wallet = await _walletRepo.GetWalletByIdAsync(incomeDto.WalletId, incomeDto.UserId);
            if (wallet == null)
                return Result<IncomeResponse>.Failure("Wallet was not found.", enErrorType.NotFound);

            incomeDto.Id = -1; // Make sure to send -1 to database (safe practice)

            // 2 - Map data ------------------------------------------------------
            var newIncome = MapIncomeDTOtoIncomeObject(incomeDto);
            newIncome.LinkedTransaction.AmountInSp = await CalcAmountInSp(wallet, newIncome.Amount);

            int newIncomeId = await _incomeRepo.AddIncomeAsync(newIncome);

            if (newIncomeId == -1)
                return Result<IncomeResponse>.Failure("Failed to add the income to the database.", enErrorType.Failure);

            newIncome.Id = newIncomeId;
            newIncome.LinkedTransaction.TransactionId = newIncomeId;

            // 3 - Form the response ----------------------------------------------
            var incomeResponse = new IncomeResponse(newIncome) { CurrencyId = wallet.CurrencyId };
            return Result<IncomeResponse>.Success(incomeResponse);
        }

        public async Task<Result<IncomeResponse>> UpdateIncomeAsync(IncomeDTO incomeDto)
        {
            // 1 - Input validations --------------------------------------------
            if (incomeDto.Amount <= 0)
                return Result<IncomeResponse>.Failure("Income amount must be greater than zero.", enErrorType.Validation);

            var wallet = await _walletRepo.GetWalletByIdAsync(incomeDto.WalletId, incomeDto.UserId);
            if (wallet == null)
                return Result<IncomeResponse>.Failure("Wallet was not found.", enErrorType.NotFound);

            // 2 - Map data ------------------------------------------------------
            var updatedIncome = MapIncomeDTOtoIncomeObject(incomeDto);
            updatedIncome.LinkedTransaction.AmountInSp = await CalcAmountInSp(wallet, updatedIncome.Amount);

            if (!await _incomeRepo.UpdateIncomeAsync(updatedIncome))
                return Result<IncomeResponse>.Failure("Failed to update the income in the database.", enErrorType.Failure);

            // 3 - Form the response ----------------------------------------------
            var incomeResponse = new IncomeResponse(updatedIncome) { CurrencyId = wallet.CurrencyId };
            return Result<IncomeResponse>.Success(incomeResponse);
        }

        public async Task<Result> DeleteIncomeAsync(int incomeId, int userId)
        {
            if (await _incomeRepo.DeleteIncomeAsync(incomeId, userId))
                return Result.Success();

            return Result.Failure("Failed to delete the income from the database.", enErrorType.Failure);
        }
    }
}
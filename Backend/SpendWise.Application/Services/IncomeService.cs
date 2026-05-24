using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.Interfaces.ExchangeRate;
using SpendWise.Application.Interfaces.Incomes;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Domain.Constants;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;

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
        public async Task<IncomeResponse?> GetIncomeAsync(int incomeId, int userId)
        {
            var income = await _incomeRepo.GetIncomeAsync(incomeId, userId);

            if (income == null) return null;

            return new IncomeResponse(income);
        }

        public async Task<PagedResponse<IncomeResponse>> GetIncomeByUserAsync(int userId, PageDTO pageDto)
        {
            var (incomeList, totalCount) = await _incomeRepo.GetIncomeByUserAsync(userId, pageDto.PageNumber, pageDto.PageSize);

            var incomesResponse = incomeList.Select(item => new IncomeResponse(item)).ToList();

            return new PagedResponse<IncomeResponse>(incomesResponse, pageDto.PageNumber, pageDto.PageSize, totalCount);
        }

        // Writing methods --------------------------------------------------
        public async Task<IncomeResponse?> AddIncomeAsync(IncomeDTO incomeDto)
        {
            var newIncome = MapIncomeDTOtoIncomeObject(incomeDto);

            var wallet = await _walletRepo.GetWalletByIdAsync(newIncome.WalletId, newIncome.UserId);

            if (wallet == null) return null;

            newIncome.LinkedTransaction.AmountInSp = await CalcAmountInSp(wallet, newIncome.Amount);

            int newIncomeId = await _incomeRepo.AddIncomeAsync(newIncome);

            if (newIncomeId == -1) return null;

            newIncome.Id = newIncomeId;
            newIncome.LinkedTransaction.TransactionId = newIncomeId;

            return new IncomeResponse(newIncome);
        }

        public async Task<IncomeResponse?> UpdateIncomeAsync(IncomeDTO incomeDto)
        {
            var updatedIncome = MapIncomeDTOtoIncomeObject(incomeDto);

            var wallet = await _walletRepo.GetWalletByIdAsync(updatedIncome.WalletId, updatedIncome.UserId);

            if (wallet == null) return null;


            updatedIncome.LinkedTransaction.AmountInSp = await CalcAmountInSp(wallet, updatedIncome.Amount);


            if (!await _incomeRepo.UpdateIncomeAsync(updatedIncome))
            {
                return null;
            }

            return new IncomeResponse(updatedIncome);
        }

        public async Task<bool> DeleteIncomeAsync(int incomeId, int userId)
        {
            return await _incomeRepo.DeleteIncomeAsync(incomeId, userId);
        }
    }
}
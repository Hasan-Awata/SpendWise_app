using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Wallet;
using SpendWise.Application.DTOs.Currency;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.DTOs.Tag;
using SpendWise.Application.Interfaces.Incomes;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Application.Interfaces.ExchangeRate;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using SpendWise.Domain.Constants;
using System.Linq;
using System.Threading.Tasks;
using System.Linq.Expressions;

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

        // Reading methods --------------------------------------------------
        public async Task<IncomeResponse?> GetIncomeAsync(int incomeId, int userId)
        {
            var income = await _incomeRepo.GetIncomeAsync(incomeId, userId);

            if (income == null)
            {
                return null;
            }

            return new IncomeResponse
            {
                Id = income.Id,
                UserId = income.UserId,
                Title = income.LinkedTransaction.Title,
                Amount = income.Amount,
                WalletId = income.WalletId,
                Date = income.Date,
                IncomeTagId = income.IncomeTagId == -1 ? -1 : income.IncomeTagId,
            };
        }

        public async Task<PagedResponse<IncomeResponse>> GetIncomeByUserAsync(int userId, PageDTO pageDto)
        {
            var (incomeList, totalCount) = await _incomeRepo.GetIncomeByUserAsync(userId, pageDto.PageNumber, pageDto.PageSize);

            var incomesResponse = incomeList.Select(item => new IncomeResponse
            {
                Id = item.Id,
                UserId = item.UserId,
                Title = item.LinkedTransaction.Title,
                Amount = item.Amount,
                WalletId = item.WalletId,
                Date = item.Date,
                IncomeTagId = item.IncomeTagId == -1 ? -1 : item.IncomeTagId,
            }).ToList();

            return new PagedResponse<IncomeResponse>(incomesResponse, pageDto.PageNumber, pageDto.PageSize, totalCount);
        }

        // Writing methods --------------------------------------------------
        public async Task<IncomeResponse?> AddIncomeAsync(IncomeDTO incomeDto)
        {
            // 1 - Assign the essential data from incomeDTO into an income object
            var newIncome = new Income
            {
                UserId = incomeDto.UserId,
                Amount = incomeDto.Amount,
                WalletId = incomeDto.WalletId,
                Date = incomeDto.Date,
                IncomeTagId = incomeDto.IncomeTagId == -1 ? -1 : incomeDto.IncomeTagId,
            };

            // 2 - Fetch the wallet info from the DB and normalize the amount to Syrian Pound
            var wallet = await _walletRepo.GetWalletByIdAsync(newIncome.WalletId, newIncome.UserId);
            decimal amountInSp = 0.0m;

            if (wallet == null)
            {
                return null;
            }

            if (wallet.CurrencyId == SupportedCurrencies.SyrianPoundId)
            {
                amountInSp = newIncome.Amount;
            }
            else
            {
                Currency? walletCurrency = SupportedCurrencies.GetById(wallet.CurrencyId);

                if (walletCurrency == null) return null;

                amountInSp = await _exchangeRateService.NormalizeToSyrianPound(walletCurrency.Code, "damascus", "sell", newIncome.Amount);
            }

            // 4 - Create a Transaction object to store in the database
            var newTransaction = new Transaction
            {
                UserId = incomeDto.UserId,
                Title = incomeDto.Title,
                Amount = incomeDto.Amount,
                AmountInSp = amountInSp, 
                Description = incomeDto.Description,
                Income = newIncome,
                WalletId = incomeDto.WalletId,
                TransactionTagId = incomeDto.IncomeTagId,
                TransactionDate = incomeDto.Date,
                TransactionType = enTransactionType.Addition,
            };

            // 5 - store both the income and the transaction in the database
            int newIncomeId = await _incomeRepo.AddIncomeAsync(newIncome, newTransaction);

            // 6 - Check if the creation succeeded
            if (newIncomeId == -1)
            {
                return null;
            }

            // 7 - Return the created item
            return new IncomeResponse
            {
                Id = newIncomeId,
                UserId = newIncome.UserId,
                Title = newTransaction.Title,
                Amount = newIncome.Amount,
                WalletId = newIncome.WalletId,
                IncomeTagId = newIncome.IncomeTagId,
                Date = newIncome.Date,
            };
        }

        public async Task<IncomeResponse?> UpdateIncomeAsync(IncomeDTO incomeDto)
        {
            // 1 - Assign the essential data from incomeDTO into an income object
            var updatedIncome = new Income
            {
                Id = incomeDto.Id, 
                UserId = incomeDto.UserId,
                Amount = incomeDto.Amount,
                WalletId = incomeDto.WalletId,
                Date = incomeDto.Date,
                IncomeTagId = incomeDto.IncomeTagId == -1 ? -1 : incomeDto.IncomeTagId,
            };

            // 2 - Fetch the wallet info from the DB and normalize the amount to Syrian Pound
            var wallet = await _walletRepo.GetWalletByIdAsync(updatedIncome.WalletId, updatedIncome.UserId);
            decimal amountInSp = 0.0m;

            if (wallet == null)
            {
                return null;
            }

            if (wallet.CurrencyId == SupportedCurrencies.SyrianPoundId)
            {
                amountInSp = updatedIncome.Amount;
            }
            else
            {
                Currency? walletCurrency = SupportedCurrencies.GetById(wallet.CurrencyId);

                if (walletCurrency == null) return null;

                amountInSp = await _exchangeRateService.NormalizeToSyrianPound(walletCurrency.Code, "damascus", "sell", updatedIncome.Amount);
            }

            // 4 - Create a Transaction object to store in the database
            var updatedTransaction = new Transaction
            {
                UserId = incomeDto.UserId,
                Title = incomeDto.Title,
                Amount = incomeDto.Amount,
                AmountInSp = amountInSp, 
                Description = incomeDto.Description,
                Income = updatedIncome,
                WalletId = incomeDto.WalletId,
                TransactionTagId = incomeDto.IncomeTagId,
                TransactionDate = incomeDto.Date,
                TransactionType = enTransactionType.Addition,
            };

            // 5 - store both the income and the transaction in the database
            // 6 - Check if the update succeeded
            if (!await _incomeRepo.UpdateIncomeAsync(updatedIncome, updatedTransaction))
            {
                return null;
            }

            // 7 - Return the created item
            return new IncomeResponse
            {
                Id = updatedIncome.Id,
                UserId = updatedIncome.UserId,
                Title = updatedTransaction.Title,
                Amount = updatedIncome.Amount,
                WalletId = updatedIncome.WalletId,
                IncomeTagId = updatedIncome.IncomeTagId,
                Date = updatedIncome.Date,
            };
        }

        public async Task<bool> DeleteIncomeAsync(int incomeId, int userId)
        {
            return await _incomeRepo.DeleteIncomeAsync(incomeId, userId);
        }
    }
}
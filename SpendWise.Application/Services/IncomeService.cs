using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Wallet;
using SpendWise.Application.DTOs.Currency;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.DTOs.Tag;
using SpendWise.Application.Interfaces.Incomes;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;

namespace SpendWise.Application.Services
{
    public class IncomeService: IIncomeService
    {
        private readonly IIncomeRepository _incomeRepo;
        
        public IncomeService(IIncomeRepository incomeRepo)
        {
            _incomeRepo = incomeRepo;
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
                Title = "Income",
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
                Title = "Income",
                Amount = item.Amount,
                WalletId = item.WalletId,
                Date = item.Date,
                // If IncomeTag is null, the result is null. 
                // Otherwise, it creates the new TagResponse.
                IncomeTagId = item.IncomeTagId == -1 ? -1 : item.IncomeTagId,
            });

            return new PagedResponse<IncomeResponse> (incomesResponse, pageDto.PageNumber, pageDto.PageSize, totalCount);
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

            // 4 - Create a Transaction object to store in the database
            var newTransaction = new Transaction
            {
              UserId = incomeDto.UserId,
              Title = "Added Income",
              Amount = incomeDto.Amount,
              Description = incomeDto.Description,
              Income = newIncome,
              WalletId = newIncome.WalletId,
              TransactionTagId = newIncome.IncomeTagId,
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
                UserId = incomeDto.UserId,
                Title = newTransaction.Title,
                Amount= newTransaction.Amount,
                WalletId = incomeDto.WalletId,
                IncomeTagId = newTransaction.TransactionTagId,
                Date = incomeDto.Date,
            };
        }
        public async Task<IncomeResponse?> UpdateIncomeAsync(IncomeDTO incomeDto)
        {
            // 1 - Assign the essential data from incomeDTO into an income object
            var updatedIncome = new Income
            {
                UserId = incomeDto.UserId,
                Amount = incomeDto.Amount,
                WalletId = incomeDto.WalletId,
                Date = incomeDto.Date,
                IncomeTagId = incomeDto.IncomeTagId == -1 ? -1 : incomeDto.IncomeTagId,
            };

            // 4 - Create a Transaction object to store in the database
            var updatedTransaction = new Transaction
            {
                UserId = incomeDto.UserId,
                Title = "Added Income",
                Amount = incomeDto.Amount,
                Description = incomeDto.Description,
                Income = updatedIncome,
                WalletId = updatedIncome.WalletId,
                TransactionTagId = updatedIncome.IncomeTagId,
                TransactionDate = incomeDto.Date,
                TransactionType = enTransactionType.Addition,
            };

            // 5 - store both the income and the transaction in the database

            // 6 - Check if the update succeeded
            if(!await _incomeRepo.UpdateIncomeAsync(updatedIncome, updatedTransaction))
            {
                return null;
            }

            // 7 - Return the created item
            return new IncomeResponse
            {
                Id = incomeDto.Id,
                UserId = incomeDto.UserId,
                Title = updatedTransaction.Title,
                Amount = updatedTransaction.Amount,
                WalletId = updatedTransaction.WalletId,
                IncomeTagId = updatedTransaction.TransactionTagId,
                Date = updatedIncome.Date,
            };
        }

        public async Task<bool> DeleteIncomeAsync(int incomeId, int userId)
        {
            return await _incomeRepo.DeleteIncomeAsync(incomeId, userId);
        }
    }
}

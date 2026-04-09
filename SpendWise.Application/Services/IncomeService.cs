using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.DTOs.Tag;
using SpendWise.Application.Interfaces.Incomes;
using SpendWise.Application.Interfaces.Tags;
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
        public async Task<IncomeResponse> GetIncomeAsync(int incomeId, int userId)
        {
            var income = await _incomeRepo.GetIncomeAsync(incomeId, userId);

            if (income == null)
            {
                throw new Exception("There is no income associated with this id");
            }

            return new IncomeResponse
            {
                Id = (int)income.Id,
                UserId = income.UserId,
                Title = "Income",
                Amount = income.Amount,
                IncomeTag = income.IncomeTag == null ? null : new TagResponse 
                { 
                    Id = income.IncomeTag.Id,
                    Label = income.IncomeTag.Label,
                    OwnerId = income.IncomeTag.OwnerId,
                },
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
                // If IncomeTag is null, the result is null. 
                // Otherwise, it creates the new TagResponse.
                IncomeTag = item.IncomeTag == null ? null : new TagResponse
                {
                    Id = item.IncomeTag.Id,
                    Label = item.IncomeTag.Label,
                    OwnerId = item.IncomeTag.OwnerId,
                }
            });

            return new PagedResponse<IncomeResponse> (incomesResponse, pageDto.PageNumber, pageDto.PageSize, totalCount);
        }

        // Writing methods --------------------------------------------------
        public async Task<IncomeResponse> AddIncomeAsync(IncomeDTO incomeDto)
        {
            // 1 - Assign the essential data from incomeDTO into an income object
            var newIncome = new Income
            {
                UserId = incomeDto.UserId,
                Amount = incomeDto.Amount,
            };

            // 2 - Check if the non-essential data existed in the incomeDTO
            Tag? newIncomeTag = null;
            
            if(incomeDto.IncomeTag != null)
            {
                newIncomeTag = new Tag 
                { 
                    Id = incomeDto.IncomeTag.Id,
                    Label = incomeDto.IncomeTag.Label,
                    OwnerId = incomeDto.IncomeTag.OwnerId,
                };
            }

            // 3 - Assign the non-essential data from the incomeDTO into the same income object
            newIncome.IncomeTag = newIncomeTag;

            // 4 - Create a Transaction object to store in the database
            var newTransaction = new Transaction
            {
              UserId = incomeDto.UserId,
              Title = "Added Income",
              Amount = incomeDto.Amount,
              Description = incomeDto.Description,
              Income = newIncome,
              WalletId = incomeDto.WalletId,
              TransactionTag = newIncomeTag,
              TransactionDate = incomeDto.Date,
              TransactionType = enTransactionType.Addition,
            };

            // 5 - store both the income and the transaction in the database
            int newIncomeId = await _incomeRepo.AddIncomeAsync(newIncome, newTransaction);

            // 6 - Return the created item
            return new IncomeResponse 
            { 
                Id = newIncomeId,
                UserId = incomeDto.UserId,
                Title = newTransaction.Title,
                Amount= newTransaction.Amount,
                IncomeTag = newIncomeTag == null ? null : new TagResponse
                {
                    Id = newIncomeTag.Id,
                    Label = newIncomeTag.Label,
                    OwnerId = newIncomeTag.OwnerId,
                }
            };
        }
        public async Task<IncomeResponse> UpdateIncomeAsync(IncomeDTO incomeDto)
        {
            // 1 - Assign the essential data from incomeDTO into an income object
            var updatedIncome = new Income
            {
                Id = incomeDto.Id,
                UserId = incomeDto.UserId,
                Amount = incomeDto.Amount,
            };

            // 2 - Check if the non-essential data existed in the incomeDTO
            Tag? updatedIncomeTag = null;

            if (incomeDto.IncomeTag != null)
            {
                updatedIncomeTag = new Tag
                {
                    Id = incomeDto.IncomeTag.Id,
                    Label = incomeDto.IncomeTag.Label,
                    OwnerId = incomeDto.IncomeTag.OwnerId,
                };
            }

            // 3 - Assign the non-essential data from the incomeDTO into the same income object
            updatedIncome.IncomeTag = updatedIncomeTag;

            // 4 - Create a Transaction object to store in the database
            var updatedTransaction = new Transaction
            {
                UserId = incomeDto.UserId,
                Title = "Added Income",
                Amount = incomeDto.Amount,
                Description = incomeDto.Description,
                Income = updatedIncome,
                WalletId = incomeDto.WalletId,
                TransactionTag = updatedIncomeTag,
                TransactionDate = incomeDto.Date,
                TransactionType = enTransactionType.Addition,
            };

            // 5 - store both the income and the transaction in the database
            int updatedIncomeId = await _incomeRepo.AddIncomeAsync(updatedIncome, updatedTransaction);

            // 6 - Return the created item
            return new IncomeResponse
            {
                Id = updatedIncomeId,
                UserId = incomeDto.UserId,
                Title = updatedTransaction.Title,
                Amount = updatedTransaction.Amount,
                IncomeTag = updatedIncomeTag == null ? null : new TagResponse
                {
                    Id = updatedIncomeTag.Id,
                    Label = updatedIncomeTag.Label,
                    OwnerId = updatedIncomeTag.OwnerId,
                }
            };
        }

        public async Task<bool> DeleteIncomeAsync(int incomeId)
        {
            return await _incomeRepo.DeleteIncomeAsync(incomeId);
        }
    }
}

using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.Interfaces.Incom;
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
        public async Task<IncomeResponse> GetIncomeAsync(int incomeId)
        {
            var transactionIncome = await _incomeRepo.GetIncomeAsync(incomeId);

            if (transactionIncome == null)
            {
                throw new Exception("There is no income associated with this id");
            }

            return new IncomeResponse
            {
                Id = (int)transactionIncome.IncomeId,
                UserId = transactionIncome.UserId,
                Title = transactionIncome.Title,
                Amount = transactionIncome.Amount,
                TagId = transactionIncome.TagId,
            };
        }

        public async Task<PagedResponse<IncomeResponse>> GetIncomeByUserAsync(int userId, PageDTO pageDto)
        {
            var (TransactionIncomeList, totalCount) = await _incomeRepo.GetIncomeByUserAsync(userId, pageDto.PageNumber, pageDto.PageSize);

            var incomesResponse = TransactionIncomeList.Select(item => new IncomeResponse
            {
                Id = (int)item.IncomeId,
                UserId = item.UserId,
                Title = item.Title,
                Amount= item.Amount,
                TagId= item.TagId,
            });

            return new PagedResponse<IncomeResponse> (incomesResponse, pageDto.PageNumber, pageDto.PageSize, totalCount);
        }

        // Writing methods --------------------------------------------------
        public async Task<IncomeResponse> AddIncomeAsync(IncomeDTO incomeDto)
        {
            // 1 - map the incomeDTO into an income object
            var newIncome = new Income
            {
                UserId = incomeDto.UserId,
                Amount = incomeDto.Amount,
            };

            // 2 - Create a Transaction object to store in the database
            var newTransaction = new Transaction
            {
              UserId = incomeDto.UserId,
              Title = "Added Income",
              Amount = incomeDto.Amount,
              Description = incomeDto.Description,
              IncomeId = null,
              WalletId = incomeDto.WalletId,
              TagId = incomeDto.TagId,
              TransactionDate = incomeDto.Date,
              TransactionType = enTransactionType.Addition,
            };

            // 3 - store both the income and the transaction in the database
            int newIncomeId = await _incomeRepo.AddIncomeAsync(newIncome, newTransaction);

            // 4 - Return the created item
            return new IncomeResponse 
            { 
                Id = newIncomeId,
                UserId = incomeDto.UserId,
                Title = newTransaction.Title,
                Amount= newTransaction.Amount,
                TagId= newTransaction.TagId,
            };
        }
        public async Task<IncomeResponse> UpdateIncomeAsync(IncomeDTO incomeDto)
        {
            // 1 - map the incomeDTO into an income object
            var updatedIncome = new Income
            {
                UserId = incomeDto.UserId,
                Amount = incomeDto.Amount,
            };

            // 2 - Create a Transaction object to update the one in the database
            var updatedTransaction = new Transaction
            {
              UserId = incomeDto.UserId,
              Title = "Added Income",
              Amount = incomeDto.Amount,
              Description = incomeDto.Description,
              IncomeId = incomeDto.Id,
              WalletId = incomeDto.WalletId,
              TagId = incomeDto.TagId,
              TransactionDate = incomeDto.Date,
              TransactionType = enTransactionType.Addition,
            };

            // 3 - update both the income and the transaction in the database
            int updatedIncomeId = await _incomeRepo.UpdateIncomeAsync(updatedIncome, updatedTransaction);

            // 4 - Return the updated item
            return new IncomeResponse 
            { 
                Id = updatedIncomeId,
                UserId = incomeDto.UserId,
                Title = updatedTransaction.Title,
                Amount= updatedTransaction.Amount,
                TagId= updatedTransaction.TagId,
            };
        }

        public async Task<bool> DeleteIncomeAsync(int incomeId)
        {
            return await _incomeRepo.DeleteIncomeAsync(incomeId);
        }
    }
}

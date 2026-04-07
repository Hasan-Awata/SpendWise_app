using SpendWise.Application.DTOs.Income;
using SpendWise.Application.Interfaces.Incom;
using SpendWise.Application.Interfaces.Incomes;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Text;
using System.Transactions;

namespace SpendWise.Application.Services
{
    public class IncomeService: IIncomeService
    {
        //Add Later 
        private readonly IIncomeRepository _incomeRepo;

        public IncomeService(IIncomeRepository incomeRepo)
        {
            _incomeRepo = incomeRepo;
        }
        

        public async Task<bool> AddIncomeAsync(IncomeDTO incomeDto)
        {
            bool isDone = false;

            // 1 - map the incomeDTO into an income object
            var newIncome = new Income
            {
                UserId = incomeDto.UserId,
                Amount = incomeDto.Amount,
            };

            // 2 - Create a Transaction object to store in the database
            var newTransaction = new Domain.Entities.Transaction
            {
              UserId = incomeDto.UserId,
              Title = "Added Income",
              Amount = incomeDto.Amount,
              Description = incomeDto.Description,
              IncomeId = null,
              WalletId = incomeDto.WalletId,
              TagId = incomeDto.TagId,
              TransactionDate = incomeDto.Date,
              TransactionType = enTransactionType.Income,
            };

            // 3 - store both the income and the transaction in the database
            isDone = await _incomeRepo.AddIncomeAsync(newIncome, newTransaction);

            return isDone;
        }
    }
}

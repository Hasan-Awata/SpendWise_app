using SpendWise.Application.DTOs.Expense;
using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.Interfaces.Expenses;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Services
{
    public class ExpenseService
    {
        private readonly IExpenseRepository _expenseRepo;

        public ExpenseService(IExpenseRepository expenseRepo)
        {
            _expenseRepo = expenseRepo;
        }

        // Reading methods --------------------------------------------------
        public async Task<ExpenseResponse> GetExpenseAsync(int expenseId)
        {
            var transactionExpense = await _expenseRepo.GetExpenseAsync(expenseId);
            var products = await _expenseRepo.GetProductsAsync(expenseId);

            if (transactionExpense == null)
            {
                throw new Exception("There is no expense associated with this id");
            }

            return new ExpenseResponse
            {
                Id = (int)transactionExpense.ExpenseId,
                UserId = transactionExpense.UserId,
                Title = transactionExpense.Title,
                Amount = transactionExpense.Amount,
                TagId = transactionExpense.TagId,
                Products = products,
            };
        }

        public async Task<PagedResponse<ExpenseResponse>> GetExpenseByUserAsync(int userId, PageDTO pageDto)
        {
            var (TransactionExpensesList, totalCount) = await _expenseRepo.GetExpensesByUserAsync(userId, pageDto.PageNumber, pageDto.PageSize);

            var expenseResponse = TransactionExpensesList.Select(item => new ExpenseResponse
            {
                Id = (int)item.ExpenseId,
                UserId = item.UserId,
                Title = item.Title,
                Amount = item.Amount,
                TagId = item.TagId,
            });

            expenseResponse.Select(async item => item.Products = await _expenseRepo.GetProductsAsync(item.Id));

            return new PagedResponse<ExpenseResponse>(expenseResponse, pageDto.PageNumber, pageDto.PageSize, totalCount);
        }

        // Writing methods --------------------------------------------------
        public async Task<ExpenseResponse> AddIncomeAsync(ExpenseDTO expenseDto)
        {
            // 1 - map the expenseDTO into an expense object
            var newIncome = new Expense
            {
                UserId = expenseDto.UserId,
                Amount = expenseDto.Amount,
                Products = expenseDto.Products,
            };

            // 2 - Create a Transaction object to store in the database
            var newTransaction = new Transaction
            {
                UserId = expenseDto.UserId,
                Title = "Added Expense",
                Amount = expenseDto.Amount,
                Description = expenseDto.Description,
                IncomeId = null,
                WalletId = expenseDto.WalletId,
                TagId = expenseDto.TagId,
                TransactionDate = expenseDto.Date,
                TransactionType = enTransactionType.Dedduction,
            };

            // 3 - store both the income and the transaction in the database
            int newExpenseId = await _expenseRepo.AddExpenseAsync(newIncome, newTransaction);

            // 4 - Return the created item
            return new ExpenseResponse
            {
                Id = newExpenseId,
                UserId = expenseDto.UserId,
                Title = newTransaction.Title,
                Amount = newTransaction.Amount,
                TagId = newTransaction.TagId,
                Products = expenseDto.Products,
            };
        }
        public async Task<ExpenseResponse> UpdateExpenseAsync(ExpenseDTO expenseDto)
        {
            // 1 - map the incomeDTO into an income object
            var updatedExpense = new Expense
            {
                UserId = expenseDto.UserId,
                Amount = expenseDto.Amount,
                Products = expenseDto.Products,
            };

            // 2 - Create a Transaction object to update the one in the database
            var updatedTransaction = new Transaction
            {
                UserId = expenseDto.UserId,
                Title = "Added Expense",
                Amount = expenseDto.Amount,
                Description = expenseDto.Description,
                IncomeId = expenseDto.Id,
                WalletId = expenseDto.WalletId,
                TagId = expenseDto.TagId,
                TransactionDate = expenseDto.Date,
                TransactionType = enTransactionType.Dedduction,
            };

            // 3 - update both the income and the transaction in the database
            int updatedIncomeId = await _expenseRepo.UpdateExpenseAsync(updatedExpense, updatedTransaction);

            // 4 - Return the updated item
            return new ExpenseResponse
            {
                Id = updatedIncomeId,
                UserId = expenseDto.UserId,
                Title = updatedTransaction.Title,
                Amount = updatedTransaction.Amount,
                TagId = updatedTransaction.TagId,
                Products = expenseDto.Products,
            };
        }

        public async Task<bool> DeleteIncomeAsync(int incomeId)
        {
            return await _expenseRepo.DeleteExpenseAsync(incomeId);
        }
    }

}

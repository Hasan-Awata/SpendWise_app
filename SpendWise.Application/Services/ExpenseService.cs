using SpendWise.Application.DTOs.Expense;
using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Tag;
using SpendWise.Application.DTOs.Category;
using SpendWise.Application.DTOs.Currency;
using SpendWise.Application.DTOs.Wallet;
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
    public class ExpenseService : IExpenseService
    {
        private readonly IExpenseRepository _expenseRepo;

        public ExpenseService(IExpenseRepository expenseRepo)
        {
            _expenseRepo = expenseRepo;
        }

        // Reading methods --------------------------------------------------
        public async Task<ExpenseResponse?> GetExpenseAsync(int expenseId, int userId)
        {
            var expense = await _expenseRepo.GetExpenseAsync(expenseId, expenseId);

            if (expense == null)
            {
                return null;
            }

            return new ExpenseResponse
            {
                ExpenseId = expense.ExpenseId,
                UserId = expense.UserId,
                Title = "Added expense",
                Amount = expense.Amount,
                Date = expense.Date,
                Products = expense.Products,
                CategoryId = expense.CategoryId,
                WalletId = expense.WalletId,
                ExpenseTagId = expense.ExpenseTagId == -1 ? -1 : expense.ExpenseTagId,
            };
        }

        public async Task<PagedResponse<ExpenseResponse>> GetExpenseByUserAsync(int userId, PageDTO pageDto)
        {
            var (expensesList, totalCount) = await _expenseRepo.GetExpensesByUserAsync(userId, pageDto.PageNumber, pageDto.PageSize);

            var expenseResponse = expensesList.Select(item => new ExpenseResponse
            {
                ExpenseId = item.ExpenseId,
                UserId = item.UserId,
                Title = "Added expense",
                Amount = item.Amount,
                Date = item.Date,
                Products = item.Products,
                CategoryId = item.CategoryId,
                WalletId = item.WalletId,
                ExpenseTagId = item.ExpenseTagId == -1 ? -1 : item.ExpenseTagId,
            });

            return new PagedResponse<ExpenseResponse>(expenseResponse, pageDto.PageNumber, pageDto.PageSize, totalCount);
        }


        // Writing methods --------------------------------------------------
        public async Task<ExpenseResponse?> AddExpenseAsync(ExpenseDTO expenseDto)
        {
            // 1 - map the expenseDTO into an expense object
            var newExpens = new Expense
            {
                UserId = expenseDto.UserId,
                Amount = expenseDto.Amount,
                Products = expenseDto.Products,
                Date = expenseDto.Date,
                CategoryId = expenseDto.CategoryId,
                ExpenseTagId = expenseDto.ExpenseTagId == -1 ? -1 : expenseDto.ExpenseTagId,
                WalletId = expenseDto.WalletId,
            };

            // 2 - Create a Transaction object to store in the database
            var newTransaction = new Transaction
            {
                UserId = expenseDto.UserId,
                Expense = newExpens,
                Description = expenseDto.Description,
                Title = "Added Expense",
                TransactionType = enTransactionType.Dedduction,
                Amount = expenseDto.Amount,
                TransactionCategoryId = newExpens.CategoryId,
                TransactionDate = newExpens.Date,
                WalletId = newExpens.WalletId,
                TransactionTagId = newExpens.ExpenseTagId,
            };

            // 3 - store both the income and the transaction in the database
            int newExpenseId = await _expenseRepo.AddExpenseAsync(newExpens, newTransaction);

            // 4 - Return the created item
            return new ExpenseResponse
            {
                ExpenseId = newExpenseId,
                UserId = newExpens.UserId,
                Title = "Added expense",
                Amount = newExpens.Amount,
                Products = newExpens.Products,
                Date = newExpens.Date,
                CategoryId = newExpens.CategoryId,
                WalletId = newExpens.WalletId,
                ExpenseTagId = newExpens.ExpenseTagId,
            };
        }
        public async Task<ExpenseResponse?> UpdateExpenseAsync(ExpenseDTO expenseDto)
        {
            // 1 - map the expenseDTO into an expense object
            var updatedExpens = new Expense
            {
                ExpenseId = expenseDto.ExpenseId,
                UserId = expenseDto.UserId,
                Amount = expenseDto.Amount,
                Products = expenseDto.Products,
                Date = expenseDto.Date,
                CategoryId = expenseDto.CategoryId,
                ExpenseTagId = expenseDto.ExpenseTagId == -1 ? -1 : expenseDto.ExpenseTagId,
                WalletId = expenseDto.WalletId,
            };

            // 2 - Create a Transaction object to store in the database
            var newTransaction = new Transaction
            {
                UserId = expenseDto.UserId,
                Expense = updatedExpens,
                Description = expenseDto.Description,
                Title = "Added Expense",
                TransactionType = enTransactionType.Dedduction,
                Amount = expenseDto.Amount,
                TransactionCategoryId = updatedExpens.CategoryId,
                TransactionDate = updatedExpens.Date,
                WalletId = updatedExpens.WalletId,
                TransactionTagId = updatedExpens.ExpenseTagId,
            };

            // 3 - store both the income and the transaction in the database
            if (!await _expenseRepo.UpdateExpenseAsync(updatedExpens, newTransaction))
                return null;

            // 4 - Return the created item
            return new ExpenseResponse
            {
                ExpenseId = updatedExpens.ExpenseId,
                UserId = updatedExpens.UserId,
                Title = "Added expense",
                Amount = updatedExpens.Amount,
                Date = updatedExpens.Date,
                Products = updatedExpens.Products,
                CategoryId = updatedExpens.CategoryId,
                WalletId = updatedExpens.WalletId,
                ExpenseTagId = updatedExpens.ExpenseTagId == -1 ? -1 : updatedExpens.ExpenseTagId,
            };
        }

        public async Task<bool> DeleteExpenseAsync(int expenseId, int userId)
        {
            return await _expenseRepo.DeleteExpenseAsync(expenseId, userId);
        }

    }

}

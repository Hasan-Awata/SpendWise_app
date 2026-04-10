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
                Products = expense.Products,
                Category = new CategoryResponse
                {
                    CategoryId = expense.Category.CategoryId,
                    Name = expense.Category.Name,
                    Priority = expense.Category.Priority,
                },
                Wallet = new WalletResponse
                {
                    WalletId = expense.Wallet.WalletId,
                    UserId = expense.Wallet.UserId,
                    Balance = expense.Wallet.Balance,
                    Currency = new CurrencyResponse
                    {
                        Id = expense.Wallet.Currency.Id,
                        CurrencyName = expense.Wallet.Currency.CurrencyName,
                        LiveValue = expense.Wallet.Currency.LiveValue,
                    },
                },
                ExpenseTag = expense.ExpenseTag == null ? null : new TagResponse
                {
                    Id = expense.ExpenseTag.Id,
                    Label = expense.ExpenseTag.Label,
                    OwnerId = expense.ExpenseTag.OwnerId,
                },
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
                Products = item.Products,
                Category = new CategoryResponse
                {
                    CategoryId = item.Category.CategoryId,
                    Name = item.Category.Name,
                    Priority = item.Category.Priority,
                },
                Wallet = new WalletResponse
                {
                    WalletId = item.Wallet.WalletId,
                    UserId = item.Wallet.UserId,
                    Balance = item.Wallet.Balance,
                    Currency = new CurrencyResponse
                    {
                        Id = item.Wallet.Currency.Id,
                        CurrencyName = item.Wallet.Currency.CurrencyName,
                        LiveValue = item.Wallet.Currency.LiveValue,
                    },
                },
                ExpenseTag = item.ExpenseTag == null ? null : new TagResponse
                {
                    Id = item.ExpenseTag.Id,
                    Label = item.ExpenseTag.Label,
                    OwnerId = item.ExpenseTag.OwnerId,
                },
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
                Category = new Category
                {
                    CategoryId = expenseDto.Category.CategoryId,
                    Name = expenseDto.Category.Name,
                    Priority = expenseDto.Category.Priority,
                },
                ExpenseTag = expenseDto.ExpenseTag == null ? null : new Tag
                {
                    Id = expenseDto.ExpenseTag.Id,
                    Label = expenseDto.ExpenseTag.Label,
                    OwnerId = expenseDto.ExpenseTag.OwnerId,
                },
                Wallet = new Wallet
                {
                    WalletId = expenseDto.Wallet.WalletId,
                    UserId = expenseDto.Wallet.UserId,
                    Balance = expenseDto.Wallet.Balance,
                    Currency = new Currency
                    {
                        Id = expenseDto.Wallet.Currency.CurrencyId,
                        CurrencyName = expenseDto.Wallet.Currency.CurrencyName,
                        LiveValue = expenseDto.Wallet.Currency.LiveValue,
                    },
                }
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
                TransactionCategory = newExpens.Category,
                TransactionDate = newExpens.Date,
                Wallet = newExpens.Wallet,
                TransactionTag = newExpens.ExpenseTag,
            };

            // 3 - store both the income and the transaction in the database
            int newExpenseId = await _expenseRepo.AddExpenseAsync(newExpens, newTransaction);

            // 4 - Return the created item
            return new ExpenseResponse
            {
                ExpenseId = newExpens.ExpenseId,
                UserId = newExpens.UserId,
                Title = "Added expense",
                Amount = newExpens.Amount,
                Products = newExpens.Products,
                Category = new CategoryResponse
                {
                    CategoryId = newExpens.Category.CategoryId,
                    Name = newExpens.Category.Name,
                    Priority = newExpens.Category.Priority,
                },
                Wallet = new WalletResponse
                {
                    WalletId = newExpens.Wallet.WalletId,
                    UserId = newExpens.Wallet.UserId,
                    Balance = newExpens.Wallet.Balance,
                    Currency = new CurrencyResponse
                    {
                        Id = newExpens.Wallet.Currency.Id,
                        CurrencyName = newExpens.Wallet.Currency.CurrencyName,
                        LiveValue = newExpens.Wallet.Currency.LiveValue,
                    },
                },
                ExpenseTag = newExpens.ExpenseTag == null ? null : new TagResponse
                {
                    Id = newExpens.ExpenseTag.Id,
                    Label = newExpens.ExpenseTag.Label,
                    OwnerId = newExpens.ExpenseTag.OwnerId,
                },
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
                Category = new Category
                {
                    CategoryId = expenseDto.Category.CategoryId,
                    Name = expenseDto.Category.Name,
                    Priority = expenseDto.Category.Priority,
                },
                ExpenseTag = expenseDto.ExpenseTag == null ? null : new Tag
                {
                    Id = expenseDto.ExpenseTag.Id,
                    Label = expenseDto.ExpenseTag.Label,
                    OwnerId = expenseDto.ExpenseTag.OwnerId,
                },
                Wallet = new Wallet
                {
                    WalletId = expenseDto.Wallet.WalletId,
                    UserId = expenseDto.Wallet.UserId,
                    Balance = expenseDto.Wallet.Balance,
                    Currency = new Currency
                    {
                        Id = expenseDto.Wallet.Currency.CurrencyId,
                        CurrencyName = expenseDto.Wallet.Currency.CurrencyName,
                        LiveValue = expenseDto.Wallet.Currency.LiveValue,
                    },
                }
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
                TransactionCategory = updatedExpens.Category,
                TransactionDate = updatedExpens.Date,
                Wallet = updatedExpens.Wallet,
                TransactionTag = updatedExpens.ExpenseTag,
            };

            // 3 - store both the income and the transaction in the database
            int updateExpenseId = await _expenseRepo.UpdateExpenseAsync(updatedExpens, newTransaction);

            // 4 - Return the created item
            return new ExpenseResponse
            {
                ExpenseId = updatedExpens.ExpenseId,
                UserId = updatedExpens.UserId,
                Title = "Added expense",
                Amount = updatedExpens.Amount,
                Products = updatedExpens.Products,
                Category = new CategoryResponse
                {
                    CategoryId = updatedExpens.Category.CategoryId,
                    Name = updatedExpens.Category.Name,
                    Priority = updatedExpens.Category.Priority,
                },
                Wallet = new WalletResponse
                {
                    WalletId = updatedExpens.Wallet.WalletId,
                    UserId = updatedExpens.Wallet.UserId,
                    Balance = updatedExpens.Wallet.Balance,
                    Currency = new CurrencyResponse
                    {
                        Id = updatedExpens.Wallet.Currency.Id,
                        CurrencyName = updatedExpens.Wallet.Currency.CurrencyName,
                        LiveValue = updatedExpens.Wallet.Currency.LiveValue,
                    },
                },
                ExpenseTag = updatedExpens.ExpenseTag == null ? null : new TagResponse
                {
                    Id = updatedExpens.ExpenseTag.Id,
                    Label = updatedExpens.ExpenseTag.Label,
                    OwnerId = updatedExpens.ExpenseTag.OwnerId,
                },
            };
        }

        public async Task<bool> DeleteExpenseAsync(int expenseId)
        {
            return await _expenseRepo.DeleteExpenseAsync(expenseId);
        }

    }

}

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
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Application.Interfaces.ExchangeRate;
using SpendWise.Domain.Constants;

namespace SpendWise.Application.Services
{
    public class ExpenseService : IExpenseService
    {
        private readonly IExpenseRepository _expenseRepo;
        private readonly IWalletRepository _walletRepo;
        private readonly IExchangeRateService _exchangeRateService;

        public ExpenseService(IExpenseRepository expenseRepo, IWalletRepository walletRepo, IExchangeRateService exchangeRateService)
        {
            _expenseRepo = expenseRepo;
            _walletRepo = walletRepo;
            _exchangeRateService = exchangeRateService;
        }

        // Helpers methods --------------------------------------------------
        private Expense MapExpenseDTOtoExpenseObject(ExpenseDTO expenseDTO)
        {
            return new Expense
            (
                expenseDTO.ExpenseId,
                expenseDTO.UserId,
                expenseDTO.Title,
                expenseDTO.Amount,
                expenseDTO.Products,
                expenseDTO.ExpenseTagId,
                expenseDTO.CategoryId,
                expenseDTO.WalletId,
                expenseDTO.LinkedTransactionId,
                expenseDTO.Date
            );
        }

        private Transaction MapExpenseDTOtoTransactionObject(ExpenseDTO expenseDTO)
        {
            var transaction =  new Transaction
            (
                expenseDTO.LinkedTransactionId,
                expenseDTO.UserId,
                expenseDTO.Title,
                expenseDTO.Description,
                expenseDTO.WalletId,
                expenseDTO.Amount,
                0, // Amount in Syrian pounds -> calculated later through out the process
                expenseDTO.Date,
                enTransactionType.Dedduction
            );

            // Custom attributes for expenses only:
            transaction.TransactionCategoryId = expenseDTO.CategoryId;
            transaction.TransactionTagId = expenseDTO.ExpenseTagId;

            return transaction;
        }

        // Reading methods --------------------------------------------------
        public async Task<ExpenseResponse?> GetExpenseAsync(int expenseId, int userId)
        {
            var expense = await _expenseRepo.GetExpenseAsync(expenseId, userId);

            if (expense == null)
            {
                return null;
            }

            return new ExpenseResponse(expense);
        }

        public async Task<PagedResponse<ExpenseResponse>> GetExpenseByUserAsync(int userId, PageDTO pageDto)
        {
            var (expensesList, totalCount) = await _expenseRepo.GetExpensesByUserAsync(userId, pageDto.PageNumber, pageDto.PageSize);

            var expenseResponse = expensesList.Select(item => new ExpenseResponse(item)).ToList();

            return new PagedResponse<ExpenseResponse>(expenseResponse, pageDto.PageNumber, pageDto.PageSize, totalCount);
        }


        // Writing methods --------------------------------------------------
        public async Task<ExpenseResponse?> AddExpenseAsync(ExpenseDTO expenseDto)
        {
            // 1 - map the expenseDTO into an expense object
            var newExpense = MapExpenseDTOtoExpenseObject(expenseDto);

            // 2 - Fethcing the wallet info from the DB and normalizing the amount to Syrian Pound
            var wallet = await _walletRepo.GetWalletByIdAsync(newExpense.WalletId, newExpense.UserId);
            decimal amountInSp = 0.0m;
            
            if (wallet == null)
            {
                return null;
            }

            if(wallet.CurrencyId == SupportedCurrencies.SyrianPoundId)
            {
                amountInSp = newExpense.Amount;
            }
            else
            {
                Currency? walletCurrency = SupportedCurrencies.GetById(wallet.CurrencyId);
                
                if (walletCurrency == null) return null;

                amountInSp = await _exchangeRateService.NormalizeToSyrianPound(walletCurrency.Code, "damascus", "sell", newExpense.Amount);
            }

            // 3 - Create a Transaction object to store in the database
            var newTransaction = MapExpenseDTOtoTransactionObject(expenseDto);
            newTransaction.AmountInSp = amountInSp;

            // 4 - store both the expense and the transaction in the database
            (int newExpenseId, bool IsOverLimit) = await _expenseRepo.AddExpenseAsync(newExpense, newTransaction);
            
            if(newExpenseId == -1) return null;

            // 5 - map important data before return the response
            newExpense.ExpenseId = newExpenseId;

            // 6 - Return the created item
            var expenseResponse = new ExpenseResponse(newExpense);
            expenseResponse.IsOverLimit = IsOverLimit;

            return expenseResponse;
        }

        public async Task<ExpenseResponse?> UpdateExpenseAsync(ExpenseDTO expenseDto)
        {
            // 1 - map the expenseDTO into an expense object
            var updatedExpens = MapExpenseDTOtoExpenseObject(expenseDto);

            // 2 - Fethcing the wallet info from the DB and normalizing the amount to Syrian Pound
            var wallet = await _walletRepo.GetWalletByIdAsync(updatedExpens.WalletId, updatedExpens.UserId);
            decimal amountInSp = 0.0m;

            if (wallet == null)
            {
                return null;
            }

            if (wallet.CurrencyId == SupportedCurrencies.SyrianPoundId)
            {
                amountInSp = updatedExpens.Amount;
            }
            else
            {
                Currency? walletCurrency = SupportedCurrencies.GetById(wallet.CurrencyId);

                if (walletCurrency == null) return null;

                amountInSp = await _exchangeRateService.NormalizeToSyrianPound(walletCurrency.Code, "damascus", "sell", updatedExpens.Amount);
            }

            // 3 - Create a Transaction object to store in the database
            var newTransaction = MapExpenseDTOtoTransactionObject(expenseDto);

            // 4 - store both the expense and the transaction in the database
            (bool Success, bool IsOverLimit) = await _expenseRepo.UpdateExpenseAsync(updatedExpens, newTransaction);
                
            if (!Success) return null;

            // 5 - Return the updated item
            var expenseResponse =  new ExpenseResponse(updatedExpens);
            expenseResponse.IsOverLimit = IsOverLimit; 

            return expenseResponse;
        }

        public async Task<bool> DeleteExpenseAsync(int expenseId, int userId)
        {
            return await _expenseRepo.DeleteExpenseAsync(expenseId, userId);
        }

    }

}

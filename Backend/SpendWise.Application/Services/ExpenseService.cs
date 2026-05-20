using SpendWise.Application.DTOs.Expense;
using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.Interfaces.ExchangeRate;
using SpendWise.Application.Interfaces.Expenses;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Domain.Constants;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SpendWise.Infrastructure.Services
{
    public class ExpenseService : IExpenseService
    {
        private readonly IExpenseRepository _expenseRepo;
        private readonly IWalletRepository _walletRepo;
        private readonly IExchangeRateService _exchangeRateService;

        public ExpenseService(
            IExpenseRepository expenseRepo,
            IWalletRepository walletRepo,
            IExchangeRateService exchangeRateService)
        {
            _expenseRepo = expenseRepo;
            _walletRepo = walletRepo;
            _exchangeRateService = exchangeRateService;
        }

        // Helpers methods --------------------------------------------------
        private Expense MapExpenseDTOtoExpenseObject(ExpenseDTO expenseDto)
        {
            return new Expense
            (
                expenseDto.ExpenseId,
                expenseDto.UserId,
                expenseDto.Title,
                expenseDto.Amount,
                expenseDto.Products,
                expenseDto.ExpenseTagId == -1 ? -1 : expenseDto.ExpenseTagId,
                expenseDto.CategoryId,
                expenseDto.WalletId,
                MapExpenseDTOtoTransactionObject(expenseDto),
                expenseDto.Date
            );
        }

        private Transaction MapExpenseDTOtoTransactionObject(ExpenseDTO expenseDto)
        {
            var transaction = new Transaction
            (
                -1,
                expenseDto.UserId,
                expenseDto.Title,
                expenseDto.Description,
                expenseDto.WalletId,
                expenseDto.Amount,
                0.0m, // amount in SP: Calculated later through the process
                expenseDto.Date,
                enTransactionType.Dedduction,
                -1,
                -1,
                -1,
                -1
            );

            // Custom attributes for expenses
            transaction.ExpenseId = expenseDto.ExpenseId;
            transaction.TransactionTagId = expenseDto.ExpenseTagId == -1 ? -1 : expenseDto.ExpenseTagId;
            transaction.TransactionCategoryId = expenseDto.CategoryId;

            return transaction;
        }

        private async Task<decimal> CalcAmountInSp(Wallet wallet, decimal amount)
        {
            if (wallet.CurrencyId == SupportedCurrencies.SyrianPoundId)
            {
                return amount;
            }

            Currency? walletCurrency = SupportedCurrencies.GetById(wallet.CurrencyId);
            if (walletCurrency == null) return 0.0m;

            return await _exchangeRateService.NormalizeToSyrianPound(walletCurrency.Code, "damascus", "sell", amount);
        }

        // Reading methods --------------------------------------------------
        public async Task<ExpenseResponse?> GetExpenseAsync(int expenseId, int userId)
        {
            var expense = await _expenseRepo.GetExpenseAsync(expenseId, userId);
            return expense == null ? null : new ExpenseResponse(expense);
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
            var newExpense = MapExpenseDTOtoExpenseObject(expenseDto);

            var wallet = await _walletRepo.GetWalletByIdAsync(newExpense.WalletId, newExpense.UserId);
            if (wallet == null) return null;

            newExpense.LinkedTransaction.AmountInSp = await CalcAmountInSp(wallet, newExpense.Amount);

            (int newExpenseId, bool IsOverLimit) = await _expenseRepo.AddExpenseAsync(newExpense);

            if (newExpenseId == -1) return null;

            newExpense.ExpenseId = newExpenseId;
            newExpense.LinkedTransaction.TransactionId = newExpenseId;

            var expenseResponse = new ExpenseResponse(newExpense);
            expenseResponse.IsOverLimit = IsOverLimit;

            return expenseResponse;
        }

        public async Task<ExpenseResponse?> AddExpenseViaOcrAsync(byte[] rawImageFile, string mimType, ExpenseDTO expenseDto)
        {
            return null;
        }

        public async Task<ExpenseResponse?> UpdateExpenseAsync(ExpenseDTO expenseDto)
        {
            var updatedExpense = MapExpenseDTOtoExpenseObject(expenseDto);

            var wallet = await _walletRepo.GetWalletByIdAsync(updatedExpense.WalletId, updatedExpense.UserId);
            if (wallet == null) return null;

            updatedExpense.LinkedTransaction.AmountInSp = await CalcAmountInSp(wallet, updatedExpense.Amount);

            (bool Success, bool IsOverLimit) = await _expenseRepo.UpdateExpenseAsync(updatedExpense);

            if (!Success) return null;

            var expenseResponse = new ExpenseResponse(updatedExpense);
            expenseResponse.IsOverLimit = IsOverLimit;

            return expenseResponse;
        }

        public async Task<bool> DeleteExpenseAsync(int expenseId, int userId)
        {
            return await _expenseRepo.DeleteExpenseAsync(expenseId, userId);
        }
    }
}
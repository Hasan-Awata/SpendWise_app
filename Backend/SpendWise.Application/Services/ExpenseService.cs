using Microsoft.Data.SqlClient;
using SpendWise.Application.DTOs.Expense;
using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.Interfaces.ExchangeRate;
using SpendWise.Application.Interfaces.Expenses;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Domain.Common;
using SpendWise.Domain.Constants;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SpendWise.Application.Services
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
                -1, -1, -1, -1
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

        // Shared Local Validation Helper (No DB Operations)
        private Result ValidateBaseExpenseInput(ExpenseDTO expenseDto)
        {
            if (expenseDto.Amount <= 0)
                return Result.Failure("Expense amount must be greater than zero.");

            if (!SystemCategories.Map.ContainsKey(expenseDto.CategoryId))
                return Result.Failure("The selected category is invalid.");

            return Result.Success();
        }

        // Reading methods --------------------------------------------------
        public async Task<Result<ExpenseResponse>> GetExpenseAsync(int expenseId, int userId)
        {
            var expense = await _expenseRepo.GetExpenseAsync(expenseId, userId);

            if (expense == null)
                return Result<ExpenseResponse>.Failure("Expense was not found.");

            return Result<ExpenseResponse>.Success(new ExpenseResponse(expense));
        }

        public async Task<Result<PagedResponse<ExpenseResponse>>> GetExpenseByUserAsync(int userId, PageDTO pageDto)
        {
            var (expensesList, totalCount) = await _expenseRepo.GetExpensesByUserAsync(userId, pageDto.PageNumber, pageDto.PageSize);
            var expenseResponse = expensesList.Select(item => new ExpenseResponse(item)).ToList();

            var data = new PagedResponse<ExpenseResponse>(expenseResponse, pageDto.PageNumber, pageDto.PageSize, totalCount);

            return Result<PagedResponse<ExpenseResponse>>.Success(data);
        }

        // Writing methods --------------------------------------------------
        public async Task<Result<ExpenseResponse>> AddExpenseAsync(ExpenseDTO expenseDto)
        {
            // 1 - Input validations --------------------------------------------
            var validationResult = ValidateBaseExpenseInput(expenseDto);
            if (!validationResult.IsSuccess)
                return Result<ExpenseResponse>.Failure(validationResult.ErrorMessage!);

            var wallet = await _walletRepo.GetWalletByIdAsync(expenseDto.WalletId, expenseDto.UserId);
            if (wallet == null)
                return Result<ExpenseResponse>.Failure("Wallet does not exist.");

            if (wallet.Balance < expenseDto.Amount)
                return Result<ExpenseResponse>.Failure("Not enough money to make this expense.");

            expenseDto.ExpenseId = -1; // Make sure to send -1 to database (safe practice)

            // 2 - Map data ------------------------------------------------------
            var newExpense = MapExpenseDTOtoExpenseObject(expenseDto);

            newExpense.LinkedTransaction.AmountInSp = await CalcAmountInSp(wallet, newExpense.Amount);

            (int newExpenseId, bool IsOverLimit) = await _expenseRepo.AddExpenseAsync(newExpense);

            if (newExpenseId == -1)
                return Result<ExpenseResponse>.Failure("Failed to add the expense to the database.");

            newExpense.ExpenseId = newExpenseId;
            newExpense.LinkedTransaction.TransactionId = newExpenseId;

            // 3 - Form the response ----------------------------------------------
            var expenseResponse = new ExpenseResponse(newExpense)
            {
                IsOverLimit = IsOverLimit
            };

            return Result<ExpenseResponse>.Success(expenseResponse);
        }

        public async Task<Result<ExpenseResponse>> UpdateExpenseAsync(ExpenseDTO expenseDto)
        {
            // 1 - Local Input validations (Zero Database Hits) -------------------------
            var validationResult = ValidateBaseExpenseInput(expenseDto);
            if (!validationResult.IsSuccess)
                return Result<ExpenseResponse>.Failure(validationResult.ErrorMessage!);

            // 2 - Fetch Wallet solely for Currency mapping rules (Required by CalcAmountInSp)
            var wallet = await _walletRepo.GetWalletByIdAsync(expenseDto.WalletId, expenseDto.UserId);
            if (wallet == null)
                return Result<ExpenseResponse>.Failure("The target wallet does not exist.");

            // 3 - Map data directly ----------------------------------------------------
            var updatedExpense = MapExpenseDTOtoExpenseObject(expenseDto);

            updatedExpense.LinkedTransaction.AmountInSp = await CalcAmountInSp(wallet, updatedExpense.Amount);

            // 4 - Execute Blind Update (Database handles balance math and verification blocks)
            // Any ownership or balance constraint issues will bubble up through your SqlExceptionHandler automatically!
            (bool success, bool isOverLimit) = await _expenseRepo.UpdateExpenseAsync(updatedExpense);

            if (!success)
                return Result<ExpenseResponse>.Failure("Failed to update the expense in the database.");

            // 5 - Form the response ----------------------------------------------------
            var expenseResponse = new ExpenseResponse(updatedExpense)
            {
                IsOverLimit = isOverLimit
            };

            return Result<ExpenseResponse>.Success(expenseResponse);
        }

        public async Task<Result> DeleteExpenseAsync(int expenseId, int userId)
        {
            if (await _expenseRepo.DeleteExpenseAsync(expenseId, userId))
                return Result.Success();

            return Result.Failure("Failed to delete the expense from the database.");
        }
    }
}
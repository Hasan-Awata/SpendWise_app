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
using System.Text.Json;
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
        private Expense MapExpenseDTOtoExpenseObject(ExpenseDTO expenseDto, string products)
        {
            return new Expense
            (
                expenseDto.ExpenseId,
                expenseDto.UserId,
                expenseDto.Title,
                expenseDto.Amount,
                products,
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
                0.0m,
                expenseDto.Date,
                enTransactionType.Dedduction,
                -1, -1, -1, -1
            );

            transaction.ExpenseId = expenseDto.ExpenseId;
            transaction.TransactionTagId = expenseDto.ExpenseTagId == -1 ? -1 : expenseDto.ExpenseTagId;
            transaction.TransactionCategoryId = expenseDto.CategoryId;

            return transaction;
        }

        private async Task<decimal> CalcAmountInSp(int currencyId, decimal amount)
        {
            if (currencyId == SupportedCurrencies.SyrianPoundId)
            {
                return amount;
            }

            Currency? walletCurrency = SupportedCurrencies.GetById(currencyId);
            if (walletCurrency == null) return 0.0m;

            return await _exchangeRateService.NormalizeToSyrianPound(walletCurrency.Code, "damascus", "sell", amount);
        }

        private Result ValidateAndSerializeProducts(List<ProductDTO> products, out string serializedJson)
        {
            serializedJson = string.Empty;

            if (products == null || !products.Any())
            {
                return Result.Failure("The products list cannot be empty.", enErrorType.Validation);
            }

            foreach (var item in products)
            {
                if (item.Quantity < 1)
                    return Result.Failure("The quantity must at least be 1 for each product", enErrorType.Validation);

                if (string.IsNullOrWhiteSpace(item.Name))
                    return Result.Failure("Every product must include a valid item name.", enErrorType.Validation);

                if (item.Price < 0)
                    return Result.Failure($"Invalid price for product '{item.Name}'. Price cannot be negative.", enErrorType.Validation);
            }

            serializedJson = JsonSerializer.Serialize(products);
            return Result.Success();
        }

        // Reading methods --------------------------------------------------
        public async Task<Result<ExpenseResponse>> GetExpenseAsync(int expenseId, int userId)
        {
            var expense = await _expenseRepo.GetExpenseAsync(expenseId, userId);

            if (expense == null)
                return Result<ExpenseResponse>.Failure("Expense was not found.", enErrorType.NotFound);

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
            // 1 - Common Validations
            if (expenseDto.Amount <= 0)
                return Result<ExpenseResponse>.Failure("Expense amount must be greater than zero.", enErrorType.Validation);

            if (!SystemCategories.Map.ContainsKey(expenseDto.CategoryId))
                return Result<ExpenseResponse>.Failure("The selected category is invalid.", enErrorType.Validation);

            var productsValidation = ValidateAndSerializeProducts(expenseDto.Products, out string productsJson);
            if (!productsValidation.IsSuccess)
                return Result<ExpenseResponse>.Failure(productsValidation.ErrorMessage!, enErrorType.Validation);

            if (expenseDto.Products.Sum(p => p.Price) != expenseDto.Amount)
                return Result<ExpenseResponse>.Failure("The total amount doesn't match with total products prices", enErrorType.BalanceViolation);

            // Fetch the unique Currency Wallet Pair 
            var walletPair = await _walletRepo.GetUserWalletsPairAsync(expenseDto.UserId, expenseDto.WalletId);
            var expensesWallet = walletPair.FirstOrDefault(w => !w.IsSaved);
            var savingWallet = walletPair.FirstOrDefault(w => w.IsSaved);

            if (expensesWallet == null || savingWallet == null)
                return Result<ExpenseResponse>.Failure("Wallet pairing infrastructure not found.", enErrorType.NotFound);

            // Calculate precise splits based on primary wallet cash availability
            decimal amountFromPrimary;
            decimal amountFromSavings;

            if (expensesWallet.Balance >= expenseDto.Amount)
            {
                amountFromPrimary = expenseDto.Amount;
                amountFromSavings = 0.0m;
            }
            else
            {
                if (expensesWallet.Balance + savingWallet.Balance < expenseDto.Amount)
                {
                    return Result<ExpenseResponse>.Failure("Not enough combined money across your wallets to complete this expense.", enErrorType.BalanceViolation);
                }

                amountFromPrimary = expensesWallet.Balance;
                amountFromSavings = expenseDto.Amount - expensesWallet.Balance; 
            }

            // Calculate SP normalization using total expense cost, not just the remainder
            decimal totalAmountInSp = await CalcAmountInSp(expensesWallet.CurrencyId, expenseDto.Amount);
            if (totalAmountInSp <= 0)
            {
                return Result<ExpenseResponse>.Failure("Failed to calculate currency exchange normalization metrics.", enErrorType.Failure);
            }

            expenseDto.ExpenseId = -1;

            // 2 - Map and Save Data
            var newExpense = MapExpenseDTOtoExpenseObject(expenseDto, productsJson);
            newExpense.LinkedTransaction.AmountInSp = totalAmountInSp;

            int newExpenseId;
            bool isOverLimit;

            if (amountFromSavings == 0.0m)
            {
                (newExpenseId, isOverLimit) = await _expenseRepo.AddExpenseAsync(newExpense);
            }
            else
            {
                (newExpenseId, isOverLimit) = await _expenseRepo.AddExpenseUsingBothWalletsAsync(
                    newExpense,
                    expensesWallet.WalletId,
                    savingWallet.WalletId,
                    amountFromPrimary,
                    amountFromSavings);
            }

            if (newExpenseId == -1)
                return Result<ExpenseResponse>.Failure("Failed to add the expense to the database.", enErrorType.Failure);

            newExpense.ExpenseId = newExpenseId;
            newExpense.LinkedTransaction.TransactionId = newExpenseId;

            // 3 - Form Response
            var expenseResponse = new ExpenseResponse(newExpense) { IsOverLimit = isOverLimit, CurrencyId = expensesWallet.CurrencyId };
            return Result<ExpenseResponse>.Success(expenseResponse);
        }

        public async Task<Result<ExpenseResponse>> UpdateExpenseAsync(ExpenseDTO expenseDto)
        {
            // 1 - Common Validations
            if (expenseDto.Amount <= 0)
                return Result<ExpenseResponse>.Failure("Expense amount must be greater than zero.", enErrorType.Validation);

            if (!SystemCategories.Map.ContainsKey(expenseDto.CategoryId))
                return Result<ExpenseResponse>.Failure("The selected category is invalid.", enErrorType.Validation);

            var productsValidation = ValidateAndSerializeProducts(expenseDto.Products, out string productsJson);
            if (!productsValidation.IsSuccess)
                return Result<ExpenseResponse>.Failure(productsValidation.ErrorMessage!, enErrorType.Validation);

            if (expenseDto.Products.Sum(p => p.Price) != expenseDto.Amount)
                return Result<ExpenseResponse>.Failure("The total amount doesn't match with total products prices", enErrorType.BalanceViolation);

            // Fetch the wallet pairings
            var walletPair = await _walletRepo.GetUserWalletsPairAsync(expenseDto.UserId, expenseDto.WalletId);
            var expensesWallet = walletPair.FirstOrDefault(w => !w.IsSaved);
            var savingWallet = walletPair.FirstOrDefault(w => w.IsSaved);

            if (expensesWallet == null || savingWallet == null)
                return Result<ExpenseResponse>.Failure("Wallet pairing infrastructure not found.", enErrorType.NotFound);

            // Calculate complete exchange normalization metrics
            decimal totalAmountInSp = await CalcAmountInSp(expensesWallet.CurrencyId, expenseDto.Amount);
            if (totalAmountInSp <= 0)
            {
                return Result<ExpenseResponse>.Failure("Failed to calculate currency exchange normalization metrics.", enErrorType.Failure);
            }

            // 2 - Map Data
            var updatedExpense = MapExpenseDTOtoExpenseObject(expenseDto, productsJson);
            updatedExpense.LinkedTransaction.AmountInSp = totalAmountInSp;

            var (success, isOverLimit) = await _expenseRepo.UpdateExpenseUsingBothWalletsAsync(
                updatedExpense,
                expensesWallet.WalletId,
                expenseDto.Amount > expensesWallet.Balance ? expensesWallet.Balance : expenseDto.Amount,
                expenseDto.Amount > expensesWallet.Balance ? expenseDto.Amount - expensesWallet.Balance : 0.0m
            );

            if (!success)
                return Result<ExpenseResponse>.Failure("Failed to update the expense in the database.", enErrorType.Failure);

            // 3 - Form Response
            var expenseResponse = new ExpenseResponse(updatedExpense) { IsOverLimit = isOverLimit, CurrencyId = expensesWallet.CurrencyId };
            return Result<ExpenseResponse>.Success(expenseResponse);
        }

        public async Task<Result> DeleteExpenseAsync(int expenseId, int userId)
        {
            if (await _expenseRepo.DeleteExpenseAsync(expenseId, userId))
                return Result.Success();

            return Result.Failure("Failed to delete the expense from the database.", enErrorType.Failure);
        }
    }
}
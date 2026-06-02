using SpendWise.Application.DTOs.SharedDebts;
using SpendWise.Application.Interfaces.ExchangeRate;
using SpendWise.Application.Interfaces.SharedDebts;
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
    public class SharedDebtService : ISharedDebtService
    {
        private readonly ISharedDebtRepository _debtRepo;
        private readonly IWalletRepository _walletRepo;
        private readonly IExchangeRateService _exchangeRateService;

        public SharedDebtService(
            ISharedDebtRepository debtRepo,
            IWalletRepository walletRepo,
            IExchangeRateService exchangeRateService)
        {
            _debtRepo = debtRepo;
            _walletRepo = walletRepo;
            _exchangeRateService = exchangeRateService;
        }

        // Helpers methods --------------------------------------------------

        private SharedDebt MapDTOToDebtObject(SharedDebtDTO debtDto, int debtId = -1)
        {
            return new SharedDebt(
                debtId,
                debtDto.CreditorID,
                debtDto.DebtorID,
                debtDto.Amount,
                debtDto.Title,
                debtDto.Status,
                debtDto.CreatedAt == default ? DateTime.UtcNow : debtDto.CreatedAt,
                debtDto.DueDate,
                debtDto.CreditorWalletID,
                debtDto.DebtorWalletID,
                debtDto.PaidAmount
            );
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

        private Result ValidateDebtDTO(SharedDebtDTO debtDto)
        {
            // Rule 1: Self-Debt Prevention
            if (debtDto.CreditorID == debtDto.DebtorID)
                return Result.Failure("Creditor and Debtor cannot be the same person.", enErrorType.Validation);

            // Rule 2: Amount Sanity
            if (debtDto.Amount <= 0)
                return Result.Failure("Debt amount must be greater than zero.", enErrorType.Validation);

            // Rule 5: Due Date Logic
            if (debtDto.DueDate <= debtDto.CreatedAt)
                return Result.Failure("Due date must be in the future relative to the creation date.", enErrorType.Validation);

            return Result.Success();
        }

        // Reading methods --------------------------------------------------

        public async Task<Result<IEnumerable<SharedDebtResponse>>> GetDebtsOwedToUserAsync(int userId)
        {
            var debts = await _debtRepo.GetDebtsOwedToUserAsync(userId);
            var response = debts.Select(item => new SharedDebtResponse(item));
            return Result<IEnumerable<SharedDebtResponse>>.Success(response);
        }

        public async Task<Result<IEnumerable<SharedDebtResponse>>> GetTheDebtsIHaveToPayAsync(int userId)
        {
            var debts = await _debtRepo.GetTheDebtsIHaveToPayAsync(userId);
            var response = debts.Select(item => new SharedDebtResponse(item));
            return Result<IEnumerable<SharedDebtResponse>>.Success(response);
        }

        public async Task<Result<SharedDebtResponse>> GetDebtByIdAsync(int debtId)
        {
            var debt = await _debtRepo.GetDebtByIdAsync(debtId);
            if (debt == null)
                return Result<SharedDebtResponse>.Failure("Debt record was not found.", enErrorType.NotFound);

            return Result<SharedDebtResponse>.Success(new SharedDebtResponse(debt));
        }

        public async Task<Result<SharedDebtResponse>> GetDebtByTitleAsync(string title)
        {
            if (string.IsNullOrWhiteSpace(title))
                return Result<SharedDebtResponse>.Failure("Title parameter cannot be empty.", enErrorType.Validation);

            var debt = await _debtRepo.GetDebtByTitleAsync(title);
            if (debt == null)
                return Result<SharedDebtResponse>.Failure("Debt record was not found.", enErrorType.NotFound);

            return Result<SharedDebtResponse>.Success(new SharedDebtResponse(debt));
        }

        public async Task<Result<IEnumerable<SharedDebtResponse>>> GetSharedDebtsForUserAsync(int userId)
        {
            var debts = await _debtRepo.GetSharedDebtsForUserAsync(userId);
            var response = debts.Select(item => new SharedDebtResponse(item));
            return Result<IEnumerable<SharedDebtResponse>>.Success(response);
        }

        public async Task<bool> DebtExistsAsyns(int debtId)
        {
            return await _debtRepo.DebtExistsAsync(debtId);
        }

        // Writing methods --------------------------------------------------

        public async Task<Result<int>> AddDebtAsync(SharedDebtDTO debtDto)
        {
            var validationResult = ValidateDebtDTO(debtDto);
            if (!validationResult.IsSuccess)
                return Result<int>.Failure(validationResult.ErrorMessage!, enErrorType.Validation);

            debtDto.PaidAmount = 0.0m; // Forced sanity setup
            var debt = MapDTOToDebtObject(debtDto, -1);

            int newDebtId = await _debtRepo.AddDebtAsync(debt);
            if (newDebtId == -1)
                return Result<int>.Failure("Failed to add the debt record to the database.", enErrorType.Failure);

            return Result<int>.Success(newDebtId);
        }

        public async Task<Result> UpdateDebtAsync(int debtId, SharedDebtDTO debtDto)
        {
            if (!await _debtRepo.DebtExistsAsync(debtId))
                return Result.Failure("Debt record not found.", enErrorType.NotFound);

            var validationResult = ValidateDebtDTO(debtDto);
            if (!validationResult.IsSuccess)
                return Result.Failure(validationResult.ErrorMessage!, enErrorType.Validation);

            var debt = MapDTOToDebtObject(debtDto, debtId);

            if (!await _debtRepo.UpdateDebtAsync(debt))
                return Result.Failure("Failed to update the debt details in the database.", enErrorType.Failure);

            return Result.Success();
        }

        public async Task<Result> DeleteDebtByIdAsync(int debtId)
        {
            if (!await _debtRepo.DebtExistsAsync(debtId))
                return Result.Failure("Debt record not found.", enErrorType.NotFound);

            if (!await _debtRepo.DeleteDebtByIdAsync(debtId))
                return Result.Failure("Failed to delete the debt record from the database.", enErrorType.Failure);

            return Result.Success();
        }

        public async Task<Result> DeletDebtByTitleAsync(string title)
        {
            if (string.IsNullOrWhiteSpace(title))
                return Result.Failure("Title cannot be empty.", enErrorType.Validation);

            if (!await _debtRepo.DeleteDebtByTitleAsync(title))
                return Result.Failure("Failed to delete the debt record, or title does not exist.", enErrorType.Failure);

            return Result.Success();
        }

        public async Task<Result> ReturnDebtAmountAsync(int debtId, ReturnDebtDTO returnDebtDTO)
        {
            var existingDebt = await _debtRepo.GetDebtByIdAsync(debtId);
            if (existingDebt == null)
                return Result.Failure("Debt record not found.", enErrorType.NotFound);

            // Rule 3: Overpayment Guard
            if (existingDebt.PaidAmount + returnDebtDTO.Amount > existingDebt.Amount)
                return Result.Failure($"Payment exceeds remaining balance. Max remaining payable: {existingDebt.Amount - existingDebt.PaidAmount}", enErrorType.Validation);

            // Rule 4 & Bug Fix: Verify debtor wallet details securely via repo lookup
            var debtorWallet = await _walletRepo.GetWalletByIdAsync(returnDebtDTO.DebtDTO.DebtorWalletID, returnDebtDTO.DebtDTO.DebtorID);
            if (debtorWallet == null)
                return Result.Failure("The specified debtor wallet could not be found.", enErrorType.NotFound);

            if (debtorWallet.Balance < returnDebtDTO.Amount)
                return Result.Failure("Insufficient funds available in the debtor's wallet to execute this transaction.", enErrorType.BalanceViolation);

            // Corrected normalization lookup using verified CurrencyId
            decimal amountInSp = await CalcAmountInSp(debtorWallet.CurrencyId, returnDebtDTO.Amount);
            if (amountInSp <= 0 && returnDebtDTO.Amount > 0)
                return Result.Failure("Failed to calculate currency exchange normalization metrics.", enErrorType.Failure);

            var debt = MapDTOToDebtObject(returnDebtDTO.DebtDTO, debtId);

            if (!await _debtRepo.ReturnDebtAmountAsync(debt, returnDebtDTO.Amount, returnDebtDTO.Title, returnDebtDTO.Description, amountInSp))
                return Result.Failure("Failed to execute and record the return payment in the database.", enErrorType.Failure);

            return Result.Success();
        }

        public async Task<Result> AcceptSharedDebtAsync(int debtId, ReturnDebtDTO returnDebtDTO)
        {
            var existingDebt = await _debtRepo.GetDebtByIdAsync(debtId);
            if (existingDebt == null)
                return Result.Failure("Debt record not found.", enErrorType.NotFound);

            // Rule 3: Overpayment Guard
            if (existingDebt.PaidAmount + returnDebtDTO.Amount > existingDebt.Amount)
                return Result.Failure($"Payment balance violation. Max remaining payable: {existingDebt.Amount - existingDebt.PaidAmount}", enErrorType.Validation);

            // Rule 4 & Bug Fix: Fetch real currency profile and confirm funds
            var debtorWallet = await _walletRepo.GetWalletByIdAsync(returnDebtDTO.DebtDTO.DebtorWalletID, returnDebtDTO.DebtDTO.DebtorID);
            if (debtorWallet == null)
                return Result.Failure("The specified debtor wallet could not be found.", enErrorType.NotFound);

            if (debtorWallet.Balance < returnDebtDTO.Amount)
                return Result.Failure("Insufficient funds available in the debtor's wallet.", enErrorType.BalanceViolation);

            decimal amountInSp = await CalcAmountInSp(debtorWallet.CurrencyId, returnDebtDTO.Amount);
            if (amountInSp <= 0 && returnDebtDTO.Amount > 0)
                return Result.Failure("Failed to calculate currency exchange normalization metrics.", enErrorType.Failure);

            var debt = MapDTOToDebtObject(returnDebtDTO.DebtDTO, debtId);

            if (!await _debtRepo.AcceptDebtAsync(debt, returnDebtDTO.Amount, returnDebtDTO.Title, returnDebtDTO.Description, amountInSp))
                return Result.Failure("Failed to securely accept debt records in the database.", enErrorType.Failure);

            return Result.Success();
        }

        public async Task<Result> RefuseDebtAsync(int debtId)
        {
            if (!await _debtRepo.DebtExistsAsync(debtId))
                return Result.Failure("Debt record not found.", enErrorType.NotFound);

            if (!await _debtRepo.RefuseDebtAsync(debtId))
                return Result.Failure("Failed to update database tracking for debt refusal.", enErrorType.Failure);

            return Result.Success();
        }
    }
}
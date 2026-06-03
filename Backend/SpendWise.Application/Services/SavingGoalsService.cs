using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.DTOs.SavingGoals;
using SpendWise.Application.DTOs.SavingsGoals;
using SpendWise.Application.Interfaces.ExchangeRate;
using SpendWise.Application.Interfaces.SavingGoals;
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
    public class SavingGoalsService : ISavingGoalService
    {
        private readonly ISavingGoalRepository _goalRepo;
        private readonly IWalletRepository _walletRepo;
        private readonly IExchangeRateService _exchangeRateService;

        public SavingGoalsService(
            ISavingGoalRepository goalRepo,
            IWalletRepository walletRepository,
            IExchangeRateService exchangeRateService)
        {
            _goalRepo = goalRepo;
            _walletRepo = walletRepository;
            _exchangeRateService = exchangeRateService;
        }

        // Centralized Mapping Helpers --------------------------------------

        private SavingGoal MapDTOToGoalObject(SavingGoalDTO dto, int userId, int goalId = -1)
        {
            return new SavingGoal(
                goalId,
                userId,
                dto.Title,
                dto.TargetAmount,
                dto.CurrentAmount,
                dto.DeadlineDate,
                dto.CurrencyId,
                dto.IsActive
            );
        }

        // Centralized Validations ------------------------------------------

        private Result ValidateGoalDTO(SavingGoalDTO dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Title))
                return Result.Failure("Saving goal title cannot be empty.", enErrorType.Validation);

            // Rule 3: Target Amount Limit
            if (dto.TargetAmount <= 0)
                return Result.Failure("Target amount must be greater than zero.", enErrorType.Validation);

            // Rule 2: Deadline Date Constraints
            if (dto.DeadlineDate <= DateTime.UtcNow)
                return Result.Failure("The goal deadline date must be set in the future.", enErrorType.Validation);

            return Result.Success();
        }

        // Reading Methods --------------------------------------------------

        public async Task<Result<SavingGoalResponse>> GetGoalByIdAsync(int goalId)
        {
            if (goalId <= 0)
                return Result<SavingGoalResponse>.Failure("Invalid goal ID.", enErrorType.Validation);

            var savingGoal = await _goalRepo.GetGoalByIdAsync(goalId);
            if (savingGoal == null)
                return Result<SavingGoalResponse>.Failure("Saving goal not found.", enErrorType.NotFound);

            return Result<SavingGoalResponse>.Success(new SavingGoalResponse(savingGoal));
        }

        public async Task<Result<PagedResponse<SavingGoalResponse>>> GetAllUserGoalsAsync(int userId, PageDTO pageDto)
        {
            if (userId <= 0)
                return Result<PagedResponse<SavingGoalResponse>>.Failure("Invalid user ID.", enErrorType.Validation);

            var (goals, totalCount) = await _goalRepo.GetAllUserGoalsAsync(userId, pageDto.PageNumber, pageDto.PageSize);

            if (goals == null || !goals.Any())
            {
                var emptyResponse = new PagedResponse<SavingGoalResponse>(new List<SavingGoalResponse>(), pageDto.PageNumber, pageDto.PageSize, 0);
                return Result<PagedResponse<SavingGoalResponse>>.Success(emptyResponse);
            }

            var goalsResponse = goals.Select(item => new SavingGoalResponse(item)).ToList();
            var pagedResponse = new PagedResponse<SavingGoalResponse>(goalsResponse, pageDto.PageNumber, pageDto.PageSize, totalCount);

            return Result<PagedResponse<SavingGoalResponse>>.Success(pagedResponse);
        }

        public async Task<Result<IEnumerable<SavingGoalResponse>>> GetAchievedGoalsAsync(int userId)
        {
            if (userId <= 0)
                return Result<IEnumerable<SavingGoalResponse>>.Failure("Invalid user ID.", enErrorType.Validation);

            var savingGoals = await _goalRepo.GetAchievedGoalsAsync(userId);
            var response = savingGoals.Select(item => new SavingGoalResponse(item)).ToList();

            return Result<IEnumerable<SavingGoalResponse>>.Success(response);
        }

        // Updated signature to match Task<Result<bool>> interface contract
        public async Task<Result<bool>> GoalExistsAsync(int goalId)
        {
            if (goalId <= 0)
                return Result<bool>.Failure("Invalid goal identifier.", enErrorType.Validation);

            var exists = await _goalRepo.GoalExistsAsync(goalId);
            return Result<bool>.Success(exists);
        }

        // Writing Methods --------------------------------------------------

        public async Task<Result<int>> AddGoalAsync(int userID, SavingGoalDTO savingGoalDto)
        {
            if (userID <= 0)
                return Result<int>.Failure("Invalid user identity correlation.", enErrorType.Validation);

            var validationResult = ValidateGoalDTO(savingGoalDto);
            if (!validationResult.IsSuccess)
                return Result<int>.Failure(validationResult.ErrorMessage!, enErrorType.Validation);

            var goal = MapDTOToGoalObject(savingGoalDto, userID, -1);

            int id = await _goalRepo.AddGoalAsync(goal);
            if (id == -1)
                return Result<int>.Failure("Failed to save the new saving goal.", enErrorType.Failure);

            return Result<int>.Success(id);
        }

        public async Task<Result> UpdateGoalAsync(int savingGoalId, SavingGoalDTO savingGoalDto)
        {
            if (savingGoalId <= 0)
                return Result.Failure("Invalid goal identifier.", enErrorType.Validation);

            if (!await _goalRepo.GoalExistsAsync(savingGoalId))
                return Result.Failure("Saving goal record not found.", enErrorType.NotFound);

            var validationResult = ValidateGoalDTO(savingGoalDto);
            if (!validationResult.IsSuccess)
                return Result.Failure(validationResult.ErrorMessage!, enErrorType.Validation);

            var goal = MapDTOToGoalObject(savingGoalDto, savingGoalDto.UserId, savingGoalId);

            if (!await _goalRepo.UpdateGoalAsync(goal))
                return Result.Failure("Failed to modify the saving goal details.", enErrorType.Failure);

            return Result.Success();
        }

        public async Task<Result> DeleteGoalAsync(int savingGoalId)
        {
            if (savingGoalId <= 0)
                return Result.Failure("Invalid goal identifier.", enErrorType.Validation);

            if (!await _goalRepo.GoalExistsAsync(savingGoalId))
                return Result.Failure("Saving goal record not found.", enErrorType.NotFound);

            if (!await _goalRepo.DeleteGoalAsync(savingGoalId))
                return Result.Failure("Failed to delete the saving goal.", enErrorType.Failure);

            return Result.Success();
        }

        // Transactional Operations -----------------------------------------

        // Updated signature to match Task<Result<bool>> interface contract
        public async Task<Result<bool>> AddAmountToSavingGoal(int savingGoalId, int walletId, int userId, double amount)
        {
            if (userId <= 0 || walletId <= 0 || savingGoalId <= 0)
                return Result<bool>.Failure("Invalid parameters provided.", enErrorType.Validation);

            if (amount <= 0)
                return Result<bool>.Failure("Deposit amount must be greater than zero.", enErrorType.Validation);

            var currentGoal = await _goalRepo.GetGoalByIdAsync(savingGoalId);
            if (currentGoal == null)
                return Result<bool>.Failure("Target saving goal does not exist.", enErrorType.NotFound);

            // Rule 4: Active/Achieved States Modifier
            if (currentGoal.IsAchieved)
                return Result<bool>.Failure("Cannot deposit into an inactive saving goal.", enErrorType.Validation);

            if (currentGoal.CurrentAmount >= currentGoal.TargetAmount)
                return Result<bool>.Failure("Cannot deposit funds into a goal that has already been achieved.", enErrorType.Validation);

            // Rule 5: Account Mapping Flexibility
            var wallet = await _walletRepo.GetWalletByIdAsync(walletId, userId);
            if (wallet == null)
                return Result<bool>.Failure("Source wallet was not found.", enErrorType.NotFound);

            decimal amountFromWallet = Convert.ToDecimal(amount);
            if (wallet.Balance < amountFromWallet)
                return Result<bool>.Failure("Insufficient funds in the selected wallet.", enErrorType.BalanceViolation);

            decimal amountToSavingGoal = amountFromWallet;
            decimal amountSYR = amountFromWallet;

            // Handle Cross-Currency Adjustments
            if (wallet.CurrencyId != currentGoal.CurrencyId)
            {
                var walletCurrency = SupportedCurrencies.GetById(wallet.CurrencyId);
                var goalCurrency = SupportedCurrencies.GetById(currentGoal.CurrencyId);

                if (walletCurrency == null || goalCurrency == null)
                    return Result<bool>.Failure("Currency structural models are missing.", enErrorType.Failure);

                amountSYR = await _exchangeRateService.NormalizeToSyrianPound(walletCurrency.Code, "Damascus", "sell", amountFromWallet);
                amountToSavingGoal = await _exchangeRateService.NormalizeFromSyrianPound(goalCurrency.Code, "Damascus", "sell", amountSYR);
            }

            // Rule 1: Over-Funding Guard
            if (currentGoal.CurrentAmount + amountToSavingGoal > currentGoal.TargetAmount)
            {
                decimal maxAllowed = currentGoal.TargetAmount - currentGoal.CurrentAmount;
                return Result<bool>.Failure($"Deposit exceeds target limits. Maximum remaining deposit allowed: {maxAllowed} in target currency.", enErrorType.Validation);
            }

            bool txDone = await _goalRepo.AddAmountToSavingGoalTransactionAsync(savingGoalId, walletId, userId, amountFromWallet, amountToSavingGoal, amountSYR);
            if (!txDone)
                return Result<bool>.Failure("Failed to safely commit the deposit transaction.", enErrorType.Failure);

            return Result<bool>.Success(true);
        }

        // Updated signature to match Task<Result<bool>> interface contract
        public async Task<Result<bool>> WithdrawAmountFromSavingGoal(int savingGoalId, int walletId, int userId, double amount)
        {
            if (userId <= 0 || walletId <= 0 || savingGoalId <= 0)
                return Result<bool>.Failure("Invalid parameters provided.", enErrorType.Validation);

            if (amount <= 0)
                return Result<bool>.Failure("Withdrawal amount must be greater than zero.", enErrorType.Validation);

            var currentGoal = await _goalRepo.GetGoalByIdAsync(savingGoalId);
            if (currentGoal == null)
                return Result<bool>.Failure("Target saving goal does not exist.", enErrorType.NotFound);

            // Rule 4: Active States Modifier
            if (currentGoal.IsAchieved)
                return Result<bool>.Failure("Cannot execute withdrawals from an inactive saving goal.", enErrorType.Validation);

            decimal amountFromGoal = Convert.ToDecimal(amount);
            if (currentGoal.CurrentAmount < amountFromGoal)
                return Result<bool>.Failure("Insufficient balances saved within this specific goal.", enErrorType.Validation);

            // Rule 5: Account Mapping Flexibility
            var wallet = await _walletRepo.GetWalletByIdAsync(walletId, userId);
            if (wallet == null)
                return Result<bool>.Failure("Destination wallet was not found.", enErrorType.NotFound);

            decimal amountToWallet = amountFromGoal;
            decimal amountSYR = amountFromGoal;

            // Handle Cross-Currency Adjustments
            if (wallet.CurrencyId != currentGoal.CurrencyId)
            {
                var goalCurrency = SupportedCurrencies.GetById(currentGoal.CurrencyId);
                var walletCurrency = SupportedCurrencies.GetById(wallet.CurrencyId);

                if (goalCurrency == null || walletCurrency == null)
                    return Result<bool>.Failure("Currency structural models are missing.", enErrorType.Failure);

                amountSYR = await _exchangeRateService.NormalizeToSyrianPound(goalCurrency.Code, "Damascus", "sell", amountFromGoal);
                amountToWallet = await _exchangeRateService.NormalizeFromSyrianPound(walletCurrency.Code, "Damascus", "sell", amountSYR);
            }

            bool txDone = await _goalRepo.WithdrawAmountFromSavingGoalTransactionAsync(savingGoalId, walletId, userId, amountFromGoal, amountToWallet, amountSYR);
            if (!txDone)
                return Result<bool>.Failure("Failed to safely execute the withdrawal transaction.", enErrorType.Failure);

            return Result<bool>.Success(true);
        }
    }
}
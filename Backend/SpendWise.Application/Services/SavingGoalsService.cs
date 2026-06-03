using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.DTOs.SavingGoals;
using SpendWise.Application.DTOs.SavingsGoals;
using SpendWise.Application.Interfaces.ExchangeRate;
using SpendWise.Application.Interfaces.SavingGoals;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Domain.Constants;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Text;

namespace SpendWise.Application.Services
{
    public class SavingGoalsService :ISavingGoalService
    {
        private readonly IWalletRepository _walletRepo;
        private readonly ISavingGoalRepository _goalRepo;
        private readonly IExchangeRateService _exchangeRateService;
        public SavingGoalsService(ISavingGoalRepository goalRepo ,IWalletRepository walletRepository, IExchangeRateService exchangeRateService) {
            _walletRepo = walletRepository;
            _exchangeRateService = exchangeRateService;

        
        _goalRepo = goalRepo;
        }

        public async Task<SavingGoalResponse?> GetGoalByIdAsync(int goalId)
        {
            
            if (_goalRepo == null)
                return null;
               
                var savingGoals= await _goalRepo.GetGoalByIdAsync(goalId);

              if (savingGoals == null)
                return null;

              
            
            return new SavingGoalResponse(savingGoals);
                        

        }
        public async Task<bool> AddAmountToSavingGoal(int savingGoalId, int walletId, int userId, double amount)
        {
            if (userId <= 0)
                return false;
            if (amount == 0)
                return true;

            if (amount < 0)
                return false;
            if (walletId <= 0) return false;

            if (savingGoalId <= 0) { return false; }


            var CurrentSavingGoal = await _goalRepo.GetGoalByIdAsync(savingGoalId);

            if (CurrentSavingGoal == null)
                return false;


            var wallet = await _walletRepo.GetWalletByIdAsync(walletId, userId);
            if (wallet == null) return false;


            if (wallet.Balance < Convert.ToDecimal(amount))
                return false;


            decimal amountFromWallet = Convert.ToDecimal(amount);
            decimal amountToSavingGoal = amountFromWallet;
            decimal amountSYR = 0;


              if (wallet.CurrencyId != CurrentSavingGoal.CurrencyId)
            {
                 var walletCurrency = SupportedCurrencies.GetById(wallet.CurrencyId);
                var goalCurrency = SupportedCurrencies.GetById(CurrentSavingGoal.CurrencyId);

                if (walletCurrency == null || string.IsNullOrEmpty(walletCurrency.Code) ||
                    goalCurrency == null || string.IsNullOrEmpty(goalCurrency.Code))
                    return false;

                amountSYR = await _exchangeRateService.NormalizeToSyrianPound(walletCurrency.Code, "Damascus", "black_market", amountFromWallet);
                 decimal amountAsSavingGoal = await _exchangeRateService.NormalizeFromSyrianPound(goalCurrency.Code, "black_market", amountSYR);
                amountToSavingGoal = Convert.ToDecimal(amountAsSavingGoal);
            }
            else
            {
                 amountToSavingGoal = amountFromWallet;
                     amountSYR = amountFromWallet;

                    }


              if (await _goalRepo.AddAmountToSavingGoalTransactionAsync(savingGoalId, walletId, userId, amountFromWallet, amountToSavingGoal, amountSYR))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        public async Task<bool> WithdrawAmountFromSavingGoal(int savingGoalId, int walletId, int userId, double amount)
        {
            if (userId <= 0)
                return false;
            if (amount == 0) return true;
            if (amount < 0)
                return false;
            if (walletId <= 0) return false;
            if (savingGoalId <= 0) return false;


             var CurrentSavingGoal = await _goalRepo.GetGoalByIdAsync(savingGoalId);

            if (CurrentSavingGoal == null)
                return false;

            if (CurrentSavingGoal.CurrentAmount < Convert.ToDecimal(amount))
                return false;

   var wallet = await _walletRepo.GetWalletByIdAsync(walletId, userId);
            if (wallet == null) return false;


             var goalCurrency = SupportedCurrencies.GetById(CurrentSavingGoal.CurrencyId);
            var walletCurrency = SupportedCurrencies.GetById(wallet.CurrencyId);

            if (goalCurrency == null || string.IsNullOrEmpty(goalCurrency.Code) ||
                walletCurrency == null || string.IsNullOrEmpty(walletCurrency.Code))
                return false;


            decimal amountFromGoal = Convert.ToDecimal(amount);
            decimal amountToWallet = amountFromGoal;
            decimal amountSYR = 0;

            try
            {
                 if (wallet.CurrencyId != CurrentSavingGoal.CurrencyId)
                {   amountSYR = await _exchangeRateService.NormalizeToSyrianPound(
                        goalCurrency.Code, "Damascus", "sell", amountFromGoal);

                      decimal amountAsWallet = await _exchangeRateService.NormalizeFromSyrianPund(
                        walletCurrency.Code, "Damascus", amountSYR);


                decimal amountAsSavingGoal = await _exchangeRateService.NormalizeFromSyrianPound(SupportedCurrencies.GetById(wallet.CurrencyId).Code, "black_market", amountSYR);



                wallet.Balance += Convert.ToDecimal(amountAsSavingGoal);
            }
            else
            {


             if (await _goalRepo.WithdrawAmountFromSavingGoalTransactionAsync(savingGoalId, walletId, userId, amountFromGoal, amountToWallet, amountSYR))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        public async Task<PagedResponse<SavingGoalResponse>> GetAllUserGoalsAsync(int userId, PageDTO pageDto)
        {
            
            var (goals, totalCount) = await _goalRepo.GetAllUserGoalsAsync(userId, pageDto.PageNumber, pageDto.PageSize);

          
            if (goals == null || !goals.Any())
            {
                return new PagedResponse<SavingGoalResponse>(new List<SavingGoalResponse>(), pageDto.PageNumber, pageDto.PageSize, 0);
            }

         
            var goalsResponse = goals.Select(item => new SavingGoalResponse
            {
                GoalID = item.GoalID,
                UserID = item.UserID,
                Title = item.Title,
                TargetAmount = item.TargetAmount,
                CurrentAmount = item.CurrentAmount,
                DeadlineDate = item.DeadlineDate
            }).ToList();

            return new PagedResponse<SavingGoalResponse>(goalsResponse, pageDto.PageNumber, pageDto.PageSize, totalCount);
        }

        public async Task<int>AddGoalAsync (int userID,SavingGoalDTO savingGoal)
        {
            if (userID <= 0 )
                return -1;
            if (savingGoal==null)
                return -1;

            
            var savinggoal =new SavingGoal(-1,userID,savingGoal.Title,savingGoal.TargetAmount,savingGoal.CurrentAmount,savingGoal.DeadlineDate,savingGoal.CurrencyId,savingGoal.IsActive);
             
            int id = await _goalRepo.AddGoalAsync(savinggoal);
            if (id == -1)
            {
                return -1;
            }
            return id;
        }
        public async Task<bool> UpdateGoalAsync(int savingGoalId,SavingGoalDTO savingGoal)
        {
            if (savingGoalId <= 0)
                return false;
            if (savingGoal==null )
                return false;

            var savinggoal = new SavingGoal(savingGoalId, savingGoal.UserId, savingGoal.Title, savingGoal.TargetAmount, savingGoal.CurrentAmount, savingGoal.DeadlineDate,savingGoal.CurrencyId,savingGoal.IsActive);

            return await _goalRepo.UpdateGoalAsync(savinggoal);
            

        }
        public async Task<bool> DeleteGoalAsync(int savingGoalId)
        {
            if (savingGoalId <= 0)
                return false;
            return await _goalRepo.DeleteGoalAsync(savingGoalId);
          
        }

        public async Task<bool> GoalExistsAsync(int goalId)
        {
            if (goalId <=0 )    return false;
            return await _goalRepo.GoalExistsAsync(goalId);
           // return false;
        }
        public async Task<IEnumerable<SavingGoalResponse>> GetAchievedGoalsAsync(int userId)
        {
            if (userId <= 0)
                return Enumerable.Empty<SavingGoalResponse>();

            IEnumerable<SavingGoal> savingGoals = new List<SavingGoal>();

            savingGoals =await _goalRepo.GetAchievedGoalsAsync(userId);


            return savingGoals.Select(item => new SavingGoalResponse
            {
                GoalID = item.GoalID,
                UserID = item.UserID,
                Title = item.Title,
                TargetAmount = item.TargetAmount,
                CurrentAmount = item.CurrentAmount,
                DeadlineDate = item.DeadlineDate




            }).ToList();
        }
    }


}


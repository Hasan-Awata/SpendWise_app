using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.DTOs.SavingGoals;
using SpendWise.Application.DTOs.SavingsGoals;
using SpendWise.Application.Interfaces.SavingGoals;
using SpendWise.Application.Interfaces.Wallets;
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
        public SavingGoalsService(ISavingGoalRepository goalRepo ,IWalletRepository walletRepository) {
            _walletRepo = walletRepository;
        
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
        public async Task<bool>AddAmountToSavingGoal(int savingGoalId,int walletId,int userId,double amount)
        {
            if (userId==-1)
                return false;
            if (amount == 0)
                return true;

            if (amount<0)
                return false;
            if (walletId==-1) return false;
            

            if (savingGoalId == -1) {  return false; }


            var CurrentSavingGoal = await _goalRepo.GetGoalByIdAsync(savingGoalId);

            if(CurrentSavingGoal == null)
                return false;

            
               var wallet = await _walletRepo.GetWalletByIdAsync(walletId, userId);
            if (wallet == null) return false;
           

            if (wallet.Balance < Convert.ToDecimal(amount))
                return false;
           
            // Convert type of balance to dolar $$

            wallet.Balance -= Convert.ToDecimal(amount);
            
            if (!await _walletRepo.UpdateWalletAsync(wallet))
                return false;




            CurrentSavingGoal.CurrentAmount +=Convert.ToDecimal( amount);


            return await _goalRepo.UpdateGoalAsync(CurrentSavingGoal);

       

            
        }
        public async Task<bool>WithdrawAmountFromSavingGoal (int savingGoalId ,int walletId ,int userId ,double amount)
        {
            
            if (userId == -1)
                return false;
            if (amount == 0) return true;
            if (amount<0)
                return false;
            if (walletId == -1) return false;


            if (savingGoalId == -1) { return false; }


            var CurrentSavingGoal = await _goalRepo.GetGoalByIdAsync(savingGoalId);

            if (CurrentSavingGoal == null)
                return false;

            if (CurrentSavingGoal.CurrentAmount < Convert.ToDecimal(amount))
                return false;



            var wallet = await _walletRepo.GetWalletByIdAsync(walletId, userId);
            if (wallet == null) return false;

            //Convert the currency type to the type available in your wallet.

            wallet.Balance +=Convert.ToDecimal( amount);
            if (!await _walletRepo.UpdateWalletAsync(wallet) ) return false;


            return await _goalRepo.UpdateGoalAsync(CurrentSavingGoal);

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
            if (userID == -1)
                return -1;
            
            var savinggoal =new SavingGoal(-1,userID,savingGoal.Title,savingGoal.TargetAmount,savingGoal.CurrentAmount,savingGoal.DeadlineDate);
            
            return await _goalRepo.AddGoalAsync(savinggoal);
            
        }
        public async Task<bool> UpdateGoalAsync(int savingGoalId,SavingGoalDTO savingGoal)
        {
            if (savingGoalId == -1)
                return false;

            var savinggoal = new SavingGoal(savingGoalId, savingGoal.UserId, savingGoal.Title, savingGoal.TargetAmount, savingGoal.CurrentAmount, savingGoal.DeadlineDate);

            return await _goalRepo.UpdateGoalAsync(savinggoal);
            

        }
        public async Task<bool> DeleteGoalAsync(int savingGoalId)
        {
            if (savingGoalId == -1)
                return false;
            return await _goalRepo.DeleteGoalAsync(savingGoalId);
          
        }

        public async Task<bool> GoalExistsAsync(int goalId)
        {
            return await _goalRepo.GoalExistsAsync(goalId);
           // return false;
        }
        public async Task<IEnumerable<SavingGoalResponse>> GetAchievedGoalsAsync(int userId)
        {

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


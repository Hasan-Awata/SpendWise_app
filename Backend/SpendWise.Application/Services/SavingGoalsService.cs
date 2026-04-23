using SpendWise.Application.DTOs.SavingGoals;
using SpendWise.Application.DTOs.SavingsGoals;
using SpendWise.Application.Interfaces.SavingGoals;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Text;

namespace SpendWise.Application.Services
{
    public class SavingGoalsService :ISavingGoalService
    {

        private readonly ISavingGoalRepository _goalRepo;
        public SavingGoalsService(ISavingGoalRepository goalRepo) { 
        
        _goalRepo = goalRepo;
        }

        public async Task<SavingGoalResponse?> GetGoalByIdAsync(int goalId)
        {
            //UnComment Later *_*
            if (_goalRepo == null)
                return null;
               
                SavingGoal savingGoals
                                        = await _goalRepo.GetGoalByIdAsync(goalId);

              if (savingGoals == null)
                return null;
                return new SavingGoalResponse(savingGoals);
                        

        }

        public  async Task<IEnumerable<SavingGoalResponse>>? GetAllUserGoalsAsync(int userId)
        {
            IEnumerable<SavingGoal> savingGoals = new List<SavingGoal>();

            savingGoals =await _goalRepo.GetAllUserGoalsAsync(userId);


            return savingGoals.Select(item => new SavingGoalResponse
            {
                GoalID = item.GoalID,
                UserID = item.UserID,
                Title = item.Title,
                TargetAmount = item.TargetAmount,
                CurrentAmount = item.CurrentAmount,
                DeadlineDate = item.DeadlineDate




            });
        }
    

        public async Task<int>AddGoalAsync (int userID,SavingGoalDTO savingGoal)
        {

            var savinggoal =new SavingGoal(-1,userID,savingGoal.Title,savingGoal.TargetAmount,savingGoal.CurrentAmount,savingGoal.DeadlineDate);
            return await _goalRepo.AddGoalAsync(savinggoal);
            
        }
        public async Task<bool> UpdateGoalAsync(int savingGoalId,SavingGoalDTO savingGoal)
        {
            var savinggoal = new SavingGoal(savingGoalId, savingGoal.UserId, savingGoal.Title, savingGoal.TargetAmount, savingGoal.CurrentAmount, savingGoal.DeadlineDate);

            return await _goalRepo.UpdateGoalAsync(savinggoal);
            

        }
        public async Task<bool> DeleteGoalAsync(int savingGoalId)
        {
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


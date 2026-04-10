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

        /*private readonly ISavingGoalsRepository _goalRepo;
        public SavingGoalsService(ISavingGoalsRepository goalRepo) { 
        
        _goalRepo = goalRepo;
        }*/

        public async Task<SavingGoalResponse?> GetGoalByIdAsync(int userID,int goalId)
        {
            //UnComment Later *_*
            //SavingGoals savingGoals =await _goalRepo .GetGoalByIdAsync(userID,goalId);
            
            // return new SavingGoalsResponse(savingGoals)
            return null;


        }

        public  async Task<IEnumerable<SavingGoalResponse>>? GetAllUserGoalsAsync(int userId)
        {
            IEnumerable<SavingGoal> savingGoals = new List<SavingGoal>();

            //savingGoals =awiat _goalRepo.GetAllUserGoalAsynce(userId);


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
            //return await _goalRepo.AddGoalAsync(userID,savingGoal);
            return -1;

        }
        public async Task<bool> UpdateGoalAsync(int savingGoalId,SavingGoalDTO savingGoal)
        {
            //return await _goalRepo.UpdateGoalAsync(savingGoalId,savingGoal);
            return false;  

        }
        public async Task<bool> DeleteGoalAsync(int savingGoalId)
        {
            //return await _goalRepo.DeleteAsync(savingGoalId);
            return false;
        }

        public async Task<bool> GoalExistsAsync(int goalId)
        {
            //return await _goalRepo.GoalExistsAsync(goalId);
            return false;
        }
        public async Task<IEnumerable<SavingGoalResponse>> GetAchievedGoalsAsync(int userId)
        {

            IEnumerable<SavingGoal> savingGoals = new List<SavingGoal>();

            //savingGoals =awiat _goalRepo.GetAchievedGoalsAsync(userId);


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
    }


}


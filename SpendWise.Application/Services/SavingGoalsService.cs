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
    public class SavingGoalsService :ISavingGoals
    {

        /*private readonly ISavingGoalsRepository _goalRepo;
        public SavingGoalsService(ISavingGoalsRepository goalRepo) { 
        
        _goalRepo = goalRepo;
        }*/

        public async Task<SavingGoalsResponse?> GetGoalByIdAsync(int goalId)
        {
            //UnComment Later *_*
            //SavingGoals savingGoals =await _goalRepo .GetGoalByIdAsync(goalId);
            
            // return new SavingGoalsResponse(savingGoals)
            return null;


        }

        public  async Task<IEnumerable<SavingGoalsResponse>>? GetAllUserGoalsAsync(int userId)
        {
            IEnumerable<SavingGoals> savingGoals = new List<SavingGoals>();

            //savingGoals =awiat _goalRepo.GetAllUserGoalAsynce(userId);


            return savingGoals.Select(item => new SavingGoalsResponse
            {
                GoalID = item.GoalID,
                UserID = item.UserID,
                Title = item.Title,
                TargetAmount = item.TargetAmount,
                CurrentAmount = item.CurrentAmount,
                DeadlineDate = item.DeadlineDate




            });
        }
    

        public async Task<bool>AddGoalAsync (SavingGoalsDTO savingGoal)
        {
            //return await _goalRepo.AddGoalAsync(savingGoal);
            return false;

        }
        public async Task<bool> UpdateGoalAsync(int savingGoalId,SavingGoalsDTO savingGoal)
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
        public async Task<IEnumerable<SavingGoalsResponse>> GetAchievedGoalsAsync(int userId)
        {

            IEnumerable<SavingGoals> savingGoals = new List<SavingGoals>();

            //savingGoals =awiat _goalRepo.GetAchievedGoalsAsync(userId);


            return savingGoals.Select(item => new SavingGoalsResponse
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


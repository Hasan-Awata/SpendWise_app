using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.SavingGoals;
using SpendWise.Application.DTOs.SavingsGoals;
using SpendWise.Application.Interfaces.SavingGoals;
using SpendWise.Domain.Entities;
using System.Security.Claims;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/Saving_Goal")]
    public class SavingGoalController : ControllerBase
    {
        private readonly ISavingGoalService _savingGoalService;
        public SavingGoalController(ISavingGoalService savingGoalService)
        {
            _savingGoalService = savingGoalService;
        }

        private int CurrentUserId
        {
            get
            {
                // 1. Get the string value from the claim
                var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                // 2. Safely attempt to parse it into an integer
                if (int.TryParse(userIdString, out int userId))
                {
                    return userId;
                }

                // 3. Fallback/Safety Net: If the claim is missing or somehow isn't a valid number
                throw new UnauthorizedAccessException("User ID claim is missing or invalid.");
            }
        }
        [HttpGet("GetGoalByID/{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetGoalByID([FromRoute] int id) {

            if (id <= 0)
                return BadRequest("Please enter correct ID");
            //int userId = CurrentUserId; 
            var goal = await _savingGoalService.GetGoalByIdAsync(id);

            if (goal == null)
            {
                return NotFound();
            }
            return Ok(goal);
        }
        [HttpGet("GetAllUserGoals / {pageDTO}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetAllUserGoalsAsync([FromQuery] PageDTO pageDTO)
        {
            int userId = CurrentUserId;
            var ListGoalsUser = await _savingGoalService.GetAllUserGoalsAsync(userId, pageDTO);
            if(ListGoalsUser == null)
            {  return NotFound(); }
            return Ok(ListGoalsUser);

        }

        [HttpPost("AddGoal/{goalDTo}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
      //  [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> AddGoal( [FromBody]SavingGoalDTO goalDto)
        {
            int userID = CurrentUserId;
             var goalId =await _savingGoalService.AddGoalAsync(userID, goalDto);
            if (goalId== -1) { return NotFound(); }
            return Ok(goalId);



        }

        [HttpPatch("UpdateGoal/{goalID,ubdatedGoal}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateGoal([FromRoute]int goalID,[FromBody]SavingGoalDTO ubdatedGoal)
        {
            if (goalID<=0) { return BadRequest(); }
            var IsDone = await _savingGoalService.UpdateGoalAsync(goalID,ubdatedGoal);
            if(!IsDone)return NotFound();
            return Ok(IsDone);

        }
        [HttpDelete("DeleteGoal/{goalId}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteGoal([FromRoute]int goalId)
        {
            if (goalId <= 0) { return BadRequest(); }

            var IsDone = await _savingGoalService.DeleteGoalAsync(goalId);
            if (!IsDone) return NotFound();
            return Ok(IsDone);
        }
        [HttpGet("GetAchievedGoals")]
        [ProducesResponseType(StatusCodes.Status200OK)]
       // [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
       public async Task<IActionResult> GetAchievedGoals()
        {
            int userID = CurrentUserId;
              var Goals =await _savingGoalService.GetAchievedGoalsAsync(userID);
            if (Goals == null) return NotFound();
            return Ok(Goals);
        }
        
        [HttpPost("{savingGoalId:int}/wallets/{walletId:int}/add/{amount}amount")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> AddAmountToSavingGoal(int savingGoalId, int walletId, [FromQuery] double amount)
        {
            
            int userId = CurrentUserId;

            if (amount <= 0)
            {
                return BadRequest("The amount to add must be greater than zero.");
            }

           
            bool isSuccess = await _savingGoalService.AddAmountToSavingGoal(savingGoalId, walletId, userId, amount);

            if (!isSuccess)
            {
                return NotFound("The saving goal or wallet was not found, or the operation is unauthorized.");
            }

            return Ok(new { Message = "Amount successfully added to the saving goal." });
        }

       
        [HttpPost("{savingGoalId:int}/wallets/{walletId:int}/withdraw/{amount}amount")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> WithdrawAmountFromSavingGoal(int savingGoalId, int walletId, [FromQuery] double amount)
        {
            
            int userId = CurrentUserId;

            if (amount <= 0)
            {
                return BadRequest("The withdrawal amount must be greater than zero.");
            }

            
            bool isSuccess = await _savingGoalService.WithdrawAmountFromSavingGoal(savingGoalId, walletId, userId, amount);

            if (!isSuccess)
            {
                return BadRequest("Withdrawal failed. Please verify your inputs or ensure the goal contains sufficient funds.");
            }

            return Ok(new { Message = "Amount successfully withdrawn and returned to the wallet." });
        }

    }
}

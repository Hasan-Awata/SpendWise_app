using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.SavingGoals;
using SpendWise.Application.Interfaces.SavingGoals;
using System.Threading.Tasks;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/saving-goals")]
    public class SavingGoalController : BaseApiController
    {
        private readonly ISavingGoalService _savingGoalService;

        public SavingGoalController(ISavingGoalService savingGoalService)
        {
            _savingGoalService = savingGoalService;
        }

          [HttpGet("{id}")]
        public async Task<IActionResult> GetGoalByID([FromRoute] int id)
        {
            if (id <= 0)
            {
                return BadRequest("Please enter a correct ID.");
            }

            var goal = await _savingGoalService.GetGoalByIdAsync(id);

            if (goal == null)
            {
                return NotFound();
            }

            return Ok(goal);
        }

        [HttpGet]
        public async Task<IActionResult> GetAllUserGoalsAsync([FromQuery] PageDTO pageDTO)
        {
            var listGoalsUser = await _savingGoalService.GetAllUserGoalsAsync(CurrentUserId, pageDTO);

            if (listGoalsUser == null)
            {
                return NotFound();
            }

            return Ok(listGoalsUser);
        }

        [HttpPost]
        public async Task<IActionResult> AddGoal([FromBody] SavingGoalDTO goalDto)
        {
             var goalId = await _savingGoalService.AddGoalAsync(CurrentUserId, goalDto);

            if (goalId == -1)
            {
                return NotFound();
            }

            // 2. نجلب الكائن الكامل الذي يحتوي على الـ ID والتفاصيل (SavingGoalResponse) لتقديمه للـ Frontend
            var createdGoal = await _savingGoalService.GetGoalByIdAsync(goalId);

            if (createdGoal == null)
            {
                return NotFound();
            }

            // 3. نرجع الـ 201 Created مع الكائن الكامل والرابط الصحيح
            return CreatedAtAction(nameof(GetGoalByID), new { id = goalId }, createdGoal);
        }

        [HttpPatch("{goalId}")]
        public async Task<IActionResult> UpdateGoal([FromRoute] int goalId, [FromBody] SavingGoalDTO updatedGoal)
        {
            if (goalId <= 0)
            {
                return BadRequest("Invalid Goal ID.");
            }

            var isDone = await _savingGoalService.UpdateGoalAsync(goalId, updatedGoal);

            if (!isDone)
            {
                return NotFound();
            }

            var updatedGoalData = await _savingGoalService.GetGoalByIdAsync(goalId);

            return Ok(updatedGoalData);
        }

        [HttpDelete("{goalId}")]
        public async Task<IActionResult> DeleteGoal([FromRoute] int goalId)
        {
            if (goalId <= 0)
            {
                return BadRequest();
            }

            var isDone = await _savingGoalService.DeleteGoalAsync(goalId);

            if (!isDone)
            {
                return NotFound();
            }

            return NoContent();
        }

        [HttpGet("achieved")]
        public async Task<IActionResult> GetAchievedGoals()
        {
            var goals = await _savingGoalService.GetAchievedGoalsAsync(CurrentUserId);

            if (goals == null)
            {
                return NotFound();
            }

            return Ok(goals);
        }

        [HttpPost("{savingGoalId:int}/wallets/{walletId:int}/add/{amount:double}")]
        public async Task<IActionResult> AddAmountToSavingGoal([FromRoute] int savingGoalId, [FromRoute] int walletId, [FromRoute] double amount)
        {
            if (amount <= 0)
            {
                return BadRequest("The amount to add must be greater than zero.");
            }

            bool isSuccess = await _savingGoalService.AddAmountToSavingGoal(savingGoalId, walletId, CurrentUserId, amount);

            if (!isSuccess)
            {
                return BadRequest("The saving goal or wallet was not found, or the operation is unauthorized.");
            }

            return Ok(new { Message = "Amount successfully added to the saving goal." });
        }

        [HttpPost("{savingGoalId:int}/wallets/{walletId:int}/withdraw/{amount:double}")]
        public async Task<IActionResult> WithdrawAmountFromSavingGoal([FromRoute] int savingGoalId, [FromRoute] int walletId, [FromRoute] double amount)
        {
            if (amount <= 0)
            {
                return BadRequest("The withdrawal amount must be greater than zero.");
            }

            bool isSuccess = await _savingGoalService.WithdrawAmountFromSavingGoal(savingGoalId, walletId, CurrentUserId, amount);

            if (!isSuccess)
            {
                return BadRequest("Withdrawal failed. Please verify your inputs or ensure the goal contains sufficient funds.");
            }

            return Ok(new { Message = "Amount successfully withdrawn and returned to the wallet." });
        }
    }
}
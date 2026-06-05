using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.SavingGoals;
using SpendWise.Application.Interfaces.SavingGoals;
using SpendWise.Domain.Common;
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
            
            var result = await _savingGoalService.GetGoalByIdAsync(id);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpGet]
        public async Task<IActionResult> GetAllUserGoalsAsync([FromQuery] PageDTO pageDTO)
        {
            var result = await _savingGoalService.GetAllUserGoalsAsync(CurrentUserId, pageDTO);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpPost]
        public async Task<IActionResult> AddGoal([FromBody] SavingGoalDTO goalDto)
        {
            var result = await _savingGoalService.AddGoalAsync(CurrentUserId, goalDto);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            var goalId = result.Value;
            var createdGoalResult = await _savingGoalService.GetGoalByIdAsync(goalId);

            if (!createdGoalResult.IsSuccess)
            {
                return HandleResultOnError(createdGoalResult);
            }

            return CreatedAtAction(nameof(GetGoalByID), new { id = goalId }, createdGoalResult.Value);
        }

        [HttpPatch("{goalId}")]
        public async Task<IActionResult> UpdateGoal([FromRoute] int goalId, [FromBody] SavingGoalDTO updatedGoal)
        {
            // نمرر الـ CurrentUserId كبارامتر ثالث للخدمة
            var result = await _savingGoalService.UpdateGoalAsync(goalId, updatedGoal, CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            // لتوفير كويري إضافي، يمكنك تمرير الـ CurrentUserId هنا أيضاً لحماية الجلب
            var updatedGoalDataResult = await _savingGoalService.GetGoalByIdAsync(goalId);

            if (!updatedGoalDataResult.IsSuccess)
            {
                return HandleResultOnError(updatedGoalDataResult);
            }

            return Ok(updatedGoalDataResult.Value);
        }

        [HttpDelete("{goalId}")]
        public async Task<IActionResult> DeleteGoal([FromRoute] int goalId)
        {
            var result = await _savingGoalService.DeleteGoalAsync(goalId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }
             
            return NoContent();
        }

        [HttpGet("achieved")]
        public async Task<IActionResult> GetAchievedGoals()
        {
            var result = await _savingGoalService.GetAchievedGoalsAsync(CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpPost("{savingGoalId:int}/wallets/{walletId:int}/add/{amount:double}")]
        public async Task<IActionResult> AddAmountToSavingGoal([FromRoute] int savingGoalId, [FromRoute] int walletId, [FromRoute] double amount)
        {
            var result = await _savingGoalService.AddAmountToSavingGoal(savingGoalId, walletId, CurrentUserId, amount);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(new { Message = "Amount successfully added to the saving goal.", Status = result.Value });
        }

        [HttpPost("{savingGoalId:int}/wallets/{walletId:int}/withdraw/{amount:double}")]
        public async Task<IActionResult> WithdrawAmountFromSavingGoal([FromRoute] int savingGoalId, [FromRoute] int walletId, [FromRoute] double amount)
        {
            var result = await _savingGoalService.WithdrawAmountFromSavingGoal(savingGoalId, walletId, CurrentUserId, amount);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(new { Message = "Amount successfully withdrawn and returned to the wallet.", Status = result.Value });
        }
    }
}
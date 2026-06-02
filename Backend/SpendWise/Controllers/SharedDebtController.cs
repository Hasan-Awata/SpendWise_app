using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.SharedDebts;
using SpendWise.Application.Interfaces.SharedDebts;
using SpendWise.Domain.Common;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/Shared_Debt")]
    public class SharedDebtController : BaseApiController
    {
        private readonly ISharedDebtService _sharedDebtService;

        public SharedDebtController(ISharedDebtService sharedDebtService)
        {
            _sharedDebtService = sharedDebtService;
        }

        [HttpGet("GetDebtByID/{id}")]
        public async Task<IActionResult> GetDebtByID([FromRoute] int id)
        {
            if (id <= 0) return BadRequest("Please enter a correct ID.");

            var result = await _sharedDebtService.GetDebtByIdAsync(id);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpGet("GetDebtByTitle/{title}")]
        public async Task<IActionResult> GetDebtByTitle([FromRoute] string title)
        {
            if (string.IsNullOrWhiteSpace(title))
            {
                return BadRequest("Please enter a valid debt title.");
            }

            var result = await _sharedDebtService.GetDebtByTitleAsync(title);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpGet("GetDebtsOwedToUser")]
        public async Task<IActionResult> GetDebtsOwedToUser()
        {
            var result = await _sharedDebtService.GetDebtsOwedToUserAsync(CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpGet("GetDebtsIHaveToPay")]
        public async Task<IActionResult> GetDebtsIHaveToPay()
        {
            var result = await _sharedDebtService.GetTheDebtsIHaveToPayAsync(CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpGet("GetAllDebtsForUser")]
        public async Task<IActionResult> GetAllDebtsForUser()
        {
            var result = await _sharedDebtService.GetSharedDebtsForUserAsync(CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpPost("AddDebt")]
        public async Task<IActionResult> AddDebt([FromBody] SharedDebtDTO debtDto)
        {
            var result = await _sharedDebtService.AddDebtAsync(debtDto);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return CreatedAtAction(nameof(GetDebtByID), new { id = result.Value }, result.Value);
        }

        [HttpPatch("UpdateDebt/{debtID}")]
        public async Task<IActionResult> UpdateDebt([FromRoute] int debtID, [FromBody] SharedDebtDTO updatedDebt)
        {
            if (debtID <= 0) return BadRequest("Invalid Debt ID.");

            var result = await _sharedDebtService.UpdateDebtAsync(debtID, updatedDebt);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok();
        }

        [HttpDelete("DeleteDebt/{debtId}")]
        public async Task<IActionResult> DeleteDebtById([FromRoute] int debtId)
        {
            if (debtId <= 0) return BadRequest("Invalid Debt ID.");

            var result = await _sharedDebtService.DeleteDebtByIdAsync(debtId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return NoContent();
        }

        [HttpDelete("DeleteDebtByTitle/{Title}")]
        public async Task<IActionResult> DeleteDebtByTitle([FromRoute] string Title)
        {
            if (string.IsNullOrWhiteSpace(Title)) return BadRequest("Title cannot be empty.");

            var result = await _sharedDebtService.DeletDebtByTitleAsync(Title);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return NoContent();
        }

        [HttpGet("CheckDebtExists/{debtId}")]
        public async Task<IActionResult> CheckDebtExists([FromRoute] int debtId)
        {
            if (debtId <= 0) return BadRequest("Invalid Debt ID.");

            var isExist = await _sharedDebtService.DebtExistsAsyns(debtId);
            if (!isExist) return NotFound(false);

            return Ok(true);
        }

        [HttpPost("ReturnDebtAmount/{debtId}")]
        public async Task<IActionResult> ReturnDebtAmount([FromRoute] int debtId, [FromBody] ReturnDebtDTO returnDebtDTO)
        {
            if (debtId <= 0) return BadRequest("Invalid Debt ID.");

            var result = await _sharedDebtService.ReturnDebtAmountAsync(debtId, returnDebtDTO);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok();
        }

        [HttpPut("AcceptDebt/{debtId}")]
        public async Task<IActionResult> AcceptDebt([FromRoute] int debtId, [FromBody] ReturnDebtDTO returnDebtDTO)
        {
            if (debtId <= 0) return BadRequest("Invalid Debt ID.");

            var result = await _sharedDebtService.AcceptSharedDebtAsync(debtId, returnDebtDTO);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok();
        }

        [HttpPatch("RefuseDebt/{debtId}")]
        public async Task<IActionResult> RefuseDebt([FromRoute] int debtId)
        {
            if (debtId <= 0) return BadRequest("Invalid Debt ID.");

            var result = await _sharedDebtService.RefuseDebtAsync(debtId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok();
        }
    }
}
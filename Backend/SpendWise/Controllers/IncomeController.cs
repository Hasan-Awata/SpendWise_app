using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.Interfaces.Incomes;
using SpendWise.Domain.Common;
using SpendWise.Domain.Enums;
using System;
using System.Security.Claims;
using System.Threading.Tasks;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/incomes")]
    public class IncomeController : BaseApiController
    {
        private readonly IIncomeService _incomeService;

        public IncomeController(IIncomeService incomeService)
        {
            _incomeService = incomeService;
        }

        // Endpoints --------------------------------------------------------
        [HttpGet("{incomeId}")]
        public async Task<IActionResult> GetIncome([FromRoute] int incomeId)
        {
            var result = await _incomeService.GetIncomeAsync(incomeId, CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpGet]
        public async Task<IActionResult> GetIncomeByUser([FromQuery] PageDTO pageDTO)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await _incomeService.GetIncomeByUserAsync(CurrentUserId, pageDTO);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpPost]
        public async Task<IActionResult> AddIncome([FromBody] IncomeDTO incomeDTO)
        {
            if (CurrentUserId != incomeDTO.UserId)
            {
                return Unauthorized();
            }

            incomeDTO.UserId = CurrentUserId;

            var result = await _incomeService.AddIncomeAsync(incomeDTO);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            var createdIncome = result.Value;

            return CreatedAtAction(nameof(GetIncome), new { incomeId = createdIncome!.Id }, createdIncome);
        }

        [HttpPatch("{incomeId}")]
        public async Task<IActionResult> UpdateIncome([FromRoute] int incomeId, [FromBody] IncomeDTO incomeDTO)
        {
            if (CurrentUserId != incomeDTO.UserId)
            {
                return Unauthorized();
            }

            // Ensures route ID safely overrides any malicious/incorrect body ID
            incomeDTO.Id = incomeId;
            incomeDTO.UserId = CurrentUserId;

            var result = await _incomeService.UpdateIncomeAsync(incomeDTO);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpDelete("{incomeId}")]
        public async Task<IActionResult> DeleteIncome([FromRoute] int incomeId)
        {
            var result = await _incomeService.DeleteIncomeAsync(incomeId, CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return NoContent();
        }
    }
}
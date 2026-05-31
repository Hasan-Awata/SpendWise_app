//using Microsoft.AspNetCore.Authorization;
//using Microsoft.AspNetCore.Http;
//using Microsoft.AspNetCore.Mvc;
//using SpendWise.Application.DTOs.SharedDebts;
//using SpendWise.Application.Interfaces.SharedDebts;
//using System.Security.Claims;

//namespace SpendWise.Controllers
//{
//        [Authorize]
//        [ApiController]
//        [Route("api/Shared_Debt")]
//        public class SharedDebtController : ControllerBase
//        {
//            private readonly ISharedDebtService _sharedDebtService;

//            public SharedDebtController(ISharedDebtService sharedDebtService)
//            {
//                _sharedDebtService = sharedDebtService;
//            }

//            private int CurrentUserId
//            {
//                get
//                {
//                    var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
//                    if (int.TryParse(userIdString, out int userId))
//                    {
//                        return userId;
//                    }
//                    throw new UnauthorizedAccessException("User ID claim is missing or invalid.");
//                }
//            }

//            [HttpGet("GetDebtByID/{id}")]
//            [ProducesResponseType(StatusCodes.Status200OK)]
//            [ProducesResponseType(StatusCodes.Status400BadRequest)]
//            [ProducesResponseType(StatusCodes.Status404NotFound)]
//            public async Task<IActionResult> GetDebtByID([FromRoute] int id)
//            {
//                if (id <= 0) return BadRequest("Please enter a correct ID.");

//                var debt = await _sharedDebtService.GetDebtByIdAsync(id);
//                if (debt == null) return NotFound();

//                return Ok(debt);
//            }
//        [HttpGet("GetDebtByTitle/{title}")]
//        [ProducesResponseType(StatusCodes.Status200OK)]
//        [ProducesResponseType(StatusCodes.Status400BadRequest)]
//        [ProducesResponseType(StatusCodes.Status404NotFound)]
//        public async Task<IActionResult> GetDebtByTitle([FromRoute] string title)
//        {
//            // 1. Validation: Ensure the title is not empty or just whitespace
//            if (string.IsNullOrWhiteSpace(title))
//            {
//                return BadRequest("Please enter a valid debt title.");
//            }

//            // 2. Service Call
//            var debt = await _sharedDebtService.GetDebtByTitleAsync(title);

//            // 3. Handle Not Found
//            if (debt == null)
//            {
//                return NotFound($"No debt found with the title: {title}");
//            }

//            // 4. Return result
//            return Ok(debt);
//        }

//            [HttpGet("GetDebtsOwedToUser")]
//            [ProducesResponseType(StatusCodes.Status200OK)]
//            [ProducesResponseType(StatusCodes.Status404NotFound)]
//            public async Task<IActionResult> GetDebtsOwedToUser()
//            {
//                int userId = CurrentUserId;
//                var debts = await _sharedDebtService.GetDebtsOwedToUserAsync(userId);
//                if (debts == null) return NotFound();

//                return Ok(debts);
//            }

//            [HttpGet("GetDebtsIHaveToPay")]
//            [ProducesResponseType(StatusCodes.Status200OK)]
//            [ProducesResponseType(StatusCodes.Status404NotFound)]
//            public async Task<IActionResult> GetDebtsIHaveToPay()
//            {
//                int userId = CurrentUserId;
//                var debts = await _sharedDebtService.GetTheDebtsIHaveToPayAsync(userId);
//                if (debts == null) return NotFound();

//                return Ok(debts);
//            }

//        [HttpGet("GetAllDebtsForUser")]
//        [ProducesResponseType(StatusCodes.Status200OK)]
//        [ProducesResponseType(StatusCodes.Status404NotFound)]
//        public async Task<IActionResult> GetAllDebtsForUser()
//        {
//            int userId = CurrentUserId;
//            var debts = await _sharedDebtService.GetSharedDebtsForUserAsync(userId);
//            if (debts == null) return NotFound();

//            return Ok(debts);
//        }
//        [HttpPost("AddDebt/{debtDto}")]
//            [ProducesResponseType(StatusCodes.Status200OK)]
//             [ProducesResponseType(StatusCodes.Status400BadRequest)]
//        public async Task<IActionResult> AddDebt([FromBody] SharedDebtDTO debtDto)
//            {
//                var debtId = await _sharedDebtService.AddDebtAsync(debtDto);
//                if (debtId == -1) return BadRequest();

//                return Ok(debtId);
//            }

//            [HttpPatch("UpdateDebt/{debtID}")]
//            [ProducesResponseType(StatusCodes.Status200OK)]
//            [ProducesResponseType(StatusCodes.Status400BadRequest)]
//            [ProducesResponseType(StatusCodes.Status404NotFound)]
//            public async Task<IActionResult> UpdateDebt([FromRoute] int debtID, [FromBody] SharedDebtDTO updatedDebt)
//            {
//                if (debtID <= 0) return BadRequest();

//                var isDone = await _sharedDebtService.UpdateDebtAsync(debtID, updatedDebt);
//                if (!isDone) return NotFound();

//                return Ok(isDone);
//            }

//            [HttpDelete("DeleteDebt/{debtId}")]
//            [ProducesResponseType(StatusCodes.Status200OK)]
//            [ProducesResponseType(StatusCodes.Status400BadRequest)]
//            [ProducesResponseType(StatusCodes.Status404NotFound)]
//            public async Task<IActionResult> DeleteDebtById([FromRoute] int debtId)
//            {
//                if (debtId <= 0) return BadRequest();

//                var isDone = await _sharedDebtService.DeleteDebtByIdAsync(debtId);
//                if (!isDone) return NotFound();

//                return Ok(isDone);
//            }
//        [HttpDelete("DeleteDebtByTitle/{Title}")]
//        [ProducesResponseType(StatusCodes.Status200OK)]
      
//        [ProducesResponseType(StatusCodes.Status404NotFound)]
//        public async Task<IActionResult> DeleteDebtByTitle([FromRoute] string Title)
//        {
          

//            var isDone = await _sharedDebtService.DeletDebtByTitleAsync(Title);
//            if (!isDone) return NotFound();

//            return Ok(isDone);
//        }
//        [HttpGet("CheckDebtExists/{debtId}")]
//        [ProducesResponseType(StatusCodes.Status200OK)]
//        [ProducesResponseType(StatusCodes.Status400BadRequest)]
//        [ProducesResponseType(StatusCodes.Status404NotFound)]
//        public async Task<IActionResult> CheckDebtExists([FromRoute] int debtId)
//        {
//            if (debtId <= 0) return BadRequest();

//            var isExist = await _sharedDebtService.DebtExistsAsyns(debtId);
//            if (!isExist) return NotFound();

//            return Ok(isExist);
//        }
//        [HttpPost("ReturnDebtAmount/{debtId}")]
//        [ProducesResponseType(StatusCodes.Status200OK)]
//        [ProducesResponseType(StatusCodes.Status400BadRequest)]
//        [ProducesResponseType(StatusCodes.Status404NotFound)]
//        public async Task<IActionResult> ReturnDebtAmount([FromRoute] int debtId, [FromBody] SharedDebtDTO debtDTO, [FromBody] decimal amount, [FromBody] string title, [FromBody] string description, [FromBody] decimal amountInSp)
//        {
//            if (debtId <= 0) return BadRequest();

//            var isDone = await _sharedDebtService.ReturnDebtAmountAsync(debtId, debtDTO, amount, title, description, amountInSp);
//            if (!isDone) return NotFound();

//            return Ok(isDone);
//        }
//    }
//    }


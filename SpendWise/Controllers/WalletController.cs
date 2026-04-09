using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.NewFolder;
using SpendWise.Application.Interfaces.Incomes;
using SpendWise.Application.Interfaces.Wallets;
using System.Security.Claims;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/wallets")]

    public class WalletController : Controller
    {
        private readonly IWalletService _walletService;

        // Helper property to securely extract the user ID from the auth token
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
        public WalletController(IWalletService walletService)
        {
            _walletService = walletService;
        }

        [HttpGet]
        public async Task<IActionResult> GetWallet([FromQuery] int walletId)
        {
            var wallet = await _walletService.GetWalletByIdAsync(walletId, CurrentUserId);

            if(wallet == null)
            {
                return NotFound();
            }

            return Ok(wallet);
        }

        [HttpGet]
        public async Task<IActionResult> GetUserWallets()
        {
            var walletsList = await _walletService.GetUserWalletsAsync(CurrentUserId);

            return Ok(walletsList);
        }

        [HttpPost("{AddWallet}")]
        public async Task<IActionResult> AddWallet([FromBody] WalletDTO walletDTO)
        {
            if(CurrentUserId != walletDTO.UserId)
            {
                return Unauthorized();
            }

            var createdWallet = await _walletService.AddWalletAsync(walletDTO);

            if (createdWallet == null)
            {
                return BadRequest();
            }

            return CreatedAtAction(nameof(GetWallet), createdWallet);
        }

        [HttpPatch("{UpdateWallet}")]
        public async Task<IActionResult> UpdateWallet([FromBody] WalletDTO walletDTO)
        {
            if(CurrentUserId != walletDTO.UserId)
            {
                return Unauthorized();
            }

            var updatedWallet = await _walletService.UpdateWalletAsync(walletDTO);

            if (updatedWallet == null)
            {
                return BadRequest();
            }

            return CreatedAtAction(nameof(GetWallet), updatedWallet);
        }

        [HttpDelete("{DeleteWallet}")]
        public async Task<IActionResult> DeleteWallet([FromQuery] int walletId)
        {
            if(await _walletService.DeleteWalletAsync(walletId))
            {
                return NoContent();
            }

            return BadRequest();
        }
    }
}

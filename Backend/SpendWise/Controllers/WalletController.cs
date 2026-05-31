using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.Wallet;
using SpendWise.Application.Interfaces.Wallets;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/wallets")]
    public class WalletController : BaseApiController
    {
        private readonly IWalletService _walletService;

        public WalletController(IWalletService walletService)
        {
            _walletService = walletService;
        }

        // Endpoints --------------------------------------------------------
        [HttpGet("{walletId}")]
        public async Task<IActionResult> GetWallet([FromRoute] int walletId)
        {
            var result = await _walletService.GetWalletByIdAsync(walletId, CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value); 
        }

        [HttpGet("{walletId}/pair")]
        public async Task<IActionResult> GetWalletPair([FromRoute] int walletId)
        {
            var result = await _walletService.GetUserWalletsPairAsync(CurrentUserId, walletId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value); 
        }

        [HttpGet]
        public async Task<IActionResult> GetUserWallets([FromQuery] int? currencyId)
        {
            if (currencyId.HasValue)
            {
                var filteredResult = await _walletService.GetWalletsByCurrencyIdAsync(CurrentUserId, currencyId.Value);

                if (!filteredResult.IsSuccess)
                {
                    return HandleResultOnError(filteredResult);
                }

                return Ok(filteredResult.Value); 
            }

            // Default: return ALL wallets for the user if no currency filter is provided
            var result = await _walletService.GetUserWalletsAsync(CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpPost]
        public async Task<IActionResult> AddWallet([FromBody] WalletDTO walletDTO)
        {
            if (CurrentUserId != walletDTO.UserId)
            {
                return Unauthorized();
            }

            walletDTO.UserId = CurrentUserId;

            var result = await _walletService.AddWalletAsync(walletDTO);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            var createdWallet = result.Value;

            return CreatedAtAction(nameof(GetWallet), new { walletId = createdWallet!.WalletId }, createdWallet);
        }

        [HttpPatch("{walletId}")]
        public async Task<IActionResult> UpdateWallet([FromRoute] int walletId, [FromBody] WalletDTO walletDTO)
        {
            if (CurrentUserId != walletDTO.UserId)
            {
                return Unauthorized();
            }

            // Ensures route ID and authenticated user safely override any body mismatch
            walletDTO.WalletId = walletId;
            walletDTO.UserId = CurrentUserId;

            var result = await _walletService.UpdateWalletAsync(walletDTO);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return Ok(result.Value);
        }

        [HttpDelete("{walletId}")]
        public async Task<IActionResult> DeleteWallet([FromRoute] int walletId)
        {
            var result = await _walletService.DeleteWalletAsync(walletId, CurrentUserId);

            if (!result.IsSuccess)
            {
                return HandleResultOnError(result);
            }

            return NoContent();
        }
    }
}
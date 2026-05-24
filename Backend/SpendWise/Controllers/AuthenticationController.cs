using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.Authentication;
using SpendWise.Application.Interfaces.Authentication;

namespace SpendWise.Controllers
{
    [ApiController]
    [Route("api/Authentication")]
    public class AuthenticationController: ControllerBase
    {
        public readonly IAuthService _authService;
        public AuthenticationController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto registerDto)
        {
            if (!ModelState.IsValid)
                return BadRequest();

            var response = await _authService.RegisterAsync(registerDto);

            //return CreatedAtAction(nameof(Register), null ,response);
            return Ok(response);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto loginDto)
        {
            if (!ModelState.IsValid)
                return BadRequest();

            var response = await _authService.LoginAsync(loginDto);

            if (response == null)
                return Unauthorized("Invalid Username or Password");

            return Ok(response);
        }

        [HttpPost("refresh")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenDto tokenDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var response = await _authService.RefreshTokenAsync(tokenDto);

            // If the service returns null, the refresh token was expired, invalid, or didn't match the DB
            if (response == null)
                return Unauthorized("Invalid access token or refresh token.");

            return Ok(response);
        }
    }

}

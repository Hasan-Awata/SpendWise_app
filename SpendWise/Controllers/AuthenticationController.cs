using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.Interfaces;
using SpendWise.Application.Interfaces.DTOs;

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

            return CreatedAtAction(nameof(Register), response);
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


    }

}

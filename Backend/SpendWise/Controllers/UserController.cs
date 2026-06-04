using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Application.DTOs.User;
using SpendWise.Application.Interfaces.Users;
using SpendWise.Domain.Entities;
using System.Threading.Tasks;

namespace SpendWise.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/users")]
    public class UserController : BaseApiController
    {
        private readonly IUserService _userService;

        public UserController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpGet("{userId}")]
        public async Task<IActionResult> GetUser([FromRoute] int userId)
        {
            var user = await _userService.GetByIdAsync(userId);

            if (user == null)
            {
                return NotFound();
            }

            return Ok(user);
        }

        [HttpGet("by-username")]
        public async Task<IActionResult> GetUserByUsername([FromQuery] string username)
        {
            if (string.IsNullOrWhiteSpace(username))
            {
                return BadRequest("username is required");
            }

            var user = await _userService.GetByUsernameAsync(username);

            if (user == null)
            {
                return NotFound();
            }

            return Ok(user);
        }

        [HttpGet("exists")]
        public async Task<IActionResult> IsUsernameExist([FromQuery] string username)
        {
            if (string.IsNullOrWhiteSpace(username))
            {
                return BadRequest("username is required");
            }

            var exists = await _userService.IsUsernameExistAsync(username);
            return Ok(exists);
        }
    }
}

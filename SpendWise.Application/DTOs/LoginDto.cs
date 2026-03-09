using System.ComponentModel.DataAnnotations;

namespace SpendWise.Application.DTOs
{
    public class LoginDto
    {
        [Required(ErrorMessage = "Username is required for logging in.")]
        public string UserName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Password is requierd for logging in.")]
        public string Password { get; set; } = string.Empty;
    }
}

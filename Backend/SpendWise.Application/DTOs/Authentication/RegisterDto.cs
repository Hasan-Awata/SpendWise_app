using System.ComponentModel.DataAnnotations;

namespace SpendWise.Application.DTOs.Authentication
{
    public class RegisterDto
    {
        [Required(ErrorMessage = "Username is required for registeration.")]
        [StringLength(maximumLength:25, ErrorMessage = "Username mustn't be more than 25 characters")]
        [MinLength(3, ErrorMessage = "Username must be at least 3 characters.")]
        public string UserName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Password is requierd for registeration.")]
        [MinLength(6, ErrorMessage = "Password must be at least 6 characters.")]
        public string Password { get; set; } = string.Empty;

        [Required(ErrorMessage = "First name is required for registeration.")]
        public string FirstName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Last name is required for registeration.")]
        public string LastName { get; set; } = string.Empty;
    }
}

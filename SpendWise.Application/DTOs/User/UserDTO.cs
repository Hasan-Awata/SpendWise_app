using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.User
{
    public class UserDTO
    {
        [Required(ErrorMessage = "Provide the user id!")]
        public int Id { get; set; }

        [Required(ErrorMessage = "Please enter a valid username name!")]
        public string Username { get; set; } = string.Empty;

    }
}

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs
{
    public class UserDTO
    {
        [Required(ErrorMessage = "Provide the tag id!")]
        public int Id { get; set; }

        [Required(ErrorMessage = "Please enter a valid tag name!")]
        public string Username { get; set; } = string.Empty;
    }
}

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Tag
{
    public class TagDTO
    {
        [Required(ErrorMessage ="Provide the tag id!")]
        public int Id { get; set; }

        [Required(ErrorMessage = "Please enter a valid tag name!")]
        public string Label { get; set; } = string.Empty;

        [Required(ErrorMessage ="Tag can't be created without an owner!")]
        public int OwnerId { get; set; }
    }
}

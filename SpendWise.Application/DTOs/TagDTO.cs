using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs
{
    public class TagDTO
    {
        [Required(ErrorMessage ="Provide the tag id!")]
        public int Id { get; set; }

        [Required(ErrorMessage = "Please enter a valid tag name!")]
        public string Label { get; set; } = string.Empty;

        [Required(ErrorMessage = "Please choose a category for your tag!")]
        public int CategoryId { get; set; }

        [Required(ErrorMessage ="Tag can't be created without an owner!")]
        public int OwnerId { get; set; }
    }
}

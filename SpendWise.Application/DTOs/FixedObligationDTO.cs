using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs
{
    public class FixedObligationDTO
    {
        [Required(ErrorMessage ="Please enter the fixed obligation id")]
        public int Id { get; set; } = -1;

        [Required(ErrorMessage ="Please enter the fixed obligation owner id")]
        public int OwnerId { get; set; } = -1;
        
        [Required(ErrorMessage ="Please enter the fixed obligation title")]
        public string Title { get; set; } = string.Empty;
        
        [Required(ErrorMessage ="Please enter the fixed obligation amount")]
        [Range(1, Double.PositiveInfinity, ErrorMessage = "Amount must be greater than or equal to 1.")]
        public decimal Amount { get; set; }

        [Required(ErrorMessage ="Please enter the fixed obligation due date")]
        public DateTime DueDate { get; set; }

        [Required(ErrorMessage ="Please enter the fixed obligation state(boolean => Active:true, InActive:flase)")]
        public bool IsActive { get; set; }

    }
}

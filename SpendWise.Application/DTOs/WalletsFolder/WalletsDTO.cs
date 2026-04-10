using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.NewFolder
{
    public  class WalletsDTO
    {
        

        [Required(ErrorMessage = "Please select a currency!")]
        public int CurrencyId { get; set; }

        //Add later 
        //Add object (Currencies)
        
        [Range(0, double.MaxValue, ErrorMessage = "Balance cannot be negative!")]
        public decimal Balance { get; set; }
        [Required(ErrorMessage = "Wallet must belong to a user!")]
        public int UserId { get; set; }
        [Required(ErrorMessage ="Please enter UserDto")]
        public UserDTO userDto { get; set; }



    }
}

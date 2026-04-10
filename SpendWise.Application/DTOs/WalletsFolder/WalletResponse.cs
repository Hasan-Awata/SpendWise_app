using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.DTOs.WalletsFolder
{
    public  class WalletResponse
    {
         public int WalletId { get; set; }

         public int CurrencyId { get; set; }

        //Add object (Currencies)
         public decimal Balance { get; set; }
         public int UserId { get; set; }
         public User user { get; set; } = null!;

        
    }
}

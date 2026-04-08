using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Enums
{
    public enum enTransactionType
    {
        Addition = 0,             // Every process that leads to add to balance
        Dedduction = 1            // Every process that leads to deduct from balance
    }
}

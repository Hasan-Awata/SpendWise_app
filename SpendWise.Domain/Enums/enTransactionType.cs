using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Enums
{
    public enum enTransactionType
    {
        Income = 0,              // Every process that leads to deduct from balance
        Expense = 1             // Every process that leads to add to the balance
    }
}

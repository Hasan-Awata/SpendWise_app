using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Enums
{
    public enum enTransactionType
    {
        Income = 0,              // A revenue provided for once to do a specific service e.g(freelancer, trader, ...) or a Salary
        FixedObligation = 1,     // A fixed amount of money a person have to pay every due date, e.g(rent, suscription, ...)
        SavingGoal = 2,          // A wish list item a person wants to save money to buy
        Expense = 3,             // A transaction indicates that the user has payed for something
    }
}

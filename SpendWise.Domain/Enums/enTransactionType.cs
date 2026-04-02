using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Enums
{
    public enum enTransactionType
    {
        FixedIncome = 0,         // A fixed, static salary, e.g (employees, workers, ...)
        Income = 1,              // A revenue provided for once to do a specific service e.g(freelancer, trader, ...)
        FixedObligation = 2,     // A fixed amount of money a person have to pay every due date, e.g(rent, suscription, ...)
        SavingGoal = 3,          // A wish list item a person wants to save money to buy
        Expense = 4,             // A transaction indicates that the user has payed for something
        SharedExpense = 5,       // A shared expense among multiple users
    }
}

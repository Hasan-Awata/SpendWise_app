using SpendWise.Application.DTOs.Income;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Expenses
{
    public interface IExpenseRepository
    {
        // Writing to database
        public Task<int> AddExpenseAsync(Expense newExpense, Transaction newTransaction);
        public Task<int> UpdateExpenseAsync(Expense newExpense, Transaction newTransaction);
        public Task<bool> DeleteExpenseAsync(int expenseId);

        // Reading from the database
        public Task<Expense> GetExpenseAsync(int expenseId); // returns a transaction to store the full information
        public Task<(IEnumerable<Expense> projects, int totalCount)> GetExpensesByUserAsync(int userId, int pageNumber, int pageSize);
        public Task<string> GetProductsAsync(int expenseId);
    }
}

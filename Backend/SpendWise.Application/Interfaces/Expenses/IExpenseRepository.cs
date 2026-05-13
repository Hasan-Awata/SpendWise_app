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
        public Task<(int ExpenseId, bool IsOverLimit)> AddExpenseAsync(Expense newExpense, Transaction newTransaction);
        public Task<(bool Success, bool IsOverLimit)> UpdateExpenseAsync(Expense newExpense, Transaction newTransaction);
        public Task<bool> DeleteExpenseAsync(int expenseId, int userId);

        // Reading from the database
        public Task<Expense> GetExpenseAsync(int expenseId, int userId);
        public Task<(IEnumerable<Expense> projects, int totalCount)> GetExpensesByUserAsync(int userId, int pageNumber, int pageSize);
        public Task<string> GetProductsAsync(int expenseId);
    }
}

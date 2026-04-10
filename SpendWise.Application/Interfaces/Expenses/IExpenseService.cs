using SpendWise.Application.DTOs.Expense;
using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Expenses
{
    public interface IExpenseService
    {
        // Writing on the database
        public Task<ExpenseResponse?> AddExpenseAsync(ExpenseDTO expenseDto);
        public Task<ExpenseResponse?> UpdateExpenseAsync(ExpenseDTO expenseDto);
        public Task<bool> DeleteExpenseAsync(int expenseId);

        // Reading from the database
        public Task<ExpenseResponse?> GetExpenseAsync(int expenseId);
        public Task<PagedResponse<ExpenseResponse>> GetExpenseByUserAsync(int userId, PageDTO pageDto);

    }
}

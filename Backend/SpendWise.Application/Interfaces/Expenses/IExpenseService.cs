using SpendWise.Application.DTOs.Expense;
using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Paged;
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Domain.Common;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Expenses
{
    public interface IExpenseService
    {
        // Writing on the database
        public Task<Result<ExpenseResponse>> AddExpenseAsync(ExpenseDTO expenseDto);
        public Task<Result<ExpenseResponse>> UpdateExpenseAsync(ExpenseDTO expenseDto);
        public Task<Result> DeleteExpenseAsync(int expenseId, int userId);
        public Task<ExpenseResponse?> AddExpenseAsync(ExpenseDTO expenseDto);
        public Task<ExpenseResponse?> AddExpenseViaOcrAsync(byte[] rawImageFile, string mimType, ExpenseDTO expenseDto);
        public Task<ExpenseResponse?> UpdateExpenseAsync(ExpenseDTO expenseDto);
        public Task<bool> DeleteExpenseAsync(int expenseId, int userId);

        // Reading from the database
        public Task<Result<ExpenseResponse>> GetExpenseAsync(int expenseId, int userId);
        public Task<Result<PagedResponse<ExpenseResponse>>> GetExpenseByUserAsync(int userId, PageDTO pageDto);

    }
}

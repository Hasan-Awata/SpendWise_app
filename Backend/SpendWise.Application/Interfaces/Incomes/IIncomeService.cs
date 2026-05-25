using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.DTOs.Income;
using SpendWise.Domain.Common;
using System;
using System.Collections.Generic;
using System.Text;
using SpendWise.Application.DTOs.Paged;

namespace SpendWise.Application.Interfaces.Incomes
{
    public interface IIncomeService
    {
        // Writing on the database
        public Task<Result<IncomeResponse?>> AddIncomeAsync(IncomeDTO incomeDto);
        public Task<Result<IncomeResponse?>> UpdateIncomeAsync(IncomeDTO incomeDto);
        public Task<Result> DeleteIncomeAsync(int incomeId, int userId);

        // Reading from the database
        public Task<Result<IncomeResponse?>> GetIncomeAsync(int incomeId, int userId);
        public Task<Result<PagedResponse<IncomeResponse>>> GetIncomeByUserAsync(int userId, PageDTO pageDto);
    }

}
using SpendWise.Application.DTOs.PagedResponse;
using SpendWise.Application.DTOs.Income;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Text;
using SpendWise.Application.DTOs.Paged;

namespace SpendWise.Application.Interfaces.Incom
{
    public interface IIncomeService
    {
        // Writing on the database
        public Task<IncomeResponse> AddIncomeAsync(IncomeDTO incomeDto);
        public Task<IncomeResponse> UpdateIncomeAsync(IncomeDTO incomeDto);
        public Task<bool> DeleteIncomeAsync(int incomeId);

        // Reading from the database
        public Task<IncomeResponse> GetIncomeAsync(int incomeId);
        public Task<PagedResponse<IncomeResponse>> GetIncomeByUserAsync(int userId, PageDTO pageDto);
    }

}
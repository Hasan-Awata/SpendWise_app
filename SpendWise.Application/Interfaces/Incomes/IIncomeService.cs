using SpendWise.Application.DTOs.Income;
using SpendWise.Domain.Entities;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Text;

    namespace SpendWise.Application.Interfaces.Incom
    {
        public interface IIncomeService
        {
            public Task<bool> AddIncomeAsync(IncomeDTO incomeDto);
        }
    }
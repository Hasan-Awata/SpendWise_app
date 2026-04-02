using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Services
{
    public  class IncomeService
    {
        //Add Later 
        //private IIncomeRepository readonly _IncomeRepo;

        public async Task<Income?> GetIncomAsync(int userId, int incomeId)
        {
            //Convert tipe of (Income
            Income  IncomeTest =null ;
            //Add Later 
            //  Income = await _IncomeRepo.GetIncomAsync(userId, incomeId);
            return IncomeTest;

        }


    }
}

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
            var  Income ;
            //Add Later 
            //  Income = await _IncomeRepo.GetIncomAsync(userId, incomeId);
            await Income;

        }


    }
}

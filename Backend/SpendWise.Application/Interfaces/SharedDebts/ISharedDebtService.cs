using SpendWise.Application.DTOs.SharedDebts;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.SharedDebts
{
    public interface  ISharedDebtService
    {
      

        // Get debts where the current user is the creditor (The money you are owed)
      public  Task<IEnumerable<SharedDebtResponse>> GetDebtsOwedToUserAsync(int userId);

        // Get debts where the current user is the debtor (The money you owe)
        public Task<IEnumerable<SharedDebtResponse>> GetTheDebtsIHaveToPayAsync(int userId);
        // Get a single debt by its ID
        public  Task<SharedDebtResponse?> GetDebtByIdAsync(int debtId);
        //Get debt by title
        public Task<SharedDebtResponse?> GetDebtByTitleAsync(string title);

        // Create a new debt
         public  Task<int> AddDebtAsync(SharedDebtDTO debtDto);

        // Update an existing debt
        public Task<bool> UpdateDebtAsync(int debtId, SharedDebtDTO debtDto);

        // Delete a debt
        public Task<bool> DeleteDebtByIdAsync(int debtId);
        public Task<bool> DeletDebtByTitleAsync(string title);

        public Task<IEnumerable<SharedDebtResponse>> GetSharedDebtsForUserAsync(int userId);
        public Task<bool> ReturnDebtAmountAsync(int debtId, SharedDebtDTO debtDTO, decimal amount, string title, string description);
        public Task<bool> DebtExistsAsyns(int debtId);
    }
}

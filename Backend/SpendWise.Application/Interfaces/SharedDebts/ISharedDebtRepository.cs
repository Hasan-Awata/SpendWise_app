using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.SharedDebts
{
    public interface ISharedDebtRepository
    {
        // Get debts where the user is the creditor
        public Task<IEnumerable<SharedDebt>> GetDebtsOwedToUserAsync(int userId);

        // Get debts where the user is the debtor
        public Task<IEnumerable<SharedDebt>> GetTheDebtsIHaveToPayAsync(int userId);

        // CRUD Operations
        public Task<SharedDebt?> GetDebtByIdAsync(int debtId);

        public Task<SharedDebt?> GetDebtByTitleAsync(string title);

        public Task<int> AddDebtAsync(SharedDebt debt);

        public Task<bool> UpdateDebtAsync(SharedDebt debt);

        public Task<bool> DeleteDebtByIdAsync(int debtId);

        public Task<bool> DeleteDebtByTitleAsync(string title);

        // Bonus: Common for repositories to check existence
        public Task<bool> DebtExistsAsync(int debtId);
    }
}

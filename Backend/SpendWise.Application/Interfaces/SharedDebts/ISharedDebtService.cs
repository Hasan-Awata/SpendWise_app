using SpendWise.Application.DTOs.SharedDebts;
using SpendWise.Domain.Common; 
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace SpendWise.Application.Interfaces.SharedDebts
{
    public interface ISharedDebtService
    {
        // Get debts where the current user is the creditor (The money you are owed)
        Task<Result<IEnumerable<SharedDebtResponse>>> GetDebtsOwedToUserAsync(int userId);

        // Get debts where the current user is the debtor (The money you owe)
        Task<Result<IEnumerable<SharedDebtResponse>>> GetTheDebtsIHaveToPayAsync(int userId);

        // Get a single debt by its ID
        Task<Result<SharedDebtResponse>> GetDebtByIdAsync(int debtId);

        // Get debt by title
        Task<Result<SharedDebtResponse>> GetDebtByTitleAsync(string title);

        // Create a new debt (Returns the new record ID inside Result)
        Task<Result<SharedDebtResponse>> AddDebtAsync(SharedDebtDTO debtDto);

        // Update an existing debt
        Task<Result> UpdateDebtAsync(int debtId, SharedDebtDTO debtDto);

        // Delete a debt
        Task<Result> DeleteDebtByIdAsync(int debtId);
        Task<Result> DeletDebtByTitleAsync(string title);

        // Get all shared debts for a specific user
        Task<Result<IEnumerable<SharedDebtResponse>>> GetSharedDebtsForUserAsync(int userId);

        // Record a payback transaction
        Task<Result> ReturnDebtAmountAsync(int debtId, ReturnDebtDTO returnDebtDTO);

        // Pure state check remains a boolean
        Task<bool> DebtExistsAsyns(int debtId);

        // Handle confirmation states
        Task<Result> AcceptSharedDebtAsync(int debtId, ReturnDebtDTO debtDTO);
        Task<Result> RefuseDebtAsync(int debtId);
    }
}
using SpendWise.Application.DTOs.SharedDebts;
using SpendWise.Application.Interfaces.SharedDebts;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Services
{
    public class SharedDebtService:ISharedDebtService 
    {
        /* private readonly ISharedDebtRepository _debtRepo;
        public SharedDebtService(ISharedDebtRepository debtRepo) { 
            _debtRepo = debtRepo;
        }
        */

        public async Task<IEnumerable<SharedDebtResponse>> GetDebtsOwedToUserAsync(int userId)
        {
           var debts = new List<SharedDebt>();
            // debts = await _debtRepo.GetDebtsOwedToUserAsync(userId);

            return debts.Select(item => new SharedDebtResponse(item));
        }

        public async Task<IEnumerable<SharedDebtResponse>> GetTheDebtsIHaveToPayAsync(int userId)
        {
            IEnumerable<SharedDebt> debts = new List<SharedDebt>();
            // debts = await _debtRepo.GetTheDebtsIHaveToPayAsync(userId);

            return debts.Select(item => new SharedDebtResponse(item));
        }

        public async Task<SharedDebtResponse?> GetDebtByIdAsync(int debtId)
        {
            // SharedDebt debt = await _debtRepo.GetDebtByIdAsync(debtId);
            // return new SharedDebtResponse(debt);
            return null;
        }

        public async Task<SharedDebtResponse?> GetDebtByTitleAsync(string title)
        {
            // SharedDebt debt = await _debtRepo.GetDebtByTitleAsync(title);
            // return new SharedDebtResponse(debt);
            return null;
        }

        public async Task<int> AddDebtAsync(SharedDebtDTO debtDto)
        {
            var Dept = new SharedDebt(-1, debtDto.CreditorID, debtDto.DebtorID, debtDto.Amount, debtDto.Title, debtDto.Status, debtDto.CreatedAt, debtDto.DueDate);

            // return await _debtRepo.AddDebtAsync(Dept);
            return -1;
        }

        public async Task<bool> UpdateDebtAsync(int debtId, SharedDebtDTO debtDto)
        {
            var Dept = new SharedDebt(-1, debtDto.CreditorID, debtDto.DebtorID, debtDto.Amount, debtDto.Title, debtDto.Status, debtDto.CreatedAt, debtDto.DueDate);

            // return await _debtRepo.UpdateDebtAsync(debtId, Dept);
            return false;
        }

        public async Task<bool> DeleteDebtByIdAsync(int debtId)
        {
            // return await _debtRepo.DeleteDebtByIdAsync(debtId);
            return false;
        }
        public async Task<bool> DeletDebtByTitleAsync(string title)
        {
            // return await _debtRepo.DeleteDebtByTitleAsynce(title);
            return false;
        }
    }
}


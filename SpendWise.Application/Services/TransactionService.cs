using SpendWise.Application.DTOs.Transaction;
using SpendWise.Application.Interfaces.Incom;
using SpendWise.Application.Interfaces.Transactions;
using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Text;
using System.Transactions;

namespace SpendWise.Application.Services
{
    public  class TransactionService: ITransactionService
    {
        private readonly IIncomeService _incomeService;
        // Add these later:
        //private readonly ITransactionService _transactionService;
        //private readonly IExpenseService _expenseService;
        //private readonly IFixedObligationService _fixedObligationService;
        //private readonly ISavingGoalService _savingGoalService;

        public TransactionService(IIncomeService incomeService)
        {
            _incomeService = incomeService;
            //_transactionRepository = transactionRepository;
        }


        //--------------- For Deletion later -----------------------------------------
        //public async Task<bool> TransactionProcess(TransactionsDTO transactionsDto)
        //{
        //    bool success = false;

        //    switch (transactionsDto.TransactionMode)
        //    {
        //        case enTransactionMode.Add:
        //            success = await CreateTransactionAsync(transactionsDto);
        //            break;
        //        case enTransactionMode.Edit:
        //            success = await UpdateTransactionAsync(transactionsDto);
        //            break;

        //        default:
        //            success = false;
        //            break;
        //    }

        //    return success;
        //}

        public async Task<bool> CreateTransactionAsync(TransactionsDTO transactionsDto)
        {

            switch (transactionsDto.TransactionType)
            {
                case enTransactionType.Income:
                    if (transactionsDto.IncomeDTO!=null)
                     return  await _incomeService.AddIncomeAsync(transactionsDto.IncomeDTO);
                    break;
                case enTransactionType.Expense:
                    // Call creating new expense method from _expenseRepository
                    break;
                case enTransactionType.FixedObligation:
                    // Call creating new obligation method from _fixedObligationRepository
                    break;
                case enTransactionType.SavingGoal:
                    // Call creating new saving goal method from _savingGoalRepository
                    break;
            }
            return false;    
        }
        public async Task<bool> UpdateTransactionAsync(TransactionsDTO transactionsDto)
        {

            switch (transactionsDto.TransactionType)
            {
                case enTransactionType.Income:
                    if(transactionsDto.IncomeDTO != null)
                    return await _incomeService.UpdateIncomeAsync(transactionsDto.IncomeDTO);
                    break;
                case enTransactionType.Expense:
                    // Call update new income method from _expenseRepository
                    break;
                case enTransactionType.FixedObligation:
                    // Call update new income method from _fixedObligationRepository
                    break;
                case enTransactionType.SavingGoal:
                    // Call update new income method from _savingGoalRepository
                    break;
            }
            return false ;
        }
        public async Task<bool> DeleteTransactionAsync(TransactionsDTO transactionsDto)
        {

            switch (transactionsDto.TransactionType)
            {
                case enTransactionType.Income:
                    if (transactionsDto.IncomeDTO != null)
                        return await _incomeService.DeleteIncomeAsync(transactionsDto.IncomeDTO.Id, transactionsDto.UserId);
                    break;
                case enTransactionType.Expense:
                    // Call deleting new income method from _expenseRepository
                    break;
                case enTransactionType.FixedObligation:
                    // Call deleting new income method from _fixedObligationRepository
                    break;
                case enTransactionType.SavingGoal:
                    // Call deleting new income method from _savingGoalRepository
                    break;
            }
            return false;   
        }

    }
}

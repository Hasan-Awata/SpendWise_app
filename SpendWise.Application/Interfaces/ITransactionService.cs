using SpendWise.Application.DTOs;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces
{
    public interface ITransactionService
    {
        public interface ITransactionService
        {
            // 1. إضافة معاملة جديدة
            public Task AddTransaction(TransactionsDTO transactionDto);

            // 2. تعديل معاملة موجودة
            public Task UpdateTransaction(TransactionsDTO transactionDto);

            // 3. حذف معاملة عن طريق معرفها (ID)
            public Task DeleteTransaction(int transactionId);

            // 4. جلب جميع المعاملات الخاصة بمستخدم معين (عرض حسب اليوزر)
            public Task<IEnumerable<TransactionsDTO>> GetTransactionsByUserId(int userId);

           
            public Task<TransactionsDTO> GetTransactionById(int transactionId);
        }

    }
}

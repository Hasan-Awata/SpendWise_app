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

            public Task<Income?> GetIncomeAsync(int userId, int incomeId);

            // 2. عرض جميع مصادر الدخل الخاصة بمستخدم معين (عرض حسب الشخص)
            public Task<IEnumerable<Income?>> GetIncomesByUserIdAsync(int userId);

            // 3. عرض مصادر الدخل حسب النوع (مثلاً: ثابت، متغير) لمستخدم معين
            public Task<IEnumerable<IncomeResponse?>> GetIncomesByTypeAsync(int userId, bool? IsFixed);

            // 4. إضافة مصدر دخل جديد
            public Task<bool> AddIncomeAsync(IncomeDTO income);

            // 5. تعديل بيانات مصدر دخل موجود
            public Task<bool> UpdateIncomeAsync(IncomeDTO income);

            // 6. حذف مصدر دخل
            public Task<bool> DeleteIncomeAsync(int incomeId, int userId);

        }
    }
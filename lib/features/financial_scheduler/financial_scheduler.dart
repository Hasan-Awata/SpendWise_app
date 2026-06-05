import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:spendwise/features/expense/data/repositories/expense_repository.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/fixed_incomes/data/repositories/fixed_income_repository.dart';
import 'package:spendwise/features/fixed_obligations/data/repositories/fixed_obligation_repository.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';

class FinancialScheduler extends GetxService {
  final FixedIncomeRepository fixedIncomeRepo;
  final FixedObligationRepository fixedObligationRepo;
  final IncomeRepository incomeRepo; // المسؤول عن تسجيل الحركات المالية الفعلية
  final ExpenseRepository expenseRepo;
  FinancialScheduler({
    required this.fixedIncomeRepo,
    required this.incomeRepo,
    required this.expenseRepo,
    required this.fixedObligationRepo,
  });
  Future<void> _executeDueFinancialTasks() async {
    final now = DateTime.now();

    final result = await fixedIncomeRepo.getFixedIncomes();

    result.fold((l) => null, (list) async {
      for (var fixed in list.where((i) => i.isActive && !i.isDeleted)) {
        // حساب تاريخ الاستحقاق القادم بناءً على آخر مرة تم فيها التنفيذ
        DateTime nextDue = fixed.isMonthly
            ? DateTime(
                fixed.lastTime.year,
                fixed.lastTime.month + 1,
                fixed.lastTime.day,
              )
            : fixed.lastTime.add(Duration(days: fixed.days));

        // تحقق: هل حان وقت الاستحقاق؟
        if (nextDue.isBefore(now) ||
            nextDue.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
          // هنا تم التنفيذ:
          // 1. أضف الدخل الفعلي (Income)
          await incomeRepo.addIncome(
            IncomeEntity(
              userId: fixed.userId, // استخدم الـ ID الموجود في الموديل
              amount: fixed.amount,
              walletId: fixed.walletId,
              title: fixed.title,
              date: nextDue,
            ),
          );

          // 2. تحديث lastTime لتصبح هي تاريخ الاستحقاق الذي نفذناه للتو
          // هذا يمنع أي تكرار مستقبلي، لأن nextDue الجديد سيكون في المستقبل دائماً
          fixed.lastTime = nextDue;
          await fixedIncomeRepo.updateFixedIncome(fixed);
        }
      }
    });
  }

  Future<void> _executeDueObligationsTasks() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // جلب كل الالتزامات الثابتة النشطة
    final result = await fixedObligationRepo.getFixedObligations();

    result.fold((l) => null, (list) async {
      for (var obligation in list.where((o) => o.isActive && !o.isDeleted)) {
        // تحقق: هل حان وقت الاستحقاق؟
        // نقارن فقط السنة، الشهر، واليوم لضمان الدقة
        if (obligation.lastTime.isBefore(today) ||
            obligation.lastTime.isAtSameMomentAs(today)) {
          // 1. تسجيل المصروف الفعلي (Expense)
          await expenseRepo.addExpense(
            ExpenseEntity(
              userId: obligation.ownerId,
              amount: obligation.amount,
              walletId: obligation.walletId,
              title: obligation.title,
              date: obligation.lastTime, // تاريخ الاستحقاق الأصلي
            ),
          );

          // 2. تحديث موعد الاستحقاق القادم (نظام الترحيل الذاتي)
          // نفترض هنا إضافة شهر أو أيام حسب منطق عملك
          obligation.lastTime = obligation.lastTime.add(
            const Duration(days: 30),
          );

          // 3. حفظ التحديث لمنع التكرار مستقبلاً
          await fixedObligationRepo.updateFixedObligation(obligation);
        }
      }
    });
  }

  Future<void> runAllTasks() async {
    await _executeDueFinancialTasks(); // Incomes
    await _executeDueObligationsTasks(); // Obligations
  }
}

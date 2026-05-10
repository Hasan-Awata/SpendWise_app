// // // تعليق: Usecase مخصص لمعالجة كافة السجلات المعلقة (إضافة أو حذف) لضمان اتساق البيانات
// import 'package:dartz/dartz.dart';
// import 'package:spendwise/core/error/failure.dart';
// import 'package:spendwise/features/expense/data/repositories/expense_repository.dart';

// class SyncPendingExpensesUsecase {
//   final ExpenseRepository repository;

//   SyncPendingExpensesUsecase(this.repository);

//   Future<Either<Failure, Unit>> call() async {
//     return await repository.syncPendingExpenses();
//   }
// }

// // // Contract: features/expense/domain/usecases/get_all_local_expenses_usecase.dart
// import 'package:dartz/dartz.dart';
// import 'package:spendwise/core/error/failure.dart';
// import 'package:spendwise/features/expense/data/repositories/expense_repository.dart';
// import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';

// class GetAllLocalExpensesUsecase {
//   final ExpenseRepository repository;

//   GetAllLocalExpensesUsecase(this.repository);

//   // دالة الاستدعاء لجلب كل المصاريف من التخزين المحلي
//   Future<Either<Failure, List<ExpenseEntity>>> call() async {
//     return await repository.getAllExpensesLocal();
//   }
// }

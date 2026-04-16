// // تعليق: Usecase مخصص لمعالجة كافة السجلات المعلقة (إضافة أو حذف) لضمان اتساق البيانات
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';

class SyncPendingIncomesUsecase {
  final IncomeRepository repository;

  SyncPendingIncomesUsecase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.syncPendingIncomes();
  }
}

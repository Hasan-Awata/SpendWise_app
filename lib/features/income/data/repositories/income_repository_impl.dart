import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeRemoteDatasource remoteDatasource;
  final IncomeLocalDataSource localDataSource;

  IncomeRepositoryImpl({
    required this.localDataSource,
    required this.remoteDatasource,
  });

  // --- Add Income ---
  @override
  Future<Either<Failure, Unit>> addIncome(IncomeModel income) async {
    try {
      // حفظ محلي أولاً (Offline-First) لضمان سرعة الاستجابة للمستخدم
      await localDataSource.addIncome(income);

      try {
        await remoteDatasource.addIncome(income);
        // إذا نجح الرفع للسيرفر، نحدث حالة المزامنة
        income.isSynced = true;
        await localDataSource.updateIncome(income);
      } catch (_) {
        // في حال فشل السيرفر، البيانات موجودة محلياً وسيتم مزامنتها لاحقاً
      }
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل حفظ الدخل محلياً"));
    }
  }

  // --- Get Incomes (Remote & Local Mix) ---
  @override
  Future<Either<Failure, PagedResponse<IncomeModel>>> getIncomes(
    int? userId,
    PageRequest page,
  ) async {
    if (userId == null) {
      return _getLocalPagedIncomes(page);
    }

    try {
      final remoteResponse = await remoteDatasource.getMyIncomes(userId, page);

      // تحديث البيانات المحلية بالبيانات الجديدة القادمة من السيرفر
      for (var income in remoteResponse.data) {
        income.isSynced = true;
        await localDataSource.addIncome(income);
      }

      return Right(remoteResponse);
    } on DioException {
      // عند حدوث خطأ في الشبكة، نعرض البيانات المخزنة محلياً لضمان استمرارية العمل
      return await _getLocalPagedIncomes(page);
    } catch (e) {
      return Left(ServerFailure("حدث خطأ غير متوقع أثناء جلب البيانات"));
    }
  }

  // --- Update Income ---
  @override
  Future<Either<Failure, Unit>> updateIncome(
    int incomeId,
    IncomeModel income,
  ) async {
    try {
      await localDataSource.updateIncome(income);
      try {
        await remoteDatasource.updateIncome(incomeId, income);
      } catch (_) {}
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل تحديث البيانات محلياً"));
    }
  }

  // --- Delete Income ---
  @override
  Future<Either<Failure, Unit>> deleteIncome(int incomeId) async {
    try {
      await localDataSource.deleteIncome(incomeId);
      try {
        await remoteDatasource.deleteIncome(incomeId);
      } catch (_) {}
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل حذف البيانات محلياً"));
    }
  }

  // --- Syncing Logic ---
  @override
  Future<Either<Failure, Unit>> syncPendingIncomes() async {
    try {
      final allLocal = await localDataSource.getIncomes();
      final unsynced = allLocal.where((i) => i.isSynced != true).toList();

      for (var income in unsynced) {
        await remoteDatasource.addIncome(income);
        income.isSynced = true;
        await localDataSource.updateIncome(income);
      }
      return const Right(unit);
    } on DioException catch (_) {
      return Left(ServerFailure("فشل الاتصال أثناء المزامنة، تأكد من الشبكة"));
    } catch (e) {
      return Left(CacheFailure("خطأ في المزامنة المحلية"));
    }
  }

  // --- Helper Methods ---

  // دالة مخصصة لتحويل البيانات المحلية إلى نظام الصفحات (Pagination) متوافق مع كلاس PagedResponse الجديد
  Future<Either<Failure, PagedResponse<IncomeModel>>> _getLocalPagedIncomes(
    PageRequest page,
  ) async {
    try {
      final all = await localDataSource.getIncomes();
      final start = (page.pageNumber - 1) * page.pageSize;

      // حساب إجمالي الصفحات بناءً على البيانات المحلية
      final calculatedTotalPages = (all.length / page.pageSize).ceil();

      if (start >= all.length) {
        return Right(
          PagedResponse(
            data: [],
            totalRecords: all.length, // الاسم الجديد
            pageNumber: page.pageNumber,
            pageSize: page.pageSize,
            totalPages: calculatedTotalPages, // الاسم الجديد
          ),
        );
      }

      final end = start + page.pageSize;
      final sliced = all.sublist(start, end > all.length ? all.length : end);

      return Right(
        PagedResponse(
          data: sliced,
          totalRecords: all.length, // مطابقة الحقل الجديد
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: calculatedTotalPages, // مطابقة الحقل الجديد
        ),
      );
    } catch (e) {
      return Left(CacheFailure("خطأ في معالجة البيانات المحلية"));
    }
  }

  @override
  Future<Either<Failure, List<IncomeModel>>> getAllIncomesLocal() async {
    try {
      final incomes = await localDataSource.getIncomes();
      return Right(incomes);
    } catch (e) {
      return Left(CacheFailure("فشل قراءة البيانات المحلية"));
    }
  }
}

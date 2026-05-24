// =========================================================================
// تطبيق مستودع الدخل المعدل ليعتمد بالكامل على طابور المزامنة الموحد
// =========================================================================

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/sync/queue/sync_queue_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:uuid/uuid.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeLocalDataSource localDataSource;
  final IncomeRemoteDatasource remote;
  final WalletLocalDatasource walletLocalDatasource;
  final CurrencyLocal currencyLocal;
  final SyncQueueRepository syncQueueRepository;

  IncomeRepositoryImpl({
    required this.localDataSource,
    required this.walletLocalDatasource,
    required this.currencyLocal,
    required this.syncQueueRepository,
    required this.remote,
  });

  // =========================================================================
  // دالة getIncomes: تجلب من السيرفر وتحدث الكاش بالكامل إن وجد إنترنت، وإلا تقرأ محلياً
  // =========================================================================

  @override
  Future<Either<Failure, PagedResponse<IncomeEntity>>> getIncomes(
    int? userId,
    PageRequest page,
  ) async {
    try {
      // 1. التحقق من توفر الإنترنت عبر الـ NetworkService
      final networkService = Get.find<NetworkService>();
      final isOnline = networkService.isOnline.value;

      if (isOnline) {
        try {
          if (kDebugMode) {
            print(
              "📡 Internet available. Fetching fresh incomes from remote...",
            );
          }

          // أ) جلب البيانات الطازجة كاملة من السيرفر
          // (قم بتعديل الدالة لتناسب الباك إند، سواء تمرير صفحة أو جلب الكل)
          final remoteResponse = await remote.getMyIncomes(userId!, page);

          if (remoteResponse != null) {
            // ب) [فرّغ]: مسح البيانات المحلية القديمة لتجنب التكرار وتطابق السيرفر
            await localDataSource.clear();

            // ج) [أملأ]: تخزين البيانات الجديدة القادمة من السيرفر محلياً
            for (var remoteIncome in remoteResponse.data) {
              remoteIncome.isSynced = true; // وسمها كمتزامنة
              remoteIncome.isDeleted = false;
              await localDataSource.addIncome(remoteIncome);
            }
          }
        } catch (remoteError) {
          // حماية خفية (Fallback): إذا حدث خطأ غير متوقع من السيرفر (مثل 500 أو timeout) رغم وجود إنترنت
          // لا نجعل التطبيق ينهار، بل نكتفي بطباعة الخطأ ونتركه يكمل ليعرض الكاش المحلي المتاح
          if (kDebugMode) {
            print(
              "⚠️ Failed to fetch from remote (Server error), falling back to cache: $remoteError",
            );
          }
        }
      } else {
        if (kDebugMode) {
          print(
            "📴 No internet connection. Reading directly from local cache...",
          );
        }
      }

      // =========================================================================
      // 2. معالجة وعرض البيانات المحلية (سواء كانت المحدثة من السيرفر أو الكاش القديم)
      // =========================================================================
      final localData = await localDataSource.getIncomes();

      // فلترة العناصر غير المحذوفة وترتيبها تنازلياً حسب التاريخ
      final filtered = localData.where((item) => !item.isDeleted).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      // تطبيق الـ Pagination محلياً على القائمة النهائية المسترجعة لضمان تماسك الـ Type
      final slice = _paginate(filtered, page);
      final entities = _mapToEntities(slice);

      return Right(
        PagedResponse(
          data: entities,
          totalRecords: filtered.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: (filtered.length / page.pageSize).ceil(),
        ),
      );
    } catch (e) {
      return Left(CacheFailure("حدث خطأ أثناء تحميل الدخل: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, String>> addIncome(IncomeEntity income) async {
    try {
      final model = IncomeModel.fromEntity(income)
        ..isSynced = false
        ..isDeleted = false
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await localDataSource.addIncome(model);

      await syncQueueRepository.addToQueue(
        SyncQueueModel(
          id: const Uuid().v4(),
          localId: model.localId,
          action: SyncAction.create,
          table: "income",
          createdAt: DateTime.now(),
          isarId: model.isarId,
        ),
      );

      return const Right("تم الحفظ محلياً وبانتظار المزامنة");
    } catch (e) {
      return Left(CacheFailure("فشل الإضافة محلياً: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateIncome(IncomeEntity entity) async {
    try {
      final local = await localDataSource.getIncome(entity.localId);
      if (local == null) return Left(CacheFailure("الدخل غير موجود للتعديل"));

      local
        ..amount = entity.amount
        ..title = entity.title
        ..date = entity.date
        ..walletId = entity.walletId
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await localDataSource.updateIncome(local);

      await syncQueueRepository.addToQueue(
        SyncQueueModel(
          id: const Uuid().v4(),
          localId: local.localId,
          action: SyncAction.update,
          table: "income",
          createdAt: DateTime.now(),
          isarId: local.isarId,
        ),
      );

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل التحديث محلياً: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteIncome(IncomeEntity entity) async {
    try {
      final local = await localDataSource.getIncome(entity.localId);
      if (local == null) return Left(CacheFailure("الدخل غير موجود للحذف"));

      local
        ..isDeleted = true
        ..isSynced = false
        ..updatedAt = DateTime.now();

      await localDataSource.updateIncome(local);

      await syncQueueRepository.addToQueue(
        SyncQueueModel(
          id: const Uuid().v4(),
          localId: local.localId,
          action: SyncAction.delete,
          table: "income",
          createdAt: DateTime.now(),
          isarId: local.isarId,
        ),
      );

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل الحذف محلياً: ${e.toString()}"));
    }
  }

  List<IncomeModel> _paginate(List<IncomeModel> list, PageRequest page) {
    final start = (page.pageNumber - 1) * page.pageSize;
    final end = (start + page.pageSize).clamp(0, list.length);
    return start >= list.length ? [] : list.sublist(start, end);
  }

  List<IncomeEntity> _mapToEntities(List<IncomeModel> slice) {
    return slice.map((model) {
      WalletEntity? wallet;
      if (model.walletLocalId != null) {
        final walletModel = walletLocalDatasource.getWallet(
          model.walletLocalId!,
        );
        if (walletModel != null) {
          walletModel.currency = currencyLocal.tryCurrencyById(
            walletModel.currencyId,
          );
          wallet = walletModel.toEntity();
        }
      }
      return model.toEntity(wallet: wallet);
    }).toList();
  }
}

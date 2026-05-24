// lib/features/transaction/data/repositories/transaction_repository_impl.dart
// TransactionRepositoryImpl: Layered repository pipeline checking network state to synchronize remote transaction frames into localized storage structures

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
// افترضت هنا مسارات الـ PagedResponse بناءً على معمارية تطبيقك، قم بتعديل مسار الاستيراد إذا لزم الأمر
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/transaction/data/datasources/transaction_local_datasource.dart';
import 'package:spendwise/features/transaction/data/datasources/transaction_remote_datasource.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements ITransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, PagedResponse<TransactionEntity>>>
  getTransactionsByUser(int userId, PageRequest page) async {
    try {
      // 1. التحقق من حالة الاتصال بالإنترنت عبر الـ NetworkService المعتمد في التطبيق
      final networkService = Get.find<NetworkService>();
      final isOnline = networkService.isOnline.value;

      if (isOnline) {
        try {
          // جلب البيانات السحابية الحية من السيرفر (Somee)
          final remoteResponse = await remoteDataSource.getMyTransactions(
            userId,
            page,
          );

          if (remoteResponse != null) {
            // مسح الكاش المحلي لتطهير الأنابيب ومنع أي تكرار ناتج عن تداخل المعرفات
            await localDataSource.clear();

            // إعادة تعبئة الكاش المحلي بالبيانات الجديدة ووسم حالتها البرمجية
            for (var remoteTransaction in remoteResponse.data) {
              remoteTransaction.isSynced = true;
              remoteTransaction.isDeleted = false;
              // افترضت اسم الدالة لديك cacheSingleTransaction أو حسب المعرف بـ localDataSource لتخزين عنصر واحد
              await localDataSource.cacheTransaction(remoteTransaction);
            }
          }
        } catch (remoteError) {
          if (kDebugMode) {
            print("⚠️ Failed to fetch transactions from remote: $remoteError");
          }
        }
      }

      // 2. جلب كامل البيانات المخزنة من الـ Local Data Source لعمل الفلترة والـ Pagination محلياً
      final localTransactions = await localDataSource
          .getAllCachedTransactions();

      // تصفية المعاملات المحذوفة، وترتيبها تصاعدياً وتنازلياً بناءً على التاريخ الأحدث
      final filtered = localTransactions.where((t) => !t.isDeleted).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      // 3. تطبيق الـ Pagination الميكانيكي على المصفوفة المصفاة
      final slice = _paginate(filtered, page);
      final entities = _mapToEntities(slice);

      // 4. تعبئة البيانات بداخل الـ PagedResponse وإرجاعها في جانب الـ Right الآمن
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
      debugPrint("GetTransactionsByUser Error: $e");
      return Left(
        CacheFailure("Failed to fetch transactions: ${e.toString()}"),
      );
    }
  }

  // دالة مساعدة لتقسيم المصفوفة (Pagination Slice) محلياً بناءً على الـ PageRequest
  List<dynamic> _paginate(List<dynamic> list, PageRequest page) {
    final int startIndex = (page.pageNumber - 1) * page.pageSize;
    if (startIndex >= list.length) return [];

    final int endIndex = startIndex + page.pageSize;
    return list.sublist(
      startIndex,
      endIndex > list.length ? list.length : endIndex,
    );
  }

  // دالة مساعدة لتحويل الـ Models القادمة من الكاش إلى Entities صالحة للـ UI
  List<TransactionEntity> _mapToEntities(List<dynamic> models) {
    return models
        .map((model) => model.toEntity() as TransactionEntity)
        .toList();
  }
}

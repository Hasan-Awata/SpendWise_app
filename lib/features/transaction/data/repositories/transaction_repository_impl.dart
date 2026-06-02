// lib/features/transaction/data/repositories/transaction_repository_impl.dart
// TransactionRepositoryImpl: Pipeline balancing remote paging state and clean local persistence mapped via Isar primary keys inside data layer

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
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
      final networkService = Get.find<NetworkService>();
      final isOnline = networkService.isOnline.value;

      if (isOnline) {
        try {
          final remoteResponse = await remoteDataSource.getMyTransactions(
            userId,
            page,
          );

          if (remoteResponse != null && remoteResponse.data.isNotEmpty) {
            // جلب الـ TransactionModels الحالية من الكاش (التي تحتوي على الـ isarId)
            final existingLocalModels = await localDataSource
                .getAllCachedTransactions();

            for (var remoteModel in remoteResponse.data) {
              remoteModel.isSynced = true;
              remoteModel.isDeleted = false;

              // الاستغلال الذكي والآمن للـ isarId المتواجد فقط على مستوى الـ Model داخل الطبقة الحالية
              final bool isAlreadyCached = existingLocalModels.any(
                (local) =>
                    (local.id != null &&
                        remoteModel.id != null &&
                        local.id == remoteModel.id) ||
                    (local.isarId == remoteModel.isarId) ||
                    (local.localId == remoteModel.localId),
              );

              if (isAlreadyCached) {
                await localDataSource.updateTransaction(remoteModel);
              } else {
                await localDataSource.cacheTransaction(remoteModel);
              }
            }

            // تسليم البيانات الفورية للسيرفر لمنع انزياح فهارس الـ Cache عند توفر الاتصال
            final entities = _mapToEntities(remoteResponse.data);
            return Right(
              PagedResponse(
                data: entities,
                totalRecords: remoteResponse.totalRecords,
                pageNumber: remoteResponse.pageNumber,
                pageSize: remoteResponse.pageSize,
                totalPages: remoteResponse.totalPages,
              ),
            );
          }
        } catch (remoteError) {
          if (kDebugMode) {
            print("⚠️ Failed to fetch transactions from remote: $remoteError");
          }
        }
      }

      // =====================================================
      // OFFLINE FALLBACK OR EMPTY REMOTE READ
      // =====================================================
      final localModels = await localDataSource.getAllCachedTransactions();

      final filtered = localModels.where((t) => !t.isDeleted).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

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
      debugPrint("GetTransactionsByUser Error: $e");
      return Left(
        CacheFailure("Failed to fetch transactions: ${e.toString()}"),
      );
    }
  }

  List<dynamic> _paginate(List<dynamic> list, PageRequest page) {
    final int startIndex = (page.pageNumber - 1) * page.pageSize;
    if (startIndex >= list.length) return [];

    final int endIndex = startIndex + page.pageSize;
    return list.sublist(
      startIndex,
      endIndex > list.length ? list.length : endIndex,
    );
  }

  List<TransactionEntity> _mapToEntities(List<dynamic> models) {
    return models
        .map((model) => model.toEntity() as TransactionEntity)
        .toList();
  }
}

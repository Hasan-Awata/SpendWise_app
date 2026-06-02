// lib/features/transaction/presentation/manager/transaction_controller.dart
// TransactionController: Reactive state manager preventing UI duplicate layouts by filtering exclusively via Isar primary keys

import 'package:get/get.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/get_transactions_usecase.dart';

class TransactionController extends GetxController {
  final GetTransactionsUseCase getTransactionsUseCase;
  TransactionController({required this.getTransactionsUseCase});

  // =====================================================
  // STATE
  // =====================================================
  final RxList<TransactionEntity> transactions = <TransactionEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadMore = false.obs;

  int _currentPage = 1;
  final int _pageSize = 15;
  bool _hasMoreData = true;

  @override
  void onInit() {
    fetchInitialTransactions();
    super.onInit();
  }

  // =====================================================
  // FETCH INITIAL (REFRESH)
  // =====================================================
  Future<void> fetchInitialTransactions() async {
    try {
      isLoading(true);
      _currentPage = 1;
      _hasMoreData = true;

      final result = await getTransactionsUseCase.getTransactionsByUser(
        CurrentUser.userId!,
        PageRequest(pageNumber: _currentPage, pageSize: _pageSize),
      );

      result.fold(
        (failure) {
          HelperFunction.showSnackBar(
            "فشلت المزامنة",
            "لم نتمكن من تحديث سجل المعاملات الحالية.",
            isError: true,
          );
        },
        (pagedResponse) {
          transactions.assignAll(pagedResponse.data);

          if (_currentPage >= pagedResponse.totalPages) {
            _hasMoreData = false;
          }
        },
      );
    } catch (e) {
      HelperFunction.showSnackBar(
        "Sync Alert",
        "Failed to retrieve fresh ledger nodes. ${e.toString()}",
        isError: true,
      );
    } finally {
      isLoading(false);
    }
  }

  // =====================================================
  // FETCH MORE (PAGINATION)
  // =====================================================
  Future<void> fetchMoreTransactions() async {
    if (isLoadMore.value || !_hasMoreData || isLoading.value) return;

    try {
      isLoadMore(true);
      _currentPage++;

      final result = await getTransactionsUseCase.getTransactionsByUser(
        CurrentUser.userId!,
        PageRequest(pageNumber: _currentPage, pageSize: _pageSize),
      );

      result.fold(
        (failure) {
          _currentPage--;
          HelperFunction.showSnackBar(
            "خطأ في التحميل",
            "فشل تحميل المعاملات الإضافية.",
            isError: true,
          );
        },
        (pagedResponse) {
          final newTransactions = pagedResponse.data;

          if (newTransactions.isEmpty) {
            _hasMoreData = false;
          } else {
            /* تطبيق طلبك بدقة: الفلترة والتحقق من التكرار 
               يعتمدان الآن كلياً على الـ isarId الفريد محلياً والـ id السيرفري سحابياً
            */
            final Map<int, TransactionEntity> isarIdMap = {
              for (final t in transactions)
                if (t.isarId != null) t.isarId!: t,
            };

            final Map<int, TransactionEntity> serverIdMap = {
              for (final t in transactions)
                if (t.id != null) t.id!: t,
            };

            final List<TransactionEntity> uniqueNewTransactions = [];

            for (final t in newTransactions) {
              final isDuplicateIsar =
                  t.isarId != null && isarIdMap.containsKey(t.isarId);
              final isDuplicateServer =
                  t.id != null && serverIdMap.containsKey(t.id);

              if (!isDuplicateIsar && !isDuplicateServer) {
                uniqueNewTransactions.add(t);
              }
            }

            if (uniqueNewTransactions.isNotEmpty) {
              transactions.addAll(uniqueNewTransactions);
            }

            if (_currentPage >= pagedResponse.totalPages ||
                newTransactions.length < _pageSize) {
              _hasMoreData = false;
            }
          }
        },
      );
    } catch (e) {
      _currentPage--;
    } finally {
      await Future.delayed(const Duration(milliseconds: 200));
      isLoadMore(false);
    }
  }
}

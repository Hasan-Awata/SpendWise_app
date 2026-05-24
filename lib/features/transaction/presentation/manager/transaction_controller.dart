// lib/features/transaction/presentation/manager/transaction_controller.dart
// TransactionController: Reactive controller managing state streams and layout pipelines with zero UI duplication risks

import 'package:get/get.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/get_transactions_usecase.dart';

class TransactionController extends GetxController {
  final GetTransactionsUseCase getTransactionsUseCase;
  TransactionController({required this.getTransactionsUseCase});

  var transactions = <TransactionEntity>[].obs;
  var isLoading = false.obs;
  var isLoadMore = false.obs;

  int _currentPage = 1;
  final int _pageSize = 15;
  bool _hasMoreData = true;

  @override
  void onInit() {
    fetchInitialTransactions();
    super.onInit();
  }

  // جلب البيانات لأول مرة أو عند عمل سحب للتحديث (Refresh)
  Future<void> fetchInitialTransactions() async {
    try {
      isLoading(true);
      _currentPage = 1;
      _hasMoreData = true;
      transactions.clear();

      // استدعاء دالة جلب المعاملات عبر تمرير الـ userId وكائن الـ PageRequest
      final result = await getTransactionsUseCase.getTransactionsByUser(
        CurrentUser.userId!,
        PageRequest(pageNumber: _currentPage, pageSize: _pageSize),
      );

      // فك غلاف الـ Either والوصول إلى الـ PagedResponse بداخل دالة النجاح
      result.fold(
        (failure) {
          HelperFunction.showSnackBar(
            "فشلت المزامنة",
            "لم نتمكن من تحديث سجل المعاملات الحالية.",
            isError: true,
          );
        },
        (pagedResponse) {
          // استخراج المصفوفة الصافية من داخل الـ PagedResponse.data وحقنها في الـ RxList
          transactions.assignAll(pagedResponse.data);

          // تحديث بوابة حماية الـ Pagination بناءً على عدد الصفحات الكلي المرجوع من الـ Repository
          if (_currentPage >= pagedResponse.totalPages) {
            _hasMoreData = false;
          }

          // HelperFunction.showSnackBar(
          //   "تم التحديث",
          //   "تم جلب المعاملات المالية الأخيرة بنجاح.",
          //   isError: false,
          // );
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

  // تحميل المزيد عند النزول لأسفل الشاشة (Pagination)
  Future<void> fetchMoreTransactions() async {
    // بوابات حماية: توقف فوراً إذا كان هناك جلب قيد التنفيذ أو انتهت بيانات السيرفر
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
          _currentPage--; // التراجع عن مؤشر الصفحة في حال الفشل
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
            // حصر صارم لكل المعرفات الظاهرة حالياً على شاشة المستخدم لمنع التكرار البصري نهائياً
            final currentRemoteIds = transactions
                .map((t) => t.id)
                .where((id) => id != null)
                .toSet();
            final currentLocalIds = transactions.map((t) => t.localId).toSet();

            final uniqueNewTransactions = newTransactions.where((t) {
              final hasDuplicateRemoteId =
                  t.id != null && currentRemoteIds.contains(t.id);
              final hasDuplicateLocalId = currentLocalIds.contains(t.localId);

              return !hasDuplicateRemoteId && !hasDuplicateLocalId;
            }).toList();

            if (uniqueNewTransactions.isNotEmpty) {
              transactions.addAll(uniqueNewTransactions);
            }

            // تحديث حالة انتهاء البيانات بناءً على مؤشر الـ totalPages المرجوع من السيرفر/الكاش
            if (_currentPage >= pagedResponse.totalPages ||
                newTransactions.length < _pageSize) {
              _hasMoreData = false;
            }
          }
        },
      );
    } catch (e) {
      _currentPage--; // التراجع عن مؤشر الصفحة في حال حدوث استثناء مفاجئ بالشبكة
    } finally {
      // قفل زمني بسيط لمنع الـ Scroll Trigger العشوائي المتكرر في نفس الأجزاء من الثانية
      await Future.delayed(const Duration(milliseconds: 200));
      isLoadMore(false);
    }
  }
}

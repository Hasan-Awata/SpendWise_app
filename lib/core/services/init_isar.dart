import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/budget/data/model/category_budget_model.dart';
import 'package:spendwise/features/category/data/models/category_model.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/savings_goals/data/models/saving_goal_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_model.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/transaction/data/models/transaction_model.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';

class InitIsar {
  InitIsar._internal();
  static final InitIsar _initIsar = InitIsar._internal();
  static InitIsar get _instance => _initIsar;
  factory InitIsar() => _instance;

  static Isar? isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open(
      [
        UserModelSchema,
        TagModelSchema,
        WalletModelSchema,
        IncomeModelSchema,
        ExpenseModelSchema,
        SavingGoalModelSchema,
        CurrencySchema,
        SyncQueueModelSchema,
        CategoryModelSchema,
        CategoryBudgetModelSchema,
        TransactionModelSchema,
      ],
      directory: dir.path,
      inspector: true,
    );

    Get.put<Isar>(isar!, permanent: true);
  }

  static void clear() async {
    await isar!.writeTxn(() async {
      await isar!.clear();
    });
  }
}

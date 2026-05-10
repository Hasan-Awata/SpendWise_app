// // تعليق: ملف حقن التبعيات الخاص بأهداف الادخار لضمان الربط الصحيح بين الطبقات المختلفة وتوفير الذاكرة
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_local_datasource.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_local_datasource_impl.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_remote_datasource.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_remote_datasource_impl.dart';
import 'package:spendwise/features/savings_goals/data/repositories/saving_goal_repository.dart';
import 'package:spendwise/features/savings_goals/data/repositories/saving_goal_repository_impl.dart';
import 'package:spendwise/features/savings_goals/domain/usecases/add_saving_goal_usecase.dart';
import 'package:spendwise/features/savings_goals/domain/usecases/delete_saving_goal_usecase.dart';
import 'package:spendwise/features/savings_goals/domain/usecases/get_achieved_goals_usecase.dart';
import 'package:spendwise/features/savings_goals/domain/usecases/get_saving_goal_usecase.dart';
import 'package:spendwise/features/savings_goals/domain/usecases/sync_pending_goals_usecase.dart'
    show SyncPendingGoalsUseCase;
import 'package:spendwise/features/savings_goals/domain/usecases/update_saving_goal_usecase.dart';
import 'package:spendwise/features/savings_goals/presentation/manager/saving_goal_action_controller.dart';
import 'package:spendwise/features/savings_goals/presentation/manager/saving_goal_lis_controller.dart';

class SavingGoalBinding implements Bindings {
  @override
  void dependencies() {
    // 1. Data Sources (حقن مصادر البيانات المحلية والبعيدة)
    Get.lazyPut<SavingGoalRemoteDatasource>(
      () => SavingGoalRemoteDatasourceImpl(client: http.Client()),
      fenix: true,
    );
    Get.lazyPut<SavingGoalLocalDatasource>(
      () => SavingGoalLocalDatasourceImpl(Get.find<Isar>()),
      fenix: true,
    );

    // 2. Repository (ربط الواجهة بالتنفيذ الفعلي للمستودع)
    Get.lazyPut<SavingGoalRepository>(
      () => SavingGoalRepositoryImpl(
        remoteDatasource: Get.find(),
        localDatasource: Get.find(),
        network: Get.find<NetworkService>(),
      ),
      fenix: true,
    );

    // 3. Use Cases (حقن حالات الاستخدام المختلفة لدعم الـ Domain Layer)
    Get.lazyPut(() => GetSavingGoalsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => AddSavingGoalUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => UpdateSavingGoalUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => DeleteSavingGoalUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetAchievedGoalsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => SyncPendingGoalsUseCase(Get.find()), fenix: true);

    // 4. Controllers (إعداد المتحكمات لإدارة واجهة المستخدم)

    // وضع الـ ListController في الـ Memory بمجرد الدخول للقسم لمراقبة القائمة والـ Pagination
    Get.lazyPut(
      () => SavingGoalListController(
        getSavingGoalsUseCase: Get.find<GetSavingGoalsUseCase>(),
        userIdUsecase: Get.find<GetUserIdUsecase>(),
      ),
      fenix: true,
    );

    // استخدام lazyPut لـ ActionController لضمان تشغيله فقط عند محاولة إضافة أو تعديل هدف
    Get.lazyPut(
      () => SavingGoalActionController(
        addSavingGoalUseCase: Get.find(),
        updateSavingGoalUseCase: Get.find(),
        deleteSavingGoalUseCase: Get.find(),
        userIdUsecase: Get.find<GetUserIdUsecase>(),
      ),
      fenix: true,
    );
  }
}

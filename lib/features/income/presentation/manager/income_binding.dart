import 'package:get/get.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasources_impl.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/income/data/repositories/income_repository_impl.dart';
import 'package:spendwise/features/income/domain/usecases/add_income_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/get_incomes_usecase.dart';
import 'package:spendwise/features/income/presentation/manager/income_controller.dart';

//binding مهمته الأساسية هي إعداد كل ما تحتاجه الشاشة من (Controllers, Use Cases, Repositories)

class IncomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncomeLocalDataSource>(() => IncomeLocalDataSourceImpl());
    Get.lazyPut<IncomeRepository>(
      () => IncomeRepositoryImpl(
        localDataSource: Get.find<IncomeLocalDataSource>(),
      ),
    );
    Get.lazyPut(() => AddIncomeUsecase(Get.find<IncomeRepository>()));
    Get.lazyPut(() => GetIncomesUsecase(Get.find<IncomeRepository>()));

    Get.put(
      IncomeController(
        addIncomeUseCase: Get.find<AddIncomeUsecase>(),
        getIncomesUseCase: Get.find<GetIncomesUsecase>(),
      ),
    );
  }
}

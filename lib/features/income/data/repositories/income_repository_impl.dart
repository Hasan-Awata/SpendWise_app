import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  // final IncomeRemoteDatasourceImpl remoteDatasource;
  final IncomeLocalDataSource localDataSource;

  IncomeRepositoryImpl({
    required this.localDataSource,
    // required this.remoteDatasource,
  });

  @override
  Future<void> addIncome(IncomeModel income) async {
    try {
      // await remoteDataSource.addIncome(income.toJson());
      await localDataSource.addIncome(income);
    } catch (e) {
      // يمكنك هنا إضافة منطق: إذا فشل الـ API، هل نحفظ في Hive فقط؟
      // حالياً سنقوم برمي الخطأ ليظهر في الـ UI
      rethrow;
    }
  }

  @override
  List<IncomeModel> getIncomes() {
    try {
      /// 1. محاولة جلب البيانات من السيرفر (الباك-أند)
      // final remoteIncomes = await remoteDataSource.getIncomes();

      // // 2. تحديث البيانات المحلية (مسح القديم وتخزين الجديد) لضمان التزامن
      // await localDataSource.clearCache();
      // for (var income in remoteIncomes) {
      //   await localDataSource.cacheIncome(income);
      // }
      // return remoteIncomes;
      return localDataSource.getIncomes();
    } catch (e) {
      // 3. في حال فشل الإنترنت، ارجع للـ Hive لكي لا يتوقف التطبيق
      // final localIncomes = localDataSource.getCachedIncomes();
      // if (localIncomes.isNotEmpty) {
      //   return localIncomes;
      // } else {
      //   // إذا كان كل شيء فارغاً، ارفع الخطأ للـ UI
      //   rethrow;
      // }
      rethrow;
    }
  }
}

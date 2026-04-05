import 'package:get/get.dart';
import 'package:spendwise/features/splash/introduction.dart';
// // Imports: استيراد الشاشات والـ Bindings الخاصة بها
import '../../features/income/presentation/pages/income_list_view.dart';
import '../../features/income/presentation/pages/add_income_view.dart';
import '../../features/income/presentation/manager/income_binding.dart';

class AppPages {
  // // Logic: التعريف الأولي للمسار الذي سيبدأ به التطبيق
  static const INITIAL = '/introduction';

  static final routes = [
    GetPage(name: '/introduction', page: () => const Introduction()),
    GetPage(
      name: '/income-list',
      page: () => const IncomeListView(),
      binding: IncomeBinding(),
    ),
    GetPage(
      name: '/add-income',
      page: () => AddIncomeView(),
      binding: IncomeBinding(),
    ),
  ];
}

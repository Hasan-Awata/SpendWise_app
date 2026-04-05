import 'package:get/get.dart';
import 'package:spendwise/features/auth/presentation/bindings/auth_binding.dart';
import 'package:spendwise/features/auth/presentation/pages/login_page.dart';
import 'package:spendwise/features/auth/presentation/pages/sign_up_page.dart';
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
    GetPage(
      name: '/signup',
      page: () => SignUpPage(),
      binding: AuthBinding(), // // تأكد من وجود هذا السطر هنا
    ),
    GetPage(name: '/login', page: () => LogInPage(), binding: AuthBinding()),
  ];
}

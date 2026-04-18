import 'package:get/get.dart';
import 'package:spendwise/features/auth/presentation/bindings/auth_binding.dart';
import 'package:spendwise/features/income/presentation/bindings/income_binding.dart';
import 'package:spendwise/features/tags/presentation/bindings/tag_binding.dart';
import 'package:spendwise/features/wallet/presentation/bindings/wallet_binding.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    AuthBinding(permanentAuthController: true).dependencies();
    WalletBinding().dependencies();
    TagBinding().dependencies();
    IncomeBinding().dependencies();
  }
}

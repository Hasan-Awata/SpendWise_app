import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';

class GetIncomesUsecase {
  final IncomeRepository repository;
  GetIncomesUsecase(this.repository);

  Future<List<IncomeModel>> call() async {
    final incomes = await repository.getIncomes();

    //     2. ما هي ميثود compareTo؟
    // هذه الميثود تقارن بين رقمين وتُعطي نتيجة من ثلاثة احتمالات:

    // 1: إذا كان الرقم الأول أكبر.//b,a

    // 1-: إذا كان الرقم الثاني أكبر.//a,b

    // 0: إذا كان الرقمان متساويين.// no change

    // // Logic: ترتيب البيانات بحيث يظهر الدخل الأكبر أولاً
    incomes.sort(
      (a, b) => b.amount.compareTo(a.amount),
    ); // b->a ترتيب من الاكبر للاصغر
    return incomes;
  }
}

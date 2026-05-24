import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

abstract class IncomeRemoteDatasource {
  Future<IncomeModel?> addIncome(IncomeModel income);
  Future<PagedResponse<IncomeModel>?> getMyIncomes(
    int userId,
    PageRequest page,
  );
  Future<IncomeModel?> updateIncome(IncomeModel income);
  Future<bool> deleteIncome(IncomeModel income);
}

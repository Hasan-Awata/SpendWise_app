import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

abstract class WalletRemoteDatasource {
  Future<WalletModel> addWalet(WalletModel wallet);

  Future<PagedResponse<WalletModel>> getMyWallet(PageRequest page);
}

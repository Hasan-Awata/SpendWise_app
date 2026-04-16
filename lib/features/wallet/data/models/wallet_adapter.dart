import 'package:hive/hive.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

class WalletAdapter extends TypeAdapter<WalletModel> {
  @override
  final typeId = 4;

  @override
  WalletModel read(BinaryReader reader) {
    return WalletModel.fromLocal(reader.read());
  }

  @override
  void write(BinaryWriter writer, WalletModel obj) {
    writer.write(obj.toLocal());
  }
}

import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:uuid/uuid.dart';

class TagModel extends TagEntity {
  String localId;
  bool isSynced;

  TagModel({
    String? localId,
    super.id = -1,
    required super.userId,
    required super.name,
    this.isSynced = false,
  }) : localId = localId ?? const Uuid().v4();

  factory TagModel.fromJson(Map<String, dynamic> map) {
    return TagModel(
      // السيرفر يرسل id وليس Id
      id: map['id'] ?? map['Id'] ?? -1,
      // السيرفر يرسل ownerId وليس OwnerId
      userId: map['ownerId'] ?? map['OwnerId'] ?? -1,
      // السيرفر يرسل label وليس Label
      name: map['label'] ?? map['Label'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "Id": id ?? -1,
    "OwnerId": CurrentUser.getUserId,
    "Label": name,
  };

  factory TagModel.fromLocal(Map<dynamic, dynamic> map) {
    return TagModel(
      localId: map['localId'],
      id: map['id'] ?? map['Id'] ?? -1,
      userId: map['ownerId'] ?? map['OwnerId'] ?? -1,
      name: map['label'] ?? map['Label'] ?? "",
      isSynced: map['isSynced'] == 1,
    );
  }

  Map<dynamic, dynamic> toLocal() => {
    "localId": localId,
    "Id": id ?? -1,
    "OwnerId": CurrentUser.getUserId ?? -1,
    "Label": name,
    "isSynced": isSynced ? 1 : 0,
  };

  @override
  String toString() {
    return "id:$id , label:$name , ";
  }
}

import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:uuid/uuid.dart';

class TagModel extends TagEntity {
  String localId;
  bool isSynced;

  TagModel({
    String? localId,
    super.id,
    required super.userId,
    required super.name,
    this.isSynced = false,
  }) : localId = localId ?? const Uuid().v4();

  factory TagModel.fromJson(Map<String, dynamic> map) {
    return TagModel(
      id: map['Id'],
      userId: map['OwnerId'] ?? -1,
      name: map['Label'],
    );
  }

  Map<String, dynamic> toJson() => {"Id": id, "OwnerId": userId, "Label": name};

  factory TagModel.fromLocal(Map<dynamic, dynamic> map) {
    return TagModel(
      localId: map['localId'],
      id: map['id'] ?? -1,
      userId: map['userId'],
      name: map['name'],
      isSynced: map['isSynced'] == 1,
    );
  }

  Map<dynamic, dynamic> toLocal() => {
    "localId": localId,
    "id": id ?? -1,
    "userId": userId,
    "name": name,
    "isSynced": isSynced ? 1 : 0,
  };
}

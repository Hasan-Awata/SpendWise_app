import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class TagEntity {
  String localId;
  int? id;
  int userId;
  String name;

  bool isDeleted;
  RxBool isSynced;

  DateTime? createdAt;
  DateTime? updatedAt;

  TagEntity({
    String? localId,
    RxBool? isSynced,
    this.id,
    required this.userId,
    required this.name,

    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  }) : isSynced = isSynced ?? false.obs,
       localId = localId ?? const Uuid().v4();
}

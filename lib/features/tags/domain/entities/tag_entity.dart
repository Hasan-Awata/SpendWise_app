import 'package:uuid/uuid.dart';

class TagEntity {
  String localId;
  int? id;
  int userId;
  String name;

  bool isDeleted;
  bool isSynced;

  DateTime? createdAt;
  DateTime? updatedAt;

  TagEntity({
    String? localId,

    this.id,
    required this.userId,
    required this.name,
    this.isSynced = false,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  }) : localId = localId ?? const Uuid().v4();
}

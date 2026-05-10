import 'package:isar/isar.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:uuid/uuid.dart';

part 'tag_model.g.dart';

@collection
class TagModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String localId;

  @Index()
  int? id;

  int userId;
  String name;

  bool isSynced;
  bool isDeleted;

  // 🔥 retry system
  int syncAttempts;
  DateTime? lastSyncError;

  DateTime? createdAt;
  DateTime? updatedAt;

  TagModel({
    required this.localId,

    this.id,
    required this.userId,
    required this.name,
    this.isSynced = false,
    this.isDeleted = false,
    this.syncAttempts = 0,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory TagModel.fromEntity(TagEntity entity) {
    return TagModel(
      localId: entity.localId,
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      isSynced: entity.isSynced,
      isDeleted: entity.isDeleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  TagEntity toEntity() {
    return TagEntity(
      localId: localId,
      id: id,
      userId: userId,
      name: name,
      isSynced: isSynced,
      isDeleted: isDeleted,

      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory TagModel.fromJson(Map<String, dynamic> json, {String? localId}) {
    return TagModel(
      localId: localId ?? const Uuid().v4(),
      id: json['id'] ?? json['tagId'],
      userId: json['ownerId'],
      name: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id ?? -1, "ownerId": userId, "label": name};
  }

  @override
  toString() {
    return 'TagModel{localId: $localId, id: $id, userId: $userId, name: $name, isSynced: $isSynced, isDeleted: $isDeleted, syncAttempts: $syncAttempts, lastSyncError: $lastSyncError, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

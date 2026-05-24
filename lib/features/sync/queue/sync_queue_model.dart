import 'package:isar/isar.dart';

part 'sync_queue_model.g.dart';

enum SyncAction { create, update, delete }

@collection
class SyncQueueModel {
  Id idIsar = Isar.autoIncrement;

  @Index()
  String id;

  String localId;

  int isarId;

  @Enumerated(EnumType.name) // 👈 هذا الحل
  SyncAction action;

  String table;
  DateTime createdAt;

  SyncQueueModel({
    required this.id,
    required this.localId,
    required this.action,
    required this.table,
    required this.createdAt,
    required this.isarId,
  });
}

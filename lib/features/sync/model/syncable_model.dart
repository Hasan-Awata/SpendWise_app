abstract class SyncableModel {
  int? get serverId;

  bool get isSynced;
  bool get isDeleted;

  set isSynced(bool value);
  set isDeleted(bool value);

  int syncAttempts = 0;

  void markSynced(int id);
}

abstract class SyncRepository<T> {
  Future<void> createByLocalId(int localId);

  Future<void> updateByLocalId(int localId);

  Future<void> deleteByLocalId(int localId);
}

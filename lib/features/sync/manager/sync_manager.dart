class SyncManager {
  final List<dynamic> engines;

  SyncManager(this.engines);

  Future<void> syncAll() async {
    try {
      for (final engine in engines) {
        await engine.sync();
      }
    } on Exception catch (_) {
      rethrow;
    }
  }
}

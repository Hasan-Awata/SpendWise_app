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

  Future<void> syncLast() async {
    for (final engine in engines) {
      try {
        await engine.syncLastItem();
      } catch (e) {
        print(
          "🚨 SyncManager: Failed to trigger syncLastItem on an engine: $e",
        );
        rethrow;
      }
    }
  }
}

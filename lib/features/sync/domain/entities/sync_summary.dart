enum QueueItemStatus { pending, offline, queued }

class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.status,
    required this.timeLabel,
  });

  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final QueueItemStatus status;
  final String timeLabel;
}

class SyncConflict {
  const SyncConflict({
    required this.orderCode,
    required this.clientName,
    required this.reason,
  });

  final String orderCode;
  final String clientName;
  final String reason;
}

class SyncHistoryEntry {
  const SyncHistoryEntry({required this.dateLabel, required this.summary});

  final String dateLabel;
  final String summary;
}

class SyncSummary {
  const SyncSummary({
    required this.isConnected,
    required this.lastUpdateLabel,
    required this.pendingCount,
    required this.successCount,
    required this.queue,
    required this.history,
    this.conflict,
  });

  final bool isConnected;
  final String lastUpdateLabel;
  final int pendingCount;
  final int successCount;
  final List<SyncQueueItem> queue;
  final List<SyncHistoryEntry> history;
  final SyncConflict? conflict;

  int get conflictCount => conflict != null ? 1 : 0;
}

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync_service.dart';

/// Sync status for UI indicators.
class SyncState {
  final bool isOnline;
  final bool isSyncing;
  final DateTime? lastSyncAt;

  const SyncState({
    this.isOnline = true,
    this.isSyncing = false,
    this.lastSyncAt,
  });

  SyncState copyWith({
    bool? isOnline,
    bool? isSyncing,
    DateTime? lastSyncAt,
  }) {
    return SyncState(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}

/// Manages sync state and triggers pull & merge.
class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier() : super(const SyncState());

  final _sync = SyncService.instance;

  /// Full pull & merge cycle. Updates UI state before/after.
  Future<void> pullAndMerge() async {
    if (state.isSyncing) return;
    state = state.copyWith(isSyncing: true);
    try {
      await _sync.pullAndMerge();
      state = state.copyWith(
        isSyncing: false,
        lastSyncAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('[SyncNotifier] Pull & merge error: $e');
      state = state.copyWith(isSyncing: false);
    }
  }

  void setOnline(bool online) {
    state = state.copyWith(isOnline: online);
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>(
  (ref) => SyncNotifier(),
);

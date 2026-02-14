import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dodged_trap.dart';
import '../models/subscription.dart';
import 'auth_service.dart';
import 'isar_service.dart';

/// Offline-first sync engine: Isar ↔ Supabase.
///
/// Isar is the local source of truth. Supabase syncs in background.
/// Uses last-write-wins conflict resolution via `updatedAt` timestamps.
class SyncService {
  SyncService._();
  static final instance = SyncService._();

  SupabaseClient get _client => Supabase.instance.client;
  Isar get _isar => IsarService.instance.db;

  /// Whether Supabase is configured.
  bool get _hasSupabase =>
      const String.fromEnvironment('SUPABASE_URL').isNotEmpty;

  /// Whether the device has network connectivity.
  Future<bool> get isOnline async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  // ─── Push Operations ───

  /// Push a single subscription to Supabase (upsert by user_id + uid).
  Future<void> pushSubscription(Subscription sub) async {
    if (!_hasSupabase || !await isOnline) return;
    final userId = AuthService.instance.userId;
    if (userId == null) return;

    try {
      await _client.from('subscriptions').upsert(
        sub.toSupabaseMap(userId),
        onConflict: 'user_id,uid',
      );
    } catch (e) {
      debugPrint('[Sync] Push subscription failed: $e');
    }
  }

  /// Push a dodged trap to Supabase.
  Future<void> pushDodgedTrap(DodgedTrap trap) async {
    if (!_hasSupabase || !await isOnline) return;
    final userId = AuthService.instance.userId;
    if (userId == null) return;

    try {
      await _client.from('dodged_traps').insert(
        trap.toSupabaseMap(userId),
      );
    } catch (e) {
      debugPrint('[Sync] Push dodged trap failed: $e');
    }
  }

  /// Soft-delete a subscription in Supabase.
  Future<void> pushDelete(String uid) async {
    if (!_hasSupabase || !await isOnline) return;
    final userId = AuthService.instance.userId;
    if (userId == null) return;

    try {
      await _client
          .from('subscriptions')
          .update({
            'deleted_at': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('uid', uid);
    } catch (e) {
      debugPrint('[Sync] Push delete failed: $e');
    }
  }

  // ─── Pull + Merge ───

  /// Pull remote changes and merge into Isar (last-write-wins).
  ///
  /// Called on app start and when connectivity is restored.
  Future<void> pullAndMerge() async {
    if (!_hasSupabase || !await isOnline) return;
    final userId = AuthService.instance.userId;
    if (userId == null) return;

    try {
      // 1. Fetch all remote subscriptions
      final remote = await _client
          .from('subscriptions')
          .select()
          .eq('user_id', userId);

      // 2. Merge remote into local (last-write-wins)
      for (final row in remote) {
        final remoteSub = Subscription.fromSupabaseMap(row);
        final localSub = await _isar.subscriptions
            .filter()
            .uidEqualTo(remoteSub.uid)
            .findFirst();

        if (localSub == null) {
          // New from remote — insert locally
          await _isar.writeTxn(() async {
            await _isar.subscriptions.put(remoteSub);
          });
        } else if (remoteSub.updatedAt.isAfter(localSub.updatedAt)) {
          // Remote is newer — overwrite local (preserve Isar ID)
          remoteSub.id = localSub.id;
          await _isar.writeTxn(() async {
            await _isar.subscriptions.put(remoteSub);
          });
        }
        // else: local is newer or same — skip (will be pushed below)
      }

      // 3. Push local records that don't exist remotely or are newer
      final localSubs = await _isar.subscriptions.where().findAll();
      final remoteUids = remote.map((r) => r['uid'] as String).toSet();

      for (final local in localSubs) {
        if (!remoteUids.contains(local.uid)) {
          // Exists locally but not remotely — push to remote
          await pushSubscription(local);
        } else {
          // Both exist — push if local is newer
          final remoteRow = remote.firstWhere((r) => r['uid'] == local.uid);
          final remoteUpdatedAt = DateTime.parse(remoteRow['updated_at'] as String);
          if (local.updatedAt.isAfter(remoteUpdatedAt)) {
            await pushSubscription(local);
          }
        }
      }

      debugPrint('[Sync] Pull & merge complete');
    } catch (e) {
      debugPrint('[Sync] Pull & merge failed: $e');
    }
  }

  // ─── Restore on Reinstall ───

  /// Restore data from Supabase when local Isar is empty but user is signed in.
  /// Returns true if data was restored.
  Future<bool> restoreFromRemote() async {
    if (!_hasSupabase || !await isOnline) return false;
    final userId = AuthService.instance.userId;
    if (userId == null) return false;

    // Only restore if local Isar is empty
    final localSubCount = await _isar.subscriptions.count();
    final localTrapCount = await _isar.dodgedTraps.count();
    if (localSubCount > 0 || localTrapCount > 0) return false;

    try {
      // Restore subscriptions
      final remoteSubs = await _client
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null);

      if (remoteSubs.isNotEmpty) {
        await _isar.writeTxn(() async {
          for (final row in remoteSubs) {
            final sub = Subscription.fromSupabaseMap(row);
            await _isar.subscriptions.put(sub);
          }
        });
      }

      // Restore dodged traps
      final remoteTraps = await _client
          .from('dodged_traps')
          .select()
          .eq('user_id', userId);

      if (remoteTraps.isNotEmpty) {
        await _isar.writeTxn(() async {
          for (final row in remoteTraps) {
            final trap = DodgedTrap.fromSupabaseMap(row);
            await _isar.dodgedTraps.put(trap);
          }
        });
      }

      final restored = remoteSubs.isNotEmpty || remoteTraps.isNotEmpty;
      if (restored) {
        debugPrint('[Sync] Restored ${remoteSubs.length} subs + ${remoteTraps.length} traps from remote');
      }
      return restored;
    } catch (e) {
      debugPrint('[Sync] Restore failed: $e');
      return false;
    }
  }

  // ─── Profile Sync ───

  /// Sync user preferences to the profiles table.
  Future<void> syncProfile({String? currency, String? locale}) async {
    if (!_hasSupabase || !await isOnline) return;
    final userId = AuthService.instance.userId;
    if (userId == null) return;

    final updates = <String, dynamic>{};
    if (currency != null) updates['display_currency'] = currency;
    if (locale != null) updates['locale'] = locale;
    if (updates.isEmpty) return;

    try {
      await _client.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      debugPrint('[Sync] Profile sync failed: $e');
    }
  }

  // ─── Analytics ───

  /// Log an app event (best-effort, no retry).
  Future<void> logEvent(String type, [Map<String, dynamic>? metadata]) async {
    if (!_hasSupabase || !await isOnline) return;
    final userId = AuthService.instance.userId;
    if (userId == null) return;

    try {
      await _client.from('app_events').insert({
        'user_id': userId,
        'event_type': type,
        'metadata': metadata ?? {},
      });
    } catch (e) {
      debugPrint('[Sync] Event log failed: $e');
    }
  }
}

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
    if (!_hasSupabase) {
      debugPrint('[Sync] Skip push "${sub.name}" — Supabase not configured');
      return;
    }
    if (!await isOnline) {
      debugPrint('[Sync] Skip push "${sub.name}" — offline');
      return;
    }
    final userId = AuthService.instance.userId;
    if (userId == null) {
      debugPrint('[Sync] Skip push "${sub.name}" — no userId');
      return;
    }

    try {
      debugPrint('[Sync] Pushing subscription: ${sub.uid} (${sub.name})');
      await _client.from('subscriptions').upsert(
        sub.toSupabaseMap(userId),
        onConflict: 'user_id,uid',
      );
      debugPrint('[Sync] Pushed "${sub.name}" OK');
    } catch (e) {
      debugPrint('[Sync] Push "${sub.name}" FAILED: $e');
    }
  }

  /// Push a dodged trap to Supabase.
  Future<void> pushDodgedTrap(DodgedTrap trap) async {
    if (!_hasSupabase || !await isOnline) return;
    final userId = AuthService.instance.userId;
    if (userId == null) return;

    try {
      debugPrint('[Sync] Pushing dodged trap: ${trap.serviceName}');
      await _client.from('dodged_traps').insert(
        trap.toSupabaseMap(userId),
      );
    } catch (e) {
      debugPrint('[Sync] Push dodged trap "${trap.serviceName}" FAILED: $e');
    }
  }

  /// Hard-delete a subscription from Supabase.
  Future<void> pushDelete(String uid) async {
    if (!_hasSupabase || !await isOnline) return;
    final userId = AuthService.instance.userId;
    if (userId == null) return;

    try {
      debugPrint('[Sync] Pushing hard delete: $uid');
      await _client
          .from('subscriptions')
          .delete()
          .eq('user_id', userId)
          .eq('uid', uid);
      debugPrint('[Sync] Hard deleted "$uid" OK');
    } catch (e) {
      debugPrint('[Sync] Push delete "$uid" FAILED: $e');
    }
  }

  // ─── Pull + Merge ───

  /// Pull remote changes and merge into Isar (last-write-wins).
  ///
  /// Called on app start and when connectivity is restored.
  Future<void> pullAndMerge() async {
    if (!_hasSupabase) {
      debugPrint('[Sync] Skip pull — Supabase not configured');
      return;
    }
    if (!await isOnline) {
      debugPrint('[Sync] Skip pull — offline');
      return;
    }
    final userId = AuthService.instance.userId;
    if (userId == null) {
      debugPrint('[Sync] Skip pull — no userId');
      return;
    }

    try {
      // 1. Fetch non-deleted remote subscriptions
      final remote = await _client
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null);

      debugPrint('[Sync] Pulled ${remote.length} remote subs');

      // 2. Merge remote into local (last-write-wins)
      int pulledCount = 0;
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
          pulledCount++;
        } else if (remoteSub.updatedAt.isAfter(localSub.updatedAt)) {
          // Remote is newer — overwrite local (preserve Isar ID)
          remoteSub.id = localSub.id;
          await _isar.writeTxn(() async {
            await _isar.subscriptions.put(remoteSub);
          });
          pulledCount++;
        }
        // else: local is newer or same — skip (will be pushed below)
      }

      if (pulledCount > 0) {
        debugPrint('[Sync] Merged $pulledCount new/updated subs from remote');
      }

      // 2b. Purge any locally-cached soft-deleted subs that may have
      //     been imported by earlier sync runs (before the deleted_at filter).
      final softDeleted = await _isar.subscriptions
          .filter()
          .deletedAtIsNotNull()
          .findAll();
      if (softDeleted.isNotEmpty) {
        await _isar.writeTxn(() async {
          await _isar.subscriptions
              .deleteAll(softDeleted.map((s) => s.id).toList());
        });
        debugPrint(
            '[Sync] Purged ${softDeleted.length} soft-deleted subs from Isar');
      }

      // 3. Bulk push: push every local sub that doesn't exist remotely
      //    or has a newer updatedAt locally. This catches subs added
      //    while offline, before sync was working (schema fixes), or
      //    on a different device.
      final localSubs = await _isar.subscriptions.where().findAll();
      final remoteByUid = <String, Map<String, dynamic>>{};
      for (final row in remote) {
        remoteByUid[row['uid'] as String] = row;
      }

      final toPush = <Subscription>[];
      for (final local in localSubs) {
        final remoteRow = remoteByUid[local.uid];
        if (remoteRow == null) {
          // Local-only — never been pushed
          toPush.add(local);
        } else {
          final remoteUpdatedAt =
              DateTime.parse(remoteRow['updated_at'] as String);
          if (local.updatedAt.isAfter(remoteUpdatedAt)) {
            // Local is newer — needs update
            toPush.add(local);
          }
        }
      }

      if (toPush.isNotEmpty) {
        debugPrint(
          '[Sync] Bulk pushing ${toPush.length} unsynced local subs...',
        );
        int pushed = 0;
        int failed = 0;
        for (final sub in toPush) {
          try {
            await _client.from('subscriptions').upsert(
              sub.toSupabaseMap(userId),
              onConflict: 'user_id,uid',
            );
            pushed++;
          } catch (e) {
            debugPrint('[Sync] Bulk push "${sub.name}" FAILED: $e');
            failed++;
          }
        }
        debugPrint('[Sync] Bulk push complete: $pushed OK, $failed failed');
      } else {
        debugPrint('[Sync] All local subs in sync — nothing to push');
      }

      debugPrint('[Sync] Pull & merge complete');
    } catch (e, st) {
      debugPrint('[Sync] Pull & merge FAILED: $e');
      debugPrint('[Sync] Stack trace: $st');
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
    } catch (e, st) {
      debugPrint('[Sync] Restore FAILED: $e');
      debugPrint('[Sync] Stack trace: $st');
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

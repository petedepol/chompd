import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/cancel_guides_data.dart';
import '../data/service_pricing_data.dart';
import '../models/service_cache.dart';
import 'isar_service.dart';

/// Syncs the service database from Supabase `service_full` view into
/// the local Isar [ServiceCache] collection.
///
/// - First launch: full sync (all services).
/// - Subsequent launches: delta sync via `get_updated_services(since_version)`.
/// - Offline fallback: seeds from bundled static data if Isar is empty.
class ServiceSyncService {
  ServiceSyncService._();
  static final instance = ServiceSyncService._();

  Isar get _isar => IsarService.instance.db;

  /// Prevents concurrent sync operations.
  Completer<void>? _activeSyncCompleter;

  /// Called after sync completes (success or fallback) so consumers can
  /// refresh their in-memory caches. Set from the widget tree where
  /// Riverpod is available.
  VoidCallback? onSyncComplete;

  /// Whether Supabase is configured.
  bool get _hasSupabase =>
      const String.fromEnvironment('SUPABASE_URL').isNotEmpty;

  SupabaseClient get _client => Supabase.instance.client;

  /// Main entry point — call from [main.dart] after Isar init.
  ///
  /// Safe to call multiple times concurrently — only the first call
  /// runs, subsequent calls wait for it to finish.
  Future<void> syncServices() async {
    // If a sync is already running, wait for it and return
    if (_activeSyncCompleter != null) {
      await _activeSyncCompleter!.future;
      return;
    }

    _activeSyncCompleter = Completer<void>();
    try {
      await _doSync();
      onSyncComplete?.call();
    } finally {
      _activeSyncCompleter!.complete();
      _activeSyncCompleter = null;
    }
  }

  Future<void> _doSync() async {
    try {
      final syncState = await _isar.syncStates.where().findFirst();
      final lastVersion = syncState?.lastSyncedVersion ?? 0;

      if (!_hasSupabase || !await _isOnline()) {
        // No network — ensure we have at least static fallback data
        final count = await _isar.serviceCaches.count();
        if (count == 0) {
          await _seedFromStaticData();
        }
        return;
      }

      if (lastVersion == 0) {
        await _fullSync();
      } else {
        await _deltaSync(lastVersion);
      }
    } catch (_) {
      // If sync fails and we have no data, seed from static
      final count = await _isar.serviceCaches.count();
      if (count == 0) {
        await _seedFromStaticData();
      }
    }
  }

  /// Full sync — fetch all services from the `service_full` view.
  Future<void> _fullSync() async {
    final rows = await _client.from('service_full').select('*');
    if (rows.isEmpty) {
      await _seedFromStaticData();
      return;
    }

    // Also fetch aliases for fuzzy matching
    final aliasRows = await _client.from('service_aliases').select('*');
    final aliasMap = <String, List<String>>{};
    for (final row in aliasRows) {
      final serviceId = row['service_id'] as String;
      aliasMap.putIfAbsent(serviceId, () => []);
      aliasMap[serviceId]!.add(
        (row['alias'] as String).toLowerCase(),
      );
    }

    int maxVersion = 0;
    final caches = <ServiceCache>[];

    for (final row in rows) {
      final cache = ServiceCache.fromSupabaseMap(row);
      cache.aliases = aliasMap[cache.supabaseId] ?? [];
      caches.add(cache);
      if (cache.dataVersion > maxVersion) {
        maxVersion = cache.dataVersion;
      }
    }

    await _isar.writeTxn(() async {
      // Clear existing cache and write fresh
      await _isar.serviceCaches.clear();
      await _isar.serviceCaches.putAll(caches);

      // Update sync state
      await _isar.syncStates.clear();
      await _isar.syncStates.put(
        SyncState()
          ..lastSyncedVersion = maxVersion
          ..lastSyncedAt = DateTime.now()
          ..lastSyncCount = caches.length,
      );
    });

  }

  /// Delta sync — fetch only services updated since [sinceVersion].
  Future<void> _deltaSync(int sinceVersion) async {
    final rows = await _client.rpc(
      'get_updated_services',
      params: {'since_version': sinceVersion},
    );

    final List rowsList = rows is List ? rows : [];
    if (rowsList.isEmpty) return;

    int maxVersion = sinceVersion;

    await _isar.writeTxn(() async {
      for (final row in rowsList) {
        final cache = ServiceCache.fromSupabaseMap(row);
        if (cache.dataVersion > maxVersion) {
          maxVersion = cache.dataVersion;
        }

        // Upsert by supabaseId
        final existing = await _isar.serviceCaches
            .where()
            .supabaseIdEqualTo(cache.supabaseId)
            .findFirst();
        if (existing != null) {
          cache.id = existing.id;
        }
        await _isar.serviceCaches.put(cache);
      }

      // Update sync state
      final syncState =
          await _isar.syncStates.where().findFirst() ?? SyncState();
      syncState
        ..lastSyncedVersion = maxVersion
        ..lastSyncedAt = DateTime.now()
        ..lastSyncCount = rowsList.length;
      await _isar.syncStates.put(syncState);
    });

  }

  /// Seed Isar from bundled static data when no network is available.
  Future<void> _seedFromStaticData() async {

    final caches = <ServiceCache>[];

    for (final info in servicePricingData) {
      // Try to find a matching cancel guide
      final guide = cancelGuidesData
          .where((g) =>
              g.serviceName == info.slug ||
              g.serviceName == info.name.toLowerCase().replaceAll(' ', '_'))
          .firstOrNull;

      String cancelGuidesJsonStr = '[]';
      int? difficultyScore;

      if (guide != null) {
        final guideJson = [
          {
            'platform': guide.platform,
            'steps': guide.steps
                .asMap()
                .entries
                .map((e) => {
                      'step': e.key + 1,
                      'title': e.value,
                      'detail': e.value,
                    })
                .toList(),
            'cancel_deeplink': guide.deepLink,
            'cancel_web_url': guide.cancellationUrl,
            'warning_text': guide.notes,
          },
        ];
        cancelGuidesJsonStr = jsonEncode(guideJson);
        difficultyScore = (guide.difficultyRating * 2).clamp(1, 10);
      }

      caches.add(ServiceCache.fromStaticServiceInfo(
        info,
        cancelGuidesJsonStr: cancelGuidesJsonStr,
        cancelDifficultyScore: difficultyScore,
      ));
    }

    // Also add cancel-guide-only services (generic platform guides)
    for (final guide in cancelGuidesData) {
      final alreadyAdded = caches.any((c) =>
          c.slug == guide.serviceName ||
          c.slug ==
              guide.serviceName.replaceAll('_', ' ').replaceAll(' ', '_'));
      if (!alreadyAdded) {
        final guideJson = [
          {
            'platform': guide.platform,
            'steps': guide.steps
                .asMap()
                .entries
                .map((e) => {
                      'step': e.key + 1,
                      'title': e.value,
                      'detail': e.value,
                    })
                .toList(),
            'cancel_deeplink': guide.deepLink,
            'cancel_web_url': guide.cancellationUrl,
            'warning_text': guide.notes,
          },
        ];

        caches.add(
          ServiceCache()
            ..supabaseId = 'static_${guide.serviceName}'
            ..slug = guide.serviceName
            ..name = guide.serviceName
                .replaceAll('_', ' ')
                .split(' ')
                .map((w) =>
                    w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
                .join(' ')
            ..category = 'other'
            ..brandColor = '#6A6A82'
            ..iconLetter = '?'
            ..hasFreeTier = false
            ..hasFamily = false
            ..hasAnnual = false
            ..hasStudent = false
            ..fallbackCurrency = 'GBP'
            ..regions = ['GB', 'US']
            ..cancelDifficulty = (guide.difficultyRating * 2).clamp(1, 10)
            ..tiersJson = '[]'
            ..cancelGuidesJson = jsonEncode(guideJson)
            ..refundTemplatesJson = '[]'
            ..darkPatternsJson = '[]'
            ..alternativesJson = '[]'
            ..communityTipCount = 0
            ..aliases = <String>[]
            ..dataVersion = 0
            ..verifiedAt = DateTime.now()
            ..updatedAt = DateTime.now()
            ..localSyncedAt = DateTime.now(),
        );
      }
    }

    await _isar.writeTxn(() async {
      await _isar.serviceCaches.putAll(caches);
      await _isar.syncStates.clear();
      await _isar.syncStates.put(
        SyncState()
          ..lastSyncedVersion = 0
          ..lastSyncedAt = DateTime.now()
          ..lastSyncCount = caches.length,
      );
    });

  }

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}

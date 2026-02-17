import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/service_insight.dart';
import 'isar_service.dart';

/// Persists curated service insights synced from Supabase.
///
/// Small table (<100 rows) — full-replace sync on each call.
/// Dismissals are local-only (not synced back).
///
/// Singleton following the same pattern as [DodgedTrapRepository].
class ServiceInsightRepository {
  ServiceInsightRepository._();
  static final instance = ServiceInsightRepository._();

  Isar get _isar => IsarService.instance.db;
  final _random = Random();

  bool get _hasSupabase =>
      const String.fromEnvironment('SUPABASE_URL').isNotEmpty;

  SupabaseClient get _client => Supabase.instance.client;

  /// Fetch all active service insights from Supabase and upsert into Isar.
  ///
  /// Preserves the local [isDismissed] flag on existing rows.
  Future<void> syncFromSupabase() async {
    if (!_hasSupabase || !await _isOnline()) return;

    try {
      final rows = await _client
          .from('service_insights')
          .select()
          .eq('is_active', true);

      if (rows.isEmpty) return;

      await _isar.writeTxn(() async {
        for (final row in rows) {
          final insight = ServiceInsight.fromSupabaseMap(row);

          // Preserve local isDismissed flag on existing rows
          final existing = await _isar.serviceInsights
              .where()
              .remoteIdEqualTo(insight.remoteId)
              .findFirst();
          if (existing != null) {
            insight.id = existing.id;
            insight.isDismissed = existing.isDismissed;
          }

          await _isar.serviceInsights.put(insight);
        }
      });

      debugPrint(
          '[ServiceInsightRepo] Synced ${rows.length} insights from Supabase');
    } catch (e) {
      debugPrint('[ServiceInsightRepo] Sync failed: $e');
    }
  }

  /// All non-dismissed insights matching the given service keys.
  List<ServiceInsight> getForServices(List<String> serviceKeys) {
    if (serviceKeys.isEmpty) return [];
    return _isar.serviceInsights
        .where()
        .filter()
        .isDismissedEqualTo(false)
        .and()
        .anyOf(serviceKeys, (q, key) => q.serviceKeyEqualTo(key))
        .sortByPriorityDesc()
        .findAllSync();
  }

  /// Pick one random non-dismissed insight matching the user's services.
  ServiceInsight? getRandomInsight(List<String> serviceKeys) {
    final available = getForServices(serviceKeys);
    if (available.isEmpty) return null;
    return available[_random.nextInt(available.length)];
  }

  /// Mark an insight as dismissed (local-only, not synced).
  Future<void> dismiss(ServiceInsight insight) async {
    insight.isDismissed = true;
    await _isar.writeTxn(() async {
      await _isar.serviceInsights.put(insight);
    });
  }

  /// Mark an insight as dismissed by Isar ID (local-only).
  ///
  /// Used by the unified carousel card which works with
  /// [InsightDisplayData] and only has the Isar ID.
  Future<void> dismissById(int isarId) async {
    final insight = _isar.serviceInsights.getSync(isarId);
    if (insight == null) return;
    await dismiss(insight);
  }

  /// Total insight count (for debug).
  int get count => _isar.serviceInsights.countSync();

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}

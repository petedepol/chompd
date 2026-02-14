import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dodged_trap.dart';
import 'isar_service.dart';
import 'sync_service.dart';

const _kDodgedTrapsKey = 'dodged_traps';

/// Persists dodged trap records via Isar.
///
/// On first run, migrates existing data from SharedPreferences to Isar,
/// then clears the SharedPreferences key.
///
/// Singleton following the same pattern as [NotificationService] and
/// [PurchaseService].
class DodgedTrapRepository {
  DodgedTrapRepository._();
  static final instance = DodgedTrapRepository._();

  Isar get _isar => IsarService.instance.db;

  /// Load + migrate from SharedPreferences on first run.
  Future<void> load() async {
    await _migrateFromSharedPreferences();
  }

  /// One-time migration from SharedPreferences to Isar.
  Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_kDodgedTrapsKey);
      if (jsonStr == null || jsonStr.isEmpty) return;

      // Only migrate if Isar is empty (avoids duplicate migration)
      final existing = await _isar.dodgedTraps.count();
      if (existing > 0) {
        // Already migrated — clean up SharedPreferences
        await prefs.remove(_kDodgedTrapsKey);
        return;
      }

      final oldTraps = DodgedTrap.decodeList(jsonStr);
      await _isar.writeTxn(() async {
        for (final trap in oldTraps) {
          await _isar.dodgedTraps.put(trap);
        }
      });

      // Clear SharedPreferences after successful migration
      await prefs.remove(_kDodgedTrapsKey);
      debugPrint('[DodgedTrapRepo] Migrated ${oldTraps.length} traps from SharedPreferences to Isar');
    } catch (e) {
      debugPrint('[DodgedTrapRepo] Migration failed: $e');
    }
  }

  /// All dodged traps.
  List<DodgedTrap> getAll() => _isar.dodgedTraps.where().findAllSync();

  /// Add a new dodged trap and persist to Isar.
  Future<void> add(DodgedTrap trap) async {
    await _isar.writeTxn(() async {
      await _isar.dodgedTraps.put(trap);
    });
    SyncService.instance.pushDodgedTrap(trap);
  }

  /// Total money saved from all dodged traps.
  double get totalSaved =>
      getAll().fold(0.0, (sum, t) => sum + t.savedAmount);

  /// Number of dodged traps recorded.
  int get count => _isar.dodgedTraps.countSync();
}

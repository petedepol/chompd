import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/dodged_trap.dart';
import '../models/merchant.dart';
import '../models/service_cache.dart';
import '../models/service_insight.dart';
import '../models/subscription.dart';
import '../models/user_insight.dart';
import 'error_logger.dart';

/// Isar database initialisation and access.
///
/// Singleton following the existing service pattern.
/// Must be called before any provider that reads from Isar.
class IsarService {
  IsarService._();
  static final instance = IsarService._();

  late Isar _isar;
  bool _initialised = false;

  static const _schemas = [
    SubscriptionSchema,
    MerchantSchema,
    DodgedTrapSchema,
    ServiceCacheSchema,
    SyncStateSchema,
    ServiceInsightSchema,
    UserInsightSchema,
  ];

  /// Initialise the Isar database.
  ///
  /// If the DB is corrupted, deletes it and retries. Local data is lost
  /// but Supabase sync will restore it on next connect.
  Future<void> init() async {
    if (_initialised) return;
    final dir = await getApplicationDocumentsDirectory();
    try {
      _isar = await Isar.open(_schemas, directory: dir.path);
    } catch (e, st) {
      ErrorLogger.log(
        event: 'isar_corrupt',
        detail: 'Isar.open failed, deleting DB and retrying: $e',
        stackTrace: st.toString(),
      );
      // Delete all Isar files and retry
      final dbFiles = Directory(dir.path)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('default.isar'));
      for (final f in dbFiles) {
        try { f.deleteSync(); } catch (_) {}
      }
      _isar = await Isar.open(_schemas, directory: dir.path);
    }
    _initialised = true;
  }

  /// The Isar database instance.
  Isar get db => _isar;
}

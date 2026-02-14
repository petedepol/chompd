import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/dodged_trap.dart';
import '../models/merchant.dart';
import '../models/service_cache.dart';
import '../models/subscription.dart';

/// Isar database initialisation and access.
///
/// Singleton following the existing service pattern.
/// Must be called before any provider that reads from Isar.
class IsarService {
  IsarService._();
  static final instance = IsarService._();

  late Isar _isar;
  bool _initialised = false;

  /// Initialise the Isar database.
  Future<void> init() async {
    if (_initialised) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        SubscriptionSchema,
        MerchantSchema,
        DodgedTrapSchema,
        ServiceCacheSchema,
        SyncStateSchema,
      ],
      directory: dir.path,
    );
    _initialised = true;
  }

  /// The Isar database instance.
  Isar get db => _isar;
}

import 'package:shared_preferences/shared_preferences.dart';

import '../models/dodged_trap.dart';

const _kDodgedTrapsKey = 'dodged_traps';

/// Persists dodged trap records via SharedPreferences.
///
/// Singleton following the same pattern as [NotificationService] and
/// [PurchaseService]. Call [load] once at startup, then [add] to
/// persist new dodged traps.
///
/// Will migrate to Isar when Subscriptions move to Isar.
class DodgedTrapRepository {
  DodgedTrapRepository._();
  static final instance = DodgedTrapRepository._();

  List<DodgedTrap> _cache = [];
  bool _loaded = false;

  /// Load persisted dodged traps from SharedPreferences.
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kDodgedTrapsKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      _cache = DodgedTrap.decodeList(jsonStr);
    }
    _loaded = true;
  }

  /// All dodged traps (unmodifiable).
  List<DodgedTrap> getAll() => List.unmodifiable(_cache);

  /// Add a new dodged trap and persist immediately.
  Future<void> add(DodgedTrap trap) async {
    trap.id = _cache.length;
    _cache.add(trap);
    await _persist();
  }

  /// Total money saved from all dodged traps.
  double get totalSaved => _cache.fold(0.0, (sum, t) => sum + t.savedAmount);

  /// Number of dodged traps recorded.
  int get count => _cache.length;

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDodgedTrapsKey, DodgedTrap.encodeList(_cache));
  }
}

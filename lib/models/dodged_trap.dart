import 'dart:convert';

import 'package:isar/isar.dart';

part 'dodged_trap.g.dart';

/// How the trap was dodged.
enum DodgedTrapSource {
  skipped, // user chose "Skip It" on trap warning
  trialCancelled, // cancelled trial before conversion
  refundRecovered, // got money back via refund guide
}

/// A record of a subscription trap the user successfully avoided.
///
/// Feeds the "Unchompd" counter on the home screen
/// and the Trap Dodger milestone track.
///
/// Persisted in Isar (migrated from SharedPreferences).
@collection
class DodgedTrap {
  Id id = Isar.autoIncrement;

  /// The service name that was dodged.
  String serviceName = '';

  /// Amount saved (typically the annual cost of the trap).
  double savedAmount = 0.0;

  /// When the user dodged this trap.
  DateTime dodgedAt = DateTime.now();

  /// Trap type stored as string.
  String trapType = '';

  /// How the trap was dodged.
  @enumerated
  DodgedTrapSource source = DodgedTrapSource.skipped;

  // ─── JSON Serialization (kept for SharedPreferences migration) ───

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceName': serviceName,
        'savedAmount': savedAmount,
        'dodgedAt': dodgedAt.toIso8601String(),
        'trapType': trapType,
        'source': source.name,
      };

  static DodgedTrap fromJson(Map<String, dynamic> json) {
    return DodgedTrap()
      ..serviceName = json['serviceName'] as String
      ..savedAmount = (json['savedAmount'] as num).toDouble()
      ..dodgedAt = DateTime.parse(json['dodgedAt'] as String)
      ..trapType = json['trapType'] as String
      ..source = DodgedTrapSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => DodgedTrapSource.skipped,
      );
  }

  /// Encode a list to a JSON string for SharedPreferences.
  static String encodeList(List<DodgedTrap> traps) {
    return jsonEncode(traps.map((t) => t.toJson()).toList());
  }

  /// Decode a JSON string from SharedPreferences to a list.
  static List<DodgedTrap> decodeList(String jsonStr) {
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((item) => DodgedTrap.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ─── Supabase Serialization ───

  /// Convert to Supabase-compatible map for insert.
  Map<String, dynamic> toSupabaseMap(String userId) {
    return {
      'user_id': userId,
      'service_name': serviceName,
      'saved_amount': savedAmount,
      'dodged_at': dodgedAt.toUtc().toIso8601String(),
      'trap_type': trapType,
      'source': source.name,
    };
  }

  /// Create from Supabase row.
  static DodgedTrap fromSupabaseMap(Map<String, dynamic> row) {
    return DodgedTrap()
      ..serviceName = row['service_name'] as String? ?? ''
      ..savedAmount = (row['saved_amount'] as num?)?.toDouble() ?? 0.0
      ..dodgedAt = row['dodged_at'] != null
          ? DateTime.parse(row['dodged_at'] as String)
          : DateTime.now()
      ..trapType = row['trap_type'] as String? ?? ''
      ..source = DodgedTrapSource.values.firstWhere(
        (e) => e.name == (row['source'] as String?),
        orElse: () => DodgedTrapSource.skipped,
      );
  }
}

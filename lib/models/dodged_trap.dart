import 'dart:convert';

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
/// Persisted via SharedPreferences (JSON-encoded list).
/// TODO: Migrate to Isar @collection when Subscriptions move to Isar.
class DodgedTrap {
  int id = 0;

  /// The service name that was dodged.
  late String serviceName;

  /// Amount saved (typically the annual cost of the trap).
  late double savedAmount;

  /// When the user dodged this trap.
  late DateTime dodgedAt;

  /// Trap type stored as string.
  late String trapType;

  /// How the trap was dodged.
  DodgedTrapSource source = DodgedTrapSource.skipped;

  // ─── JSON Serialization ───

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
      ..id = json['id'] as int? ?? 0
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
}

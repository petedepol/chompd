import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Logs unmatched service names locally for future database expansion.
///
/// Uses SharedPreferences for v1 (Option B from the spec).
/// Stores a list of {name, category, price, currency, reportedAt} entries.
/// Can be exported as CSV later or pushed to Supabase when ready.
class UnmatchedServiceLogger {
  UnmatchedServiceLogger._();
  static final instance = UnmatchedServiceLogger._();

  static const _key = 'unmatched_services';

  /// Log an unmatched service name.
  Future<void> log({
    required String name,
    String? category,
    double? price,
    String? currency,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_key) ?? [];

      final entry = jsonEncode({
        'name': name,
        'category': category,
        'price': price,
        'currency': currency,
        'reported_at': DateTime.now().toIso8601String(),
      });

      // Avoid duplicate logging of the same service name
      final existingNames = existing
          .map((e) {
            try {
              final map = jsonDecode(e) as Map<String, dynamic>;
              return (map['name'] as String?)?.toLowerCase();
            } catch (_) {
              return null;
            }
          })
          .whereType<String>()
          .toSet();

      if (existingNames.contains(name.toLowerCase())) {
        return; // Already logged
      }

      existing.add(entry);
      await prefs.setStringList(_key, existing);
    } catch (_) {
      // Silently ignored
    }
  }

  /// Get all logged unmatched service entries.
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entries = prefs.getStringList(_key) ?? [];
      return entries
          .map((e) {
            try {
              return jsonDecode(e) as Map<String, dynamic>;
            } catch (_) {
              return null;
            }
          })
          .whereType<Map<String, dynamic>>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Get count of unique unmatched services.
  Future<int> get count async {
    final entries = await getAll();
    return entries.length;
  }

  /// Clear all logged entries.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

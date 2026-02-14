import '../models/merchant.dart';

/// Local merchant intelligence database.
///
/// Implements the 3-tier intelligence flywheel:
/// - Tier 1: Auto-detect — known patterns, zero API calls
/// - Tier 2: Quick Confirm — learned from users, single confirm tap
/// - Tier 3: Full Question — new/ambiguous, multi-choice Q&A
///
/// For v1 this is an in-memory map. Sprint 4+ will back it with Isar.
class MerchantDb {
  MerchantDb._();
  static final instance = MerchantDb._();

  /// The in-memory merchant intelligence store.
  /// Key = uppercase pattern string (e.g. "NETFLIX.COM").
  final Map<String, Merchant> _db = {};

  /// Pre-seed with known high-confidence merchants.
  void seed() {
    final seeds = [
      _seed('NETFLIX.COM', 'Netflix', 0.99, MerchantTier.autoDetect, 8420,
          category: 'streaming', icon: 'N', color: '#E50914'),
      _seed('SPOTIFY.COM', 'Spotify', 0.99, MerchantTier.autoDetect, 7891,
          category: 'music', icon: 'S', color: '#1DB954'),
      _seed('APPLE.COM/BILL', 'iCloud+', 0.95, MerchantTier.autoDetect, 6102,
          category: 'storage', icon: '\u2601', color: '#4285F4'),
      _seed('CRU*ZWIFT', 'Zwift', 0.97, MerchantTier.autoDetect, 1205,
          category: 'fitness', icon: 'Z', color: '#FC6719'),
      _seed('AMZN DIGITAL*7.99', 'Kindle Unlimited', 0.78,
          MerchantTier.quickConfirm, 342,
          category: 'streaming', icon: 'K', color: '#FF9900'),
      _seed('PP*HEADSPACE', 'Headspace', 0.82, MerchantTier.quickConfirm, 289,
          category: 'fitness', icon: 'H', color: '#F47D31'),
      _seed('AUDIBLE UK', 'Audible', 0.88, MerchantTier.quickConfirm, 567,
          category: 'streaming', icon: 'A', color: '#FF9900'),
      _seed('GOOGLE*SVCS', 'Google Service', 0.30,
          MerchantTier.fullQuestion, 45,
          category: 'productivity', icon: 'G', color: '#4285F4'),
      _seed('MSFT*STORE', 'Microsoft Service', 0.25,
          MerchantTier.fullQuestion, 23,
          category: 'productivity', icon: 'M', color: '#00A4EF'),
    ];

    for (final m in seeds) {
      _db[m.pattern.toUpperCase()] = m;
    }
  }

  /// Look up a pattern in the local DB.
  ///
  /// Returns the [Merchant] if found, null if no match.
  /// Pattern matching is case-insensitive and supports partial contains.
  Merchant? lookup(String rawText) {
    final upper = rawText.toUpperCase().trim();

    // Exact match first
    if (_db.containsKey(upper)) return _db[upper];

    // Partial match — check if any known pattern is contained in the text
    for (final entry in _db.entries) {
      if (upper.contains(entry.key)) return entry.value;
    }

    return null;
  }

  /// Record a user confirmation, strengthening the pattern.
  ///
  /// If the pattern already exists, increments confirmCount and
  /// potentially promotes its tier. If new, creates a Tier 2 entry.
  void confirm({
    required String pattern,
    required String resolvedName,
    String? category,
    String? icon,
    String? color,
    String? defaultCycle,
  }) {
    final key = pattern.toUpperCase().trim();
    final existing = _db[key];

    if (existing != null) {
      existing
        ..confirmCount += 1
        ..updatedAt = DateTime.now();

      // Tier promotion: if enough confirms, promote to higher tier
      if (existing.tier == MerchantTier.fullQuestion &&
          existing.confirmCount >= 5) {
        existing
          ..tier = MerchantTier.quickConfirm
          ..confidence = 0.78;
      }
      if (existing.tier == MerchantTier.quickConfirm &&
          existing.confirmCount >= 20) {
        existing
          ..tier = MerchantTier.autoDetect
          ..confidence = 0.95;
      }
    } else {
      // New entry — start as Tier 2 (quick confirm)
      final m = Merchant()
        ..pattern = key
        ..resolvedName = resolvedName
        ..confidence = 0.75
        ..tier = MerchantTier.quickConfirm
        ..confirmCount = 1
        ..category = category
        ..icon = icon
        ..color = color
        ..defaultCycle = defaultCycle
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
      _db[key] = m;
    }
  }

  /// Get all merchants, optionally filtered by tier.
  List<Merchant> getAll({MerchantTier? tier}) {
    if (tier == null) return _db.values.toList();
    return _db.values.where((m) => m.tier == tier).toList();
  }

  /// Total number of merchants in the DB.
  int get count => _db.length;

  /// Stats for the intelligence flywheel display.
  Map<String, int> get tierStats {
    int t1 = 0, t2 = 0, t3 = 0;
    for (final m in _db.values) {
      switch (m.tier) {
        case MerchantTier.autoDetect:
          t1++;
        case MerchantTier.quickConfirm:
          t2++;
        case MerchantTier.fullQuestion:
          t3++;
      }
    }
    return {'tier1': t1, 'tier2': t2, 'tier3': t3};
  }

  /// Get options for a quick-confirm or full-question scenario.
  ///
  /// Returns likely alternatives for the given pattern based on
  /// similar patterns in the DB and common service names.
  List<String> getAlternatives(String resolvedName) {
    switch (resolvedName) {
      case 'Kindle Unlimited':
        return ['Amazon Prime', 'Audible', 'Amazon Music', 'Other'];
      case 'Microsoft Service':
        return [
          'Xbox Game Pass Ultimate',
          'Microsoft 365 Family',
          'Microsoft 365 Personal',
          'Xbox Game Pass Core',
          'Other',
        ];
      case 'Google Service':
        return [
          'Google One',
          'YouTube Premium',
          'Google Workspace',
          'Other',
        ];
      case 'Headspace':
        return ['Calm', 'Insight Timer', 'Other'];
      default:
        return ['Other'];
    }
  }

  // ── Seed helper ──

  static Merchant _seed(
    String pattern,
    String name,
    double confidence,
    MerchantTier tier,
    int users, {
    String? category,
    String? icon,
    String? color,
  }) {
    return Merchant()
      ..pattern = pattern
      ..resolvedName = name
      ..confidence = confidence
      ..tier = tier
      ..confirmCount = users
      ..category = category
      ..icon = icon
      ..color = color
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
  }
}

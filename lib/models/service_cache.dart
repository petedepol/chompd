import 'dart:convert';

import 'package:isar/isar.dart';

import 'cancel_guide_v2.dart';
import 'refund_template_v2.dart';
import 'service_pricing.dart';

part 'service_cache.g.dart';

/// Offline cache mirroring the Supabase `service_full` view.
///
/// Stores all child data (tiers, cancel guides, refund templates,
/// dark patterns, alternatives) as JSON strings to avoid multiple
/// Isar collections. Parsed lazily via convenience getters.
@collection
class ServiceCache {
  Id id = Isar.autoIncrement;

  /// Supabase UUID (for sync matching).
  @Index(unique: true)
  late String supabaseId;

  /// Core identity.
  @Index()
  late String slug;
  late String name;
  @Index()
  late String category;
  late String brandColor;
  late String iconLetter;
  String? iconUrl;

  /// Short 1-2 sentence service description (nullable — populated via SQL).
  String? description;

  /// URLs.
  String? websiteUrl;
  String? cancelUrl;
  String? pricingUrl;
  String? refundPolicyUrl;

  /// Flags.
  late bool hasFreeTier;
  late bool hasFamily;
  late bool hasAnnual;
  late bool hasStudent;
  double? annualDiscountPct;

  /// Currency & region.
  late String fallbackCurrency;
  late List<String> regions;

  /// Scores.
  int? cancelDifficulty;
  double? refundSuccessRate;

  // ─── Denormalised children (stored as JSON strings) ───

  /// Pricing tiers JSON array.
  late String tiersJson;

  /// Cancel guides JSON array.
  late String cancelGuidesJson;

  /// Refund templates JSON array.
  late String refundTemplatesJson;

  /// Dark pattern flags JSON array.
  late String darkPatternsJson;

  /// Alternatives JSON array.
  late String alternativesJson;

  /// Approved community tip count.
  late int communityTipCount;

  /// Aliases for fuzzy matching.
  @Index(type: IndexType.value)
  late List<String> aliases;

  // ─── Sync metadata ───

  /// Matches `services.data_version` in Supabase.
  @Index()
  late int dataVersion;

  late DateTime verifiedAt;
  late DateTime updatedAt;

  /// When this record was last synced from Supabase.
  late DateTime localSyncedAt;

  // ─── Parsed convenience getters (ignored by Isar) ───

  /// Parse tiers JSON into [ServiceTier] objects.
  @ignore
  List<ServiceTier> get parsedTiers {
    final list = _decodeJsonList(tiersJson);
    return list.map((m) {
      return ServiceTier(
        tier: m['tier_name'] as String? ?? 'Standard',
        gbp: (m['monthly_gbp'] as num?)?.toDouble(),
        gbpYr: (m['annual_gbp'] as num?)?.toDouble(),
        usd: (m['monthly_usd'] as num?)?.toDouble(),
        usdYr: (m['annual_usd'] as num?)?.toDouble(),
        eur: (m['monthly_eur'] as num?)?.toDouble(),
        eurYr: (m['annual_eur'] as num?)?.toDouble(),
        pln: (m['monthly_pln'] as num?)?.toDouble(),
        plnYr: (m['annual_pln'] as num?)?.toDouble(),
      );
    }).toList();
  }

  /// Parse cancel guides JSON into [CancelGuideData] objects.
  @ignore
  List<CancelGuideData> get parsedCancelGuides {
    final list = _decodeJsonList(cancelGuidesJson);
    return list.map((m) => CancelGuideData.fromJson(m)).toList();
  }

  /// Parse refund templates JSON into [RefundTemplateData] objects.
  @ignore
  List<RefundTemplateData> get parsedRefundTemplates {
    final list = _decodeJsonList(refundTemplatesJson);
    return list.map((m) => RefundTemplateData.fromJson(m)).toList();
  }

  /// Parse dark patterns JSON.
  @ignore
  List<Map<String, dynamic>> get parsedDarkPatterns {
    return _decodeJsonList(darkPatternsJson);
  }

  /// Parse alternatives JSON.
  @ignore
  List<Map<String, dynamic>> get parsedAlternatives {
    return _decodeJsonList(alternativesJson);
  }

  /// Convert to [ServiceInfo] for backwards compatibility with
  /// annual savings and other consumers.
  ServiceInfo toServiceInfo() {
    return ServiceInfo(
      name: name,
      slug: slug,
      category: category,
      brandColor: brandColor,
      iconLetter: iconLetter,
      fallbackCurrency: fallbackCurrency,
      tiers: parsedTiers,
    );
  }

  // ─── Static builders ───

  /// Build from a row returned by the Supabase `service_full` view.
  static ServiceCache fromSupabaseMap(Map<String, dynamic> json) {
    return ServiceCache()
      ..supabaseId = json['id'] as String
      ..slug = json['slug'] as String
      ..name = json['name'] as String
      ..category = json['category'] as String
      ..brandColor = json['brand_color'] as String? ?? '#6A6A82'
      ..iconLetter = json['icon_letter'] as String? ?? '?'
      ..iconUrl = json['icon_url'] as String?
      ..description = json['description'] as String?
      ..websiteUrl = json['website_url'] as String?
      ..cancelUrl = json['cancel_url'] as String?
      ..pricingUrl = json['pricing_url'] as String?
      ..refundPolicyUrl = json['refund_policy_url'] as String?
      ..hasFreeTier = json['has_free_tier'] as bool? ?? false
      ..hasFamily = json['has_family'] as bool? ?? false
      ..hasAnnual = json['has_annual'] as bool? ?? false
      ..hasStudent = json['has_student'] as bool? ?? false
      ..annualDiscountPct =
          (json['annual_discount_pct'] as num?)?.toDouble()
      ..fallbackCurrency = json['fallback_currency'] as String? ?? 'USD'
      ..regions = (json['regions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['GB', 'US']
      ..cancelDifficulty = json['cancel_difficulty'] as int?
      ..refundSuccessRate =
          (json['refund_success_rate'] as num?)?.toDouble()
      ..tiersJson = _encodeJson(json['tiers'])
      ..cancelGuidesJson = _encodeJson(json['cancel_guides'])
      ..refundTemplatesJson = _encodeJson(json['refund_templates'])
      ..darkPatternsJson = _encodeJson(json['dark_patterns'])
      ..alternativesJson = _encodeJson(json['alternatives'])
      ..communityTipCount = json['community_tip_count'] as int? ?? 0
      ..aliases = <String>[]
      ..dataVersion = json['data_version'] as int? ?? 1
      ..verifiedAt = DateTime.tryParse(
              json['verified_at']?.toString() ?? '') ??
          DateTime.now()
      ..updatedAt =
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
              DateTime.now()
      ..localSyncedAt = DateTime.now();
  }

  /// Build a minimal cache entry from existing static [ServiceInfo] for
  /// offline fallback. Uses `dataVersion: 0` so any real Supabase sync
  /// will overwrite it.
  ///
  /// [cancelGuideJson] should be the pre-encoded JSON for the cancel
  /// guide if available (pass from the seeding logic that has access to
  /// the cancel_guides_data import).
  static ServiceCache fromStaticServiceInfo(
    ServiceInfo info, {
    String cancelGuidesJsonStr = '[]',
    int? cancelDifficultyScore,
  }) {
    // Convert ServiceTier list → JSON matching Supabase tiers format
    final tiersJsonList = info.tiers.map((t) {
      return {
        'tier_name': t.tier,
        'monthly_gbp': t.gbp,
        'annual_gbp': t.gbpYr,
        'monthly_usd': t.usd,
        'annual_usd': t.usdYr,
        'monthly_eur': t.eur,
        'annual_eur': t.eurYr,
        'monthly_pln': t.pln,
        'annual_pln': t.plnYr,
        'is_popular': false,
      };
    }).toList();

    return ServiceCache()
      ..supabaseId = 'static_${info.slug}'
      ..slug = info.slug
      ..name = info.name
      ..category = info.category
      ..brandColor = info.brandColor
      ..iconLetter = info.iconLetter
      ..hasFreeTier = false
      ..hasFamily =
          info.tiers.any((t) => t.tier.toLowerCase().contains('family'))
      ..hasAnnual = info.hasAnyAnnualPlan
      ..hasStudent =
          info.tiers.any((t) => t.tier.toLowerCase().contains('student'))
      ..fallbackCurrency = info.fallbackCurrency
      ..regions = ['GB', 'US']
      ..cancelDifficulty = cancelDifficultyScore
      ..tiersJson = jsonEncode(tiersJsonList)
      ..cancelGuidesJson = cancelGuidesJsonStr
      ..refundTemplatesJson = '[]'
      ..darkPatternsJson = '[]'
      ..alternativesJson = '[]'
      ..communityTipCount = 0
      ..aliases = <String>[]
      ..dataVersion = 0
      ..verifiedAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..localSyncedAt = DateTime.now();
  }

  // ─── Helpers ───

  static String _encodeJson(dynamic value) {
    if (value == null) return '[]';
    if (value is String) return value;
    return jsonEncode(value);
  }

  static List<Map<String, dynamic>> _decodeJsonList(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

// ─── Sync state tracking ───

/// Tracks the last successful service cache sync.
@collection
class SyncState {
  Id id = Isar.autoIncrement;

  /// Last successfully synced `data_version`.
  late int lastSyncedVersion;

  /// When was the last successful sync.
  late DateTime lastSyncedAt;

  /// How many services were updated in last sync.
  late int lastSyncCount;
}

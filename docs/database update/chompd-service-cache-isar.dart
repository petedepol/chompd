// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHOMPD — Isar Offline Cache Model
// Mirrors the service_full Supabase view as a single
// denormalized collection. No more separate Isar models
// for CancelGuide, RefundTemplate, etc.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'package:isar/isar.dart';

part 'service_cache.g.dart';

@collection
class ServiceCache {
  Id id = Isar.autoIncrement;

  /// Supabase UUID (for sync matching)
  @Index(unique: true)
  late String supabaseId;

  /// Core identity
  @Index()
  late String slug;
  late String name;
  @Index()
  late String category;
  late String brandColor;
  late String iconLetter;
  String? iconUrl;

  /// URLs
  String? websiteUrl;
  String? cancelUrl;
  String? pricingUrl;
  String? refundPolicyUrl;

  /// Flags
  late bool hasFreeTier;
  late bool hasFamily;
  late bool hasAnnual;
  late bool hasStudent;
  double? annualDiscountPct;

  /// Currency & region
  late String fallbackCurrency; // 'GBP', 'USD', 'EUR', 'PLN'
  late List<String> regions;

  /// Scores
  int? cancelDifficulty; // 1-10
  double? refundSuccessRate;

  /// ━━━ DENORMALIZED CHILDREN (stored as JSON strings) ━━━

  /// Pricing tiers — JSON array
  /// [{tier_name, monthly_gbp, annual_gbp, ..., trial_days, trial_requires_payment, is_popular}]
  late String tiersJson;

  /// Cancel guides — JSON array
  /// [{platform, steps: [{step, title, detail, deeplink}], cancel_deeplink, warning_text, pro_tip}]
  late String cancelGuidesJson;

  /// Refund templates — JSON array
  /// [{billing_method, steps, email_template, email_subject, contact_email, success_rate_pct, ...}]
  late String refundTemplatesJson;

  /// Dark pattern flags — JSON array
  /// [{pattern_type, severity, title, description, is_active}]
  late String darkPatternsJson;

  /// Alternatives — JSON array
  /// [{alt_name, reason, price_comparison, relevance_score}]
  late String alternativesJson;

  /// Community tip count (just the number, not full tips — those load on demand)
  late int communityTipCount;

  /// Aliases (for fuzzy matching)
  @Index(type: IndexType.value)
  late List<String> aliases;

  /// ━━━ SYNC METADATA ━━━

  /// Matches services.data_version in Supabase
  @Index()
  late int dataVersion;

  late DateTime verifiedAt;
  late DateTime updatedAt;
  late DateTime localSyncedAt; // when this record was last synced from Supabase
}


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SYNC METADATA (tracks last sync state)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@collection
class SyncState {
  Id id = Isar.autoIncrement;

  /// Last successfully synced data_version
  late int lastSyncedVersion;

  /// When was the last successful sync
  late DateTime lastSyncedAt;

  /// How many services were updated in last sync
  late int lastSyncCount;
}

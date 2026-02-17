import 'package:isar/isar.dart';

part 'service_insight.g.dart';

/// A curated insight for a specific service, synced from Supabase.
///
/// These are editorial tips like "Your iCloud+ includes a free VPN"
/// or "Switch Strava to annual and save 40%". Not computed from
/// user data (those live in [insightsProvider]).
@collection
class ServiceInsight {
  Id id = Isar.autoIncrement;

  /// Supabase UUID (for sync matching / dedup).
  @Index(unique: true)
  late String remoteId;

  /// Matches ServiceCache.slug (e.g. 'netflix', 'spotify').
  @Index()
  late String serviceKey;

  /// Insight category: 'hidden_perk', 'plan_optimise', 'annual_saving', etc.
  late String insightType;

  /// English title.
  late String title;

  /// Polish title (nullable).
  String? titlePl;

  /// English body text.
  late String body;

  /// Polish body text (nullable).
  String? bodyPl;

  /// Optional CTA button text (English).
  String? actionLabel;

  /// Optional CTA button text (Polish).
  String? actionLabelPl;

  /// Action type: 'info', 'cancel_reminder', 'plan_change', 'external_link'.
  String? actionType;

  /// Higher = show first.
  int priority = 0;

  /// Local-only: user dismissed this insight. Not synced to Supabase.
  bool isDismissed = false;

  // ─── Supabase mapping ───

  /// Create from a Supabase `service_insights` row.
  static ServiceInsight fromSupabaseMap(Map<String, dynamic> row) {
    return ServiceInsight()
      ..remoteId = row['id'] as String
      ..serviceKey = row['service_key'] as String? ?? ''
      ..insightType = row['insight_type'] as String? ?? 'hidden_perk'
      ..title = row['title'] as String? ?? ''
      ..titlePl = row['title_pl'] as String?
      ..body = row['body'] as String? ?? ''
      ..bodyPl = row['body_pl'] as String?
      ..actionLabel = row['action_label'] as String?
      ..actionLabelPl = row['action_label_pl'] as String?
      ..actionType = row['action_type'] as String?
      ..priority = (row['priority'] as num?)?.toInt() ?? 0
      ..isDismissed = false;
  }
}

import 'package:isar/isar.dart';

part 'user_insight.g.dart';

/// An AI-generated insight for a specific user, synced from Supabase.
///
/// These are personalised tips generated server-side by Claude Haiku
/// (e.g. "Switch Netflix to annual and save £24/year"). Unlike
/// [ServiceInsight] (editorial, same for all users), these are
/// scoped to a single user via [userId].
///
/// Dismiss and read state sync back to Supabase (fire-and-forget).
@collection
class UserInsight {
  Id id = Isar.autoIncrement;

  /// Supabase UUID (for sync matching / dedup).
  @Index(unique: true)
  late String remoteId;

  /// The auth user this insight belongs to.
  late String userId;

  /// Links to a specific subscription (nullable).
  String? subscriptionId;

  /// Matches ServiceCache.slug (e.g. 'netflix', 'spotify').
  @Index()
  String? serviceKey;

  /// Insight category: 'hidden_perk', 'plan_optimise', 'annual_saving',
  /// 'cancel_timing', etc.
  late String insightType;

  /// Insight title (in user's language — AI-generated).
  late String title;

  /// Insight body text (in user's language — AI-generated).
  late String body;

  /// Optional CTA button text.
  String? actionLabel;

  /// Action type: 'info', 'cancel_reminder', 'plan_change'.
  String? actionType;

  /// Higher = show first.
  int priority = 0;

  /// Whether the user has seen this insight.
  bool isRead = false;

  /// Whether the user dismissed this insight. Synced to Supabase.
  bool isDismissed = false;

  /// When this insight was generated server-side.
  late DateTime generatedAt;

  /// Optional expiry — insight auto-hides after this date.
  DateTime? expiresAt;

  // ─── Supabase mapping ───

  /// Create from a Supabase `user_insights` row.
  static UserInsight fromSupabaseMap(Map<String, dynamic> row) {
    return UserInsight()
      ..remoteId = row['id'] as String
      ..userId = row['user_id'] as String? ?? ''
      ..subscriptionId = row['subscription_id'] as String?
      ..serviceKey = row['service_key'] as String?
      ..insightType = row['insight_type'] as String? ?? 'general'
      ..title = row['title'] as String? ?? ''
      ..body = row['body'] as String? ?? ''
      ..actionLabel = row['action_label'] as String?
      ..actionType = row['action_type'] as String?
      ..priority = (row['priority'] as num?)?.toInt() ?? 0
      ..isRead = row['is_read'] as bool? ?? false
      ..isDismissed = false
      ..generatedAt = row['generated_at'] != null
          ? DateTime.parse(row['generated_at'] as String)
          : DateTime.now()
      ..expiresAt = row['expires_at'] != null
          ? DateTime.parse(row['expires_at'] as String)
          : null;
  }
}

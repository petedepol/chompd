/// Unified display model for both curated (ServiceInsight) and
/// AI-generated (UserInsight) insights shown in the home carousel.
///
/// This is a pure display DTO — not persisted in Isar.
/// Both [ServiceInsight] and [UserInsight] map to this for rendering.
class InsightDisplayData {
  /// Isar ID — used for dismiss and read operations.
  final int isarId;

  /// Supabase UUID — used for Supabase sync operations.
  final String remoteId;

  /// Insight category: 'hidden_perk', 'plan_optimise', 'annual_saving', etc.
  final String insightType;

  /// Display title (already localised for curated insights).
  final String title;

  /// Display body (already localised for curated insights).
  final String body;

  /// Optional CTA button text.
  final String? actionLabel;

  /// Action type: 'info', 'cancel_reminder', 'plan_change'.
  final String? actionType;

  /// Higher = show first.
  final int priority;

  /// True for AI-generated (UserInsight), false for curated (ServiceInsight).
  final bool isAiGenerated;

  /// Service key linking to a specific subscription (nullable).
  final String? serviceKey;

  const InsightDisplayData({
    required this.isarId,
    required this.remoteId,
    required this.insightType,
    required this.title,
    required this.body,
    this.actionLabel,
    this.actionType,
    this.priority = 0,
    this.isAiGenerated = false,
    this.serviceKey,
  });
}

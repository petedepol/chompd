import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/insight_display_data.dart';
import '../services/user_insight_repository.dart';
import 'locale_provider.dart';
import 'service_insight_provider.dart';

/// Provides a merged list of AI user insights + curated service insights.
///
/// AI insights shown first (higher priority, personalised), curated last.
/// Maximum 3 total to prevent carousel bloat.
///
/// Used by [ServiceInsightCard] to render the unified insight carousel.
final combinedInsightsProvider = Provider<List<InsightDisplayData>>((ref) {
  // 1. AI-generated user insights (reads synchronously from Isar)
  final aiInsights = UserInsightRepository.instance.getActiveInsights();

  // 2. Curated service insights (from existing Phase 1 provider)
  final serviceInsights = ref.watch(serviceInsightsListProvider);

  // Locale for curated insight localisation
  final locale = ref.watch(localeProvider);
  final isPl = locale.languageCode == 'pl';

  final combined = <InsightDisplayData>[];

  // AI insights first (max 3)
  for (final ai in aiInsights) {
    if (combined.length >= 3) break;
    combined.add(InsightDisplayData(
      isarId: ai.id,
      remoteId: ai.remoteId,
      insightType: ai.insightType,
      title: ai.title,
      body: ai.body,
      actionLabel: ai.actionLabel,
      actionType: ai.actionType,
      priority: ai.priority,
      isAiGenerated: true,
      serviceKey: ai.serviceKey,
    ));
  }

  // Fill remaining slots with curated insights (up to 3 total)
  for (final si in serviceInsights) {
    if (combined.length >= 3) break;
    combined.add(InsightDisplayData(
      isarId: si.id,
      remoteId: si.remoteId,
      insightType: si.insightType,
      title: (isPl && si.titlePl != null) ? si.titlePl! : si.title,
      body: (isPl && si.bodyPl != null) ? si.bodyPl! : si.body,
      actionLabel: (isPl && si.actionLabelPl != null)
          ? si.actionLabelPl
          : si.actionLabel,
      actionType: si.actionType,
      priority: si.priority,
      isAiGenerated: false,
      serviceKey: si.serviceKey,
    ));
  }

  return combined;
});

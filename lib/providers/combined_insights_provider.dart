import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/insight_display_data.dart';
import '../models/subscription.dart';
import '../services/user_insight_repository.dart';
import 'locale_provider.dart';
import 'service_cache_provider.dart';
import 'service_insight_provider.dart';
import 'subscriptions_provider.dart';

/// Pick a localised string by language code, falling back to English.
String _localized(
  String en,
  String lang, {
  String? pl,
  String? de,
  String? fr,
  String? es,
}) {
  switch (lang) {
    case 'pl':
      return pl ?? en;
    case 'de':
      return de ?? en;
    case 'fr':
      return fr ?? en;
    case 'es':
      return es ?? en;
    default:
      return en;
  }
}

extension _StringExt on String {
  /// Returns null if the string is empty, otherwise itself.
  String? ifEmpty(String? fallback) => isEmpty ? fallback : this;
}

/// Provides a merged list of AI user insights + curated service insights.
///
/// AI insights shown first (higher priority, personalised), curated last.
/// Maximum 3 total to prevent carousel bloat.
///
/// Validates `annual_saving` insights against the service database —
/// drops insights suggesting annual billing for services that don't offer it
/// (e.g. ChatGPT Plus, iCloud+, Netflix are monthly-only).
/// Also drops `annual_saving` insights when the user's subscription is
/// already on a yearly billing cycle.
///
/// Used by [ServiceInsightCard] to render the unified insight carousel.
final combinedInsightsProvider = Provider<List<InsightDisplayData>>((ref) {
  // 1. AI-generated user insights (reads synchronously from Isar)
  final aiInsights = UserInsightRepository.instance.getActiveInsights();

  // 2. Curated service insights (from existing Phase 1 provider)
  final serviceInsights = ref.watch(serviceInsightsListProvider);

  // Service cache for annual plan validation
  final cache = ref.watch(serviceCacheProvider.notifier);

  // User subscriptions — used to skip annual_saving insights for subs
  // already on a yearly billing cycle.
  final subs = ref.watch(subscriptionsProvider);

  // Locale for curated insight localisation
  final locale = ref.watch(localeProvider);
  final lang = locale.languageCode;

  /// Returns true if the user already has a yearly subscription matching
  /// the given [serviceKey].
  bool isAlreadyYearly(String? serviceKey) {
    if (serviceKey == null) return false;
    final key = serviceKey.toLowerCase();
    return subs.any((s) =>
        s.isActive &&
        s.cycle == BillingCycle.yearly &&
        s.name.toLowerCase().contains(key));
  }

  // Build a set of service slugs the user actually has
  final userServiceSlugs = <String>{};
  for (final sub in subs.where((s) => s.isActive)) {
    if (sub.matchedServiceId != null) {
      final service = cache.findById(sub.matchedServiceId!);
      if (service != null) {
        userServiceSlugs.add(service.slug);
        continue;
      }
    }
    // Fallback: try name matching
    final service = cache.findByName(sub.name);
    if (service != null) userServiceSlugs.add(service.slug);
  }

  final combined = <InsightDisplayData>[];

  // AI insights first (max 3), with annual_saving validation
  // AND subscription matching — only show if user has the matching service
  for (final ai in aiInsights) {
    if (combined.length >= 3) break;

    // Guard: only show insights for services the user actually has
    if (ai.serviceKey != null &&
        !userServiceSlugs.contains(ai.serviceKey)) {
      continue;
    }

    // Guard: drop 'annual_saving' insights for services without annual plans
    // or when the user's subscription is already on a yearly cycle.
    // The AI sometimes hallucinates annual savings for monthly-only services
    // (e.g. ChatGPT Plus, iCloud+, Netflix, Disney+).
    if (ai.insightType == 'annual_saving') {
      if (isAlreadyYearly(ai.serviceKey)) continue;
      if (ai.serviceKey != null) {
        final service = cache.findByName(ai.serviceKey!);
        if (service != null && !service.hasAnnual) continue;
      }
    }

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

  // Fill remaining slots with curated insights (up to 3 total),
  // with the same annual_saving validation
  for (final si in serviceInsights) {
    if (combined.length >= 3) break;

    // Same annual_saving guards as above
    if (si.insightType == 'annual_saving') {
      if (isAlreadyYearly(si.serviceKey)) continue;
      final service = cache.findByName(si.serviceKey);
      if (service != null && !service.hasAnnual) continue;
    }

    combined.add(InsightDisplayData(
      isarId: si.id,
      remoteId: si.remoteId,
      insightType: si.insightType,
      title: _localized(si.title, lang,
          pl: si.titlePl, de: si.titleDe, fr: si.titleFr, es: si.titleEs),
      body: _localized(si.body, lang,
          pl: si.bodyPl, de: si.bodyDe, fr: si.bodyFr, es: si.bodyEs),
      actionLabel: _localized(si.actionLabel ?? '', lang,
              pl: si.actionLabelPl,
              de: si.actionLabelDe,
              fr: si.actionLabelFr,
              es: si.actionLabelEs)
          .ifEmpty(null),
      actionType: si.actionType,
      priority: si.priority,
      isAiGenerated: false,
      serviceKey: si.serviceKey,
    ));
  }

  return combined;
});

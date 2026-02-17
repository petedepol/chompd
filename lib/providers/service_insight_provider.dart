import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/service_insight.dart';
import '../services/service_insight_repository.dart';
import 'service_cache_provider.dart';
import 'subscriptions_provider.dart';

/// Provides all non-dismissed curated insights matching the user's active
/// subscriptions. Used by [ServiceInsightCard] to cycle through insights.
final serviceInsightsListProvider = Provider<List<ServiceInsight>>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  final cache = ref.watch(serviceCacheProvider.notifier);

  // Build a set of service slugs for the user's active subscriptions
  final slugs = <String>{};
  for (final sub in subs.where((s) => s.isActive)) {
    if (sub.matchedServiceId != null) {
      final service = cache.findById(sub.matchedServiceId!);
      if (service != null) {
        slugs.add(service.slug);
        continue;
      }
    }
    // Fallback: try name matching
    final service = cache.findByName(sub.name);
    if (service != null) slugs.add(service.slug);
  }

  if (slugs.isEmpty) return [];

  return ServiceInsightRepository.instance.getForServices(slugs.toList());
});

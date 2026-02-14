import '../models/service_pricing.dart';
import '../models/subscription.dart';
import '../providers/service_cache_provider.dart';

/// Result of an annual savings computation for one subscription.
class SubSavingsResult {
  final Subscription subscription;
  final ServiceInfo service;
  final ServiceTier matchedTier;
  final double monthlyPrice;
  final double annualPrice;
  final double savings;

  const SubSavingsResult({
    required this.subscription,
    required this.service,
    required this.matchedTier,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.savings,
  });
}

/// Aggregated savings result for the dashboard card.
class AnnualSavingsResult {
  final double totalSavings;
  final List<SubSavingsResult> items;
  final int matchedCount;
  final int totalActiveCount;

  const AnnualSavingsResult({
    required this.totalSavings,
    required this.items,
    required this.matchedCount,
    required this.totalActiveCount,
  });

  bool get isEmpty => items.isEmpty;
}

/// Computes annual savings opportunities from the user's subscriptions.
class AnnualSavingsService {
  AnnualSavingsService._();

  static AnnualSavingsResult compute({
    required List<Subscription> subscriptions,
    required String displayCurrency,
    required ServiceCacheNotifier cacheNotifier,
  }) {
    final active = subscriptions.where((s) => s.isActive).toList();
    final results = <SubSavingsResult>[];

    for (final sub in active) {
      // Skip subs already on yearly billing
      if (sub.cycle == BillingCycle.yearly) continue;

      final service = cacheNotifier.findByName(sub.name);
      if (service == null) continue;

      final tier = cacheNotifier.findBestTier(sub, service, displayCurrency);
      if (tier == null) continue;

      final pair = cacheNotifier.resolvePricePair(tier, service, displayCurrency);
      if (pair == null) continue;

      final monthly = pair.monthly;
      final annual = pair.annual;
      final savings = (monthly * 12) - annual;
      if (savings <= 0) continue;

      final serviceInfo = service.toServiceInfo();
      results.add(SubSavingsResult(
        subscription: sub,
        service: serviceInfo,
        matchedTier: tier,
        monthlyPrice: monthly,
        annualPrice: annual,
        savings: savings,
      ));
    }

    results.sort((a, b) => b.savings.compareTo(a.savings));

    return AnnualSavingsResult(
      totalSavings: results.fold(0.0, (sum, r) => sum + r.savings),
      items: results,
      matchedCount: results.length,
      totalActiveCount: active.length,
    );
  }
}

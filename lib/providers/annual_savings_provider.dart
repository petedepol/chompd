import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/annual_savings_service.dart';
import 'currency_provider.dart';
import 'service_cache_provider.dart';
import 'subscriptions_provider.dart';

/// Computed annual savings from switching monthly subs to yearly plans.
final annualSavingsProvider = Provider<AnnualSavingsResult>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  final currency = ref.watch(currencyProvider);
  // Watch the cache list so this recomputes when sync finishes
  ref.watch(serviceCacheProvider);
  final cacheNotifier = ref.read(serviceCacheProvider.notifier);

  return AnnualSavingsService.compute(
    subscriptions: subs,
    displayCurrency: currency,
    cacheNotifier: cacheNotifier,
  );
});

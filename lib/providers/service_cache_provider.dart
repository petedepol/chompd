import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/cancel_guide_v2.dart';
import '../models/refund_template_v2.dart';
import '../models/service_cache.dart';
import '../models/service_pricing.dart';
import '../models/subscription.dart';
import '../services/exchange_rate_service.dart';
import '../services/isar_service.dart';

/// Provides the cached service database as an in-memory list.
///
/// Loads from Isar on init, then exposes lookup methods matching the
/// old static helper API (`findServiceByName`, `findBestTier`, etc.).
final serviceCacheProvider =
    StateNotifierProvider<ServiceCacheNotifier, List<ServiceCache>>(
  (ref) => ServiceCacheNotifier(),
);

class ServiceCacheNotifier extends StateNotifier<List<ServiceCache>> {
  ServiceCacheNotifier() : super([]) {
    _load();
  }

  Isar get _isar => IsarService.instance.db;

  /// Load all services from Isar into memory.
  Future<void> _load() async {
    final all = await _isar.serviceCaches.where().findAll();
    state = all;
  }

  /// Refresh from Isar (call after sync completes).
  Future<void> refresh() async {
    await _load();
  }

  /// Whether any services are loaded.
  bool get hasData => state.isNotEmpty;

  // ─── Lookup methods (replace static helpers) ───

  /// Find a [ServiceCache] by subscription name (fuzzy matching).
  ServiceCache? findByName(String name) {
    final normalised = name.toLowerCase().trim();
    final slug = normalised.replaceAll(' ', '_');

    // 1. Exact slug match
    for (final s in state) {
      if (s.slug == slug) return s;
    }

    // 2. Alias match
    for (final s in state) {
      if (s.aliases.contains(normalised)) return s;
    }

    // 3. Exact name match (case-insensitive)
    for (final s in state) {
      if (s.name.toLowerCase() == normalised) return s;
    }

    // 4. Partial match
    for (final s in state) {
      final sLower = s.name.toLowerCase();
      if (normalised.contains(sLower) || sLower.contains(normalised)) {
        return s;
      }
    }

    return null;
  }

  /// Find the best matching cancel guide for a subscription.
  CancelGuideData? findCancelGuide(String name, {bool isIOS = true}) {
    final service = findByName(name);
    if (service != null) {
      final guides = service.parsedCancelGuides;
      if (guides.isNotEmpty) {
        // Try platform-specific first
        final platform = isIOS ? 'ios' : 'android';
        final specific = guides.where((g) => g.platform == platform);
        if (specific.isNotEmpty) return specific.first;

        // Try 'all' platform
        final all = guides.where((g) => g.platform == 'all');
        if (all.isNotEmpty) return all.first;

        // Return first available
        return guides.first;
      }
    }

    // Fallback to generic platform guide
    final genericSlug =
        isIOS ? 'app_store_generic' : 'google_play_generic';
    for (final s in state) {
      if (s.slug == genericSlug) {
        final guides = s.parsedCancelGuides;
        if (guides.isNotEmpty) return guides.first;
      }
    }

    return null;
  }

  /// Find service-specific refund templates.
  List<RefundTemplateData> findRefundTemplates(String name) {
    final service = findByName(name);
    if (service == null) return [];
    return service.parsedRefundTemplates;
  }

  /// Get the cancel difficulty score for a service (1-10).
  int? getCancelDifficulty(String name) {
    return findByName(name)?.cancelDifficulty;
  }

  /// Try to match a subscription name against the service database.
  /// Returns the Supabase UUID if matched, null otherwise.
  String? matchServiceId(String name) {
    final service = findByName(name);
    return service?.supabaseId;
  }

  // ─── Pricing helpers (match old API) ───

  /// Find the tier whose monthly price is closest to the user's actual price.
  ServiceTier? findBestTier(
    Subscription sub,
    ServiceCache service,
    String displayCurrency,
  ) {
    final tiers = service.parsedTiers;
    if (tiers.isEmpty) return null;
    if (tiers.length == 1) return tiers.first;

    final info = service.toServiceInfo();
    final userMonthly = sub.monthlyEquivalentIn(displayCurrency);
    ServiceTier? best;
    double bestDiff = double.infinity;

    for (final tier in tiers) {
      final tierMonthly = _resolveMonthlyPrice(tier, info, displayCurrency);
      if (tierMonthly == null) continue;
      final diff = (tierMonthly - userMonthly).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        best = tier;
      }
    }

    return best;
  }

  /// Resolve monthly + annual prices from the SAME currency source.
  ({double monthly, double annual})? resolvePricePair(
    ServiceTier tier,
    ServiceCache service,
    String displayCurrency,
  ) {
    final info = service.toServiceInfo();
    final sources = [
      displayCurrency,
      info.fallbackCurrency,
      'GBP',
      'USD',
    ];

    for (final code in sources) {
      final m = tier.monthlyPrice(code);
      final a = tier.annualPrice(code);
      if (m != null && a != null) {
        if (code == displayCurrency) {
          return (monthly: m, annual: a);
        }
        final fx = ExchangeRateService.instance;
        return (
          monthly: fx.convert(m, code, displayCurrency),
          annual: fx.convert(a, code, displayCurrency),
        );
      }
    }

    return null;
  }

  double? _resolveMonthlyPrice(
    ServiceTier tier,
    ServiceInfo service,
    String displayCurrency,
  ) {
    final direct = tier.monthlyPrice(displayCurrency);
    if (direct != null) return direct;

    final fb = tier.monthlyPrice(service.fallbackCurrency);
    if (fb != null) {
      return ExchangeRateService.instance.convert(
        fb,
        service.fallbackCurrency,
        displayCurrency,
      );
    }

    for (final code in ['GBP', 'USD']) {
      final p = tier.monthlyPrice(code);
      if (p != null) {
        return ExchangeRateService.instance.convert(
            p, code, displayCurrency);
      }
    }

    return null;
  }
}

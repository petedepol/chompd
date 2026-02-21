import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/subscription.dart';
import 'currency_provider.dart';
import 'subscriptions_provider.dart';

/// Maps a normalised date (year-month-day, no time) to the list of
/// subscriptions that renew on that date.
///
/// Populates the next 12 months of renewals for each active subscription
/// based on its billing cycle.
final renewalCalendarProvider =
    Provider<Map<DateTime, List<Subscription>>>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  final active = subs.where((s) => s.isActive).toList();

  final map = <DateTime, List<Subscription>>{};

  for (final sub in active) {
    final dates = _projectRenewals(sub, months: 12);
    for (final date in dates) {
      final key = _normalise(date);
      map.putIfAbsent(key, () => []).add(sub);
    }
  }

  return map;
});

/// Provider: total spend for a given day (converted to display currency).
/// Uses date-aware pricing so intro/trial subs show realPrice after expiry.
final daySpendProvider =
    Provider.family<double, DateTime>((ref, day) {
  final calendar = ref.watch(renewalCalendarProvider);
  final currency = ref.watch(currencyProvider);
  final key = _normalise(day);
  final subs = calendar[key];
  if (subs == null || subs.isEmpty) return 0;
  return subs.fold(0.0, (sum, s) => sum + s.priceInOnDate(currency, day));
});

/// Projects future renewal dates for a subscription across N months.
List<DateTime> _projectRenewals(Subscription sub, {int months = 12}) {
  final dates = <DateTime>[];
  final now = DateTime.now();
  final limit = DateTime(now.year, now.month + months, now.day);

  var current = sub.nextRenewal;

  // If next renewal is in the past, advance to future
  while (current.isBefore(now.subtract(const Duration(days: 1)))) {
    current = _advanceByCycle(current, sub.cycle);
  }

  // Project forward
  while (current.isBefore(limit)) {
    dates.add(current);
    current = _advanceByCycle(current, sub.cycle);
  }

  return dates;
}

DateTime _advanceByCycle(DateTime date, BillingCycle cycle) {
  switch (cycle) {
    case BillingCycle.weekly:
      return date.add(const Duration(days: 7));
    case BillingCycle.monthly:
      return DateTime(date.year, date.month + 1, date.day);
    case BillingCycle.quarterly:
      return DateTime(date.year, date.month + 3, date.day);
    case BillingCycle.yearly:
      return DateTime(date.year + 1, date.month, date.day);
  }
}

/// Strips time component for map key consistency.
DateTime _normalise(DateTime d) => DateTime(d.year, d.month, d.day);

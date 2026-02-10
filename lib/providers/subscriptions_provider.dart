import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/subscription.dart';

/// Mock subscription data matching the visual design prototype.
///
/// In Sprint 2, this will be replaced with Isar-backed persistence.
List<Subscription> _buildMockSubscriptions() {
  final now = DateTime.now();

  Subscription make({
    required String name,
    required double price,
    required String currency,
    required BillingCycle cycle,
    required int renewInDays,
    required String category,
    required String icon,
    required String brandColor,
    bool isTrial = false,
    int? trialDays,
  }) {
    final sub = Subscription()
      ..uid = name.toLowerCase().replaceAll(' ', '-')
      ..name = name
      ..price = price
      ..currency = currency
      ..cycle = cycle
      ..nextRenewal = now.add(Duration(days: renewInDays))
      ..category = category
      ..iconName = icon
      ..brandColor = brandColor
      ..isTrial = isTrial
      ..isActive = true
      ..source = SubscriptionSource.manual
      ..createdAt = now.subtract(const Duration(days: 60));

    if (isTrial && trialDays != null) {
      sub.trialEndDate = now.add(Duration(days: trialDays));
    }

    return sub;
  }

  return [
    make(
      name: 'Netflix',
      price: 15.99,
      currency: 'GBP',
      cycle: BillingCycle.monthly,
      renewInDays: 22,
      category: 'Entertainment',
      icon: 'N',
      brandColor: '#E50914',
    ),
    make(
      name: 'Spotify',
      price: 10.99,
      currency: 'GBP',
      cycle: BillingCycle.monthly,
      renewInDays: 1,
      category: 'Music',
      icon: 'S',
      brandColor: '#1DB954',
    ),
    make(
      name: 'Figma Pro',
      price: 9.99,
      currency: 'USD',
      cycle: BillingCycle.monthly,
      renewInDays: 5,
      category: 'Design',
      icon: 'F',
      brandColor: '#A259FF',
      isTrial: true,
      trialDays: 11,
    ),
    make(
      name: 'Zwift',
      price: 17.99,
      currency: 'GBP',
      cycle: BillingCycle.monthly,
      renewInDays: 12,
      category: 'Fitness',
      icon: 'Z',
      brandColor: '#FC6719',
    ),
    make(
      name: 'iCloud+',
      price: 2.99,
      currency: 'GBP',
      cycle: BillingCycle.monthly,
      renewInDays: 18,
      category: 'Storage',
      icon: '\u2601', // ☁
      brandColor: '#4285F4',
    ),
    make(
      name: 'ChatGPT Plus',
      price: 20.00,
      currency: 'USD',
      cycle: BillingCycle.monthly,
      renewInDays: 8,
      category: 'Productivity',
      icon: 'G',
      brandColor: '#10A37F',
    ),
    make(
      name: 'Xbox Game Pass',
      price: 10.99,
      currency: 'GBP',
      cycle: BillingCycle.monthly,
      renewInDays: 15,
      category: 'Gaming',
      icon: 'X',
      brandColor: '#107C10',
      isTrial: true,
      trialDays: 3,
    ),
    make(
      name: 'Strava',
      price: 6.99,
      currency: 'GBP',
      cycle: BillingCycle.monthly,
      renewInDays: 28,
      category: 'Fitness',
      icon: '\u25B2', // ▲
      brandColor: '#FC4C02',
    ),
  ];
}

/// Provider: all subscriptions (active + cancelled).
final subscriptionsProvider =
    StateNotifierProvider<SubscriptionsNotifier, List<Subscription>>((ref) {
  return SubscriptionsNotifier();
});

/// Provider: cancelled subscriptions — derived from the main list.
final cancelledSubsProvider = Provider<List<Subscription>>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  return subs.where((s) => !s.isActive && s.cancelledDate != null).toList()
    ..sort((a, b) => (b.cancelledDate ?? DateTime.now())
        .compareTo(a.cancelledDate ?? DateTime.now()));
});

/// Provider: total monthly spend.
final monthlySpendProvider = Provider<double>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  return subs
      .where((s) => s.isActive)
      .fold(0.0, (sum, s) => sum + s.monthlyEquivalent);
});

/// Provider: total yearly spend.
final yearlySpendProvider = Provider<double>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  return subs
      .where((s) => s.isActive)
      .fold(0.0, (sum, s) => sum + s.yearlyEquivalent);
});

/// Provider: subscriptions with expiring trials.
final expiringTrialsProvider = Provider<List<Subscription>>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  return subs
      .where((s) =>
          s.isActive &&
          s.isTrial &&
          s.trialDaysRemaining != null &&
          s.trialDaysRemaining! <= 7)
      .toList()
    ..sort((a, b) =>
        (a.trialDaysRemaining ?? 99).compareTo(b.trialDaysRemaining ?? 99));
});

/// Provider: total money saved from cancelled subs.
///
/// Calculated as: monthlyEquivalent × months since cancellation.
final totalSavedProvider = Provider<double>((ref) {
  final cancelled = ref.watch(cancelledSubsProvider);
  return cancelled.fold(0.0, (sum, sub) {
    if (sub.cancelledDate == null) return sum;
    final monthsSinceCancelled =
        DateTime.now().difference(sub.cancelledDate!).inDays / 30;
    return sum + (sub.monthlyEquivalent * monthsSinceCancelled);
  });
});

/// State notifier for subscription list management.
///
/// In Sprint 2 this will integrate with Isar for persistence.
class SubscriptionsNotifier extends StateNotifier<List<Subscription>> {
  SubscriptionsNotifier() : super(_buildMockSubscriptions());

  void add(Subscription sub) {
    state = [...state, sub];
  }

  void remove(String uid) {
    state = state.where((s) => s.uid != uid).toList();
  }

  void update(Subscription updated) {
    state = [
      for (final s in state)
        if (s.uid == updated.uid) updated else s,
    ];
  }

  void cancel(String uid) {
    state = [
      for (final s in state)
        if (s.uid == uid)
          (s
            ..isActive = false
            ..cancelledDate = DateTime.now())
        else
          s,
    ];
  }
}

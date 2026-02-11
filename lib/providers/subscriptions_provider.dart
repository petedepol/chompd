import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/subscription.dart';

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
/// Starts empty — users add subscriptions via AI Scan or Quick Add.
/// Will integrate with Isar for persistence in a future sprint.
class SubscriptionsNotifier extends StateNotifier<List<Subscription>> {
  SubscriptionsNotifier() : super([]);

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

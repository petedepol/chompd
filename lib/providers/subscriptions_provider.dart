import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/constants.dart';
import '../models/subscription.dart';
import 'currency_provider.dart';

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

/// Provider: total monthly spend (converted to display currency).
final monthlySpendProvider = Provider<double>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  final displayCurrency = ref.watch(currencyProvider);
  return subs
      .where((s) => s.isActive)
      .fold(0.0, (sum, s) => sum + s.monthlyEquivalentIn(displayCurrency));
});

/// Provider: total yearly spend (converted to display currency).
final yearlySpendProvider = Provider<double>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  final displayCurrency = ref.watch(currencyProvider);
  return subs
      .where((s) => s.isActive)
      .fold(0.0, (sum, s) => sum + s.yearlyEquivalentIn(displayCurrency));
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

/// Provider: total money saved from cancelled subs (converted to display currency).
///
/// Calculated as: monthlyEquivalentIn(displayCurrency) × months since cancellation.
final totalSavedProvider = Provider<double>((ref) {
  final cancelled = ref.watch(cancelledSubsProvider);
  final displayCurrency = ref.watch(currencyProvider);
  return cancelled.fold(0.0, (sum, sub) {
    if (sub.cancelledDate == null) return sum;
    final monthsSinceCancelled =
        DateTime.now().difference(sub.cancelledDate!).inDays / 30;
    return sum + (sub.monthlyEquivalentIn(displayCurrency) * monthsSinceCancelled);
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

  /// Toggle a reminder day for a specific subscription.
  ///
  /// Initialises the subscription's reminder list from global defaults
  /// on first use, then toggles the specified day.
  void toggleReminderDay(String uid, int day) {
    final sub = state.firstWhere((s) => s.uid == uid);
    // If reminders list is empty, initialise from global defaults
    if (sub.reminders.isEmpty) {
      for (final d in AppConstants.proReminderDays) {
        sub.reminders.add(ReminderConfig()
          ..daysBefore = d
          ..enabled = d == 0);
      }
    }
    // Toggle the specific day
    final idx = sub.reminders.indexWhere((r) => r.daysBefore == day);
    if (idx >= 0) {
      sub.reminders[idx].enabled = !sub.reminders[idx].enabled;
    } else {
      sub.reminders.add(ReminderConfig()
        ..daysBefore = day
        ..enabled = true);
    }
    update(sub);
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

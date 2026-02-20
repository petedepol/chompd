import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../config/constants.dart';
import '../models/subscription.dart';
import '../services/isar_service.dart';
import '../services/sync_service.dart';
import 'currency_provider.dart';

/// Provider: all subscriptions (active + cancelled).
final subscriptionsProvider =
    StateNotifierProvider<SubscriptionsNotifier, List<Subscription>>((ref) {
  return SubscriptionsNotifier();
});

/// Provider: all cancelled subscriptions (including dismissed ones).
final _allCancelledSubsProvider = Provider<List<Subscription>>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  return subs.where((s) => !s.isActive && s.cancelledDate != null).toList()
    ..sort((a, b) => (b.cancelledDate ?? DateTime.now())
        .compareTo(a.cancelledDate ?? DateTime.now()));
});

/// Provider: visible cancelled subscriptions (excludes dismissed cards).
final cancelledSubsProvider = Provider<List<Subscription>>((ref) {
  return ref
      .watch(_allCancelledSubsProvider)
      .where((s) => !s.cancelledDismissed)
      .toList();
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

/// Provider: total money saved from VISIBLE cancelled subs (excludes dismissed).
///
/// Calculated as: monthlyEquivalentIn(displayCurrency) × months since cancellation,
/// with a minimum of 1 month (the next avoided payment).
/// Uses cancelledSubsProvider (not _allCancelledSubsProvider) so the header
/// total matches the sum of the individual cancelled cards the user can see.
final totalSavedProvider = Provider<double>((ref) {
  final visibleCancelled = ref.watch(cancelledSubsProvider);
  final displayCurrency = ref.watch(currencyProvider);
  debugPrint('[Savings] Counting ${visibleCancelled.length} cancelled subs:');
  return visibleCancelled.fold(0.0, (sum, sub) {
    final cancelDate = sub.cancelledDate ?? sub.createdAt;
    final daysSinceCancelled =
        DateTime.now().difference(cancelDate).inDays;
    // At least 1 month — the next payment you avoided by cancelling.
    final months = (daysSinceCancelled / 30).clamp(1.0, double.infinity);
    final monthlyInCurrency = sub.monthlyEquivalentIn(displayCurrency);
    final contribution = monthlyInCurrency * months;
    debugPrint('[Savings]   ${sub.name}: ${sub.price} ${sub.currency} (monthly=$monthlyInCurrency in $displayCurrency) × $months months = $contribution');
    return sum + contribution;
  });
});

/// State notifier for subscription list management.
///
/// Backed by Isar for local persistence. Loads from Isar on construction.
/// Sync hooks for Supabase are called after each write (Phase 5).
class SubscriptionsNotifier extends StateNotifier<List<Subscription>> {
  SubscriptionsNotifier() : super([]) {
    _loadFromIsar();
  }

  Isar get _isar => IsarService.instance.db;

  /// Load all non-deleted subscriptions from Isar.
  Future<void> _loadFromIsar() async {
    try {
      final subs = await _isar.subscriptions
          .filter()
          .deletedAtIsNull()
          .findAll();

      // Migrate legacy category names → Supabase enum values
      final needsMigration = <Subscription>[];
      for (final sub in subs) {
        final migrated = AppConstants.migrateCategory(sub.category);
        if (migrated != sub.category) {
          sub.category = migrated;
          needsMigration.add(sub);
        }
      }
      if (needsMigration.isNotEmpty) {
        debugPrint(
          '[SubscriptionsNotifier] Migrating ${needsMigration.length} '
          'category names to Supabase enum values',
        );
        await _isar.writeTxn(() async {
          await _isar.subscriptions.putAll(needsMigration);
        });
      }

      state = subs;
    } catch (e) {
      debugPrint('[SubscriptionsNotifier] Isar load failed: $e');
    }
  }

  /// Reload from Isar (e.g. after sync merge).
  Future<void> reload() async => _loadFromIsar();

  Future<void> add(Subscription sub) async {
    // Dedup guard: skip if a sub with the same name was added in the last 30s
    final isDup = state.any((s) =>
        s.name.toLowerCase() == sub.name.toLowerCase() &&
        s.createdAt
            .isAfter(DateTime.now().subtract(const Duration(seconds: 30))));
    if (isDup) {
      debugPrint(
          '[SubscriptionsNotifier] Skipping duplicate add for "${sub.name}"');
      return;
    }

    sub.updatedAt = DateTime.now();
    state = [...state, sub];
    try {
      await _isar.writeTxn(() async {
        await _isar.subscriptions.put(sub);
      });
      SyncService.instance.pushSubscription(sub);
    } catch (e) {
      debugPrint('[SubscriptionsNotifier] Isar add failed: $e');
    }
  }

  Future<void> remove(String uid) async {
    // Hard-delete: remove from Isar and Supabase completely.
    // Cancelled subs (isActive=false) are a separate flow and stay.
    final exists = state.any((s) => s.uid == uid);
    if (!exists) return;
    state = state.where((s) => s.uid != uid).toList();
    try {
      await _isar.writeTxn(() async {
        await _isar.subscriptions
            .filter()
            .uidEqualTo(uid)
            .deleteAll();
      });
      SyncService.instance.pushDelete(uid);
    } catch (e) {
      debugPrint('[SubscriptionsNotifier] Isar remove failed: $e');
    }
  }

  Future<void> update(Subscription updated) async {
    updated.updatedAt = DateTime.now();
    state = [
      for (final s in state)
        if (s.uid == updated.uid) updated else s,
    ];
    try {
      await _isar.writeTxn(() async {
        await _isar.subscriptions.put(updated);
      });
      SyncService.instance.pushSubscription(updated);
    } catch (e) {
      debugPrint('[SubscriptionsNotifier] Isar update failed: $e');
    }
  }

  /// Toggle a reminder day for a specific subscription.
  ///
  /// Initialises the subscription's reminder list from global defaults
  /// on first use, then toggles the specified day.
  Future<void> toggleReminderDay(String uid, int day) async {
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
    await update(sub);
  }

  /// Dismiss a cancelled subscription card from the home screen graveyard.
  /// The sub still counts towards total savings — just hidden from the list.
  Future<void> dismissCancelled(String uid) async {
    final idx = state.indexWhere((s) => s.uid == uid);
    if (idx < 0) return;
    final sub = state[idx]..cancelledDismissed = true;
    await update(sub);
  }

  Future<void> cancel(String uid) async {
    final idx = state.indexWhere((s) => s.uid == uid);
    if (idx < 0) return;
    final sub = state[idx]
      ..isActive = false
      ..cancelledDate = DateTime.now()
      ..updatedAt = DateTime.now();
    state = [
      for (final s in state)
        if (s.uid == uid) sub else s,
    ];
    try {
      await _isar.writeTxn(() async {
        await _isar.subscriptions.put(sub);
      });
      SyncService.instance.pushSubscription(sub);
    } catch (e) {
      debugPrint('[SubscriptionsNotifier] Isar cancel failed: $e');
    }
  }

  /// Reactivate a cancelled subscription.
  Future<void> reactivate(String uid) async {
    final idx = state.indexWhere((s) => s.uid == uid);
    if (idx < 0) return;
    final sub = state[idx]
      ..isActive = true
      ..cancelledDate = null
      ..cancelledDismissed = false
      ..updatedAt = DateTime.now();
    state = [
      for (final s in state)
        if (s.uid == uid) sub else s,
    ];
    try {
      await _isar.writeTxn(() async {
        await _isar.subscriptions.put(sub);
      });
      SyncService.instance.pushSubscription(sub);
    } catch (e) {
      debugPrint('[SubscriptionsNotifier] Isar reactivate failed: $e');
    }
  }

  /// Unfreeze all frozen subscriptions (e.g. when user upgrades to Pro/trial).
  Future<void> unfreezeAll() async {
    final frozen = state.where(
      (s) => !s.isActive && s.cancelledDate == null,
    ).toList();
    if (frozen.isEmpty) return;

    for (final sub in frozen) {
      sub.isActive = true;
      sub.updatedAt = DateTime.now();
    }

    state = [...state]; // trigger rebuild
    try {
      await _isar.writeTxn(() async {
        await _isar.subscriptions.putAll(frozen);
      });
      for (final sub in frozen) {
        SyncService.instance.pushSubscription(sub);
      }
    } catch (e) {
      debugPrint('[SubscriptionsNotifier] Isar unfreezeAll failed: $e');
    }
  }

  /// Freeze excess subscriptions beyond [maxActive] (oldest stay active).
  ///
  /// Only affects non-cancelled subs. Cancelled subs are a separate state.
  Future<void> freezeExcess(int maxActive) async {
    final activeSubs = state
        .where((s) => s.isActive && s.cancelledDate == null)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (activeSubs.length <= maxActive) return;

    final toFreeze = activeSubs.sublist(maxActive);
    for (final sub in toFreeze) {
      sub.isActive = false;
      sub.updatedAt = DateTime.now();
    }

    state = [...state]; // trigger rebuild
    try {
      await _isar.writeTxn(() async {
        await _isar.subscriptions.putAll(toFreeze);
      });
      for (final sub in toFreeze) {
        SyncService.instance.pushSubscription(sub);
      }
    } catch (e) {
      debugPrint('[SubscriptionsNotifier] Isar freezeExcess failed: $e');
    }
  }
}

/// Provider: frozen subscriptions (inactive but NOT cancelled).
final frozenSubsProvider = Provider<List<Subscription>>((ref) {
  return ref
      .watch(subscriptionsProvider)
      .where((s) => !s.isActive && s.cancelledDate == null)
      .toList();
});

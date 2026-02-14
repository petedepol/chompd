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
    // Soft-delete: set deletedAt, keep in Isar for sync
    final idx = state.indexWhere((s) => s.uid == uid);
    if (idx < 0) return;
    final sub = state[idx];
    sub.deletedAt = DateTime.now();
    sub.updatedAt = DateTime.now();
    state = state.where((s) => s.uid != uid).toList();
    try {
      await _isar.writeTxn(() async {
        await _isar.subscriptions.put(sub);
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
}

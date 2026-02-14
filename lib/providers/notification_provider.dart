import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/constants.dart';
import '../services/notification_service.dart';
import 'currency_provider.dart';
import 'subscriptions_provider.dart';

// ─── Notification Preferences ───

/// User's notification preferences.
class NotificationPreferences {
  /// Whether notifications are enabled globally.
  final bool enabled;

  /// Whether morning digest is enabled.
  final bool morningDigestEnabled;

  /// Time for morning digest (default 8:30 AM).
  final TimeOfDay digestTime;

  /// Whether trial expiry alerts are enabled.
  final bool trialAlertsEnabled;

  /// Whether renewal reminders are enabled.
  final bool renewalRemindersEnabled;

  /// Custom reminder days override (null = use default for tier).
  final List<int>? customReminderDays;

  /// Whether the user is on Pro tier.
  final bool isPro;

  const NotificationPreferences({
    this.enabled = true,
    this.morningDigestEnabled = true,
    this.digestTime = const TimeOfDay(hour: 8, minute: 30),
    this.trialAlertsEnabled = true,
    this.renewalRemindersEnabled = true,
    this.customReminderDays,
    this.isPro = false,
  });

  NotificationPreferences copyWith({
    bool? enabled,
    bool? morningDigestEnabled,
    TimeOfDay? digestTime,
    bool? trialAlertsEnabled,
    bool? renewalRemindersEnabled,
    List<int>? customReminderDays,
    bool? isPro,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      morningDigestEnabled:
          morningDigestEnabled ?? this.morningDigestEnabled,
      digestTime: digestTime ?? this.digestTime,
      trialAlertsEnabled: trialAlertsEnabled ?? this.trialAlertsEnabled,
      renewalRemindersEnabled:
          renewalRemindersEnabled ?? this.renewalRemindersEnabled,
      customReminderDays:
          customReminderDays ?? this.customReminderDays,
      isPro: isPro ?? this.isPro,
    );
  }

  /// The active reminder days based on tier.
  List<int> get activeReminderDays {
    if (customReminderDays != null) return customReminderDays!;
    return isPro
        ? AppConstants.proReminderDays
        : AppConstants.freeReminderDays;
  }
}

// ─── Notification Preferences Notifier ───

class NotificationPreferencesNotifier
    extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesNotifier()
      : super(const NotificationPreferences());

  void toggleEnabled(bool value) {
    state = state.copyWith(enabled: value);
    _syncService();
  }

  void toggleMorningDigest(bool value) {
    state = state.copyWith(morningDigestEnabled: value);
  }

  void setDigestTime(TimeOfDay time) {
    state = state.copyWith(digestTime: time);
  }

  void toggleTrialAlerts(bool value) {
    state = state.copyWith(trialAlertsEnabled: value);
  }

  void toggleRenewalReminders(bool value) {
    state = state.copyWith(renewalRemindersEnabled: value);
  }

  /// Toggle a specific reminder day on/off.
  /// Copies the current activeReminderDays, adds/removes [day],
  /// then stores as customReminderDays.
  void toggleReminderDay(int day) {
    final current = List<int>.from(state.activeReminderDays);
    if (current.contains(day)) {
      current.remove(day);
    } else {
      current.add(day);
      current.sort((a, b) => b.compareTo(a)); // descending: 7, 3, 1, 0
    }
    state = state.copyWith(
      customReminderDays: current,
      renewalRemindersEnabled: current.isNotEmpty,
    );
  }

  void setProStatus(bool isPro) {
    state = state.copyWith(isPro: isPro);
    NotificationService.instance.setProStatus(isPro);
  }

  void _syncService() {
    if (!state.enabled) {
      NotificationService.instance.cancelAll();
    }
  }
}

// ─── Providers ───

/// Notification preferences provider.
final notificationPrefsProvider = StateNotifierProvider<
    NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  return NotificationPreferencesNotifier();
});

/// Scheduled notifications count.
final pendingNotificationsProvider = Provider<int>((ref) {
  // Trigger re-evaluation when subscriptions change
  ref.watch(subscriptionsProvider);
  return NotificationService.instance.pendingCount;
});

/// Upcoming notifications (next 7 days).
final upcomingNotificationsProvider =
    Provider<List<ScheduledNotification>>((ref) {
  ref.watch(subscriptionsProvider);
  return NotificationService.instance.getUpcoming(days: 7);
});

/// Provider that manages scheduling reminders for all active subscriptions.
///
/// This watches the subscription list and reschedules when it changes.
final notificationSchedulerProvider = Provider<void>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  final prefs = ref.watch(notificationPrefsProvider);
  final displayCurrency = ref.watch(currencyProvider);

  if (!prefs.enabled) return;

  final service = NotificationService.instance;

  // Schedule reminders for all active subscriptions
  for (final sub in subs.where((s) => s.isActive)) {
    if (prefs.renewalRemindersEnabled) {
      service.scheduleReminders(sub);
    }
  }

  // Schedule morning digest
  if (prefs.morningDigestEnabled) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayRenewals = subs.where((s) {
      final renewal = DateTime(
        s.nextRenewal.year,
        s.nextRenewal.month,
        s.nextRenewal.day,
      );
      return s.isActive && renewal == today;
    }).toList();

    final expiringTrials = subs.where((s) {
      if (!s.isTrial || s.trialEndDate == null) return false;
      final trialEnd = DateTime(
        s.trialEndDate!.year,
        s.trialEndDate!.month,
        s.trialEndDate!.day,
      );
      return s.isActive && trialEnd == today;
    }).toList();

    service.scheduleMorningDigest(
      todayRenewals: todayRenewals,
      expiringTrials: expiringTrials,
      displayCurrency: displayCurrency,
    );
  }
});

/// Summary data for the notification settings screen.
class NotificationSummary {
  final int totalScheduled;
  final int renewalReminders;
  final int trialAlerts;
  final bool hasDigest;
  final List<int> activeReminderDays;
  final bool isPro;

  const NotificationSummary({
    required this.totalScheduled,
    required this.renewalReminders,
    required this.trialAlerts,
    required this.hasDigest,
    required this.activeReminderDays,
    required this.isPro,
  });
}

final notificationSummaryProvider = Provider<NotificationSummary>((ref) {
  final prefs = ref.watch(notificationPrefsProvider);
  final scheduled = NotificationService.instance.scheduled;

  return NotificationSummary(
    totalScheduled: scheduled.length,
    renewalReminders: scheduled
        .where(
            (n) => n.channelId == NotificationChannels.renewalReminder)
        .length,
    trialAlerts: scheduled
        .where((n) => n.channelId == NotificationChannels.trialExpiry)
        .length,
    hasDigest: scheduled
        .any((n) => n.channelId == NotificationChannels.morningDigest),
    activeReminderDays: prefs.activeReminderDays,
    isPro: prefs.isPro,
  );
});

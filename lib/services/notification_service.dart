import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../models/subscription.dart';

/// Notification channel identifiers.
class NotificationChannels {
  NotificationChannels._();

  static const String renewalReminder = 'renewal_reminder';
  static const String trialExpiry = 'trial_expiry';
  static const String morningDigest = 'morning_digest';
}

/// Notification priority.
enum NotificationPriority {
  low,
  normal,
  high,
}

/// A scheduled notification record.
class ScheduledNotification {
  final int id;
  final String channelId;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final NotificationPriority priority;
  final String? subscriptionUid;

  const ScheduledNotification({
    required this.id,
    required this.channelId,
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.priority = NotificationPriority.normal,
    this.subscriptionUid,
  });

  @override
  String toString() =>
      'ScheduledNotification($id: "$title" at $scheduledAt)';
}

/// Notification service for scheduling renewal reminders and trial alerts.
///
/// For v1 prototype, this manages the scheduling logic and stores
/// pending notifications in memory. In production, this will use
/// flutter_local_notifications for actual OS-level notifications.
///
/// Reminder tiers:
/// - **Free:** Morning-of renewal only (day 0)
/// - **Pro:** 7 days, 3 days, 1 day, morning-of
///
/// Trial alerts always fire at 3 days and 1 day before expiry.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  /// Whether the notification service has been initialised.
  bool _initialised = false;

  /// In-memory store of scheduled notifications (production: OS scheduler).
  final List<ScheduledNotification> _scheduled = [];

  /// Notification ID counter.
  int _nextId = 1000;

  /// Whether the user has granted notification permissions.
  bool _permissionGranted = false;

  /// Whether the user is a Pro subscriber.
  bool _isPro = false;

  // ─── Initialisation ───

  /// Initialise the notification service.
  ///
  /// In production, this would:
  /// 1. Request notification permissions
  /// 2. Create notification channels (Android)
  /// 3. Restore scheduled notifications
  Future<void> init() async {
    if (_initialised) return;

    // For prototype, auto-grant permissions
    _permissionGranted = true;
    _initialised = true;

    debugPrint('[NotificationService] Initialised');
  }

  /// Update Pro status (affects which reminder tiers are available).
  void setProStatus(bool isPro) {
    _isPro = isPro;
    debugPrint('[NotificationService] Pro status: $_isPro');
  }

  // ─── Permission ───

  /// Request notification permission from the user.
  ///
  /// Returns true if permission was granted.
  Future<bool> requestPermission() async {
    // In production: platform-specific permission request
    _permissionGranted = true;
    return true;
  }

  bool get hasPermission => _permissionGranted;

  // ─── Scheduling ───

  /// Schedule all reminders for a subscription.
  ///
  /// Clears any existing reminders for this subscription first,
  /// then schedules based on the user's tier (free/pro).
  Future<void> scheduleReminders(Subscription sub) async {
    if (!_initialised || !_permissionGranted) return;
    if (!sub.isActive) return;

    // Clear existing reminders for this subscription
    cancelReminders(sub.uid);

    // Determine which reminder days are available
    final reminderDays =
        _isPro ? AppConstants.proReminderDays : AppConstants.freeReminderDays;

    // Schedule renewal reminders
    for (final daysBefore in reminderDays) {
      final reminderDate = sub.nextRenewal.subtract(
        Duration(days: daysBefore),
      );

      // Only schedule future notifications
      if (reminderDate.isAfter(DateTime.now())) {
        // Schedule at 9:00 AM
        final scheduledAt = DateTime(
          reminderDate.year,
          reminderDate.month,
          reminderDate.day,
          9, // 9 AM
          0,
        );

        // Skip if the scheduled time has already passed
        if (scheduledAt.isBefore(DateTime.now())) continue;

        final notification = ScheduledNotification(
          id: _nextId++,
          channelId: NotificationChannels.renewalReminder,
          title: _renewalTitle(sub, daysBefore),
          body: _renewalBody(sub, daysBefore),
          scheduledAt: scheduledAt,
          priority: daysBefore <= 1
              ? NotificationPriority.high
              : NotificationPriority.normal,
          subscriptionUid: sub.uid,
        );

        _scheduled.add(notification);
        debugPrint('[NotificationService] Scheduled: $notification');
      }
    }

    // Schedule trial expiry alerts (always available, even on free)
    if (sub.isTrial && sub.trialEndDate != null) {
      _scheduleTrialAlerts(sub);
    }
  }

  /// Schedule trial expiry alerts at 3 days, 1 day, and day-of.
  void _scheduleTrialAlerts(Subscription sub) {
    final trialEnd = sub.trialEndDate!;
    final alertDays = [3, 1, 0];

    for (final daysBefore in alertDays) {
      final alertDate = trialEnd.subtract(Duration(days: daysBefore));

      if (alertDate.isAfter(DateTime.now())) {
        final scheduledAt = DateTime(
          alertDate.year,
          alertDate.month,
          alertDate.day,
          9,
          0,
        );

        // Skip if the scheduled time has already passed
        if (scheduledAt.isBefore(DateTime.now())) continue;

        final notification = ScheduledNotification(
          id: _nextId++,
          channelId: NotificationChannels.trialExpiry,
          title: _trialTitle(sub, daysBefore),
          body: _trialBody(sub, daysBefore),
          scheduledAt: scheduledAt,
          priority: NotificationPriority.high,
          subscriptionUid: sub.uid,
        );

        _scheduled.add(notification);
        debugPrint('[NotificationService] Trial alert: $notification');
      }
    }
  }

  /// Schedule aggressive alerts for a tracked trap trial.
  ///
  /// Fires at 72h, 24h, and 2h before trial expiry, plus a
  /// post-conversion check-in 2h after expiry.
  void scheduleAggressiveTrialAlerts({
    required String subscriptionUid,
    required String serviceName,
    required double realPrice,
    required String currency,
    required DateTime trialExpiresAt,
  }) {
    final priceStr = Subscription.formatPrice(realPrice, currency);

    // 72 hours before
    final alert72h = trialExpiresAt.subtract(const Duration(hours: 72));
    if (alert72h.isAfter(DateTime.now())) {
      final notification = ScheduledNotification(
        id: _nextId++,
        channelId: NotificationChannels.trialExpiry,
        title: '$serviceName trial ends in 3 days',
        body: 'It\'ll auto-charge $priceStr. Cancel now if you don\'t want it.',
        scheduledAt: alert72h,
        priority: NotificationPriority.normal,
        subscriptionUid: subscriptionUid,
      );
      _scheduled.add(notification);
      debugPrint('[NotificationService] Trap alert 72h: $notification');
    }

    // 24 hours before
    final alert24h = trialExpiresAt.subtract(const Duration(hours: 24));
    if (alert24h.isAfter(DateTime.now())) {
      final notification = ScheduledNotification(
        id: _nextId++,
        channelId: NotificationChannels.trialExpiry,
        title: '\u26A0\uFE0F TOMORROW: $serviceName will charge $priceStr',
        body: 'Cancel now if you don\'t want to keep it.',
        scheduledAt: alert24h,
        priority: NotificationPriority.high,
        subscriptionUid: subscriptionUid,
      );
      _scheduled.add(notification);
      debugPrint('[NotificationService] Trap alert 24h: $notification');
    }

    // 2 hours before — URGENT
    final alert2h = trialExpiresAt.subtract(const Duration(hours: 2));
    if (alert2h.isAfter(DateTime.now())) {
      final notification = ScheduledNotification(
        id: _nextId++,
        channelId: NotificationChannels.trialExpiry,
        title: '\uD83D\uDEA8 $serviceName charges $priceStr in 2 HOURS',
        body: 'This is your last chance to cancel.',
        scheduledAt: alert2h,
        priority: NotificationPriority.high,
        subscriptionUid: subscriptionUid,
      );
      _scheduled.add(notification);
      debugPrint('[NotificationService] Trap alert 2h: $notification');
    }

    // Post-conversion check-in (2h after expiry)
    final afterConvert = trialExpiresAt.add(const Duration(hours: 2));
    final afterNotif = ScheduledNotification(
      id: _nextId++,
      channelId: NotificationChannels.trialExpiry,
      title: 'Did you mean to keep $serviceName?',
      body: 'You were charged $priceStr. Tap if you need help getting a refund.',
      scheduledAt: afterConvert,
      priority: NotificationPriority.normal,
      subscriptionUid: subscriptionUid,
    );
    _scheduled.add(afterNotif);
    debugPrint('[NotificationService] Trap post-conversion: $afterNotif');
  }

  /// Schedule a morning digest notification.
  ///
  /// Fires daily at 8:30 AM if any renewals are due today.
  /// [displayCurrency] is used to convert mixed-currency totals.
  Future<void> scheduleMorningDigest({
    required List<Subscription> todayRenewals,
    required List<Subscription> expiringTrials,
    String displayCurrency = 'GBP',
  }) async {
    if (!_initialised || !_permissionGranted) return;

    // Cancel any existing digest
    _scheduled.removeWhere(
      (n) => n.channelId == NotificationChannels.morningDigest,
    );

    if (todayRenewals.isEmpty && expiringTrials.isEmpty) return;

    final now = DateTime.now();
    var scheduledAt = DateTime(now.year, now.month, now.day, 8, 30);

    // If it's already past 8:30 today, schedule for tomorrow
    if (scheduledAt.isBefore(now)) {
      scheduledAt = scheduledAt.add(const Duration(days: 1));
    }

    String title;
    String body;

    if (todayRenewals.isNotEmpty && expiringTrials.isNotEmpty) {
      title = '${todayRenewals.length} renewal(s) + ${expiringTrials.length} trial(s) today';
      body = _digestBody(todayRenewals, expiringTrials, displayCurrency);
    } else if (todayRenewals.isNotEmpty) {
      final total = todayRenewals.fold(0.0, (sum, s) => sum + s.priceIn(displayCurrency));
      title = '${todayRenewals.length} subscription(s) renewing today';
      body =
          '${todayRenewals.map((s) => s.name).join(", ")} \u2014 ${Subscription.formatPrice(total, displayCurrency)} total';
    } else {
      title = '${expiringTrials.length} trial(s) expiring today';
      body =
          '${expiringTrials.map((s) => s.name).join(", ")} \u2014 cancel now to avoid charges';
    }

    final notification = ScheduledNotification(
      id: _nextId++,
      channelId: NotificationChannels.morningDigest,
      title: title,
      body: body,
      scheduledAt: scheduledAt,
      priority: NotificationPriority.high,
    );

    _scheduled.add(notification);
    debugPrint('[NotificationService] Morning digest: $notification');
  }

  /// Cancel all reminders for a specific subscription.
  void cancelReminders(String subscriptionUid) {
    final removed = _scheduled
        .where((n) => n.subscriptionUid == subscriptionUid)
        .toList();

    _scheduled.removeWhere((n) => n.subscriptionUid == subscriptionUid);

    if (removed.isNotEmpty) {
      debugPrint(
        '[NotificationService] Cancelled ${removed.length} reminders for $subscriptionUid',
      );
    }
  }

  /// Cancel all scheduled notifications.
  void cancelAll() {
    _scheduled.clear();
    debugPrint('[NotificationService] All notifications cancelled');
  }

  // ─── Queries ───

  /// Get all scheduled notifications.
  List<ScheduledNotification> get scheduled =>
      List.unmodifiable(_scheduled);

  /// Get scheduled notifications for a specific subscription.
  List<ScheduledNotification> getForSubscription(String uid) {
    return _scheduled.where((n) => n.subscriptionUid == uid).toList();
  }

  /// Get all notifications due in the next N days.
  List<ScheduledNotification> getUpcoming({int days = 7}) {
    final cutoff = DateTime.now().add(Duration(days: days));
    return _scheduled
        .where((n) => n.scheduledAt.isBefore(cutoff))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// Count of pending notifications.
  int get pendingCount => _scheduled.length;

  // ─── Message Templates ───

  String _renewalTitle(Subscription sub, int daysBefore) {
    if (daysBefore == 0) {
      return '${sub.name} renews today';
    } else if (daysBefore == 1) {
      return '${sub.name} renews tomorrow';
    } else {
      return '${sub.name} renews in $daysBefore days';
    }
  }

  String _renewalBody(Subscription sub, int daysBefore) {
    final price = '${Subscription.formatPrice(sub.price, sub.currency)}/${sub.cycle.shortLabel}';

    if (daysBefore == 0) {
      return 'You\'ll be charged $price today. Tap to review or cancel.';
    } else if (daysBefore == 1) {
      return '$price will be charged tomorrow. Still want to keep it?';
    } else if (daysBefore == 3) {
      return '$price renewal coming up in 3 days.';
    } else {
      return '$price renewal in $daysBefore days. Time to review?';
    }
  }

  String _trialTitle(Subscription sub, int daysBefore) {
    if (daysBefore == 0) {
      return '\u26A0 ${sub.name} trial ends today!';
    } else if (daysBefore == 1) {
      return '${sub.name} trial ends tomorrow';
    } else {
      return '${sub.name} trial ends in $daysBefore days';
    }
  }

  String _trialBody(Subscription sub, int daysBefore) {
    final price = '${Subscription.formatPrice(sub.price, sub.currency)}/${sub.cycle.shortLabel}';

    if (daysBefore == 0) {
      return 'Your free trial ends today! You\'ll be charged $price. Cancel now if you don\'t want to continue.';
    } else if (daysBefore == 1) {
      return 'One day left on your trial. After that it\'s $price. Cancel now to avoid charges.';
    } else {
      return '$daysBefore days left on your free trial. Full price is $price after that.';
    }
  }

  String _digestBody(
    List<Subscription> renewals,
    List<Subscription> trials,
    String displayCurrency,
  ) {
    final parts = <String>[];

    if (renewals.isNotEmpty) {
      final total = renewals.fold(0.0, (sum, s) => sum + s.priceIn(displayCurrency));
      parts.add(
        'Renewals: ${renewals.map((s) => s.name).join(", ")} (${Subscription.formatPrice(total, displayCurrency)})',
      );
    }

    if (trials.isNotEmpty) {
      parts.add(
        'Trials ending: ${trials.map((s) => s.name).join(", ")} \u2014 cancel to avoid charges',
      );
    }

    return parts.join('\n');
  }
}

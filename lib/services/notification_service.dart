import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../l10n/generated/app_localizations.dart';
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

  /// The flutter_local_notifications plugin instance.
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Whether the notification service has been initialised.
  bool _initialised = false;

  /// In-memory store of scheduled notifications (production: OS scheduler).
  final List<ScheduledNotification> _scheduled = [];

  /// Notification ID counter.
  int _nextId = 1000;

  /// Cached l10n instance — refreshed on each scheduling call.
  S? _l10n;

  /// Whether the user has granted notification permissions.
  bool _permissionGranted = false;

  /// Whether the user is a Pro subscriber.
  bool _isPro = false;

  // ─── Initialisation ───

  /// Initialise the notification service.
  ///
  /// Sets up flutter_local_notifications with platform-specific config.
  Future<void> init() async {
    if (_initialised) return;

    // iOS settings — don't request permissions at init, do it later
    // via requestPermission() so we control when the dialog shows.
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(
      iOS: iosSettings,
      android: androidSettings,
    );

    await _plugin.initialize(settings: initSettings);

    _initialised = true;
    debugPrint('[NotificationService] Initialised');
  }

  /// Update Pro status (affects which reminder tiers are available).
  void setProStatus(bool isPro) {
    _isPro = isPro;
    debugPrint('[NotificationService] Pro status: $_isPro');
  }

  /// Get the localised strings instance based on stored locale.
  Future<S> _getL10n() async {
    if (_l10n != null) return _l10n!;
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('user_locale') ?? 'en';
    _l10n = lookupS(Locale(langCode));
    return _l10n!;
  }

  /// Refresh cached l10n (call when locale changes).
  void refreshLocale() {
    _l10n = null;
  }

  // ─── Permission ───

  /// Request notification permission from the user.
  ///
  /// Shows the OS permission dialog on iOS. On Android 13+, requests
  /// the POST_NOTIFICATIONS permission.
  ///
  /// Returns true if permission was granted.
  Future<bool> requestPermission() async {
    bool granted = false;

    if (Platform.isIOS) {
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        granted = await iosPlugin.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } else if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        granted =
            await androidPlugin.requestNotificationsPermission() ?? false;
      }
    }

    _permissionGranted = granted;
    debugPrint(
      '[NotificationService] Permission ${granted ? "granted" : "denied"}',
    );
    return granted;
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

    final l = await _getL10n();

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
          title: _renewalTitle(sub, daysBefore, l),
          body: _renewalBody(sub, daysBefore, l),
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
      await _scheduleTrialAlerts(sub, l);
    }
  }

  /// Schedule trial expiry alerts at 3 days, 1 day, and day-of.
  Future<void> _scheduleTrialAlerts(Subscription sub, S l) async {
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
          title: _trialTitle(sub, daysBefore, l),
          body: _trialBody(sub, daysBefore, l),
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
  Future<void> scheduleAggressiveTrialAlerts({
    required String subscriptionUid,
    required String serviceName,
    required double realPrice,
    required String currency,
    required DateTime trialExpiresAt,
  }) async {
    final l = await _getL10n();
    final priceStr = Subscription.formatPrice(realPrice, currency);

    // 72 hours before
    final alert72h = trialExpiresAt.subtract(const Duration(hours: 72));
    if (alert72h.isAfter(DateTime.now())) {
      final notification = ScheduledNotification(
        id: _nextId++,
        channelId: NotificationChannels.trialExpiry,
        title: l.notifTrapTrialTitle3d(serviceName),
        body: l.notifTrapTrialBody3d(priceStr),
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
        title: l.notifTrapTrialTitleTomorrow(serviceName, priceStr),
        body: l.notifTrapTrialBodyTomorrow,
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
        title: l.notifTrapTrialTitle2h(serviceName, priceStr),
        body: l.notifTrapTrialBody2h,
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
      title: l.notifTrapPostCharge(serviceName),
      body: l.notifTrapPostChargeBody(priceStr),
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

    final l = await _getL10n();
    final now = DateTime.now();
    var scheduledAt = DateTime(now.year, now.month, now.day, 8, 30);

    // If it's already past 8:30 today, schedule for tomorrow
    if (scheduledAt.isBefore(now)) {
      scheduledAt = scheduledAt.add(const Duration(days: 1));
    }

    String title;
    String body;

    if (todayRenewals.isNotEmpty && expiringTrials.isNotEmpty) {
      title = l.notifDigestBoth(todayRenewals.length, expiringTrials.length);
      body = _digestBody(todayRenewals, expiringTrials, displayCurrency, l);
    } else if (todayRenewals.isNotEmpty) {
      final total = todayRenewals.fold(0.0, (sum, s) => sum + s.priceIn(displayCurrency));
      title = l.notifDigestRenewals(todayRenewals.length);
      body = l.notifDigestRenewalBody(
        todayRenewals.map((s) => s.name).join(', '),
        Subscription.formatPrice(total, displayCurrency),
      );
    } else {
      title = l.notifDigestTrials(expiringTrials.length);
      body = l.notifDigestTrialBody(
        expiringTrials.map((s) => s.name).join(', '),
      );
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

  String _renewalTitle(Subscription sub, int daysBefore, S l) {
    if (daysBefore == 0) {
      return l.notifRenewsToday(sub.name);
    } else if (daysBefore == 1) {
      return l.notifRenewsTomorrow(sub.name);
    } else {
      return l.notifRenewsInDays(sub.name, daysBefore);
    }
  }

  String _renewalBody(Subscription sub, int daysBefore, S l) {
    final price = '${Subscription.formatPrice(sub.price, sub.currency)}/${sub.cycle.shortLabel}';

    if (daysBefore == 0) {
      return l.notifChargesToday(price);
    } else if (daysBefore == 1) {
      return l.notifChargesTomorrow(price);
    } else if (daysBefore == 3) {
      return l.notifCharges3Days(price);
    } else {
      return l.notifChargesInDays(price, daysBefore);
    }
  }

  String _trialTitle(Subscription sub, int daysBefore, S l) {
    if (daysBefore == 0) {
      return l.notifTrialEndsToday(sub.name);
    } else if (daysBefore == 1) {
      return l.notifTrialEndsTomorrow(sub.name);
    } else {
      return l.notifTrialEndsInDays(sub.name, daysBefore);
    }
  }

  String _trialBody(Subscription sub, int daysBefore, S l) {
    final price = '${Subscription.formatPrice(sub.price, sub.currency)}/${sub.cycle.shortLabel}';

    if (daysBefore == 0) {
      return l.notifTrialBodyToday(price);
    } else if (daysBefore == 1) {
      return l.notifTrialBodyTomorrow(price);
    } else {
      return l.notifTrialBodyDays(daysBefore, price);
    }
  }

  String _digestBody(
    List<Subscription> renewals,
    List<Subscription> trials,
    String displayCurrency,
    S l,
  ) {
    final parts = <String>[];

    if (renewals.isNotEmpty) {
      final total = renewals.fold(0.0, (sum, s) => sum + s.priceIn(displayCurrency));
      parts.add(l.notifDigestRenewalBody(
        renewals.map((s) => s.name).join(', '),
        Subscription.formatPrice(total, displayCurrency),
      ));
    }

    if (trials.isNotEmpty) {
      parts.add(l.notifDigestTrialBody(
        trials.map((s) => s.name).join(', '),
      ));
    }

    return parts.join('\n');
  }
}

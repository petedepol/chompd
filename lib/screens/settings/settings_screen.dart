import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/subscription.dart';
import '../../providers/budget_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/subscriptions_provider.dart';
import '../../services/haptic_service.dart';
import '../../services/notification_service.dart';
import '../../utils/csv_export.dart';
import '../paywall/paywall_screen.dart';

/// Settings screen with notification preferences.
///
/// Lets users configure:
/// - Global notification toggle
/// - Morning digest on/off + time picker
/// - Renewal reminders on/off
/// - Trial expiry alerts on/off
/// - Reminder schedule preview (free vs Pro)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final summary = ref.watch(notificationSummaryProvider);
    final prefsNotifier = ref.read(notificationPrefsProvider.notifier);

    return Scaffold(
      backgroundColor: ChompdColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
                height: MediaQuery.of(context).padding.top + 8),
          ),

          // ─── Top Bar ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: ChompdColors.bgElevated,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: ChompdColors.border),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 14,
                        color: ChompdColors.textMid,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ChompdColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ─── Notifications Section ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  Row(
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        size: 16,
                        color: ChompdColors.mint,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NOTIFICATIONS',
                        style: ChompdTypography.sectionLabel.copyWith(
                          color: ChompdColors.mint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${summary.totalScheduled} reminders scheduled',
                    style: const TextStyle(
                      fontSize: 11,
                      color: ChompdColors.textDim,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Global toggle
                  _SettingsToggle(
                    icon: Icons.notifications_active_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Get reminded about renewals and trials',
                    value: prefs.enabled,
                    onChanged: prefsNotifier.toggleEnabled,
                  ),

                  const SizedBox(height: 10),

                  // Sections below only show if notifications enabled
                  AnimatedOpacity(
                    opacity: prefs.enabled ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: !prefs.enabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Morning digest
                          _SettingsToggle(
                            icon: Icons.wb_sunny_outlined,
                            title: 'Morning Digest',
                            subtitle: 'Daily summary at ${_formatTime(prefs.digestTime)}',
                            value: prefs.morningDigestEnabled,
                            onChanged:
                                prefsNotifier.toggleMorningDigest,
                            trailing: GestureDetector(
                              onTap: () => _pickDigestTime(
                                  context, ref, prefs.digestTime),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      ChompdColors.bgElevated,
                                  borderRadius:
                                      BorderRadius.circular(6),
                                  border: Border.all(
                                      color:
                                          ChompdColors.border),
                                ),
                                child: Text(
                                  _formatTime(prefs.digestTime),
                                  style: ChompdTypography.mono(
                                    size: 11,
                                    weight: FontWeight.w700,
                                    color: ChompdColors.textMid,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Renewal reminders
                          _SettingsToggle(
                            icon: Icons.event_repeat_outlined,
                            title: 'Renewal Reminders',
                            subtitle: _reminderSubtitle(prefs),
                            value: prefs.renewalRemindersEnabled,
                            onChanged:
                                prefsNotifier.toggleRenewalReminders,
                          ),

                          const SizedBox(height: 10),

                          // Trial alerts
                          _SettingsToggle(
                            icon: Icons.timer_outlined,
                            title: 'Trial Expiry Alerts',
                            subtitle:
                                'Warns at 3 days, 1 day, and day-of',
                            value: prefs.trialAlertsEnabled,
                            onChanged:
                                prefsNotifier.toggleTrialAlerts,
                            accentColor: ChompdColors.amber,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ─── Reminder Schedule Preview ───
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 16,
                        color: ChompdColors.purple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'REMINDER SCHEDULE',
                        style: ChompdTypography.sectionLabel.copyWith(
                          color: ChompdColors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _ReminderScheduleCard(
                    isPro: prefs.isPro,
                    activeReminderDays: prefs.activeReminderDays,
                  ),

                  const SizedBox(height: 28),

                  // ─── Upcoming Notifications ───
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: ChompdColors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'UPCOMING',
                        style: ChompdTypography.sectionLabel.copyWith(
                          color: ChompdColors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _UpcomingNotificationsCard(ref: ref),

                  const SizedBox(height: 28),

                  // ─── Chompd Pro ───
                  if (!prefs.isPro) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: ChompdColors.mint,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'CHOMPD PRO',
                          style: ChompdTypography.sectionLabel.copyWith(
                            color: ChompdColors.mint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () => showPaywall(
                        context,
                        trigger: PaywallTrigger.settingsUpgrade,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              ChompdColors.mint.withValues(alpha: 0.08),
                              ChompdColors.bgCard,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: ChompdColors.mint.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  colors: [
                                    ChompdColors.mintDark,
                                    ChompdColors.mint,
                                  ],
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.auto_awesome,
                                size: 20,
                                color: ChompdColors.bg,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Unlock Chompd Pro',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: ChompdColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${Subscription.formatPrice(AppConstants.proPrice, 'GBP')} \u2022 One-time payment',
                                    style: ChompdTypography.mono(
                                      size: 11,
                                      color: ChompdColors.textDim,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: ChompdColors.mint,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],

                  // ─── Currency ───
                  Row(
                    children: [
                      const Icon(
                        Icons.currency_exchange_outlined,
                        size: 16,
                        color: ChompdColors.mint,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CURRENCY',
                        style: ChompdTypography.sectionLabel.copyWith(
                          color: ChompdColors.mint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _CurrencySetting(ref: ref),

                  const SizedBox(height: 28),

                  // ─── Monthly Budget ───
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 16,
                        color: ChompdColors.mint,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MONTHLY BUDGET',
                        style: ChompdTypography.sectionLabel.copyWith(
                          color: ChompdColors.mint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _BudgetSetting(ref: ref),

                  const SizedBox(height: 28),

                  // ─── Haptics ───
                  Row(
                    children: [
                      const Icon(
                        Icons.vibration_outlined,
                        size: 16,
                        color: ChompdColors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HAPTIC FEEDBACK',
                        style: ChompdTypography.sectionLabel.copyWith(
                          color: ChompdColors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _SettingsToggle(
                    icon: Icons.vibration_outlined,
                    title: 'Haptic Feedback',
                    subtitle: 'Vibrations on taps, toggles, and celebrations',
                    value: HapticService.instance.enabled,
                    onChanged: (val) {
                      HapticService.instance.setEnabled(val);
                      if (val) HapticService.instance.selection();
                      // Force rebuild
                      (context as Element).markNeedsBuild();
                    },
                    accentColor: ChompdColors.blue,
                  ),

                  const SizedBox(height: 28),

                  // ─── Data Export ───
                  Row(
                    children: [
                      const Icon(
                        Icons.download_outlined,
                        size: 16,
                        color: ChompdColors.purple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'DATA EXPORT',
                        style: ChompdTypography.sectionLabel.copyWith(
                          color: ChompdColors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _ExportButton(ref: ref),

                  const SizedBox(height: 28),

                  // ─── App Info ───
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: ChompdColors.textDim,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ABOUT',
                        style: ChompdTypography.sectionLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _InfoRow(
                    label: 'Version',
                    value: '1.0.0 (Sprint 10)',
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    label: 'Tier',
                    value: prefs.isPro ? 'Pro' : 'Free',
                    valueColor: prefs.isPro
                        ? ChompdColors.mint
                        : ChompdColors.textDim,
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    label: 'AI Model',
                    value: 'Claude Haiku 4.5',
                  ),

                  SizedBox(
                    height:
                        MediaQuery.of(context).padding.bottom + 40,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _reminderSubtitle(NotificationPreferences prefs) {
    final days = prefs.activeReminderDays;
    if (days.length == 1 && days.first == 0) {
      return 'Morning-of only (upgrade for more)';
    }
    final labels = days.map((d) {
      if (d == 0) return 'day-of';
      if (d == 1) return '1 day';
      return '$d days';
    }).toList();
    return labels.join(', ') + ' before renewal';
  }

  Future<void> _pickDigestTime(
    BuildContext context,
    WidgetRef ref,
    TimeOfDay currentTime,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (ctx, child) => Theme(
        data: ChompdTheme.dark.copyWith(
          colorScheme: const ColorScheme.dark(
            primary: ChompdColors.mint,
            surface: ChompdColors.bgElevated,
            onSurface: ChompdColors.text,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(notificationPrefsProvider.notifier).setDigestTime(picked);
    }
  }
}

// ──────────────────────────────────────────────
// Setting Widgets
// ──────────────────────────────────────────────

/// Toggle row for settings.
class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? trailing;
  final Color? accentColor;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.trailing,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? ChompdColors.mint;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ChompdColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value
              ? accent.withValues(alpha: 0.2)
              : ChompdColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: value ? accent : ChompdColors.textDim,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: value
                        ? ChompdColors.text
                        : ChompdColors.textMid,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: ChompdColors.textDim,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: _ToggleSwitch(value: value, color: accent),
          ),
        ],
      ),
    );
  }
}

/// Custom toggle switch matching the design.
class _ToggleSwitch extends StatelessWidget {
  final bool value;
  final Color color;
  const _ToggleSwitch({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 22,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: value ? color : ChompdColors.bgElevated,
        borderRadius: BorderRadius.circular(11),
        border: value
            ? null
            : Border.all(color: ChompdColors.border),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        alignment:
            value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: value ? Colors.white : ChompdColors.textDim,
            borderRadius: BorderRadius.circular(9),
          ),
        ),
      ),
    );
  }
}

/// Reminder schedule card showing free vs pro tiers.
class _ReminderScheduleCard extends StatelessWidget {
  final bool isPro;
  final List<int> activeReminderDays;

  const _ReminderScheduleCard({
    required this.isPro,
    required this.activeReminderDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ChompdColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ChompdColors.border),
      ),
      child: Column(
        children: [
          // Timeline visualization
          Row(
            children: [
              _TimelineDot(
                day: 7,
                label: '7d',
                isActive: activeReminderDays.contains(7),
                isPro: true,
              ),
              _TimelineConnector(
                isActive: activeReminderDays.contains(7),
              ),
              _TimelineDot(
                day: 3,
                label: '3d',
                isActive: activeReminderDays.contains(3),
                isPro: true,
              ),
              _TimelineConnector(
                isActive: activeReminderDays.contains(3),
              ),
              _TimelineDot(
                day: 1,
                label: '1d',
                isActive: activeReminderDays.contains(1),
                isPro: true,
              ),
              _TimelineConnector(
                isActive: activeReminderDays.contains(1),
              ),
              _TimelineDot(
                day: 0,
                label: 'Day of',
                isActive: activeReminderDays.contains(0),
                isPro: false,
              ),
            ],
          ),

          if (!isPro) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => showPaywall(
                context,
                trigger: PaywallTrigger.settingsUpgrade,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: ChompdColors.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ChompdColors.purple.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: ChompdColors.purple,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Upgrade to Pro for 7d, 3d, and 1d reminders',
                        style: TextStyle(
                          fontSize: 11,
                          color: ChompdColors.purple,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: ChompdColors.purple,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Timeline dot for the reminder schedule.
class _TimelineDot extends StatelessWidget {
  final int day;
  final String label;
  final bool isActive;
  final bool isPro;

  const _TimelineDot({
    required this.day,
    required this.label,
    required this.isActive,
    required this.isPro,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive
                ? ChompdColors.mint.withValues(alpha: 0.15)
                : ChompdColors.bgElevated,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? ChompdColors.mint
                  : ChompdColors.border,
              width: isActive ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: isActive
              ? const Icon(
                  Icons.notifications_active_rounded,
                  size: 12,
                  color: ChompdColors.mint,
                )
              : Icon(
                  isPro ? Icons.lock_outline_rounded : Icons.check_rounded,
                  size: 10,
                  color: ChompdColors.textDim,
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: isActive
                ? ChompdColors.mint
                : ChompdColors.textDim,
          ),
        ),
      ],
    );
  }
}

/// Connector line between timeline dots.
class _TimelineConnector extends StatelessWidget {
  final bool isActive;
  const _TimelineConnector({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: isActive
              ? ChompdColors.mint.withValues(alpha: 0.3)
              : ChompdColors.border,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

/// Upcoming notifications list.
class _UpcomingNotificationsCard extends StatelessWidget {
  final WidgetRef ref;
  const _UpcomingNotificationsCard({required this.ref});

  @override
  Widget build(BuildContext context) {
    final upcoming = ref.watch(upcomingNotificationsProvider);

    if (upcoming.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ChompdColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ChompdColors.border),
        ),
        child: const Center(
          child: Text(
            'No upcoming notifications',
            style: TextStyle(
              fontSize: 12,
              color: ChompdColors.textDim,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: ChompdColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ChompdColors.border),
      ),
      child: Column(
        children: upcoming
            .take(5) // Show max 5
            .map((n) => _NotificationRow(notification: n))
            .toList(),
      ),
    );
  }
}

/// Single notification row.
class _NotificationRow extends StatelessWidget {
  final ScheduledNotification notification;
  const _NotificationRow({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isRenewal = notification.channelId ==
        NotificationChannels.renewalReminder;
    final isTrial = notification.channelId ==
        NotificationChannels.trialExpiry;
    final icon = isTrial
        ? Icons.timer_outlined
        : isRenewal
            ? Icons.event_repeat_outlined
            : Icons.wb_sunny_outlined;
    final color = isTrial
        ? ChompdColors.amber
        : isRenewal
            ? ChompdColors.mint
            : ChompdColors.blue;

    final daysAway = notification.scheduledAt
        .difference(DateTime.now())
        .inDays;
    final timeLabel = daysAway == 0
        ? 'Today'
        : daysAway == 1
            ? 'Tomorrow'
            : 'In $daysAway days';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ChompdColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  notification.body,
                  style: const TextStyle(
                    fontSize: 10,
                    color: ChompdColors.textDim,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              timeLabel,
              style: ChompdTypography.mono(
                size: 9,
                weight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CSV export button.
class _ExportButton extends StatefulWidget {
  final WidgetRef ref;
  const _ExportButton({required this.ref});

  @override
  State<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<_ExportButton> {
  bool _exporting = false;
  String? _lastPath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _exporting ? null : () => _export(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ChompdColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ChompdColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ChompdColors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: _exporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ChompdColors.purple,
                      ),
                    )
                  : const Icon(
                      Icons.table_chart_outlined,
                      size: 20,
                      color: ChompdColors.purple,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Export to CSV',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ChompdColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _lastPath != null
                        ? 'Saved successfully'
                        : 'Download all your subscriptions as a spreadsheet',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: _lastPath != null
                          ? ChompdColors.mint
                          : ChompdColors.textDim,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _lastPath != null
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: 16,
              color: _lastPath != null
                  ? ChompdColors.mint
                  : ChompdColors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    setState(() => _exporting = true);
    try {
      final allSubs = widget.ref.read(subscriptionsProvider);
      final path = await CsvExport.exportToFile(allSubs);
      HapticService.instance.success();
      setState(() {
        _exporting = false;
        _lastPath = path;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: ChompdColors.bgElevated,
            content: Text(
              'Exported ${allSubs.length} subscriptions to CSV',
              style: const TextStyle(
                color: ChompdColors.text,
                fontSize: 12,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _exporting = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: ChompdColors.red.withValues(alpha: 0.9),
            content: Text(
              'Export failed: $e',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}

/// Budget setting with preset chips and custom entry.
class _BudgetSetting extends StatelessWidget {
  final WidgetRef ref;
  const _BudgetSetting({required this.ref});

  static const _presets = [50.0, 75.0, 100.0, 150.0, 200.0, 300.0];

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(budgetProvider);
    final currency = ref.watch(currencyProvider);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ChompdColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ChompdColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: ChompdColors.mint,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Spending Target',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ChompdColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Used for the spending ring on your dashboard',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: ChompdColors.textDim,
                      ),
                    ),
                  ],
                ),
              ),
              // Current value display
              GestureDetector(
                onTap: () => _showCustomBudgetDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ChompdColors.mint.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ChompdColors.mint.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    Subscription.formatPrice(budget, currency, decimals: 0),
                    style: ChompdTypography.mono(
                      size: 14,
                      weight: FontWeight.w700,
                      color: ChompdColors.mint,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Preset chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((preset) {
              final isSelected = (budget - preset).abs() < 0.01;
              return GestureDetector(
                onTap: () {
                  ref.read(budgetProvider.notifier).setBudget(preset);
                  HapticService.instance.selection();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ChompdColors.mint.withValues(alpha: 0.15)
                        : ChompdColors.bgElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? ChompdColors.mint.withValues(alpha: 0.4)
                          : ChompdColors.border,
                    ),
                  ),
                  child: Text(
                    Subscription.formatPrice(preset, currency, decimals: 0),
                    style: ChompdTypography.mono(
                      size: 12,
                      weight: FontWeight.w700,
                      color: isSelected
                          ? ChompdColors.mint
                          : ChompdColors.textMid,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showCustomBudgetDialog(BuildContext context) {
    final controller = TextEditingController(
      text: ref.read(budgetProvider).toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ChompdColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: ChompdColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set Monthly Budget',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ChompdColors.text,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Enter your target monthly subscription spend.',
                style: TextStyle(
                  fontSize: 12,
                  color: ChompdColors.textDim,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: ChompdTypography.mono(
                  size: 20,
                  weight: FontWeight.w700,
                  color: ChompdColors.text,
                ),
                decoration: InputDecoration(
                  prefixText: Subscription.isSymbolSuffix(ref.read(currencyProvider))
                      ? null
                      : '${Subscription.currencySymbol(ref.read(currencyProvider))} ',
                  prefixStyle: ChompdTypography.mono(
                    size: 20,
                    weight: FontWeight.w700,
                    color: ChompdColors.mint,
                  ),
                  suffixText: Subscription.isSymbolSuffix(ref.read(currencyProvider))
                      ? ' ${Subscription.currencySymbol(ref.read(currencyProvider))}'
                      : null,
                  suffixStyle: ChompdTypography.mono(
                    size: 20,
                    weight: FontWeight.w700,
                    color: ChompdColors.mint,
                  ),
                  filled: true,
                  fillColor: ChompdColors.bgElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ChompdColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ChompdColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: ChompdColors.mint, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: ChompdColors.textDim),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final value = double.tryParse(controller.text);
                      if (value != null && value > 0) {
                        ref.read(budgetProvider.notifier).setBudget(value);
                        HapticService.instance.success();
                      }
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: ChompdColors.mint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: ChompdColors.bg,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Currency selector — horizontal wrapping chips.
class _CurrencySetting extends StatelessWidget {
  final WidgetRef ref;
  const _CurrencySetting({required this.ref});

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(currencyProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChompdColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ChompdColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Display currency',
            style: TextStyle(
              fontSize: 12,
              color: ChompdColors.textDim,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: supportedCurrencies.map((c) {
              final code = c['code'] as String;
              final symbol = c['symbol'] as String;
              final isSelected = current == code;
              return GestureDetector(
                onTap: () {
                  ref.read(currencyProvider.notifier).setCurrency(code);
                  HapticService.instance.selection();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ChompdColors.mint.withValues(alpha: 0.12)
                        : ChompdColors.bgElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? ChompdColors.mint.withValues(alpha: 0.5)
                          : ChompdColors.border,
                    ),
                  ),
                  child: Text(
                    '$symbol $code',
                    style: ChompdTypography.mono(
                      size: 12,
                      weight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected
                          ? ChompdColors.mint
                          : ChompdColors.textMid,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Info row for about section.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: ChompdColors.textDim,
          ),
        ),
        Text(
          value,
          style: ChompdTypography.mono(
            size: 11,
            weight: FontWeight.w700,
            color: valueColor ?? ChompdColors.textMid,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/subscription.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/subscriptions_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/auth_service.dart';
import '../../services/haptic_service.dart';
import '../../services/notification_service.dart';
import '../../utils/csv_export.dart';
import '../../utils/l10n_extension.dart';
import '../paywall/paywall_screen.dart';

final _versionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

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
    final c = context.colors;
    final prefs = ref.watch(notificationPrefsProvider);
    final summary = ref.watch(notificationSummaryProvider);
    final prefsNotifier = ref.read(notificationPrefsProvider.notifier);

    return Scaffold(
      backgroundColor: c.bg,
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
                        color: c.bgElevated,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: c.border),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 14,
                        color: c.textMid,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.settingsTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: c.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ─── Account Section ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _AccountSection(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ─── Theme Section ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ThemeSection(),
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
                      Icon(
                        Icons.notifications_outlined,
                        size: 16,
                        color: c.mint,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.sectionNotifications,
                        style: ChompdTypography.sectionLabel.copyWith(
                          color: c.mint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${summary.totalScheduled} reminders scheduled',
                    style: TextStyle(
                      fontSize: 11,
                      color: c.textDim,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Global toggle
                  _SettingsToggle(
                    icon: Icons.notifications_active_outlined,
                    title: context.l10n.pushNotifications,
                    subtitle: context.l10n.pushNotificationsSubtitle,
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
                            title: context.l10n.morningDigest,
                            subtitle: context.l10n.morningDigestSubtitle(_formatTime(prefs.digestTime)),
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
                                      c.bgElevated,
                                  borderRadius:
                                      BorderRadius.circular(6),
                                  border: Border.all(
                                      color:
                                          c.border),
                                ),
                                child: Text(
                                  _formatTime(prefs.digestTime),
                                  style: ChompdTypography.mono(
                                    size: 11,
                                    weight: FontWeight.w700,
                                    color: c.textMid,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Renewal reminders
                          _SettingsToggle(
                            icon: Icons.event_repeat_outlined,
                            title: context.l10n.renewalReminders,
                            subtitle: _reminderSubtitle(context, prefs),
                            value: prefs.renewalRemindersEnabled,
                            onChanged:
                                prefsNotifier.toggleRenewalReminders,
                          ),

                          const SizedBox(height: 10),

                          // Trial alerts
                          _SettingsToggle(
                            icon: Icons.timer_outlined,
                            title: context.l10n.trialExpiryAlerts,
                            subtitle:
                                context.l10n.trialExpirySubtitle,
                            value: prefs.trialAlertsEnabled,
                            onChanged:
                                prefsNotifier.toggleTrialAlerts,
                            accentColor: c.amber,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ─── Reminder Schedule Preview ───
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 16,
                        color: c.purple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.sectionReminderSchedule,
                        style: ChompdTypography.sectionLabel.copyWith(
                          color: c.purple,
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
                      Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: c.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.sectionUpcoming,
                        style: ChompdTypography.sectionLabel.copyWith(
                          color: c.blue,
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
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: c.mint,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.sectionChompdPro,
                          style: ChompdTypography.sectionLabel.copyWith(
                            color: c.mint,
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
                              c.mint.withValues(alpha: 0.08),
                              c.bgCard,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: c.mint.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  colors: [
                                    c.mintDark,
                                    c.mint,
                                  ],
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.auto_awesome,
                                size: 20,
                                color: c.bg,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.unlockChompdPro,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: c.text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${Subscription.formatPrice(AppConstants.proPrice, 'GBP')} \u2022 ${context.l10n.oneTimePayment}',
                                    style: ChompdTypography.mono(
                                      size: 11,
                                      color: c.textDim,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: c.mint,
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
                      Icon(
                        Icons.currency_exchange_outlined,
                        size: 16,
                        color: c.mint,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.sectionCurrency,
                        style: ChompdTypography.sectionLabel.copyWith(
                          color: c.mint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _CurrencySetting(ref: ref),

                  const SizedBox(height: 28),

                  // ─── Language ───
                  Row(
                    children: [
                      Icon(
                        Icons.language_outlined,
                        size: 16,
                        color: c.mint,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.sectionLanguage,
                        style: ChompdTypography.sectionLabel.copyWith(
                          color: c.mint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _LanguageSetting(ref: ref),
                  const SizedBox(height: 28),

                  // ─── Monthly Budget ───
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 16,
                        color: c.mint,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.sectionMonthlyBudget,
                        style: ChompdTypography.sectionLabel.copyWith(
                          color: c.mint,
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
                      Icon(
                        Icons.vibration_outlined,
                        size: 16,
                        color: c.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.sectionHapticFeedback,
                        style: ChompdTypography.sectionLabel.copyWith(
                          color: c.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _SettingsToggle(
                    icon: Icons.vibration_outlined,
                    title: context.l10n.hapticFeedback,
                    subtitle: context.l10n.hapticSubtitle,
                    value: HapticService.instance.enabled,
                    onChanged: (val) {
                      HapticService.instance.setEnabled(val);
                      if (val) HapticService.instance.selection();
                      // Force rebuild
                      (context as Element).markNeedsBuild();
                    },
                    accentColor: c.blue,
                  ),

                  const SizedBox(height: 28),

                  // ─── Data Export ───
                  Row(
                    children: [
                      Icon(
                        Icons.download_outlined,
                        size: 16,
                        color: c.purple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.sectionDataExport,
                        style: ChompdTypography.sectionLabel.copyWith(
                          color: c.purple,
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
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: c.textDim,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.sectionAbout,
                        style: ChompdTypography.sectionLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _InfoRow(
                    label: context.l10n.version,
                    value: ref.watch(_versionProvider).when(
                      data: (v) => v,
                      loading: () => '...',
                      error: (_, __) => '1.0.0',
                    ),
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    label: context.l10n.tier,
                    value: prefs.isPro ? context.l10n.pro : context.l10n.free,
                    valueColor: prefs.isPro
                        ? c.mint
                        : c.textDim,
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    label: context.l10n.aiModel,
                    value: context.l10n.aiModelValue,
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

  String _reminderSubtitle(BuildContext context, NotificationPreferences prefs) {
    final days = prefs.activeReminderDays;
    if (days.length == 1 && days.first == 0) {
      return context.l10n.reminderSubtitleMorningOnly;
    }
    final labels = days.map((d) {
      if (d == 0) return context.l10n.dayOf;
      if (d == 1) return context.l10n.oneDay;
      return context.l10n.nDays(d);
    }).toList();
    return context.l10n.reminderSubtitleDays(labels.join(', '));
  }

  Future<void> _pickDigestTime(
    BuildContext context,
    WidgetRef ref,
    TimeOfDay currentTime,
  ) async {
    final c = context.colors;
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (ctx, child) => Theme(
        data: (context.isDarkMode ? ChompdTheme.dark : ChompdTheme.light).copyWith(
          colorScheme: ColorScheme(
            brightness: context.isDarkMode ? Brightness.dark : Brightness.light,
            primary: c.mint,
            onPrimary: c.bg,
            secondary: c.mint,
            onSecondary: c.bg,
            surface: c.bgElevated,
            onSurface: c.text,
            error: c.red,
            onError: c.text,
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
// Theme Section
// ──────────────────────────────────────────────

class _ThemeSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.palette_outlined,
              size: 16,
              color: context.colors.purple,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.themeTitle,
              style: ChompdTypography.sectionLabel.copyWith(
                color: context.colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.colors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.border),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _ThemeChip(
                label: context.l10n.themeSystem,
                icon: Icons.settings_suggest_outlined,
                isSelected: currentMode == AppThemeMode.system,
                onTap: () => notifier.setMode(AppThemeMode.system),
              ),
              _ThemeChip(
                label: context.l10n.themeDark,
                icon: Icons.dark_mode_outlined,
                isSelected: currentMode == AppThemeMode.dark,
                onTap: () => notifier.setMode(AppThemeMode.dark),
              ),
              _ThemeChip(
                label: context.l10n.themeLight,
                icon: Icons.light_mode_outlined,
                isSelected: currentMode == AppThemeMode.light,
                onTap: () => notifier.setMode(AppThemeMode.light),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticService.instance.selection();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.mint.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? context.colors.mint.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? context.colors.mint : context.colors.textDim,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? context.colors.mint : context.colors.textMid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Account Section
// ──────────────────────────────────────────────

class _AccountSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final authState = ref.watch(authProvider);
    final syncState = ref.watch(syncProvider);

    final isAnonymous = authState.status == AuthStatus.anonymous ||
        authState.status == AuthStatus.initialising;
    final email = AuthService.instance.email;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 16,
              color: context.colors.blue,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.sectionAccount,
              style: ChompdTypography.sectionLabel.copyWith(
                color: context.colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showAccountSheet(context, ref, isAnonymous),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isAnonymous
                    ? c.amber.withValues(alpha: 0.3)
                    : c.mint.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isAnonymous
                        ? c.amber.withValues(alpha: 0.1)
                        : c.mint.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isAnonymous
                        ? Icons.cloud_off_outlined
                        : Icons.cloud_done_outlined,
                    size: 20,
                    color: isAnonymous
                        ? c.amber
                        : c.mint,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAnonymous
                            ? context.l10n.accountAnonymous
                            : context.l10n.accountBackedUp,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAnonymous
                            ? context.l10n.accountBackupPrompt
                            : (email != null
                                ? context.l10n.accountSignedInAs(email)
                                : _syncLabel(context, syncState)),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: c.textDim,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Sync indicator
                if (!isAnonymous) ...[
                  const SizedBox(width: 8),
                  if (syncState.isSyncing)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.mint,
                      ),
                    )
                  else
                    Icon(
                      syncState.isOnline
                          ? Icons.check_circle_outline_rounded
                          : Icons.wifi_off_rounded,
                      size: 16,
                      color: syncState.isOnline
                          ? c.mint
                          : c.textDim,
                    ),
                ],
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: c.textDim,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _syncLabel(BuildContext context, SyncState syncState) {
    if (syncState.isSyncing) return context.l10n.syncStatusSyncing;
    if (!syncState.isOnline) return context.l10n.syncStatusOffline;
    if (syncState.lastSyncAt != null) {
      final ago = DateTime.now().difference(syncState.lastSyncAt!);
      if (ago.inMinutes < 1) return context.l10n.syncStatusSynced;
      if (ago.inMinutes < 60) {
        return context.l10n.syncStatusLastSync('${ago.inMinutes}m ago');
      }
      return context.l10n.syncStatusLastSync('${ago.inHours}h ago');
    }
    return context.l10n.syncStatusNeverSynced;
  }

  void _showAccountSheet(
    BuildContext context,
    WidgetRef ref,
    bool isAnonymous,
  ) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: c.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: c.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              if (isAnonymous) ...[
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: c.blue,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.signInToBackUp,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _SignInButton(
                  icon: Icons.apple,
                  label: context.l10n.signInWithApple,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await AuthService.instance.linkAppleSignIn();
                    ref.invalidate(authProvider);
                  },
                ),
                const SizedBox(height: 10),
                _SignInButton(
                  icon: Icons.g_mobiledata_rounded,
                  label: context.l10n.signInWithGoogle,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await AuthService.instance.linkGoogleSignIn();
                    ref.invalidate(authProvider);
                  },
                ),
              ] else ...[
                Icon(
                  Icons.cloud_done_outlined,
                  size: 40,
                  color: c.mint,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.accountBackedUp,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
                if (AuthService.instance.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    AuthService.instance.email!,
                    style: TextStyle(
                      fontSize: 12,
                      color: c.textDim,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmSignOut(context, ref);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: c.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: c.red.withValues(alpha: 0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      context.l10n.signOut,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.red,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.border),
        ),
        title: Text(
          context.l10n.signOut,
          style: TextStyle(
            color: c.text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          context.l10n.signOutConfirm,
          style: TextStyle(
            color: c.textMid,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.cancel,
              style: TextStyle(color: c.textDim),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.instance.signOut();
              ref.invalidate(authProvider);
            },
            child: Text(
              context.l10n.signOut,
              style: TextStyle(color: c.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SignInButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: c.bgElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: c.text),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.text,
              ),
            ),
          ],
        ),
      ),
    );
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
    final c = context.colors;
    final accent = accentColor ?? c.mint;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value
              ? accent.withValues(alpha: 0.2)
              : c.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: value ? accent : c.textDim,
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
                        ? c.text
                        : c.textMid,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: c.textDim,
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
    final c = context.colors;
    return Container(
      width: 40,
      height: 22,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: value ? color : c.bgElevated,
        borderRadius: BorderRadius.circular(11),
        border: value
            ? null
            : Border.all(color: c.border),
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
            color: value ? Colors.white : c.textDim,
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
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          // Timeline visualization
          Row(
            children: [
              _TimelineDot(
                day: 7,
                label: context.l10n.timelineLabel7d,
                isActive: activeReminderDays.contains(7),
                isPro: true,
              ),
              _TimelineConnector(
                isActive: activeReminderDays.contains(7),
              ),
              _TimelineDot(
                day: 3,
                label: context.l10n.timelineLabel3d,
                isActive: activeReminderDays.contains(3),
                isPro: true,
              ),
              _TimelineConnector(
                isActive: activeReminderDays.contains(3),
              ),
              _TimelineDot(
                day: 1,
                label: context.l10n.timelineLabel1d,
                isActive: activeReminderDays.contains(1),
                isPro: true,
              ),
              _TimelineConnector(
                isActive: activeReminderDays.contains(1),
              ),
              _TimelineDot(
                day: 0,
                label: context.l10n.timelineLabelDayOf,
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
                  color: c.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: c.purple.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: c.purple,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.upgradeProReminders,
                        style: TextStyle(
                          fontSize: 11,
                          color: c.purple,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: c.purple,
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
    final c = context.colors;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive
                ? c.mint.withValues(alpha: 0.15)
                : c.bgElevated,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? c.mint
                  : c.border,
              width: isActive ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: isActive
              ? Icon(
                  Icons.notifications_active_rounded,
                  size: 12,
                  color: c.mint,
                )
              : Icon(
                  isPro ? Icons.lock_outline_rounded : Icons.check_rounded,
                  size: 10,
                  color: c.textDim,
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: isActive
                ? c.mint
                : c.textDim,
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
    final c = context.colors;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: isActive
              ? c.mint.withValues(alpha: 0.3)
              : c.border,
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
    final c = context.colors;
    final upcoming = ref.watch(upcomingNotificationsProvider);

    if (upcoming.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Center(
          child: Text(
            context.l10n.noUpcomingNotifications,
            style: TextStyle(
              fontSize: 12,
              color: c.textDim,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
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
    final c = context.colors;
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
        ? c.amber
        : isRenewal
            ? c.mint
            : c.blue;

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
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: c.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  notification.body,
                  style: TextStyle(
                    fontSize: 10,
                    color: c.textDim,
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
    final c = context.colors;
    return GestureDetector(
      onTap: _exporting ? null : () => _export(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: _exporting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.purple,
                      ),
                    )
                  : Icon(
                      Icons.table_chart_outlined,
                      size: 20,
                      color: c.purple,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.exportToCsv,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _lastPath != null
                        ? 'Saved successfully'
                        : context.l10n.exportHint,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: _lastPath != null
                          ? c.mint
                          : c.textDim,
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
                  ? c.mint
                  : c.purple,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    final c = context.colors;
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
            backgroundColor: c.bgElevated,
            content: Text(
              context.l10n.exportSuccess(allSubs.length),
              style: TextStyle(
                color: c.text,
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
            backgroundColor: c.red.withValues(alpha: 0.9),
            content: Text(
              context.l10n.exportFailed(e.toString()),
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
    final c = context.colors;
    final budget = ref.watch(budgetProvider);
    final currency = ref.watch(currencyProvider);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: c.mint,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.monthlySpendingTarget,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.budgetHint,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: c.textDim,
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
                    color: c.mint.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: c.mint.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    Subscription.formatPrice(budget, currency, decimals: 0),
                    style: ChompdTypography.mono(
                      size: 14,
                      weight: FontWeight.w700,
                      color: c.mint,
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
                        ? c.mint.withValues(alpha: 0.15)
                        : c.bgElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? c.mint.withValues(alpha: 0.4)
                          : c.border,
                    ),
                  ),
                  child: Text(
                    Subscription.formatPrice(preset, currency, decimals: 0),
                    style: ChompdTypography.mono(
                      size: 12,
                      weight: FontWeight.w700,
                      color: isSelected
                          ? c.mint
                          : c.textMid,
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
    final c = context.colors;
    final controller = TextEditingController(
      text: ref.read(budgetProvider).toStringAsFixed(0),
    );
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: c.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.setBudgetTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.setBudgetSubtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: c.textDim,
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
                  color: c.text,
                ),
                decoration: InputDecoration(
                  prefixText: Subscription.isSymbolSuffix(ref.read(currencyProvider))
                      ? null
                      : '${Subscription.currencySymbol(ref.read(currencyProvider))} ',
                  prefixStyle: ChompdTypography.mono(
                    size: 20,
                    weight: FontWeight.w700,
                    color: c.mint,
                  ),
                  suffixText: Subscription.isSymbolSuffix(ref.read(currencyProvider))
                      ? ' ${Subscription.currencySymbol(ref.read(currencyProvider))}'
                      : null,
                  suffixStyle: ChompdTypography.mono(
                    size: 20,
                    weight: FontWeight.w700,
                    color: c.mint,
                  ),
                  filled: true,
                  fillColor: c.bgElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: c.mint, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      context.l10n.cancel,
                      style: TextStyle(color: c.textDim),
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
                        color: c.mint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.l10n.save,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: c.bg,
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
    final c = context.colors;
    final current = ref.watch(currencyProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Display currency',
            style: TextStyle(
              fontSize: 12,
              color: c.textDim,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: supportedCurrencies.map((cur) {
              final code = cur['code'] as String;
              final symbol = cur['symbol'] as String;
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
                        ? c.mint.withValues(alpha: 0.12)
                        : c.bgElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? c.mint.withValues(alpha: 0.5)
                          : c.border,
                    ),
                  ),
                  child: Text(
                    '$symbol $code',
                    style: ChompdTypography.mono(
                      size: 12,
                      weight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected
                          ? c.mint
                          : c.textMid,
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

/// Language selector — horizontal wrapping chips.
class _LanguageSetting extends StatelessWidget {
  final WidgetRef ref;
  const _LanguageSetting({required this.ref});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final currentLocale = ref.watch(localeProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: supportedLanguages.map((lang) {
        final code = lang['code']!;
        final isSelected = currentLocale.languageCode == code;
        return GestureDetector(
          onTap: () {
            HapticService.instance.selection();
            ref.read(localeProvider.notifier).setLocale(Locale(code));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? c.mint.withValues(alpha: 0.12)
                  : c.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? c.mint.withValues(alpha: 0.4)
                    : c.border,
              ),
            ),
            child: Text(
              lang['native']!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? c.mint : c.textMid,
              ),
            ),
          ),
        );
      }).toList(),
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
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: c.textDim,
          ),
        ),
        Text(
          value,
          style: ChompdTypography.mono(
            size: 11,
            weight: FontWeight.w700,
            color: valueColor ?? c.textMid,
          ),
        ),
      ],
    );
  }
}

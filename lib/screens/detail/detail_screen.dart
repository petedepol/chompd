import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/subscription.dart';
import '../../providers/notification_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/subscriptions_provider.dart';
import '../../data/cancel_guides_data.dart';
import '../../services/haptic_service.dart';
import '../../services/notification_service.dart';
import '../../utils/date_helpers.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/mascot_image.dart';
import '../cancel/cancel_guide_screen.dart';
import '../paywall/paywall_screen.dart';
import 'add_edit_screen.dart';

/// Subscription detail screen — matches the visual design prototype.
///
/// Shows hero card with brand colour, renewal countdown bar,
/// reminders section, payment history, and cancel button.
class DetailScreen extends ConsumerWidget {
  final Subscription subscription;

  const DetailScreen({super.key, required this.subscription});

  static Color _parseHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for live updates
    final subs = ref.watch(subscriptionsProvider);
    final liveSub = subs.where((s) => s.uid == subscription.uid).firstOrNull;
    final sub = liveSub ?? subscription;

    final color = sub.brandColor != null
        ? _parseHex(sub.brandColor!)
        : ChompdColors.textDim;
    final daysLeft = sub.daysUntilRenewal;
    final renewalPct = (1 - (daysLeft / sub.cycle.approximateDays)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: ChompdColors.bg,
      body: CustomScrollView(
        slivers: [
          // Safe area
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.top + 8),
          ),

          // ─── Top Bar ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _BackButton(onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.subscriptionDetail,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ChompdColors.text,
                      ),
                    ),
                  ),
                  _IconButton(
                    icon: Icons.edit_outlined,
                    onTap: () => _openEditForm(context, ref, sub),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ─── Hero Card ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.13),
                      ChompdColors.bgCard,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.87),
                            color.withValues(alpha: 0.53),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.27),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        sub.iconName ?? sub.name[0],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      sub.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ChompdColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: sub.priceDisplay.split('/')[0],
                            style: ChompdTypography.mono(
                              size: 28,
                              weight: FontWeight.w700,
                              color: ChompdColors.mint,
                            ),
                          ),
                          TextSpan(
                            text: '/${sub.cycle.localShortLabel(context.l10n)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: ChompdColors.textDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Annual cost reframe (confronting pill)
                    if (sub.cycle != BillingCycle.yearly) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ChompdColors.bgElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: sub.yearlyEquivalent > 100
                                ? ChompdColors.amber.withValues(alpha: 0.2)
                                : ChompdColors.border,
                          ),
                        ),
                        child: Text(
                          context.l10n.thatsPerYear(Subscription.formatPrice(sub.yearlyEquivalent, sub.currency, decimals: 0)),
                          style: ChompdTypography.mono(
                            size: 12,
                            weight: FontWeight.w600,
                            color: sub.yearlyEquivalent > 100
                                ? ChompdColors.amber
                                : ChompdColors.textMid,
                          ),
                        ),
                      ),
                      // Lifetime projection
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.overThreeYears(Subscription.formatPrice(sub.yearlyEquivalent * 3, sub.currency, decimals: 0)),
                        style: const TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: ChompdColors.textDim,
                        ),
                      ),
                    ],
                    if (sub.isTrial && sub.trialDaysRemaining != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ChompdColors.amberGlow,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: ChompdColors.amber.withValues(alpha: 0.27),
                          ),
                        ),
                        child: Text(
                          sub.trialDaysRemaining! <= 0
                              ? context.l10n.trialExpired
                              : context.l10n.trialDaysRemaining(sub.trialDaysRemaining!),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ChompdColors.amber,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ─── Trap Warning (if applicable) ───
          if (sub.isTrap == true)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 12,
                ),
                child: _TrapInfoCard(subscription: sub),
              ),
            ),

          // ─── Renewal Countdown ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _InfoCard(
                label: context.l10n.nextRenewal,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateHelpers.shortDate(sub.nextRenewal),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ChompdColors.text,
                          ),
                        ),
                        Text(
                          daysLeft == 0
                              ? context.l10n.chargesToday(Subscription.formatPrice(sub.price, sub.currency))
                              : daysLeft == 1
                                  ? context.l10n.chargesTomorrow(Subscription.formatPrice(sub.price, sub.currency))
                                  : daysLeft <= 3
                                      ? context.l10n.chargesSoon(daysLeft, Subscription.formatPrice(sub.price, sub.currency))
                                      : context.l10n.daysCount(daysLeft),
                          style: ChompdTypography.mono(
                            size: 12,
                            weight: FontWeight.w700,
                            color: daysLeft <= 3
                                ? ChompdColors.red
                                : daysLeft <= 7
                                    ? ChompdColors.amber
                                    : ChompdColors.mint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: renewalPct,
                        minHeight: 6,
                        backgroundColor: ChompdColors.bgElevated,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          daysLeft <= 3
                              ? ChompdColors.red
                              : daysLeft <= 7
                                  ? ChompdColors.amber
                                  : ChompdColors.mint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ─── Reminders ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _RemindersCard(subscriptionUid: sub.uid, ref: ref),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ─── Payment History ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _InfoCard(
                label: context.l10n.sectionPaymentHistory,
                child: Column(
                  children: [
                    ..._buildPaymentHistory(sub),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.totalPaid,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ChompdColors.textMid,
                            ),
                          ),
                          Text(
                            Subscription.formatPrice(sub.totalPaidSinceCreation, sub.currency),
                            style: ChompdTypography.mono(
                              size: 13,
                              weight: FontWeight.w700,
                              color: ChompdColors.mint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ─── Details ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _InfoCard(
                label: context.l10n.sectionDetails,
                child: Column(
                  children: [
                    _DetailRow(label: context.l10n.detailCategory, value: AppConstants.localisedCategory(sub.category, context.l10n)),
                    _divider(),
                    _DetailRow(label: context.l10n.detailCurrency, value: sub.currency),
                    _divider(),
                    _DetailRow(label: context.l10n.detailBillingCycle, value: sub.cycle.localLabel(context.l10n)),
                    _divider(),
                    _DetailRow(
                      label: context.l10n.detailAdded,
                      value: context.l10n.addedVia(
                        DateHelpers.shortDate(sub.createdAt),
                        sub.source == SubscriptionSource.aiScan
                            ? context.l10n.sourceAiScan
                            : sub.source == SubscriptionSource.quickAdd
                                ? context.l10n.sourceQuickAdd
                                : context.l10n.sourceManual,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ─── Delete Button ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: GestureDetector(
                onTap: () => _showDeleteDialog(context, ref, sub),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ChompdColors.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    context.l10n.delete,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ChompdColors.textDim,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Cancel Guide Button (bottom of page) ───
          if (sub.isActive)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: GestureDetector(
                  onTap: () => _navigateToCancelGuide(context, sub),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: ChompdColors.redGlow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: ChompdColors.red.withValues(alpha: 0.2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      context.l10n.cancelSubscription,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ChompdColors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 30,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPaymentHistory(Subscription sub) {
    // Calculate real payment dates from createdAt → now based on billing cycle.
    final payments = <DateTime>[];
    final now = DateTime.now();
    final start = sub.createdAt;

    // Walk backwards from the most recent renewal to createdAt.
    // nextRenewal is the *upcoming* one, so the last paid date
    // is one cycle before nextRenewal.
    DateTime cursor = _subtractCycle(sub.nextRenewal, sub.cycle);

    // Collect past payments (most recent first), up to 12 entries max.
    while (!cursor.isBefore(start) && payments.length < 12) {
      if (!cursor.isAfter(now)) {
        payments.add(cursor);
      }
      cursor = _subtractCycle(cursor, sub.cycle);
    }

    // If no payments yet (e.g. new trial), show a hint.
    if (payments.isEmpty) {
      return [
        Builder(builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              context.l10n.noPaymentsYet(DateHelpers.shortDate(start)),
              style: const TextStyle(
                fontSize: 12,
                color: ChompdColors.textDim,
              ),
            ),
          );
        }),
      ];
    }

    return payments.asMap().entries.map((entry) {
      final isLast = entry.key == payments.length - 1;
      final date = entry.value;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateHelpers.shortDate(date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: ChompdColors.textMid,
                  ),
                ),
                Text(
                  Subscription.formatPrice(sub.price, sub.currency),
                  style: ChompdTypography.mono(
                    size: 12,
                    color: ChompdColors.text,
                  ),
                ),
              ],
            ),
          ),
          if (!isLast) _divider(),
        ],
      );
    }).toList();
  }

  /// Subtract one billing cycle from a date.
  static DateTime _subtractCycle(DateTime date, BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.weekly:
        return date.subtract(const Duration(days: 7));
      case BillingCycle.monthly:
        return DateTime(date.year, date.month - 1, date.day);
      case BillingCycle.quarterly:
        return DateTime(date.year, date.month - 3, date.day);
      case BillingCycle.yearly:
        return DateTime(date.year - 1, date.month, date.day);
    }
  }

  void _openEditForm(BuildContext context, WidgetRef ref, Subscription sub) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditScreen(existingSub: sub),
      ),
    );
  }

  /// Navigates to the cancel guide for this service.
  /// Falls back to generic platform guide if no specific match found.
  void _navigateToCancelGuide(BuildContext context, Subscription sub) {
    final guide = findGuideForSubscription(sub.name);
    if (guide != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              CancelGuideScreen(subscription: sub, guide: guide),
        ),
      );
    } else {
      // Fallback: show generic advice
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.noGuideYet(sub.name),
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: ChompdColors.bgElevated,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, Subscription sub) {
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        title: context.l10n.deleteNameTitle(sub.name),
        message: context.l10n.deleteNameMessage,
        confirmLabel: context.l10n.delete,
        confirmColor: ChompdColors.red,
        onConfirm: () {
          ref.read(subscriptionsProvider.notifier).remove(sub.uid);
          NotificationService.instance.cancelReminders(sub.uid);
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  static Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: ChompdColors.border,
    );
  }
}

// ─── Shared Widgets ───

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: ChompdColors.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ChompdColors.border),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.arrow_back_rounded,
          size: 16,
          color: ChompdColors.textMid,
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: ChompdColors.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ChompdColors.border),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: ChompdColors.textMid),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final Widget child;
  const _InfoCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ChompdColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ChompdColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ChompdTypography.sectionLabel),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Interactive reminders card — shows scheduled reminders and upcoming alerts.
class _RemindersCard extends StatelessWidget {
  final String subscriptionUid;
  final WidgetRef ref;

  const _RemindersCard({required this.subscriptionUid, required this.ref});

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(notificationPrefsProvider);
    final scheduled =
        NotificationService.instance.getForSubscription(subscriptionUid);
    final isPro = prefs.isPro;

    return _InfoCard(
      label: context.l10n.sectionReminders,
      child: Column(
        children: [
          // Scheduled count
          if (scheduled.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    size: 13,
                    color: ChompdColors.mint,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.remindersScheduled(scheduled.length),
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: ChompdColors.mint,
                    ),
                  ),
                ],
              ),
            ),

          _ReminderRow(
            label: context.l10n.reminderDaysBefore7,
            enabled: prefs.renewalRemindersEnabled &&
                prefs.activeReminderDays.contains(7),
            isPro: true,
            isLocked: !isPro,
            onChanged: isPro ? (_) {
              ref.read(notificationPrefsProvider.notifier).toggleReminderDay(7);
              HapticService.instance.selection();
            } : null,
          ),
          const Divider(height: 1, color: ChompdColors.border),
          _ReminderRow(
            label: context.l10n.reminderDaysBefore3,
            enabled: prefs.renewalRemindersEnabled &&
                prefs.activeReminderDays.contains(3),
            isPro: true,
            isLocked: !isPro,
            onChanged: isPro ? (_) {
              ref.read(notificationPrefsProvider.notifier).toggleReminderDay(3);
              HapticService.instance.selection();
            } : null,
          ),
          const Divider(height: 1, color: ChompdColors.border),
          _ReminderRow(
            label: context.l10n.reminderDaysBefore1,
            enabled: prefs.renewalRemindersEnabled &&
                prefs.activeReminderDays.contains(1),
            isPro: true,
            isLocked: !isPro,
            onChanged: isPro ? (_) {
              ref.read(notificationPrefsProvider.notifier).toggleReminderDay(1);
              HapticService.instance.selection();
            } : null,
          ),
          const Divider(height: 1, color: ChompdColors.border),
          _ReminderRow(
            label: context.l10n.reminderMorningOf,
            enabled: prefs.renewalRemindersEnabled &&
                prefs.activeReminderDays.contains(0),
            isPro: false,
            isLocked: false,
            onChanged: (_) {
              ref.read(notificationPrefsProvider.notifier).toggleReminderDay(0);
              HapticService.instance.selection();
            },
          ),

          if (!isPro) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => showPaywall(
                context,
                trigger: PaywallTrigger.reminderUpgrade,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ChompdColors.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 12,
                      color: ChompdColors.purple,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.l10n.upgradeForReminders,
                        style: const TextStyle(
                          fontSize: 10,
                          color: ChompdColors.purple,
                        ),
                      ),
                    ),
                    const Icon(
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

class _ReminderRow extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool isPro;
  final bool isLocked;
  final ValueChanged<bool>? onChanged;
  const _ReminderRow({
    required this.label,
    required this.enabled,
    required this.isPro,
    this.isLocked = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : () => onChanged?.call(!enabled),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  color: enabled ? ChompdColors.text : ChompdColors.textDim,
                ),
              ),
            ),
            if (isPro)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: ChompdColors.mint.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PRO',
                  style: ChompdTypography.mono(
                    size: 7,
                    weight: FontWeight.w700,
                    color: ChompdColors.mint,
                  ),
                ),
              ),
            if (isLocked)
              const Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: ChompdColors.textDim,
              )
            else
              Container(
                width: 36,
                height: 20,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: enabled ? ChompdColors.mint : ChompdColors.bgElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment:
                      enabled ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: ChompdColors.textDim),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ChompdColors.text,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ChompdColors.bgElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ChompdColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: ChompdColors.textMid,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ChompdColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.l10n.keep,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ChompdColors.textMid,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: confirmColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: confirmColor.withValues(alpha: 0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        confirmLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: confirmColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Trap warning card shown on detail screen for subscriptions
/// flagged as dark pattern traps.
class _TrapInfoCard extends StatelessWidget {
  final Subscription subscription;
  const _TrapInfoCard({required this.subscription});

  /// Map stored trapType string to localised label.
  String _trapTypeLabel(BuildContext context) {
    return switch (subscription.trapType) {
      'trialBait' => context.l10n.trapTypeTrialBait,
      'priceFraming' => context.l10n.trapTypePriceFraming,
      'hiddenRenewal' => context.l10n.trapTypeHiddenRenewal,
      'cancelFriction' => context.l10n.trapTypeCancelFriction,
      _ => context.l10n.trapTypeGeneric,
    };
  }

  /// Map severity string to localised one-liner explanation.
  String _severityExplanation(BuildContext context) {
    return switch (subscription.trapSeverity) {
      'high' => context.l10n.severityExplainHigh,
      'medium' => context.l10n.severityExplainMedium,
      _ => context.l10n.severityExplainLow,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isHigh = subscription.trapSeverity == 'high';
    final warningColor = isHigh ? ChompdColors.red : ChompdColors.amber;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warningColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: TRAP DETECTED + severity badge
          Row(
            children: [
              Icon(Icons.warning_rounded, size: 16, color: warningColor),
              const SizedBox(width: 6),
              const MascotImage(
                asset: 'piranha_alert.png',
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.trapDetected,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: warningColor,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: warningColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  (subscription.trapSeverity ?? 'medium').toUpperCase(),
                  style: ChompdTypography.mono(
                    size: 9,
                    weight: FontWeight.w700,
                    color: warningColor,
                  ),
                ),
              ),
            ],
          ),

          // Trap type pill + severity explanation
          const SizedBox(height: 10),
          Row(
            children: [
              // Trap type pill (e.g. "Trial Bait")
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ChompdColors.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  _trapTypeLabel(context),
                  style: ChompdTypography.mono(
                    size: 10,
                    weight: FontWeight.w600,
                    color: ChompdColors.purple,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Severity one-liner
              Expanded(
                child: Text(
                  _severityExplanation(context),
                  style: const TextStyle(
                    fontSize: 11,
                    color: ChompdColors.textDim,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // AI warning message (piranha explanation)
          if (subscription.trapWarningMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: ChompdColors.mintGlow,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                subscription.trapWarningMessage!,
                style: const TextStyle(
                  fontSize: 13,
                  color: ChompdColors.textMid,
                  height: 1.5,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Trial price → Real price
          if (subscription.trialPrice != null &&
              subscription.realPrice != null)
            Row(
              children: [
                Text(
                  Subscription.formatPrice(subscription.trialPrice!, subscription.currency),
                  style: ChompdTypography.mono(
                    size: 16,
                    color: ChompdColors.textDim,
                  ).copyWith(decoration: TextDecoration.lineThrough),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 14, color: warningColor),
                const SizedBox(width: 8),
                Text(
                  Subscription.formatPrice(subscription.realPrice!, subscription.currency),
                  style: ChompdTypography.mono(
                    size: 16,
                    weight: FontWeight.w700,
                    color: warningColor,
                  ),
                ),
              ],
            ),

          // Trial expiry
          if (subscription.trialExpiresAt != null) ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.trialExpires(DateHelpers.shortDate(subscription.trialExpiresAt!)),
              style: TextStyle(fontSize: 12, color: warningColor),
            ),
          ],

          // Real annual cost
          if (subscription.realAnnualCost != null) ...[
            const SizedBox(height: 4),
            Text(
              context.l10n.realAnnualCost(Subscription.formatPrice(subscription.realAnnualCost!, subscription.currency)),
              style: const TextStyle(
                fontSize: 11,
                color: ChompdColors.textDim,
              ),
            ),
          ],
        ],
      ),
    );
  }
}


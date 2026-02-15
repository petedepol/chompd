import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/cancel_guide_v2.dart';
import '../../models/subscription.dart';
import '../../providers/notification_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/subscriptions_provider.dart';
import '../../providers/service_cache_provider.dart';
import '../../services/haptic_service.dart';
import '../../services/notification_service.dart';
import '../../utils/date_helpers.dart';
import '../../utils/l10n_extension.dart';
import '../../data/generic_cancel_guides.dart';
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
    final c = context.colors;
    // Watch for live updates
    final subs = ref.watch(subscriptionsProvider);
    final liveSub = subs.where((s) => s.uid == subscription.uid).firstOrNull;
    final sub = liveSub ?? subscription;

    final color = sub.brandColor != null
        ? _parseHex(sub.brandColor!)
        : c.textDim;
    final serviceDescription = ref.read(serviceCacheProvider.notifier)
        .findByName(sub.name)?.description;
    final daysLeft = sub.daysUntilRenewal;
    final renewalPct = (1 - (daysLeft / sub.cycle.approximateDays)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: c.bg,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: c.text,
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
                      c.bgCard,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    // Icon + Name + Description (horizontal layout)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
                              colors: [
                                color.withValues(alpha: 0.87),
                                color.withValues(alpha: 0.53),
                              ],
                            ),
                            border: Theme.of(context).brightness == Brightness.light
                                ? Border.all(
                                    color: Colors.black.withValues(alpha: 0.08),
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.27),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            sub.iconName ?? sub.name[0],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: c.text,
                                ),
                              ),
                              if (serviceDescription != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  serviceDescription,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: c.textDim,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: sub.priceDisplay.split('/')[0],
                            style: ChompdTypography.mono(
                              size: 28,
                              weight: FontWeight.w700,
                              color: c.mint,
                            ),
                          ),
                          TextSpan(
                            text: '/${sub.cycle.localShortLabel(context.l10n)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: c.textDim,
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
                          color: sub.yearlyEquivalent > 100
                              ? c.amber.withValues(alpha: 0.15)
                              : c.bgElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: sub.yearlyEquivalent > 100
                                ? c.amber.withValues(alpha: 0.3)
                                : c.border,
                          ),
                        ),
                        child: Text(
                          context.l10n.thatsPerYear(Subscription.formatPrice(sub.yearlyEquivalent, sub.currency, decimals: 0)),
                          style: ChompdTypography.mono(
                            size: 12,
                            weight: FontWeight.w600,
                            color: sub.yearlyEquivalent > 100
                                ? c.amber
                                : c.textMid,
                          ),
                        ),
                      ),
                      // Lifetime projection
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.overThreeYears(Subscription.formatPrice(sub.yearlyEquivalent * 3, sub.currency, decimals: 0)),
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: c.textMid.withValues(alpha: 0.7),
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
                          color: c.amberGlow,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: c.amber.withValues(alpha: 0.27),
                          ),
                        ),
                        child: Text(
                          sub.trialDaysRemaining! <= 0
                              ? context.l10n.trialExpired
                              : context.l10n.trialDaysRemaining(sub.trialDaysRemaining!),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: c.amber,
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

          // ─── Unmatched Service Banner ───
          if (!sub.isMatched)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 12,
                ),
                child: _UnmatchedInfoBanner(),
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
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: c.text,
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
                                ? c.red
                                : daysLeft <= 7
                                    ? c.amber
                                    : c.mint,
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
                        backgroundColor: c.bgElevated,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          daysLeft <= 3
                              ? c.red
                              : daysLeft <= 7
                                  ? c.amber
                                  : c.mint,
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
                child: Builder(builder: (context) {
                  final historyWidgets = _buildPaymentHistory(sub, context);
                  final pastPaymentCount = _countPastPayments(sub);
                  return Column(
                    children: [
                      ...historyWidgets,
                      if (pastPaymentCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.totalPaid,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: c.textMid,
                                ),
                              ),
                              Text(
                                Subscription.formatPrice(
                                    sub.price * pastPaymentCount, sub.currency),
                                style: ChompdTypography.mono(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: c.mint,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }),
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
                    _divider(context),
                    _DetailRow(label: context.l10n.detailCurrency, value: sub.currency),
                    _divider(context),
                    _DetailRow(label: context.l10n.detailBillingCycle, value: sub.cycle.localLabel(context.l10n)),
                    _divider(context),
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

          // ─── Annual Plan Info ───
          Consumer(builder: (context, ref, _) {
            final cacheNotifier = ref.watch(serviceCacheProvider.notifier);
            final service = cacheNotifier.findByName(sub.name);
            if (service == null) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            // Skip if already on yearly billing
            if (sub.cycle == BillingCycle.yearly) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            final tier = cacheNotifier.findBestTier(sub, service, sub.currency);
            if (tier == null) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            final pair = cacheNotifier.resolvePricePair(tier, service, sub.currency);

            if (pair == null) {
              // Service exists in DB but no annual plan
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _InfoCard(
                    label: context.l10n.annualPlanLabel,
                    child: Text(
                      context.l10n.noAnnualPlan,
                      style: TextStyle(fontSize: 12, color: c.textDim),
                    ),
                  ),
                ),
              );
            }

            final savings = (pair.monthly * 12) - pair.annual;
            if (savings <= 0) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _InfoCard(
                  label: context.l10n.annualPlanLabel,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.savings_outlined,
                        size: 16,
                        color: Color(0xFF1B8F6A),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.annualPlanAvailable(
                            Subscription.formatPrice(savings, sub.currency),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1B8F6A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

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
                    border: Border.all(color: c.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    context.l10n.delete,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.textDim,
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
                  onTap: () => _navigateToCancelGuide(context, ref, sub),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: c.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: c.red.withValues(alpha: 0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      context.l10n.cancelSubscription,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.red,
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

  List<Widget> _buildPaymentHistory(Subscription sub, BuildContext context) {
    final c = context.colors;
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

    // If no payments yet (e.g. new trial), show a richer empty state.
    if (payments.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 32,
                color: c.textDim.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.noPaymentsYet(DateHelpers.shortDate(start)),
                style: TextStyle(
                  fontSize: 12,
                  color: c.textDim,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.paymentsTrackedHint,
                style: TextStyle(
                  fontSize: 11,
                  color: c.textDim.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              // Upcoming payment preview
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: c.bgElevated.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: c.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateHelpers.shortDate(sub.nextRenewal),
                      style: TextStyle(
                        fontSize: 12,
                        color: c.textDim,
                      ),
                    ),
                    Text(
                      Subscription.formatPrice(sub.price, sub.currency),
                      style: ChompdTypography.mono(
                        size: 12,
                        weight: FontWeight.w600,
                        color: c.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ];
    }

    final rows = payments.asMap().entries.map((entry) {
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
                  style: TextStyle(
                    fontSize: 12,
                    color: c.textMid,
                  ),
                ),
                Text(
                  Subscription.formatPrice(sub.price, sub.currency),
                  style: ChompdTypography.mono(
                    size: 12,
                    color: c.text,
                  ),
                ),
              ],
            ),
          ),
          _divider(context),
        ],
      );
    }).toList();

    // Upcoming renewal — visually distinct
    rows.add(Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    DateHelpers.shortDate(sub.nextRenewal),
                    style: TextStyle(
                      fontSize: 12,
                      color: c.textDim,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: c.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      context.l10n.upcoming,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: c.amber,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                Subscription.formatPrice(sub.price, sub.currency),
                style: ChompdTypography.mono(
                  size: 12,
                  color: c.textDim,
                ),
              ),
            ],
          ),
        ),
      ],
    ));

    return rows;
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

  /// Count past payments only (on or before today).
  static int _countPastPayments(Subscription sub) {
    final now = DateTime.now();
    DateTime cursor = _subtractCycle(sub.nextRenewal, sub.cycle);
    int count = 0;
    while (!cursor.isBefore(sub.createdAt) && count < 999) {
      if (!cursor.isAfter(now)) count++;
      cursor = _subtractCycle(cursor, sub.cycle);
    }
    return count;
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
  void _navigateToCancelGuide(
    BuildContext context,
    WidgetRef ref,
    Subscription sub,
  ) {
    final cacheNotifier = ref.read(serviceCacheProvider.notifier);
    final allGuides = cacheNotifier.findAllCancelGuides(sub.name);
    final difficulty = cacheNotifier.getCancelDifficulty(sub.name);

    void openGuide(CancelGuideData guide) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CancelGuideScreen(
            subscription: sub,
            guideData: guide,
            cancelDifficulty: difficulty,
          ),
        ),
      );
    }

    // If exactly one guide, skip picker
    if (allGuides.length == 1) {
      openGuide(allGuides.first);
      return;
    }

    // If multiple guides, show platform picker
    if (allGuides.length > 1) {
      _showPlatformPicker(context, sub, allGuides, difficulty);
      return;
    }

    // No service-specific guides — show generic platform-based guide
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final genericGuide = findGenericCancelGuide(isIOS: isIOS);
    if (genericGuide != null) {
      openGuide(genericGuide);
    }
  }

  void _showPlatformPicker(
    BuildContext context,
    Subscription sub,
    List<CancelGuideData> guides,
    int? difficulty,
  ) {
    final c = context.colors;

    String platformLabel(String platform) {
      switch (platform) {
        case 'ios':
          return context.l10n.cancelPlatformIos;
        case 'android':
          return context.l10n.cancelPlatformAndroid;
        case 'web':
          return context.l10n.cancelPlatformWeb;
        default:
          return platform;
      }
    }

    IconData platformIcon(String platform) {
      switch (platform) {
        case 'ios':
          return Icons.apple;
        case 'android':
          return Icons.android;
        case 'web':
          return Icons.language;
        default:
          return Icons.help_outline;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: c.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.textDim.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.cancelPlatformPickerTitle(sub.name),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 16),
              ...guides.map((guide) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CancelGuideScreen(
                              subscription: sub,
                              guideData: guide,
                              cancelDifficulty: difficulty,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: c.bgElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: c.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              platformIcon(guide.platform),
                              size: 22,
                              color: c.text,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                platformLabel(guide.platform),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: c.text,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: c.textDim,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, Subscription sub) {
    final c = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        title: context.l10n.deleteNameTitle(sub.name),
        message: context.l10n.deleteNameMessage,
        confirmLabel: context.l10n.delete,
        confirmColor: c.red,
        onConfirm: () {
          ref.read(subscriptionsProvider.notifier).remove(sub.uid);
          NotificationService.instance.cancelReminders(sub.uid);
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  static Widget _divider(BuildContext context) {
    final c = context.colors;
    return Divider(
      height: 1,
      thickness: 1,
      color: c.border,
    );
  }
}

// ─── Shared Widgets ───

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: c.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.border),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_back_rounded,
          size: 16,
          color: c.textMid,
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
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: c.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.border),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: c.textMid),
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
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
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

/// Interactive reminders card — shows per-subscription reminder toggles.
///
/// Each subscription has its own reminder schedule stored in
/// `Subscription.reminders`. Falls back to global defaults (morning-of only)
/// when the reminders list is empty (i.e. user hasn't customised yet).
class _RemindersCard extends StatelessWidget {
  final String subscriptionUid;
  final WidgetRef ref;

  const _RemindersCard({required this.subscriptionUid, required this.ref});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final prefs = ref.watch(notificationPrefsProvider);
    final subs = ref.watch(subscriptionsProvider);
    final sub = subs.where((s) => s.uid == subscriptionUid).firstOrNull;
    final scheduled =
        NotificationService.instance.getForSubscription(subscriptionUid);
    final isPro = prefs.isPro;

    // Determine which days are active for THIS subscription.
    // If the sub has custom reminders, use those; otherwise fall back to
    // global prefs (morning-of for free, all for pro).
    final hasCustom = sub != null && sub.reminders.isNotEmpty;
    bool isDayEnabled(int day) {
      if (hasCustom) {
        return sub.reminders.any((r) => r.daysBefore == day && r.enabled);
      }
      // Global fallback
      return prefs.renewalRemindersEnabled &&
          prefs.activeReminderDays.contains(day);
    }

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
                  Icon(
                    Icons.schedule_outlined,
                    size: 13,
                    color: c.mint,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.remindersScheduled(scheduled.length),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: c.mint,
                    ),
                  ),
                ],
              ),
            ),

          _ReminderRow(
            label: context.l10n.reminderDaysBefore7,
            enabled: isDayEnabled(7),
            isPro: true,
            isLocked: !isPro,
            onChanged: isPro ? (_) {
              ref.read(subscriptionsProvider.notifier).toggleReminderDay(subscriptionUid, 7);
              HapticService.instance.selection();
            } : null,
          ),
          Divider(height: 1, color: c.border),
          _ReminderRow(
            label: context.l10n.reminderDaysBefore3,
            enabled: isDayEnabled(3),
            isPro: true,
            isLocked: !isPro,
            onChanged: isPro ? (_) {
              ref.read(subscriptionsProvider.notifier).toggleReminderDay(subscriptionUid, 3);
              HapticService.instance.selection();
            } : null,
          ),
          Divider(height: 1, color: c.border),
          _ReminderRow(
            label: context.l10n.reminderDaysBefore1,
            enabled: isDayEnabled(1),
            isPro: true,
            isLocked: !isPro,
            onChanged: isPro ? (_) {
              ref.read(subscriptionsProvider.notifier).toggleReminderDay(subscriptionUid, 1);
              HapticService.instance.selection();
            } : null,
          ),
          Divider(height: 1, color: c.border),
          _ReminderRow(
            label: context.l10n.reminderMorningOf,
            enabled: isDayEnabled(0),
            isPro: false,
            isLocked: false,
            onChanged: (_) {
              ref.read(subscriptionsProvider.notifier).toggleReminderDay(subscriptionUid, 0);
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
                  color: c.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 12,
                      color: c.purple,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.l10n.upgradeForReminders,
                        style: TextStyle(
                          fontSize: 10,
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
    final c = context.colors;
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
                  color: enabled ? c.text : c.textDim,
                ),
              ),
            ),
            if (isPro)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: c.mint.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PRO',
                  style: ChompdTypography.mono(
                    size: 7,
                    weight: FontWeight.w700,
                    color: c.mint,
                  ),
                ),
              ),
            if (isLocked)
              Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: c.textDim,
              )
            else
              Container(
                width: 36,
                height: 20,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: enabled ? c.mint : c.bgElevated,
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
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: c.textDim),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: c.text,
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
    final c = context.colors;
    return Dialog(
      backgroundColor: c.bgElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: c.textMid,
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
                        border: Border.all(color: c.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.l10n.keep,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.textMid,
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
    final c = context.colors;
    final isHigh = subscription.trapSeverity == 'high';
    final warningColor = isHigh ? c.red : c.amber;
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
                  color: c.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  _trapTypeLabel(context),
                  style: ChompdTypography.mono(
                    size: 10,
                    weight: FontWeight.w600,
                    color: c.purple,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Severity one-liner
              Expanded(
                child: Text(
                  _severityExplanation(context),
                  style: TextStyle(
                    fontSize: 11,
                    color: c.textDim,
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
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: c.mintGlow,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                subscription.trapWarningMessage!,
                style: TextStyle(
                  fontSize: 13,
                  color: c.textMid,
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
                    color: c.textDim,
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
              style: TextStyle(
                fontSize: 11,
                color: c.textDim,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Subtle info banner shown on the detail screen for unmatched services.
///
/// Non-alarming, helpful tone — explains that generic guides are shown.
class _UnmatchedInfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: c.blue.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: c.blue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'We don\'t have specific data for this service yet. Cancel and refund guides show general steps for your platform.',
              style: TextStyle(
                fontSize: 12,
                color: c.textMid,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


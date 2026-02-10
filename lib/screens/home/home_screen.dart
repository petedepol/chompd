import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../models/subscription.dart';
import '../../providers/currency_provider.dart';
import '../../providers/insights_provider.dart';
import '../../providers/nudge_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/subscriptions_provider.dart';
import '../../widgets/share_card_builder.dart';
import '../../services/haptic_service.dart';
import '../../widgets/animated_list_item.dart';
import '../../widgets/category_bar.dart';
import '../../widgets/confetti_overlay.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/milestone_card.dart';
import '../../widgets/money_saved_counter.dart';
import '../../widgets/quick_add_sheet.dart';
import '../../widgets/spending_ring.dart';
import '../../widgets/subscription_card.dart';
import '../../widgets/mascot_image.dart';
import '../../widgets/nudge_card.dart';
import '../../widgets/trap_stats_card.dart';
import '../../providers/budget_provider.dart';
import '../detail/add_edit_screen.dart';
import '../detail/detail_screen.dart';
import '../paywall/paywall_screen.dart';
import '../scan/scan_screen.dart';
import '../calendar/calendar_screen.dart';
import '../settings/settings_screen.dart';

/// Home screen — the main dashboard.
///
/// Layout matches the visual design prototype:
/// - Chompd header with settings button
/// - Spending ring (monthly total with budget arc)
/// - Category breakdown bar
/// - Trial expiry alert banner
/// - Active subscriptions list with stagger entrance + swipe actions
/// - Cancelled subscriptions graveyard with savings
/// - Milestone progress track
/// - Glassmorphic bottom navigation bar
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showConfetti = false;

  void _showAddOptions(BuildContext context, WidgetRef ref) {
    HapticService.instance.selection();
    final canAdd = ref.read(canAddSubProvider);
    final canScan = ref.read(canScanProvider);
    final remainingSubs = ref.read(remainingSubsProvider);
    final remainingScans = ref.read(remainingScansProvider);
    final isPro = ref.read(isProProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(ctx).padding.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: ChompdColors.bgElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: ChompdColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!isPro)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ChompdColors.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ChompdColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _LimitBadge(label: 'Subs left', count: remainingSubs,
                        color: canAdd ? ChompdColors.mint : ChompdColors.red),
                      Container(width: 1, height: 20, color: ChompdColors.border),
                      _LimitBadge(label: 'Scans left', count: remainingScans,
                        color: canScan ? ChompdColors.purple : ChompdColors.red),
                    ],
                  ),
                ),
              ),
            // AI Scan option
            GestureDetector(
              onTap: () async {
                HapticService.instance.selection();
                Navigator.of(ctx).pop();
                if (!canScan) {
                  await showPaywall(context, trigger: PaywallTrigger.scanLimit);
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScanScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: canScan
                        ? [ChompdColors.purple, const Color(0xFF8B5CF6)]
                        : [ChompdColors.purple.withValues(alpha: 0.4),
                           const Color(0xFF8B5CF6).withValues(alpha: 0.4)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ChompdColors.purple.withValues(alpha: 0.27),
                      blurRadius: 20, offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(canScan ? Icons.auto_awesome : Icons.lock_outline_rounded,
                      size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(canScan ? 'AI Scan Screenshot' : 'AI Scan (Upgrade to Pro)',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Quick Add option
            GestureDetector(
              onTap: () async {
                HapticService.instance.selection();
                Navigator.of(ctx).pop();
                if (!canAdd) {
                  await showPaywall(context, trigger: PaywallTrigger.subscriptionLimit);
                  return;
                }
                showQuickAddSheet(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: canAdd
                        ? [ChompdColors.mintDark, ChompdColors.mint]
                        : [ChompdColors.mintDark.withValues(alpha: 0.4),
                           ChompdColors.mint.withValues(alpha: 0.4)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(canAdd ? Icons.add_rounded : Icons.lock_outline_rounded,
                      size: 16, color: ChompdColors.bg),
                    const SizedBox(width: 8),
                    Text(canAdd ? 'Quick Add / Manual' : 'Add Sub (Upgrade to Pro)',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ChompdColors.bg)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptions = ref.watch(subscriptionsProvider);
    final cancelledSubs = ref.watch(cancelledSubsProvider);
    final expiringTrials = ref.watch(expiringTrialsProvider);
    final totalSaved = ref.watch(totalSavedProvider);

    final activeSubs = subscriptions.where((s) => s.isActive).toList();

    return Scaffold(
      backgroundColor: ChompdColors.bg,
      body: Stack(
        children: [
          // ─── Scrollable Content ───
          CustomScrollView(
            slivers: [
              // Safe area padding
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.top + 8,
                ),
              ),

              // ─── Header ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Chomp',
                                  style: TextStyle(
                                    color: ChompdColors.text,
                                  ),
                                ),
                                TextSpan(
                                  text: 'd',
                                  style: TextStyle(
                                    color: ChompdColors.mint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${activeSubs.length} active \u00B7 ${cancelledSubs.length} cancelled',
                            style: const TextStyle(
                              fontSize: 11,
                              color: ChompdColors.textDim,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Calendar button
                          GestureDetector(
                            onTap: () {
                              HapticService.instance.light();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CalendarScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: ChompdColors.bgElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: ChompdColors.border),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.calendar_month_outlined,
                                size: 18,
                                color: ChompdColors.textMid,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Settings button
                          GestureDetector(
                            onTap: () {
                              HapticService.instance.light();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: ChompdColors.bgElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: ChompdColors.border),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.settings_outlined,
                                size: 18,
                                color: ChompdColors.textMid,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Spending Ring ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      const Center(
                        child: SpendingRing(),
                      ),
                      // Budget mood indicator
                      Consumer(
                        builder: (context, ref, _) {
                          final spend = ref.watch(monthlySpendProvider);
                          final budget = ref.watch(budgetProvider);
                          final pct = budget > 0 ? spend / budget : 0.0;

                          if (pct > 1.0) {
                            // Over budget — sad piranha
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const MascotImage(
                                    asset: 'piranha_sad.png',
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ouch. That\u2019s a lot of chomping.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: ChompdColors.red
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (pct < 0.5 && activeSubs.length >= 3) {
                            // Well under budget — happy piranha
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const MascotImage(
                                    asset: 'piranha_thumbsup.png',
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Looking good! Well under budget.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: ChompdColors.mint
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Yearly Burn Banner ───
              if (activeSubs.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: _YearlyBurnBanner(
                      yearlyTotal: ref.watch(yearlySpendProvider),
                      subCount: activeSubs.length,
                      totalSaved: totalSaved,
                      cancelledCount: cancelledSubs.length,
                      currencySymbol: Subscription.currencySymbol(
                        ref.watch(currencyProvider),
                      ),
                    ),
                  ),
                ),

              // ─── Compact Savings Counter ───
              if (cancelledSubs.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _CompactSavings(
                      totalSaved: totalSaved,
                      cancelledCount: cancelledSubs.length,
                      currencySymbol: Subscription.currencySymbol(
                        ref.watch(currencyProvider),
                      ),
                    ),
                  ),
                ),

              // ─── Smart Insights ───
              Builder(builder: (context) {
                final insights = ref.watch(insightsProvider);
                if (insights.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _InsightsCard(insights: insights),
                  ),
                );
              }),

              // ─── Trap Stats Card (Saved from Traps) ───
              const SliverToBoxAdapter(
                child: TrapStatsCard(),
              ),

              // ─── Category Bar ───
              if (activeSubs.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: CategoryBar(
                      subscriptions: activeSubs,
                      currencySymbol: Subscription.currencySymbol(
                        ref.watch(currencyProvider),
                      ),
                    ),
                  ),
                ),

              // ─── Trial Alert ───
              if (expiringTrials.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: _TrialAlertBanner(trials: expiringTrials),
                  ),
                ),

              // ─── AI Nudge Card ───
              if (ref.watch(nudgeProvider) != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NudgeCard(nudge: ref.watch(nudgeProvider)!),
                  ),
                ),

              // ─── Section: Active Subscriptions ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ACTIVE SUBSCRIPTIONS',
                        style: ChompdTypography.sectionLabel,
                      ),
                      Text(
                        '${activeSubs.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: ChompdColors.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Empty State or Subscription Cards ───
              if (activeSubs.isEmpty)
                const SliverToBoxAdapter(
                  child: EmptyState.noSubscriptions(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final sub = activeSubs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: AnimatedListItem(
                            index: index,
                            child: SubscriptionCard(
                              subscription: sub,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailScreen(subscription: sub),
                                  ),
                                );
                              },
                              onEdit: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddEditScreen(existingSub: sub),
                                  ),
                                );
                              },
                              onDelete: () {
                                _showDeleteDialog(context, sub);
                              },
                            ),
                          ),
                        );
                      },
                      childCount: activeSubs.length,
                    ),
                  ),
                ),

              // ─── Section: Cancelled — Money Saved ───
              if (cancelledSubs.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      children: [
                        Text(
                          'CANCELLED \u2014 MONEY SAVED',
                          style: ChompdTypography.sectionLabel,
                        ),
                        const Spacer(),
                        MoneySavedCounter(
                          amount: totalSaved,
                          currencySymbol: Subscription.currencySymbol(
                            ref.watch(currencyProvider),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cancelled = cancelledSubs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: AnimatedListItem(
                            index: index,
                            child: _CancelledCard(cancelled: cancelled),
                          ),
                        );
                      },
                      childCount: cancelledSubs.length,
                    ),
                  ),
                ),

                // ─── Milestone Track ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              const Text(
                                '\uD83C\uDFC6 ',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                'MILESTONES',
                                style: ChompdTypography.sectionLabel.copyWith(
                                  color: ChompdColors.mint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        MilestoneTrack(
                          totalSaved: totalSaved,
                          currencySymbol: Subscription.currencySymbol(
                            ref.watch(currencyProvider),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Bottom padding for FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),

          // ─── Floating Scan Button ───
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            right: 20,
            child: _ScanFab(
              onTap: () => _showAddOptions(context, ref),
            ),
          ),

          // ─── Confetti Overlay ───
          if (_showConfetti)
            Positioned.fill(
              child: ConfettiOverlay(
                onComplete: () {
                  if (mounted) setState(() => _showConfetti = false);
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic sub) {
    HapticService.instance.warning();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ChompdColors.bgElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Delete Subscription?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ChompdColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Remove ${sub.name} permanently?',
                style: const TextStyle(
                  fontSize: 13,
                  color: ChompdColors.textMid,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ChompdColors.border),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Keep',
                          style: TextStyle(
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
                      onTap: () {
                        ref
                            .read(subscriptionsProvider.notifier)
                            .remove(sub.uid);
                        HapticService.instance.success();
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: ChompdColors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ChompdColors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ChompdColors.red,
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
      ),
    );
  }
}

/// Trial expiry alert banner — amber themed.
class _TrialAlertBanner extends StatelessWidget {
  final List trials;

  const _TrialAlertBanner({required this.trials});

  @override
  Widget build(BuildContext context) {
    final urgentTrials = trials
        .where(
            (t) => t.trialDaysRemaining != null && t.trialDaysRemaining! <= 3)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ChompdColors.amberGlow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ChompdColors.amber.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Text(
            '\u26A0\uFE0F',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trials.length} trial${trials.length > 1 ? 's' : ''} expiring soon',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ChompdColors.amber,
                  ),
                ),
                if (urgentTrials.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${urgentTrials.map((t) => t.name).join(', ')} \u2014 ${urgentTrials.first.trialDaysRemaining} days left',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: ChompdColors.textDim,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cancelled subscription card with savings display — graveyard style.
class _CancelledCard extends StatelessWidget {
  final Subscription cancelled;

  const _CancelledCard({required this.cancelled});

  Color get _brandColor {
    if (cancelled.brandColor == null) return ChompdColors.textDim;
    final hex = cancelled.brandColor!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  int get _monthsSinceCancelled {
    if (cancelled.cancelledDate == null) return 0;
    return DateTime.now().difference(cancelled.cancelledDate!).inDays ~/ 30;
  }

  double get _saved => cancelled.monthlyEquivalent * _monthsSinceCancelled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ChompdColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ChompdColors.border),
      ),
      child: Opacity(
        opacity: 0.7,
        child: Row(
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _brandColor.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                cancelled.iconName ?? (cancelled.name.isNotEmpty ? cancelled.name[0] : '?'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _brandColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name + cancel date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cancelled.name,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: ChompdColors.textMid,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    _monthsSinceCancelled > 0
                        ? 'Cancelled ${_monthsSinceCancelled}mo ago'
                        : 'Just cancelled',
                    style: const TextStyle(
                      fontSize: 10,
                      color: ChompdColors.textDim,
                    ),
                  ),
                ],
              ),
            ),

            // Savings
            Text(
              '+${Subscription.currencySymbol(cancelled.currency)}${_saved.toStringAsFixed(0)}',
              style: ChompdTypography.mono(
                size: 13,
                weight: FontWeight.w700,
                color: ChompdColors.mint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact limit badge for the add-options bottom sheet.
class _LimitBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _LimitBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: ChompdTypography.mono(
            size: 18,
            weight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: ChompdColors.textDim,
          ),
        ),
      ],
    );
  }
}

/// Premium floating scan button — the app's primary action.
///
/// Design: 64px pill-shaped button with mint gradient, breathing glow,
/// specular highlight sweep, and camera icon.
/// Position: Bottom-right, 20px from edge, above safe area.
/// Interaction: Tap opens the add-options sheet (AI Scan / Quick Add).
class _ScanFab extends StatefulWidget {
  final VoidCallback onTap;
  const _ScanFab({required this.onTap});

  @override
  State<_ScanFab> createState() => _ScanFabState();
}

class _ScanFabState extends State<_ScanFab> with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _specularController;
  late AnimationController _tapController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    // Slow breathing glow — 3.5s cycle
    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    )..repeat();

    // Specular highlight sweep — 4s cycle
    _specularController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Tap scale feedback — 150ms
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _specularController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticService.instance.success();
    _tapController.forward().then((_) => _tapController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tapController,
      builder: (context, child) {
        final scale = 1.0 - (_tapController.value * 0.08);
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          _handleTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedBuilder(
          animation: _breatheController,
          builder: (context, child) {
            final breathe = math.sin(_breatheController.value * 2 * math.pi);
            final glowOpacity = 0.25 + (breathe * 0.5 + 0.5) * 0.2;
            final glowBlur = 20.0 + (breathe * 0.5 + 0.5) * 12;

            return Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ChompdColors.mintDark.withValues(alpha: _pressed ? 0.8 : 0.93),
                    ChompdColors.mint.withValues(alpha: _pressed ? 0.75 : 0.87),
                  ],
                ),
                boxShadow: [
                  // Breathing glow shadow
                  BoxShadow(
                    color: ChompdColors.mint.withValues(alpha: glowOpacity),
                    blurRadius: glowBlur,
                    offset: const Offset(0, 6),
                  ),
                  // Subtle dark shadow for depth
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Specular highlight sweep
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedBuilder(
                      animation: _specularController,
                      builder: (context, _) {
                        final sweepX = -64 * 0.3 +
                            (64 * 1.6) * _specularController.value;
                        return Transform.translate(
                          offset: Offset(sweepX, 0),
                          child: Transform.rotate(
                            angle: 25 * math.pi / 180,
                            child: Container(
                              width: 64 * 0.3,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0),
                                    Colors.white.withValues(alpha: 0.15),
                                    Colors.white.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Static specular highlight at top
                  Positioned(
                    top: 3,
                    left: 7,
                    right: 7,
                    height: 14,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.3),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Camera icon
                  const Center(
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 26,
                      color: Color(0xFF07070C),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// "Your subscriptions cost you £X,XXX/year" — the confronting truth.
///
/// Tappable share button. Shows monthly + daily breakdowns.
class _YearlyBurnBanner extends StatelessWidget {
  final double yearlyTotal;
  final int subCount;
  final double totalSaved;
  final int cancelledCount;
  final String currencySymbol;

  const _YearlyBurnBanner({
    required this.yearlyTotal,
    required this.subCount,
    required this.totalSaved,
    required this.cancelledCount,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final monthlyAvg = yearlyTotal / 12;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ChompdColors.purple.withValues(alpha: 0.08),
            ChompdColors.bgCard,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ChompdColors.purple.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'YEARLY BURN',
                style: ChompdTypography.sectionLabel.copyWith(
                  color: ChompdColors.purple,
                ),
              ),
              const Spacer(),
              // Share tap target
              GestureDetector(
                onTap: () {
                  ShareCardBuilder.shareYearlyBurn(
                    context: context,
                    yearlyTotal: yearlyTotal,
                    subCount: subCount,
                    totalSaved: totalSaved,
                    cancelledCount: cancelledCount,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ChompdColors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.share_outlined,
                        size: 12,
                        color: ChompdColors.purple,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Share',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: ChompdColors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // The big number
          Text(
            '$currencySymbol${yearlyTotal.toStringAsFixed(0)}',
            style: ChompdTypography.mono(
              size: 36,
              weight: FontWeight.w700,
              color: ChompdColors.text,
            ),
          ),
          const SizedBox(height: 4),

          // Context line
          Text(
            'per year across $subCount subscription${subCount == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 12,
              color: ChompdColors.textDim,
            ),
          ),
          const SizedBox(height: 8),

          // Monthly average + daily cost
          Row(
            children: [
              _BurnChip(
                label: 'monthly avg',
                value: '$currencySymbol${monthlyAvg.toStringAsFixed(0)}',
              ),
              const SizedBox(width: 8),
              _BurnChip(
                label: 'daily cost',
                value: '$currencySymbol${(yearlyTotal / 365).toStringAsFixed(2)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BurnChip extends StatelessWidget {
  final String label;
  final String value;
  const _BurnChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ChompdColors.bgElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: ChompdTypography.mono(
              size: 12,
              weight: FontWeight.w700,
              color: ChompdColors.purple,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: ChompdColors.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact savings banner — sits below Yearly Burn when cancelled subs exist.
///
/// "SAVED WITH CHOMPD — zł247 from 3 cancelled"
class _CompactSavings extends StatelessWidget {
  final double totalSaved;
  final int cancelledCount;
  final String currencySymbol;

  const _CompactSavings({
    required this.totalSaved,
    required this.cancelledCount,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ChompdColors.mint.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ChompdColors.mint.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Text(
            'SAVED WITH CHOMPD',
            style: ChompdTypography.sectionLabel.copyWith(
              color: ChompdColors.mint,
              fontSize: 9,
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 12, color: ChompdColors.mint.withValues(alpha: 0.2)),
          const SizedBox(width: 8),
          Text(
            '$currencySymbol${totalSaved.toStringAsFixed(0)}',
            style: ChompdTypography.mono(
              size: 14,
              weight: FontWeight.w700,
              color: ChompdColors.mint,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'from $cancelledCount cancelled',
            style: const TextStyle(
              fontSize: 11,
              color: ChompdColors.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rotating smart insights — one visible at a time, tappable to cycle.
class _InsightsCard extends StatefulWidget {
  final List<Insight> insights;
  const _InsightsCard({required this.insights});

  @override
  State<_InsightsCard> createState() => _InsightsCardState();
}

class _InsightsCardState extends State<_InsightsCard> {
  int _currentIndex = 0;

  void _next() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.insights.length;
    });
    HapticService.instance.light();
  }

  Color _colorForType(InsightType type) {
    switch (type) {
      case InsightType.saving:
        return ChompdColors.mint;
      case InsightType.warning:
        return ChompdColors.amber;
      case InsightType.info:
        return ChompdColors.blue;
      case InsightType.celebration:
        return ChompdColors.mint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final insight = widget.insights[_currentIndex];
    final color = _colorForType(insight.type);

    return GestureDetector(
      onTap: widget.insights.length > 1 ? _next : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ChompdColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: color, width: 3),
            top: const BorderSide(color: ChompdColors.border),
            right: const BorderSide(color: ChompdColors.border),
            bottom: const BorderSide(color: ChompdColors.border),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(insight.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      insight.message,
                      key: ValueKey(_currentIndex),
                      style: const TextStyle(
                        fontSize: 12,
                        color: ChompdColors.textMid,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (widget.insights.length > 1) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ...List.generate(
                          widget.insights.length,
                          (i) => Container(
                            margin: const EdgeInsets.only(right: 4),
                            width: i == _currentIndex ? 12 : 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: i == _currentIndex
                                  ? color
                                  : ChompdColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'tap for more',
                          style: TextStyle(
                            fontSize: 9,
                            color: ChompdColors.textDim,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

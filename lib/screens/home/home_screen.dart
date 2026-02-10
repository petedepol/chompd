import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../models/subscription.dart';
import '../../providers/nudge_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/subscriptions_provider.dart';
import '../../services/haptic_service.dart';
import '../../widgets/animated_list_item.dart';
import '../../widgets/bottom_nav_bar.dart';
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
import '../../providers/spend_view_provider.dart';
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
                      // Over budget piranha indicator
                      Consumer(
                        builder: (context, ref, _) {
                          final view = ref.watch(spendViewProvider);
                          final totalMonthly = ref.watch(monthlySpendProvider);
                          final totalYearly = ref.watch(yearlySpendProvider);
                          final budget = ref.watch(budgetProvider);
                          final isYearly = view == SpendView.yearly;
                          final displayAmount =
                              isYearly ? totalYearly : totalMonthly;
                          final displayBudget =
                              isYearly ? budget * 12 : budget;
                          final overBudget = displayAmount > displayBudget;

                          if (!overBudget) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const MascotImage(
                                  asset: 'piranha_sad.png',
                                  size: 32,
                                  fadeIn: true,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ouch. That\'s a lot of chomping.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        ChompdColors.red.withValues(alpha: 0.8),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Trap Stats Card (Saved from Traps) ───
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: TrapStatsCard(),
                ),
              ),

              // ─── Category Bar ───
              if (activeSubs.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: CategoryBar(subscriptions: activeSubs),
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
                        MoneySavedCounter(amount: totalSaved),
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
                        MilestoneTrack(totalSaved: totalSaved),
                      ],
                    ),
                  ),
                ),
              ],

              // Bottom padding for nav bar
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),

          // ─── Bottom Navigation Bar ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavBar(
              currentIndex: 0,
              onTap: (index) {
                HapticService.instance.selection();
              },
              onScanTap: () => _showAddOptions(context, ref),
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
              '+\u00A3${_saved.toStringAsFixed(0)}',
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

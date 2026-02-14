import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../utils/l10n_extension.dart';
import '../../models/subscription.dart';
import '../../providers/currency_provider.dart';
import '../../providers/insights_provider.dart';
import '../../providers/nudge_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/subscriptions_provider.dart';
import '../../widgets/share_card_builder.dart';
import '../../services/haptic_service.dart';
import '../../widgets/animated_list_item.dart';
import '../../widgets/annual_savings_card.dart';
import '../../widgets/category_bar.dart';
import '../../widgets/confetti_overlay.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/insight_card.dart';
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
  final Set<String> _dismissedCards = {};

  void _showAddOptions(BuildContext context, WidgetRef ref) {
    HapticService.instance.selection();
    final canAdd = ref.read(canAddSubProvider);
    final canScan = ref.read(canScanProvider);
    final remainingSubs = ref.read(remainingSubsProvider);
    final remainingScans = ref.read(remainingScansProvider);
    final isPro = ref.read(isProProvider);
    final c = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
        padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(ctx).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: c.bgElevated.withValues(alpha: 0.85),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: c.border,
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
                    color: c.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _LimitBadge(label: ctx.l10n.subsLeft, count: remainingSubs,
                        color: canAdd ? c.mint : c.red),
                      Container(width: 1, height: 20, color: c.border),
                      _LimitBadge(label: ctx.l10n.scansLeft, count: remainingScans,
                        color: canScan ? c.purple : c.red),
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
                        ? [c.purple, c.purple]
                        : [c.purple.withValues(alpha: 0.4),
                           c.purple.withValues(alpha: 0.4)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: c.purple.withValues(alpha: 0.27),
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
                    Text(canScan ? ctx.l10n.aiScanScreenshot : ctx.l10n.aiScanUpgradeToPro,
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
                        ? [c.mintDark, c.mint]
                        : [c.mintDark.withValues(alpha: 0.4),
                           c.mint.withValues(alpha: 0.4)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(canAdd ? Icons.add_rounded : Icons.lock_outline_rounded,
                      size: 16, color: c.bg),
                    const SizedBox(width: 8),
                    Text(canAdd ? ctx.l10n.quickAddManual : ctx.l10n.addSubUpgradeToPro,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.bg)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final subscriptions = ref.watch(subscriptionsProvider);
    final cancelledSubs = ref.watch(cancelledSubsProvider);
    final expiringTrials = ref.watch(expiringTrialsProvider);
    final totalSaved = ref.watch(totalSavedProvider);

    final activeSubs = subscriptions.where((s) => s.isActive).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      backgroundColor: c.bg,
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
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Chomp',
                                  style: TextStyle(
                                    color: c.text,
                                  ),
                                ),
                                TextSpan(
                                  text: 'd',
                                  style: TextStyle(
                                    color: c.mint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.l10n.homeStatusLine(activeSubs.length, cancelledSubs.length),
                            style: TextStyle(
                              fontSize: 11,
                              color: c.textMid,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Scan / Add button
                          GestureDetector(
                            onTap: () => _showAddOptions(context, ref),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: c.mint.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: c.mint.withValues(alpha: 0.25),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.camera_alt_rounded,
                                size: 18,
                                color: c.mint,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
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
                                color: c.bgElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: c.border),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.calendar_month_outlined,
                                size: 18,
                                color: c.textMid,
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
                                color: c.bgElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: c.border),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.settings_outlined,
                                size: 18,
                                color: c.textMid,
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
                          final c = context.colors;
                          final spend = ref.watch(monthlySpendProvider);
                          final budget = ref.watch(budgetProvider);
                          final pct = budget > 0 ? spend / budget : 0.0;

                          if (pct > 1.0) {
                            // Over budget — big sad piranha with red glow
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: c.red
                                              .withValues(alpha: 0.15),
                                          blurRadius: 24,
                                          spreadRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const MascotImage(
                                      asset: 'piranha_sad.png',
                                      size: 64,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    context.l10n.overBudgetMood,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: c.red
                                          .withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (pct < 0.5 && activeSubs.length >= 3) {
                            // Well under budget — happy piranha
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const MascotImage(
                                    asset: 'piranha_thumbsup.png',
                                    size: 48,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    context.l10n.underBudgetMood,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: c.mint
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
                      currencyCode: ref.watch(currencyProvider),
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
                      currencyCode: ref.watch(currencyProvider),
                    ),
                  ),
                ),

              // ─── Annual Savings Card ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: const AnnualSavingsCard(),
                ),
              ),

              // ─── Smart Insights ───
              Builder(builder: (context) {
                final c = context.colors;
                final insights = ref.watch(insightsProvider);
                if (insights.isEmpty || _dismissedCards.contains('insights')) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Dismissible(
                      key: const ValueKey('insights_dismiss'),
                      direction: DismissDirection.horizontal,
                      onDismissed: (_) {
                        HapticService.instance.light();
                        setState(() => _dismissedCards.add('insights'));
                      },
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: Icon(Icons.close_rounded, color: c.textDim, size: 20),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(Icons.close_rounded, color: c.textDim, size: 20),
                      ),
                      child: InsightCard(insights: insights),
                    ),
                  ),
                );
              }),

              // ─── Trap Stats Card (Saved from Traps) ───
              if (!_dismissedCards.contains('trap_stats'))
                SliverToBoxAdapter(
                  child: Dismissible(
                    key: const ValueKey('trap_stats_dismiss'),
                    direction: DismissDirection.horizontal,
                    onDismissed: (_) {
                      HapticService.instance.light();
                      setState(() => _dismissedCards.add('trap_stats'));
                    },
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: Icon(Icons.close_rounded, color: c.textDim, size: 20),
                    ),
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: Icon(Icons.close_rounded, color: c.textDim, size: 20),
                    ),
                    child: const TrapStatsCard(),
                  ),
                ),

              // ─── Category Bar ───
              if (activeSubs.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: CategoryBar(
                      subscriptions: activeSubs,
                      currencyCode: ref.watch(currencyProvider),
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
                        context.l10n.sectionActiveSubscriptions,
                        style: ChompdTypography.sectionLabel,
                      ),
                      Text(
                        '${activeSubs.length}',
                        style: TextStyle(
                          fontSize: 10,
                          color: c.textMid,
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
                          context.l10n.sectionCancelledSaved,
                          style: ChompdTypography.sectionLabel,
                        ),
                        const Spacer(),
                        MoneySavedCounter(
                          amount: totalSaved,
                          currencyCode: ref.watch(currencyProvider),
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
                                context.l10n.sectionMilestones,
                                style: ChompdTypography.sectionLabel.copyWith(
                                  color: c.mint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        MilestoneTrack(
                          totalSaved: totalSaved,
                          currencyCode: ref.watch(currencyProvider),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
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
    final c = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: c.bgElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ctx.l10n.deleteSubscriptionTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ctx.l10n.deleteSubscriptionMessage(sub.name),
                style: TextStyle(
                  fontSize: 13,
                  color: c.textMid,
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
                          border: Border.all(color: c.border),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          ctx.l10n.keep,
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
                          color: c.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: c.red.withValues(alpha: 0.3),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          ctx.l10n.delete,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: c.red,
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
    final c = context.colors;
    final urgentTrials = trials
        .where(
            (t) => t.trialDaysRemaining != null && t.trialDaysRemaining! <= 3)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.amberGlow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: c.amber.withValues(alpha: 0.2),
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
                  context.l10n.trialsExpiringSoon(trials.length),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.amber,
                  ),
                ),
                if (urgentTrials.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.trialDaysLeft(urgentTrials.map((t) => t.name).join(', '), urgentTrials.first.trialDaysRemaining),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: c.textDim,
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

  int get _monthsSinceCancelled {
    if (cancelled.cancelledDate == null) return 0;
    return DateTime.now().difference(cancelled.cancelledDate!).inDays ~/ 30;
  }

  double get _saved => cancelled.monthlyEquivalent * _monthsSinceCancelled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final brandColor = () {
      if (cancelled.brandColor == null) return c.textDim;
      final hex = cancelled.brandColor!.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    }();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
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
                color: brandColor.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                cancelled.iconName ?? (cancelled.name.isNotEmpty ? cancelled.name[0] : '?'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: brandColor,
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
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: c.textMid,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    _monthsSinceCancelled > 0
                        ? context.l10n.cancelledMonthsAgo(_monthsSinceCancelled)
                        : context.l10n.justCancelled,
                    style: TextStyle(
                      fontSize: 10,
                      color: c.textDim,
                    ),
                  ),
                ],
              ),
            ),

            // Savings
            Text(
              '+${Subscription.formatPrice(_saved, cancelled.currency, decimals: 0)}',
              style: ChompdTypography.mono(
                size: 13,
                weight: FontWeight.w700,
                color: c.mint,
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
    final c = context.colors;
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
          style: TextStyle(
            fontSize: 10,
            color: c.textDim,
          ),
        ),
      ],
    );
  }
}

/// "Your subscriptions cost you \u00a3X,XXX/year" \u2014 the confronting truth.
///
/// Tappable share button. Shows monthly + daily breakdowns.
class _YearlyBurnBanner extends StatelessWidget {
  final double yearlyTotal;
  final int subCount;
  final double totalSaved;
  final int cancelledCount;
  final String currencyCode;

  const _YearlyBurnBanner({
    required this.yearlyTotal,
    required this.subCount,
    required this.totalSaved,
    required this.cancelledCount,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final monthlyAvg = yearlyTotal / 12;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.purple.withValues(alpha: 0.08),
            c.bgCard,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: c.purple.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.sectionYearlyBurn,
                style: ChompdTypography.sectionLabel.copyWith(
                  color: c.purple,
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
                    currencySymbol: Subscription.currencySymbol(currencyCode),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: c.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.share_outlined,
                        size: 12,
                        color: c.purple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.share,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: c.purple,
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
            Subscription.formatPrice(yearlyTotal, currencyCode, decimals: 0),
            style: ChompdTypography.mono(
              size: 36,
              weight: FontWeight.w700,
              color: c.text,
            ),
          ),
          const SizedBox(height: 4),

          // Context line
          Text(
            context.l10n.perYearAcrossSubs(subCount),
            style: TextStyle(
              fontSize: 12,
              color: c.textDim,
            ),
          ),
          const SizedBox(height: 8),

          // Monthly average + daily cost
          Row(
            children: [
              _BurnChip(
                label: context.l10n.monthlyAvg,
                value: Subscription.formatPrice(monthlyAvg, currencyCode, decimals: 0),
              ),
              const SizedBox(width: 8),
              _BurnChip(
                label: context.l10n.dailyCost,
                value: Subscription.formatPrice(yearlyTotal / 365, currencyCode),
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
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.bgElevated,
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
              color: c.purple,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: c.textMid,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact savings banner — sits below Yearly Burn when cancelled subs exist.
///
/// "SAVED WITH CHOMPD \u2014 z\u0142247 from 3 cancelled"
class _CompactSavings extends StatelessWidget {
  final double totalSaved;
  final int cancelledCount;
  final String currencyCode;

  const _CompactSavings({
    required this.totalSaved,
    required this.cancelledCount,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.mint.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: c.mint.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Text(
            context.l10n.sectionSavedWithChompd,
            style: ChompdTypography.sectionLabel.copyWith(
              color: c.mint,
              fontSize: 9,
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 12, color: c.mint.withValues(alpha: 0.2)),
          const SizedBox(width: 8),
          Text(
            Subscription.formatPrice(totalSaved, currencyCode, decimals: 0),
            style: ChompdTypography.mono(
              size: 14,
              weight: FontWeight.w700,
              color: c.mint,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            context.l10n.fromCancelled(cancelledCount),
            style: TextStyle(
              fontSize: 11,
              color: c.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

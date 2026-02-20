import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/cancel_guide_v2.dart';
import '../../models/subscription.dart';
import '../../providers/notification_provider.dart';
import '../../providers/entitlement_provider.dart';
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

/// Subscription detail screen — premium visual overhaul.
///
/// Features: brand-colour ambient glow behind icon, animated price count-up,
/// visual payment timeline, fire-date reminders, polished detail rows,
/// and intentional action buttons.
class DetailScreen extends ConsumerStatefulWidget {
  final Subscription subscription;

  const DetailScreen({super.key, required this.subscription});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _priceController;
  late final Animation<double> _priceAnimation;

  static Color _parseHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  void initState() {
    super.initState();
    _priceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _priceAnimation = Tween<double>(begin: 0, end: widget.subscription.price)
        .animate(CurvedAnimation(parent: _priceController, curve: Curves.easeOut));
    _priceController.forward();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  /// Service description from the curated database.
  String? _serviceDescription(Subscription sub) {
    final id = sub.matchedServiceId;
    if (id == null) return null;
    final service = ref.read(serviceCacheProvider.notifier).findById(id);
    final desc = service?.description;
    return (desc != null && desc.isNotEmpty) ? desc : null;
  }

  /// Glow tier based on subscription price (quartile system).
  _GlowTier _glowTier(double price) {
    if (price >= 30) return _GlowTier.max;
    if (price >= 15) return _GlowTier.high;
    if (price >= 5) return _GlowTier.medium;
    return _GlowTier.low;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Watch for live updates
    final subs = ref.watch(subscriptionsProvider);
    final liveSub = subs.where((s) => s.uid == widget.subscription.uid).firstOrNull;
    final sub = liveSub ?? widget.subscription;

    final color = sub.brandColor != null
        ? _parseHex(sub.brandColor!)
        : c.mint;
    final daysLeft = sub.daysUntilRenewal;
    final renewalPct = (1 - (daysLeft / sub.cycle.approximateDays)).clamp(0.0, 1.0);
    final locale = Localizations.localeOf(context).languageCode;
    final tier = _glowTier(sub.price);

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
                  _PressableIconButton(
                    icon: Icons.edit_outlined,
                    onTap: () => _openEditForm(context, sub),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ─── Hero Card with Ambient Glow (2A) ───
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
                  border: Border.all(
                    color: tier.borderColor(c.mint),
                  ),
                  boxShadow: tier.boxShadow(c.mint),
                ),
                child: Column(
                  children: [
                    // Icon with ambient glow + Name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Ambient glow behind icon (2A.1)
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Radial glow
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      color.withValues(alpha: 0.25),
                                      Colors.transparent,
                                    ],
                                    radius: 0.7,
                                  ),
                                ),
                              ),
                              // Icon
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
                            ],
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: c.text,
                                ),
                              ),
                              const SizedBox(height: 3),
                              // Description punchline (from service DB) or category fallback
                              Builder(builder: (context) {
                                final desc = _serviceDescription(sub);
                                return Text(
                                  desc ?? AppConstants.localisedCategory(sub.category, context.l10n),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: c.textMid,
                                  ),
                                );
                              }),
                              // AI Scan provenance badge (2A.3)
                              if (sub.source == SubscriptionSource.aiScan) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: c.mint.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '✨ ${context.l10n.sourceAiScan}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: c.mint,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Animated price (2A.2)
                    AnimatedBuilder(
                      animation: _priceAnimation,
                      builder: (context, _) => RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: Subscription.formatPrice(
                                _priceAnimation.value,
                                sub.currency,
                              ),
                              style: ChompdTypography.mono(
                                size: 32,
                                weight: FontWeight.w700,
                                color: c.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub.cycle.localLabel(context.l10n),
                      style: TextStyle(
                        fontSize: 14,
                        color: c.textMid,
                      ),
                    ),

                    // Annual cost reframe
                    if (sub.cycle != BillingCycle.yearly) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            color: sub.yearlyEquivalent > 100 ? c.amber : c.textMid,
                          ),
                        ),
                      ),
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

                    // Trial badge
                    if (sub.isTrial && sub.trialDaysRemaining != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: c.amberGlow,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: c.amber.withValues(alpha: 0.27)),
                        ),
                        child: Text(
                          sub.trialDaysRemaining! <= 0
                              ? context.l10n.trialExpired
                              : (sub.trialPrice != null && sub.trialPrice! > 0)
                                  ? context.l10n.introPriceDaysRemaining(sub.trialDaysRemaining!)
                                  : context.l10n.trialDaysRemaining(sub.trialDaysRemaining!),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: c.amber,
                          ),
                        ),
                      ),
                    ],

                    // Cancelled status banner
                    if (sub.cancelledDate != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: c.red.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: c.red.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          sub.nextRenewal.isBefore(DateTime.now())
                              ? context.l10n.cancelledStatusExpired(
                                  DateHelpers.shortDate(sub.nextRenewal, locale: locale),
                                )
                              : context.l10n.cancelledStatusExpires(
                                  DateHelpers.shortDate(sub.nextRenewal, locale: locale),
                                ),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: c.red,
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
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
                child: _TrapInfoCard(subscription: sub),
              ),
            ),

          // ─── Unmatched Service Banner ───
          if (!sub.isMatched)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
                child: _UnmatchedInfoBanner(),
              ),
            ),

          // ─── Renewal Countdown (hide for cancelled subs) ───
          if (sub.isActive)
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
                            DateHelpers.shortDate(sub.nextRenewal, locale: locale),
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

          if (sub.isActive) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ─── Reminders with Fire Dates (2D) ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _RemindersCard(
                  subscriptionUid: sub.uid,
                  nextRenewal: sub.nextRenewal,
                  ref: ref,
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ─── Reactivate Button (cancelled subs only) ───
          if (sub.cancelledDate != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _PressableButton(
                  onTap: () {
                    HapticService.instance.success();
                    ref.read(subscriptionsProvider.notifier).reactivate(sub.uid);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: c.mint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.mint.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      context.l10n.reactivateSubscription,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.mint,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ─── Payment History Timeline (2C) ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _PaymentTimeline(subscription: sub),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ─── Details Section (2F) ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _InfoCard(
                label: context.l10n.sectionDetails,
                child: Column(
                  children: [
                    _DetailRow(
                      label: context.l10n.detailCategory,
                      value: AppConstants.localisedCategory(sub.category, context.l10n),
                      dotColor: CategoryColors.forCategory(sub.category),
                    ),
                    _thinDivider(),
                    _DetailRow(
                      label: context.l10n.detailCurrency,
                      value: sub.currency,
                    ),
                    _thinDivider(),
                    _DetailRow(
                      label: context.l10n.detailBillingCycle,
                      value: sub.cycle.localLabel(context.l10n),
                    ),
                    _thinDivider(),
                    _DetailRow(
                      label: context.l10n.detailAdded,
                      value: DateHelpers.shortDate(sub.createdAt, locale: locale),
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
            if (sub.cycle == BillingCycle.yearly) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            final bestTier = cacheNotifier.findBestTier(sub, service, sub.currency);
            if (bestTier == null) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            var pair = cacheNotifier.resolvePricePair(bestTier, service, sub.currency);
            pair ??= cacheNotifier.resolveAnnualFromAlternateTiers(service, sub.currency);
            if (pair == null) {
              // No annual pricing — hide section entirely (2E rule)
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            final userMonthly = sub.monthlyEquivalentIn(sub.currency);
            final savings = (userMonthly * 12) - pair.annual;
            if (savings <= 0) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: c.mint.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: c.mint.withValues(alpha: 0.15),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.savings_outlined, size: 16, color: c.mint),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.annualPlanAvailable(
                            Subscription.formatPrice(savings, sub.currency),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: c.mint,
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

          // ─── Action Buttons (2G) ───
          // Cancel subscription button (constructive first)
          if (sub.isActive)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _PressableButton(
                  onTap: () => _navigateToCancelGuide(context, sub),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.open_in_new_rounded, size: 14, color: c.mint),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.cancelSubscription,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: c.mint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Spacer
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Delete button (destructive, de-emphasized)
          SliverToBoxAdapter(
            child: Center(
              child: _PressableButton(
                onTap: () => _showDeleteDialog(context, sub),
                child: Text(
                  context.l10n.delete,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFFF453A),
                  ),
                ),
              ),
            ),
          ),

          // Bottom padding (2G.4)
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 40,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _thinDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.white.withValues(alpha: 0.06),
    );
  }

  void _openEditForm(BuildContext context, Subscription sub) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditScreen(existingSub: sub)),
    );
  }

  void _navigateToCancelGuide(BuildContext context, Subscription sub) {
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

    if (allGuides.length == 1) {
      openGuide(allGuides.first);
      return;
    }
    if (allGuides.length > 1) {
      _showPlatformPicker(context, sub, allGuides, difficulty);
      return;
    }
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
      return switch (platform) {
        'ios' => context.l10n.cancelPlatformIos,
        'android' => context.l10n.cancelPlatformAndroid,
        'web' => context.l10n.cancelPlatformWeb,
        _ => platform,
      };
    }

    IconData platformIcon(String platform) {
      return switch (platform) {
        'ios' => Icons.apple,
        'android' => Icons.android,
        'web' => Icons.language,
        _ => Icons.help_outline,
      };
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: c.bgElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: c.border),
                        ),
                        child: Row(
                          children: [
                            Icon(platformIcon(guide.platform), size: 22, color: c.text),
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
                            Icon(Icons.chevron_right_rounded, size: 18, color: c.textDim),
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

  /// Glassmorphic delete confirmation dialog (2G.3)
  void _showDeleteDialog(BuildContext context, Subscription sub) {
    final c = context.colors;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: _ConfirmDialog(
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
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Glow Tier System (2A.4)
// ═══════════════════════════════════════════════════════════════════

enum _GlowTier { low, medium, high, max }

extension _GlowTierExt on _GlowTier {
  Color borderColor(Color mint) {
    return switch (this) {
      _GlowTier.low => mint.withValues(alpha: 0.15),
      _GlowTier.medium => mint.withValues(alpha: 0.30),
      _GlowTier.high => mint.withValues(alpha: 0.50),
      _GlowTier.max => mint.withValues(alpha: 0.70),
    };
  }

  List<BoxShadow>? boxShadow(Color mint) {
    return switch (this) {
      _GlowTier.low => null,
      _GlowTier.medium => [BoxShadow(color: mint.withValues(alpha: 0.10), blurRadius: 6)],
      _GlowTier.high => [BoxShadow(color: mint.withValues(alpha: 0.18), blurRadius: 12)],
      _GlowTier.max => [BoxShadow(color: mint.withValues(alpha: 0.28), blurRadius: 20)],
    };
  }
}

// ═══════════════════════════════════════════════════════════════════
// Payment History Visual Timeline (2C)
// ═══════════════════════════════════════════════════════════════════

class _PaymentTimeline extends StatelessWidget {
  final Subscription subscription;
  const _PaymentTimeline({required this.subscription});

  static DateTime _subtractCycle(DateTime date, BillingCycle cycle) {
    return switch (cycle) {
      BillingCycle.weekly => date.subtract(const Duration(days: 7)),
      BillingCycle.monthly => DateTime(date.year, date.month - 1, date.day),
      BillingCycle.quarterly => DateTime(date.year, date.month - 3, date.day),
      BillingCycle.yearly => DateTime(date.year - 1, date.month, date.day),
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sub = subscription;
    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();

    // Collect past payments
    final payments = <DateTime>[];
    DateTime cursor = _subtractCycle(sub.nextRenewal, sub.cycle);
    while (!cursor.isBefore(sub.createdAt) && payments.length < 12) {
      if (!cursor.isAfter(now)) payments.add(cursor);
      cursor = _subtractCycle(cursor, sub.cycle);
    }

    final pastCount = payments.length;

    return _InfoCard(
      label: context.l10n.sectionPaymentHistory,
      child: Column(
        children: [
          if (payments.isEmpty) ...[
            // Empty state (2C.4)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 28, color: c.textDim.withValues(alpha: 0.4)),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.noPaymentsYet(DateHelpers.shortDate(sub.createdAt, locale: locale)),
                    style: TextStyle(fontSize: 12, color: c.textDim),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Past payments with timeline
            ...payments.asMap().entries.map((entry) {
              final date = entry.value;
              return _TimelineRow(
                dotColor: c.mint.withValues(alpha: 0.7),
                dotSize: 8,
                isLast: entry.key == payments.length - 1 && true, // not last if upcoming follows
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateHelpers.shortDate(date, locale: locale),
                      style: TextStyle(fontSize: 13, color: c.textMid),
                    ),
                    Text(
                      Subscription.formatPrice(sub.price, sub.currency),
                      style: ChompdTypography.mono(size: 13, weight: FontWeight.w700, color: c.text),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Upcoming payment — glowing dot
          _TimelineRow(
            dotColor: c.mint,
            dotSize: 10,
            hasGlow: true,
            isLast: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      DateHelpers.shortDate(sub.nextRenewal, locale: locale),
                      style: TextStyle(fontSize: 13, color: c.textDim),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: c.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        context.l10n.upcoming,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: c.amber),
                      ),
                    ),
                  ],
                ),
                Text(
                  Subscription.formatPrice(sub.price, sub.currency),
                  style: ChompdTypography.mono(size: 13, color: c.textDim),
                ),
              ],
            ),
          ),

          // Total paid
          if (pastCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.totalPaid,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.textMid),
                  ),
                  Text(
                    Subscription.formatPrice(sub.price * pastCount, sub.currency),
                    style: ChompdTypography.mono(size: 13, weight: FontWeight.w700, color: c.mint),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Single row in the payment timeline with a dot on the left.
class _TimelineRow extends StatelessWidget {
  final Color dotColor;
  final double dotSize;
  final bool hasGlow;
  final bool isLast;
  final Widget child;

  const _TimelineRow({
    required this.dotColor,
    this.dotSize = 8,
    this.hasGlow = false,
    this.isLast = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: 4),
                // Dot
                Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    boxShadow: hasGlow
                        ? [BoxShadow(color: dotColor.withValues(alpha: 0.25), blurRadius: 6)]
                        : null,
                  ),
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Shared Widgets
// ═══════════════════════════════════════════════════════════════════

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
        child: Icon(Icons.arrow_back_rounded, size: 16, color: c.textMid),
      ),
    );
  }
}

/// Icon button with press feedback (2H.2)
class _PressableIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PressableIconButton({required this.icon, required this.onTap});

  @override
  State<_PressableIconButton> createState() => _PressableIconButtonState();
}

class _PressableIconButtonState extends State<_PressableIconButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: c.bgElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.border),
          ),
          alignment: Alignment.center,
          child: Icon(widget.icon, size: 16, color: c.textMid),
        ),
      ),
    );
  }
}

/// Generic pressable wrapper with scale feedback (2H.2)
class _PressableButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  const _PressableButton({required this.onTap, required this.child});

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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

// ═══════════════════════════════════════════════════════════════════
// Reminders Card with Fire Dates (2D)
// ═══════════════════════════════════════════════════════════════════

class _RemindersCard extends StatelessWidget {
  final String subscriptionUid;
  final DateTime nextRenewal;
  final WidgetRef ref;

  const _RemindersCard({
    required this.subscriptionUid,
    required this.nextRenewal,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final locale = Localizations.localeOf(context).languageCode;
    final prefs = ref.watch(notificationPrefsProvider);
    final subs = ref.watch(subscriptionsProvider);
    final sub = subs.where((s) => s.uid == subscriptionUid).firstOrNull;
    final scheduled = NotificationService.instance.getForSubscription(subscriptionUid);
    final ent = ref.watch(entitlementProvider);
    final hasSmartReminders = ent.hasSmartReminders;

    final hasCustom = sub != null && sub.reminders.isNotEmpty;
    bool isDayEnabled(int day) {
      if (hasCustom) {
        return sub.reminders.any((r) => r.daysBefore == day && r.enabled);
      }
      return prefs.renewalRemindersEnabled && prefs.activeReminderDays.contains(day);
    }

    /// Calculate the concrete fire date for a reminder offset.
    String fireDate(int daysBefore) {
      final date = nextRenewal.subtract(Duration(days: daysBefore));
      return DateHelpers.shortDate(date, locale: locale);
    }

    return _InfoCard(
      label: '🔔  ${context.l10n.sectionReminders}',
      child: Column(
        children: [
          if (scheduled.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.schedule_outlined, size: 13, color: c.mint),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.remindersScheduled(scheduled.length),
                    style: TextStyle(fontSize: 10.5, color: c.mint),
                  ),
                ],
              ),
            ),

          _ReminderRow(
            label: context.l10n.reminderDaysBefore7,
            fireDate: fireDate(7),
            enabled: isDayEnabled(7),
            showProBadge: !hasSmartReminders,
            isLocked: !hasSmartReminders,
            onChanged: hasSmartReminders ? (_) {
              ref.read(subscriptionsProvider.notifier).toggleReminderDay(subscriptionUid, 7);
              HapticService.instance.selection();
            } : null,
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
          _ReminderRow(
            label: context.l10n.reminderDaysBefore3,
            fireDate: fireDate(3),
            enabled: isDayEnabled(3),
            showProBadge: !hasSmartReminders,
            isLocked: !hasSmartReminders,
            onChanged: hasSmartReminders ? (_) {
              ref.read(subscriptionsProvider.notifier).toggleReminderDay(subscriptionUid, 3);
              HapticService.instance.selection();
            } : null,
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
          _ReminderRow(
            label: context.l10n.reminderDaysBefore1,
            fireDate: fireDate(1),
            enabled: isDayEnabled(1),
            showProBadge: !hasSmartReminders,
            isLocked: !hasSmartReminders,
            onChanged: hasSmartReminders ? (_) {
              ref.read(subscriptionsProvider.notifier).toggleReminderDay(subscriptionUid, 1);
              HapticService.instance.selection();
            } : null,
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
          _ReminderRow(
            label: context.l10n.reminderMorningOf,
            fireDate: fireDate(0),
            enabled: isDayEnabled(0),
            showProBadge: false,
            isLocked: false,
            onChanged: (_) {
              ref.read(subscriptionsProvider.notifier).toggleReminderDay(subscriptionUid, 0);
              HapticService.instance.selection();
            },
          ),

          if (!hasSmartReminders) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => showPaywall(
                context,
                trigger: PaywallTrigger.reminderUpgrade,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: c.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 12, color: c.purple),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.l10n.upgradeForReminders,
                        style: TextStyle(fontSize: 10, color: c.purple),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 10, color: c.purple),
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

/// Reminder row with fire date display (2D.2)
class _ReminderRow extends StatelessWidget {
  final String label;
  final String? fireDate;
  final bool enabled;
  final bool showProBadge;
  final bool isLocked;
  final ValueChanged<bool>? onChanged;

  const _ReminderRow({
    required this.label,
    this.fireDate,
    required this.enabled,
    required this.showProBadge,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: enabled ? c.text : c.textDim,
                    ),
                  ),
                  // Fire date (2D.2)
                  if (fireDate != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      fireDate!,
                      style: TextStyle(fontSize: 11, color: c.textDim),
                    ),
                  ],
                ],
              ),
            ),
            if (showProBadge)
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
              Icon(Icons.lock_outline_rounded, size: 14, color: c.textDim)
            else
              Container(
                width: 36,
                height: 20,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: enabled ? c.mint : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
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

// ═══════════════════════════════════════════════════════════════════
// Detail Row (2F)
// ═══════════════════════════════════════════════════════════════════

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? dotColor;
  const _DetailRow({required this.label, required this.value, this.dotColor});

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
            style: TextStyle(fontSize: 13, color: c.textMid),
          ),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category dot (2F.4)
                if (dotColor != null) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dotColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: c.text,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Confirm Dialog with glassmorphic overlay (2G.3)
// ═══════════════════════════════════════════════════════════════════

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
                        border: Border.all(color: confirmColor.withValues(alpha: 0.3)),
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

// ═══════════════════════════════════════════════════════════════════
// Trap Info Card (preserved from original)
// ═══════════════════════════════════════════════════════════════════

class _TrapInfoCard extends StatelessWidget {
  final Subscription subscription;
  const _TrapInfoCard({required this.subscription});

  String _trapTypeLabel(BuildContext context) {
    return switch (subscription.trapType) {
      'trialBait' => context.l10n.trapTypeTrialBait,
      'priceFraming' => context.l10n.trapTypePriceFraming,
      'hiddenRenewal' => context.l10n.trapTypeHiddenRenewal,
      'cancelFriction' => context.l10n.trapTypeCancelFriction,
      _ => context.l10n.trapTypeGeneric,
    };
  }

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
    final locale = Localizations.localeOf(context).languageCode;
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
          Row(
            children: [
              Icon(Icons.warning_rounded, size: 16, color: warningColor),
              const SizedBox(width: 6),
              const MascotImage(asset: 'piranha_alert.png', size: 28),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: c.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  _trapTypeLabel(context),
                  style: ChompdTypography.mono(size: 10, weight: FontWeight.w600, color: c.purple),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _severityExplanation(context),
                  style: TextStyle(fontSize: 11, color: c.textDim),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (subscription.trapWarningMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: c.mintGlow, width: 3)),
              ),
              child: Text(
                subscription.trapWarningMessage!,
                style: TextStyle(fontSize: 13, color: c.textMid, height: 1.5),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (subscription.trialPrice != null && subscription.realPrice != null)
            Row(
              children: [
                Text(
                  Subscription.formatPrice(subscription.trialPrice!, subscription.currency),
                  style: ChompdTypography.mono(size: 16, color: c.textDim)
                      .copyWith(decoration: TextDecoration.lineThrough),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 14, color: warningColor),
                const SizedBox(width: 8),
                Text(
                  Subscription.formatPrice(subscription.realPrice!, subscription.currency),
                  style: ChompdTypography.mono(size: 16, weight: FontWeight.w700, color: warningColor),
                ),
              ],
            ),
          if (subscription.trialExpiresAt != null) ...[
            const SizedBox(height: 8),
            Text(
              (subscription.trialPrice != null && subscription.trialPrice! > 0)
                  ? context.l10n.introPriceExpires(DateHelpers.shortDate(subscription.trialExpiresAt!, locale: locale))
                  : context.l10n.trialExpires(DateHelpers.shortDate(subscription.trialExpiresAt!, locale: locale)),
              style: TextStyle(fontSize: 12, color: warningColor),
            ),
          ],
          if (subscription.realAnnualCost != null) ...[
            const SizedBox(height: 4),
            Text(
              context.l10n.realAnnualCost(Subscription.formatPrice(subscription.realAnnualCost!, subscription.currency)),
              style: TextStyle(fontSize: 11, color: c.textDim),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Unmatched Info Banner (preserved from original)
// ═══════════════════════════════════════════════════════════════════

class _UnmatchedInfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.blue.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: c.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'We don\'t have specific data for this service yet. Cancel and refund guides show general steps for your platform.',
              style: TextStyle(fontSize: 12, color: c.textMid, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

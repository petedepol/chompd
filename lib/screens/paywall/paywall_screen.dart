import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/subscription.dart';
import '../../providers/notification_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../services/purchase_service.dart';
import '../../utils/l10n_extension.dart';

/// Paywall screen — "Sell without sleaze."
///
/// Design principles from the trends doc:
/// - Blurred background (the screen they came from)
/// - 6 feature list with icons
/// - Price card with gradient glow
/// - Tagline: "A subscription tracker that isn't a subscription."
/// - No countdown timers, no fake urgency, no comparison tables
class PaywallScreen extends ConsumerStatefulWidget {
  /// What triggered the paywall (for messaging).
  final PaywallTrigger trigger;

  const PaywallScreen({
    super.key,
    this.trigger = PaywallTrigger.manual,
  });

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _purchasing = false;
  bool _restoring = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  String _triggerMessage(BuildContext context) {
    switch (widget.trigger) {
      case PaywallTrigger.subscriptionLimit:
        return context.l10n.paywallLimitSubs(AppConstants.freeMaxSubscriptions);
      case PaywallTrigger.scanLimit:
        return context.l10n.paywallLimitScans;
      case PaywallTrigger.reminderUpgrade:
        return context.l10n.paywallLimitReminders;
      case PaywallTrigger.settingsUpgrade:
        return context.l10n.paywallGeneric;
      case PaywallTrigger.trialExpired:
        return context.l10n.paywallGeneric;
      case PaywallTrigger.manual:
        return context.l10n.paywallGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final purchaseState = ref.watch(purchaseProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // If purchase succeeded, auto-close
    if (purchaseState == PurchaseState.pro) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Update notification prefs to Pro
        ref.read(notificationPrefsProvider.notifier).setProStatus(true);
        Navigator.of(context).pop(true);
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: c.bg.withValues(alpha: 0.85),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Close button — stays fixed at top
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c.bgElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: c.border),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: c.textMid,
                        ),
                      ),
                    ),
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: bottomPadding + 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),

                        // ─── Pro Badge ───
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                c.mintDark,
                                c.mint,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: c.mint.withValues(alpha: 0.3),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 32,
                            color: c.bg,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ─── Title ───
                        Text(
                          context.l10n.chompdPro,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: c.text,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ─── Tagline ───
                        Text(
                          context.l10n.paywallTagline,
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: c.textMid,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Trigger-specific message
                        Text(
                          _triggerMessage(context),
                          style: TextStyle(
                            fontSize: 12,
                            color: c.textDim,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ─── Feature List ───
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              _FeatureRow(
                                icon: Icons.savings_outlined,
                                text: context.l10n.paywallFeature1,
                              ),
                              const SizedBox(height: 14),
                              _FeatureRow(
                                icon: Icons.timer_off_outlined,
                                text: context.l10n.paywallFeature2,
                              ),
                              const SizedBox(height: 14),
                              _FeatureRow(
                                icon: Icons.auto_awesome,
                                text: context.l10n.paywallFeature3,
                              ),
                              const SizedBox(height: 14),
                              _FeatureRow(
                                icon: Icons.all_inclusive_rounded,
                                text: context.l10n.paywallFeature4,
                              ),
                              const SizedBox(height: 14),
                              _FeatureRow(
                                icon: Icons.notifications_active_outlined,
                                text: context.l10n.paywallFeature5,
                              ),
                              const SizedBox(height: 14),
                              _FeatureRow(
                                icon: Icons.share_outlined,
                                text: context.l10n.paywallFeature6,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ─── Savings Context ───
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            bottom: 16,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: c.mint.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: c.mint.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Text(
                              context.l10n.paywallContext,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: c.mint,
                              ),
                            ),
                          ),
                        ),

                        // ─── Price Card ───
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: c.bgCard,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: c.mint.withValues(alpha:
                                      0.2 + _glowController.value * 0.15,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: c.mint.withValues(alpha:
                                        0.08 + _glowController.value * 0.08,
                                      ),
                                      blurRadius:
                                          16 + _glowController.value * 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          Subscription.formatPrice(AppConstants.proPrice, AppConstants.proCurrency),
                                          style: ChompdTypography.mono(
                                            size: 28,
                                            weight: FontWeight.w700,
                                            color: c.mint,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          context.l10n.oneTimePayment,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: c.textDim,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            c.mint.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        context.l10n.lifetime,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: c.mint,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ─── Purchase Button ───
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GestureDetector(
                            onTap: _purchasing ? null : _handlePurchase,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: _purchasing
                                      ? [
                                          c.mintDark
                                              .withValues(alpha: 0.5),
                                          c.mint.withValues(alpha: 0.5),
                                        ]
                                      : [
                                          c.mintDark,
                                          c.mint,
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        c.mint.withValues(alpha: 0.27),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: _purchasing
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          c.bg,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      context.l10n.unlockChompdPro,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: c.bg,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ─── Restore Purchase ───
                        GestureDetector(
                          onTap: _restoring ? null : _handleRestore,
                          child: Text(
                            _restoring
                                ? context.l10n.restoring
                                : context.l10n.restorePurchase,
                            style: TextStyle(
                              fontSize: 12,
                              color: c.textDim,
                            ),
                          ),
                        ),

                        // Error message
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontSize: 11,
                              color: c.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase() async {
    setState(() {
      _purchasing = true;
      _errorMessage = null;
    });

    final success =
        await ref.read(purchaseProvider.notifier).purchasePro();

    if (mounted) {
      setState(() => _purchasing = false);
      if (!success) {
        setState(() =>
            _errorMessage = context.l10n.purchaseError);
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() {
      _restoring = true;
      _errorMessage = null;
    });

    final success =
        await ref.read(purchaseProvider.notifier).restorePurchase();

    if (mounted) {
      setState(() => _restoring = false);
      if (!success) {
        setState(
            () => _errorMessage = context.l10n.noPreviousPurchase);
      }
    }
  }
}

// ─── Feature Row ───

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: c.mint.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 14,
            color: c.mint,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: c.text,
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper to show the paywall as a full-screen modal.
///
/// Returns true if the user purchased Pro, false otherwise.
Future<bool> showPaywall(
  BuildContext context, {
  PaywallTrigger trigger = PaywallTrigger.manual,
}) async {
  final result = await Navigator.of(context).push<bool>(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => PaywallScreen(trigger: trigger),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
    ),
  );
  return result ?? false;
}

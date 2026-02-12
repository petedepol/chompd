import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../providers/notification_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../services/purchase_service.dart';

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

  String get _triggerMessage {
    switch (widget.trigger) {
      case PaywallTrigger.subscriptionLimit:
        return 'You\'ve hit the free limit of ${AppConstants.freeMaxSubscriptions} subscriptions.';
      case PaywallTrigger.scanLimit:
        return 'You\'ve used all ${AppConstants.freeMaxScans} free AI scans.';
      case PaywallTrigger.reminderUpgrade:
        return 'Advance reminders are a Pro feature.';
      case PaywallTrigger.settingsUpgrade:
        return 'Unlock the full Chompd experience.';
      case PaywallTrigger.manual:
        return 'Unlock the full Chompd experience.';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                color: ChompdColors.bg.withValues(alpha: 0.85),
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
                          color: ChompdColors.bgElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: ChompdColors.border),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: ChompdColors.textMid,
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
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                ChompdColors.mintDark,
                                ChompdColors.mint,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ChompdColors.mint.withValues(alpha: 0.3),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 32,
                            color: ChompdColors.bg,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ─── Title ───
                        const Text(
                          'Chompd Pro',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: ChompdColors.text,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ─── Tagline ───
                        const Text(
                          'A subscription tracker that isn\'t a subscription.',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: ChompdColors.textMid,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Trigger-specific message
                        Text(
                          _triggerMessage,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ChompdColors.textDim,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ─── Feature List ───
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: const [
                              _FeatureRow(
                                icon: Icons.savings_outlined,
                                text: 'Save \u00A3100\u2013\u00A3500/year on hidden waste',
                              ),
                              SizedBox(height: 14),
                              _FeatureRow(
                                icon: Icons.timer_off_outlined,
                                text: 'Never miss a trial expiry again',
                              ),
                              SizedBox(height: 14),
                              _FeatureRow(
                                icon: Icons.auto_awesome,
                                text: 'Unlimited AI trap scanning',
                              ),
                              SizedBox(height: 14),
                              _FeatureRow(
                                icon: Icons.all_inclusive_rounded,
                                text: 'Track every subscription you have',
                              ),
                              SizedBox(height: 14),
                              _FeatureRow(
                                icon: Icons.notifications_active_outlined,
                                text: 'Early warnings: 7d, 3d, 1d before charges',
                              ),
                              SizedBox(height: 14),
                              _FeatureRow(
                                icon: Icons.share_outlined,
                                text: 'Shareable savings cards',
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
                              color: ChompdColors.mint.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: ChompdColors.mint.withValues(alpha: 0.12),
                              ),
                            ),
                            child: const Text(
                              'Pays for itself after cancelling just one forgotten subscription.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: ChompdColors.mint,
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
                                  color: ChompdColors.bgCard,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: ChompdColors.mint.withValues(alpha:
                                      0.2 + _glowController.value * 0.15,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ChompdColors.mint.withValues(alpha:
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
                                          '\u00A3${AppConstants.proPrice.toStringAsFixed(2)}',
                                          style: ChompdTypography.mono(
                                            size: 28,
                                            weight: FontWeight.w700,
                                            color: ChompdColors.mint,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'One-time payment. Forever.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: ChompdColors.textDim,
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
                                            ChompdColors.mint.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'LIFETIME',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: ChompdColors.mint,
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
                                          ChompdColors.mintDark
                                              .withValues(alpha: 0.5),
                                          ChompdColors.mint.withValues(alpha: 0.5),
                                        ]
                                      : [
                                          ChompdColors.mintDark,
                                          ChompdColors.mint,
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        ChompdColors.mint.withValues(alpha: 0.27),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: _purchasing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          ChompdColors.bg,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Unlock Chompd Pro',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: ChompdColors.bg,
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
                                ? 'Restoring...'
                                : 'Restore Purchase',
                            style: const TextStyle(
                              fontSize: 12,
                              color: ChompdColors.textDim,
                            ),
                          ),
                        ),

                        // Error message
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: ChompdColors.red,
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
            _errorMessage = 'Purchase could not be completed. Try again.');
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
            () => _errorMessage = 'No previous purchase found.');
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
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: ChompdColors.mint.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 14,
            color: ChompdColors.mint,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: ChompdColors.text,
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

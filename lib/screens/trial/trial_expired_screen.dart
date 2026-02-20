import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/theme.dart';
import '../../utils/l10n_extension.dart';
import '../../providers/currency_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/subscriptions_provider.dart';
import '../../models/subscription.dart';
import '../../services/haptic_service.dart';
import '../../widgets/mascot_image.dart';
import '../paywall/paywall_screen.dart';

const _kTrialExpiredShownKey = 'trial_expired_shown';

/// Whether the expired screen has already been shown.
Future<bool> hasTrialExpiredBeenShown() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kTrialExpiredShownKey) ?? false;
}

/// Mark the expired screen as shown.
Future<void> markTrialExpiredShown() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kTrialExpiredShownKey, true);
}

/// Full-screen modal shown once when the trial expires.
///
/// Shows real user stats and a CTA to unlock Pro or continue free.
class TrialExpiredScreen extends ConsumerWidget {
  const TrialExpiredScreen({super.key});

  /// Show the trial expired screen as a modal dialog.
  static Future<void> show(BuildContext context) async {
    await markTrialExpiredShown();
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => const TrialExpiredScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final subs = ref.watch(subscriptionsProvider);
    final currency = ref.watch(currencyProvider);
    final frozen = ref.watch(frozenSubsProvider);
    final activeSubs = subs.where((s) => s.isActive).toList();
    final monthlySpend = ref.watch(monthlySpendProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: c.bgElevated.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: c.red.withValues(alpha: 0.2),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sad mascot
                  const MascotImage(
                    asset: 'piranha_sad.png',
                    size: 90,
                    fadeIn: true,
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    l.trialExpiredTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Stats subtitle
                  Text(
                    l.trialExpiredSubtitle(
                      activeSubs.length,
                      Subscription.formatPrice(monthlySpend, currency),
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      color: c.textMid,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Frozen notice
                  if (frozen.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.amber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: c.amber.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: c.amber,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l.trialExpiredFrozen(frozen.length),
                              style: TextStyle(
                                fontSize: 12,
                                color: c.amber,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Unlock Pro CTA
                  GestureDetector(
                    onTap: () {
                      HapticService.instance.success();
                      Navigator.of(context).pop();
                      showPaywall(context, trigger: PaywallTrigger.trialExpired);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [c.mintDark, c.mint],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: c.mint.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l.trialExpiredCta,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: c.bg,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Dismiss
                  GestureDetector(
                    onTap: () {
                      HapticService.instance.light();
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        l.trialExpiredDismiss,
                        style: TextStyle(
                          fontSize: 13,
                          color: c.textDim,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

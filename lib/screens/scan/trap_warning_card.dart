import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../models/scan_result.dart';
import '../../models/subscription.dart';
import '../../models/trap_result.dart';
import '../../providers/scan_provider.dart';
import '../../widgets/mascot_image.dart';
import '../../providers/subscriptions_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/price_breakdown_card.dart';
import '../../widgets/severity_badge.dart';

/// Full-screen trap warning overlay.
///
/// Shown when the AI scan detects a medium/high severity dark pattern.
/// Presents the trap details with a price breakdown and gives the user
/// two choices: "Skip It" (saves money) or "Track Trial Anyway" (sets alerts).
class TrapWarningCard extends ConsumerWidget {
  final ScanResult subscription;
  final TrapResult trap;

  const TrapWarningCard({
    super.key,
    required this.subscription,
    required this.trap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHigh = trap.severity == TrapSeverity.high;
    final warningColor = isHigh ? ChompdColors.red : ChompdColors.amber;

    return Container(
      color: ChompdColors.bg.withValues(alpha: 0.95),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ───
                Row(
                  children: [
                    Icon(Icons.warning_rounded, size: 28, color: warningColor),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'TRAP DETECTED',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ChompdColors.text,
                        ),
                      ),
                    ),
                    SeverityBadge(severity: trap.severity),
                  ],
                ),

                const SizedBox(height: 16),

                // ─── Piranha alert animation ───
                const Center(
                  child: MascotImage(
                    asset: 'piranha_alert_anim.gif',
                    size: 120,
                    fadeIn: true,
                  ),
                ),

                const SizedBox(height: 16),

                // ─── Service name ───
                Text(
                  'This "${trap.serviceName ?? subscription.serviceName}" offer is actually:',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ChompdColors.textMid,
                  ),
                ),

                const SizedBox(height: 16),

                // ─── Price breakdown ───
                PriceBreakdownCard(trap: trap),

                const SizedBox(height: 16),

                // ─── AI warning message ───
                Container(
                  padding: const EdgeInsets.only(left: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: ChompdColors.mintGlow,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Text(
                    trap.warningMessage,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ChompdColors.textMid,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(),

                // ─── Primary: Skip It ───
                GestureDetector(
                  onTap: () {
                    ref.read(scanProvider.notifier).skipTrap(trap);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [ChompdColors.mint, ChompdColors.mintDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'SKIP IT \u2014 SAVE \u00A3${trap.savingsAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ChompdColors.bg,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ─── Secondary: Track Trial Anyway ───
                GestureDetector(
                  onTap: () {
                    // Guard against double-tap
                    final phase = ref.read(scanProvider).phase;
                    if (phase != ScanPhase.trapDetected) return;

                    // 1. Transition UI state
                    ref
                        .read(scanProvider.notifier)
                        .trackTrapTrial(subscription, trap);

                    // 2. Create subscription with trap metadata
                    final sub = Subscription.fromScanWithTrap(
                      subscription,
                      trap,
                    );

                    // 3. Save to subscriptions list
                    ref.read(subscriptionsProvider.notifier).add(sub);

                    // 4. Schedule aggressive trial alerts
                    if (trap.trialDurationDays != null &&
                        sub.trialExpiresAt != null) {
                      NotificationService.instance
                          .scheduleAggressiveTrialAlerts(
                        subscriptionUid: sub.uid,
                        serviceName: sub.name,
                        realPrice: trap.realPrice ?? sub.price,
                        currency: sub.currency,
                        trialExpiresAt: sub.trialExpiresAt!,
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: ChompdColors.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Track Trial Anyway',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ChompdColors.textDim,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_active,
                                size: 12, color: ChompdColors.textDim,),
                            SizedBox(width: 4),
                            Text(
                              'We\'ll remind you before it charges',
                              style: TextStyle(
                                fontSize: 11,
                                color: ChompdColors.textDim,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

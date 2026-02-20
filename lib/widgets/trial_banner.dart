import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/theme.dart';
import '../models/entitlement.dart';
import '../providers/entitlement_provider.dart';
import '../providers/purchase_provider.dart';
import '../screens/paywall/paywall_screen.dart';
import '../services/haptic_service.dart';
import '../utils/l10n_extension.dart';

/// Slim trial status strip for the home screen.
///
/// - Trial active: "✨ Pro trial · X days left          Upgrade"
/// - Trial expired: "Pro trial expired          Upgrade"
/// - Pro user: hidden entirely
/// - Free (never trialled): hidden entirely
///
/// Roughly 36-40px total height. Tapping anywhere opens the paywall.
class TrialBanner extends ConsumerWidget {
  const TrialBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(userTierProvider);
    final ent = ref.watch(entitlementProvider);

    // Pro → hide. Free without expired trial → hide.
    if (tier == UserTier.pro) return const SizedBox.shrink();
    if (tier == UserTier.free && !ent.isTrialExpired) {
      return const SizedBox.shrink();
    }

    final c = context.colors;
    final l = context.l10n;
    final isExpired = ent.isTrialExpired;
    final daysLeft = ent.trialDaysRemaining;
    final isUrgent = !isExpired && ent.isTrialUrgent;

    final accentColor = isExpired
        ? c.textDim
        : isUrgent
            ? c.amber
            : c.mint;

    return GestureDetector(
      onTap: () {
        HapticService.instance.light();
        showPaywall(context, trigger: PaywallTrigger.settingsUpgrade);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.20),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isExpired
                  ? Icons.timer_off_outlined
                  : isUrgent
                      ? Icons.timer_outlined
                      : Icons.auto_awesome,
              size: 14,
              color: accentColor,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                isExpired
                    ? l.trialBannerExpired
                    : l.trialBannerDays(daysLeft),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: accentColor,
                ),
              ),
            ),
            Text(
              l.trialBannerUpgrade,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isExpired ? c.mint : accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

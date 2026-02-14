import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/subscription.dart';
import '../providers/currency_provider.dart';
import '../providers/trap_stats_provider.dart';
import '../utils/l10n_extension.dart';
import 'mascot_image.dart';

class TrapStatsCard extends ConsumerWidget {
  const TrapStatsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final trapStats = ref.watch(trapStatsProvider);
    final currency = ref.watch(currencyProvider);

    if (!trapStats.hasStats) {
      return const SizedBox.shrink(); // No padding when empty
    }

    final breakdownItems = <String>[];
    if (trapStats.trapsSkipped > 0) {
      breakdownItems.add(context.l10n.trapsDodged(trapStats.trapsSkipped));
    }
    if (trapStats.trialsCancelled > 0) {
      breakdownItems.add(context.l10n.trialsCancelled(trapStats.trialsCancelled));
    }
    if (trapStats.refundsRecovered > 0) {
      breakdownItems.add(context.l10n.refundsRecovered(trapStats.refundsRecovered));
    }

    final breakdownText = breakdownItems.join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: c.mintGlow.withValues(alpha: 0.15),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const MascotImage(
                asset: 'piranha_thumbsup.png',
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.unchompd,
                style: TextStyle(
                  color: c.textMid,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Subscription.formatPrice(trapStats.totalSaved, currency),
            style: GoogleFonts.spaceMono(
              color: c.mint,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.fromSubscriptionTraps,
            style: TextStyle(
              color: c.textDim,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            breakdownText,
            style: GoogleFonts.spaceMono(
              color: c.textDim,
              fontSize: 10,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

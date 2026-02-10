import 'package:flutter/material.dart';

import '../config/theme.dart';
import 'mascot_image.dart';

/// Empty state widget for screens with no data.
///
/// Supports two visual modes:
/// - Emoji icon (default) — used for trials and savings empty states
/// - Mascot image — used for the main "no subscriptions" empty state
class EmptyState extends StatelessWidget {
  final String icon;
  final String? imagePath;
  final String title;
  final String subtitle;
  final Color accentColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.accentColor = ChompdColors.mint,
    this.imagePath,
  });

  /// Empty state for no subscriptions tracked yet.
  /// Shows piranha_sleeping mascot.
  const EmptyState.noSubscriptions({super.key})
      : icon = '',
        imagePath = 'piranha_sleeping.png',
        title = 'No subscriptions yet',
        subtitle = 'Scan a screenshot or tap + to get started.',
        accentColor = ChompdColors.mint;

  /// Empty state for no active trials.
  const EmptyState.noTrials({super.key})
      : icon = '\u23F0',
        imagePath = null,
        title = 'No active trials',
        subtitle = 'When you add trial subscriptions,\nthey\u2019ll appear here with countdown alerts.',
        accentColor = ChompdColors.amber;

  /// Empty state for no cancelled subs (savings).
  const EmptyState.noSavings({super.key})
      : icon = '\uD83D\uDCB0',
        imagePath = null,
        title = 'No savings yet',
        subtitle = 'Cancel subscriptions you don\u2019t use\nand watch your savings grow here.',
        accentColor = ChompdColors.mint;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mascot image or emoji icon
            if (imagePath != null)
              MascotImage(
                asset: imagePath!,
                size: 120,
                fadeIn: true,
              )
            else
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ChompdColors.textMid,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: ChompdColors.textDim,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

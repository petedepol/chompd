import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../utils/l10n_extension.dart';
import 'discovery_tips_card.dart';
import 'mascot_image.dart';

enum _EmptyStateType { custom, noSubscriptions, noTrials, noSavings }

/// Empty state widget for screens with no data.
///
/// Supports two visual modes:
/// - Emoji icon (default) — used for trials and savings empty states
/// - Mascot image — used for the main "no subscriptions" empty state
class EmptyState extends StatelessWidget {
  final String icon;
  final String? imagePath;
  final String? _title;
  final String? _subtitle;
  final Color accentColor;
  final _EmptyStateType _type;

  const EmptyState({
    super.key,
    required this.icon,
    required String title,
    required String subtitle,
    this.accentColor = ChompdColors.mint,
    this.imagePath,
  })  : _title = title,
        _subtitle = subtitle,
        _type = _EmptyStateType.custom;

  /// Empty state for no subscriptions tracked yet.
  /// Shows piranha_sleeping mascot.
  const EmptyState.noSubscriptions({super.key})
      : icon = '',
        imagePath = 'piranha_sleeping.png',
        _title = null,
        _subtitle = null,
        accentColor = ChompdColors.mint,
        _type = _EmptyStateType.noSubscriptions;

  /// Empty state for no active trials.
  const EmptyState.noTrials({super.key})
      : icon = '\u23F0',
        imagePath = null,
        _title = null,
        _subtitle = null,
        accentColor = ChompdColors.amber,
        _type = _EmptyStateType.noTrials;

  /// Empty state for no cancelled subs (savings).
  const EmptyState.noSavings({super.key})
      : icon = '\uD83D\uDCB0',
        imagePath = null,
        _title = null,
        _subtitle = null,
        accentColor = ChompdColors.mint,
        _type = _EmptyStateType.noSavings;

  String _resolveTitle(BuildContext context) {
    if (_title != null) return _title;
    switch (_type) {
      case _EmptyStateType.noSubscriptions:
        return context.l10n.emptyNoSubscriptions;
      case _EmptyStateType.noTrials:
        return context.l10n.emptyNoTrials;
      case _EmptyStateType.noSavings:
        return context.l10n.emptyNoSavings;
      case _EmptyStateType.custom:
        return '';
    }
  }

  String _resolveSubtitle(BuildContext context) {
    if (_subtitle != null) return _subtitle;
    switch (_type) {
      case _EmptyStateType.noSubscriptions:
        return context.l10n.emptyNoSubscriptionsHint;
      case _EmptyStateType.noTrials:
        return context.l10n.emptyNoTrialsHint;
      case _EmptyStateType.noSavings:
        return context.l10n.emptyNoSavingsHint;
      case _EmptyStateType.custom:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _resolveTitle(context);
    final subtitle = _resolveSubtitle(context);

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
            // Show discovery tips only on the main "no subscriptions" state
            if (_type == _EmptyStateType.noSubscriptions) ...[
              const SizedBox(height: 24),
              const DiscoveryTipsCard(),
            ],
          ],
        ),
      ),
    );
  }
}

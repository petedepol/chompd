import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';
import '../models/subscription.dart';
import '../services/haptic_service.dart';
import '../utils/l10n_extension.dart';
import 'trial_badge.dart';

/// A single subscription card for the home screen list.
///
/// Shows service icon, name, trial badge (if applicable),
/// renewal info, and price. Supports swipe-to-delete and
/// swipe-to-edit with spring physics.
class SubscriptionCard extends StatefulWidget {
  final Subscription subscription;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  bool _pressed = false;

  /// Category colour for card tint/border — consistent across same-category subs.
  Color get _categoryColor =>
      CategoryColors.forCategory(widget.subscription.category);

  /// Brand colour for the icon badge only. Falls back to category colour.
  Color get _brandColor {
    if (widget.subscription.brandColor != null &&
        widget.subscription.brandColor!.isNotEmpty) {
      try {
        return _parseHexColor(widget.subscription.brandColor!);
      } catch (_) {
        // Fall through to category colour
      }
    }
    return _categoryColor;
  }

  static Color _parseHexColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  /// Build the icon content — uses category icon when the AI hasn't
  /// set a proper icon (i.e. single letter or null).
  Widget _buildIconContent(Subscription sub) {
    final icon = sub.iconName;
    final isSingleLetter = icon == null || icon.length <= 1;

    if (isSingleLetter) {
      final catIcon = CategoryIcons.forCategory(sub.category);
      if (catIcon != null) {
        return Icon(catIcon, size: 20, color: Colors.white);
      }
    }

    return Text(
      icon ?? (sub.name.isNotEmpty ? sub.name[0] : '?'),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscription = widget.subscription;
    final trialDays = subscription.trialDaysRemaining;
    final isTrialUrgent = trialDays != null && trialDays <= 3;
    final catColor = _categoryColor;
    final iconColor = _brandColor;

    final borderColor = isTrialUrgent
        ? ChompdColors.amber.withValues(alpha: 0.27)
        : ChompdColors.border;

    final accentColor = isTrialUrgent
        ? ChompdColors.amber.withValues(alpha: 0.6)
        : catColor.withValues(alpha: 0.5);

    Widget card = GestureDetector(
      onTap: () {
        HapticService.instance.light();
        widget.onTap?.call();
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _pressed ? ChompdColors.bgElevated : ChompdColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _pressed ? 0.0 : 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: catColor.withValues(alpha: _pressed ? 0.0 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            if (isTrialUrgent)
              BoxShadow(
                color: ChompdColors.amberGlow,
                blurRadius: 16,
                spreadRadius: 0,
              ),
          ],
        ),
        child: Stack(
          children: [
            // Left accent bar — positioned over the left edge
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 3,
              child: ColoredBox(color: accentColor),
            ),
            // Top-light gradient — subtle "lit from above" effect
            Positioned(
              left: 14,
              right: 14,
              top: 0,
              height: 1,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      ChompdColors.borderHighlight,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Card content with left padding accounting for accent
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 12, 14, 12),
              child: Row(
                children: [
                  // ─── Service Icon ───
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          iconColor.withValues(alpha: 0.87),
                          iconColor.withValues(alpha: 0.53),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _buildIconContent(subscription),
                  ),

                  const SizedBox(width: 12),

                  // ─── Name + Renewal ───
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                subscription.name,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: ChompdColors.text,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (trialDays != null) ...[
                              const SizedBox(width: 6),
                              TrialBadge(daysRemaining: trialDays),
                            ],
                            if (subscription.isTrap == true) ...[
                              const SizedBox(width: 6),
                              _TrapBadge(subscription: subscription),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          subscription.localRenewalLabel(context.l10n),
                          style: TextStyle(
                            fontSize: 11,
                            color: subscription.daysUntilRenewal < 0
                                ? ChompdColors.amber
                                : ChompdColors.textMid,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── Price ───
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Zero price + not a trap = unknown price
                      if (subscription.price == 0 && subscription.isTrap != true)
                        Text(
                          '\u2014',
                          style: ChompdTypography.priceCard.copyWith(
                            color: ChompdColors.textDim,
                          ),
                        )
                      else
                        Text(
                          Subscription.formatPrice(subscription.price, subscription.currency),
                          style: (subscription.isTrap == true)
                              ? ChompdTypography.priceCard.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: ChompdColors.textDim,
                                  fontSize: 11,
                                )
                              : ChompdTypography.priceCard,
                        ),
                      if (subscription.isTrap == true &&
                          subscription.realPrice != null)
                        Text(
                          '\u2192 ${Subscription.formatPrice(subscription.realPrice!, subscription.currency)}',
                          style: GoogleFonts.spaceMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: subscription.trapSeverity == 'high'
                                ? ChompdColors.red
                                : ChompdColors.amber,
                          ),
                        )
                      else
                        Text(
                          '/${subscription.cycle.localShortLabel(context.l10n)}',
                          style: ChompdTypography.cycleLabel,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Wrap with Dismissible for swipe actions if callbacks provided
    if (widget.onDelete != null || widget.onEdit != null) {
      card = Dismissible(
        key: ValueKey(subscription.uid),
        background: _buildSwipeBackground(
          alignment: Alignment.centerLeft,
          color: ChompdColors.blue,
          icon: Icons.edit_outlined,
          label: context.l10n.edit,
        ),
        secondaryBackground: _buildSwipeBackground(
          alignment: Alignment.centerRight,
          color: ChompdColors.red,
          icon: Icons.delete_outline_rounded,
          label: context.l10n.delete,
        ),
        confirmDismiss: (direction) async {
          HapticService.instance.selection();
          if (direction == DismissDirection.endToStart) {
            widget.onDelete?.call();
          } else {
            widget.onEdit?.call();
          }
          return false;
        },
        child: card,
      );
    }

    return card;
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerRight) ...[
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Icon(icon, color: color, size: 20),
          if (alignment == Alignment.centerLeft) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small inline badge shown on subscription cards flagged as traps.
class _TrapBadge extends StatelessWidget {
  final Subscription subscription;

  const _TrapBadge({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final isHigh = subscription.trapSeverity == 'high';
    final color = isHigh ? ChompdColors.red : ChompdColors.amber;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_rounded, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            subscription.trialDurationDays != null
                ? context.l10n.trapDays(subscription.trialDurationDays!)
                : context.l10n.trapBadge,
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

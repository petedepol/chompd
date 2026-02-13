import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../utils/l10n_extension.dart';

/// Pulsing amber badge for trial subscriptions.
///
/// Shows "Xd trial" with a subtle pulse animation when
/// the trial is expiring within 7 days.
class TrialBadge extends StatefulWidget {
  final int daysRemaining;

  const TrialBadge({
    super.key,
    required this.daysRemaining,
  });

  @override
  State<TrialBadge> createState() => _TrialBadgeState();
}

class _TrialBadgeState extends State<TrialBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Pulse for trials expiring within 7 days
    if (widget.daysRemaining <= 7) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = widget.daysRemaining <= 3;
    final shouldPulse = widget.daysRemaining <= 7;

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isUrgent
            ? ChompdColors.amberGlow
            : ChompdColors.amber.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        context.l10n.trialBadge(widget.daysRemaining),
        style: ChompdTypography.mono(
          size: 8,
          weight: FontWeight.w700,
          color: ChompdColors.amber,
        ).copyWith(
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
    );

    if (shouldPulse) {
      return FadeTransition(
        opacity: _pulseAnimation,
        child: badge,
      );
    }

    return badge;
  }
}

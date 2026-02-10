import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/theme.dart';
import '../providers/budget_provider.dart';
import '../providers/spend_view_provider.dart';
import '../providers/subscriptions_provider.dart';
import '../services/haptic_service.dart';

/// Circular spending ring — the hero element on the home screen.
///
/// Shows total spend as a gradient arc with budget context.
/// Tap to toggle between monthly and yearly views.
class SpendingRing extends ConsumerStatefulWidget {
  final double size;

  const SpendingRing({
    super.key,
    this.size = 160.0,
  });

  @override
  ConsumerState<SpendingRing> createState() => _SpendingRingState();
}

class _SpendingRingState extends ConsumerState<SpendingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleView() {
    final current = ref.read(spendViewProvider);
    ref.read(spendViewProvider.notifier).state =
        current == SpendView.monthly ? SpendView.yearly : SpendView.monthly;
    HapticService.instance.selection();
    // Re-animate the ring on toggle
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(spendViewProvider);
    final totalMonthly = ref.watch(monthlySpendProvider);
    final totalYearly = ref.watch(yearlySpendProvider);
    final budget = ref.watch(budgetProvider);

    final isYearly = view == SpendView.yearly;
    final displayAmount = isYearly ? totalYearly : totalMonthly;
    final displayBudget = isYearly ? budget * 12 : budget;
    final overBudget = displayAmount > displayBudget;

    return GestureDetector(
      onTap: _toggleView,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, child) {
            return CustomPaint(
              painter: _RingPainter(
                progress: _progress.value,
                percentage:
                    (displayAmount / displayBudget).clamp(0.0, 1.0),
                overBudget: overBudget,
              ),
              child: child,
            );
          },
          child: Center(
            child: AnimatedBuilder(
              animation: _progress,
              builder: (context, _) {
                final animatedTotal = displayAmount * _progress.value;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Period label
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isYearly ? 'YEARLY' : 'MONTHLY',
                        key: ValueKey(isYearly ? 'yearly' : 'monthly'),
                        style: ChompdTypography.mono(
                          size: 11,
                          color: ChompdColors.textDim,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Amount
                    Text(
                      '\u00A3${animatedTotal.toStringAsFixed(2)}',
                      style: ChompdTypography.priceHero,
                    ),
                    const SizedBox(height: 2),

                    // Budget context
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        overBudget
                            ? '\u00A3${(displayAmount - displayBudget).toStringAsFixed(0)} over budget'
                            : 'of \u00A3${displayBudget.toStringAsFixed(0)} budget',
                        key: ValueKey('budget_$isYearly'),
                        style: TextStyle(
                          fontSize: 10,
                          color: overBudget
                              ? ChompdColors.red
                              : ChompdColors.textDim,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Toggle hint
                    Text(
                      isYearly ? 'tap for monthly' : 'tap for yearly',
                      style: ChompdTypography.mono(
                        size: 9,
                        color: ChompdColors.textDim.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double percentage;
  final bool overBudget;

  _RingPainter({
    required this.progress,
    required this.percentage,
    required this.overBudget,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;
    const strokeWidth = 8.0;

    // Background track
    final trackPaint = Paint()
      ..color = ChompdColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final sweepAngle = 2 * math.pi * percentage * progress;
    if (sweepAngle > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);

      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      if (overBudget) {
        arcPaint.color = ChompdColors.red;
      } else if (percentage > 0.8) {
        arcPaint.color = ChompdColors.amber;
      } else {
        arcPaint.shader = const LinearGradient(
          colors: [ChompdColors.mintDark, ChompdColors.mint],
        ).createShader(rect);
      }

      canvas.drawArc(
        rect,
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        arcPaint,
      );

      // Subtle glow effect
      final glowColor = overBudget
          ? ChompdColors.red
          : percentage > 0.8
              ? ChompdColors.amber
              : ChompdColors.mint;

      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..color = glowColor.withValues(alpha: 0.25 * progress);

      canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.percentage != percentage ||
        oldDelegate.overBudget != overBudget;
  }
}

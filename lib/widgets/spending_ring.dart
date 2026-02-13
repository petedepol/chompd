import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/theme.dart';
import '../models/subscription.dart';
import '../providers/budget_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/spend_view_provider.dart';
import '../providers/subscriptions_provider.dart';
import '../services/haptic_service.dart';
import '../utils/l10n_extension.dart';

/// Circular spending ring — the hero element on the home screen.
///
/// Shows total spend as a gradient arc with budget context.
/// Tap to toggle between monthly and yearly views.
///
/// Size is responsive by default: 42% of screen width, clamped
/// between 140–220px. Override with an explicit [size] if needed.
class SpendingRing extends ConsumerStatefulWidget {
  final double? size;

  const SpendingRing({
    super.key,
    this.size,
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

  /// Amount with smaller currency symbol, handling prefix/suffix currencies.
  Widget _buildSplitPrice(double amount, String currency) {
    final symbol = Subscription.currencySymbol(currency);
    final number = amount.toStringAsFixed(2);
    final isSuffix = Subscription.isSymbolSuffix(currency);

    final symbolWidget = Text(
      symbol,
      style: ChompdTypography.mono(
        size: 16,
        weight: FontWeight.w700,
        color: ChompdColors.text,
      ),
    );
    final numberWidget = Text(
      number,
      style: ChompdTypography.priceHero,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: isSuffix
          ? [numberWidget, const SizedBox(width: 2), symbolWidget]
          : [symbolWidget, numberWidget],
    );
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
    final currency = ref.watch(currencyProvider);

    final isYearly = view == SpendView.yearly;
    final displayAmount = isYearly ? totalYearly : totalMonthly;
    final displayBudget = isYearly ? budget * 12 : budget;
    final overBudget = displayAmount > displayBudget;
    final percentage = (displayAmount / displayBudget).clamp(0.0, 1.0);

    // Responsive size: 42% of screen width, clamped 140–220px.
    final screenWidth = MediaQuery.of(context).size.width;
    final ringSize = widget.size ?? (screenWidth * 0.42).clamp(140.0, 220.0);

    return GestureDetector(
      onTap: _toggleView,
      child: SizedBox(
        width: ringSize,
        height: ringSize,
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, child) {
            return CustomPaint(
              painter: _RingPainter(
                progress: _progress.value,
                percentage: percentage,
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
                        isYearly ? context.l10n.ringYearly : context.l10n.ringMonthly,
                        key: ValueKey(isYearly ? 'yearly' : 'monthly'),
                        style: ChompdTypography.mono(
                          size: 11,
                          color: ChompdColors.textDim,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Amount — smaller currency symbol
                    _buildSplitPrice(animatedTotal, currency),
                    const SizedBox(height: 2),

                    // Budget context
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        overBudget
                            ? context.l10n.overBudget(Subscription.formatPrice(displayAmount - displayBudget, currency, decimals: 0))
                            : context.l10n.ofBudget(Subscription.formatPrice(displayBudget, currency, decimals: 0)),
                        key: ValueKey('budget_$isYearly'),
                        style: TextStyle(
                          fontSize: 10,
                          color: overBudget
                              ? ChompdColors.red
                              : percentage > 0.9
                                  ? ChompdColors.amber
                                  : ChompdColors.textDim,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Toggle hint
                    Text(
                      isYearly ? context.l10n.tapForMonthly : context.l10n.tapForYearly,
                      style: ChompdTypography.mono(
                        size: 9,
                        color: ChompdColors.textDim.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Budget target range
                    Text(
                      context.l10n.budgetRange(Subscription.formatPrice(0, currency, decimals: 0), Subscription.formatPrice(displayBudget, currency, decimals: 0)),
                      style: TextStyle(
                        fontSize: 9,
                        color: ChompdColors.textDim.withValues(alpha: 0.5),
                        letterSpacing: 0.3,
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
        // Over budget: red with pulsing intensity
        arcPaint.shader = const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
        ).createShader(rect);
      } else if (percentage > 0.9) {
        // 90-100%: amber bleeding into red — danger zone
        final urgency = (percentage - 0.9) / 0.1; // 0.0 → 1.0
        arcPaint.shader = LinearGradient(
          colors: [
            Color.lerp(ChompdColors.amber, ChompdColors.red, urgency)!,
            Color.lerp(const Color(0xFFFCD34D), ChompdColors.red, urgency * 0.7)!,
          ],
        ).createShader(rect);
      } else if (percentage > 0.7) {
        // 70-90%: mint fading into amber — caution zone
        final caution = (percentage - 0.7) / 0.2; // 0.0 → 1.0
        arcPaint.shader = LinearGradient(
          colors: [
            Color.lerp(ChompdColors.mintDark, ChompdColors.amber, caution)!,
            Color.lerp(ChompdColors.mint, const Color(0xFFFCD34D), caution)!,
          ],
        ).createShader(rect);
      } else {
        // 0-70%: healthy mint gradient
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
      final Color glowColor;
      if (overBudget) {
        glowColor = ChompdColors.red;
      } else if (percentage > 0.9) {
        final urgency = (percentage - 0.9) / 0.1;
        glowColor = Color.lerp(ChompdColors.amber, ChompdColors.red, urgency)!;
      } else if (percentage > 0.7) {
        final caution = (percentage - 0.7) / 0.2;
        glowColor = Color.lerp(ChompdColors.mint, ChompdColors.amber, caution)!;
      } else {
        glowColor = ChompdColors.mint;
      }

      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..color = glowColor.withValues(alpha: 0.25 * progress);

      canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, glowPaint);

      // Leading edge dot — bright circle at the tip of the arc
      if (sweepAngle > 0.05) {
        final endAngle = -math.pi / 2 + sweepAngle;
        final dotCenter = Offset(
          center.dx + radius * math.cos(endAngle),
          center.dy + radius * math.sin(endAngle),
        );

        // Outer glow
        final dotGlowPaint = Paint()
          ..color = glowColor.withValues(alpha: 0.4 * progress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(dotCenter, strokeWidth * 0.8, dotGlowPaint);

        // Bright core
        final dotPaint = Paint()
          ..color = glowColor.withValues(alpha: 0.9 * progress);
        canvas.drawCircle(dotCenter, strokeWidth * 0.45, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.percentage != percentage ||
        oldDelegate.overBudget != overBudget;
  }
}

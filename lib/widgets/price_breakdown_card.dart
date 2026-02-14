import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/subscription.dart';
import '../models/trap_result.dart';
import '../utils/l10n_extension.dart';

/// Visual price comparison card: trial price → arrow → real price.
///
/// The centrepiece of the trap warning overlay. Shows what the user
/// pays now vs what they'll pay after the trial/intro period.
class PriceBreakdownCard extends StatefulWidget {
  final TrapResult trap;

  const PriceBreakdownCard({super.key, required this.trap});

  @override
  State<PriceBreakdownCard> createState() => _PriceBreakdownCardState();
}

class _PriceBreakdownCardState extends State<PriceBreakdownCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrowController;
  late Animation<Offset> _arrowSlide;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _arrowSlide = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeOut),
    );
    _arrowController.forward();
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  Color _borderColor(BuildContext context) {
    final c = context.colors;
    return switch (widget.trap.severity) {
      TrapSeverity.high => c.red.withValues(alpha: 0.3),
      TrapSeverity.medium => c.amber.withValues(alpha: 0.3),
      TrapSeverity.low => c.blue.withValues(alpha: 0.3),
    };
  }

  Color _priceColor(BuildContext context) {
    final c = context.colors;
    return switch (widget.trap.severity) {
      TrapSeverity.high => c.red,
      TrapSeverity.medium => c.amber,
      TrapSeverity.low => c.blue,
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final trap = widget.trap;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LEFT: Trial price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.priceToday,
                      style: TextStyle(fontSize: 10, color: c.textDim),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Subscription.formatPrice(trap.trialPrice ?? 0, 'GBP'),
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: c.mint,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.dayTrial((trap.trialDurationDays ?? '?').toString()),
                      style: TextStyle(
                        fontSize: 11,
                        color: c.textDim,
                      ),
                    ),
                  ],
                ),
              ),

              // ARROW (animated)
              SlideTransition(
                position: _arrowSlide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '\u2192',
                    style: TextStyle(fontSize: 20, color: c.textMid),
                  ),
                ),
              ),

              // RIGHT: Real price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.l10n.priceThen,
                      style: TextStyle(fontSize: 10, color: c.textDim),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trap.realPrice != null
                          ? Subscription.formatPrice(trap.realPrice!, 'GBP')
                          : '?',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _priceColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '/${trap.realBillingCycle ?? "year"}',
                      style: TextStyle(
                        fontSize: 11,
                        color: c.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Annual cost summary
          if (trap.realAnnualCost != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.l10n.realCostFirstYear(Subscription.formatPrice(trap.realAnnualCost!, 'GBP')),
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: c.text,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

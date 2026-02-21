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
  final String currency;

  const PriceBreakdownCard({super.key, required this.trap, required this.currency});

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
    final scenario = trap.scenario;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor(context)),
      ),
      child: Column(
        children: [
          if (scenario == 'renewal_notice')
            // Single price layout for renewals at the same price
            _buildRenewalLayout(context, c, trap)
          else
            // Two-column layout for trial_to_paid, price_increase, and fallback
            _buildTwoColumnLayout(context, c, trap, scenario),

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
                context.l10n.realCostFirstYear(Subscription.formatPrice(trap.realAnnualCost!, widget.currency)),
                style: ChompdTypography.mono(
                  size: 13,
                  weight: FontWeight.w700,
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

  /// Localise an AI billing cycle string to its short l10n form.
  String _cycleShort(BuildContext context, String? cycle) {
    return switch (cycle?.toLowerCase()) {
      'weekly' => context.l10n.cycleWeeklyShort,
      'monthly' => context.l10n.cycleMonthlyShort,
      'quarterly' => context.l10n.cycleQuarterlyShort,
      'yearly' => context.l10n.cycleYearlyShort,
      _ => cycle ?? context.l10n.cycleYearlyShort,
    };
  }

  /// Renewal notice: single centred price — "RENEWS AT → £20.00/yearly"
  Widget _buildRenewalLayout(BuildContext context, dynamic c, TrapResult trap) {
    return Column(
      children: [
        Text(
          context.l10n.priceRenewsAt,
          style: TextStyle(fontSize: 10, color: c.textDim),
        ),
        const SizedBox(height: 8),
        Text(
          trap.realPrice != null
              ? Subscription.formatPrice(trap.realPrice!, widget.currency)
              : '?',
          style: ChompdTypography.mono(
            size: 24,
            weight: FontWeight.w700,
            color: _priceColor(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '/${_cycleShort(context, trap.realBillingCycle)}',
          style: TextStyle(
            fontSize: 11,
            color: c.textDim,
          ),
        ),
      ],
    );
  }

  /// Two-column layout for trial_to_paid, price_increase, and default.
  Widget _buildTwoColumnLayout(
    BuildContext context,
    dynamic c,
    TrapResult trap,
    String? scenario,
  ) {
    // price_increase → "NOW" / "THEN"; trial_to_paid or null → "TODAY" / "THEN"
    final leftLabel = scenario == 'price_increase' ? context.l10n.priceNow : context.l10n.priceToday;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // LEFT: Current / trial price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leftLabel,
                style: TextStyle(fontSize: 10, color: c.textDim),
              ),
              const SizedBox(height: 8),
              Text(
                Subscription.formatPrice(trap.trialPrice ?? 0, widget.currency),
                style: ChompdTypography.mono(
                  size: 20,
                  weight: FontWeight.w700,
                  color: c.mint,
                ),
              ),
              const SizedBox(height: 4),
              if (scenario != 'price_increase' && trap.trialDurationDays != null)
                Text(
                  // Intro pricing (trialPrice > 0): show "N-month intro"
                  // Free trial (trialPrice == 0 or null): show "N-day trial"
                  (trap.trialPrice != null && trap.trialPrice! > 0)
                      ? context.l10n.monthIntro(
                          (trap.trialDurationDays! / 30).round().toString(),
                        )
                      : context.l10n.dayTrial(trap.trialDurationDays.toString()),
                  style: TextStyle(
                    fontSize: 11,
                    color: c.textDim,
                  ),
                )
              else if (scenario == 'price_increase')
                Text(
                  '/${_cycleShort(context, trap.realBillingCycle)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: c.textDim,
                  ),
                )
              else
                Text(
                  (trap.trialPrice != null && trap.trialPrice! > 0)
                      ? context.l10n.monthIntro('?')
                      : context.l10n.dayTrial((trap.trialDurationDays ?? '?').toString()),
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

        // RIGHT: Future / real price
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
                    ? Subscription.formatPrice(trap.realPrice!, widget.currency)
                    : '?',
                style: ChompdTypography.mono(
                  size: 20,
                  weight: FontWeight.w700,
                  color: _priceColor(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '/${_cycleShort(context, trap.realBillingCycle)}',
                style: TextStyle(
                  fontSize: 11,
                  color: c.textDim,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/subscription.dart';
import '../services/exchange_rate_service.dart';
import 'currency_provider.dart';
import 'subscriptions_provider.dart';

/// An insight is a piece of smart financial advice derived from the user's data.
class Insight {
  final String emoji;
  final String headline;
  final String message;
  final String? actionLabel;
  final InsightType type;

  const Insight({
    required this.emoji,
    required this.headline,
    required this.message,
    this.actionLabel,
    required this.type,
  });
}

enum InsightType { saving, warning, info, celebration }

/// Generates smart insights from subscription data.
///
/// These are simple logic-based insights — no AI needed.
/// Checks for: expensive subscriptions, yearly savings opportunities,
/// total spend changes, underused trials, and budget proximity.
final insightsProvider = Provider<List<Insight>>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  final currency = ref.watch(currencyProvider);
  final fx = ExchangeRateService.instance;
  final active = subs.where((s) => s.isActive).toList();
  final cancelled = subs.where((s) => !s.isActive).toList();
  final insights = <Insight>[];

  if (active.isEmpty) return insights;

  // 1. Most expensive subscription (compared in display currency)
  final sorted = [...active]
    ..sort((a, b) => b.yearlyEquivalentIn(currency).compareTo(a.yearlyEquivalentIn(currency)));
  final priciest = sorted.first;
  final priciestYearly = priciest.yearlyEquivalentIn(currency);
  if (priciestYearly > fx.convert(100, 'GBP', currency)) {
    insights.add(Insight(
      emoji: '\uD83D\uDCB8',
      headline: 'Big spender',
      message:
          '${priciest.name} costs you **${Subscription.formatPrice(priciestYearly, currency, decimals: 0)}/year**. That\u2019s your most expensive subscription.',
      type: InsightType.warning,
    ));
  }

  // 2. Monthly subscriptions that would save money as yearly
  // (Assumes ~17% saving for yearly vs monthly — industry standard)
  final monthlyThreshold = fx.convert(5, 'GBP', currency);
  final monthlySubs = active
      .where((s) => s.cycle == BillingCycle.monthly && s.monthlyEquivalentIn(currency) > monthlyThreshold)
      .toList();
  if (monthlySubs.length >= 2) {
    final potentialSaving =
        monthlySubs.fold(0.0, (sum, s) => sum + (s.yearlyEquivalentIn(currency) * 0.17));
    insights.add(Insight(
      emoji: '\uD83D\uDCA1',
      headline: 'Annual savings',
      message:
          'Switching **${monthlySubs.length} subscriptions** to annual billing could save ~**${Subscription.formatPrice(potentialSaving, currency, decimals: 0)}/year**.',
      type: InsightType.saving,
    ));
  }

  // 3. Subscription count reality check
  if (active.length >= 8) {
    insights.add(Insight(
      emoji: '\uD83D\uDE32',
      headline: 'Reality check',
      message:
          'You have **${active.length} active subscriptions**. The average person has 12 \u2014 are you using them all?',
      type: InsightType.info,
    ));
  }

  // 4. Celebrate cancelled savings (converted to display currency)
  if (cancelled.isNotEmpty) {
    final monthsSaved = cancelled.fold(0.0, (sum, s) {
      if (s.cancelledDate == null) return sum;
      return sum +
          s.monthlyEquivalentIn(currency) *
              (DateTime.now().difference(s.cancelledDate!).inDays / 30);
    });
    if (monthsSaved > 0) {
      insights.add(Insight(
        emoji: '\uD83C\uDF89',
        headline: 'Money saved',
        message:
            'You\u2019ve saved **${Subscription.formatPrice(monthsSaved, currency, decimals: 0)}** since cancelling **${cancelled.length} subscription${cancelled.length == 1 ? '' : 's'}**. Nice one!',
        type: InsightType.celebration,
      ));
    }
  }

  // 5. Trial ending soon — remind to decide
  final expiringTrials = active
      .where((s) => s.isTrial && (s.trialDaysRemaining ?? 99) <= 3)
      .toList();
  if (expiringTrials.isNotEmpty) {
    final names = expiringTrials.map((s) => s.name).join(', ');
    insights.add(Insight(
      emoji: '\u23F0',
      headline: 'Trial ending',
      message:
          '**$names** trial${expiringTrials.length > 1 ? 's' : ''} ending soon. Cancel now or you\u2019ll be charged.',
      type: InsightType.warning,
    ));
  }

  // 6. Daily cost reframe (if high, in display currency)
  final yearlyTotal = active.fold(0.0, (sum, s) => sum + s.yearlyEquivalentIn(currency));
  final dailyCost = yearlyTotal / 365;
  if (dailyCost > fx.convert(5, 'GBP', currency)) {
    insights.add(Insight(
      emoji: '\u2615',
      headline: 'Daily cost',
      message:
          'Your subscriptions cost **${Subscription.formatPrice(dailyCost, currency)}/day** \u2014 that\u2019s a fancy coffee, every single day.',
      type: InsightType.info,
    ));
  }

  return insights;
});

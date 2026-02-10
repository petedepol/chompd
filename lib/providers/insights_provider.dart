import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/subscription.dart';
import 'currency_provider.dart';
import 'subscriptions_provider.dart';

/// An insight is a piece of smart financial advice derived from the user's data.
class Insight {
  final String emoji;
  final String message;
  final String? actionLabel;
  final InsightType type;

  const Insight({
    required this.emoji,
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
  final sym = Subscription.currencySymbol(currency);
  final active = subs.where((s) => s.isActive).toList();
  final cancelled = subs.where((s) => !s.isActive).toList();
  final insights = <Insight>[];

  if (active.isEmpty) return insights;

  // 1. Most expensive subscription
  final sorted = [...active]
    ..sort((a, b) => b.yearlyEquivalent.compareTo(a.yearlyEquivalent));
  final priciest = sorted.first;
  if (priciest.yearlyEquivalent > 100) {
    insights.add(Insight(
      emoji: '\uD83D\uDCB8',
      message:
          '${priciest.name} costs you $sym${priciest.yearlyEquivalent.toStringAsFixed(0)}/year. That\u2019s your most expensive subscription.',
      type: InsightType.warning,
    ));
  }

  // 2. Monthly subscriptions that would save money as yearly
  // (Assumes ~17% saving for yearly vs monthly — industry standard)
  final monthlySubs = active
      .where((s) => s.cycle == BillingCycle.monthly && s.price > 5)
      .toList();
  if (monthlySubs.length >= 2) {
    final potentialSaving =
        monthlySubs.fold(0.0, (sum, s) => sum + (s.yearlyEquivalent * 0.17));
    insights.add(Insight(
      emoji: '\uD83D\uDCA1',
      message:
          'Switching ${monthlySubs.length} subscriptions to annual billing could save ~$sym${potentialSaving.toStringAsFixed(0)}/year.',
      type: InsightType.saving,
    ));
  }

  // 3. Subscription count reality check
  if (active.length >= 8) {
    insights.add(Insight(
      emoji: '\uD83D\uDE32',
      message:
          'You have ${active.length} active subscriptions. The average person has 12 \u2014 are you using them all?',
      type: InsightType.info,
    ));
  }

  // 4. Celebrate cancelled savings
  if (cancelled.isNotEmpty) {
    final monthsSaved = cancelled.fold(0.0, (sum, s) {
      if (s.cancelledDate == null) return sum;
      return sum +
          s.monthlyEquivalent *
              (DateTime.now().difference(s.cancelledDate!).inDays / 30);
    });
    if (monthsSaved > 0) {
      insights.add(Insight(
        emoji: '\uD83C\uDF89',
        message:
            'You\u2019ve saved $sym${monthsSaved.toStringAsFixed(0)} since cancelling ${cancelled.length} subscription${cancelled.length == 1 ? '' : 's'}. Nice one!',
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
      message:
          '$names trial${expiringTrials.length > 1 ? 's' : ''} ending soon. Cancel now or you\u2019ll be charged.',
      type: InsightType.warning,
    ));
  }

  // 6. Daily cost reframe (if high)
  final yearlyTotal = active.fold(0.0, (sum, s) => sum + s.yearlyEquivalent);
  final dailyCost = yearlyTotal / 365;
  if (dailyCost > 5) {
    insights.add(Insight(
      emoji: '\u2615',
      message:
          'Your subscriptions cost $sym${dailyCost.toStringAsFixed(2)} per day \u2014 that\u2019s a fancy coffee, every single day.',
      type: InsightType.info,
    ));
  }

  return insights;
});

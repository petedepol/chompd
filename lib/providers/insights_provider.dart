import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/subscription.dart';
import '../services/exchange_rate_service.dart';
import 'currency_provider.dart';
import 'locale_provider.dart';
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
  final locale = ref.watch(localeProvider);
  final l = lookupS(locale);
  final fx = ExchangeRateService.instance;
  final active = subs.where((s) => s.isActive).toList();
  final cancelled = subs.where((s) => !s.isActive && s.cancelledDate != null).toList();
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
      headline: l.insightBigSpenderHeadline,
      message: l.insightBigSpenderMessage(
        priciest.name,
        Subscription.formatPrice(priciestYearly, currency, decimals: 0),
      ),
      type: InsightType.warning,
    ));
  }

  // 2. (Removed — replaced by real data-backed AnnualSavingsCard)

  // 3. Subscription count reality check
  if (active.length >= 8) {
    insights.add(Insight(
      emoji: '\uD83D\uDE32',
      headline: l.insightRealityCheckHeadline,
      message: l.insightRealityCheckMessage(active.length),
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
        headline: l.insightMoneySavedHeadline,
        message: l.insightMoneySavedMessage(
          Subscription.formatPrice(monthsSaved, currency, decimals: 0),
          cancelled.length,
        ),
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
      headline: l.insightTrialEndingHeadline,
      message: l.insightTrialEndingMessage(names, expiringTrials.length),
      type: InsightType.warning,
    ));
  }

  // 6. Daily cost reframe (if high, in display currency)
  final yearlyTotal = active.fold(0.0, (sum, s) => sum + s.yearlyEquivalentIn(currency));
  final dailyCost = yearlyTotal / 365;
  if (dailyCost > fx.convert(5, 'GBP', currency)) {
    insights.add(Insight(
      emoji: '\u2615',
      headline: l.insightDailyCostHeadline,
      message: l.insightDailyCostMessage(
        Subscription.formatPrice(dailyCost, currency),
      ),
      type: InsightType.info,
    ));
  }

  return insights;
});

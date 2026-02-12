import '../models/nudge_candidate.dart';
import '../models/subscription.dart';
import 'exchange_rate_service.dart';

/// Heuristic nudge engine — evaluates all active subscriptions
/// and returns candidates that deserve a "should I keep this?" prompt.
///
/// Runs locally. No API calls. No ongoing cost.
class NudgeEngine {
  /// Evaluate all subs and return nudge-worthy candidates,
  /// sorted by priority (1 = highest).
  ///
  /// [displayCurrency] is used to convert thresholds and calculate
  /// percentages across mixed-currency subscriptions.
  /// Nudge messages still show the sub's original currency.
  List<NudgeCandidate> evaluate(
    List<Subscription> subs, {
    String displayCurrency = 'GBP',
  }) {
    final candidates = <NudgeCandidate>[];
    final fx = ExchangeRateService.instance;
    final totalYearly = subs
        .where((s) => s.isActive)
        .fold(0.0, (sum, s) => sum + s.yearlyEquivalentIn(displayCurrency));

    // Scale GBP thresholds to display currency
    final threshold10 = fx.convert(10, 'GBP', displayCurrency);
    final threshold15 = fx.convert(15, 'GBP', displayCurrency);

    for (final sub in subs.where((s) => s.isActive)) {
      // Skip if user explicitly confirmed keeping within last 90 days
      if (sub.keepConfirmed && sub.lastReviewedAt != null) {
        final daysSinceReview =
            DateTime.now().difference(sub.lastReviewedAt!).inDays;
        if (daysSinceReview < 90) continue;
      }

      // Rule 1: Expensive + old — over £10/mo equivalent, not reviewed in 90+ days
      if (sub.monthlyEquivalentIn(displayCurrency) >= threshold10 &&
          _daysSinceLastReview(sub) > 90) {
        final pct = totalYearly > 0
            ? (sub.yearlyEquivalentIn(displayCurrency) / totalYearly * 100).round()
            : 0;
        candidates.add(NudgeCandidate(
          sub: sub,
          reason: NudgeReason.expensiveUnreviewed,
          message:
              'You\'ve been paying ${Subscription.formatPrice(sub.monthlyEquivalent, sub.currency)}/mo '
              'for ${_monthsActive(sub)} months \u2014 $pct% of your yearly spend. Still using it?',
          priority: 2,
        ));
      }

      // Rule 2: Trial converted + never reviewed
      if (sub.isTrap == true &&
          sub.trialExpiresAt != null &&
          DateTime.now().isAfter(sub.trialExpiresAt!) &&
          _daysSinceLastReview(sub) > 14) {
        candidates.add(NudgeCandidate(
          sub: sub,
          reason: NudgeReason.trialConverted,
          message:
              'Your ${sub.name} trial converted '
              '${_daysAgo(sub.trialExpiresAt!)} days ago. '
              'Worth keeping at ${Subscription.formatPrice(sub.price, sub.currency)}/${sub.cycle.shortLabel}?',
          priority: 1,
        ));
      }

      // Rule 3: Renewal approaching + expensive (>£15/mo equivalent, within 7 days)
      if (sub.monthlyEquivalentIn(displayCurrency) >= threshold15 &&
          sub.daysUntilRenewal <= 7 &&
          sub.daysUntilRenewal > 0) {
        final pct = totalYearly > 0
            ? (sub.yearlyEquivalentIn(displayCurrency) / totalYearly * 100).round()
            : 0;
        candidates.add(NudgeCandidate(
          sub: sub,
          reason: NudgeReason.renewalApproaching,
          message:
              '${sub.name} renews in ${sub.daysUntilRenewal} days '
              'at ${Subscription.formatPrice(sub.price, sub.currency)} \u2014 '
              '$pct% of your yearly spend. Still worth it?',
          priority: 2,
        ));
      }

      // Rule 4: Duplicate category (3+ in same category)
      final sameCategorySubs = subs
          .where(
            (s) => s.isActive && s.category == sub.category && s.uid != sub.uid,
          )
          .toList();
      if (sameCategorySubs.length >= 2 && _daysSinceLastReview(sub) > 60) {
        final totalMonthly = [sub, ...sameCategorySubs]
            .fold(0.0, (sum, s) => sum + s.monthlyEquivalentIn(displayCurrency));
        candidates.add(NudgeCandidate(
          sub: sub,
          reason: NudgeReason.duplicateCategory,
          message:
              'You have ${sameCategorySubs.length + 1} ${sub.category} '
              'subscriptions totalling '
              '${Subscription.formatPrice(totalMonthly, displayCurrency)}/mo. Need them all?',
          priority: 3,
        ));
      }

      // Rule 5: Annual sub approaching renewal (30 days out)
      if (sub.cycle == BillingCycle.yearly &&
          sub.daysUntilRenewal <= 30 &&
          sub.daysUntilRenewal > 7) {
        final pct = totalYearly > 0
            ? (sub.yearlyEquivalentIn(displayCurrency) / totalYearly * 100).round()
            : 0;
        candidates.add(NudgeCandidate(
          sub: sub,
          reason: NudgeReason.annualRenewalSoon,
          message:
              '${sub.name} renews in ${sub.daysUntilRenewal} days '
              'for ${Subscription.formatPrice(sub.price, sub.currency)} \u2014 '
              '$pct% of your total. Still using it?',
          priority: 1,
        ));
      }
    }

    // Sort by priority (1 = highest)
    candidates.sort((a, b) => a.priority.compareTo(b.priority));
    return candidates;
  }

  int _daysSinceLastReview(Subscription sub) {
    if (sub.lastReviewedAt == null) {
      return DateTime.now().difference(sub.createdAt).inDays;
    }
    return DateTime.now().difference(sub.lastReviewedAt!).inDays;
  }

  int _monthsActive(Subscription sub) {
    return DateTime.now().difference(sub.createdAt).inDays ~/ 30;
  }

  int _daysAgo(DateTime date) {
    return DateTime.now().difference(date).inDays;
  }
}

import '../models/nudge_candidate.dart';
import '../models/subscription.dart';

/// Heuristic nudge engine — evaluates all active subscriptions
/// and returns candidates that deserve a "should I keep this?" prompt.
///
/// Runs locally. No API calls. No ongoing cost.
class NudgeEngine {
  /// Evaluate all subs and return nudge-worthy candidates,
  /// sorted by priority (1 = highest).
  List<NudgeCandidate> evaluate(List<Subscription> subs) {
    final candidates = <NudgeCandidate>[];
    final totalYearly = subs
        .where((s) => s.isActive)
        .fold(0.0, (sum, s) => sum + s.yearlyEquivalent);

    for (final sub in subs.where((s) => s.isActive)) {
      // Skip if user explicitly confirmed keeping within last 90 days
      if (sub.keepConfirmed && sub.lastReviewedAt != null) {
        final daysSinceReview =
            DateTime.now().difference(sub.lastReviewedAt!).inDays;
        if (daysSinceReview < 90) continue;
      }

      // Rule 1: Expensive + old — over £10/mo, not reviewed in 90+ days
      if (sub.monthlyEquivalent >= 10 && _daysSinceLastReview(sub) > 90) {
        final sym = Subscription.currencySymbol(sub.currency);
        final pct = totalYearly > 0
            ? (sub.yearlyEquivalent / totalYearly * 100).round()
            : 0;
        candidates.add(NudgeCandidate(
          sub: sub,
          reason: NudgeReason.expensiveUnreviewed,
          message:
              'You\'ve been paying $sym${sub.monthlyEquivalent.toStringAsFixed(2)}/mo '
              'for ${_monthsActive(sub)} months \u2014 $pct% of your yearly spend. Still using it?',
          priority: 2,
        ));
      }

      // Rule 2: Trial converted + never reviewed
      if (sub.isTrap == true &&
          sub.trialExpiresAt != null &&
          DateTime.now().isAfter(sub.trialExpiresAt!) &&
          _daysSinceLastReview(sub) > 14) {
        final sym = Subscription.currencySymbol(sub.currency);
        candidates.add(NudgeCandidate(
          sub: sub,
          reason: NudgeReason.trialConverted,
          message:
              'Your ${sub.name} trial converted '
              '${_daysAgo(sub.trialExpiresAt!)} days ago. '
              'Worth keeping at $sym${sub.price.toStringAsFixed(2)}/${sub.cycle.shortLabel}?',
          priority: 1,
        ));
      }

      // Rule 3: Renewal approaching + expensive (>£15/mo, within 7 days)
      if (sub.monthlyEquivalent >= 15 &&
          sub.daysUntilRenewal <= 7 &&
          sub.daysUntilRenewal > 0) {
        final sym = Subscription.currencySymbol(sub.currency);
        final pct = totalYearly > 0
            ? (sub.yearlyEquivalent / totalYearly * 100).round()
            : 0;
        candidates.add(NudgeCandidate(
          sub: sub,
          reason: NudgeReason.renewalApproaching,
          message:
              '${sub.name} renews in ${sub.daysUntilRenewal} days '
              'at $sym${sub.price.toStringAsFixed(2)} \u2014 '
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
            .fold(0.0, (sum, s) => sum + s.monthlyEquivalent);
        final sym = Subscription.currencySymbol(sub.currency);
        candidates.add(NudgeCandidate(
          sub: sub,
          reason: NudgeReason.duplicateCategory,
          message:
              'You have ${sameCategorySubs.length + 1} ${sub.category} '
              'subscriptions totalling '
              '$sym${totalMonthly.toStringAsFixed(2)}/mo. Need them all?',
          priority: 3,
        ));
      }

      // Rule 5: Annual sub approaching renewal (30 days out)
      if (sub.cycle == BillingCycle.yearly &&
          sub.daysUntilRenewal <= 30 &&
          sub.daysUntilRenewal > 7) {
        final sym = Subscription.currencySymbol(sub.currency);
        final pct = totalYearly > 0
            ? (sub.yearlyEquivalent / totalYearly * 100).round()
            : 0;
        candidates.add(NudgeCandidate(
          sub: sub,
          reason: NudgeReason.annualRenewalSoon,
          message:
              '${sub.name} renews in ${sub.daysUntilRenewal} days '
              'for $sym${sub.price.toStringAsFixed(2)} \u2014 '
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

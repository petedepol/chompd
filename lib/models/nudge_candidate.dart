import 'subscription.dart';

/// Result from the nudge engine — a subscription that deserves
/// a "should I keep this?" prompt.
class NudgeCandidate {
  final Subscription sub;
  final NudgeReason reason;
  final String message;

  /// Priority: 1 = highest urgency.
  final int priority;

  const NudgeCandidate({
    required this.sub,
    required this.reason,
    required this.message,
    required this.priority,
  });
}

/// Why the nudge was triggered.
enum NudgeReason {
  trialConverted,
  expensiveUnreviewed,
  renewalApproaching,
  duplicateCategory,
  annualRenewalSoon,
}

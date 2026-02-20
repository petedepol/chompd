import '../config/constants.dart';

/// User's entitlement tier.
enum UserTier {
  free,   // Post-trial or never started trial
  trial,  // Within 7-day trial period
  pro,    // Paid £4.99
}

/// Immutable snapshot of the user's current entitlement state.
///
/// Single source of truth for what the user can do. Every feature gate
/// in the app derives from this.
class Entitlement {
  final UserTier tier;
  final DateTime? trialStartDate; // null if never started
  final DateTime? trialEndDate;   // null if never started

  const Entitlement({
    this.tier = UserTier.free,
    this.trialStartDate,
    this.trialEndDate,
  });

  // ─── Tier Checks ───

  bool get isFree => tier == UserTier.free;
  bool get isTrial => tier == UserTier.trial;
  bool get isPro => tier == UserTier.pro;

  /// Has full Pro-level access (trial or paid).
  bool get hasFullAccess => isPro || isTrial;

  // ─── Trial State ───

  /// Days remaining in the trial (0 if not on trial or expired).
  int get trialDaysRemaining {
    if (trialEndDate == null || !isTrial) return 0;
    final remaining = trialEndDate!.difference(DateTime.now()).inDays;
    return remaining.clamp(0, AppConstants.trialDurationDays);
  }

  /// Whether the user's trial has expired (was on trial, now free).
  bool get isTrialExpired =>
      trialStartDate != null && isFree && trialEndDate != null &&
      DateTime.now().isAfter(trialEndDate!);

  /// Whether the trial is in its urgent phase (day 5+).
  bool get isTrialUrgent => isTrial && trialDaysRemaining <= 3;

  // ─── Feature Gates ───

  int get maxSubscriptions =>
      hasFullAccess ? 999 : AppConstants.freeMaxSubscriptions;

  int get maxScans =>
      hasFullAccess ? 999 : AppConstants.freeMaxScans;

  bool get hasSmartReminders => hasFullAccess;
  bool get hasUnlimitedScans => hasFullAccess;
  bool get hasUnlimitedSubs => hasFullAccess;
  bool get hasFullDashboard => hasFullAccess;
  bool get hasAllCancelGuides => hasFullAccess;
  bool get hasSmartNudges => hasFullAccess;
  bool get hasSavingsCards => hasFullAccess;
  bool get hasCsvExport => hasFullAccess;

  List<int> get reminderDays =>
      hasSmartReminders
          ? AppConstants.proReminderDays
          : AppConstants.freeReminderDays;

  // ─── Copy ───

  Entitlement copyWith({
    UserTier? tier,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
  }) {
    return Entitlement(
      tier: tier ?? this.tier,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
    );
  }

  @override
  String toString() =>
      'Entitlement(tier: $tier, trialDaysRemaining: $trialDaysRemaining)';
}

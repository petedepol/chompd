import 'package:isar/isar.dart';

import 'scan_result.dart';
import 'trap_result.dart';

part 'subscription.g.dart';

/// Billing cycle options.
enum BillingCycle {
  weekly,
  monthly,
  quarterly,
  yearly;

  String get label {
    switch (this) {
      case BillingCycle.weekly:
        return 'Weekly';
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.quarterly:
        return 'Quarterly';
      case BillingCycle.yearly:
        return 'Yearly';
    }
  }

  String get shortLabel {
    switch (this) {
      case BillingCycle.weekly:
        return 'wk';
      case BillingCycle.monthly:
        return 'mo';
      case BillingCycle.quarterly:
        return 'qtr';
      case BillingCycle.yearly:
        return 'yr';
    }
  }

  int get approximateDays {
    switch (this) {
      case BillingCycle.weekly:
        return 7;
      case BillingCycle.monthly:
        return 30;
      case BillingCycle.quarterly:
        return 90;
      case BillingCycle.yearly:
        return 365;
    }
  }

  /// Parse a billing cycle from a string (e.g. 'monthly', 'yearly').
  static BillingCycle fromString(String value) {
    return switch (value.toLowerCase()) {
      'weekly' => BillingCycle.weekly,
      'monthly' => BillingCycle.monthly,
      'quarterly' => BillingCycle.quarterly,
      'yearly' => BillingCycle.yearly,
      _ => BillingCycle.monthly,
    };
  }
}

/// How the subscription was added.
enum SubscriptionSource {
  manual,
  aiScan,
  quickAdd,
}

/// Reminder configuration embedded in each subscription.
@embedded
class ReminderConfig {
  /// Days before renewal (0 = morning-of).
  int daysBefore = 0;

  /// Whether this reminder is enabled.
  bool enabled = true;

  /// Whether this reminder requires Pro.
  bool requiresPro = false;
}

/// Core subscription data model — stored in Isar.
@collection
class Subscription {
  Id id = Isar.autoIncrement;

  /// Unique string identifier (UUID).
  @Index(unique: true)
  String uid = '';

  /// Service name (e.g. "Netflix").
  @Index()
  String name = '';

  /// Price per billing cycle.
  double price = 0.0;

  /// ISO 4217 currency code.
  String currency = 'GBP';

  /// Billing frequency.
  @enumerated
  BillingCycle cycle = BillingCycle.monthly;

  /// Next renewal date.
  DateTime nextRenewal = DateTime.now();

  /// Category for grouping and colour coding.
  @Index()
  String category = 'Other';

  /// Whether currently in a free trial.
  bool isTrial = false;

  /// When the trial ends (null if not a trial).
  DateTime? trialEndDate;

  /// Whether the subscription is active.
  @Index()
  bool isActive = true;

  /// When the user marked it as cancelled.
  DateTime? cancelledDate;

  /// Icon identifier (first letter, emoji, or asset name).
  String? iconName;

  /// Brand colour as hex string (e.g. "#E50914").
  String? brandColor;

  /// How this subscription was created.
  @enumerated
  SubscriptionSource source = SubscriptionSource.manual;

  /// When this record was created.
  DateTime createdAt = DateTime.now();

  /// Reminder schedule.
  List<ReminderConfig> reminders = [];

  // ─── Trap Scanner Fields ───

  /// Whether this subscription was flagged as a dark pattern trap.
  bool? isTrap;

  /// Trap type: 'trial_bait', 'price_framing', 'hidden_renewal', 'cancel_friction'.
  String? trapType;

  /// Introductory / trial price (what the user pays now).
  double? trialPrice;

  /// How many days the trial lasts.
  int? trialDurationDays;

  /// The real price after the trial / intro period ends.
  double? realPrice;

  /// Calculated annual cost at the real price.
  double? realAnnualCost;

  /// Trap severity: 'low', 'medium', 'high'.
  String? trapSeverity;

  /// Exact trial expiry timestamp (for aggressive alerts).
  DateTime? trialExpiresAt;

  /// Whether aggressive trial alerts have been scheduled.
  bool trialReminderSet = false;

  // ─── Nudge / Review Fields ───

  /// Last time user confirmed "I want to keep this".
  DateTime? lastReviewedAt;

  /// Last time we showed a nudge for this sub.
  DateTime? lastNudgedAt;

  /// User explicitly said "keep it" — suppress nudges for 90 days.
  bool keepConfirmed = false;

  // ─── Computed Helpers ───

  /// Days until next renewal from now.
  int get daysUntilRenewal {
    return nextRenewal.difference(DateTime.now()).inDays;
  }

  /// Days remaining in trial (null if not a trial).
  int? get trialDaysRemaining {
    if (!isTrial || trialEndDate == null) return null;
    return trialEndDate!.difference(DateTime.now()).inDays;
  }

  /// Monthly equivalent price for consistent comparisons.
  double get monthlyEquivalent {
    switch (cycle) {
      case BillingCycle.weekly:
        return price * 4.33;
      case BillingCycle.monthly:
        return price;
      case BillingCycle.quarterly:
        return price / 3;
      case BillingCycle.yearly:
        return price / 12;
    }
  }

  /// Annual cost regardless of billing cycle.
  double get yearlyEquivalent {
    switch (cycle) {
      case BillingCycle.weekly:
        return price * 52;
      case BillingCycle.monthly:
        return price * 12;
      case BillingCycle.quarterly:
        return price * 4;
      case BillingCycle.yearly:
        return price;
    }
  }

  /// Price display string (e.g. "£15.99/mo").
  String get priceDisplay {
    final symbol = currencySymbol(currency);
    return '$symbol${price.toStringAsFixed(2)}/${cycle.shortLabel}';
  }

  static String currencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'GBP':
        return '\u00A3';
      case 'USD':
        return '\$';
      case 'EUR':
        return '\u20AC';
      default:
        return '$code ';
    }
  }

  /// Build a Subscription from AI scan + trap detection results.
  ///
  /// Used by the "Track Trial Anyway" flow to create a subscription
  /// with all trap metadata populated.
  static Subscription fromScanWithTrap(ScanResult scan, TrapResult trap) {
    final now = DateTime.now();
    final cycle = BillingCycle.fromString(scan.billingCycle);

    final sub = Subscription()
      ..uid =
          '${scan.serviceName.toLowerCase().replaceAll(' ', '-')}-${now.millisecondsSinceEpoch}'
      ..name = scan.serviceName
      ..price = scan.price
      ..currency = scan.currency
      ..cycle = cycle
      ..nextRenewal =
          scan.nextRenewal ?? now.add(Duration(days: cycle.approximateDays))
      ..category = scan.category ?? 'Other'
      ..isTrial = scan.isTrial || (trap.trialDurationDays != null)
      ..trialEndDate = scan.trialEndDate
      ..isActive = true
      ..iconName = scan.iconName
      ..brandColor = scan.brandColor
      ..source = SubscriptionSource.aiScan
      ..createdAt = now
      // Trap fields
      ..isTrap = trap.isTrap
      ..trapType = trap.trapType?.name
      ..trialPrice = trap.trialPrice
      ..trialDurationDays = trap.trialDurationDays
      ..realPrice = trap.realPrice
      ..realAnnualCost = trap.realAnnualCost
      ..trapSeverity = trap.severity.name;

    // Calculate trial expiry from duration
    if (trap.trialDurationDays != null) {
      sub.trialExpiresAt = now.add(Duration(days: trap.trialDurationDays!));
      sub.trialEndDate ??= sub.trialExpiresAt;
    }

    return sub;
  }
}

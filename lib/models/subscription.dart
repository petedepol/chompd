import 'package:isar/isar.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/exchange_rate_service.dart';
import '../utils/date_helpers.dart';
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

/// Extension providing localised billing cycle labels.
extension BillingCycleL10n on BillingCycle {
  /// Localised full label (e.g. "Weekly", "Monthly").
  String localLabel(S l) {
    switch (this) {
      case BillingCycle.weekly:
        return l.cycleWeekly;
      case BillingCycle.monthly:
        return l.cycleMonthly;
      case BillingCycle.quarterly:
        return l.cycleQuarterly;
      case BillingCycle.yearly:
        return l.cycleYearly;
    }
  }

  /// Localised short label (e.g. "wk", "mo").
  String localShortLabel(S l) {
    switch (this) {
      case BillingCycle.weekly:
        return l.cycleWeeklyShort;
      case BillingCycle.monthly:
        return l.cycleMonthlyShort;
      case BillingCycle.quarterly:
        return l.cycleQuarterlyShort;
      case BillingCycle.yearly:
        return l.cycleYearlyShort;
    }
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
  /// Values match the Supabase `service_category` enum.
  @Index()
  String category = 'other';

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

  /// AI-generated warning explaining WHY this is a trap.
  String? trapWarningMessage;

  /// Exact trial expiry timestamp (for aggressive alerts).
  DateTime? trialExpiresAt;

  /// Whether aggressive trial alerts have been scheduled.
  bool trialReminderSet = false;

  // ─── Service Matching ───

  /// UUID from ServiceCache if matched to a known service, null if unmatched.
  String? matchedServiceId;

  /// Whether this subscription is matched to a known service in our database.
  @ignore
  bool get isMatched => matchedServiceId != null;

  // ─── Nudge / Review Fields ───

  /// Last time user confirmed "I want to keep this".
  DateTime? lastReviewedAt;

  /// Last time we showed a nudge for this sub.
  DateTime? lastNudgedAt;

  /// User explicitly said "keep it" — suppress nudges for 90 days.
  bool keepConfirmed = false;

  /// User swiped to dismiss the cancelled card from the home screen graveyard.
  /// The subscription still counts towards total savings — just hidden from the list.
  bool cancelledDismissed = false;

  // ─── Sync Fields ───

  /// Last time this record was modified (for sync conflict resolution).
  DateTime updatedAt = DateTime.now();

  /// Soft-delete timestamp (null = not deleted; set = deleted).
  DateTime? deletedAt;

  // ─── Computed Helpers ───

  /// Active reminder days for this subscription (or null = use global default).
  List<int>? get customReminderDays {
    if (reminders.isEmpty) return null;
    return reminders.where((r) => r.enabled).map((r) => r.daysBefore).toList();
  }

  /// Days until next renewal from now (can be negative if overdue).
  int get daysUntilRenewal {
    return nextRenewal.difference(DateTime.now()).inDays;
  }

  /// Human-friendly renewal label.
  ///
  /// Future: "Renews today/tomorrow/in X days"
  /// Recent past (≤7 days): "Renewed yesterday/X days ago"
  /// Old past (>7 days): "Renews 14 Mar 2026" — shows the date so
  /// users can spot incorrect dates and fix them.
  String get renewalLabel => localRenewalLabel(null);

  /// Localised renewal label. Pass [l] for full localisation.
  /// Falls back to English when [l] is null.
  /// [locale] is passed to [DateHelpers.shortDate] for month name localisation.
  String localRenewalLabel(S? l, {String? locale}) {
    final days = daysUntilRenewal;
    if (l != null) {
      if (days == 0) return l.renewsToday;
      if (days == 1) return l.renewsTomorrow;
      if (days > 1 && days <= 30) return l.renewsInDays(days);
      if (days > 30) return l.renewsOnDate(DateHelpers.shortDate(nextRenewal, locale: locale));
      if (days == -1) return l.renewedYesterday;
      if (days >= -7) return l.renewedDaysAgo(-days);
      return l.renewsOnDate(DateHelpers.shortDate(nextRenewal, locale: locale));
    }
    // Fallback English (used in model-only contexts)
    if (days == 0) return 'Renews today';
    if (days == 1) return 'Renews tomorrow';
    if (days > 1 && days <= 30) return 'Renews in $days days';
    if (days > 30) return 'Renews ${DateHelpers.shortDate(nextRenewal, locale: locale)}';
    if (days == -1) return 'Renewed yesterday';
    if (days >= -7) return 'Renewed ${-days} days ago';
    return 'Renews ${DateHelpers.shortDate(nextRenewal, locale: locale)}';
  }

  /// Days remaining in trial (null if not a trial).
  /// Returns 0 for expired trials (never negative).
  int? get trialDaysRemaining {
    if (!isTrial || trialEndDate == null) return null;
    final days = trialEndDate!.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  /// The effective price for spending calculations.
  /// For trap subscriptions, uses realPrice (what they'll actually pay)
  /// so that yearly burn and category totals reflect the true cost.
  double get effectivePrice {
    if (isTrap == true && realPrice != null && realPrice! > 0) {
      return realPrice!;
    }
    return price;
  }

  /// Total paid since subscription was added to Chompd.
  /// Counts billing cycles elapsed since [createdAt].
  /// Always counts at least 1 payment — the user just paid when they add it.
  double get totalPaidSinceCreation {
    final daysSince = DateTime.now().difference(createdAt).inDays;
    final cyclesElapsed = (daysSince / cycle.approximateDays).floor();
    // If added today (daysSince=0), count 1 payment — the user just paid
    final payments = daysSince == 0 ? 1 : cyclesElapsed.clamp(1, 999);
    return effectivePrice * payments;
  }

  /// Monthly equivalent price for consistent comparisons.
  double get monthlyEquivalent {
    final p = effectivePrice;
    switch (cycle) {
      case BillingCycle.weekly:
        return p * 4.33;
      case BillingCycle.monthly:
        return p;
      case BillingCycle.quarterly:
        return p / 3;
      case BillingCycle.yearly:
        return p / 12;
    }
  }

  /// Annual cost regardless of billing cycle.
  double get yearlyEquivalent {
    final p = effectivePrice;
    switch (cycle) {
      case BillingCycle.weekly:
        return p * 52;
      case BillingCycle.monthly:
        return p * 12;
      case BillingCycle.quarterly:
        return p * 4;
      case BillingCycle.yearly:
        return p;
    }
  }

  // ─── Currency Conversion Helpers ───

  /// Effective price converted to a target currency.
  double priceIn(String targetCurrency) =>
      ExchangeRateService.instance.convert(effectivePrice, currency, targetCurrency);

  /// Monthly equivalent converted to a target currency.
  double monthlyEquivalentIn(String targetCurrency) =>
      ExchangeRateService.instance
          .convert(monthlyEquivalent, currency, targetCurrency);

  /// Yearly equivalent converted to a target currency.
  double yearlyEquivalentIn(String targetCurrency) =>
      ExchangeRateService.instance
          .convert(yearlyEquivalent, currency, targetCurrency);

  /// Price display string (e.g. "£15.99/mo" or "10.00 zł/mo").
  /// Uses effectivePrice so trap subs show real cost.
  String get priceDisplay {
    return '${formatPrice(effectivePrice, currency)}/${cycle.shortLabel}';
  }

  /// The currency symbol for a given ISO 4217 code.
  static String currencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'GBP':
        return '\u00A3';
      case 'USD':
        return '\$';
      case 'EUR':
        return '\u20AC';
      case 'JPY':
        return '\u00A5';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'PLN':
        return 'z\u0142';
      case 'CHF':
        return 'CHF ';
      case 'SEK':
      case 'NOK':
      case 'DKK':
        return 'kr';
      default:
        return '$code ';
    }
  }

  /// Whether the currency symbol goes after the number.
  ///
  /// Suffix: EUR (€), PLN (zł), SEK/NOK/DKK (kr)
  /// Prefix: GBP (£), USD ($), JPY (¥), CAD (C$), AUD (A$), CHF
  static bool isSymbolSuffix(String code) {
    switch (code.toUpperCase()) {
      case 'EUR':
      case 'PLN':
      case 'SEK':
      case 'NOK':
      case 'DKK':
        return true;
      default:
        return false;
    }
  }

  /// Format a price with the correct symbol placement.
  ///
  /// Prefix currencies: "£15.99", "$20.00"
  /// Suffix currencies: "15.99 zł", "10.00 kr"
  static String formatPrice(double amount, String currencyCode, {int decimals = 2}) {
    final sym = currencySymbol(currencyCode);
    final value = amount.toStringAsFixed(decimals);
    if (isSymbolSuffix(currencyCode)) {
      return '$value $sym';
    }
    return '$sym$value';
  }

  /// Build a Subscription from AI scan + trap detection results.
  ///
  /// Used by the "Track Trial Anyway" flow to create a subscription
  /// with all trap metadata populated.
  static Subscription fromScanWithTrap(ScanResult scan, TrapResult trap) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cycle = BillingCycle.fromString(scan.billingCycle ?? 'monthly');

    // Determine the effective trial end date:
    // 1. AI extracted a future date → use it
    // 2. AI extracted a PAST date → trial expired, clear it
    // 3. No date extracted but trap has duration → calculate from now
    // 4. No date at all → keep AI's isTrial flag but no expiry date
    final bool trialEndDateIsInPast =
        scan.trialEndDate != null && scan.trialEndDate!.isBefore(today);

    DateTime? effectiveTrialEnd;
    if (scan.trialEndDate != null && !trialEndDateIsInPast) {
      effectiveTrialEnd = scan.trialEndDate;
    } else if (!trialEndDateIsInPast && trap.trialDurationDays != null) {
      effectiveTrialEnd = now.add(Duration(days: trap.trialDurationDays!));
    }

    // Trial is active if:
    // - AI says trial AND no explicit past expiry date, OR
    // - trap has duration days and we calculated a future expiry
    final bool aiSaysTrial = scan.isTrial || trap.trialDurationDays != null;
    final bool trialStillActive = aiSaysTrial && !trialEndDateIsInPast;

    final sub = Subscription()
      ..uid =
          '${scan.serviceName.toLowerCase().replaceAll(' ', '-')}-${now.millisecondsSinceEpoch}'
      ..name = scan.serviceName
      ..price = scan.price ?? 0
      ..currency = scan.currency
      ..cycle = cycle
      ..nextRenewal = _nextFutureRenewal(scan.nextRenewal, cycle)
      ..category = scan.category ?? 'other'
      ..isTrial = trialStillActive
      ..trialEndDate = trialStillActive ? effectiveTrialEnd : null
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
      ..trapSeverity = trap.severity.name
      ..trapWarningMessage = trap.warningMessage.isNotEmpty ? trap.warningMessage : null;

    // Set trial expiry and override nextRenewal only when we have
    // a concrete future expiry date (not just isTrial with no date).
    if (trialStillActive && effectiveTrialEnd != null) {
      sub.trialExpiresAt = effectiveTrialEnd;
      // For trap/trial subs, "next renewal" = when trial expires
      // and real charge kicks in.
      sub.nextRenewal = effectiveTrialEnd;
    }

    return sub;
  }

  // ─── Supabase Serialization ───

  /// Convert to Supabase-compatible map for upsert.
  Map<String, dynamic> toSupabaseMap(String userId) {
    return {
      'user_id': userId,
      'uid': uid,
      'name': name,
      'price': price,
      'currency': currency,
      'cycle': cycle.name,
      'next_renewal': nextRenewal.toUtc().toIso8601String(),
      'category': category,
      'is_trial': isTrial,
      'trial_end_date': trialEndDate?.toUtc().toIso8601String(),
      'is_active': isActive,
      'cancelled_date': cancelledDate?.toUtc().toIso8601String(),
      'icon_name': iconName,
      'brand_color': brandColor,
      'source': source.name,
      'is_trap': isTrap,
      'trap_type': trapType,
      'trial_price': trialPrice,
      'trial_duration_days': trialDurationDays,
      'real_price': realPrice,
      'real_annual_cost': realAnnualCost,
      'trap_severity': trapSeverity,
      'trap_warning_message': trapWarningMessage,
      'trial_expires_at': trialExpiresAt?.toUtc().toIso8601String(),
      'trial_reminder_set': trialReminderSet,
      'matched_service_id': matchedServiceId,
      'last_reviewed_at': lastReviewedAt?.toUtc().toIso8601String(),
      'last_nudged_at': lastNudgedAt?.toUtc().toIso8601String(),
      'keep_confirmed': keepConfirmed,
      'cancelled_dismissed': cancelledDismissed,
      'reminders': reminders
          .map((r) => {
                'daysBefore': r.daysBefore,
                'enabled': r.enabled,
                'requiresPro': r.requiresPro,
              })
          .toList(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  /// Create a Subscription from a Supabase row.
  static Subscription fromSupabaseMap(Map<String, dynamic> row) {
    final sub = Subscription()
      ..uid = row['uid'] as String
      ..name = row['name'] as String
      ..price = (row['price'] as num).toDouble()
      ..currency = row['currency'] as String? ?? 'GBP'
      ..cycle = BillingCycle.fromString(row['cycle'] as String? ?? 'monthly')
      ..nextRenewal = DateTime.parse(row['next_renewal'] as String)
      ..category = row['category'] as String? ?? 'other'
      ..isTrial = row['is_trial'] as bool? ?? false
      ..isActive = row['is_active'] as bool? ?? true
      ..source = SubscriptionSource.values.firstWhere(
        (e) => e.name == (row['source'] as String?),
        orElse: () => SubscriptionSource.manual,
      )
      ..createdAt = DateTime.parse(row['created_at'] as String)
      ..updatedAt = DateTime.parse(row['updated_at'] as String);

    // Nullable fields
    if (row['trial_end_date'] != null) {
      sub.trialEndDate = DateTime.parse(row['trial_end_date'] as String);
    }
    if (row['cancelled_date'] != null) {
      sub.cancelledDate = DateTime.parse(row['cancelled_date'] as String);
    }
    sub.iconName = row['icon_name'] as String?;
    sub.brandColor = row['brand_color'] as String?;
    sub.isTrap = row['is_trap'] as bool?;
    sub.trapType = row['trap_type'] as String?;
    if (row['trial_price'] != null) {
      sub.trialPrice = (row['trial_price'] as num).toDouble();
    }
    sub.trialDurationDays = row['trial_duration_days'] as int?;
    if (row['real_price'] != null) {
      sub.realPrice = (row['real_price'] as num).toDouble();
    }
    if (row['real_annual_cost'] != null) {
      sub.realAnnualCost = (row['real_annual_cost'] as num).toDouble();
    }
    sub.trapSeverity = row['trap_severity'] as String?;
    sub.trapWarningMessage = row['trap_warning_message'] as String?;
    if (row['trial_expires_at'] != null) {
      sub.trialExpiresAt = DateTime.parse(row['trial_expires_at'] as String);
    }
    sub.trialReminderSet = row['trial_reminder_set'] as bool? ?? false;
    sub.matchedServiceId = row['matched_service_id'] as String?;
    if (row['last_reviewed_at'] != null) {
      sub.lastReviewedAt = DateTime.parse(row['last_reviewed_at'] as String);
    }
    if (row['last_nudged_at'] != null) {
      sub.lastNudgedAt = DateTime.parse(row['last_nudged_at'] as String);
    }
    sub.keepConfirmed = row['keep_confirmed'] as bool? ?? false;
    sub.cancelledDismissed = row['cancelled_dismissed'] as bool? ?? false;
    if (row['deleted_at'] != null) {
      sub.deletedAt = DateTime.parse(row['deleted_at'] as String);
    }

    // Reminders from JSONB
    final remindersJson = row['reminders'] as List<dynamic>?;
    if (remindersJson != null) {
      sub.reminders = remindersJson
          .map((r) => ReminderConfig()
            ..daysBefore = (r['daysBefore'] as num?)?.toInt() ?? 0
            ..enabled = r['enabled'] as bool? ?? true
            ..requiresPro = r['requiresPro'] as bool? ?? false)
          .toList();
    }

    return sub;
  }

  /// Ensures a renewal date is in the future.
  /// If [extracted] is null, defaults to now + one billing cycle.
  /// If [extracted] is in the past, rolls forward by cycle steps until future.
  static DateTime _nextFutureRenewal(DateTime? extracted, BillingCycle cycle) {
    final now = DateTime.now();
    if (extracted == null) {
      return now.add(Duration(days: cycle.approximateDays));
    }
    final today = DateTime(now.year, now.month, now.day);
    if (!extracted.isBefore(today)) return extracted;
    var future = extracted;
    final step = cycle.approximateDays;
    while (future.isBefore(today)) {
      future = future.add(Duration(days: step));
    }
    return future;
  }
}

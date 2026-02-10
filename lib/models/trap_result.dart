/// Result from AI trap detection analysis.
///
/// This is a plain Dart class (not stored in Isar) — it's the
/// structured trap analysis returned alongside the regular [ScanResult].
class TrapResult {
  final bool isTrap;
  final TrapType? trapType;
  final TrapSeverity severity;
  final double? trialPrice;
  final int? trialDurationDays;
  final double? realPrice;
  final String? realBillingCycle; // 'weekly', 'monthly', 'yearly'
  final double? realAnnualCost;
  final int confidence; // 0-100
  final String warningMessage;
  final String? serviceName;

  const TrapResult({
    required this.isTrap,
    this.trapType,
    required this.severity,
    this.trialPrice,
    this.trialDurationDays,
    this.realPrice,
    this.realBillingCycle,
    this.realAnnualCost,
    required this.confidence,
    required this.warningMessage,
    this.serviceName,
  });

  /// No trap detected — safe result.
  static const clean = TrapResult(
    isTrap: false,
    severity: TrapSeverity.low,
    confidence: 0,
    warningMessage: '',
  );

  /// Parse from the Claude Haiku JSON `trap` object.
  factory TrapResult.fromJson(Map<String, dynamic> json) {
    return TrapResult(
      isTrap: json['is_trap'] as bool? ?? false,
      trapType: _parseTrapType(json['trap_type'] as String?),
      severity: _parseSeverity(json['severity'] as String? ?? 'low'),
      trialPrice: (json['trial_price'] as num?)?.toDouble(),
      trialDurationDays: json['trial_duration_days'] as int?,
      realPrice: (json['real_price'] as num?)?.toDouble(),
      realBillingCycle: json['billing_cycle'] as String?,
      realAnnualCost: (json['real_annual_cost'] as num?)?.toDouble(),
      confidence: json['confidence'] as int? ?? 0,
      warningMessage: json['warning_message'] as String? ?? '',
      serviceName: json['service_name'] as String?,
    );
  }

  static TrapType? _parseTrapType(String? type) {
    return switch (type) {
      'trial_bait' => TrapType.trialBait,
      'price_framing' => TrapType.priceFraming,
      'hidden_renewal' => TrapType.hiddenRenewal,
      'cancel_friction' => TrapType.cancelFriction,
      _ => null,
    };
  }

  static TrapSeverity _parseSeverity(String severity) {
    return switch (severity) {
      'high' => TrapSeverity.high,
      'medium' => TrapSeverity.medium,
      _ => TrapSeverity.low,
    };
  }

  /// The amount the user would save by skipping this trap.
  double get savingsAmount => realAnnualCost ?? realPrice ?? 0;

  /// Human-readable trap type label.
  String get trapTypeLabel => switch (trapType) {
        TrapType.trialBait => 'Trial Bait',
        TrapType.priceFraming => 'Price Framing',
        TrapType.hiddenRenewal => 'Hidden Renewal',
        TrapType.cancelFriction => 'Cancel Friction',
        null => 'Subscription Trap',
      };
}

/// Types of subscription dark patterns.
enum TrapType {
  trialBait, // £1 trial → £99/year
  priceFraming, // "£1.92/week" hiding £99/year
  hiddenRenewal, // auto-renew buried in fine print
  cancelFriction, // deliberately hard to cancel
}

/// How severe / deceptive the trap is.
enum TrapSeverity {
  low, // standard trial (Netflix free month → £15.99/mo)
  medium, // intro price that increases significantly (£1 → £9.99/mo)
  high, // extreme price jump or deceptive framing (£1 → £99.99/year)
}

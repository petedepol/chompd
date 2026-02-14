/// Result from an AI scan of a screenshot.
///
/// This is a plain Dart class (not stored in Isar) — it's the
/// structured response from Claude Haiku before the user confirms.
class ScanResult {
  final String serviceName;

  /// Price per billing cycle. Null if not found in the image.
  final double? price;

  final String currency;

  /// Billing cycle. Null if not determinable from the image.
  final String? billingCycle;

  final DateTime? nextRenewal;
  final bool isTrial;
  final DateTime? trialEndDate;
  final String? category;
  final String? iconName;
  final String? brandColor;

  /// Per-field confidence scores (0.0–1.0).
  final Map<String, double> confidence;

  /// Overall confidence (average of per-field scores).
  final double overallConfidence;

  /// Which tier matched (1 = auto-detect, 2 = quick confirm, 3 = full AI).
  final int tier;

  /// Raw source type: 'email', 'bank_statement', 'app_store', 'receipt', 'billing_page', 'other'.
  final String? sourceType;

  /// Fields that could not be extracted from the image.
  final List<String> missingFields;

  /// Brief AI explanation of what was found and what's missing.
  final String? extractionNotes;

  /// Whether this subscription is expiring (already cancelled) rather than renewing.
  ///
  /// On iOS subscriptions screens, "Expires on [date]" means the user already
  /// cancelled and the service will stop on that date. "Renews [date]" means
  /// it's an active subscription that will auto-charge. This field helps us
  /// distinguish between the two so we don't track cancelled subs as active.
  final bool isExpiring;

  const ScanResult({
    required this.serviceName,
    this.price,
    required this.currency,
    this.billingCycle,
    this.nextRenewal,
    this.isTrial = false,
    this.trialEndDate,
    this.category,
    this.iconName,
    this.brandColor,
    required this.confidence,
    required this.overallConfidence,
    required this.tier,
    this.sourceType,
    this.missingFields = const [],
    this.extractionNotes,
    this.isExpiring = false,
  });

  /// Parse from the Claude Haiku JSON response.
  ///
  /// All numeric casts use defensive `is num` checks because Claude may
  /// return `false` or other non-numeric types for fields it can't determine.
  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final conf = <String, double>{};
    if (json['confidence'] is Map) {
      (json['confidence'] as Map).forEach((key, value) {
        if (value is num) {
          conf[key.toString()] = value.toDouble();
        }
      });
    }

    // Parse missing_fields array
    final missing = <String>[];
    if (json['missing_fields'] is List) {
      for (final f in json['missing_fields'] as List) {
        missing.add(f.toString());
      }
    }

    return ScanResult(
      serviceName: json['service_name'] as String? ?? 'Unknown',
      price: json['price'] is num ? (json['price'] as num).toDouble() : null,
      currency: json['currency'] as String? ?? 'GBP',
      billingCycle: json['billing_cycle'] is String ? json['billing_cycle'] as String : null,
      nextRenewal: json['next_renewal'] is String
          ? DateTime.tryParse(json['next_renewal'] as String)
          : null,
      isTrial: json['is_trial'] == true,
      trialEndDate: json['trial_end_date'] is String
          ? DateTime.tryParse(json['trial_end_date'] as String)
          : null,
      category: json['category'] is String ? json['category'] as String : null,
      iconName: json['icon'] is String ? json['icon'] as String : null,
      brandColor: json['brand_color'] is String ? json['brand_color'] as String : null,
      confidence: conf,
      overallConfidence:
          json['overall_confidence'] is num ? (json['overall_confidence'] as num).toDouble() : 0.0,
      tier: json['tier'] is num ? (json['tier'] as num).toInt() : 3,
      sourceType: json['source_type'] is String ? json['source_type'] as String : null,
      missingFields: missing,
      extractionNotes: json['extraction_notes'] is String ? json['extraction_notes'] as String : null,
      isExpiring: json['is_expiring'] == true,
    );
  }

  /// Whether this result is confident enough to auto-accept.
  bool get isHighConfidence => overallConfidence >= 0.90;

  /// Whether this needs user clarification.
  bool get needsClarification => overallConfidence < 0.90;

  /// Whether this scan found no subscription at all.
  bool get isNotFound =>
      (serviceName == 'Unknown' || serviceName.isEmpty) &&
      overallConfidence == 0;

  /// Whether critical fields are missing and need user input.
  bool get hasMissingFields => missingFields.isNotEmpty && !isNotFound;

  /// Whether the price specifically needs user input.
  bool get needsPrice => price == null || missingFields.contains('price');

  /// Whether the billing cycle needs user input.
  bool get needsCycle =>
      billingCycle == null || missingFields.contains('billing_cycle');
}

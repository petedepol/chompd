/// Per-service refund template data parsed from Supabase
/// `refund_templates` JSONB.
class RefundTemplateData {
  final String billingMethod;
  final List<RefundStepData> steps;
  final String? emailTemplate;
  final String? emailSubject;
  final String? contactEmail;
  final String? contactUrl;
  final double? successRatePct;
  final int? avgRefundDays;
  final int? refundWindowDays;

  const RefundTemplateData({
    required this.billingMethod,
    required this.steps,
    this.emailTemplate,
    this.emailSubject,
    this.contactEmail,
    this.contactUrl,
    this.successRatePct,
    this.avgRefundDays,
    this.refundWindowDays,
  });

  factory RefundTemplateData.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'];
    final List<RefundStepData> parsedSteps;

    if (rawSteps is List) {
      parsedSteps = rawSteps
          .whereType<Map<String, dynamic>>()
          .map((s) => RefundStepData.fromJson(s))
          .toList();
    } else {
      parsedSteps = [];
    }

    return RefundTemplateData(
      billingMethod: json['billing_method'] as String? ?? 'direct',
      steps: parsedSteps,
      emailTemplate: json['email_template'] as String?,
      emailSubject: json['email_subject'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactUrl: json['contact_url'] as String?,
      successRatePct:
          (json['success_rate_pct'] as num?)?.toDouble(),
      avgRefundDays: json['avg_refund_days'] as int?,
      refundWindowDays: json['refund_window_days'] as int?,
    );
  }

  /// Human-readable billing method label.
  String get billingMethodLabel {
    switch (billingMethod) {
      case 'app_store':
        return 'Apple App Store';
      case 'google_play':
        return 'Google Play';
      case 'direct':
        return 'Direct / Email';
      case 'paypal':
        return 'PayPal';
      case 'stripe':
        return 'Stripe';
      case 'bank_chargeback':
        return 'Bank Chargeback';
      default:
        return billingMethod;
    }
  }

  /// Emoji icon for the billing method.
  String get icon {
    switch (billingMethod) {
      case 'app_store':
        return '\uD83C\uDF4E'; // apple
      case 'google_play':
        return '\u25B6\uFE0F'; // play
      case 'direct':
        return '\u2709\uFE0F'; // envelope
      case 'paypal':
        return '\uD83D\uDCB3'; // credit card
      case 'stripe':
        return '\uD83D\uDCB3'; // credit card
      case 'bank_chargeback':
        return '\uD83C\uDFE6'; // bank
      default:
        return '\uD83D\uDCB0'; // money bag
    }
  }

  /// Format success rate for display.
  String get successRateLabel {
    if (successRatePct != null) return '~${successRatePct!.toStringAsFixed(0)}%';
    return 'Unknown';
  }

  /// Format refund window for display.
  String get refundWindowLabel {
    if (refundWindowDays != null) return '$refundWindowDays days';
    return 'Varies';
  }
}

/// A single step in a refund guide.
class RefundStepData {
  final int step;
  final String title;
  final String? detail;
  final String? url;

  const RefundStepData({
    required this.step,
    required this.title,
    this.detail,
    this.url,
  });

  factory RefundStepData.fromJson(Map<String, dynamic> json) {
    return RefundStepData(
      step: json['step'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      detail: json['detail'] as String?,
      url: json['url'] as String?,
    );
  }
}

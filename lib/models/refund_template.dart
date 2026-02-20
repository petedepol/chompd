/// Platform-specific refund path with steps and optional email template.
class RefundTemplate {
  final String id;
  final String name;
  final RefundPath path;
  final List<String> steps;
  final String? url;
  final String? emailTemplate;
  final String successRate;
  final String timeframe;

  /// Localised name overrides keyed by language code.
  final Map<String, String> nameLocalized;

  /// Localised steps keyed by language code: {'pl': [...], 'de': [...], ...}.
  final Map<String, List<String>> stepsLocalized;

  /// Localised email template keyed by language code.
  final Map<String, String> emailTemplateLocalized;

  /// Localised success rate label keyed by language code.
  final Map<String, String> successRateLocalized;

  /// Localised timeframe label keyed by language code.
  final Map<String, String> timeframeLocalized;

  const RefundTemplate({
    required this.id,
    required this.name,
    required this.path,
    required this.steps,
    this.url,
    this.emailTemplate,
    required this.successRate,
    required this.timeframe,
    this.nameLocalized = const {},
    this.stepsLocalized = const {},
    this.emailTemplateLocalized = const {},
    this.successRateLocalized = const {},
    this.timeframeLocalized = const {},
  });

  /// Returns localised name for [langCode], falling back to English.
  String getName(String langCode) => nameLocalized[langCode] ?? name;

  /// Returns localised steps for [langCode], falling back to English.
  List<String> getSteps(String langCode) => stepsLocalized[langCode] ?? steps;

  /// Returns localised email template for [langCode], falling back to English.
  String? getEmailTemplate(String langCode) =>
      emailTemplateLocalized[langCode] ?? emailTemplate;

  /// Returns localised success rate for [langCode], falling back to English.
  String getSuccessRate(String langCode) =>
      successRateLocalized[langCode] ?? successRate;

  /// Returns localised timeframe for [langCode], falling back to English.
  String getTimeframe(String langCode) =>
      timeframeLocalized[langCode] ?? timeframe;
}

/// The four escalation paths for getting a refund.
enum RefundPath {
  appStore,
  googlePlay,
  directBilling,
  bankChargeback;

  String get icon {
    switch (this) {
      case RefundPath.appStore:
        return '\uD83C\uDF4E'; // apple emoji
      case RefundPath.googlePlay:
        return '\u25B6\uFE0F'; // play button
      case RefundPath.directBilling:
        return '\u2709\uFE0F'; // envelope
      case RefundPath.bankChargeback:
        return '\uD83C\uDFE6'; // bank
    }
  }
}

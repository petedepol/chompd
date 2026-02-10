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

  const RefundTemplate({
    required this.id,
    required this.name,
    required this.path,
    required this.steps,
    this.url,
    this.emailTemplate,
    required this.successRate,
    required this.timeframe,
  });
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

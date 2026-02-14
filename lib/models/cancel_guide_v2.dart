/// A single step in a cancel guide (richer than the old List<String>).
class CancelGuideStep {
  final int step;
  final String title;
  final String detail;
  final String? deeplink;

  const CancelGuideStep({
    required this.step,
    required this.title,
    required this.detail,
    this.deeplink,
  });

  factory CancelGuideStep.fromJson(Map<String, dynamic> json) {
    return CancelGuideStep(
      step: json['step'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      detail: json['detail'] as String? ?? json['title'] as String? ?? '',
      deeplink: json['deeplink'] as String?,
    );
  }
}

/// Cancel guide data parsed from the Supabase `cancel_guides` JSONB.
class CancelGuideData {
  final String platform;
  final List<CancelGuideStep> steps;
  final String? cancelDeeplink;
  final String? cancelWebUrl;
  final int? estimatedMinutes;
  final String? warningText;
  final String? proTip;

  const CancelGuideData({
    required this.platform,
    required this.steps,
    this.cancelDeeplink,
    this.cancelWebUrl,
    this.estimatedMinutes,
    this.warningText,
    this.proTip,
  });

  factory CancelGuideData.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'];
    final List<CancelGuideStep> parsedSteps;

    if (rawSteps is List) {
      parsedSteps = rawSteps
          .whereType<Map<String, dynamic>>()
          .map((s) => CancelGuideStep.fromJson(s))
          .toList();
    } else {
      parsedSteps = [];
    }

    return CancelGuideData(
      platform: json['platform'] as String? ?? 'all',
      steps: parsedSteps,
      cancelDeeplink: json['cancel_deeplink'] as String?,
      cancelWebUrl: json['cancel_web_url'] as String?,
      estimatedMinutes: json['estimated_minutes'] as int?,
      warningText: json['warning_text'] as String?,
      proTip: json['pro_tip'] as String?,
    );
  }

  /// The best URL to open for cancellation (deeplink first, then web).
  String? get bestCancelUrl => cancelDeeplink ?? cancelWebUrl;
}

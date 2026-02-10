/// Step-by-step cancellation guide for a specific service.
///
/// Stored as plain Dart for now — Isar annotations deferred
/// until persistence layer is wired up.
class CancelGuide {
  int id;

  /// Normalised lowercase service name: "netflix", "spotify".
  String serviceName;

  /// Target platform: 'ios', 'android', 'web', 'all'.
  String platform;

  /// Ordered cancellation steps.
  List<String> steps;

  /// iOS Settings URL or deep link.
  String? deepLink;

  /// Direct web cancel page URL.
  String? cancellationUrl;

  /// Extra context, e.g. "Netflix saves your profile for 10 months."
  String? notes;

  /// 1-5 difficulty rating (1 = easy, 5 = deliberately hard).
  int difficultyRating;

  /// When these steps were last verified as correct.
  DateTime? lastVerified;

  CancelGuide({
    this.id = 0,
    required this.serviceName,
    required this.platform,
    required this.steps,
    this.deepLink,
    this.cancellationUrl,
    this.notes,
    required this.difficultyRating,
    this.lastVerified,
  });

  /// Colour representing difficulty.
  ///
  /// 1-2 mint (easy), 3-4 amber (medium-hard), 5 red (very hard).
  String get difficultyLabel {
    switch (difficultyRating) {
      case 1:
        return 'Easy \u2014 straightforward cancel';
      case 2:
        return 'Easy \u2014 one extra step';
      case 3:
        return 'Medium \u2014 takes a few minutes';
      case 4:
        return 'Hard \u2014 they make this deliberately difficult';
      case 5:
        return 'Very hard \u2014 multiple retention screens or fees';
      default:
        return '';
    }
  }
}

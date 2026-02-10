import 'scan_result.dart';
import 'trap_result.dart';

/// Combined result from an AI scan — subscription details + trap analysis.
///
/// The AI scan now returns both a [ScanResult] (subscription extraction)
/// and a [TrapResult] (dark pattern detection) in a single API call.
class ScanOutput {
  final ScanResult subscription;
  final TrapResult trap;

  const ScanOutput({
    required this.subscription,
    required this.trap,
  });

  /// Parse from Claude Haiku JSON response containing both keys.
  factory ScanOutput.fromJson(Map<String, dynamic> json) {
    return ScanOutput(
      subscription:
          ScanResult.fromJson(json['subscription'] as Map<String, dynamic>),
      trap: json['trap'] != null
          ? TrapResult.fromJson(json['trap'] as Map<String, dynamic>)
          : TrapResult.clean,
    );
  }

  /// Whether to show the full trap warning card (medium/high severity).
  bool get shouldShowTrapWarning =>
      trap.isTrap && trap.confidence >= 60 && trap.severity != TrapSeverity.low;

  /// Whether to show a softer trial info notice (low severity).
  bool get shouldShowTrialNotice =>
      trap.isTrap && trap.severity == TrapSeverity.low;
}

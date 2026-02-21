import 'package:flutter/services.dart';

/// Centralised haptic feedback service.
///
/// All haptics route through here so the user's
/// "Haptics Off" setting is respected globally.
class HapticService {
  HapticService._();
  static final HapticService instance = HapticService._();

  bool _enabled = true;

  bool get enabled => _enabled;

  void setEnabled(bool value) => _enabled = value;

  // ─── Feedback Types ───

  /// Success — subscription added, scan complete, save confirmed.
  void success() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Warning — trial expiring, approaching budget.
  void warning() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Selection — tab switch, option selected, toggle.
  void selection() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  /// Light tap — button press, card tap.
  void light() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  /// Error — scan failed, network error (double-tap).
  Future<void> error() async {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    HapticFeedback.heavyImpact();
  }

  /// Celebration — milestone reached, confetti moment.
  Future<void> celebration() async {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    HapticFeedback.lightImpact();
  }
}

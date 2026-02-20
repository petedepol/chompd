import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages in-app review prompt timing.
///
/// Triggers after positive actions (successful scan, cancellation) but only
/// when usage thresholds are met and enough time has passed since the last
/// prompt. Apple/Google naturally rate-limit the native dialog, so we just
/// call `requestReview()` when conditions are met and let the OS decide.
class ReviewService {
  ReviewService._();
  static final instance = ReviewService._();

  static const _kScanCountKey = 'review_scan_count';
  static const _kCancelCountKey = 'review_cancel_count';
  static const _kLastRequestKey = 'review_last_request';

  /// Minimum successful scans before requesting review.
  static const _minScans = 3;

  /// Minimum cancellations before requesting review.
  static const _minCancels = 1;

  /// Minimum days between review requests.
  static const _cooldownDays = 90;

  /// Increment the successful scan counter.
  Future<void> recordScan() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_kScanCountKey) ?? 0;
    await prefs.setInt(_kScanCountKey, count + 1);
  }

  /// Increment the cancellation counter.
  Future<void> recordCancel() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_kCancelCountKey) ?? 0;
    await prefs.setInt(_kCancelCountKey, count + 1);
  }

  /// Check conditions and request review if appropriate.
  ///
  /// Call after positive actions (scan save, cancel completion).
  /// The OS decides whether to actually show the prompt.
  Future<void> maybeRequestReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final scanCount = prefs.getInt(_kScanCountKey) ?? 0;
      final cancelCount = prefs.getInt(_kCancelCountKey) ?? 0;

      // Threshold: 3+ scans OR 1+ cancellations
      if (scanCount < _minScans && cancelCount < _minCancels) {
        debugPrint('[ReviewService] Thresholds not met: scans=$scanCount, cancels=$cancelCount');
        return;
      }

      // Cooldown: not within 90 days of last request
      final lastRequest = prefs.getInt(_kLastRequestKey) ?? 0;
      final daysSinceLast = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(lastRequest))
          .inDays;

      if (lastRequest > 0 && daysSinceLast < _cooldownDays) {
        debugPrint('[ReviewService] Cooldown active: ${_cooldownDays - daysSinceLast} days remaining');
        return;
      }

      // Check availability
      final inAppReview = InAppReview.instance;
      if (!await inAppReview.isAvailable()) {
        debugPrint('[ReviewService] InAppReview not available');
        return;
      }

      // Request review — OS decides whether to show
      debugPrint('[ReviewService] Requesting review (scans=$scanCount, cancels=$cancelCount)');
      await inAppReview.requestReview();

      // Save timestamp
      await prefs.setInt(
        _kLastRequestKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Never crash the app over a review prompt
      debugPrint('[ReviewService] Error: $e');
    }
  }
}

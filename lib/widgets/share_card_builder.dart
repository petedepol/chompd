import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/haptic_service.dart';

/// Builds and shares branded stat text for subscription insights.
///
/// v1: Shares formatted text with stats.
/// v2: Will render a branded image card (1080x1350) for Instagram stories.
class ShareCardBuilder {
  ShareCardBuilder._();

  /// Share the yearly burn stat as formatted text.
  static Future<void> shareYearlyBurn({
    required BuildContext context,
    required double yearlyTotal,
    required int subCount,
    required double totalSaved,
    required int cancelledCount,
    String currencySymbol = '\u00A3',
  }) async {
    HapticService.instance.light();

    final s = currencySymbol;
    final buffer = StringBuffer();
    buffer.writeln(
        'I spend $s${yearlyTotal.toStringAsFixed(0)}/year on $subCount subscriptions \uD83D\uDE33');
    buffer.writeln();
    buffer.writeln(
        'That\u2019s $s${(yearlyTotal / 12).toStringAsFixed(0)}/month or $s${(yearlyTotal / 365).toStringAsFixed(2)}/day');

    if (totalSaved > 0) {
      buffer.writeln();
      buffer.writeln(
          '\u2713 Saved $s${totalSaved.toStringAsFixed(0)} by cancelling $cancelledCount subscription${cancelledCount == 1 ? '' : 's'}');
    }

    buffer.writeln();
    buffer.writeln('Tracked with Chompd \u2014 Scan. Track. Bite back.');

    await Share.share(buffer.toString());
  }

  /// Share savings celebration.
  static Future<void> shareSavings({
    required BuildContext context,
    required double totalSaved,
    required int cancelledCount,
    String currencySymbol = '\u00A3',
  }) async {
    HapticService.instance.light();

    final s = currencySymbol;
    final text =
        'I saved $s${totalSaved.toStringAsFixed(0)} by cancelling $cancelledCount subscription${cancelledCount == 1 ? '' : 's'} \uD83C\uDF89\n\nBite back at subscriptions \u2014 getchompd.com';

    await Share.share(text);
  }
}

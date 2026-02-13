import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/haptic_service.dart';
import '../utils/l10n_extension.dart';

/// Builds and shares branded stat text for subscription insights.
///
/// v1: Shares formatted text with stats.
/// v2: Will render a branded image card (1080x1350) for Instagram stories.
class ShareCardBuilder {
  ShareCardBuilder._();

  /// Get the share position origin from the button's render box.
  /// Required on iPad, helps on iPhone too.
  static Rect? _shareOrigin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

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
    buffer.writeln(context.l10n.shareYearlyBurn(s, yearlyTotal.toStringAsFixed(0), subCount));
    buffer.writeln();
    buffer.writeln(context.l10n.shareMonthlyDaily(s, (yearlyTotal / 12).toStringAsFixed(0), (yearlyTotal / 365).toStringAsFixed(2)));

    if (totalSaved > 0) {
      buffer.writeln();
      buffer.writeln(context.l10n.shareSavedBy(s, totalSaved.toStringAsFixed(0), cancelledCount));
    }

    buffer.writeln();
    buffer.writeln(context.l10n.shareFooter);

    await Share.share(
      buffer.toString(),
      sharePositionOrigin: _shareOrigin(context),
    );
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
    final text = context.l10n.shareSavings(s, totalSaved.toStringAsFixed(0), cancelledCount);

    await Share.share(
      text,
      sharePositionOrigin: _shareOrigin(context),
    );
  }
}

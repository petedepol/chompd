import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/trap_result.dart';
import '../utils/l10n_extension.dart';

/// Small pill badge indicating trap severity level.
///
/// HIGH → red "HIGH RISK", MEDIUM → amber "CAUTION", LOW → blue "INFO".
class SeverityBadge extends StatelessWidget {
  final TrapSeverity severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final Color bgColor;
    final Color textColor;
    final String label;

    switch (severity) {
      case TrapSeverity.high:
        bgColor = c.red.withValues(alpha: 0.15);
        textColor = c.red;
        label = context.l10n.severityHigh;
      case TrapSeverity.medium:
        bgColor = c.amber.withValues(alpha: 0.15);
        textColor = c.amber;
        label = context.l10n.severityCaution;
      case TrapSeverity.low:
        bgColor = c.blue.withValues(alpha: 0.15);
        textColor = c.blue;
        label = context.l10n.severityInfo;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'SpaceMono',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: textColor,
        ),
      ),
    );
  }
}

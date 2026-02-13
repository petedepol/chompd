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

  Color get _bgColor => switch (severity) {
        TrapSeverity.high => ChompdColors.red.withValues(alpha: 0.15),
        TrapSeverity.medium => ChompdColors.amber.withValues(alpha: 0.15),
        TrapSeverity.low => ChompdColors.blue.withValues(alpha: 0.15),
      };

  Color get _textColor => switch (severity) {
        TrapSeverity.high => ChompdColors.red,
        TrapSeverity.medium => ChompdColors.amber,
        TrapSeverity.low => ChompdColors.blue,
      };

  String _label(BuildContext context) => switch (severity) {
        TrapSeverity.high => context.l10n.severityHigh,
        TrapSeverity.medium => context.l10n.severityCaution,
        TrapSeverity.low => context.l10n.severityInfo,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        _label(context),
        style: TextStyle(
          fontFamily: 'SpaceMono',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: _textColor,
        ),
      ),
    );
  }
}

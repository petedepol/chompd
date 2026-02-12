import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../providers/insights_provider.dart';
import '../services/haptic_service.dart';

/// Bevel-style conversational insight card.
///
/// Shows an emoji-headlined insight with bold data points,
/// pagination dots, and tap-to-cycle through multiple insights.
class InsightCard extends StatefulWidget {
  final List<Insight> insights;
  const InsightCard({super.key, required this.insights});

  @override
  State<InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<InsightCard> {
  int _currentIndex = 0;

  void _next() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.insights.length;
    });
    HapticService.instance.light();
  }

  Color _colorForType(InsightType type) {
    switch (type) {
      case InsightType.saving:
        return ChompdColors.mint;
      case InsightType.warning:
        return ChompdColors.amber;
      case InsightType.info:
        return ChompdColors.blue;
      case InsightType.celebration:
        return ChompdColors.mint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final insight = widget.insights[_currentIndex];
    final color = _colorForType(insight.type);

    return GestureDetector(
      onTap: widget.insights.length > 1 ? _next : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ChompdColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji + headline
            Row(
              children: [
                Text(insight.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        insight.headline,
                        key: ValueKey('h_$_currentIndex'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ChompdColors.text,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Body with **bold** markers
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _RichBody(
                  key: ValueKey('b_$_currentIndex'),
                  text: insight.message,
                ),
              ),
            ),

            // Pagination dots
            if (widget.insights.length > 1) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  ...List.generate(
                    widget.insights.length,
                    (i) => Container(
                      margin: const EdgeInsets.only(right: 4),
                      width: i == _currentIndex ? 12 : 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: i == _currentIndex
                            ? color
                            : ChompdColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'tap for more',
                    style: TextStyle(
                      fontSize: 9,
                      color: ChompdColors.textDim.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Parses **bold** markers in text and renders as rich text.
class _RichBody extends StatelessWidget {
  final String text;
  const _RichBody({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    final parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          fontSize: 13,
          height: 1.5,
          fontWeight: i.isOdd ? FontWeight.w700 : FontWeight.w400,
          color: i.isOdd ? ChompdColors.text : ChompdColors.textMid,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

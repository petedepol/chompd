import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/theme.dart';
import '../models/insight_display_data.dart';
import '../providers/combined_insights_provider.dart';
import '../providers/entitlement_provider.dart';
import '../providers/purchase_provider.dart';
import '../providers/service_insight_provider.dart';
import '../screens/paywall/paywall_screen.dart';
import '../services/haptic_service.dart';
import '../services/service_insight_repository.dart';
import '../services/user_insight_repository.dart';
import '../utils/l10n_extension.dart';

/// Carousel card showing curated + AI-generated insights.
///
/// Pro users see the full content with dismiss action.
/// Free users see a teaser with blurred body + paywall CTA.
///
/// Data comes from [combinedInsightsProvider] which merges AI-generated
/// (UserInsight) and curated (ServiceInsight) insights, AI first.
class ServiceInsightCard extends ConsumerStatefulWidget {
  final bool embedded;
  const ServiceInsightCard({super.key, this.embedded = false});

  @override
  ConsumerState<ServiceInsightCard> createState() =>
      _ServiceInsightCardState();
}

class _ServiceInsightCardState extends ConsumerState<ServiceInsightCard> {
  int _currentIndex = 0;
  final Set<int> _markedRead = {};

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final hasInsights = ref.watch(entitlementProvider).hasFullDashboard;
    final insights = ref.watch(combinedInsightsProvider);

    if (insights.isEmpty) return const SizedBox.shrink();

    // Clamp index
    if (_currentIndex >= insights.length) _currentIndex = 0;
    final insight = insights[_currentIndex];

    // Map insightType to emoji and label
    final bool isSavingsType = insight.insightType == 'annual_saving' ||
        insight.insightType == 'plan_optimise';
    final String emoji = isSavingsType ? '\uD83D\uDCB0' : '\uD83D\uDCA1';
    final String label =
        isSavingsType ? l.insightSaveMoney : l.insightDidYouKnow;

    // Map insightType to accent colour
    final Color accentColor;
    switch (insight.insightType) {
      case 'annual_saving':
      case 'plan_optimise':
        accentColor = c.accent;
      case 'price_change':
      case 'cancel_timing':
        accentColor = c.warning;
      case 'alternative':
      case 'overlap':
        accentColor = c.info;
      default:
        accentColor = c.purple;
    }

    // Pro gating: free users see teaser
    if (!hasInsights) {
      return _ProTeaser(
        accentColor: accentColor,
        bgCard: c.bgCard,
        textDim: c.textDim,
      );
    }

    // Mark AI insight as read (once per session)
    if (insight.isAiGenerated && !_markedRead.contains(insight.isarId)) {
      _markedRead.add(insight.isarId);
      UserInsightRepository.instance.markAsRead(insight.isarId);
    }

    return GestureDetector(
      onTap: insights.length > 1
          ? () {
              setState(() {
                _currentIndex = (_currentIndex + 1) % insights.length;
              });
              HapticService.instance.light();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.15),
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji + label + dismiss
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: ChompdTypography.mono(
                          size: 10,
                          weight: FontWeight.w400,
                          color: accentColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _dismiss(insight),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: c.textDim,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      insight.title,
                      key: ValueKey('si_t_${insight.remoteId}'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: c.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // AI insight cards are display-only — no action buttons or links
                // Body with **bold** markers
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: _RichBody(
                      key: ValueKey('si_b_${insight.remoteId}'),
                      text: insight.body,
                      textMid: c.textMid,
                      textBold: c.text,
                    ),
                  ),
                ),

                // Bottom row: pagination dots
                if (insights.length > 1) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(
                      insights.length,
                      (i) => Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: i == _currentIndex ? 12 : 6,
                        height: 4,
                        decoration: BoxDecoration(
                          color: i == _currentIndex
                              ? accentColor
                              : c.textDim,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // AI badge (top-right, overlapping dismiss area)
            if (insight.isAiGenerated)
              Positioned(
                top: 0,
                right: 28, // Leave room for dismiss X
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: c.proTagBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: c.purple.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '\u2728',
                        style: TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'AI',
                        style: ChompdTypography.mono(
                          size: 9,
                          weight: FontWeight.w600,
                          color: c.purple,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _dismiss(InsightDisplayData insight) {
    HapticService.instance.light();
    if (insight.isAiGenerated) {
      UserInsightRepository.instance.dismissInsight(insight.isarId);
    } else {
      ServiceInsightRepository.instance.dismissById(insight.isarId);
    }
    ref.invalidate(combinedInsightsProvider);
    ref.invalidate(serviceInsightsListProvider);
  }
}

// ─── Rich Body (bold markers) ───

/// Renders text with **bold** markers as rich text.
class _RichBody extends StatelessWidget {
  final String text;
  final Color textMid;
  final Color textBold;
  const _RichBody({
    super.key,
    required this.text,
    required this.textMid,
    required this.textBold,
  });

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
          color: i.isOdd ? textBold : textMid,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

// ─── Pro Teaser (free users) ───

/// Locked teaser card for free users — taps through to paywall.
class _ProTeaser extends StatelessWidget {
  final Color accentColor;
  final Color bgCard;
  final Color textDim;

  const _ProTeaser({
    required this.accentColor,
    required this.bgCard,
    required this.textDim,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const PaywallScreen(
              trigger: PaywallTrigger.manual,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lock + label
            Row(
              children: [
                const Text('\uD83D\uDD12',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  l.insightProLabel,
                  style: ChompdTypography.mono(
                    size: 10,
                    weight: FontWeight.w400,
                    color: textDim,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              l.insightProTeaserTitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: c.text,
              ),
            ),
            const SizedBox(height: 6),

            // Placeholder body lines (simulating redacted text)
            Container(
              height: 12,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: textDim.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 12,
              width: 180,
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: textDim.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(height: 16),

            // Unlock CTA
            Row(
              children: [
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline,
                          size: 14, color: accentColor),
                      const SizedBox(width: 6),
                      Text(
                        '${l.insightUnlockPro} \u2192',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

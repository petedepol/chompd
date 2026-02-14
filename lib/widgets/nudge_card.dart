import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/theme.dart';
import '../models/nudge_candidate.dart';
import '../providers/subscriptions_provider.dart';
import '../screens/detail/detail_screen.dart';
import '../services/haptic_service.dart';
import '../utils/l10n_extension.dart';
import 'mascot_image.dart';

/// Dismissible inline card shown on the home screen when the
/// nudge engine identifies a subscription worth reviewing.
///
/// Appears between the category bar and subscription list.
/// Purple left border, piranha placeholder, gentle message.
class NudgeCard extends ConsumerWidget {
  final NudgeCandidate nudge;
  final VoidCallback? onDismissed;

  const NudgeCard({super.key, required this.nudge, this.onDismissed});

  void _dismiss(WidgetRef ref) {
    HapticService.instance.light();
    // Mark as reviewed — suppress nudges for 90 days
    nudge.sub
      ..lastReviewedAt = DateTime.now()
      ..keepConfirmed = true;
    ref.read(subscriptionsProvider.notifier).update(nudge.sub);
    onDismissed?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Dismissible(
      key: Key('nudge_${nudge.sub.uid}'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => _dismiss(ref),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: c.purple, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: mascot placeholder + message
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Piranha thinking placeholder (32px purple circle)
                const MascotImage(
                  asset: 'piranha_thinking.png',
                  size: 32,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    nudge.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: c.textMid,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Sub name in mono
            Text(
              nudge.sub.name,
              style: ChompdTypography.mono(
                size: 12,
                color: c.textDim,
              ),
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailScreen(subscription: nudge.sub),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: c.mint.withValues(alpha: 0.5),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.l10n.nudgeReview,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c.mint,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _dismiss(ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: c.border,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.l10n.nudgeKeepIt,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c.textDim,
                        ),
                      ),
                    ),
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

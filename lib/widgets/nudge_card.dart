import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/theme.dart';
import '../models/nudge_candidate.dart';
import '../providers/subscriptions_provider.dart';
import '../screens/detail/detail_screen.dart';
import '../services/haptic_service.dart';

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
    return Dismissible(
      key: Key('nudge_${nudge.sub.uid}'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => _dismiss(ref),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ChompdColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            left: BorderSide(color: ChompdColors.purple, width: 4),
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
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: ChompdColors.purple,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    nudge.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ChompdColors.textMid,
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
                color: ChompdColors.textDim,
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
                          color: ChompdColors.mint.withValues(alpha: 0.5),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Review',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ChompdColors.mint,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _dismiss(ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: const Text(
                      'I need this',
                      style: TextStyle(
                        fontSize: 12,
                        color: ChompdColors.textDim,
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

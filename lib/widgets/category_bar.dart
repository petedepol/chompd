import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/subscription.dart';

/// Horizontal category breakdown bar with colour-coded segments.
///
/// Shows proportional spending per category as a stacked bar,
/// with legend dots below. Matches the CatBar in the design prototype.
class CategoryBar extends StatelessWidget {
  final List<Subscription> subscriptions;

  const CategoryBar({
    super.key,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) return const SizedBox.shrink();

    // Aggregate spend per category
    final categorySpend = <String, double>{};
    for (final sub in subscriptions) {
      categorySpend[sub.category] =
          (categorySpend[sub.category] ?? 0) + sub.price;
    }

    final total = categorySpend.values.fold(0.0, (a, b) => a + b);
    final sorted = categorySpend.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stacked bar
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 6,
            child: Row(
              children: sorted.map((entry) {
                final fraction = entry.value / total;
                return Expanded(
                  flex: (fraction * 1000).round().clamp(1, 1000),
                  child: Container(
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: CategoryColors.forCategory(entry.key),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Legend (top 4 categories)
        Wrap(
          spacing: 10,
          runSpacing: 4,
          children: sorted.take(4).map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: CategoryColors.forCategory(entry.key),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 10,
                    color: ChompdColors.textDim,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  '\u00A3${entry.value.toStringAsFixed(0)}',
                  style: ChompdTypography.mono(
                    size: 10,
                    color: ChompdColors.textMid,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

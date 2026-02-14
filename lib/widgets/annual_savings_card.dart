import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/theme.dart';
import '../models/subscription.dart';
import '../providers/annual_savings_provider.dart';
import '../providers/currency_provider.dart';
import '../screens/savings/all_savings_screen.dart';
import '../services/annual_savings_service.dart';
import '../utils/l10n_extension.dart';

/// Dashboard card showing real annual savings opportunities.
class AnnualSavingsCard extends ConsumerWidget {
  const AnnualSavingsCard({super.key});

  static const _green = Color(0xFF1B8F6A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final result = ref.watch(annualSavingsProvider);
    final currency = ref.watch(currencyProvider);

    if (result.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _green.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                context.l10n.annualSavingsTitle,
                style: ChompdTypography.sectionLabel.copyWith(
                  color: _green,
                ),
              ),
              const Spacer(),
              if (result.items.length > 4)
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AllSavingsScreen(),
                    ),
                  ),
                  child: Text(
                    context.l10n.seeAll,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Total savings headline
          Text(
            Subscription.formatPrice(result.totalSavings, currency),
            style: ChompdTypography.mono(
              size: 28,
              weight: FontWeight.w700,
              color: _green,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.l10n.annualSavingsSubtitle,
            style: TextStyle(fontSize: 12, color: c.textDim),
          ),
          const SizedBox(height: 14),

          // Top 4 service rows
          ...result.items.take(4).map(
                (item) => _ServiceRow(item: item, currency: currency),
              ),

          const SizedBox(height: 10),

          // Coverage note
          Text(
            context.l10n.annualSavingsCoverage(
              result.matchedCount,
              result.totalActiveCount,
            ),
            style: TextStyle(fontSize: 10, color: c.textDim),
          ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final SubSavingsResult item;
  final String currency;
  const _ServiceRow({required this.item, required this.currency});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final brandColor = _parseHex(item.service.brandColor);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: brandColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              item.service.iconLetter,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: brandColor,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Service name
          Expanded(
            child: Text(
              item.service.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: c.text,
              ),
            ),
          ),

          // Savings amount
          Text(
            '+${Subscription.formatPrice(item.savings, currency)}',
            style: ChompdTypography.mono(
              size: 12,
              weight: FontWeight.w700,
              color: AnnualSavingsCard._green,
            ),
          ),
        ],
      ),
    );
  }

  static Color _parseHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

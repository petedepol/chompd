import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../models/subscription.dart';
import '../../providers/annual_savings_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/annual_savings_service.dart';
import '../../utils/l10n_extension.dart';

class AllSavingsScreen extends ConsumerWidget {
  const AllSavingsScreen({super.key});

  static const _green = Color(0xFF1B8F6A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final result = ref.watch(annualSavingsProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.top + 8,
            ),
          ),

          // Top bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: c.border),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: c.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.allSavingsTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: c.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Total savings hero
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Subscription.formatPrice(result.totalSavings, currency),
                    style: ChompdTypography.mono(
                      size: 36,
                      weight: FontWeight.w700,
                      color: _green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.allSavingsSubtitle,
                    style: TextStyle(fontSize: 13, color: c.textDim),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Full list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _DetailRow(
                  item: result.items[index],
                  currency: currency,
                ),
                childCount: result.items.length,
              ),
            ),
          ),

          // Coverage note
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                context.l10n.annualSavingsCoverage(
                  result.matchedCount,
                  result.totalActiveCount,
                ),
                style: TextStyle(fontSize: 11, color: c.textDim),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final SubSavingsResult item;
  final String currency;
  const _DetailRow({required this.item, required this.currency});

  static const _green = Color(0xFF1B8F6A);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final brandColor = _parseHex(item.service.brandColor);
    final monthlyFormatted = Subscription.formatPrice(
      item.monthlyPrice,
      currency,
    );
    final annualFormatted = Subscription.formatPrice(
      item.annualPrice,
      currency,
      decimals: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: brandColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              item.service.iconLetter,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: brandColor,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + price comparison
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.service.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.monthlyVsAnnual(
                    monthlyFormatted,
                    annualFormatted,
                  ),
                  style: TextStyle(fontSize: 11, color: c.textDim),
                ),
              ],
            ),
          ),

          // Savings
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${Subscription.formatPrice(item.savings, currency)}',
                style: ChompdTypography.mono(
                  size: 13,
                  weight: FontWeight.w700,
                  color: _green,
                ),
              ),
              Text(
                context.l10n.perYear,
                style: TextStyle(fontSize: 10, color: c.textDim),
              ),
            ],
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

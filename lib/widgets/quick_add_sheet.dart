import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/theme.dart';
import '../models/subscription.dart';
import '../providers/purchase_provider.dart';
import '../providers/subscriptions_provider.dart';
import '../screens/detail/add_edit_screen.dart';
import '../screens/paywall/paywall_screen.dart';

/// Pre-loaded popular service templates for quick-add.
class ServiceTemplate {
  final String name;
  final double price;
  final String currency;
  final BillingCycle cycle;
  final String category;
  final String icon;
  final String brandColor;

  const ServiceTemplate({
    required this.name,
    required this.price,
    required this.currency,
    required this.cycle,
    required this.category,
    required this.icon,
    required this.brandColor,
  });
}

const _templates = [
  ServiceTemplate(name: 'Netflix', price: 15.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'Entertainment', icon: 'N', brandColor: '#E50914'),
  ServiceTemplate(name: 'Spotify', price: 10.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'Music', icon: 'S', brandColor: '#1DB954'),
  ServiceTemplate(name: 'Disney+', price: 7.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'Entertainment', icon: 'D', brandColor: '#113CCF'),
  ServiceTemplate(name: 'Apple Music', price: 10.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'Music', icon: '\u266B', brandColor: '#FC3C44'),
  ServiceTemplate(name: 'YouTube Premium', price: 12.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'Entertainment', icon: '\u25B6', brandColor: '#FF0000'),
  ServiceTemplate(name: 'Amazon Prime', price: 8.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'Entertainment', icon: 'A', brandColor: '#FF9900'),
  ServiceTemplate(name: 'iCloud+', price: 2.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'Storage', icon: '\u2601', brandColor: '#4285F4'),
  ServiceTemplate(name: 'ChatGPT Plus', price: 20.00, currency: 'USD', cycle: BillingCycle.monthly, category: 'Productivity', icon: 'G', brandColor: '#10A37F'),
  ServiceTemplate(name: 'Claude Pro', price: 20.00, currency: 'USD', cycle: BillingCycle.monthly, category: 'Productivity', icon: 'C', brandColor: '#D97757'),
  ServiceTemplate(name: 'Xbox Game Pass', price: 10.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'Gaming', icon: 'X', brandColor: '#107C10'),
  ServiceTemplate(name: 'PlayStation Plus', price: 6.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'Gaming', icon: 'P', brandColor: '#003087'),
  ServiceTemplate(name: 'Adobe CC', price: 54.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'Design', icon: 'Ai', brandColor: '#FF0000'),
  ServiceTemplate(name: 'Figma', price: 12.00, currency: 'USD', cycle: BillingCycle.monthly, category: 'Design', icon: 'F', brandColor: '#A259FF'),
  ServiceTemplate(name: 'Notion', price: 10.00, currency: 'USD', cycle: BillingCycle.monthly, category: 'Productivity', icon: 'N', brandColor: '#000000'),
  ServiceTemplate(name: 'Strava', price: 6.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'Fitness', icon: '\u25B2', brandColor: '#FC4C02'),
  ServiceTemplate(name: 'Zwift', price: 17.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'Fitness', icon: 'Z', brandColor: '#FC6719'),
  ServiceTemplate(name: 'NordVPN', price: 3.49, currency: 'GBP', cycle: BillingCycle.monthly, category: 'Productivity', icon: 'N', brandColor: '#4687FF'),
  ServiceTemplate(name: 'Dropbox', price: 9.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'Storage', icon: 'D', brandColor: '#0061FE'),
  ServiceTemplate(name: 'Microsoft 365', price: 5.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'Productivity', icon: 'M', brandColor: '#00A4EF'),
  ServiceTemplate(name: 'The Athletic', price: 7.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'News', icon: 'A', brandColor: '#1DA1F2'),
];

/// Shows the quick-add bottom sheet with popular services + manual add.
void showQuickAddSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _QuickAddSheet(),
  );
}

class _QuickAddSheet extends ConsumerStatefulWidget {
  const _QuickAddSheet();

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  String _search = '';

  List<ServiceTemplate> get _filtered {
    if (_search.isEmpty) return _templates;
    final q = _search.toLowerCase();
    return _templates
        .where((t) =>
            t.name.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: ChompdColors.bgElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: ChompdColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Add Subscription',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ChompdColors.text,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: ChompdColors.textDim,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Manual add button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddEditScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [ChompdColors.mintDark, ChompdColors.mint],
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: ChompdColors.bg),
                    SizedBox(width: 8),
                    Text(
                      'Add Manually',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ChompdColors.bg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Divider with "or choose a service"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(child: Divider(color: ChompdColors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or choose a service',
                    style: TextStyle(
                      fontSize: 10,
                      color: ChompdColors.textDim,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: ChompdColors.border)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(fontSize: 13, color: ChompdColors.text),
              decoration: InputDecoration(
                hintText: 'Search services...',
                hintStyle: const TextStyle(color: ChompdColors.textDim),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: ChompdColors.textDim,
                ),
                filled: true,
                fillColor: ChompdColors.bgCard,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ChompdColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ChompdColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ChompdColors.mint),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Service grid
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final tpl = _filtered[index];
                return _TemplateRow(
                  template: tpl,
                  onTap: () => _quickAdd(tpl),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _quickAdd(ServiceTemplate tpl) async {
    final canAdd = ref.read(canAddSubProvider);
    if (!canAdd) {
      Navigator.of(context).pop();
      await showPaywall(context, trigger: PaywallTrigger.subscriptionLimit);
      return;
    }

    final now = DateTime.now();
    final sub = Subscription()
      ..uid = '${tpl.name.toLowerCase().replaceAll(' ', '-')}-${now.millisecondsSinceEpoch}'
      ..name = tpl.name
      ..price = tpl.price
      ..currency = tpl.currency
      ..cycle = tpl.cycle
      ..nextRenewal = now.add(Duration(days: tpl.cycle.approximateDays))
      ..category = tpl.category
      ..iconName = tpl.icon
      ..brandColor = tpl.brandColor
      ..isActive = true
      ..source = SubscriptionSource.quickAdd
      ..createdAt = now;

    ref.read(subscriptionsProvider.notifier).add(sub);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tpl.name} added!'),
        backgroundColor: ChompdColors.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _TemplateRow extends StatelessWidget {
  final ServiceTemplate template;
  final VoidCallback onTap;
  const _TemplateRow({required this.template, required this.onTap});

  Color get _color {
    final hex = template.brandColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: ChompdColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ChompdColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [_color.withValues(alpha: 0.87), _color.withValues(alpha: 0.53)],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                template.icon,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ChompdColors.text,
                    ),
                  ),
                  Text(
                    template.category,
                    style: const TextStyle(
                      fontSize: 10,
                      color: ChompdColors.textDim,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${Subscription.currencySymbol(template.currency)}${template.price.toStringAsFixed(2)}/${template.cycle.shortLabel}',
              style: ChompdTypography.mono(
                size: 12,
                weight: FontWeight.w700,
                color: ChompdColors.textMid,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: ChompdColors.mint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add_rounded,
                size: 16,
                color: ChompdColors.mint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/theme.dart';
import '../models/subscription.dart';
import '../providers/currency_provider.dart';
import '../providers/purchase_provider.dart';
import '../providers/subscriptions_provider.dart';
import '../screens/detail/add_edit_screen.dart';
import '../screens/paywall/paywall_screen.dart';
import '../services/haptic_service.dart';

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

  // Edit panel state
  ServiceTemplate? _selectedTemplate;
  late TextEditingController _priceCtrl;
  String _editCurrency = 'GBP';
  BillingCycle _editCycle = BillingCycle.monthly;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  List<ServiceTemplate> get _filtered {
    if (_search.isEmpty) return _templates;
    final q = _search.toLowerCase();
    return _templates
        .where((t) =>
            t.name.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q))
        .toList();
  }

  void _selectTemplate(ServiceTemplate tpl) {
    HapticService.instance.selection();
    setState(() {
      if (_selectedTemplate?.name == tpl.name) {
        // Tapping same template deselects
        _selectedTemplate = null;
      } else {
        _selectedTemplate = tpl;
        _priceCtrl.text = tpl.price.toStringAsFixed(2);
        _editCurrency = tpl.currency;
        _editCycle = tpl.cycle;
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _search = value;
      // Deselect if selected template is no longer in filtered results
      if (_selectedTemplate != null) {
        final q = value.toLowerCase();
        if (q.isNotEmpty &&
            !_selectedTemplate!.name.toLowerCase().contains(q) &&
            !_selectedTemplate!.category.toLowerCase().contains(q)) {
          _selectedTemplate = null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: ChompdColors.bgElevated.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              onChanged: _onSearchChanged,
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
                  isSelected: _selectedTemplate?.name == tpl.name,
                  onTap: () => _selectTemplate(tpl),
                );
              },
            ),
          ),

          // Edit panel (animated)
          _buildEditPanel(),
        ],
      ),
    ),
      ),
    );
  }

  Widget _buildEditPanel() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: _selectedTemplate == null
          ? const SizedBox.shrink()
          : _EditPanelContent(
              template: _selectedTemplate!,
              priceCtrl: _priceCtrl,
              currency: _editCurrency,
              cycle: _editCycle,
              onCurrencyChanged: (c) => setState(() => _editCurrency = c),
              onCycleChanged: (c) {
                HapticService.instance.selection();
                setState(() => _editCycle = c);
              },
              onDismiss: () => setState(() => _selectedTemplate = null),
              onAdd: _quickAdd,
            ),
    );
  }

  void _quickAdd() async {
    final tpl = _selectedTemplate!;
    final canAdd = ref.read(canAddSubProvider);
    if (!canAdd) {
      Navigator.of(context).pop();
      await showPaywall(context, trigger: PaywallTrigger.subscriptionLimit);
      return;
    }

    final price = double.tryParse(_priceCtrl.text) ?? tpl.price;
    if (price <= 0) return;

    final now = DateTime.now();
    final sub = Subscription()
      ..uid = '${tpl.name.toLowerCase().replaceAll(' ', '-')}-${now.millisecondsSinceEpoch}'
      ..name = tpl.name
      ..price = price
      ..currency = _editCurrency
      ..cycle = _editCycle
      ..nextRenewal = now.add(Duration(days: _editCycle.approximateDays))
      ..category = tpl.category
      ..iconName = tpl.icon
      ..brandColor = tpl.brandColor
      ..isActive = true
      ..source = SubscriptionSource.quickAdd
      ..createdAt = now;

    HapticService.instance.success();
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

// ─── Edit Panel ───

class _EditPanelContent extends StatelessWidget {
  final ServiceTemplate template;
  final TextEditingController priceCtrl;
  final String currency;
  final BillingCycle cycle;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<BillingCycle> onCycleChanged;
  final VoidCallback onDismiss;
  final VoidCallback onAdd;

  const _EditPanelContent({
    required this.template,
    required this.priceCtrl,
    required this.currency,
    required this.cycle,
    required this.onCurrencyChanged,
    required this.onCycleChanged,
    required this.onDismiss,
    required this.onAdd,
  });

  Color get _brandColor {
    final hex = template.brandColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final isValid = (double.tryParse(priceCtrl.text) ?? 0) > 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChompdColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _brandColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Service identity + dismiss
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      _brandColor.withValues(alpha: 0.87),
                      _brandColor.withValues(alpha: 0.53),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  template.icon,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 14,
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
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: ChompdColors.textDim,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Price + Currency row
          Row(
            children: [
              // Price field
              Expanded(
                flex: 2,
                child: TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  style: ChompdTypography.mono(
                    size: 14,
                    weight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      color: ChompdColors.textDim,
                    ),
                    filled: true,
                    fillColor: ChompdColors.bgElevated,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: ChompdColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: ChompdColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: ChompdColors.mint),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Currency dropdown
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: ChompdColors.bgElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ChompdColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currency,
                      isExpanded: true,
                      dropdownColor: ChompdColors.bgElevated,
                      style: ChompdTypography.mono(
                        size: 12,
                        weight: FontWeight.w600,
                      ),
                      icon: const Icon(
                        Icons.expand_more_rounded,
                        size: 16,
                        color: ChompdColors.textDim,
                      ),
                      items: supportedCurrencies
                          .map((c) => DropdownMenuItem<String>(
                                value: c['code'] as String,
                                child: Text(
                                  '${c['symbol']} ${c['code']}',
                                  style: ChompdTypography.mono(
                                    size: 12,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) onCurrencyChanged(v);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Billing cycle chips
          Row(
            children: BillingCycle.values.map((c) {
              final isSelected = c == cycle;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onCycleChanged(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(
                      right: c != BillingCycle.values.last ? 6 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ChompdColors.mint.withValues(alpha: 0.12)
                          : ChompdColors.bgElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? ChompdColors.mint.withValues(alpha: 0.5)
                            : ChompdColors.border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      c.shortLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? ChompdColors.mint : ChompdColors.textDim,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // Add button
          GestureDetector(
            onTap: isValid ? onAdd : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: isValid
                    ? const LinearGradient(
                        colors: [ChompdColors.mintDark, ChompdColors.mint],
                      )
                    : null,
                color: isValid ? null : ChompdColors.border,
              ),
              alignment: Alignment.center,
              child: Text(
                'Add ${template.name}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isValid ? ChompdColors.bg : ChompdColors.textDim,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Template Row ───

class _TemplateRow extends StatelessWidget {
  final ServiceTemplate template;
  final bool isSelected;
  final VoidCallback onTap;
  const _TemplateRow({
    required this.template,
    this.isSelected = false,
    required this.onTap,
  });

  Color get _color {
    final hex = template.brandColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? _color.withValues(alpha: 0.08)
              : ChompdColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? _color.withValues(alpha: 0.4)
                : ChompdColors.border,
          ),
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
              '${Subscription.formatPrice(template.price, template.currency)}/${template.cycle.shortLabel}',
              style: ChompdTypography.mono(
                size: 12,
                weight: FontWeight.w700,
                color: ChompdColors.textMid,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? _color.withValues(alpha: 0.2)
                    : ChompdColors.mint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(
                isSelected ? Icons.check_rounded : Icons.add_rounded,
                size: 16,
                color: isSelected ? _color : ChompdColors.mint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

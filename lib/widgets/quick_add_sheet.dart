import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../models/subscription.dart';
import '../providers/currency_provider.dart';
import '../providers/purchase_provider.dart';
import '../providers/service_cache_provider.dart';
import '../providers/subscriptions_provider.dart';
import '../screens/detail/add_edit_screen.dart';
import '../screens/paywall/paywall_screen.dart';
import '../services/exchange_rate_service.dart';
import '../services/haptic_service.dart';
import '../services/unmatched_service_logger.dart';
import '../utils/l10n_extension.dart';

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
  ServiceTemplate(name: 'Netflix', price: 15.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'streaming', icon: 'N', brandColor: '#E50914'),
  ServiceTemplate(name: 'Spotify', price: 10.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'music', icon: 'S', brandColor: '#1DB954'),
  ServiceTemplate(name: 'Disney+', price: 7.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'streaming', icon: 'D', brandColor: '#113CCF'),
  ServiceTemplate(name: 'Apple Music', price: 10.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'music', icon: '\u266B', brandColor: '#FC3C44'),
  ServiceTemplate(name: 'YouTube Premium', price: 12.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'streaming', icon: '\u25B6', brandColor: '#FF0000'),
  ServiceTemplate(name: 'Amazon Prime', price: 8.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'streaming', icon: 'A', brandColor: '#FF9900'),
  ServiceTemplate(name: 'iCloud+', price: 2.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'storage', icon: '\u2601', brandColor: '#4285F4'),
  ServiceTemplate(name: 'ChatGPT Plus', price: 20.00, currency: 'USD', cycle: BillingCycle.monthly, category: 'ai', icon: 'G', brandColor: '#10A37F'),
  ServiceTemplate(name: 'Claude Pro', price: 20.00, currency: 'USD', cycle: BillingCycle.monthly, category: 'ai', icon: 'C', brandColor: '#D97757'),
  ServiceTemplate(name: 'Xbox Game Pass', price: 10.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'gaming', icon: 'X', brandColor: '#107C10'),
  ServiceTemplate(name: 'PlayStation Plus', price: 6.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'gaming', icon: 'P', brandColor: '#003087'),
  ServiceTemplate(name: 'Adobe CC', price: 54.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'developer', icon: 'Ai', brandColor: '#FF0000'),
  ServiceTemplate(name: 'Figma', price: 12.00, currency: 'USD', cycle: BillingCycle.monthly, category: 'developer', icon: 'F', brandColor: '#A259FF'),
  ServiceTemplate(name: 'Notion', price: 10.00, currency: 'USD', cycle: BillingCycle.monthly, category: 'productivity', icon: 'N', brandColor: '#000000'),
  ServiceTemplate(name: 'Strava', price: 6.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'fitness', icon: '\u25B2', brandColor: '#FC4C02'),
  ServiceTemplate(name: 'Zwift', price: 17.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'fitness', icon: 'Z', brandColor: '#FC6719'),
  ServiceTemplate(name: 'NordVPN', price: 3.49, currency: 'GBP', cycle: BillingCycle.monthly, category: 'vpn', icon: 'N', brandColor: '#4687FF'),
  ServiceTemplate(name: 'Dropbox', price: 9.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'storage', icon: 'D', brandColor: '#0061FE'),
  ServiceTemplate(name: 'Microsoft 365', price: 5.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'productivity', icon: 'M', brandColor: '#00A4EF'),
  ServiceTemplate(name: 'The Athletic', price: 7.99, currency: 'GBP', cycle: BillingCycle.monthly, category: 'news', icon: 'A', brandColor: '#1DA1F2'),
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
  late String _editCurrency;
  BillingCycle _editCycle = BillingCycle.monthly;
  bool _isTrial = false;
  int _trialDays = 7;
  final ScrollController _listScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController();
    _editCurrency = ref.read(currencyProvider);
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _listScrollCtrl.dispose();
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
        _editCurrency = ref.read(currencyProvider);
        _editCycle = tpl.cycle;
        _isTrial = false;
        _trialDays = 7;

        // Convert template price to user's currency
        if (tpl.currency != _editCurrency) {
          final converted = ExchangeRateService.instance
              .convert(tpl.price, tpl.currency, _editCurrency);
          _priceCtrl.text = converted.toStringAsFixed(2);
        } else {
          _priceCtrl.text = tpl.price.toStringAsFixed(2);
        }
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

  /// Auto-scroll to the edit panel when keyboard opens.
  void _scrollToEditPanel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listScrollCtrl.hasClients) {
        _listScrollCtrl.animateTo(
          _listScrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Use viewInsets to shrink the sheet when keyboard opens,
    // instead of adding padding that causes overflow.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final keyboardOpen = bottomInset > 50;
    // When keyboard is open AND editing a template, collapse header to save space
    final compactMode = keyboardOpen && _selectedTemplate != null;

    // Auto-scroll to edit panel when keyboard appears
    if (compactMode) {
      _scrollToEditPanel();
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85 - bottomInset,
      ),
      decoration: BoxDecoration(
        color: c.bgElevated.withValues(alpha: 0.85),
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
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.addSubscriptionSheet,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: c.textDim,
                  ),
                ),
              ],
            ),
          ),

          // Collapse header elements when keyboard is open + editing
          if (!compactMode) ...[
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
                    gradient: LinearGradient(
                      colors: [c.mintDark, c.mint],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_outlined, size: 16, color: c.bg),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.addManually,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: c.bg,
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
                  Expanded(child: Divider(color: c.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      context.l10n.orChooseService,
                      style: TextStyle(
                        fontSize: 10,
                        color: c.textDim,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: c.border)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: _onSearchChanged,
                style: TextStyle(fontSize: 13, color: c.text),
                decoration: InputDecoration(
                  hintText: context.l10n.searchServices,
                  hintStyle: TextStyle(color: c.textDim),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: c.textDim,
                  ),
                  filled: true,
                  fillColor: c.bgCard,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.mint),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Service grid + edit panel in single scrollable area
          Expanded(
            child: ListView.builder(
              controller: _listScrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filtered.length + (_selectedTemplate != null ? 1 : 0),
              itemBuilder: (context, index) {
                // Find where to insert the edit panel (right after the selected template)
                final selectedIdx = _selectedTemplate == null
                    ? -1
                    : _filtered.indexWhere((t) => t.name == _selectedTemplate!.name);
                final editPanelIdx = selectedIdx + 1;

                if (_selectedTemplate != null && index == editPanelIdx) {
                  // This slot is the edit panel
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildEditPanel(),
                  );
                }

                // Adjust template index: items after the edit panel slot shift by 1
                final tplIndex = (_selectedTemplate != null && index > editPanelIdx)
                    ? index - 1
                    : index;

                if (tplIndex >= _filtered.length) {
                  return const SizedBox.shrink();
                }

                final tpl = _filtered[tplIndex];
                return _TemplateRow(
                  template: tpl,
                  isSelected: _selectedTemplate?.name == tpl.name,
                  onTap: () => _selectTemplate(tpl),
                );
              },
            ),
          ),
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
              isTrial: _isTrial,
              trialDays: _trialDays,
              onCurrencyChanged: (c) => setState(() => _editCurrency = c),
              onCycleChanged: (c) {
                HapticService.instance.selection();
                setState(() => _editCycle = c);
              },
              onTrialChanged: (v) => setState(() => _isTrial = v),
              onTrialDaysChanged: (d) => setState(() => _trialDays = d),
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
    final trialEnd = _isTrial ? now.add(Duration(days: _trialDays)) : null;
    final sub = Subscription()
      ..uid = '${tpl.name.toLowerCase().replaceAll(' ', '-')}-${now.millisecondsSinceEpoch}'
      ..name = tpl.name
      ..price = price
      ..currency = _editCurrency
      ..cycle = _editCycle
      ..nextRenewal = trialEnd ?? now.add(Duration(days: _editCycle.approximateDays))
      ..category = tpl.category
      ..iconName = tpl.icon
      ..brandColor = tpl.brandColor
      ..isActive = true
      ..isTrial = _isTrial
      ..trialEndDate = trialEnd
      ..trialExpiresAt = trialEnd
      ..source = SubscriptionSource.quickAdd
      ..createdAt = now;

    // Match against service database
    final matchedId = ref.read(serviceCacheProvider.notifier).matchServiceId(sub.name);
    sub.matchedServiceId = matchedId;
    if (matchedId == null) {
      UnmatchedServiceLogger.instance.log(
        name: sub.name,
        category: tpl.category,
        price: sub.price,
        currency: sub.currency,
      );
    }

    HapticService.instance.success();
    ref.read(subscriptionsProvider.notifier).add(sub);
    Navigator.of(context).pop();

    final c = context.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tpl.name} added!'),
        backgroundColor: c.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─── Edit Panel ───

class _EditPanelContent extends StatefulWidget {
  final ServiceTemplate template;
  final TextEditingController priceCtrl;
  final String currency;
  final BillingCycle cycle;
  final bool isTrial;
  final int trialDays;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<BillingCycle> onCycleChanged;
  final ValueChanged<bool> onTrialChanged;
  final ValueChanged<int> onTrialDaysChanged;
  final VoidCallback onDismiss;
  final VoidCallback onAdd;

  const _EditPanelContent({
    required this.template,
    required this.priceCtrl,
    required this.currency,
    required this.cycle,
    required this.isTrial,
    required this.trialDays,
    required this.onCurrencyChanged,
    required this.onCycleChanged,
    required this.onTrialChanged,
    required this.onTrialDaysChanged,
    required this.onDismiss,
    required this.onAdd,
  });

  @override
  State<_EditPanelContent> createState() => _EditPanelContentState();
}

class _EditPanelContentState extends State<_EditPanelContent> {
  final FocusNode _priceFocus = FocusNode();
  bool _priceHasFocus = false;

  @override
  void initState() {
    super.initState();
    _priceFocus.addListener(() {
      if (mounted) setState(() => _priceHasFocus = _priceFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _priceFocus.dispose();
    super.dispose();
  }

  Color get _brandColor {
    final hex = widget.template.brandColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isValid = (double.tryParse(widget.priceCtrl.text) ?? 0) > 0;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.bgCard,
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
                  widget.template.icon,
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
                      widget.template.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.text,
                      ),
                    ),
                    Text(
                      AppConstants.localisedCategory(widget.template.category, context.l10n),
                      style: TextStyle(
                        fontSize: 10,
                        color: c.textDim,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: widget.onDismiss,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: c.textDim,
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
                  controller: widget.priceCtrl,
                  focusNode: _priceFocus,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  inputFormatters: [
                    // Allow digits, dots, and commas (European decimal)
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    // Replace commas with dots so parsing works
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return newValue.copyWith(
                        text: newValue.text.replaceAll(',', '.'),
                      );
                    }),
                  ],
                  style: ChompdTypography.mono(
                    size: 14,
                    weight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: context.l10n.priceField,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      color: c.textDim,
                    ),
                    filled: true,
                    fillColor: c.bgElevated,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    // Tick button to confirm price & dismiss keyboard
                    suffixIcon: _priceHasFocus
                        ? GestureDetector(
                            onTap: () {
                              _priceFocus.unfocus();
                              HapticService.instance.light();
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: isValid
                                    ? c.mint.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: isValid
                                    ? c.mint
                                    : c.textDim,
                              ),
                            ),
                          )
                        : null,
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 32,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: c.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: c.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: c.mint),
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
                    color: c.bgElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.currency,
                      isExpanded: true,
                      dropdownColor: c.bgElevated,
                      style: ChompdTypography.mono(
                        size: 12,
                        weight: FontWeight.w600,
                      ),
                      icon: Icon(
                        Icons.expand_more_rounded,
                        size: 16,
                        color: c.textDim,
                      ),
                      items: supportedCurrencies
                          .map((cur) => DropdownMenuItem<String>(
                                value: cur['code'] as String,
                                child: Text(
                                  '${cur['symbol']} ${cur['code']}',
                                  style: ChompdTypography.mono(
                                    size: 12,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) widget.onCurrencyChanged(v);
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
            children: BillingCycle.values.map((cycle) {
              final isSelected = cycle == widget.cycle;
              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onCycleChanged(cycle),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(
                      right: cycle != BillingCycle.values.last ? 6 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? c.mint.withValues(alpha: 0.12)
                          : c.bgElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? c.mint.withValues(alpha: 0.5)
                            : c.border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cycle.localShortLabel(context.l10n),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? c.mint : c.textDim,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Trial toggle
          GestureDetector(
            onTap: () {
              HapticService.instance.selection();
              widget.onTrialChanged(!widget.isTrial);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isTrial
                    ? c.amber.withValues(alpha: 0.08)
                    : c.bgElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.isTrial
                      ? c.amber.withValues(alpha: 0.3)
                      : c.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isTrial
                        ? Icons.timer_outlined
                        : Icons.timer_off_outlined,
                    size: 16,
                    color: widget.isTrial
                        ? c.amber
                        : c.textDim,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.freeTrialToggle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: widget.isTrial
                            ? c.amber
                            : c.textDim,
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: widget.isTrial
                          ? c.amber
                          : c.border,
                    ),
                    alignment: widget.isTrial
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: widget.isTrial
                            ? c.bg
                            : c.textDim,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Trial duration chips
          if (widget.isTrial) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  context.l10n.trialDurationLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: c.textDim,
                  ),
                ),
                const SizedBox(width: 8),
                for (final days in [7, 14, 30])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        HapticService.instance.selection();
                        widget.onTrialDaysChanged(days);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.trialDays == days
                              ? c.amber.withValues(alpha: 0.15)
                              : c.bgElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.trialDays == days
                                ? c.amber.withValues(alpha: 0.4)
                                : c.border,
                          ),
                        ),
                        child: Text(
                          days == 7
                              ? context.l10n.trialDays7
                              : days == 14
                                  ? context.l10n.trialDays14
                                  : context.l10n.trialDays30,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: widget.trialDays == days
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: widget.trialDays == days
                                ? c.amber
                                : c.textDim,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // Add button
          GestureDetector(
            onTap: isValid ? widget.onAdd : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: isValid
                    ? LinearGradient(
                        colors: [c.mintDark, c.mint],
                      )
                    : null,
                color: isValid ? null : c.border,
              ),
              alignment: Alignment.center,
              child: Text(
                context.l10n.addServiceName(widget.template.name),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isValid ? c.bg : c.textDim,
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
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? _color.withValues(alpha: 0.08)
              : c.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? _color.withValues(alpha: 0.4)
                : c.border,
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
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                  Text(
                    AppConstants.localisedCategory(template.category, context.l10n),
                    style: TextStyle(
                      fontSize: 10,
                      color: c.textDim,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${Subscription.formatPrice(template.price, template.currency)}/${template.cycle.localShortLabel(context.l10n)}',
              style: ChompdTypography.mono(
                size: 12,
                weight: FontWeight.w700,
                color: c.textMid,
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
                    : c.mint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(
                isSelected ? Icons.check_rounded : Icons.add_rounded,
                size: 16,
                color: isSelected ? _color : c.mint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

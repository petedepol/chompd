import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/subscription.dart';
import '../../providers/currency_provider.dart';
import '../../providers/subscriptions_provider.dart';
import '../../utils/l10n_extension.dart';

/// Add or edit a subscription.
///
/// If [existingSub] is provided, the form pre-fills with its data.
/// Otherwise, creates a new subscription.
class AddEditScreen extends ConsumerStatefulWidget {
  final Subscription? existingSub;

  const AddEditScreen({super.key, this.existingSub});

  @override
  ConsumerState<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends ConsumerState<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late String _currency;
  late BillingCycle _cycle;
  late String _category;
  late DateTime _nextRenewal;
  late bool _isTrial;
  DateTime? _trialEndDate;
  String? _iconName;
  String? _brandColor;

  bool get _isEditing => widget.existingSub != null;

  @override
  void initState() {
    super.initState();
    final sub = widget.existingSub;
    _nameCtrl = TextEditingController(text: sub?.name ?? '');
    _priceCtrl = TextEditingController(
      text: sub != null ? sub.price.toStringAsFixed(2) : '',
    );
    _currency = sub?.currency ?? ref.read(currencyProvider);
    _cycle = sub?.cycle ?? BillingCycle.monthly;
    _category = sub?.category ?? 'Entertainment';
    _nextRenewal = sub?.nextRenewal ?? DateTime.now().add(const Duration(days: 30));
    _isTrial = sub?.isTrial ?? false;
    _trialEndDate = sub?.trialEndDate;
    _iconName = sub?.iconName;
    _brandColor = sub?.brandColor;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.top + 8),
          ),

          // ─── Top Bar ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c.bgElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: c.border),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: c.textMid,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isEditing ? context.l10n.editSubscription : context.l10n.addSubscription,
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

          // ─── Form ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    _label(context.l10n.fieldServiceName),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _nameCtrl,
                      hint: context.l10n.hintServiceName,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? context.l10n.errorNameRequired : null,
                    ),

                    const SizedBox(height: 20),

                    // Price + Currency row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label(context.l10n.fieldPrice),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _priceCtrl,
                                hint: context.l10n.hintPrice,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                                validator: (v) {
                                  if (v == null || v.isEmpty) return context.l10n.errorPriceRequired;
                                  final parsed = double.tryParse(v);
                                  if (parsed == null || parsed <= 0) return context.l10n.errorInvalidPrice;
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label(context.l10n.fieldCurrency),
                              const SizedBox(height: 6),
                              _buildDropdown<String>(
                                value: _currency,
                                items: supportedCurrencies.map((cur) => cur['code'] as String).toList(),
                                labels: supportedCurrencies.map((cur) => '${cur['symbol']} ${cur['code']}').toList(),
                                onChanged: (v) => setState(() => _currency = v!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Billing Cycle
                    _label(context.l10n.fieldBillingCycle),
                    const SizedBox(height: 6),
                    Row(
                      children: BillingCycle.values.map((cycle) {
                        final selected = _cycle == cycle;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _cycle = cycle),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? c.mint.withValues(alpha: 0.12)
                                    : c.bgCard,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selected
                                      ? c.mint.withValues(alpha: 0.4)
                                      : c.border,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                cycle.localLabel(context.l10n),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? c.mint
                                      : c.textDim,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Category
                    _label(context.l10n.fieldCategory),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: AppConstants.categories.map((cat) {
                        final selected = _category == cat;
                        final catColor = CategoryColors.forCategory(cat);
                        return GestureDetector(
                          onTap: () => setState(() => _category = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? catColor.withValues(alpha: 0.15)
                                  : c.bgCard,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? catColor.withValues(alpha: 0.5)
                                    : c.border,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: catColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppConstants.localisedCategory(cat, context.l10n),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: selected
                                        ? c.text
                                        : c.textDim,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Next Renewal Date
                    _label(context.l10n.fieldNextRenewal),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickRenewalDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: c.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: c.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: c.textMid,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${_nextRenewal.day}/${_nextRenewal.month}/${_nextRenewal.year}',
                              style: TextStyle(
                                fontSize: 14,
                                color: c.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Trial toggle
                    GestureDetector(
                      onTap: () => setState(() {
                        _isTrial = !_isTrial;
                        if (_isTrial && _trialEndDate == null) {
                          _trialEndDate =
                              DateTime.now().add(const Duration(days: 14));
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _isTrial
                              ? c.amberGlow
                              : c.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isTrial
                                ? c.amber.withValues(alpha: 0.3)
                                : c.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isTrial
                                  ? Icons.timer
                                  : Icons.timer_outlined,
                              size: 18,
                              color: _isTrial
                                  ? c.amber
                                  : c.textDim,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.l10n.freeTrialToggle,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _isTrial
                                      ? c.amber
                                      : c.textMid,
                                ),
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 20,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: _isTrial
                                    ? c.amber
                                    : c.bgElevated,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 200),
                                alignment: _isTrial
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_isTrial) ...[
                      const SizedBox(height: 12),
                      _label(context.l10n.fieldTrialEnds),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickTrialEndDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: c.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: c.amber.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.event_outlined,
                                size: 16,
                                color: c.amber,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _trialEndDate != null
                                    ? '${_trialEndDate!.day}/${_trialEndDate!.month}/${_trialEndDate!.year}'
                                    : context.l10n.selectDate,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: c.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ─── Save Button ───
                    GestureDetector(
                      onTap: _save,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [c.mintDark, c.mint],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: c.mint.withValues(alpha: 0.27),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _isEditing ? context.l10n.saveChanges : context.l10n.addSubscription,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: c.bg,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: ChompdTypography.sectionLabel);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final c = context.colors;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(fontSize: 14, color: c.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textDim),
        filled: true,
        fillColor: c.bgCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          borderSide: BorderSide(color: c.mint, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.red),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required List<String> labels,
    required ValueChanged<T?> onChanged,
  }) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: c.bgElevated,
          style: TextStyle(fontSize: 13, color: c.text),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: c.textDim,
          ),
          items: items.asMap().entries.map((e) {
            return DropdownMenuItem<T>(
              value: e.value,
              child: Text(labels[e.key]),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _pickRenewalDate() async {
    final c = context.colors;
    final baseTheme = context.isDarkMode ? ChompdTheme.dark : ChompdTheme.light;

    final picked = await showDatePicker(
      context: context,
      initialDate: _nextRenewal,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: baseTheme.copyWith(
          colorScheme: ColorScheme(
            brightness: context.isDarkMode ? Brightness.dark : Brightness.light,
            primary: c.mint,
            onPrimary: c.bg,
            secondary: c.mint,
            onSecondary: c.bg,
            surface: c.bgElevated,
            onSurface: c.text,
            error: c.red,
            onError: c.text,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _nextRenewal = picked);
  }

  Future<void> _pickTrialEndDate() async {
    final c = context.colors;
    final baseTheme = context.isDarkMode ? ChompdTheme.dark : ChompdTheme.light;

    final picked = await showDatePicker(
      context: context,
      initialDate: _trialEndDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: baseTheme.copyWith(
          colorScheme: ColorScheme(
            brightness: context.isDarkMode ? Brightness.dark : Brightness.light,
            primary: c.amber,
            onPrimary: c.bg,
            secondary: c.amber,
            onSecondary: c.bg,
            surface: c.bgElevated,
            onSurface: c.text,
            error: c.red,
            onError: c.text,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _trialEndDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final price = double.parse(_priceCtrl.text);
    final notifier = ref.read(subscriptionsProvider.notifier);

    if (_isEditing) {
      final updated = widget.existingSub!
        ..name = name
        ..price = price
        ..currency = _currency
        ..cycle = _cycle
        ..category = _category
        ..nextRenewal = _nextRenewal
        ..isTrial = _isTrial
        ..trialEndDate = _isTrial ? _trialEndDate : null;
      notifier.update(updated);
    } else {
      final sub = Subscription()
        ..uid = '${name.toLowerCase().replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch}'
        ..name = name
        ..price = price
        ..currency = _currency
        ..cycle = _cycle
        ..nextRenewal = _nextRenewal
        ..category = _category
        ..isTrial = _isTrial
        ..trialEndDate = _isTrial ? _trialEndDate : null
        ..isActive = true
        ..iconName = _iconName ?? name[0].toUpperCase()
        ..brandColor = _brandColor
        ..source = SubscriptionSource.manual
        ..createdAt = DateTime.now();
      notifier.add(sub);
    }

    Navigator.of(context).pop();
    if (_isEditing) Navigator.of(context).pop(); // Also pop detail screen
  }
}

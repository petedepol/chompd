import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/subscription.dart';
import '../../providers/currency_provider.dart';
import '../../providers/subscriptions_provider.dart';

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
    _currency = sub?.currency ?? 'GBP';
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
    return Scaffold(
      backgroundColor: ChompdColors.bg,
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
                        color: ChompdColors.bgElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: ChompdColors.border),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: ChompdColors.textMid,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isEditing ? 'Edit Subscription' : 'Add Subscription',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ChompdColors.text,
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
                    _label('SERVICE NAME'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _nameCtrl,
                      hint: 'e.g. Netflix, Spotify',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Name required' : null,
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
                              _label('PRICE'),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _priceCtrl,
                                hint: '9.99',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                                ],
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Price required';
                                  final parsed = double.tryParse(v);
                                  if (parsed == null || parsed <= 0) return 'Invalid price';
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
                              _label('CURRENCY'),
                              const SizedBox(height: 6),
                              _buildDropdown<String>(
                                value: _currency,
                                items: supportedCurrencies.map((c) => c['code'] as String).toList(),
                                labels: supportedCurrencies.map((c) => '${c['symbol']} ${c['code']}').toList(),
                                onChanged: (v) => setState(() => _currency = v!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Billing Cycle
                    _label('BILLING CYCLE'),
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
                                    ? ChompdColors.mint.withValues(alpha: 0.12)
                                    : ChompdColors.bgCard,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selected
                                      ? ChompdColors.mint.withValues(alpha: 0.4)
                                      : ChompdColors.border,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                cycle.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? ChompdColors.mint
                                      : ChompdColors.textDim,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Category
                    _label('CATEGORY'),
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
                                  : ChompdColors.bgCard,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? catColor.withValues(alpha: 0.5)
                                    : ChompdColors.border,
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
                                  cat,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: selected
                                        ? ChompdColors.text
                                        : ChompdColors.textDim,
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
                    _label('NEXT RENEWAL'),
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
                          color: ChompdColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ChompdColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: ChompdColors.textMid,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${_nextRenewal.day}/${_nextRenewal.month}/${_nextRenewal.year}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: ChompdColors.text,
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
                              ? ChompdColors.amberGlow
                              : ChompdColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isTrial
                                ? ChompdColors.amber.withValues(alpha: 0.3)
                                : ChompdColors.border,
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
                                  ? ChompdColors.amber
                                  : ChompdColors.textDim,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'This is a free trial',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _isTrial
                                      ? ChompdColors.amber
                                      : ChompdColors.textMid,
                                ),
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 20,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: _isTrial
                                    ? ChompdColors.amber
                                    : ChompdColors.bgElevated,
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
                      _label('TRIAL ENDS'),
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
                            color: ChompdColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ChompdColors.amber.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_outlined,
                                size: 16,
                                color: ChompdColors.amber,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _trialEndDate != null
                                    ? '${_trialEndDate!.day}/${_trialEndDate!.month}/${_trialEndDate!.year}'
                                    : 'Select date',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: ChompdColors.text,
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
                          gradient: const LinearGradient(
                            colors: [ChompdColors.mintDark, ChompdColors.mint],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ChompdColors.mint.withValues(alpha: 0.27),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _isEditing ? 'Save Changes' : 'Add Subscription',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: ChompdColors.bg,
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: ChompdColors.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: ChompdColors.textDim),
        filled: true,
        fillColor: ChompdColors.bgCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          borderSide: const BorderSide(color: ChompdColors.mint, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ChompdColors.red),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: ChompdColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ChompdColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: ChompdColors.bgElevated,
          style: const TextStyle(fontSize: 13, color: ChompdColors.text),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: ChompdColors.textDim,
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextRenewal,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: ChompdTheme.dark.copyWith(
          colorScheme: const ColorScheme.dark(
            primary: ChompdColors.mint,
            surface: ChompdColors.bgElevated,
            onSurface: ChompdColors.text,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _nextRenewal = picked);
  }

  Future<void> _pickTrialEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _trialEndDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ChompdTheme.dark.copyWith(
          colorScheme: const ColorScheme.dark(
            primary: ChompdColors.amber,
            surface: ChompdColors.bgElevated,
            onSurface: ChompdColors.text,
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

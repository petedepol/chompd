import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../../models/refund_template.dart';  // Generic fallback model
import '../../models/refund_template_v2.dart';  // Service-specific from Supabase
import '../../models/subscription.dart';
import '../../providers/service_cache_provider.dart';
import '../../services/haptic_service.dart';
import '../../utils/l10n_extension.dart';

/// Refund Rescue screen — guides users through getting money back.
///
/// Two phases:
/// 1. Path selector — pick how you were charged
/// 2. Step-by-step guide for the selected path
class RefundRescueScreen extends ConsumerStatefulWidget {
  final Subscription subscription;

  const RefundRescueScreen({super.key, required this.subscription});

  @override
  ConsumerState<RefundRescueScreen> createState() =>
      _RefundRescueScreenState();
}

class _RefundRescueScreenState extends ConsumerState<RefundRescueScreen> {
  // Generic path selection (old model)
  RefundTemplate? _selectedTemplate;
  // Service-specific template selection (new model)
  RefundTemplateData? _selectedServiceTemplate;

  List<bool> _stepChecks = [];
  bool _showConfirmation = false;

  Subscription get sub => widget.subscription;

  /// Current language code for localised content.
  String get _lang => Localizations.localeOf(context).languageCode;

  /// Service-specific refund templates from the cache.
  List<RefundTemplateData> get _serviceTemplates {
    final notifier = ref.read(serviceCacheProvider.notifier);
    return notifier.findRefundTemplates(sub.name);
  }

  void _selectPath(RefundTemplate template) {
    HapticService.instance.selection();
    setState(() {
      _selectedTemplate = template;
      _selectedServiceTemplate = null;
      _stepChecks = List.filled(template.getSteps(_lang).length, false);
    });
  }

  void _selectServiceTemplate(RefundTemplateData template) {
    HapticService.instance.selection();
    setState(() {
      _selectedServiceTemplate = template;
      _selectedTemplate = null;
      _stepChecks = List.filled(template.steps.length, false);
    });
  }

  void _backToPathSelector() {
    HapticService.instance.light();
    setState(() {
      _selectedTemplate = null;
      _selectedServiceTemplate = null;
      _stepChecks = [];
      _showConfirmation = false;
    });
  }

  void _toggleStep(int index) {
    HapticService.instance.selection();
    setState(() {
      _stepChecks[index] = !_stepChecks[index];
    });
  }

  void _copyEmail() async {
    HapticService.instance.light();
    // Use service-specific email template if available
    final String email;
    if (_selectedServiceTemplate?.emailTemplate != null) {
      email = _fillServiceEmailTemplate(
        _selectedServiceTemplate!.emailTemplate!,
        sub,
      );
    } else {
      email = _buildDisputeEmail(sub);
    }
    await Clipboard.setData(ClipboardData(text: email));
    if (!mounted) return;
    final c = context.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.emailCopied),
        backgroundColor: c.mint,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }



  void _submitRequest() {
    HapticService.instance.selection();
    setState(() => _showConfirmation = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  /// Fill service-specific email template with subscription data.
  String _fillServiceEmailTemplate(String template, Subscription sub) {
    final dateFormat = DateFormat('d MMMM yyyy');
    return template
        .replaceAll('{{service}}', sub.name)
        .replaceAll('{{amount}}', Subscription.formatPrice(sub.price, sub.currency))
        .replaceAll('{{date}}', dateFormat.format(sub.nextRenewal));
  }

  /// Build generic dispute email using localised template.
  String _buildDisputeEmail(Subscription sub) {
    final dateFormat = DateFormat('d MMMM yyyy', _lang);
    final directBilling = _genericRefundPaths
        .firstWhere((p) => p.id == 'direct_billing');
    final template = directBilling.getEmailTemplate(_lang) ??
        directBilling.emailTemplate!;

    return template
        .replaceAll('{service_name}', sub.name)
        .replaceAll(
          '{trial_price}',
          Subscription.formatPrice(sub.trialPrice ?? 0, sub.currency),
        )
        .replaceAll(
          '{real_price}',
          '${Subscription.formatPrice(sub.realPrice ?? sub.price, sub.currency)}/${sub.cycle.shortLabel}',
        )
        .replaceAll('{signup_date}', dateFormat.format(sub.createdAt))
        .replaceAll(
          '{charge_amount}',
          Subscription.formatPrice(sub.realPrice ?? sub.price, sub.currency),
        )
        .replaceAll('{charge_date}', dateFormat.format(sub.nextRenewal));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: _showConfirmation
          ? _buildConfirmation()
          : _selectedServiceTemplate != null
              ? _buildServiceStepsView()
              : _selectedTemplate != null
                  ? _buildStepsView()
                  : _buildPathSelector(),
    );
  }

  // ─── Phase 1: Path Selector ───

  Widget _buildPathSelector() {
    final c = context.colors;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child:
              SizedBox(height: MediaQuery.of(context).padding.top + 8),
        ),

        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _BackButton(onTap: () => Navigator.of(context).pop()),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.refundRescue,
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

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Piranha message
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: c.purple.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                context.l10n.refundIntro,
                style: TextStyle(
                  fontSize: 13,
                  color: c.text,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Charge info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              context.l10n.chargedYou(sub.name, Subscription.formatPrice(sub.price, sub.currency)),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: c.textMid,
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Section label
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              context.l10n.howCharged,
              style: ChompdTypography.sectionLabel,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Service-specific templates (from Supabase cache) OR generic fallback
        // Only use service-specific if they actually have steps populated
        if (_serviceTemplates.any((t) => t.steps.isNotEmpty)) ...[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final usable = _serviceTemplates.where((t) => t.steps.isNotEmpty).toList();
                final template = usable[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: _ServicePathCard(
                    template: template,
                    onTap: () => _selectServiceTemplate(template),
                  ),
                );
              },
              childCount: _serviceTemplates.where((t) => t.steps.isNotEmpty).length,
            ),
          ),
        ] else ...[
          // Generic path cards (fallback when no service-specific data)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final template = _genericRefundPaths[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: _PathCard(
                    template: template,
                    onTap: () => _selectPath(template),
                  ),
                );
              },
              childCount: _genericRefundPaths.length,
            ),
          ),
        ],

        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).padding.bottom + 30,
          ),
        ),
      ],
    );
  }

  // ─── Phase 2: Steps View ───

  Widget _buildStepsView() {
    final c = context.colors;
    final template = _selectedTemplate!;
    final isDirectBilling = template.path == RefundPath.directBilling;
    final localSteps = template.getSteps(_lang);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToPathSelector();
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
                height: MediaQuery.of(context).padding.top + 8),
          ),

          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _BackButton(onTap: _backToPathSelector),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      template.getName(_lang),
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

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Success rate pill
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: c.mint.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.l10n.successRate(template.getSuccessRate(_lang)),
                        style: ChompdTypography.mono(
                          size: 11,
                          weight: FontWeight.w600,
                          color: c.mint,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      template.getTimeframe(_lang),
                      style: TextStyle(
                        fontSize: 11,
                        color: c.textDim,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Steps
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 4),
                  child: _StepCard(
                    index: index,
                    text: localSteps[index],
                    checked: _stepChecks[index],
                    onToggle: () => _toggleStep(index),
                  ),
                );
              },
              childCount: localSteps.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Copy Email button (direct billing only)
          if (isDirectBilling)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: _copyEmail,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: c.mint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      context.l10n.copyDisputeEmail,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.bg,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (isDirectBilling)
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Open Refund Page button
          if (template.url != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () async {
                    HapticService.instance.light();
                    final url = Uri.parse(template.url!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: c.mint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: c.mint.withValues(alpha: 0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.l10n.openRefundPage,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: c.mint,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 14,
                          color: c.mint,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Submit request button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _submitRequest,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    context.l10n.iveSubmittedRequest,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 30,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Phase 2b: Service-Specific Steps View ───

  Widget _buildServiceStepsView() {
    final c = context.colors;
    final template = _selectedServiceTemplate!;
    final hasEmail = template.emailTemplate != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToPathSelector();
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
                height: MediaQuery.of(context).padding.top + 8),
          ),

          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _BackButton(onTap: _backToPathSelector),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      template.billingMethodLabel,
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

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Success rate + refund window
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (template.successRatePct != null)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: c.mint.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          template.successRateLabel,
                          style: ChompdTypography.mono(
                            size: 11,
                            weight: FontWeight.w600,
                            color: c.mint,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  if (template.successRatePct != null)
                    const SizedBox(width: 8),
                  if (template.refundWindowDays != null)
                    Flexible(
                      child: Text(
                        context.l10n.refundWindowDays(template.refundWindowDays.toString()),
                        style: TextStyle(
                          fontSize: 11,
                          color: c.textDim,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (template.avgRefundDays != null)
                    Flexible(
                      child: Text(
                        ' · ${context.l10n.avgRefundDays(template.avgRefundDays.toString())}',
                        style: TextStyle(
                          fontSize: 11,
                          color: c.textDim,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Steps
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final step = template.steps[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 4),
                  child: _StepCard(
                    index: index,
                    text: step.title,
                    detail: step.detail,
                    checked: _stepChecks[index],
                    onToggle: () => _toggleStep(index),
                  ),
                );
              },
              childCount: template.steps.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Copy Email button (if template has email)
          if (hasEmail)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: _copyEmail,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: c.mint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      context.l10n.copyDisputeEmail,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.bg,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (hasEmail)
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Contact URL button
          if (template.contactUrl != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () async {
                    HapticService.instance.light();
                    final url = Uri.parse(template.contactUrl!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: c.mint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: c.mint.withValues(alpha: 0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.l10n.openRefundPage,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: c.mint,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 14,
                          color: c.mint,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Submit request button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _submitRequest,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    context.l10n.iveSubmittedRequest,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 30,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Confirmation ───

  Widget _buildConfirmation() {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.mint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(32),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.check_rounded,
                size: 32,
                color: c.mint,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.requestSubmitted,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: c.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              context.l10n.requestSubmittedMessage,
              style: TextStyle(
                fontSize: 13,
                color: c.textMid,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Private Widgets ───

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
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
          Icons.arrow_back_rounded,
          size: 16,
          color: c.textMid,
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  final RefundTemplate template;
  final VoidCallback onTap;

  const _PathCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lang = Localizations.localeOf(context).languageCode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Text(
              template.path.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.getName(lang),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.getSuccessRate(lang),
                    style: ChompdTypography.mono(
                      size: 11,
                      color: c.mint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 0,
              child: Text(
                template.getTimeframe(lang),
                style: TextStyle(
                  fontSize: 10,
                  color: c.textDim,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: c.textDim,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicePathCard extends StatelessWidget {
  final RefundTemplateData template;
  final VoidCallback onTap;

  const _ServicePathCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.purple.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: c.purple.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Text(
              template.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.billingMethodLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (template.successRatePct != null)
                    Text(
                      template.successRateLabel,
                      style: ChompdTypography.mono(
                        size: 11,
                        color: c.mint,
                      ),
                    ),
                ],
              ),
            ),
            if (template.refundWindowDays != null)
              Text(
                context.l10n.refundWindowDays(template.refundWindowDays.toString()),
                style: TextStyle(
                  fontSize: 10,
                  color: c.textDim,
                ),
              ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: c.textDim,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int index;
  final String text;
  final String? detail;
  final bool checked;
  final VoidCallback onToggle;

  const _StepCard({
    required this.index,
    required this.text,
    this.detail,
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: checked
                ? c.mint.withValues(alpha: 0.3)
                : c.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox circle
            Container(
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked
                    ? c.mint.withValues(alpha: 0.15)
                    : Colors.transparent,
                border: Border.all(
                  color: checked
                      ? c.mint
                      : c.textDim,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: checked
                  ? Icon(Icons.check_rounded,
                      size: 14, color: c.mint)
                  : Text(
                      '${index + 1}',
                      style: ChompdTypography.mono(
                        size: 10,
                        weight: FontWeight.w700,
                        color: c.textDim,
                      ),
                    ),
            ),
            // Step text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.stepNumber(index + 1),
                    style: ChompdTypography.mono(
                      size: 9,
                      weight: FontWeight.w700,
                      color: c.textDim,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      color: checked
                          ? c.textDim
                          : c.text,
                      decoration:
                          checked ? TextDecoration.lineThrough : null,
                      height: 1.4,
                    ),
                  ),
                  if (detail != null && detail!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      detail!,
                      style: TextStyle(
                        fontSize: 12,
                        color: c.textDim,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Generic Refund Paths (fallback when no service-specific data) ───

const List<RefundTemplate> _genericRefundPaths = [
  RefundTemplate(
    id: 'app_store',
    name: 'Apple App Store Refund',
    path: RefundPath.appStore,
    steps: [
      'Go to reportaproblem.apple.com',
      'Sign in with your Apple ID',
      'Find the charge in your purchase history',
      'Tap "Report a Problem" next to the charge',
      'Select "I didn\'t intend to purchase this item" or '
          '"I didn\'t authorise this purchase"',
      'Add a brief explanation: "I was misled by trial terms"',
      'Submit your request',
    ],
    url: 'https://reportaproblem.apple.com',
    successRate: '~80% for first request',
    timeframe: 'Usually refunded within 48 hours',
    nameLocalized: {
      'pl': 'Zwrot z Apple App Store',
      'de': 'Apple App Store Erstattung',
      'fr': 'Remboursement Apple App Store',
      'es': 'Reembolso de Apple App Store',
    },
    stepsLocalized: {
      'pl': [
        'Przejdź na reportaproblem.apple.com',
        'Zaloguj się swoim Apple ID',
        'Znajdź obciążenie w historii zakupów',
        'Dotknij „Zgłoś problem" obok obciążenia',
        'Wybierz „Nie zamierzałem kupować tego przedmiotu" lub „Nie autoryzowałem tego zakupu"',
        'Dodaj krótkie wyjaśnienie: „Zostałem wprowadzony w błąd warunkami okresu próbnego"',
        'Wyślij zgłoszenie',
      ],
      'de': [
        'Gehe auf reportaproblem.apple.com',
        'Melde dich mit deiner Apple-ID an',
        'Finde die Abbuchung in deinem Kaufverlauf',
        'Tippe neben der Abbuchung auf „Problem melden"',
        'Wähle „Ich wollte diesen Artikel nicht kaufen" oder „Ich habe diesen Kauf nicht autorisiert"',
        'Füge eine kurze Erklärung hinzu: „Ich wurde durch die Testbedingungen irregeführt"',
        'Sende deine Anfrage ab',
      ],
      'fr': [
        'Va sur reportaproblem.apple.com',
        'Connecte-toi avec ton identifiant Apple',
        'Trouve le débit dans ton historique d\'achats',
        'Appuie sur « Signaler un problème » à côté du débit',
        'Sélectionne « Je n\'avais pas l\'intention d\'acheter cet article » ou « Je n\'ai pas autorisé cet achat »',
        'Ajoute une brève explication : « J\'ai été induit en erreur par les conditions d\'essai »',
        'Envoie ta demande',
      ],
      'es': [
        'Ve a reportaproblem.apple.com',
        'Inicia sesión con tu Apple ID',
        'Encuentra el cargo en tu historial de compras',
        'Toca "Informar de un problema" junto al cargo',
        'Selecciona "No tenía intención de comprar este artículo" o "No autoricé esta compra"',
        'Añade una breve explicación: "Me engañaron con los términos de la prueba"',
        'Envía tu solicitud',
      ],
    },
    successRateLocalized: {
      'pl': '~80% przy pierwszym zgłoszeniu',
      'de': '~80% beim ersten Antrag',
      'fr': '~80% à la première demande',
      'es': '~80% en la primera solicitud',
    },
    timeframeLocalized: {
      'pl': 'Zwrot zwykle w ciągu 48 godzin',
      'de': 'Normalerweise innerhalb von 48 Stunden erstattet',
      'fr': 'Remboursement généralement sous 48 heures',
      'es': 'Normalmente reembolsado en 48 horas',
    },
  ),
  RefundTemplate(
    id: 'google_play',
    name: 'Google Play Refund',
    path: RefundPath.googlePlay,
    steps: [
      'Go to play.google.com/store/account/orderhistory',
      'Find the charge you want to dispute',
      'Click "Report a problem"',
      'Select "I didn\'t mean to make this purchase" or '
          '"My purchase doesn\'t work as expected"',
      'Fill in the details and submit',
    ],
    url: 'https://play.google.com/store/account/orderhistory',
    successRate: '~70% for first request',
    timeframe: 'Usually 1\u20134 business days',
    nameLocalized: {
      'pl': 'Zwrot z Google Play',
      'de': 'Google Play Erstattung',
      'fr': 'Remboursement Google Play',
      'es': 'Reembolso de Google Play',
    },
    stepsLocalized: {
      'pl': [
        'Przejdź na play.google.com/store/account/orderhistory',
        'Znajdź obciążenie, które chcesz zakwestionować',
        'Kliknij „Zgłoś problem"',
        'Wybierz „Nie zamierzałem dokonywać tego zakupu" lub „Mój zakup nie działa zgodnie z oczekiwaniami"',
        'Wypełnij szczegóły i wyślij',
      ],
      'de': [
        'Gehe auf play.google.com/store/account/orderhistory',
        'Finde die Abbuchung, die du anfechten möchtest',
        'Klicke auf „Problem melden"',
        'Wähle „Ich wollte diesen Kauf nicht tätigen" oder „Mein Kauf funktioniert nicht wie erwartet"',
        'Fülle die Details aus und sende ab',
      ],
      'fr': [
        'Va sur play.google.com/store/account/orderhistory',
        'Trouve le débit que tu veux contester',
        'Clique sur « Signaler un problème »',
        'Sélectionne « Je n\'avais pas l\'intention de faire cet achat » ou « Mon achat ne fonctionne pas comme prévu »',
        'Remplis les détails et envoie',
      ],
      'es': [
        'Ve a play.google.com/store/account/orderhistory',
        'Encuentra el cargo que quieres disputar',
        'Haz clic en "Informar de un problema"',
        'Selecciona "No quise hacer esta compra" o "Mi compra no funciona como esperaba"',
        'Completa los detalles y envía',
      ],
    },
    successRateLocalized: {
      'pl': '~70% przy pierwszym zgłoszeniu',
      'de': '~70% beim ersten Antrag',
      'fr': '~70% à la première demande',
      'es': '~70% en la primera solicitud',
    },
    timeframeLocalized: {
      'pl': 'Zwykle 1\u20134 dni robocze',
      'de': 'Normalerweise 1\u20134 Werktage',
      'fr': 'Généralement 1 à 4 jours ouvrés',
      'es': 'Normalmente 1\u20134 días hábiles',
    },
  ),
  RefundTemplate(
    id: 'direct_billing',
    name: 'Email the Company',
    path: RefundPath.directBilling,
    steps: [
      'Find the company\'s support email (check their website '
          'footer or your confirmation email)',
      'Copy the pre-written dispute email below',
      'Fill in the highlighted fields with your details',
      'Send the email',
      'If no response in 7 days, follow up once',
      'If still no response after 14 days, escalate to bank chargeback',
    ],
    emailTemplate: '''Subject: Refund Request \u2014 Misleading Subscription Terms

Dear [Company] Support,

I signed up for what I understood to be a {trial_price} trial of {service_name} on {signup_date}.

I was not clearly informed that this would automatically renew at {real_price}. The pricing terms were not presented transparently at the point of purchase.

Under the UK Consumer Rights Act 2015, consumers are entitled to clear and transparent pricing. I am requesting a full refund of {charge_amount} charged on {charge_date}.

Please process this refund within 14 days.

Regards,
[Your name]''',
    successRate: '~50\u201360% \u2014 varies by company',
    timeframe: '3\u201314 days depending on company',
    nameLocalized: {
      'pl': 'Napisz do firmy',
      'de': 'E-Mail an das Unternehmen',
      'fr': 'Envoyer un e-mail à l\'entreprise',
      'es': 'Enviar correo a la empresa',
    },
    stepsLocalized: {
      'pl': [
        'Znajdź adres e-mail wsparcia firmy (sprawdź stopkę strony lub e-mail z potwierdzeniem)',
        'Skopiuj gotowy e-mail z reklamacją poniżej',
        'Wypełnij wyróżnione pola swoimi danymi',
        'Wyślij e-mail',
        'Jeśli brak odpowiedzi po 7 dniach, wyślij przypomnienie',
        'Jeśli brak odpowiedzi po 14 dniach, eskaluj do obciążenia zwrotnego w banku',
      ],
      'de': [
        'Finde die Support-E-Mail-Adresse des Unternehmens (prüfe den Website-Footer oder deine Bestätigungs-E-Mail)',
        'Kopiere die vorbereitete Widerspruchs-E-Mail unten',
        'Fülle die markierten Felder mit deinen Daten aus',
        'Sende die E-Mail',
        'Wenn nach 7 Tagen keine Antwort, schicke eine Erinnerung',
        'Wenn nach 14 Tagen immer noch keine Antwort, eskaliere zur Rückbuchung bei der Bank',
      ],
      'fr': [
        'Trouve l\'e-mail de support de l\'entreprise (vérifie le bas de page du site ou ton e-mail de confirmation)',
        'Copie l\'e-mail de contestation pré-rédigé ci-dessous',
        'Remplis les champs surlignés avec tes informations',
        'Envoie l\'e-mail',
        'Si pas de réponse après 7 jours, relance une fois',
        'Si toujours pas de réponse après 14 jours, passe à la rétrofacturation bancaire',
      ],
      'es': [
        'Encuentra el correo de soporte de la empresa (revisa el pie de la web o tu correo de confirmación)',
        'Copia el correo de disputa preescrito abajo',
        'Rellena los campos resaltados con tus datos',
        'Envía el correo',
        'Si no hay respuesta en 7 días, haz un seguimiento',
        'Si sigue sin respuesta después de 14 días, escala a contracargo bancario',
      ],
    },
    emailTemplateLocalized: {
      'pl': '''Temat: Prośba o zwrot \u2014 Wprowadzające w błąd warunki subskrypcji

Szanowna Obsługo,

Zarejestrowałem się w usłudze {service_name} dnia {signup_date}, rozumiejąc, że jest to okres próbny za {trial_price}.

Nie zostałem jasno poinformowany, że subskrypcja zostanie automatycznie przedłużona po cenie {real_price}. Warunki cenowe nie zostały przedstawione w sposób przejrzysty w momencie zakupu.

Zgodnie z przepisami o ochronie konsumentów, proszę o pełny zwrot kwoty {charge_amount} pobranej dnia {charge_date}.

Proszę o przetworzenie zwrotu w ciągu 14 dni.

Z poważaniem,
[Twoje imię i nazwisko]''',
      'de': '''Betreff: Erstattungsanfrage \u2014 Irreführende Abonnementbedingungen

Sehr geehrter Support,

ich habe mich am {signup_date} für ein {trial_price}-Probeabo von {service_name} angemeldet.

Ich wurde nicht klar darüber informiert, dass dieses automatisch zum Preis von {real_price} verlängert wird. Die Preisgestaltung wurde beim Kauf nicht transparent dargestellt.

Gemäß den Verbraucherschutzgesetzen bitte ich um die vollständige Erstattung von {charge_amount}, die am {charge_date} abgebucht wurde.

Bitte bearbeiten Sie diese Erstattung innerhalb von 14 Tagen.

Mit freundlichen Grüßen,
[Ihr Name]''',
      'fr': '''Objet : Demande de remboursement \u2014 Conditions d'abonnement trompeuses

Cher Support,

Je me suis inscrit le {signup_date} à ce que je comprenais être un essai à {trial_price} de {service_name}.

Je n'ai pas été clairement informé que cela serait automatiquement renouvelé au tarif de {real_price}. Les conditions tarifaires n'ont pas été présentées de manière transparente au moment de l'achat.

Conformément aux lois sur la protection des consommateurs, je demande le remboursement intégral de {charge_amount} débité le {charge_date}.

Merci de traiter ce remboursement dans un délai de 14 jours.

Cordialement,
[Votre nom]''',
      'es': '''Asunto: Solicitud de reembolso \u2014 Términos de suscripción engañosos

Estimado Soporte,

Me registré el {signup_date} en lo que entendí como una prueba de {trial_price} de {service_name}.

No fui informado claramente de que esto se renovaría automáticamente a {real_price}. Los términos de precios no se presentaron de forma transparente en el momento de la compra.

De acuerdo con las leyes de protección al consumidor, solicito el reembolso completo de {charge_amount} cobrado el {charge_date}.

Por favor, procesen este reembolso en un plazo de 14 días.

Atentamente,
[Su nombre]''',
    },
    successRateLocalized: {
      'pl': '~50\u201360% \u2014 zależy od firmy',
      'de': '~50\u201360% \u2014 variiert je nach Unternehmen',
      'fr': '~50\u201360% \u2014 varie selon l\'entreprise',
      'es': '~50\u201360% \u2014 varía según la empresa',
    },
    timeframeLocalized: {
      'pl': '3\u201314 dni w zależności od firmy',
      'de': '3\u201314 Tage je nach Unternehmen',
      'fr': '3 à 14 jours selon l\'entreprise',
      'es': '3\u201314 días según la empresa',
    },
  ),
  RefundTemplate(
    id: 'bank_chargeback',
    name: 'Bank Chargeback (Last Resort)',
    path: RefundPath.bankChargeback,
    steps: [
      'Open your banking app or call your bank',
      'Find the transaction you want to dispute',
      'Select "Dispute transaction" or "Chargeback"',
      'Reason: "Misleading subscription terms" or '
          '"Services not as described"',
      'Provide evidence: screenshot of the original offer '
          'showing the trial price',
      'Your bank will investigate \u2014 this usually takes '
          '5\u201310 business days',
    ],
    successRate: '~70\u201380% \u2014 banks are familiar with this pattern',
    timeframe: '5\u201310 business days',
    nameLocalized: {
      'pl': 'Obciążenie zwrotne w banku (ostateczność)',
      'de': 'Bank-Rückbuchung (letzter Ausweg)',
      'fr': 'Rétrofacturation bancaire (dernier recours)',
      'es': 'Contracargo bancario (último recurso)',
    },
    stepsLocalized: {
      'pl': [
        'Otwórz aplikację bankową lub zadzwoń do banku',
        'Znajdź transakcję, którą chcesz zakwestionować',
        'Wybierz „Reklamuj transakcję" lub „Obciążenie zwrotne"',
        'Powód: „Wprowadzające w błąd warunki subskrypcji" lub „Usługa niezgodna z opisem"',
        'Przedstaw dowody: zrzut ekranu oryginalnej oferty z ceną okresu próbnego',
        'Bank zbada sprawę \u2014 to zwykle trwa 5\u201310 dni roboczych',
      ],
      'de': [
        'Öffne deine Banking-App oder rufe deine Bank an',
        'Finde die Transaktion, die du anfechten möchtest',
        'Wähle „Transaktion anfechten" oder „Rückbuchung"',
        'Grund: „Irreführende Abonnementbedingungen" oder „Leistung nicht wie beschrieben"',
        'Lege Beweise vor: Screenshot des Originalangebots mit dem Testpreis',
        'Deine Bank wird ermitteln \u2014 das dauert normalerweise 5\u201310 Werktage',
      ],
      'fr': [
        'Ouvre ton appli bancaire ou appelle ta banque',
        'Trouve la transaction que tu veux contester',
        'Sélectionne « Contester la transaction » ou « Rétrofacturation »',
        'Motif : « Conditions d\'abonnement trompeuses » ou « Services non conformes à la description »',
        'Fournis des preuves : capture d\'écran de l\'offre originale avec le prix d\'essai',
        'Ta banque enquêtera \u2014 cela prend généralement 5 à 10 jours ouvrés',
      ],
      'es': [
        'Abre tu app bancaria o llama a tu banco',
        'Encuentra la transacción que quieres disputar',
        'Selecciona "Disputar transacción" o "Contracargo"',
        'Motivo: "Términos de suscripción engañosos" o "Servicios no según lo descrito"',
        'Proporciona evidencia: captura de pantalla de la oferta original con el precio de prueba',
        'Tu banco investigará \u2014 esto suele tardar 5\u201310 días hábiles',
      ],
    },
    successRateLocalized: {
      'pl': '~70\u201380% \u2014 banki znają ten schemat',
      'de': '~70\u201380% \u2014 Banken kennen dieses Muster',
      'fr': '~70\u201380% \u2014 les banques connaissent ce schéma',
      'es': '~70\u201380% \u2014 los bancos están familiarizados con este patrón',
    },
    timeframeLocalized: {
      'pl': '5\u201310 dni roboczych',
      'de': '5\u201310 Werktage',
      'fr': '5 à 10 jours ouvrés',
      'es': '5\u201310 días hábiles',
    },
  ),
];

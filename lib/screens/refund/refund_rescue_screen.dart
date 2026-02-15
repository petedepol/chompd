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
      _stepChecks = List.filled(template.steps.length, false);
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

  /// Build generic dispute email (was in refund_paths_data.dart).
  String _buildDisputeEmail(Subscription sub) {
    final dateFormat = DateFormat('d MMMM yyyy');
    final template = _genericRefundPaths
        .firstWhere((p) => p.id == 'direct_billing')
        .emailTemplate!;

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
                      template.name,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: c.mint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      context.l10n.successRate(template.successRate),
                      style: ChompdTypography.mono(
                        size: 11,
                        weight: FontWeight.w600,
                        color: c.mint,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      template.timeframe,
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
                    text: template.steps[index],
                    checked: _stepChecks[index],
                    onToggle: () => _toggleStep(index),
                  ),
                );
              },
              childCount: template.steps.length,
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
                    Container(
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
                      ),
                    ),
                  if (template.successRatePct != null)
                    const SizedBox(width: 8),
                  if (template.refundWindowDays != null)
                    Flexible(
                      child: Text(
                        '${template.refundWindowDays}-day refund window',
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
                        ' · ~${template.avgRefundDays}d avg',
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
                    template.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.successRate,
                    style: ChompdTypography.mono(
                      size: 11,
                      color: c.mint,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              template.timeframe,
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
                '${template.refundWindowDays}d window',
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
  ),
];

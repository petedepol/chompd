import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../models/cancel_guide_v2.dart';
import '../../models/subscription.dart';
import '../../providers/subscriptions_provider.dart';
import '../../services/haptic_service.dart';
import '../../services/review_service.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/cancel_celebration.dart';
import '../refund/refund_rescue_screen.dart';

class CancelGuideScreen extends ConsumerStatefulWidget {
  final Subscription subscription;
  final CancelGuideData guideData;
  final int? cancelDifficulty;

  const CancelGuideScreen({
    Key? key,
    required this.subscription,
    required this.guideData,
    this.cancelDifficulty,
  }) : super(key: key);

  @override
  ConsumerState<CancelGuideScreen> createState() => _CancelGuideScreenState();
}

class _CancelGuideScreenState extends ConsumerState<CancelGuideScreen> {
  late List<bool> _completed;

  /// Current language code for localised content.
  String get _lang => Localizations.localeOf(context).languageCode;

  @override
  void initState() {
    super.initState();
    _completed = List<bool>.filled(widget.guideData.steps.length, false);
  }

  int get _difficulty => widget.cancelDifficulty ?? 3;

  Color _getDifficultyColor() {
    final c = context.colors;
    if (_difficulty <= 3) {
      return c.mint;
    } else if (_difficulty <= 6) {
      return c.amber;
    } else {
      return c.red;
    }
  }

  String _getDifficultyLabel() {
    if (_difficulty <= 2) return context.l10n.difficultyEasy;
    if (_difficulty <= 4) return context.l10n.difficultyModerate;
    if (_difficulty <= 6) return context.l10n.difficultyMedium;
    if (_difficulty <= 8) return context.l10n.difficultyHard;
    return context.l10n.difficultyVeryHard;
  }

  void _toggleStep(int index) {
    HapticService.instance.selection();
    setState(() {
      _completed[index] = !_completed[index];
    });
  }

  void _handleCancelSubscription() {
    HapticService.instance.light();
    _showCancelConfirmDialog();
  }

  void _showCancelConfirmDialog() {
    final c = context.colors;
    final sub = widget.subscription;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.bgElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          context.l10n.cancelSubscriptionConfirm(sub.name),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: c.text,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              context.l10n.keep,
              style: TextStyle(color: c.textMid),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _completeCancellation();
            },
            child: Text(
              context.l10n.cancelSubscription,
              style: TextStyle(color: c.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _completeCancellation() {
    final sub = widget.subscription;
    ref.read(subscriptionsProvider.notifier).cancel(sub.uid);

    // Record cancellation for review prompt
    ReviewService.instance.recordCancel();

    if (mounted) {
      Navigator.of(context).pop(); // Pop the cancel guide
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        builder: (ctx) => CancelCelebration(
          subscription: sub,
          onDismiss: () {
            Navigator.of(ctx).pop();
            // Request review after celebration is dismissed
            ReviewService.instance.maybeRequestReview();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: c.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.cancelGuideTitle(widget.subscription.name),
          style: TextStyle(
            color: c.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Difficulty Indicator Card
            _buildDifficultyCard(),
            const SizedBox(height: 24),

            // Steps List
            _buildStepsList(),
            const SizedBox(height: 24),

            // Warning/Notes Card (if present)
            if (widget.guideData.getWarningText(_lang) != null) ...[
              _buildNotesCard(),
              const SizedBox(height: 24),
            ],

            // Pro tip card (if present)
            if (widget.guideData.getProTip(_lang) != null) ...[
              _buildProTipCard(),
              const SizedBox(height: 24),
            ],

            // I've Cancelled Button
            _buildCancelledButton(),
            const SizedBox(height: 16),

            // Refund tip card
            _buildRefundTipCard(),
            const SizedBox(height: 16),

            // Request Refund Button
            _buildRequestRefundButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyCard() {
    final c = context.colors;
    final difficulty = _difficulty;
    final color = _getDifficultyColor();
    // Map 1-10 to 5 blocks: each block = 2 levels
    final filledBlocks = (difficulty / 2).ceil().clamp(1, 5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: c.border.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.difficultyLevel,
            style: TextStyle(
              color: c.textDim,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: index < filledBlocks
                        ? color
                        : c.bgCard,
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getDifficultyLabel(),
            style: TextStyle(
              color: c.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList() {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.cancellationSteps,
          style: ChompdTypography.sectionLabel.copyWith(
            color: c.text,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.guideData.steps.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildStepCard(index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStepCard(int index) {
    final c = context.colors;
    final isCompleted = _completed[index];
    final step = widget.guideData.steps[index];
    final localTitle = step.getTitle(_lang);
    final localDetail = step.getDetail(_lang);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: c.border.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _toggleStep(index),
            child: Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 12, top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? c.mint : Colors.transparent,
                border: Border.all(
                  color: c.mint,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 16,
                    )
                  : null,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.stepNumber(index + 1),
                  style: ChompdTypography.mono(
                    size: 11,
                    color: c.textDim,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  localTitle,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                if (localDetail.isNotEmpty && localDetail != localTitle) ...[
                  const SizedBox(height: 2),
                  Text(
                    localDetail,
                    style: TextStyle(
                      color: c.textMid,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: c.amber.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 2),
            child: Icon(
              Icons.info_outline,
              color: c.amber,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              widget.guideData.getWarningText(_lang)!,
              style: TextStyle(
                color: c.text,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProTipCard() {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.mint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: c.mint.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 2),
            child: Icon(
              Icons.tips_and_updates_outlined,
              color: c.mint,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              widget.guideData.getProTip(_lang)!,
              style: TextStyle(
                color: c.text,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledButton() {
    final c = context.colors;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _handleCancelSubscription,
        style: OutlinedButton.styleFrom(
          foregroundColor: c.mint,
          side: BorderSide(
            color: c.mint,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          context.l10n.iveCancelled,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRefundTipCard() {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.purple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: c.purple.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 18,
            color: c.purple,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.refundTipTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.refundTipBody,
                  style: TextStyle(
                    fontSize: 12,
                    color: c.textMid,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestRefundButton() {
    final c = context.colors;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RefundRescueScreen(subscription: widget.subscription),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: c.purple.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: c.purple.withValues(alpha: 0.2),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          context.l10n.requestRefund,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: c.purple,
          ),
        ),
      ),
    );
  }

}


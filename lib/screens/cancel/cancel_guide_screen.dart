import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../models/cancel_guide_v2.dart';
import '../../models/subscription.dart';
import '../../providers/subscriptions_provider.dart';
import '../../services/haptic_service.dart';
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
    if (_difficulty <= 2) return 'Easy — straightforward cancel';
    if (_difficulty <= 4) return 'Moderate — a few steps required';
    if (_difficulty <= 6) return 'Medium — takes a few minutes';
    if (_difficulty <= 8) return 'Hard — they make this deliberately difficult';
    return 'Very hard — multiple retention screens or fees';
  }

  void _toggleStep(int index) {
    HapticService.instance.selection();
    setState(() {
      _completed[index] = !_completed[index];
    });
  }

  void _handleCancelSubscription() {
    HapticService.instance.light();
    _showCancelReasonSheet();
  }

  void _showCancelReasonSheet() {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(ctx).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: c.bgElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: c.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              context.l10n.whyCancelling,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: c.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.whyCancellingHint,
              style: TextStyle(
                fontSize: 12,
                color: c.textDim,
              ),
            ),
            const SizedBox(height: 16),

            ..._cancelReasons(context).map((reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _completeCancellation(reason);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: c.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.border),
                      ),
                      child: Row(
                        children: [
                          Text(
                            reason.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reason.label,
                              style: TextStyle(
                                fontSize: 14,
                                color: c.text,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: c.textDim,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),

            // Skip option
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  _completeCancellation(null);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    context.l10n.skip,
                    style: TextStyle(
                      fontSize: 12,
                      color: c.textDim,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _completeCancellation(_CancelReason? reason) {
    final sub = widget.subscription;

    // Log the reason (for analytics later)
    if (reason != null) {
      debugPrint('[CancelGuide] ${sub.name} cancelled: ${reason.label}');
    }

    ref.read(subscriptionsProvider.notifier).cancel(sub.uid);

    if (mounted) {
      Navigator.of(context).pop(); // Pop the cancel guide
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        builder: (ctx) => CancelCelebration(
          subscription: sub,
          onDismiss: () => Navigator.of(ctx).pop(),
        ),
      );
    }
  }

  List<_CancelReason> _cancelReasons(BuildContext context) => [
    _CancelReason('\uD83D\uDCB8', context.l10n.reasonTooExpensive),
    _CancelReason('\uD83D\uDE34', context.l10n.reasonDontUse),
    _CancelReason('\u23F8\uFE0F', context.l10n.reasonBreak),
    _CancelReason('\uD83D\uDD04', context.l10n.reasonSwitching),
    _CancelReason('\uD83E\uDD37', context.l10n.other),
  ];

  void _handleOpenCancelPage() {
    HapticService.instance.light();
    final url = widget.guideData.bestCancelUrl;
    if (url != null) {
      developer.log('Opening cancellation URL: $url', name: 'CancelGuide');
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
            if (widget.guideData.warningText != null) ...[
              _buildNotesCard(),
              const SizedBox(height: 24),
            ],

            // Pro tip card (if present)
            if (widget.guideData.proTip != null) ...[
              _buildProTipCard(),
              const SizedBox(height: 24),
            ],

            // Open Cancel Page Button
            if (widget.guideData.bestCancelUrl != null) ...[
              _buildOpenCancelPageButton(),
              const SizedBox(height: 16),
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
                  step.title,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                if (step.detail.isNotEmpty && step.detail != step.title) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.detail,
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
              widget.guideData.warningText!,
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
              widget.guideData.proTip!,
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

  Widget _buildOpenCancelPageButton() {
    final c = context.colors;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleOpenCancelPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: c.mint,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          context.l10n.openCancelPage,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
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

class _CancelReason {
  final String emoji;
  final String label;
  const _CancelReason(this.emoji, this.label);
}

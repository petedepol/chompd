import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/theme.dart';
import '../../models/scan_result.dart';
import '../../models/subscription.dart';
import '../../providers/currency_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/scan_provider.dart';
import '../../providers/subscriptions_provider.dart';
import '../../services/merchant_db.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/mascot_image.dart';
import '../../widgets/scan_shimmer.dart';
import '../../widgets/toast_overlay.dart';
import '../paywall/paywall_screen.dart';

/// The AI scan screen with conversational Q&A flow.
///
/// Matches the design prototype's chat-style interface:
/// - System messages (left, gradient bg)
/// - Info blocks (left, blue accent)
/// - Partial results (left, orange border)
/// - Questions (left, purple accent + option buttons)
/// - User answers (right, accent-tinted)
/// - Final results (left, green gradient)
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showToast = false;
  ScanResult? _toastResult;

  @override
  void initState() {
    super.initState();
    // Seed the merchant DB if not already done
    MerchantDb.instance.seed();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    final scanCounter = ref.watch(scanCounterProvider);

    // Auto-scroll when messages change
    ref.listen<ScanState>(scanProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: ChompdColors.bg,
      body: Stack(
        children: [
          // ─── Main Content ───
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 8),

              // ─── Top Bar ───
              _buildTopBar(context, scanState, scanCounter),

              const SizedBox(height: 16),

              // ─── Messages Area ───
              Expanded(
                child: scanState.phase == ScanPhase.idle
                    ? _buildIdleView(scanCounter)
                    : scanState.phase == ScanPhase.trapSkipped
                        ? _buildTrapSkippedView(scanState)
                        : _buildChatView(scanState),
              ),

              // ─── Bottom Action Bar ───
              _buildBottomBar(scanState),
            ],
          ),

          // ─── Toast Overlay ───
          if (_showToast && _toastResult != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 80,
              left: 0,
              right: 0,
              child: ScanToast(
                result: _toastResult!,
                onDismissed: () => setState(() => _showToast = false),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Top Bar ───

  Widget _buildTopBar(
      BuildContext context, ScanState scanState, int scanCount) {
    final isPro = ref.watch(isProProvider);
    final remaining = ref.watch(remainingScansProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              ref.read(scanProvider.notifier).reset();
              Navigator.of(context).pop();
            },
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
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: ChompdColors.textMid,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: ChompdColors.purple,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.scanTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ChompdColors.text,
                      ),
                    ),
                  ],
                ),
                if (scanState.phase == ScanPhase.scanning)
                  Text(
                    context.l10n.scanAnalysing,
                    style: const TextStyle(
                      fontSize: 10,
                      color: ChompdColors.purple,
                    ),
                  ),
              ],
            ),
          ),

          // Scan counter badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPro
                  ? ChompdColors.mint.withValues(alpha: 0.12)
                  : (remaining == 0
                      ? ChompdColors.red.withValues(alpha: 0.12)
                      : ChompdColors.purple.withValues(alpha: 0.12)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isPro ? context.l10n.proInfinity : context.l10n.scansLeftCount(remaining),
              style: ChompdTypography.mono(
                size: 9,
                weight: FontWeight.w700,
                color: isPro
                    ? ChompdColors.mint
                    : (remaining == 0
                        ? ChompdColors.red
                        : ChompdColors.purple),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Idle View — scenario picker for prototype ───

  Widget _buildIdleView(int scanCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Spacer(),

          // AI sparkle icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: ChompdColors.purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.auto_awesome,
              size: 32,
              color: ChompdColors.purple,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            context.l10n.scanIdleTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ChompdColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.scanIdleSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: ChompdColors.textDim,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Camera scan button
          GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ChompdColors.purple, Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: ChompdColors.purple.withValues(alpha: 0.27),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.takePhoto,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Gallery picker button
          GestureDetector(
            onTap: () => _pickImage(ImageSource.gallery),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ChompdColors.border),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library_outlined, size: 18, color: ChompdColors.textMid),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.chooseFromGallery,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ChompdColors.textMid,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  /// Pick an image from camera or gallery and start a real AI scan.
  Future<void> _pickImage(ImageSource source) async {
    final canScan = ref.read(canScanProvider);
    if (!canScan) {
      await showPaywall(context, trigger: PaywallTrigger.scanLimit);
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (picked == null) return; // User cancelled

      final bytes = await picked.readAsBytes();
      final mimeType = picked.mimeType ??
          (picked.path.toLowerCase().endsWith('.png')
              ? 'image/png'
              : 'image/jpeg');

      ref.read(scanCounterProvider.notifier).increment();
      ref.read(scanProvider.notifier).startScan(
            imageBytes: bytes,
            mimeType: mimeType,
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? context.l10n.cameraPermError
                : context.l10n.galleryPermError,
          ),
          backgroundColor: ChompdColors.bgElevated,
        ),
      );
    }
  }

  // ─── Trap Skipped Celebration View ───

  Widget _buildTrapSkippedView(ScanState scanState) {
    final savedAmount = scanState.skippedSavingsAmount ?? 0;
    final serviceName = scanState.skippedServiceName ?? 'Unknown';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Celebrate piranha GIF
            const MascotImage(
              asset: 'piranha_celebrate_anim.gif',
              size: 120,
              fadeIn: true,
              fadeDuration: Duration(milliseconds: 400),
            ),
            const SizedBox(height: 24),

            // Smart move text
            Text(
              context.l10n.smartMove,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ChompdColors.text,
              ),
            ),
            const SizedBox(height: 8),

            // Service name
            Text(
              context.l10n.youSkipped(serviceName),
              style: const TextStyle(
                fontSize: 14,
                color: ChompdColors.textMid,
              ),
            ),
            const SizedBox(height: 20),

            // Savings amount badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ChompdColors.mintDark, ChompdColors.mint],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ChompdColors.mint.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    context.l10n.saved,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: ChompdColors.bg,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\u00A3${savedAmount.toStringAsFixed(2)}',
                    style: ChompdTypography.mono(
                      size: 32,
                      weight: FontWeight.w700,
                      color: ChompdColors.bg,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Added to Unchompd note
            Text(
              context.l10n.addedToUnchompd,
              style: const TextStyle(
                fontSize: 12,
                color: ChompdColors.textDim,
              ),
            ),
            const SizedBox(height: 32),

            // Done button
            GestureDetector(
              onTap: () {
                ref.read(scanProvider.notifier).reset();
                Navigator.of(context).pop();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: ChompdColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  context.l10n.done,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ChompdColors.textMid,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Chat View ───

  Widget _buildChatView(ScanState scanState) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: scanState.messages.length +
          (scanState.phase == ScanPhase.scanning ? 1 : 0),
      itemBuilder: (context, index) {
        // Typing indicator during scanning
        if (index == scanState.messages.length &&
            scanState.phase == ScanPhase.scanning) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thinking piranha GIF
                const MascotImage(
                  asset: 'piranha_thinking_anim.gif',
                  size: 80,
                  fadeIn: true,
                ),
                const SizedBox(height: 8),
                _ChatBubble(
                  isUser: false,
                  borderColor: ChompdColors.purple,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const TypingDots(),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.analysing,
                        style: TextStyle(
                          fontSize: 12,
                          color: ChompdColors.purple.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final msg = scanState.messages[index];
        return _buildMessage(msg, index, scanState);
      },
    );
  }

  Widget _buildMessage(ChatMessage msg, int index, ScanState scanState) {
    switch (msg.type) {
      case ChatMessageType.system:
        return _SystemMessage(text: msg.text);

      case ChatMessageType.info:
        return _InfoMessage(text: msg.text);

      case ChatMessageType.partial:
        return _PartialResultMessage(
          text: msg.text,
          result: msg.scanResult,
        );

      case ChatMessageType.question:
        return _QuestionMessage(
          text: msg.text,
          questionType: msg.questionType!,
          options: msg.options!,
          isAnswered: msg.isAnswered,
          selectedAnswer: msg.selectedAnswer,
          onAnswer: (answer) => _onAnswer(index, answer, scanState),
          defaultCurrency: ref.read(currencyProvider),
        );

      case ChatMessageType.answer:
        return _AnswerMessage(text: msg.text);

      case ChatMessageType.result:
        return _ResultMessage(
          text: msg.text,
          result: msg.scanResult!,
          onAdd: () => _addSubscription(msg.scanResult!),
        );

      case ChatMessageType.multiResult:
        return _MultiResultMessage(
          text: msg.text,
          results: msg.multiResults!,
          onAddAll: () => _addAllSubscriptions(msg.multiResults!),
        );
    }
  }

  void _onAnswer(int index, String answer, ScanState scanState) {
    ref.read(scanProvider.notifier).answerQuestion(index, answer);

    // For trial scenario, add follow-up currency question after first answer
    final currentResult = scanState.currentResult;
    if (currentResult != null &&
        currentResult.isTrial &&
        currentResult.currency != 'GBP') {
      // Check if this is the first question being answered
      final answeredCount = scanState.messages
          .where((m) =>
              m.type == ChatMessageType.question && m.isAnswered)
          .length;
      if (answeredCount == 0) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ref.read(scanProvider.notifier).addFollowUpQuestion();
          }
        });
      }
    }
  }

  void _addSubscription(ScanResult result) async {
    final canAdd = ref.read(canAddSubProvider);
    if (!canAdd) {
      await showPaywall(context, trigger: PaywallTrigger.subscriptionLimit);
      return;
    }

    final now = DateTime.now();
    final sub = Subscription()
      ..uid =
          '${result.serviceName.toLowerCase().replaceAll(' ', '-')}-${now.millisecondsSinceEpoch}'
      ..name = result.serviceName
      ..price = result.price ?? 0
      ..currency = result.currency
      ..cycle = _parseCycle(result.billingCycle ?? 'monthly')
      ..nextRenewal =
          result.nextRenewal ?? now.add(const Duration(days: 30))
      ..category = result.category ?? 'Other'
      ..isTrial = result.isTrial
      ..trialEndDate = result.trialEndDate
      ..iconName = result.iconName
      ..brandColor = result.brandColor
      ..isActive = true
      ..source = SubscriptionSource.aiScan
      ..createdAt = now;

    ref.read(subscriptionsProvider.notifier).add(sub);

    // Show toast
    setState(() {
      _showToast = true;
      _toastResult = result;
    });

    // Pop back to home after delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        ref.read(scanProvider.notifier).reset();
        Navigator.of(context).pop();
      }
    });
  }

  void _addAllSubscriptions(List<ScanResult> results) async {
    final canAdd = ref.read(canAddSubProvider);
    if (!canAdd) {
      await showPaywall(context, trigger: PaywallTrigger.subscriptionLimit);
      return;
    }

    final now = DateTime.now();
    for (final result in results) {
      final sub = Subscription()
        ..uid =
            '${result.serviceName.toLowerCase().replaceAll(' ', '-')}-${now.millisecondsSinceEpoch}'
        ..name = result.serviceName
        ..price = result.price ?? 0
        ..currency = result.currency
        ..cycle = _parseCycle(result.billingCycle ?? 'monthly')
        ..nextRenewal =
            result.nextRenewal ?? now.add(const Duration(days: 30))
        ..category = result.category ?? 'Other'
        ..isTrial = result.isTrial
        ..trialEndDate = result.trialEndDate
        ..iconName = result.iconName
        ..brandColor = result.brandColor
        ..isActive = true
        ..source = SubscriptionSource.aiScan
        ..createdAt = now;

      ref.read(subscriptionsProvider.notifier).add(sub);
    }

    // Show toast for first result
    if (results.isNotEmpty) {
      setState(() {
        _showToast = true;
        _toastResult = results.first;
      });
    }

    // Pop back after delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        ref.read(scanProvider.notifier).reset();
        Navigator.of(context).pop();
      }
    });
  }

  BillingCycle _parseCycle(String cycle) {
    switch (cycle.toLowerCase()) {
      case 'weekly':
        return BillingCycle.weekly;
      case 'quarterly':
        return BillingCycle.quarterly;
      case 'yearly':
        return BillingCycle.yearly;
      default:
        return BillingCycle.monthly;
    }
  }

  // ─── Bottom Bar ───

  Widget _buildBottomBar(ScanState scanState) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    if (scanState.phase == ScanPhase.idle) {
      return SizedBox(height: bottomPadding + 16);
    }

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 16),
      child: scanState.phase == ScanPhase.result
          ? const SizedBox.shrink()
          : const SizedBox.shrink(),
    );
  }
}

// ──────────────────────────────────────────────
// Chat Message Widgets
// ──────────────────────────────────────────────

/// Base chat bubble container.
class _ChatBubble extends StatelessWidget {
  final bool isUser;
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;

  const _ChatBubble({
    required this.isUser,
    required this.child,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isUser
                  ? ChompdColors.mint.withValues(alpha: 0.12)
                  : ChompdColors.bgCard),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 14),
          ),
          border: Border.all(
            color: borderColor ?? ChompdColors.border,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// System message — "Screenshot received!", "Analysing..."
class _SystemMessage extends StatelessWidget {
  final String text;
  const _SystemMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return _ChatBubble(
      isUser: false,
      borderColor: ChompdColors.purple.withValues(alpha: 0.3),
      backgroundColor: ChompdColors.purple.withValues(alpha: 0.08),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('\uD83E\uDD16', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: ChompdColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Info message — stats, auto-detection confirmations.
class _InfoMessage extends StatelessWidget {
  final String text;
  const _InfoMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return _ChatBubble(
      isUser: false,
      borderColor: ChompdColors.blue.withValues(alpha: 0.3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('\u2139\uFE0F', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                color: ChompdColors.textMid,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Partial result — low-confidence result with details.
class _PartialResultMessage extends StatelessWidget {
  final String text;
  final ScanResult? result;
  const _PartialResultMessage({required this.text, this.result});

  @override
  Widget build(BuildContext context) {
    return _ChatBubble(
      isUser: false,
      borderColor: ChompdColors.amber.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('\uD83D\uDD0D', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: ChompdColors.text,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (result != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: ChompdColors.bgElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(result!.overallConfidence * 100).round()}%',
                    style: ChompdTypography.mono(
                      size: 11,
                      weight: FontWeight.w700,
                      color: result!.overallConfidence >= 0.7
                          ? ChompdColors.amber
                          : ChompdColors.red,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.confidence,
                    style: const TextStyle(
                      fontSize: 10,
                      color: ChompdColors.textDim,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Question message with interactive option buttons.
class _QuestionMessage extends StatefulWidget {
  final String text;
  final QuestionType questionType;
  final List<String> options;
  final bool isAnswered;
  final String? selectedAnswer;
  final void Function(String) onAnswer;
  final String defaultCurrency;

  const _QuestionMessage({
    required this.text,
    required this.questionType,
    required this.options,
    required this.isAnswered,
    this.selectedAnswer,
    required this.onAnswer,
    this.defaultCurrency = 'USD',
  });

  @override
  State<_QuestionMessage> createState() => _QuestionMessageState();
}

class _QuestionMessageState extends State<_QuestionMessage> {
  bool _showOtherInput = false;
  final TextEditingController _otherCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  late String _priceCurrency;
  String _priceCycle = 'mo';

  @override
  void initState() {
    super.initState();
    _priceCurrency = widget.defaultCurrency;
  }

  /// Whether this question is asking for a price (options contain "/mo" or "/yr").
  bool get _isPriceQuestion =>
      widget.options.any((o) => o.contains('/mo') || o.contains('/yr'));

  @override
  void dispose() {
    _otherCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ChatBubble(
      isUser: false,
      borderColor: ChompdColors.purple.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('\uD83D\uDCAC', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: ChompdColors.text,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (widget.isAnswered)
            // Show selected answer dimmed
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ChompdColors.mint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ChompdColors.mint.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: ChompdColors.mint,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.selectedAnswer ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ChompdColors.mint,
                    ),
                  ),
                ],
              ),
            )
          else if (_showOtherInput && _isPriceQuestion)
            // Custom price input with currency + cycle
            _buildPriceInput()
          else if (_showOtherInput)
            // Generic "Other" text input (for non-price questions)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _otherCtrl,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ChompdColors.text,
                    ),
                    decoration: InputDecoration(
                      hintText: context.l10n.typeYourAnswer,
                      hintStyle: const TextStyle(
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
                        borderSide: const BorderSide(
                          color: ChompdColors.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: ChompdColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: ChompdColors.purple,
                        ),
                      ),
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        widget.onAnswer(v.trim());
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (_otherCtrl.text.trim().isNotEmpty) {
                      widget.onAnswer(_otherCtrl.text.trim());
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: ChompdColors.purple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.send_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          else
            // Option buttons
            _buildOptions(),
        ],
      ),
    );
  }

  void _submitPrice() {
    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price <= 0) return;

    final sym = Subscription.currencySymbol(_priceCurrency);
    final isSuffix = Subscription.isSymbolSuffix(_priceCurrency);
    final value = price.toStringAsFixed(2);
    // Format: "£19.99/mo [GBP]" — currency code in brackets for the provider to extract
    final priceStr = isSuffix ? '$value $sym' : '$sym$value';
    widget.onAnswer('$priceStr/$_priceCycle [$_priceCurrency]');
  }

  Widget _buildPriceInput() {
    final isValid = (double.tryParse(_priceCtrl.text.trim()) ?? 0) > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price + Currency row
        Row(
          children: [
            // Price field
            Expanded(
              flex: 2,
              child: TextField(
                controller: _priceCtrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                style: ChompdTypography.mono(
                  size: 14,
                  weight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    color: ChompdColors.textDim.withValues(alpha: 0.5),
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
                    borderSide: const BorderSide(color: ChompdColors.purple),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submitPrice(),
              ),
            ),
            const SizedBox(width: 8),

            // Currency dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: ChompdColors.bgElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ChompdColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _priceCurrency,
                  dropdownColor: ChompdColors.bgElevated,
                  style: ChompdTypography.mono(
                    size: 11,
                    weight: FontWeight.w600,
                  ),
                  icon: const Icon(
                    Icons.expand_more_rounded,
                    size: 14,
                    color: ChompdColors.textDim,
                  ),
                  items: supportedCurrencies
                      .map((c) => DropdownMenuItem<String>(
                            value: c['code'] as String,
                            child: Text(
                              '${c['symbol']} ${c['code']}',
                              style: ChompdTypography.mono(
                                size: 11,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _priceCurrency = v);
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Cycle toggle + send button row
        Row(
          children: [
            // Cycle chips
            ...['mo', 'yr', 'wk', 'qtr'].map((c) {
              final isSelected = c == _priceCycle;
              final label = c == 'mo'
                  ? context.l10n.cycleMonthly
                  : c == 'yr'
                      ? context.l10n.cycleYearly
                      : c == 'wk'
                          ? context.l10n.cycleWeekly
                          : context.l10n.cycleQuarterly;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _priceCycle = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ChompdColors.purple.withValues(alpha: 0.15)
                          : ChompdColors.bgElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? ChompdColors.purple.withValues(alpha: 0.5)
                            : ChompdColors.border,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? ChompdColors.purple : ChompdColors.textDim,
                      ),
                    ),
                  ),
                ),
              );
            }),

            const Spacer(),

            // Send button
            GestureDetector(
              onTap: isValid ? _submitPrice : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isValid ? ChompdColors.purple : ChompdColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.send_rounded,
                  size: 16,
                  color: isValid ? Colors.white : ChompdColors.textDim,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptions() {
    if (widget.questionType == QuestionType.confirm) {
      // Confirm: large primary button + smaller alternatives
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary confirm button
          GestureDetector(
            onTap: () => widget.onAnswer(widget.options.first),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ChompdColors.mintDark, ChompdColors.mint],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                context.l10n.yesIts(widget.options.first),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ChompdColors.bg,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Alternative options as pills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.options.skip(1).map((opt) {
              return _OptionPill(
                label: opt,
                onTap: () {
                  if (opt == 'Other' || opt == 'Other amount') {
                    setState(() => _showOtherInput = true);
                  } else {
                    widget.onAnswer(opt);
                  }
                },
              );
            }).toList(),
          ),
        ],
      );
    } else {
      // Choose: all pill buttons
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: widget.options.map((opt) {
          return _OptionPill(
            label: opt,
            onTap: () {
              if (opt == 'Other' || opt == 'Other amount') {
                setState(() => _showOtherInput = true);
              } else {
                widget.onAnswer(opt);
              }
            },
          );
        }).toList(),
      );
    }
  }
}

/// User answer bubble — right-aligned, accent-tinted.
class _AnswerMessage extends StatelessWidget {
  final String text;
  const _AnswerMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return _ChatBubble(
      isUser: true,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ChompdColors.mint,
        ),
      ),
    );
  }
}

/// Final confirmed result with "Add" button.
class _ResultMessage extends StatefulWidget {
  final String text;
  final ScanResult result;
  final VoidCallback onAdd;

  const _ResultMessage({
    required this.text,
    required this.result,
    required this.onAdd,
  });

  @override
  State<_ResultMessage> createState() => _ResultMessageState();
}

class _ResultMessageState extends State<_ResultMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _brandColor {
    final hex =
        widget.result.brandColor?.replaceFirst('#', '') ?? '6EE7B7';
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    return _ChatBubble(
      isUser: false,
      borderColor: ChompdColors.mint.withValues(alpha: 0.4),
      backgroundColor: ChompdColors.mint.withValues(alpha: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('\u2705', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ChompdColors.mint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Result card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ChompdColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ChompdColors.border),
            ),
            child: Row(
              children: [
                // Brand icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        _brandColor.withValues(alpha: 0.87),
                        _brandColor.withValues(alpha: 0.53),
                      ],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    r.iconName ?? r.serviceName[0],
                    style: const TextStyle(
                      fontSize: 16,
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
                        r.serviceName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ChompdColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${Subscription.formatPrice(r.price ?? 0, r.currency)}/${r.billingCycle == 'monthly' ? 'mo' : r.billingCycle ?? 'mo'}',
                            style: ChompdTypography.mono(
                              size: 12,
                              weight: FontWeight.w700,
                              color: ChompdColors.textMid,
                            ),
                          ),
                          if (r.isTrial) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ChompdColors.amberGlow,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                context.l10n.trialLabel,
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: ChompdColors.amber,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Add button with pulse
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return GestureDetector(
                onTap: widget.onAdd,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [ChompdColors.mintDark, ChompdColors.mint],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: ChompdColors.mint.withValues(alpha: 
                          0.15 + _pulseController.value * 0.15,
                        ),
                        blurRadius: 8 + _pulseController.value * 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded, size: 16, color: ChompdColors.bg),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.addToChompd,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: ChompdColors.bg,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Multiple results card for bank statement scans.
class _MultiResultMessage extends StatelessWidget {
  final String text;
  final List<ScanResult> results;
  final VoidCallback onAddAll;

  const _MultiResultMessage({
    required this.text,
    required this.results,
    required this.onAddAll,
  });

  @override
  Widget build(BuildContext context) {
    final total = results.fold(0.0, (sum, r) => sum + (r.price ?? 0));

    return _ChatBubble(
      isUser: false,
      borderColor: ChompdColors.mint.withValues(alpha: 0.4),
      backgroundColor: ChompdColors.mint.withValues(alpha: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('\u2705', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ChompdColors.mint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Individual result rows
          ...results.map((r) => _MiniResultRow(result: r)),

          // Total
          const Divider(color: ChompdColors.border, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.monthlyTotal,
                style: const TextStyle(
                  fontSize: 11,
                  color: ChompdColors.textDim,
                ),
              ),
              Text(
                '\u00A3${total.toStringAsFixed(2)}/mo',
                style: ChompdTypography.mono(
                  size: 13,
                  weight: FontWeight.w700,
                  color: ChompdColors.text,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Add all button
          GestureDetector(
            onTap: onAddAll,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ChompdColors.mintDark, ChompdColors.mint],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                context.l10n.addAllToChompd(results.length),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ChompdColors.bg,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact result row for multi-sub cards.
class _MiniResultRow extends StatelessWidget {
  final ScanResult result;
  const _MiniResultRow({required this.result});

  Color get _brandColor {
    final hex = result.brandColor?.replaceFirst('#', '') ?? '6EE7B7';
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _brandColor.withValues(alpha: 0.2),
            ),
            alignment: Alignment.center,
            child: Text(
              result.iconName ?? result.serviceName[0],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _brandColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              result.serviceName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ChompdColors.text,
              ),
            ),
          ),
          if (result.tier == 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: ChompdColors.mint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                context.l10n.autoTier,
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  color: ChompdColors.mint,
                ),
              ),
            ),
          Text(
            Subscription.formatPrice(result.price ?? 0, result.currency),
            style: ChompdTypography.mono(
              size: 11,
              weight: FontWeight.w700,
              color: ChompdColors.textMid,
            ),
          ),
        ],
      ),
    );
  }
}

/// Option pill button.
class _OptionPill extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _OptionPill({required this.label, required this.onTap});

  @override
  State<_OptionPill> createState() => _OptionPillState();
}

class _OptionPillState extends State<_OptionPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _pressed
              ? ChompdColors.purple.withValues(alpha: 0.15)
              : ChompdColors.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _pressed
                ? ChompdColors.purple.withValues(alpha: 0.5)
                : ChompdColors.border,
          ),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _pressed ? ChompdColors.purple : ChompdColors.textMid,
          ),
        ),
      ),
    );
  }
}


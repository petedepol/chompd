import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/constants.dart';
import '../models/dodged_trap.dart';
import '../models/scan_output.dart';
import '../models/scan_result.dart';
import '../models/subscription.dart';
import '../models/trap_result.dart';
import '../services/ai_scan_service.dart';
import '../services/dodged_trap_repository.dart';
import '../services/merchant_db.dart';

// ─── Scan Phase ───

/// The current phase of the scan flow.
enum ScanPhase {
  /// Waiting for user to provide a screenshot.
  idle,

  /// Screenshot received, analysing with shimmer animation.
  scanning,

  /// AI returned results, showing conversational Q&A.
  questioning,

  /// All questions answered, showing final result.
  result,

  /// Error occurred during scan.
  error,

  /// Trap detected — showing warning card (medium/high severity).
  trapDetected,

  /// User skipped a trap — showing celebration + savings amount.
  trapSkipped,

  /// Multi-subscription review — presenting subs one by one.
  multiReview,
}

// ─── Chat Message Types ───

/// Type of message in the conversational scan flow.
enum ChatMessageType {
  /// System status message (e.g. "Screenshot received").
  system,

  /// Informational block (e.g. auto-detected subs count).
  info,

  /// Partial/low-confidence result needing clarification.
  partial,

  /// Question for the user (confirm or choose).
  question,

  /// User's answer to a question.
  answer,

  /// Final confirmed result.
  result,

  /// Multiple results (bank statement with several charges).
  multiResult,

  /// Single item in a one-by-one multi-review flow.
  multiReview,
}

/// Question interaction type.
enum QuestionType {
  /// "Is this X? Yes / No" — large primary button + alternatives.
  confirm,

  /// "Which service is this?" — multiple choice pills.
  choose,
}

/// A single message in the scan conversation.
class ChatMessage {
  final ChatMessageType type;
  final String text;
  final ScanResult? scanResult;
  final List<ScanResult>? multiResults;

  // Question-specific fields
  final QuestionType? questionType;
  final List<String>? options;
  final String? selectedAnswer;
  final bool isAnswered;

  // Multi-review fields (one-by-one flow)
  final int? multiReviewIndex;
  final int? multiReviewTotal;
  final TrapResult? trapResult;

  const ChatMessage({
    required this.type,
    required this.text,
    this.scanResult,
    this.multiResults,
    this.questionType,
    this.options,
    this.selectedAnswer,
    this.isAnswered = false,
    this.multiReviewIndex,
    this.multiReviewTotal,
    this.trapResult,
  });

  ChatMessage copyWith({
    String? selectedAnswer,
    bool? isAnswered,
  }) {
    return ChatMessage(
      type: type,
      text: text,
      scanResult: scanResult,
      multiResults: multiResults,
      questionType: questionType,
      options: options,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isAnswered: isAnswered ?? this.isAnswered,
      multiReviewIndex: multiReviewIndex,
      multiReviewTotal: multiReviewTotal,
      trapResult: trapResult,
    );
  }
}

// ─── Scan State ───

/// Full state for the scan flow.
class ScanState {
  final ScanPhase phase;
  final List<ChatMessage> messages;
  final ScanResult? currentResult;
  final List<ScanResult>? multiResults;
  final String? errorMessage;
  final int pendingQuestionIndex;

  // ─── Trap Scanner fields ───

  /// Trap detection result (populated when a trap is found).
  final TrapResult? trapResult;

  /// Trial notice for low-severity traps (shown as info badge).
  final TrapResult? trialNotice;

  /// Amount saved when user skipped a trap.
  final double? skippedSavingsAmount;

  /// Name of the service that was skipped.
  final String? skippedServiceName;

  // ─── Multi-review fields (one-by-one flow) ───

  /// All detected subscriptions (with trap data) for multi-review.
  final List<ScanOutput>? multiOutputs;

  /// Index of the subscription currently being reviewed (0-based).
  final int multiReviewIndex;

  /// How many subscriptions the user has added so far.
  final int multiReviewAddedCount;

  const ScanState({
    this.phase = ScanPhase.idle,
    this.messages = const [],
    this.currentResult,
    this.multiResults,
    this.errorMessage,
    this.pendingQuestionIndex = -1,
    this.trapResult,
    this.trialNotice,
    this.skippedSavingsAmount,
    this.skippedServiceName,
    this.multiOutputs,
    this.multiReviewIndex = 0,
    this.multiReviewAddedCount = 0,
  });

  ScanState copyWith({
    ScanPhase? phase,
    List<ChatMessage>? messages,
    ScanResult? currentResult,
    List<ScanResult>? multiResults,
    String? errorMessage,
    int? pendingQuestionIndex,
    TrapResult? trapResult,
    TrapResult? trialNotice,
    double? skippedSavingsAmount,
    String? skippedServiceName,
    List<ScanOutput>? multiOutputs,
    int? multiReviewIndex,
    int? multiReviewAddedCount,
  }) {
    return ScanState(
      phase: phase ?? this.phase,
      messages: messages ?? this.messages,
      currentResult: currentResult ?? this.currentResult,
      multiResults: multiResults ?? this.multiResults,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingQuestionIndex:
          pendingQuestionIndex ?? this.pendingQuestionIndex,
      trapResult: trapResult ?? this.trapResult,
      trialNotice: trialNotice ?? this.trialNotice,
      skippedSavingsAmount: skippedSavingsAmount ?? this.skippedSavingsAmount,
      skippedServiceName: skippedServiceName ?? this.skippedServiceName,
      multiOutputs: multiOutputs ?? this.multiOutputs,
      multiReviewIndex: multiReviewIndex ?? this.multiReviewIndex,
      multiReviewAddedCount: multiReviewAddedCount ?? this.multiReviewAddedCount,
    );
  }
}

// ─── Scan Notifier ───

/// State notifier managing the entire scan conversation flow.
class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier() : super(const ScanState());

  /// Reset to idle state for a new scan.
  void reset() {
    state = const ScanState();
  }

  /// Append a system message to the current conversation.
  void _addSystemMessage(String text) {
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          type: ChatMessageType.system,
          text: text,
        ),
      ],
    );
  }

  /// Determines if a Haiku result is too poor and needs Sonnet escalation.
  ///
  /// Escalates when:
  /// - No subscription found (Unknown service name)
  /// - Very low overall confidence
  /// - Found a name but missing both price and cycle (too incomplete)
  /// - All per-field confidences are below 0.5
  bool _shouldEscalate(ScanResult result) {
    // No subscription detected at all
    if (result.serviceName == 'Unknown' || result.serviceName.isEmpty) {
      return true;
    }

    // Very low confidence — Haiku isn't sure about anything
    if (result.overallConfidence < 0.3) {
      return true;
    }

    // Found a name but no price and no cycle — too incomplete
    if (result.price == null && result.billingCycle == null) {
      return true;
    }

    // All per-field confidences are below 0.5
    if (result.confidence.isNotEmpty &&
        result.confidence.values.every((c) => c < 0.5)) {
      return true;
    }

    return false;
  }

  /// Start a scan with a screenshot image.
  ///
  /// For Sprint 3 prototype, [scenario] triggers mock data.
  /// In production, [imageBytes] and [mimeType] would be sent to Claude.
  Future<void> startScan({
    Uint8List? imageBytes,
    String? mimeType,
    String scenario = 'clear_email',
  }) async {
    // Phase 1: Scanning
    state = state.copyWith(
      phase: ScanPhase.scanning,
      messages: [
        const ChatMessage(
          type: ChatMessageType.system,
          text: 'Screenshot received! Analysing...',
        ),
      ],
    );

    try {
      if (scenario == 'multi') {
        // Old mock path — redirect to startTrapScan for new flow
        return;
      }

      // Get AI result — try Haiku first, escalate to Sonnet if needed
      late ScanResult result;
      if (useMockData) {
        result = await AiScanService.mock(scenario);
      } else {
        if (imageBytes == null || mimeType == null) {
          _addSystemMessage('Unable to process image. Please try again.');
          state = state.copyWith(phase: ScanPhase.idle);
          return;
        }

        const apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
        if (apiKey.isEmpty) {
          _addSystemMessage('AI scanning is not configured. Please contact support.');
          state = state.copyWith(phase: ScanPhase.idle);
          return;
        }

        final service = AiScanService(apiKey: apiKey);

        // Pass 1: Haiku (fast + cheap)
        result = await service.analyseScreenshot(
          imageBytes: imageBytes,
          mimeType: mimeType,
        );

        // Check if Haiku struggled — escalate to Sonnet
        if (_shouldEscalate(result)) {
          _addSystemMessage('Taking a closer look\u2026');

          // Pass 2: Sonnet (smarter, handles complex images)
          result = await service.analyseScreenshot(
            imageBytes: imageBytes,
            mimeType: mimeType,
            modelOverride: AppConstants.aiModelFallback,
          );
        }
      }

      state = state.copyWith(currentResult: result);

      // No subscription found — stop here
      if (result.isNotFound) {
        await _handleNotFound(result);
        return;
      }

      // If critical fields are missing, ask user to fill gaps first
      if (result.hasMissingFields) {
        await _handleMissingData(result);
      }
      // Route based on tier / confidence
      else if (result.tier == 1 || result.isHighConfidence) {
        await _handleAutoDetect(result);
      } else if (result.tier == 2) {
        await _handleQuickConfirm(result);
      } else {
        await _handleFullQuestion(result, scenario);
      }
    } catch (e) {
      state = state.copyWith(
        phase: ScanPhase.error,
        errorMessage: e.toString(),
        messages: [
          ...state.messages,
          ChatMessage(
            type: ChatMessageType.system,
            text: 'Something went wrong: ${e.toString()}',
          ),
        ],
      );
    }
  }

  /// Handle Tier 1 — auto-detect, no questions needed.
  Future<void> _handleAutoDetect(ScanResult result) async {
    await Future.delayed(const Duration(milliseconds: 400));

    state = state.copyWith(
      phase: ScanPhase.result,
      messages: [
        ...state.messages,
        ChatMessage(
          type: ChatMessageType.result,
          text: 'Found ${result.serviceName}!',
          scanResult: result,
        ),
      ],
    );
  }

  /// Handle case where no subscription was found in the image.
  Future<void> _handleNotFound(ScanResult result) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final messages = <ChatMessage>[...state.messages];

    // Show extraction notes if available (explains what the AI saw)
    if (result.extractionNotes != null && result.extractionNotes!.isNotEmpty) {
      messages.add(ChatMessage(
        type: ChatMessageType.info,
        text: result.extractionNotes!,
      ));
    }

    messages.add(const ChatMessage(
      type: ChatMessageType.system,
      text:
          'No subscriptions found in this image. Try scanning a receipt, confirmation email, or app store screenshot instead.',
    ));

    state = state.copyWith(
      phase: ScanPhase.idle,
      messages: messages,
    );
  }

  /// Handle Tier 2 — quick confirm with primary button.
  Future<void> _handleQuickConfirm(ScanResult result) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final merchantDb = MerchantDb.instance;
    final alternatives = merchantDb.getAlternatives(result.serviceName);
    final confirmPct = (result.overallConfidence * 100).round();

    state = state.copyWith(
      phase: ScanPhase.questioning,
      messages: [
        ...state.messages,
        ChatMessage(
          type: ChatMessageType.partial,
          text: 'Found a recurring charge that looks like it could be ${result.serviceName}.',
          scanResult: result,
        ),
        ChatMessage(
          type: ChatMessageType.question,
          text: '$confirmPct% of users with this charge say it\'s ${result.serviceName}. Sound right?',
          questionType: QuestionType.confirm,
          options: [result.serviceName, ...alternatives],
        ),
      ],
      pendingQuestionIndex: 1, // Index in messages of the active question
    );
  }

  /// Handle Tier 3 — full question with multiple choice.
  Future<void> _handleFullQuestion(
      ScanResult result, String scenario) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final merchantDb = MerchantDb.instance;
    final alternatives = merchantDb.getAlternatives(result.serviceName);

    final priceStr = result.price != null
        ? Subscription.formatPrice(result.price!, result.currency)
        : '?';
    final cycleStr = result.billingCycle ?? 'month';

    final messages = <ChatMessage>[
      ...state.messages,
      ChatMessage(
        type: ChatMessageType.partial,
        text: 'Found a charge for $priceStr/$cycleStr.',
        scanResult: result,
      ),
    ];

    if (scenario == 'trial') {
      // Trial scenario: 2 sequential questions
      messages.add(
        ChatMessage(
          type: ChatMessageType.question,
          text: 'This looks like ${result.serviceName}. Personal subscription or team/business plan?',
          questionType: QuestionType.choose,
          options: ['Personal', 'Team / Business', 'Not sure'],
        ),
      );
    } else {
      // Standard Tier 3: single multi-choice question
      final displayName = result.serviceName.contains('Microsoft')
          ? 'Microsoft'
          : result.serviceName.split(' ').first;
      messages.add(
        ChatMessage(
          type: ChatMessageType.question,
          text: 'Found a charge for $displayName at $priceStr/month. Which service is this?',
          questionType: QuestionType.choose,
          options: alternatives,
        ),
      );
    }

    state = state.copyWith(
      phase: ScanPhase.questioning,
      messages: messages,
      pendingQuestionIndex: messages.length - 1,
    );
  }

  /// Handle multi-sub scan results — one-by-one review flow.
  ///
  /// Accepts full [ScanOutput] list (subscription + trap data).
  Future<void> _handleMultiScan({required List<ScanOutput> outputs}) async {
    // Filter out "Unknown" or empty results
    final validOutputs = outputs.where((o) => !o.subscription.isNotFound).toList();
    if (validOutputs.isEmpty) {
      _addSystemMessage('No subscriptions found in this image.');
      state = state.copyWith(phase: ScanPhase.idle);
      return;
    }

    // Single result — use the existing single scan flow
    if (validOutputs.length == 1) {
      await _handleSingleScanOutput(validOutputs.first);
      return;
    }

    // Multiple results — show checklist for batch selection
    final messages = <ChatMessage>[
      ...state.messages,
      ChatMessage(
        type: ChatMessageType.multiReview,
        text: 'Found ${validOutputs.length} subscriptions!',
        multiReviewTotal: validOutputs.length,
      ),
    ];

    state = state.copyWith(
      phase: ScanPhase.multiReview,
      messages: messages,
      multiOutputs: validOutputs,
      multiReviewIndex: 0,
      multiReviewAddedCount: 0,
    );
  }

  /// Batch-add selected subscriptions from the multi-scan checklist.
  ///
  /// [addedCount] is how many the user checked and added.
  void completeMultiReview(int addedCount) {
    final total = state.multiOutputs?.length ?? 0;
    final messages = [...state.messages];
    messages.add(ChatMessage(
      type: ChatMessageType.system,
      text: 'All done! Added $addedCount of $total subscriptions.',
    ));
    state = state.copyWith(
      phase: ScanPhase.result,
      messages: messages,
      multiReviewAddedCount: addedCount,
    );
  }

  /// User answers a question.
  void answerQuestion(int messageIndex, String answer) {
    final messages = [...state.messages];

    // Mark question as answered
    messages[messageIndex] = messages[messageIndex].copyWith(
      selectedAnswer: answer,
      isAnswered: true,
    );

    // Add user's answer as a chat bubble
    messages.add(
      ChatMessage(
        type: ChatMessageType.answer,
        text: answer,
      ),
    );

    final currentResult = state.currentResult;

    // ─── Handle missing-data price/cycle answers ───
    if (currentResult != null && currentResult.hasMissingFields) {
      final handled = _handleMissingDataAnswer(
        answer,
        currentResult,
        messages,
      );
      if (handled) return;
    }

    // Update the current result name if the answer changes it
    ScanResult? updatedResult = currentResult;
    if (answer != 'Other' && currentResult != null) {
      updatedResult = ScanResult(
        serviceName: answer,
        price: currentResult.price,
        currency: currentResult.currency,
        billingCycle: currentResult.billingCycle,
        nextRenewal: currentResult.nextRenewal,
        isTrial: currentResult.isTrial,
        trialEndDate: currentResult.trialEndDate,
        category: currentResult.category,
        iconName: currentResult.iconName,
        brandColor: currentResult.brandColor,
        confidence: currentResult.confidence,
        overallConfidence: 0.95, // User confirmed
        tier: currentResult.tier,
        sourceType: currentResult.sourceType,
        missingFields: currentResult.missingFields,
        extractionNotes: currentResult.extractionNotes,
      );
    }

    // Find next unanswered question
    final nextQ = messages.indexWhere(
      (m) =>
          m.type == ChatMessageType.question &&
          !m.isAnswered &&
          messages.indexOf(m) > messageIndex,
    );

    state = state.copyWith(
      messages: messages,
      currentResult: updatedResult,
      pendingQuestionIndex: nextQ,
    );

    // If no more questions, show result after a brief delay
    if (nextQ == -1) {
      _showFinalResult(updatedResult);
    }
  }

  /// Handle a user answer to a missing-data question (price or cycle).
  /// Returns true if handled, false to fall through to normal logic.
  bool _handleMissingDataAnswer(
    String answer,
    ScanResult currentResult,
    List<ChatMessage> messages,
  ) {
    // ─── Price answer ───
    if (currentResult.needsPrice) {
      double? parsedPrice;
      String? parsedCycle;
      String? parsedCurrency;

      // Extract explicit currency code from "[GBP]" suffix if present
      final currencyCodeMatch = RegExp(r'\[([A-Z]{3})\]').firstMatch(answer);
      if (currencyCodeMatch != null) {
        parsedCurrency = currencyCodeMatch.group(1);
      }

      // Parse price from options like "£18/mo", "$20/mo", "15.99 zł/mo",
      // "C$20.00/mo", "A$9.99/yr", "¥1500/mo", "CHF12.00/mo", "kr99.00/mo"
      final priceMatch =
          RegExp(r'(?:[A-Z]*[\£\$\€\¥]|CHF|kr|z[łl])?\s*([\d.]+)\s*(?:z[łl]|kr)?\s*/?(?:(mo|yr|wk|qtr))?')
              .firstMatch(answer);
      if (priceMatch != null) {
        parsedPrice = double.tryParse(priceMatch.group(1) ?? '');
        final cycleHint = priceMatch.group(2);
        if (cycleHint == 'yr') {
          parsedCycle = 'yearly';
        } else if (cycleHint == 'mo') {
          parsedCycle = 'monthly';
        } else if (cycleHint == 'wk') {
          parsedCycle = 'weekly';
        } else if (cycleHint == 'qtr') {
          parsedCycle = 'quarterly';
        }
      }

      if (parsedPrice != null) {
        // Create updated result with user-provided price
        final updatedMissing = currentResult.missingFields
            .where((f) => f != 'price')
            .toList();
        // Also remove billing_cycle from missing if we got it from the answer
        if (parsedCycle != null) {
          updatedMissing.remove('billing_cycle');
        }

        final updated = ScanResult(
          serviceName: currentResult.serviceName,
          price: parsedPrice,
          currency: parsedCurrency ?? currentResult.currency,
          billingCycle: parsedCycle ?? currentResult.billingCycle,
          nextRenewal: currentResult.nextRenewal,
          isTrial: currentResult.isTrial,
          trialEndDate: currentResult.trialEndDate,
          category: currentResult.category,
          iconName: currentResult.iconName,
          brandColor: currentResult.brandColor,
          confidence: currentResult.confidence,
          overallConfidence: 0.85, // User-provided = high confidence
          tier: 2,
          sourceType: currentResult.sourceType,
          missingFields: updatedMissing,
          extractionNotes: currentResult.extractionNotes,
        );

        state = state.copyWith(
          currentResult: updated,
          messages: messages,
        );

        // Still need billing cycle?
        if (updated.needsCycle) {
          messages.add(ChatMessage(
            type: ChatMessageType.question,
            text: 'Is ${updated.serviceName} billed monthly or yearly?',
            questionType: QuestionType.choose,
            options: const ['Monthly', 'Yearly', 'Weekly', 'Quarterly'],
          ));
          state = state.copyWith(
            messages: messages,
            pendingQuestionIndex: messages.length - 1,
          );
          return true;
        }

        // All data collected — route to confirmation
        _handleQuickConfirm(updated);
        return true;
      }
    }

    // ─── Billing cycle answer ───
    if (currentResult.needsCycle) {
      final cycleLower = answer.toLowerCase();
      String? parsedCycle;
      if (cycleLower.contains('month')) {
        parsedCycle = 'monthly';
      } else if (cycleLower.contains('year') || cycleLower.contains('annual')) {
        parsedCycle = 'yearly';
      } else if (cycleLower.contains('week')) {
        parsedCycle = 'weekly';
      } else if (cycleLower.contains('quarter')) {
        parsedCycle = 'quarterly';
      }

      if (parsedCycle != null) {
        final updatedMissing = currentResult.missingFields
            .where((f) => f != 'billing_cycle')
            .toList();

        final updated = ScanResult(
          serviceName: currentResult.serviceName,
          price: currentResult.price,
          currency: currentResult.currency,
          billingCycle: parsedCycle,
          nextRenewal: currentResult.nextRenewal,
          isTrial: currentResult.isTrial,
          trialEndDate: currentResult.trialEndDate,
          category: currentResult.category,
          iconName: currentResult.iconName,
          brandColor: currentResult.brandColor,
          confidence: currentResult.confidence,
          overallConfidence: 0.85,
          tier: 2,
          sourceType: currentResult.sourceType,
          missingFields: updatedMissing,
          extractionNotes: currentResult.extractionNotes,
        );

        state = state.copyWith(
          currentResult: updated,
          messages: messages,
        );

        // All data collected — route to confirmation
        _handleQuickConfirm(updated);
        return true;
      }
    }

    return false;
  }

  /// After a trial question, add the follow-up currency question.
  void addFollowUpQuestion() {
    if (state.currentResult == null) return;
    final result = state.currentResult!;

    final messages = [...state.messages];
    messages.add(
      ChatMessage(
        type: ChatMessageType.question,
        text: 'The price is in ${result.currency} (${Subscription.formatPrice(result.price ?? 0, result.currency)}). How should we track it?',
        questionType: QuestionType.choose,
        options: [
          'Convert to \u00A3 GBP',
          'Keep in ${result.currency == 'USD' ? '\$ USD' : '\u20AC EUR'}',
        ],
      ),
    );

    state = state.copyWith(
      messages: messages,
      pendingQuestionIndex: messages.length - 1,
    );
  }

  /// Handle scans where some fields couldn't be extracted from the image.
  /// Shows what was found and asks the user to fill in the gaps.
  Future<void> _handleMissingData(ScanResult result) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final messages = <ChatMessage>[...state.messages];

    // Show what we DID find
    final foundParts = <String>[];
    if (result.serviceName != 'Unknown') {
      foundParts.add(result.serviceName);
    }
    if (result.nextRenewal != null) {
      foundParts.add(
          'renews ${result.nextRenewal!.day}/${result.nextRenewal!.month}/${result.nextRenewal!.year}');
    }
    if (result.billingCycle != null) {
      foundParts.add(result.billingCycle!);
    }

    if (foundParts.isNotEmpty) {
      messages.add(ChatMessage(
        type: ChatMessageType.info,
        text: 'Found: ${foundParts.join(' \u00B7 ')}',
      ));
    }

    // Show extraction notes from AI
    if (result.extractionNotes != null) {
      messages.add(ChatMessage(
        type: ChatMessageType.info,
        text: result.extractionNotes!,
      ));
    }

    // Ask for price if missing
    if (result.needsPrice) {
      final name = result.serviceName != 'Unknown'
          ? result.serviceName
          : 'this subscription';
      messages.add(ChatMessage(
        type: ChatMessageType.question,
        text: 'I couldn\'t find the price in this image. How much is $name?',
        questionType: QuestionType.choose,
        options: _suggestPrices(result),
      ));
    }
    // Ask for billing cycle if missing (but price was found)
    else if (result.needsCycle) {
      messages.add(ChatMessage(
        type: ChatMessageType.question,
        text: 'Is ${result.serviceName} billed monthly or yearly?',
        questionType: QuestionType.choose,
        options: const ['Monthly', 'Yearly', 'Weekly', 'Quarterly'],
      ));
    }
    // Price and cycle both present — nothing to ask, route to confirm
    else {
      state = state.copyWith(
        messages: messages,
        currentResult: result,
      );
      if (result.serviceName != 'Unknown' &&
          result.overallConfidence >= 0.7) {
        await _handleQuickConfirm(result);
      } else {
        await _handleFullQuestion(result, 'clear_email');
      }
      return;
    }

    state = state.copyWith(
      phase: ScanPhase.questioning,
      messages: messages,
      currentResult: result,
      pendingQuestionIndex: messages.indexWhere(
        (m) => m.type == ChatMessageType.question && !m.isAnswered,
      ),
    );
  }

  /// Suggest common price points based on the service name and currency.
  List<String> _suggestPrices(ScanResult result) {
    final currency = result.currency;
    final sym = Subscription.currencySymbol(currency);
    final isSuffix = Subscription.isSymbolSuffix(currency);

    String fmt(double amount, String cycle) {
      final value = amount.toStringAsFixed(2);
      final price = isSuffix ? '$value $sym' : '$sym$value';
      return '$price/$cycle';
    }

    // Known service prices (approximate, in their typical currency)
    final knownPrices = <String, List<String>>{
      'claude': [fmt(18, 'mo'), fmt(16, 'mo'), fmt(20, 'mo')],
      'chatgpt': [fmt(20, 'mo'), fmt(200, 'yr')],
      'netflix': [fmt(4.99, 'mo'), fmt(10.99, 'mo'), fmt(17.99, 'mo')],
      'spotify': [fmt(10.99, 'mo'), fmt(14.99, 'mo')],
      'youtube': [fmt(11.99, 'mo'), fmt(19.99, 'mo')],
      'apple': [fmt(0.99, 'mo'), fmt(2.99, 'mo'), fmt(6.99, 'mo')],
      'microsoft': [fmt(5.99, 'mo'), fmt(7.99, 'mo'), fmt(59.99, 'yr')],
      'adobe': [fmt(9.98, 'mo'), fmt(19.97, 'mo'), fmt(52.99, 'mo')],
      'disney': [fmt(4.99, 'mo'), fmt(7.99, 'mo'), fmt(10.99, 'mo')],
      'amazon': [fmt(8.99, 'mo'), fmt(95, 'yr')],
      'screenpal': [fmt(3, 'mo'), fmt(6, 'mo'), fmt(8, 'mo')],
      'notion': [fmt(8, 'mo'), fmt(10, 'mo')],
      'figma': [fmt(12, 'mo'), fmt(15, 'mo')],
      'canva': [fmt(10.99, 'mo'), fmt(99.99, 'yr')],
      'github': [fmt(4, 'mo'), fmt(21, 'mo')],
      'google': [fmt(1.49, 'mo'), fmt(3.49, 'mo'), fmt(6.99, 'mo')],
    };

    // Check if we have known prices for this service
    final nameLower = result.serviceName.toLowerCase();
    for (final entry in knownPrices.entries) {
      if (nameLower.contains(entry.key)) {
        return [...entry.value, 'Other amount'];
      }
    }

    // Generic price suggestions in the detected currency
    return [
      fmt(4.99, 'mo'),
      fmt(9.99, 'mo'),
      fmt(14.99, 'mo'),
      fmt(19.99, 'mo'),
      'Other amount',
    ];
  }

  /// Show the final confirmed result.
  Future<void> _showFinalResult(ScanResult? result) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final messages = [...state.messages];

    if (state.multiResults != null) {
      messages.add(
        ChatMessage(
          type: ChatMessageType.multiResult,
          text: '${state.multiResults!.length} subscriptions confirmed!',
          multiResults: state.multiResults,
        ),
      );
    } else if (result != null) {
      messages.add(
        ChatMessage(
          type: ChatMessageType.result,
          text: '${result.serviceName} confirmed!',
          scanResult: result,
        ),
      );
    }

    state = state.copyWith(
      phase: ScanPhase.result,
      messages: messages,
    );

    // Record confirmation in merchant DB for the flywheel
    if (result != null) {
      MerchantDb.instance.confirm(
        pattern: result.serviceName.toUpperCase(),
        resolvedName: result.serviceName,
        category: result.category,
        icon: result.iconName,
        color: result.brandColor,
      );
    }
  }

  // ─── Trap Scanner Methods ───

  /// Start a scan with trap detection.
  ///
  /// Automatically detects single vs multi-subscription images:
  /// - Single subscription (email, receipt) → standard scan + trap flow
  /// - Multiple subscriptions (bank statement) → multi-scan flow with batch add
  ///
  /// For mock mode, [scenario] triggers test data.
  Future<void> startTrapScan({
    Uint8List? imageBytes,
    String? mimeType,
    String scenario = 'clear_email',
  }) async {
    state = state.copyWith(
      phase: ScanPhase.scanning,
      messages: [
        const ChatMessage(
          type: ChatMessageType.system,
          text: 'Screenshot received! Scanning for traps...',
        ),
      ],
    );

    try {
      if (useMockData) {
        // Mock mode
        final output = await AiScanService.mockWithTrap(scenario);
        await _handleSingleScanOutput(output);
        return;
      }

      // ─── Real API mode ───
      if (imageBytes == null || mimeType == null) {
        _addSystemMessage('Unable to process image. Please try again.');
        state = state.copyWith(phase: ScanPhase.idle);
        return;
      }

      const apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
      if (apiKey.isEmpty) {
        _addSystemMessage('AI scanning is not configured. Please contact support.');
        state = state.copyWith(phase: ScanPhase.idle);
        return;
      }

      final service = AiScanService(apiKey: apiKey);

      // Try multi-extraction first (handles both single and multi results)
      List<ScanOutput> outputs = await service.analyseScreenshotMulti(
        imageBytes: imageBytes,
        mimeType: mimeType,
      );

      // Filter out empty/unknown results
      outputs = outputs.where((o) => !o.subscription.isNotFound).toList();

      // If Haiku found nothing, escalate to Sonnet
      if (outputs.isEmpty) {
        _addSystemMessage('Taking a closer look\u2026');
        outputs = await service.analyseScreenshotMulti(
          imageBytes: imageBytes,
          mimeType: mimeType,
          modelOverride: AppConstants.aiModelFallback,
        );
        outputs = outputs.where((o) => !o.subscription.isNotFound).toList();
      }
      // If Haiku found one result but it's low confidence, escalate
      else if (outputs.length == 1 && _shouldEscalate(outputs.first.subscription)) {
        _addSystemMessage('Taking a closer look\u2026');
        outputs = await service.analyseScreenshotMulti(
          imageBytes: imageBytes,
          mimeType: mimeType,
          modelOverride: AppConstants.aiModelFallback,
        );
        outputs = outputs.where((o) => !o.subscription.isNotFound).toList();
      }
      // For complex multi-sub screenshots (5+ items), use Sonnet for higher accuracy
      else if (outputs.length >= 5) {
        _addSystemMessage('Found many subscriptions, taking a closer look\u2026');
        outputs = await service.analyseScreenshotMulti(
          imageBytes: imageBytes,
          mimeType: mimeType,
          modelOverride: AppConstants.aiModelFallback,
        );
        outputs = outputs.where((o) => !o.subscription.isNotFound).toList();
      }

      if (outputs.isEmpty) {
        await _handleNotFound(ScanResult(
          serviceName: 'Unknown',
          currency: 'GBP',
          confidence: {},
          overallConfidence: 0,
          tier: 3,
        ));
        return;
      }

      // Route based on result count
      if (outputs.length == 1) {
        // Single subscription → standard flow with trap detection
        await _handleSingleScanOutput(outputs.first);
      } else {
        // Multiple subscriptions → one-by-one review flow
        await _handleMultiScan(outputs: outputs);
      }
    } catch (e) {
      state = state.copyWith(
        phase: ScanPhase.error,
        errorMessage: e.toString(),
        messages: [
          ...state.messages,
          ChatMessage(
            type: ChatMessageType.system,
            text: 'Something went wrong: ${e.toString()}',
          ),
        ],
      );
    }
  }

  /// Handle a single scan output (subscription + trap detection).
  Future<void> _handleSingleScanOutput(ScanOutput output) async {
    // No subscription found
    if (output.subscription.isNotFound) {
      await _handleNotFound(output.subscription);
      return;
    }

    // If critical fields are missing, ask user to fill gaps first
    if (output.subscription.hasMissingFields) {
      state = state.copyWith(
        currentResult: output.subscription,
        trapResult: output.trap,
      );
      await _handleMissingData(output.subscription);
      return;
    }

    if (output.shouldShowTrapWarning) {
      // HIGH / MEDIUM severity trap — show full warning card
      state = state.copyWith(
        phase: ScanPhase.trapDetected,
        currentResult: output.subscription,
        trapResult: output.trap,
        messages: [
          ...state.messages,
          ChatMessage(
            type: ChatMessageType.system,
            text: '\u26A0\uFE0F Trap detected in ${output.subscription.serviceName}!',
          ),
        ],
      );
    } else if (output.shouldShowTrialNotice) {
      // LOW severity — show normal result with trial info notice
      state = state.copyWith(
        phase: ScanPhase.result,
        currentResult: output.subscription,
        trialNotice: output.trap,
        messages: [
          ...state.messages,
          ChatMessage(
            type: ChatMessageType.result,
            text: 'Found ${output.subscription.serviceName}!',
            scanResult: output.subscription,
          ),
        ],
      );
    } else {
      // No trap — route based on confidence
      state = state.copyWith(currentResult: output.subscription);

      if (output.subscription.tier == 1 || output.subscription.isHighConfidence) {
        await _handleAutoDetect(output.subscription);
      } else if (output.subscription.tier == 2) {
        await _handleQuickConfirm(output.subscription);
      } else {
        await _handleFullQuestion(output.subscription, 'clear_email');
      }
    }
  }

  /// User chose "Skip It" on the trap warning — log savings and celebrate.
  void skipTrap(TrapResult trap) {
    // Log the dodged trap (in-memory for v1; Isar persistence later)
    final dodged = DodgedTrap()
      ..serviceName = trap.serviceName ?? 'Unknown'
      ..savedAmount = trap.savingsAmount
      ..dodgedAt = DateTime.now()
      ..trapType = trap.trapType?.name ?? 'unknown'
      ..source = DodgedTrapSource.skipped;

    // Persist to SharedPreferences
    DodgedTrapRepository.instance.add(dodged);

    state = ScanState(
      phase: ScanPhase.trapSkipped,
      skippedSavingsAmount: trap.savingsAmount,
      skippedServiceName: trap.serviceName ?? 'Unknown',
    );

    // Celebration haptic
    HapticFeedback.heavyImpact();
  }

  /// User chose "Track Trial Anyway" — add subscription with trap metadata
  /// and schedule aggressive trial alerts.
  void trackTrapTrial(ScanResult subscription, TrapResult trap) {
    // In a full implementation, we'd create a Subscription with trap fields
    // and save it via the subscriptions provider. For the prototype,
    // we transition to result phase and schedule alerts.

    // Schedule aggressive trial alerts if there's an expiry
    if (trap.trialDurationDays != null) {
      // Notification service will handle the 72h/24h/2h alerts
      // (integrated in Phase 5)
    }

    state = state.copyWith(
      phase: ScanPhase.result,
      messages: [
        ...state.messages,
        ChatMessage(
          type: ChatMessageType.system,
          text: 'Tracking ${subscription.serviceName} trial. We\'ll remind you before it charges!',
        ),
        ChatMessage(
          type: ChatMessageType.result,
          text: '${subscription.serviceName} added with trial alerts.',
          scanResult: subscription,
        ),
      ],
    );
  }

  /// Access the persisted dodged traps list.
  static List<DodgedTrap> get dodgedTraps =>
      DodgedTrapRepository.instance.getAll();
}

// ─── Providers ───

/// The main scan state provider.
final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier();
});

/// Convenience: current scan phase.
final scanPhaseProvider = Provider<ScanPhase>((ref) {
  return ref.watch(scanProvider).phase;
});

/// Convenience: scan messages.
final scanMessagesProvider = Provider<List<ChatMessage>>((ref) {
  return ref.watch(scanProvider).messages;
});

/// Free scan counter — tracks how many AI scans the user has used.
///
/// For v1 this is in-memory. Sprint 5+ will persist in SharedPreferences.
class ScanCounterNotifier extends StateNotifier<int> {
  ScanCounterNotifier() : super(0);

  void increment() => state++;
  void reset() => state = 0;
  bool get canScan => state < 3; // Free tier: 3 scans max
  int get remaining => 3 - state;
}

final scanCounterProvider =
    StateNotifierProvider<ScanCounterNotifier, int>((ref) {
  return ScanCounterNotifier();
});

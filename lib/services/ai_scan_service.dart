import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/scan_result.dart';
import '../models/trap_result.dart';
import '../models/scan_output.dart';

/// In debug builds, use mock data. In release, use real API.
/// Override with --dart-define=USE_MOCK=true to force mock in release.
const _forceMock = bool.fromEnvironment('USE_MOCK');
final useMockData = _forceMock || kDebugMode;

/// Claude Haiku integration for screenshot scanning.
///
/// Takes a screenshot image (bytes), sends it to Claude Haiku
/// with a structured extraction prompt, and returns a [ScanResult]
/// or [ScanOutput] (subscription + trap detection).
///
/// For v1 the API key is bundled in the app (move to proxy at scale).
class AiScanService {
  AiScanService({required this.apiKey});

  final String apiKey;

  static const _baseUrl = 'https://api.anthropic.com/v1/messages';

  /// Analyse a screenshot and extract subscription + trap details.
  ///
  /// [imageBytes] — the raw screenshot PNG/JPEG bytes.
  /// [mimeType]   — 'image/png' or 'image/jpeg'.
  ///
  /// Returns a [ScanOutput] with both subscription and trap data.
  /// Throws on network or parse errors.
  Future<ScanOutput> analyseScreenshotWithTrap({
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    final base64Image = base64Encode(imageBytes);

    final body = jsonEncode({
      'model': AppConstants.aiModel,
      'max_tokens': 4096,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': mimeType,
                'data': base64Image,
              },
            },
            {
              'type': 'text',
              'text': _extractionPrompt,
            },
          ],
        },
      ],
    });

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception(
        'Claude API error ${response.statusCode}: ${response.body}',
      );
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final content = responseJson['content'] as List<dynamic>;
    final textBlock = content.firstWhere(
      (block) => block['type'] == 'text',
      orElse: () => throw Exception('No text block in Claude response'),
    );
    final rawText = textBlock['text'] as String;

    // Claude may wrap JSON in markdown fences — strip them
    final cleanedJson = rawText
        .replaceAll(RegExp(r'^```json?\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^```\s*$', multiLine: true), '')
        .trim();

    final parsed = jsonDecode(cleanedJson) as Map<String, dynamic>;
    return ScanOutput.fromJson(parsed);
  }

  /// Convenience: analyse screenshot and return just subscription data.
  Future<ScanResult> analyseScreenshot({
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    final output = await analyseScreenshotWithTrap(
      imageBytes: imageBytes,
      mimeType: mimeType,
    );
    return output.subscription;
  }

  /// Mock analysis for prototyping — simulates Claude response.
  ///
  /// [scenario] matches the 5 test scenarios from the design prototype:
  /// - 'clear_email'   — Netflix, Tier 1, auto-detect
  /// - 'learned_match' — Kindle Unlimited, Tier 2, quick-confirm
  /// - 'ambiguous'     — Microsoft service, Tier 3, full question
  /// - 'trial'         — Figma Pro trial, Tier 3, 2 questions
  /// - 'multi'         — Bank statement with 4 charges
  static Future<ScanResult> mock(String scenario) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 1100));

    switch (scenario) {
      case 'clear_email':
        return ScanResult(
          serviceName: 'Netflix',
          price: 15.99,
          currency: 'GBP',
          billingCycle: 'monthly',
          nextRenewal: DateTime.now().add(const Duration(days: 28)),
          category: 'Entertainment',
          iconName: 'N',
          brandColor: '#E50914',
          confidence: {
            'name': 0.99,
            'price': 0.98,
            'cycle': 0.99,
            'currency': 0.99,
          },
          overallConfidence: 0.98,
          tier: 1,
          sourceType: 'email',
        );

      case 'learned_match':
        return ScanResult(
          serviceName: 'Kindle Unlimited',
          price: 7.99,
          currency: 'GBP',
          billingCycle: 'monthly',
          category: 'Entertainment',
          iconName: 'K',
          brandColor: '#FF9900',
          confidence: {
            'name': 0.78,
            'price': 0.95,
            'cycle': 0.90,
            'currency': 0.99,
          },
          overallConfidence: 0.82,
          tier: 2,
          sourceType: 'bank_statement',
        );

      case 'ambiguous':
        return ScanResult(
          serviceName: 'Microsoft Service',
          price: 10.99,
          currency: 'GBP',
          billingCycle: 'monthly',
          category: 'Gaming',
          iconName: 'M',
          brandColor: '#00A4EF',
          confidence: {
            'name': 0.45,
            'price': 0.92,
            'cycle': 0.88,
            'currency': 0.95,
          },
          overallConfidence: 0.55,
          tier: 3,
          sourceType: 'bank_statement',
        );

      case 'trial':
        return ScanResult(
          serviceName: 'Figma Pro',
          price: 9.99,
          currency: 'USD',
          billingCycle: 'monthly',
          isTrial: true,
          trialEndDate: DateTime.now().add(const Duration(days: 14)),
          category: 'Design',
          iconName: 'F',
          brandColor: '#A259FF',
          confidence: {
            'name': 0.88,
            'price': 0.92,
            'cycle': 0.85,
            'currency': 0.95,
            'trial': 0.90,
          },
          overallConfidence: 0.88,
          tier: 3,
          sourceType: 'email',
        );

      case 'multi':
        // For multi-sub, return just the first detected one.
        // The scan screen handles multi-sub by running multiple results.
        return ScanResult(
          serviceName: 'Spotify',
          price: 10.99,
          currency: 'GBP',
          billingCycle: 'monthly',
          category: 'Music',
          iconName: 'S',
          brandColor: '#1DB954',
          confidence: {
            'name': 0.99,
            'price': 0.99,
            'cycle': 0.99,
            'currency': 0.99,
          },
          overallConfidence: 0.99,
          tier: 1,
          sourceType: 'bank_statement',
        );

      default:
        throw ArgumentError('Unknown scenario: $scenario');
    }
  }

  /// Mock multi-sub results for the bank statement scenario.
  static Future<List<ScanResult>> mockMulti() async {
    await Future.delayed(const Duration(milliseconds: 1800));

    return [
      ScanResult(
        serviceName: 'Spotify',
        price: 10.99,
        currency: 'GBP',
        billingCycle: 'monthly',
        category: 'Music',
        iconName: 'S',
        brandColor: '#1DB954',
        confidence: {
          'name': 0.99,
          'price': 0.99,
          'cycle': 0.99,
          'currency': 0.99,
        },
        overallConfidence: 0.99,
        tier: 1,
        sourceType: 'bank_statement',
      ),
      ScanResult(
        serviceName: 'Zwift',
        price: 17.99,
        currency: 'GBP',
        billingCycle: 'monthly',
        category: 'Fitness',
        iconName: 'Z',
        brandColor: '#FC6719',
        confidence: {
          'name': 0.97,
          'price': 0.99,
          'cycle': 0.95,
          'currency': 0.99,
        },
        overallConfidence: 0.97,
        tier: 1,
        sourceType: 'bank_statement',
      ),
      ScanResult(
        serviceName: 'Google Service',
        price: 1.99,
        currency: 'GBP',
        billingCycle: 'monthly',
        category: 'Productivity',
        iconName: 'G',
        brandColor: '#4285F4',
        confidence: {
          'name': 0.30,
          'price': 0.95,
          'cycle': 0.80,
          'currency': 0.99,
        },
        overallConfidence: 0.30,
        tier: 3,
        sourceType: 'bank_statement',
      ),
      ScanResult(
        serviceName: 'Headspace',
        price: 9.99,
        currency: 'GBP',
        billingCycle: 'monthly',
        category: 'Health',
        iconName: 'H',
        brandColor: '#F47D31',
        confidence: {
          'name': 0.72,
          'price': 0.95,
          'cycle': 0.88,
          'currency': 0.99,
        },
        overallConfidence: 0.72,
        tier: 2,
        sourceType: 'bank_statement',
      ),
    ];
  }

  // ─── Trap Detection Mock Scenarios ───

  /// Mock scan with trap detection for prototyping.
  ///
  /// [scenario] controls what kind of trap (if any) is returned:
  /// - 'trap_trial_bait'   — £1 trial → £99.99/year (HIGH severity)
  /// - 'trap_price_framing' — "£1.92/week" hiding £99.99/year (HIGH)
  /// - 'trap_hidden_renewal' — free trial with buried auto-renewal (MEDIUM)
  /// - 'trap_safe_trial'   — Netflix free month (LOW — info notice only)
  /// - 'clear_email'       — no trap detected (normal flow)
  static Future<ScanOutput> mockWithTrap(String scenario) async {
    await Future.delayed(const Duration(milliseconds: 1100));

    switch (scenario) {
      case 'trap_trial_bait':
        return ScanOutput(
          subscription: ScanResult(
            serviceName: 'StarGaze Premium',
            price: 1.00,
            currency: 'GBP',
            billingCycle: 'yearly',
            isTrial: true,
            trialEndDate: DateTime.now().add(const Duration(days: 3)),
            category: 'Entertainment',
            iconName: 'S',
            brandColor: '#6B21A8',
            confidence: {'name': 0.95, 'price': 0.99, 'cycle': 0.92, 'currency': 0.99},
            overallConfidence: 0.96,
            tier: 1,
            sourceType: 'app_store',
          ),
          trap: const TrapResult(
            isTrap: true,
            trapType: TrapType.trialBait,
            severity: TrapSeverity.high,
            trialPrice: 1.00,
            trialDurationDays: 3,
            realPrice: 99.99,
            realBillingCycle: 'yearly',
            realAnnualCost: 100.99,
            confidence: 95,
            warningMessage: 'This app charges £1 for a 3-day trial, then auto-renews at £99.99/year. The real cost is hidden behind the trial button.',
            serviceName: 'StarGaze Premium',
          ),
        );

      case 'trap_price_framing':
        return ScanOutput(
          subscription: ScanResult(
            serviceName: 'FitCoach Pro',
            price: 1.92,
            currency: 'GBP',
            billingCycle: 'weekly',
            category: 'Fitness',
            iconName: 'F',
            brandColor: '#DC2626',
            confidence: {'name': 0.92, 'price': 0.98, 'cycle': 0.90, 'currency': 0.99},
            overallConfidence: 0.94,
            tier: 1,
            sourceType: 'app_store',
          ),
          trap: const TrapResult(
            isTrap: true,
            trapType: TrapType.priceFraming,
            severity: TrapSeverity.high,
            trialPrice: null,
            trialDurationDays: null,
            realPrice: 99.99,
            realBillingCycle: 'yearly',
            realAnnualCost: 99.99,
            confidence: 92,
            warningMessage: 'This app displays the price as "just £1.92/week" but charges £99.99 annually upfront. The weekly framing makes it look 52x cheaper than it is.',
            serviceName: 'FitCoach Pro',
          ),
        );

      case 'trap_hidden_renewal':
        return ScanOutput(
          subscription: ScanResult(
            serviceName: 'MindClear Meditation',
            price: 0.00,
            currency: 'GBP',
            billingCycle: 'monthly',
            isTrial: true,
            trialEndDate: DateTime.now().add(const Duration(days: 7)),
            category: 'Health',
            iconName: 'M',
            brandColor: '#059669',
            confidence: {'name': 0.90, 'price': 0.95, 'cycle': 0.85, 'currency': 0.99},
            overallConfidence: 0.91,
            tier: 2,
            sourceType: 'app_store',
          ),
          trap: const TrapResult(
            isTrap: true,
            trapType: TrapType.hiddenRenewal,
            severity: TrapSeverity.medium,
            trialPrice: 0.00,
            trialDurationDays: 7,
            realPrice: 9.99,
            realBillingCycle: 'monthly',
            realAnnualCost: 119.88,
            confidence: 85,
            warningMessage: 'This "free" trial auto-renews at £9.99/month after 7 days. The auto-renewal terms are buried in small print.',
            serviceName: 'MindClear Meditation',
          ),
        );

      case 'trap_safe_trial':
        return ScanOutput(
          subscription: ScanResult(
            serviceName: 'Netflix',
            price: 15.99,
            currency: 'GBP',
            billingCycle: 'monthly',
            isTrial: true,
            trialEndDate: DateTime.now().add(const Duration(days: 30)),
            category: 'Entertainment',
            iconName: 'N',
            brandColor: '#E50914',
            confidence: {'name': 0.99, 'price': 0.99, 'cycle': 0.99, 'currency': 0.99},
            overallConfidence: 0.99,
            tier: 1,
            sourceType: 'email',
          ),
          trap: const TrapResult(
            isTrap: true,
            trapType: TrapType.trialBait,
            severity: TrapSeverity.low,
            trialPrice: 0.00,
            trialDurationDays: 30,
            realPrice: 15.99,
            realBillingCycle: 'monthly',
            realAnnualCost: 191.88,
            confidence: 80,
            warningMessage: 'Standard free month trial. After 30 days it auto-renews at £15.99/month.',
            serviceName: 'Netflix',
          ),
        );

      default:
        // No trap — normal subscription (e.g. 'clear_email')
        final sub = await mock(scenario);
        return ScanOutput(subscription: sub, trap: TrapResult.clean);
    }
  }

  /// The structured extraction prompt sent to Claude Haiku.
  ///
  /// Includes both subscription extraction (Task 1) and
  /// trap detection (Task 2) in a single API call.
  static const _extractionPrompt = '''
Analyse this screenshot of a subscription confirmation, bank statement, or app store receipt.

TASK 1 — SUBSCRIPTION EXTRACTION:
Extract these details:
- service_name: actual product name (e.g. "Netflix", not "NETFLIX.COM")
- price: numeric only, no currency symbol
- currency: ISO 4217 (GBP, USD, EUR)
- billing_cycle: "weekly" | "monthly" | "quarterly" | "yearly"
- next_renewal: ISO date string, or null
- is_trial: boolean
- trial_end_date: ISO date string when trial ends, or null
- category: one of "Entertainment", "Music", "Design", "Fitness", "Productivity", "Storage", "News", "Gaming", "Finance", "Education", "Health", "Other"
- icon: first letter or short identifier (1-2 chars)
- brand_color: hex colour code
- source_type: "email" | "bank_statement" | "app_store" | "receipt"
- confidence: per-field 0.0-1.0
- overall_confidence: average
- tier: 1 (certain), 2 (likely), 3 (uncertain)

TASK 2 — TRAP DETECTION:
Also analyse for subscription dark patterns:
1. Trial periods — what is the trial length? What happens after?
2. Auto-renewal terms — is there automatic billing after the trial?
3. Real price — what will the user actually pay per year after any intro period?
4. Price framing tricks — is an annual price disguised as weekly/daily to look smaller?
5. Hidden terms — any fine print about recurring charges not prominently displayed?

RESPOND WITH VALID JSON ONLY (no markdown, no backticks):
{
  "subscription": {
    "service_name": "string",
    "price": number,
    "currency": "string",
    "billing_cycle": "string",
    "next_renewal": "string or null",
    "is_trial": boolean,
    "trial_end_date": "string or null",
    "category": "string",
    "icon": "string",
    "brand_color": "string",
    "source_type": "string",
    "confidence": { "name": 0.0, "price": 0.0, "cycle": 0.0, "currency": 0.0 },
    "overall_confidence": 0.0,
    "tier": 1
  },
  "trap": {
    "is_trap": boolean,
    "trap_type": "trial_bait" | "price_framing" | "hidden_renewal" | "cancel_friction" | null,
    "severity": "low" | "medium" | "high",
    "trial_price": number or null,
    "trial_duration_days": number or null,
    "real_price": number or null,
    "billing_cycle": "weekly" | "monthly" | "yearly" | null,
    "real_annual_cost": number or null,
    "confidence": number (0-100),
    "warning_message": "plain English, max 2 sentences",
    "service_name": "string"
  }
}

SEVERITY GUIDE:
- "low": Standard trial with reasonable auto-renewal. User likely knows what they're getting.
- "medium": Intro price that significantly increases. The jump is notable but not extreme.
- "high": Extreme price jump OR deceptive framing. Designed to mislead.

If no subscription or trap is detected, return is_trap: false and confidence: 0 in the trap object.
If multiple subscriptions are visible, return a JSON array of subscription objects (trap applies to the primary one).
Return ONLY valid JSON, no markdown, no explanation.
''';
}

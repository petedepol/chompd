import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/scan_result.dart';
import '../models/trap_result.dart';
import '../models/scan_output.dart';

/// Use real API when ANTHROPIC_API_KEY is provided, mock data otherwise.
/// Override with --dart-define=USE_MOCK=true to force mock even with a key.
const _forceMock = bool.fromEnvironment('USE_MOCK');
const _hasApiKey = String.fromEnvironment('ANTHROPIC_API_KEY') != '';
final useMockData = _forceMock || !_hasApiKey;

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
    String? modelOverride,
  }) async {
    final base64Image = base64Encode(imageBytes);

    final body = jsonEncode({
      'model': modelOverride ?? AppConstants.aiModel,
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
        .timeout(Duration(seconds: modelOverride != null ? 60 : 30));

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

    final decoded = jsonDecode(cleanedJson);

    // Claude may return a JSON array when it detects multiple subscriptions
    // (e.g. bank statements). Handle both single object and array responses.
    final Map<String, dynamic> parsed;
    if (decoded is List) {
      if (decoded.isEmpty) {
        throw Exception('Claude returned an empty array');
      }
      parsed = decoded.first as Map<String, dynamic>;
    } else {
      parsed = decoded as Map<String, dynamic>;
    }

    return ScanOutput.fromJson(parsed);
  }

  /// Analyse a screenshot and extract ALL subscription + trap details.
  ///
  /// Returns a list of [ScanOutput] when multiple subscriptions are found
  /// (e.g. bank statements). Returns a single-item list for single results.
  Future<List<ScanOutput>> analyseScreenshotMulti({
    required Uint8List imageBytes,
    required String mimeType,
    String? modelOverride,
  }) async {
    final base64Image = base64Encode(imageBytes);

    final body = jsonEncode({
      'model': modelOverride ?? AppConstants.aiModel,
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
              'text': _multiExtractionPrompt,
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
        .timeout(Duration(seconds: modelOverride != null ? 60 : 30));

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

    final cleanedJson = rawText
        .replaceAll(RegExp(r'^```json?\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^```\s*$', multiLine: true), '')
        .trim();

    final decoded = jsonDecode(cleanedJson);

    if (decoded is List) {
      return decoded
          .where((item) => item is Map<String, dynamic>)
          .map((item) => ScanOutput.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (decoded is Map<String, dynamic>) {
      return [ScanOutput.fromJson(decoded)];
    } else {
      throw Exception('Unexpected AI response format');
    }
  }

  /// Convenience: analyse screenshot and return just subscription data.
  Future<ScanResult> analyseScreenshot({
    required Uint8List imageBytes,
    required String mimeType,
    String? modelOverride,
  }) async {
    final output = await analyseScreenshotWithTrap(
      imageBytes: imageBytes,
      mimeType: mimeType,
      modelOverride: modelOverride,
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
Analyse this image carefully. It may be:
- A subscription confirmation email
- A bank/card transaction list or statement
- An app store receipt or billing page
- A payment confirmation screen
- Any screen showing subscription or recurring payment info

TASK 1 — SUBSCRIPTION EXTRACTION:
Find any subscription or recurring payment services and extract:
- service_name: the actual product/service name (e.g. "Netflix", "ScreenPal", "Claude Pro")
- price: numeric only, no currency symbol. If price is NOT visible, set to null.
- currency: ISO 4217 code (GBP, USD, EUR, PLN, etc). Infer from symbols, language, or context.
- billing_cycle: "weekly" | "monthly" | "quarterly" | "yearly". Infer from context if not explicit.
- next_renewal: ISO date string if visible, or null
- is_trial: boolean
- trial_end_date: ISO date string, or null
- category: one of "Entertainment", "Music", "Design", "Fitness", "Productivity", "Storage", "News", "Gaming", "Finance", "Education", "Health", "Other"
- icon: first letter or short identifier (1-2 chars)
- brand_color: hex colour code for the brand
- source_type: "email" | "bank_statement" | "app_store" | "receipt" | "billing_page" | "other"

HOW TO READ BANK STATEMENTS:
Bank and card transaction lists require extra attention:
- Look for software/app/service names INSIDE transaction descriptions
- Card payments often show: "VISA/MASTERCARD [card number] [amount] [currency] [merchant name]"
- Foreign currency conversions (e.g. "8.00 USD 1 USD=3.69 PLN") strongly suggest online/digital subscriptions
- The service name may appear at the END of a long transaction line, sometimes truncated
- Polish bank format: "DOP. VISA ... PŁATNOŚĆ KARTĄ [amount] [currency] [service name]"
- UK bank format: "CARD PAYMENT TO [service name]" or "[service name] [reference]"
- Common subscription merchants to look for: Netflix, Spotify, YouTube, Apple, Google, Adobe, Microsoft, Amazon, Disney+, ChatGPT, Claude, Notion, Figma, Canva, ScreenPal, GitHub, Dropbox, iCloud, HBO, Hulu, Paramount+
- Ignore one-off purchases (groceries, shops, restaurants, transfers)
- If a transaction has a foreign currency conversion AND matches a known digital service, it is very likely a subscription

HOW TO READ iOS SUBSCRIPTIONS SCREEN (Settings → Subscriptions):
- "Expires on [date]" = trial or intro offer that will AUTO-RENEW at full price after that date
  → set is_trial: true, trial_end_date: that date
  → if no price is shown alongside "Expires on": flag is_trap: true, trap_type: "trial_bait",
    severity: "medium", warning_message: "[Service] trial expires on [date] and will auto-renew at an unknown price. Cancel before then if you don't want to be charged."
- "Renews [date]" WITH a visible price = active paid subscription (NOT a trial)
- "(7 Day Trial)" or similar text in the plan name = trial period
  → flag is_trap: true, trap_type: "trial_bait"

DATE INFERENCE:
- When a date has NO year (e.g. "18 April", "14 February"), assume the NEXT future occurrence from today's date.
  Example: if today is February 2026 and the image says "Expires on 18 April", that means 18 April 2026, NOT 2024.
- If a date with no year would be in the past for the current year, roll forward to next year.
- Always return ISO format: "2026-04-18"

IMPORTANT RULES:
1. If a field is NOT visible in the image, set it to null. Do NOT guess or default to 0.
2. For service_name: use the real product name. "Claude Pro" not "Anthropic". "ScreenPal" not "PayPro S.A."
3. For billing_cycle: if the image says "next charge" with a date, calculate the cycle. If not explicit, infer "monthly" for most digital services.
4. If you find a service name but not a price, still return the service with price as null — do NOT return "Unknown".
5. If you genuinely cannot find ANY subscription or recurring service in the image, return service_name as "Unknown" with overall_confidence 0.0.
6. Set confidence per field: 1.0 if clearly visible, 0.5 if inferred, 0.0 if not found.

ALSO INCLUDE:
- missing_fields: array of field names that could not be found (e.g. ["price", "billing_cycle"])
- extraction_notes: brief explanation of what you found and what's missing (max 2 sentences)

TASK 2 — TRAP DETECTION:
Analyse for subscription dark patterns:
1. Trial periods — what is the trial length? What happens after?
2. Auto-renewal terms — is there automatic billing?
3. Real price — what will the user actually pay per year after any intro period?
4. Price framing tricks — is an annual price disguised as weekly/daily?
5. Hidden terms — any fine print about recurring charges?

RESPOND WITH VALID JSON ONLY (no markdown, no backticks):
{
  "subscription": {
    "service_name": "string",
    "price": number or null,
    "currency": "string",
    "billing_cycle": "string or null",
    "next_renewal": "string or null",
    "is_trial": boolean,
    "trial_end_date": "string or null",
    "category": "string",
    "icon": "string",
    "brand_color": "string",
    "source_type": "string",
    "confidence": { "name": 0.0, "price": 0.0, "cycle": 0.0, "currency": 0.0 },
    "overall_confidence": 0.0,
    "tier": 1,
    "missing_fields": ["string"],
    "extraction_notes": "string"
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
- "low": Standard subscription with clear terms.
- "medium": Intro price that significantly increases. Notable but not extreme.
- "high": Extreme price jump OR deceptive framing. Designed to mislead.

If no subscription is detected at all, return service_name "Unknown" with overall_confidence 0.
If multiple subscriptions are visible, return the most prominent one only.
Return ONLY valid JSON, no markdown, no explanation.
''';

  /// Prompt for multi-subscription extraction (bank statements, billing pages).
  ///
  /// Returns a JSON array of subscription+trap objects.
  static const _multiExtractionPrompt = '''
Analyse this image carefully. It is likely a bank statement, card transaction list, or billing page with MULTIPLE subscriptions.

For EACH recurring subscription or digital service charge you find, extract:
- service_name: the actual product/service name (e.g. "Netflix", "ScreenPal", "Claude Pro")
- price: numeric only, no currency symbol. If price is NOT visible, set to null.
- currency: ISO 4217 code (GBP, USD, EUR, PLN, etc). Infer from symbols, language, or context.
- billing_cycle: "weekly" | "monthly" | "quarterly" | "yearly". Infer from context if not explicit.
- next_renewal: ISO date string if visible, or null
- is_trial: boolean
- trial_end_date: ISO date string, or null
- category: one of "Entertainment", "Music", "Design", "Fitness", "Productivity", "Storage", "News", "Gaming", "Finance", "Education", "Health", "Other"
- icon: first letter or short identifier (1-2 chars)
- brand_color: hex colour code for the brand
- source_type: "email" | "bank_statement" | "app_store" | "receipt" | "billing_page" | "other"
- confidence: per-field scores (0.0-1.0)
- overall_confidence: average confidence (0.0-1.0)
- tier: 1 (auto-detect), 2 (likely match), or 3 (uncertain)
- missing_fields: array of field names not found
- extraction_notes: brief explanation (max 1 sentence per subscription)

HOW TO READ BANK STATEMENTS:
- Look for software/app/service names INSIDE transaction descriptions
- Card payments often show: "VISA/MASTERCARD [card number] [amount] [currency] [merchant name]"
- Foreign currency conversions strongly suggest online/digital subscriptions
- Polish bank format: "DOP. VISA ... PŁATNOŚĆ KARTĄ [amount] [currency] [service name]"
- UK bank format: "CARD PAYMENT TO [service name]"
- Common subscription merchants: Netflix, Spotify, YouTube, Apple, Google, Adobe, Microsoft, Amazon, Disney+, ChatGPT, Claude, Notion, Figma, Canva, ScreenPal, GitHub, Dropbox, iCloud, HBO, Hulu, Paramount+
- IGNORE one-off purchases (groceries, shops, restaurants, transfers, physical stores)

HOW TO READ iOS SUBSCRIPTIONS SCREEN (Settings → Subscriptions):
- "Expires on [date]" = trial or intro offer that will AUTO-RENEW at full price after that date
  → set is_trial: true, trial_end_date: that date
  → if no price is shown alongside "Expires on": flag is_trap: true, trap_type: "trial_bait",
    severity: "medium", warning_message: "[Service] trial expires on [date] and will auto-renew at an unknown price. Cancel before then if you don't want to be charged."
- "Renews [date]" WITH a visible price = active paid subscription (NOT a trial)
- "(7 Day Trial)" or similar text in the plan name = trial period
  → flag is_trap: true, trap_type: "trial_bait"

DATE INFERENCE:
- When a date has NO year (e.g. "18 April", "14 February"), assume the NEXT future occurrence from today's date.
  Example: if today is February 2026 and the image says "Expires on 18 April", that means 18 April 2026, NOT 2024.
- If a date with no year would be in the past for the current year, roll forward to next year.
- Always return ISO format: "2026-04-18"

IMPORTANT RULES:
1. If a field is NOT visible in the image, set it to null. Do NOT guess or default to 0.
2. For service_name: use the real product name. "Claude Pro" not "Anthropic".
3. Only include charges that are CLEARLY recurring subscriptions or digital services.
4. Set confidence per field: 1.0 if clearly visible, 0.5 if inferred, 0.0 if not found.

TRAP DETECTION — For each subscription, check these patterns:
- trial_bait: Trial/intro price that auto-converts to a higher price. Flag when:
  • "Expires on" date visible without a clear renewal price → user doesn't know what they'll pay
  • Explicit "Trial" / "Free Trial" in plan name or description
  • Intro price (e.g. £1) much lower than typical market price for that service
- price_framing: Price shown in a misleading way (e.g. daily cost to hide monthly total)
- hidden_renewal: Auto-renewal terms buried or not clearly stated

Severity guide:
- "high": Price jump >5x OR renewal price is completely hidden/unknown
- "medium": Price increase 2-5x, or trial with unclear renewal terms
- "low": Standard trial with visible and reasonable renewal price

Set is_trap: true when ANY of these patterns are detected.
ALWAYS set warning_message to a clear, direct sentence when is_trap is true, like:
"This £1 trial auto-renews at £99.99/year in 3 days — cancel before then to avoid being charged."

RESPOND WITH A JSON ARRAY (no markdown, no backticks):
[
  {
    "subscription": { ... },
    "trap": {
      "is_trap": false,
      "trap_type": null,
      "severity": "low",
      "trial_price": null,
      "trial_duration_days": null,
      "real_price": null,
      "billing_cycle": null,
      "real_annual_cost": null,
      "confidence": 0,
      "warning_message": null,
      "service_name": "string"
    }
  },
  ...
]

If NO subscriptions are found, return a single-item array with service_name "Unknown" and overall_confidence 0.
Return ONLY valid JSON array, no markdown, no explanation.
''';
}

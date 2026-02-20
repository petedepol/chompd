import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/constants.dart';
import '../models/scan_result.dart';
import '../models/trap_result.dart';
import '../models/scan_output.dart';
import 'error_logger.dart';

/// Use real API when ANTHROPIC_API_KEY or SUPABASE_URL is provided.
/// Override with --dart-define=USE_MOCK=true to force mock.
const _forceMock = bool.fromEnvironment('USE_MOCK');
const _apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
const _hasApiKey = _apiKey != '';
const _hasSupabase = String.fromEnvironment('SUPABASE_URL') != '';
/// Whether to use Edge Function (only if explicitly enabled AND deployed).
/// Default: false — direct API is the primary path for dev.
const _useEdgeFn = bool.fromEnvironment('USE_EDGE_FUNCTION');
final useMockData = _forceMock || (!_hasApiKey && !_hasSupabase);

/// Thrown when the free scan limit is reached (server returns 429).
class ScanLimitReachedException implements Exception {
  final int limit;
  ScanLimitReachedException(this.limit);

  @override
  String toString() => 'Free scan limit reached ($limit scans)';
}

/// Thrown when the device has no internet connection or the request timed out.
class NoConnectionException implements Exception {
  final String? reason;
  NoConnectionException([this.reason]);

  @override
  String toString() => reason ?? 'No internet connection';
}

/// Thrown when the API returns 429 (rate limit / too many requests).
class ApiLimitException implements Exception {
  @override
  String toString() => 'API rate limit reached';
}

/// Thrown when the API returns a server error (500, 502, 503).
class ApiUnavailableException implements Exception {
  final int statusCode;
  ApiUnavailableException(this.statusCode);

  @override
  String toString() => 'API temporarily unavailable (HTTP $statusCode)';
}

/// Claude Haiku integration for screenshot scanning.
///
/// Routes requests through a Supabase Edge Function ('ai-scan')
/// when Supabase is configured. Falls back to direct Anthropic API
/// when only ANTHROPIC_API_KEY is provided (dev mode).
class AiScanService {
  AiScanService();

  static const _directBaseUrl = 'https://api.anthropic.com/v1/messages';

  /// Whether to route through Edge Function (opt-in via --dart-define=USE_EDGE_FUNCTION=true).
  bool get _useEdgeFunction => _useEdgeFn && _hasSupabase;

  /// Call the AI API via Edge Function or direct fallback.
  ///
  /// Prefers Supabase Edge Function when configured. Falls back to direct
  /// Anthropic API if the Edge Function is unavailable (not deployed, etc.)
  /// and a local ANTHROPIC_API_KEY is provided.
  Future<Map<String, dynamic>> _callApi(Map<String, dynamic> body) async {
    if (_useEdgeFunction) {
      try {
        return await _callViaEdgeFunction(body);
      } on ScanLimitReachedException {
        rethrow; // Don't fall back for intentional limit
      } on NoConnectionException {
        rethrow; // Don't fall back — no network means no network
      } on ApiLimitException {
        rethrow; // Don't fall back — rate limited everywhere
      } on ApiUnavailableException {
        rethrow; // Don't fall back — server-side issue
      } catch (e, st) {
        // Edge Function not deployed or erroring — try direct if key available
        ErrorLogger.log(event: 'ai_api_error', detail: 'Edge Function fallback: $e', stackTrace: st.toString());
        if (_hasApiKey) {
          return _callDirectApi(body);
        }
        rethrow;
      }
    }
    return _callDirectApi(body);
  }

  /// Call via Supabase Edge Function (production path).
  Future<Map<String, dynamic>> _callViaEdgeFunction(
      Map<String, dynamic> body) async {
    final client = Supabase.instance.client;
    final response = await client.functions.invoke(
      'ai-scan',
      body: body,
    );

    if (response.status == 429) {
      final data = response.data as Map<String, dynamic>? ?? {};
      throw ScanLimitReachedException(data['limit'] as int? ?? 5);
    }

    if (response.status != 200) {
      throw Exception('Edge Function error ${response.status}: ${response.data}');
    }

    return response.data as Map<String, dynamic>;
  }

  /// Direct Anthropic API call (dev fallback).
  Future<Map<String, dynamic>> _callDirectApi(
      Map<String, dynamic> body) async {
    if (!_hasApiKey) {
      throw Exception('No API key configured — pass --dart-define=ANTHROPIC_API_KEY=sk-...');
    }
    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_directBaseUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': _apiKey,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode(body),
          )
          .timeout(Duration(
              seconds: (body['model'] as String?)?.contains('sonnet') == true
                  ? 90
                  : 60));
    } on SocketException catch (e) {
      throw NoConnectionException('No internet connection: $e');
    } on TimeoutException {
      throw NoConnectionException('Request timed out — check your connection');
    } on HttpException catch (e) {
      throw NoConnectionException('Network error: $e');
    }

    if (response.statusCode == 429) {
      throw ApiLimitException();
    }
    if (response.statusCode >= 500 && response.statusCode < 600) {
      throw ApiUnavailableException(response.statusCode);
    }
    if (response.statusCode != 200) {
      throw Exception(
        'Claude API error ${response.statusCode}: ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Analyse a screenshot and extract subscription + trap details.
  ///
  /// [imageBytes] — the raw screenshot PNG/JPEG bytes.
  /// [mimeType]   — 'image/png' or 'image/jpeg'.
  ///
  /// Returns a [ScanOutput] with both subscription and trap data.
  /// Throws on network or parse errors.
  /// Throws [ScanLimitReachedException] if free scan limit reached.
  /// Run dedicated trap detection scan.
  ///
  /// Returns a [TrapResult] from a focused fine-print analysis.
  /// Returns [TrapResult.clean] if the scan fails or finds no traps.
  /// This method NEVER throws — trap scan failure is not user-facing.
  Future<TrapResult> _runTrapScan({
    required String base64Image,
    required String mimeType,
    String langCode = 'en',
  }) async {
    try {
      final body = {
        'model': AppConstants.aiModel,
        'max_tokens': 1000,
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
                'text': _trapScanPromptFor(langCode),
              },
            ],
          },
        ],
      };

      final responseJson = await _callApi(body);
      final content = responseJson['content'] as List<dynamic>;
      final textBlock = content.firstWhere(
        (block) => block['type'] == 'text',
        orElse: () => throw Exception('No text block in trap scan response'),
      );
      final rawText = textBlock['text'] as String;
      final decoded = _extractJson(rawText);

      if (decoded is! Map<String, dynamic>) {
        return TrapResult.clean;
      }

      final data = decoded;
      final hasTraps = data['has_traps'] as bool? ?? false;

      if (!hasTraps) return TrapResult.clean;

      // Map worst_type string to TrapType enum
      TrapType? trapType;
      final worstType = data['worst_type'] as String?;
      switch (worstType) {
        case 'trial_bait':
          trapType = TrapType.trialBait;
          break;
        case 'price_framing':
          trapType = TrapType.priceFraming;
          break;
        case 'hidden_renewal':
          trapType = TrapType.hiddenRenewal;
          break;
        case 'cancel_friction':
          trapType = TrapType.cancelFriction;
          break;
        default:
          trapType = TrapType.hiddenRenewal;
      }

      // Map severity string to TrapSeverity enum
      TrapSeverity severity;
      switch (data['worst_severity'] as String? ?? 'low') {
        case 'high':
          severity = TrapSeverity.high;
          break;
        case 'medium':
          severity = TrapSeverity.medium;
          break;
        default:
          severity = TrapSeverity.low;
      }

      // Parse scenario and map new fields for backward compat
      final scenario = data['scenario'] as String?;
      // current_price → trialPrice (what user pays now / initially)
      final currentPrice = (data['current_price'] as num?)?.toDouble();
      // future_price → realPrice (what user will pay later)
      final futurePrice = (data['future_price'] as num?)?.toDouble();
      // future_billing_cycle → realBillingCycle
      final futureBillingCycle = data['future_billing_cycle'] as String?;

      return TrapResult(
        isTrap: true,
        trapType: trapType,
        severity: severity,
        scenario: scenario,
        trialPrice: currentPrice,
        trialDurationDays: (data['trial_duration_days'] as num?)?.toInt(),
        realPrice: futurePrice,
        realBillingCycle: futureBillingCycle,
        realAnnualCost: (data['real_annual_cost'] as num?)?.toDouble(),
        confidence: data['confidence'] as int? ?? 0,
        warningMessage: data['warning_message'] as String? ?? '',
        serviceName: '',
      );
    } catch (e, st) {
      ErrorLogger.log(event: 'ai_api_error', detail: 'parseTrapResult: $e', stackTrace: st.toString());
      return TrapResult.clean;
    }
  }

  /// Max dimension for images sent to the API.
  static const _maxDimension = 1280;

  /// JPEG quality for re-encoded images (0-100).
  static const _jpegQuality = 80;

  /// Normalise image bytes for the API: convert non-JPEG/PNG formats (HEIC,
  /// WebP, etc.), resize oversized images to fit within [_maxDimension]px on
  /// the longest side, and re-encode as JPEG for small payload size.
  ///
  /// Every image sent to the API passes through this method. Returns a record
  /// of (bytes, mimeType) ready for base64 encoding.
  static Future<({Uint8List bytes, String mime})> _normaliseImage(
    Uint8List imageBytes,
    String mimeType,
  ) async {
    try {
      // ── Step 1: Decode ──
      // For JPEG/PNG the `image` package can decode directly.
      // For HEIC/HEIF/WebP we need Flutter's platform codec first.
      img.Image? decoded;
      final isNativeFormat =
          mimeType == 'image/jpeg' || mimeType == 'image/png';

      if (isNativeFormat) {
        // Quick size check — if already small enough, pass through as-is.
        decoded = await compute(_decodeImage, imageBytes);
        if (decoded != null &&
            decoded.width <= _maxDimension &&
            decoded.height <= _maxDimension &&
            imageBytes.length <= 500 * 1024) {
          return (bytes: imageBytes, mime: mimeType);
        }
      } else {
        // HEIC / HEIF / WebP / other — decode via platform codec to raw RGBA,
        // then hand off to the image package for resize + JPEG encode.
        final rgba = await _decodeToPlatformRgba(imageBytes);
        if (rgba == null) {
          return (bytes: imageBytes, mime: mimeType);
        }
        decoded = rgba;
      }

      if (decoded == null) {
        return (bytes: imageBytes, mime: mimeType);
      }

      // ── Step 2: Resize if needed ──
      final needsResize =
          decoded.width > _maxDimension || decoded.height > _maxDimension;
      if (needsResize) {
        final scale = _maxDimension /
            (decoded.width > decoded.height
                ? decoded.width
                : decoded.height);
        final newW = (decoded.width * scale).round();
        final newH = (decoded.height * scale).round();
        decoded = img.copyResize(decoded, width: newW, height: newH,
            interpolation: img.Interpolation.linear);
      }

      // ── Step 3: Encode as JPEG ──
      final jpegBytes = await compute<_EncodeParams, Uint8List>(
        _encodeJpeg,
        _EncodeParams(decoded, _jpegQuality),
      );

      return (bytes: jpegBytes, mime: 'image/jpeg');
    } catch (_) {
      return (bytes: imageBytes, mime: mimeType);
    }
  }

  /// Decode image bytes using the `image` package (runs in isolate).
  static img.Image? _decodeImage(Uint8List bytes) {
    return img.decodeImage(bytes);
  }

  /// Encode an image to JPEG (runs in isolate).
  static Uint8List _encodeJpeg(_EncodeParams params) {
    return Uint8List.fromList(
      img.encodeJpg(params.image, quality: params.quality),
    );
  }

  /// Decode non-native formats (HEIC, WebP, etc.) via Flutter's platform
  /// codec into an [img.Image] suitable for the `image` package.
  static Future<img.Image?> _decodeToPlatformRgba(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;
      final byteData = await uiImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      final w = uiImage.width;
      final h = uiImage.height;
      uiImage.dispose();
      codec.dispose();

      if (byteData == null || byteData.lengthInBytes == 0) return null;

      return img.Image.fromBytes(
        width: w,
        height: h,
        bytes: byteData.buffer,
        numChannels: 4,
        order: img.ChannelOrder.rgba,
      );
    } catch (_) {
      return null;
    }
  }

  /// Analyse a screenshot and extract subscription + trap details.
  ///
  /// Runs TWO API calls in parallel:
  /// 1. Subscription extraction (detailed, comprehensive)
  /// 2. Trap detection (dedicated fine-print analysis)
  ///
  /// If trap detection fails, returns clean trap result (no error shown).
  /// Throws on subscription extraction failure.
  /// Throws [ScanLimitReachedException] if free scan limit reached.
  Future<ScanOutput> analyseScreenshotWithTrap({
    required Uint8List imageBytes,
    required String mimeType,
    String? modelOverride,
    String langCode = 'en',
  }) async {
    // Normalise HEIC/HEIF/WebP → PNG for API compatibility.
    final normalised = await _normaliseImage(imageBytes, mimeType);
    final base64Image = base64Encode(normalised.bytes);

    if (base64Image.isEmpty) {
      throw Exception('Image encoding produced empty result');
    }

    // Build subscription extraction request body
    final subBody = {
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
                'media_type': normalised.mime,
                'data': base64Image,
              },
            },
            {
              'type': 'text',
              'text': _extractionPromptFor(langCode),
            },
          ],
        },
      ],
    };

    // Run both calls in parallel
    final results = await Future.wait<dynamic>([
      _callApi(subBody),
      _runTrapScan(base64Image: base64Image, mimeType: normalised.mime, langCode: langCode),
    ]);

    // Parse subscription result (call 1)
    final subResponseJson = results[0] as Map<String, dynamic>;
    final content = subResponseJson['content'] as List<dynamic>;
    final textBlock = content.firstWhere(
      (block) => block['type'] == 'text',
      orElse: () => throw Exception('No text block in Claude response'),
    );
    final rawText = textBlock['text'] as String;
    final decoded = _extractJson(rawText);

    final Map<String, dynamic> parsed;
    if (decoded is List) {
      if (decoded.isEmpty) {
        throw Exception('Claude returned an empty array');
      }
      parsed = decoded.first as Map<String, dynamic>;
    } else {
      parsed = decoded as Map<String, dynamic>;
    }

    // Build subscription from parsed JSON
    final subscriptionJson = parsed['subscription'] as Map<String, dynamic>? ?? parsed;
    final subscription = ScanResult.fromJson(subscriptionJson);

    // Get trap result (call 2) — already a TrapResult, never throws
    final trapResult = results[1] as TrapResult;
    // Set service name on trap result if trap was found
    final finalTrap = trapResult.isTrap
        ? TrapResult(
            isTrap: trapResult.isTrap,
            trapType: trapResult.trapType,
            severity: trapResult.severity,
            scenario: trapResult.scenario,
            trialPrice: trapResult.trialPrice,
            trialDurationDays: trapResult.trialDurationDays,
            realPrice: trapResult.realPrice,
            realBillingCycle: trapResult.realBillingCycle,
            realAnnualCost: trapResult.realAnnualCost,
            confidence: trapResult.confidence,
            warningMessage: trapResult.warningMessage,
            serviceName: subscription.serviceName,
          )
        : TrapResult.clean;

    return ScanOutput(subscription: subscription, trap: finalTrap);
  }

  /// Analyse a screenshot and extract ALL subscription + trap details.
  ///
  /// Returns a list of [ScanOutput] when multiple subscriptions are found
  /// (e.g. bank statements). Returns a single-item list for single results.
  /// Throws [ScanLimitReachedException] if free scan limit reached.
  Future<List<ScanOutput>> analyseScreenshotMulti({
    required Uint8List imageBytes,
    required String mimeType,
    String? modelOverride,
    String langCode = 'en',
  }) async {
    // Normalise HEIC/HEIF/WebP → PNG for API compatibility.
    final normalised = await _normaliseImage(imageBytes, mimeType);
    final base64Image = base64Encode(normalised.bytes);

    if (base64Image.isEmpty) {
      throw Exception('Image encoding produced empty result');
    }

    final body = {
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
                'media_type': normalised.mime,
                'data': base64Image,
              },
            },
            {
              'type': 'text',
              'text': _multiExtractionPromptFor(langCode),
            },
          ],
        },
      ],
    };

    final responseJson = await _callApi(body);
    final content = responseJson['content'] as List<dynamic>;
    final textBlock = content.firstWhere(
      (block) => block['type'] == 'text',
      orElse: () => throw Exception('No text block in Claude response'),
    );
    final rawText = textBlock['text'] as String;

    final decoded = _extractJson(rawText);

    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((item) => ScanOutput.fromJson(item))
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
          category: 'streaming',
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
          category: 'streaming',
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
          category: 'gaming',
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
          category: 'developer',
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
          category: 'music',
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
        category: 'music',
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
        category: 'fitness',
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
        category: 'productivity',
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
        category: 'fitness',
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
            category: 'streaming',
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
            category: 'fitness',
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
            category: 'fitness',
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
            category: 'streaming',
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

  /// Robustly extract JSON from Claude's response text.
  ///
  /// Claude sometimes adds commentary before or after the JSON
  /// (e.g. "**IMPORTANT NOTE:** ..."). This method:
  /// 1. Strips markdown code fences
  /// 2. Finds the outermost JSON object ({...}) or array ([...])
  /// 3. Ignores any text outside those boundaries
  static dynamic _extractJson(String rawText) {
    // Strip markdown fences first
    var text = rawText
        .replaceAll(RegExp(r'^```json?\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^```\s*$', multiLine: true), '')
        .trim();

    // Try parsing directly — works if Claude returned clean JSON
    try {
      return jsonDecode(text);
    } catch (_) {
      // Fall through to extraction logic
    }

    // Find the first { or [ and extract the balanced JSON from there
    final firstBrace = text.indexOf('{');
    final firstBracket = text.indexOf('[');

    int start;
    String openChar;
    String closeChar;

    if (firstBrace < 0 && firstBracket < 0) {
      throw FormatException('No JSON found in AI response: ${text.substring(0, text.length.clamp(0, 200))}');
    } else if (firstBrace < 0) {
      start = firstBracket;
      openChar = '[';
      closeChar = ']';
    } else if (firstBracket < 0) {
      start = firstBrace;
      openChar = '{';
      closeChar = '}';
    } else {
      // Use whichever comes first
      if (firstBrace < firstBracket) {
        start = firstBrace;
        openChar = '{';
        closeChar = '}';
      } else {
        start = firstBracket;
        openChar = '[';
        closeChar = ']';
      }
    }

    // Walk forward to find the matching closing bracket/brace,
    // accounting for nesting and strings.
    int depth = 0;
    bool inString = false;
    bool escaped = false;
    int? end;

    for (int i = start; i < text.length; i++) {
      final c = text[i];

      if (escaped) {
        escaped = false;
        continue;
      }

      if (c == r'\' && inString) {
        escaped = true;
        continue;
      }

      if (c == '"') {
        inString = !inString;
        continue;
      }

      if (inString) continue;

      if (c == openChar) {
        depth++;
      } else if (c == closeChar) {
        depth--;
        if (depth == 0) {
          end = i;
          break;
        }
      }
    }

    if (end == null) {
      throw FormatException('Unbalanced JSON in AI response');
    }

    final jsonStr = text.substring(start, end + 1);
    return jsonDecode(jsonStr);
  }

  /// Map language code to full language name for AI prompt instructions.
  static String _languageName(String langCode) {
    return switch (langCode) {
      'pl' => 'Polish',
      'de' => 'German',
      'fr' => 'French',
      'es' => 'Spanish',
      _ => 'English',
    };
  }

  /// Language instruction appended to AI prompts when non-English.
  static String _langInstruction(String langCode) {
    if (langCode == 'en') return '';
    final lang = _languageName(langCode);
    return '\nIMPORTANT: Write the extraction_notes and warning_message fields in $lang. Use $lang for all human-readable text in your response. Keep field names and enum values (like billing_cycle, category, source_type) in English.\n';
  }

  /// The structured extraction prompt sent to Claude Haiku.
  ///
  /// Includes both subscription extraction (Task 1) and
  /// trap detection (Task 2) in a single API call.
  static String _extractionPromptFor(String langCode) => '''
${_langInstruction(langCode)}
Today's date is ${DateTime.now().toIso8601String().substring(0, 10)}.

Analyse this image carefully. It may be:
- A subscription confirmation email
- A bank/card transaction list or statement
- An app store receipt or billing page
- A payment confirmation screen
- Any screen showing subscription or recurring payment info

TASK 1 — SUBSCRIPTION EXTRACTION:
Find any subscription or recurring payment services and extract:
- service_name: the actual product/service name (e.g. "Netflix", "ScreenPal", "Claude Pro")
- price: numeric only, no currency symbol. This is the CURRENT price the user pays or will pay at the NEXT renewal. For intro/promotional pricing, use the intro price (not the future full price). If price is NOT visible, set to null.
- currency: ISO 4217 code (GBP, USD, EUR, PLN, etc). Infer from symbols, language, or context.
- billing_cycle: "weekly" | "monthly" | "quarterly" | "yearly". Infer from context if not explicit.
- next_renewal: ISO date string — the NEXT date the user will be charged ANY amount. NOT the date the price changes. If in an intro period with multiple charges before the full price, use the next billing date at the current price. Example: "£3.49/month for 2 months then £6.99 starting Mar 28" purchased Jan 29 → next_renewal = "2026-02-28".
- is_trial: boolean
- trial_end_date: ISO date string — when the intro/trial period ENDS and full price begins. Different from next_renewal when there are billing dates during the intro period.
- category: one of "streaming", "music", "ai", "productivity", "storage", "fitness", "gaming", "reading", "communication", "news", "finance", "education", "vpn", "developer", "bundle", "other"
- icon: first letter or short identifier (1-2 chars)
- brand_color: hex colour code for the brand
- source_type: "email" | "bank_statement" | "app_store" | "receipt" | "billing_page" | "other"
- is_expiring: boolean — true if the subscription says "Expires" (already cancelled, will stop). false if it says "Renews" (active, will auto-charge). Default false.

HOW TO READ BANK STATEMENTS:
Bank and card transaction lists require extra attention:
- Look for software/app/service names INSIDE transaction descriptions
- Card payments often show: "VISA/MASTERCARD [card number] [amount] [currency] [merchant name]"
- Foreign currency conversions (e.g. "8.00 USD 1 USD=3.69 PLN") strongly suggest online/digital subscriptions
- The service name may appear at the END of a long transaction line, sometimes truncated
- Polish bank format: "DOP. VISA ... PŁATNOŚĆ KARTĄ [amount] [currency] [service name]"
- UK bank format: "CARD PAYMENT TO [service name]" or "[service name] [reference]"
- Common subscription merchants to look for: Netflix, Spotify, YouTube, Apple, Google, Adobe, Microsoft, Amazon Prime, Disney+, ChatGPT, Claude, Notion, Figma, Canva, ScreenPal, GitHub, Dropbox, iCloud, HBO, Hulu, Paramount+
- If a transaction has a foreign currency conversion AND matches a known digital service, it is very likely a subscription

BANK STATEMENT DATE RULES — CRITICAL:
Bank/card statements show TRANSACTION dates, NOT renewal dates.
- A charge on "31 Jan" means the payment was taken on that date
- It does NOT tell you when the NEXT charge will be
- For bank statement source_type: ALWAYS set next_renewal to null
- Do NOT try to calculate the next renewal from a transaction date
- The app will ask the user for the actual renewal date separately

BANK STATEMENT BILLING CYCLE RULES:
When scanning bank statements, you often only see ONE charge. You cannot
reliably determine the billing cycle from a single transaction.
- If you can see MULTIPLE charges for the same service across different dates,
  you CAN infer the cycle from the gap between them
- If you only see ONE charge, set billing_cycle to null — do NOT guess
- Do NOT use price alone to determine billing cycle for bank statements
  (prices vary hugely by country and currency)

CRITICAL — WHAT IS NOT A SUBSCRIPTION (ABSOLUTE RULES):
You MUST strictly filter out non-subscription transactions. ONLY return transactions that you are HIGHLY CONFIDENT are RECURRING DIGITAL SERVICES or SOFTWARE SUBSCRIPTIONS.

NEVER return ANY of the following — even if the amount looks subscription-like:
- Retail/grocery stores: Lidl, Biedronka, Żabka, Tesco, Carrefour, Auchan, Kaufland, Netto, Stokrotka, Dino, etc.
- Drugstores/pharmacies: Rossmann, Hebe, dm, etc.
- Clothing/sports: Decathlon, Zara, H&M, IKEA, Pepco, Action, TK Maxx, Primark, etc.
- Electronics: MediaMarkt, RTV Euro AGD, x-kom, etc.
- General retail: Empik, Allegro (one-off), AliExpress, eBay, Amazon (non-Prime one-offs)
- BLIK payments: "Zakup BLIK" is a Polish instant payment method — the merchant after "BLIK" (e.g. PayPro S.A., Przelewy24, Tpay, DotPay) is a PAYMENT PROCESSOR, not a subscription service. ALWAYS skip these.
- Payment processors: PayPro, Przelewy24, Tpay, DotPay, PayU, Stripe (as merchant name), Adyen — these are intermediaries, NOT the actual service
- Bank transfers, ATM withdrawals, salary deposits, standing orders to individuals
- One-time online purchases
- Utility bills (electricity, gas, water) — unless clearly a streaming/software service
- Fuel stations, public transport, parking
- Insurance, loan repayments
- Restaurant/food delivery one-off orders
- "Wpłata końcówek" or rounding-up savings — these are bank features, NOT subscriptions
- ANY physical store or brick-and-mortar retailer

KEY RULE: If a transaction description does NOT clearly contain a recognisable digital/software service name (like Netflix, Spotify, ScreenPal, Adobe, ChatGPT, etc.), do NOT include it. When in doubt, EXCLUDE the transaction.

HOW TO READ iOS SUBSCRIPTIONS SCREEN (Settings → Subscriptions):

CRITICAL RULE — "Expires" vs "Renews" is the ONLY status indicator:
On iOS, plan names like "Annual Premium (7 Day Trial)" are STATIC metadata — Apple does NOT
update the plan name after the trial converts to a paid subscription. So "(7 Day Trial)" in
the plan name does NOT mean the trial is currently active. You MUST use the "Renews"/"Expires"
keyword to determine the actual status.

1. "Expires on [date]" = ALREADY CANCELLED — the user cancelled and the service will stop.
   → ALWAYS set is_expiring: true, is_trial: false
   → This applies REGARDLESS of whether the plan name contains "Trial", "7 Day Trial",
     "Free Trial", "Intro Offer", etc. Those are just historical plan name labels.
   → Do NOT flag as a trap — the user already cancelled, they are safe.
   → ONLY exception: if the expiry date is within 7 days from TODAY (not months away — literally
     ≤7 calendar days) AND the plan name says "Trial" AND no regular price is visible anywhere,
     it MIGHT be an active trial about to end. In this rare case ONLY: set is_trial: true,
     is_expiring: false, flag as trap.
   → Example: "Annual Premium (7 Day Trial)" + "Expires on 7 October" (months away)
     → is_expiring: true, is_trial: false. The "(7 Day Trial)" is just a historical plan name.
     The date is months away, NOT within 7 days, so the exception does NOT apply.

2. "Renews [date]" = ACTIVE subscription that will auto-charge.
   → set is_expiring: false
   → If plan name contains "Trial" BUT the renews date is MORE than 14 days away:
     the trial is OVER — this is now a normal paid subscription. Set is_trial: false.
   → If plan name contains "Trial" AND the renews date is within ~7-14 days:
     this might be an active trial about to convert. Set is_trial: true, flag as trap.

3. Summary priority: "Expires" → is_expiring: true (always). "Renews" → is_expiring: false (always).
   Trial text in the plan name is informational only — it does NOT override the Expires/Renews status.

BILLING CYCLE INFERENCE ON iOS SUBSCRIPTIONS SCREEN — CRITICAL:
The iOS subscriptions list shows the price but usually does NOT show "/mo" or "/yr" explicitly.
You MUST infer the billing cycle from these clues:
1. PLAN NAME is the strongest clue:
   - "Annual", "Yearly", "12 Month", "1 Year" in plan name → "yearly"
   - "Monthly", "1 Month" in plan name → "monthly"
   - "Weekly", "1 Week" in plan name → "weekly"
   - "Quarterly", "3 Month" in plan name → "quarterly"
2. PRICE as a clue — use your knowledge of common service pricing:
   - ChatGPT Plus: ~20 USD/mo or ~200 USD/yr (in PLN: ~99.99 PLN/mo or ~499-999 PLN/yr). If price is ~99.99 PLN → likely MONTHLY
   - iCloud+: ~0.99-9.99 USD/mo depending on tier. 50GB ~0.99/mo, 200GB ~2.99/mo, 2TB ~9.99/mo. In PLN: 2TB ~3.99-49.99 PLN/mo. If showing 49.99 PLN → likely MONTHLY
   - Strava: ~80 USD/yr or ~12 USD/mo. In PLN: ~150 PLN/yr or ~50 PLN/mo. If showing 149.99 PLN → likely YEARLY
   - Netflix: ~15 USD/mo or ~23 USD/mo premium. In PLN: ~33-60 PLN/mo
   - Spotify: ~10 USD/mo or ~12 USD/mo premium. In PLN: ~24-30 PLN/mo
   - YouTube Premium: ~14 USD/mo. In PLN: ~24-50 PLN/mo
3. RENEWAL DATE gap from today — if renewal is ~1 month away → monthly, ~1 year away → yearly
4. When in doubt between monthly and yearly: if the price seems HIGH for a monthly charge for that specific service, it's probably yearly. If it seems LOW for a yearly charge, it's probably monthly.
DO NOT default to "monthly" — actually reason about the price and plan name.

RENEWS vs EXPIRES — CRITICAL DISTINCTION:
- "Renews" = ACTIVE subscription, will auto-charge → is_expiring: false
- "Expires" = ALREADY CANCELLED, will stop → is_expiring: true (even if plan name mentions "Trial")
- When is_expiring is true: the subscription should NOT be tracked as active. The user already cancelled it.
- Default is_expiring to false when you cannot determine the status.

DATE INFERENCE — CRITICAL (you MUST follow these rules):
- ALL dates you return for next_renewal and trial_end_date MUST be in the future (today or later). NEVER return a past date.
- When a date has NO year (e.g. "18 April", "14 February"), assume the NEXT future occurrence from today's date.
  Example: if today is February 2026 and the image says "Expires on 18 April", that means 18 April 2026, NOT 2024.
- When a date HAS a year but is in the PAST, roll it forward by the billing cycle until it is in the future.
  Example: yearly sub showing "7 October 2025" and today is Feb 2026 → return "2026-10-07".
  Example: monthly sub showing "14 January 2025" → roll forward monthly → return the next future occurrence.
- Screenshots may show OLD dates from past billing periods. Always convert these to the NEXT future renewal date.
- If a date with no year would be in the past for the current year, roll forward to next year.
- CRITICAL for MONTHLY subs: "Renews 20 February" with today being 14 Feb 2026 → next_renewal is "2026-02-20" (6 days away, NOT a year away).
  "Renews 14 February" with today being 14 Feb 2026 → next_renewal is "2026-03-14" (next month, since today's date has passed).
- CRITICAL for YEARLY subs: The date shown on iOS is the ACTUAL next renewal date, NOT a date you need to add a year to.
  "Renews 20 February" on a yearly sub with today being 14 Feb 2026 → next_renewal is "2026-02-20" (6 days away).
  "Renews 18 April" on a yearly sub with today being 14 Feb 2026 → next_renewal is "2026-04-18" (2 months away, NOT 2027).
  Do NOT add the billing cycle to the displayed date — the date IS the next renewal. Only roll forward if the date is in the PAST.
- Always return ISO format: "2026-04-18"

IMPORTANT RULES:
1. If a field is NOT visible in the image, set it to null. Do NOT guess or default to 0.
2. For service_name: use the real product name. "Claude Pro" not "Anthropic". "ScreenPal" not "PayPro S.A.". "Amazon Prime" not "Amazon".
3. For billing_cycle: NEVER blindly default to "monthly". Always reason about the cycle using plan name, price, and renewal date gap. See BILLING CYCLE INFERENCE section above.
4. If you find a service name but not a price, still return the service with price as null — do NOT return "Unknown".
5. If you genuinely cannot find ANY subscription or recurring service in the image, return service_name as "Unknown" with overall_confidence 0.0.
6. Set confidence per field: 1.0 if clearly visible, 0.5 if inferred, 0.0 if not found.
7. For bank statements: ONLY extract transactions that are digital/software subscriptions. Skip ALL physical retail stores, grocery shops, drugstores (e.g. Rossmann), sporting goods stores (e.g. Decathlon), restaurants, and other brick-and-mortar purchases. Be very conservative — it is better to miss a subscription than to wrongly include a store purchase.

ALSO INCLUDE:
- missing_fields: array of field names that could not be found (e.g. ["price", "billing_cycle"])
- extraction_notes: brief explanation of what you found and what's missing (max 2 sentences)

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
    "is_expiring": boolean,
    "confidence": { "name": 0.0, "price": 0.0, "cycle": 0.0, "currency": 0.0 },
    "overall_confidence": 0.0,
    "tier": 1,
    "missing_fields": ["string"],
    "extraction_notes": "string"
  }
}

If no subscription is detected at all, return service_name "Unknown" with overall_confidence 0.
If multiple subscriptions are visible, return the most prominent one only.
Return ONLY valid JSON, no markdown, no explanation.
''';

  /// Prompt for multi-subscription extraction (bank statements, billing pages).
  ///
  /// Returns a JSON array of subscription+trap objects.
  static String _multiExtractionPromptFor(String langCode) => '''
${_langInstruction(langCode)}
Today's date is ${DateTime.now().toIso8601String().substring(0, 10)}.

Analyse this image carefully. It is likely a bank statement, card transaction list, or billing page with MULTIPLE subscriptions.

For EACH recurring subscription or digital service charge you find, extract:
- service_name: the actual product/service name (e.g. "Netflix", "ScreenPal", "Claude Pro")
- price: numeric only, no currency symbol. This is the CURRENT price the user pays or will pay at the NEXT renewal. For intro/promotional pricing, use the intro price (not the future full price). If price is NOT visible, set to null.
- currency: ISO 4217 code (GBP, USD, EUR, PLN, etc). Infer from symbols, language, or context.
- billing_cycle: "weekly" | "monthly" | "quarterly" | "yearly". Infer from context if not explicit.
- next_renewal: ISO date string — the NEXT date the user will be charged ANY amount. NOT the date the price changes. If in an intro period with multiple charges before the full price, use the next billing date at the current price. Example: "£3.49/month for 2 months then £6.99 starting Mar 28" purchased Jan 29 → next_renewal = "2026-02-28".
- is_trial: boolean
- trial_end_date: ISO date string — when the intro/trial period ENDS and full price begins. Different from next_renewal when there are billing dates during the intro period.
- category: one of "streaming", "music", "ai", "productivity", "storage", "fitness", "gaming", "reading", "communication", "news", "finance", "education", "vpn", "developer", "bundle", "other"
- icon: first letter or short identifier (1-2 chars)
- brand_color: hex colour code for the brand
- source_type: "email" | "bank_statement" | "app_store" | "receipt" | "billing_page" | "other"
- is_expiring: boolean — true if the subscription says "Expires" (already cancelled, will stop). false if it says "Renews" (active, will auto-charge). Default false.
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
- Common subscription merchants: Netflix, Spotify, YouTube, Apple, Google, Adobe, Microsoft, Amazon Prime, Disney+, ChatGPT, Claude, Notion, Figma, Canva, ScreenPal, GitHub, Dropbox, iCloud, HBO, Hulu, Paramount+

BANK STATEMENT DATE RULES — CRITICAL:
Bank/card statements show TRANSACTION dates, NOT renewal dates.
- A charge on "31 Jan" means the payment was taken on that date
- It does NOT tell you when the NEXT charge will be
- For bank statement source_type: ALWAYS set next_renewal to null
- Do NOT try to calculate the next renewal from a transaction date
- The app will ask the user for the actual renewal date separately

BANK STATEMENT BILLING CYCLE RULES:
When scanning bank statements, you often only see ONE charge. You cannot
reliably determine the billing cycle from a single transaction.
- If you can see MULTIPLE charges for the same service across different dates,
  you CAN infer the cycle from the gap between them
- If you only see ONE charge, set billing_cycle to null — do NOT guess
- Do NOT use price alone to determine billing cycle for bank statements
  (prices vary hugely by country and currency)

CRITICAL — WHAT IS NOT A SUBSCRIPTION (ABSOLUTE RULES — MUST EXCLUDE):
You MUST strictly filter out non-subscription transactions. ONLY return transactions that you are HIGHLY CONFIDENT are RECURRING DIGITAL SERVICES or SOFTWARE SUBSCRIPTIONS.

NEVER return ANY of the following — even if the amount looks subscription-like:
- Retail/grocery stores: Lidl, Biedronka, Żabka, Tesco, Carrefour, Auchan, Kaufland, Netto, Stokrotka, Dino, etc.
- Drugstores/pharmacies: Rossmann, Hebe, dm, etc.
- Clothing/sports: Decathlon, Zara, H&M, IKEA, Pepco, Action, TK Maxx, Primark, etc.
- Electronics: MediaMarkt, RTV Euro AGD, x-kom, etc.
- General retail: Empik, Allegro (one-off), AliExpress, eBay, Amazon (non-Prime one-offs)
- BLIK payments: "Zakup BLIK" is a Polish instant payment method — the merchant after "BLIK" (e.g. PayPro S.A., Przelewy24, Tpay, DotPay) is a PAYMENT PROCESSOR, not a subscription service. ALWAYS skip these.
- Payment processors: PayPro, Przelewy24, Tpay, DotPay, PayU, Stripe (as merchant name), Adyen — these are intermediaries, NOT the actual service
- Bank transfers, ATM withdrawals, salary deposits, standing orders to individuals
- One-time online purchases
- Utility bills (electricity, gas, water) — unless clearly a streaming/software service
- Fuel stations, public transport, parking
- Insurance, loan repayments
- Restaurant/food delivery one-off orders
- "Wpłata końcówek" or rounding-up savings — these are bank features, NOT subscriptions
- ANY physical store or brick-and-mortar retailer

KEY RULE: If a transaction description does NOT clearly contain a recognisable digital/software service name (like Netflix, Spotify, ScreenPal, Adobe, ChatGPT, etc.), do NOT include it. When in doubt, EXCLUDE the transaction.

HOW TO READ iOS SUBSCRIPTIONS SCREEN (Settings → Subscriptions):

CRITICAL RULE — "Expires" vs "Renews" is the ONLY status indicator:
On iOS, plan names like "Annual Premium (7 Day Trial)" are STATIC metadata — Apple does NOT
update the plan name after the trial converts to a paid subscription. So "(7 Day Trial)" in
the plan name does NOT mean the trial is currently active. You MUST use the "Renews"/"Expires"
keyword to determine the actual status.

1. "Expires on [date]" = ALREADY CANCELLED — the user cancelled and the service will stop.
   → ALWAYS set is_expiring: true, is_trial: false
   → This applies REGARDLESS of whether the plan name contains "Trial", "7 Day Trial",
     "Free Trial", "Intro Offer", etc. Those are just historical plan name labels.
   → Do NOT flag as a trap — the user already cancelled, they are safe.
   → ONLY exception: if the expiry date is within 7 days from TODAY (not months away — literally
     ≤7 calendar days) AND the plan name says "Trial" AND no regular price is visible anywhere,
     it MIGHT be an active trial about to end. In this rare case ONLY: set is_trial: true,
     is_expiring: false, flag as trap.
   → Example: "Annual Premium (7 Day Trial)" + "Expires on 7 October" (months away)
     → is_expiring: true, is_trial: false. The "(7 Day Trial)" is just a historical plan name.
     The date is months away, NOT within 7 days, so the exception does NOT apply.

2. "Renews [date]" = ACTIVE subscription that will auto-charge.
   → set is_expiring: false
   → If plan name contains "Trial" BUT the renews date is MORE than 14 days away:
     the trial is OVER — this is now a normal paid subscription. Set is_trial: false.
   → If plan name contains "Trial" AND the renews date is within ~7-14 days:
     this might be an active trial about to convert. Set is_trial: true, flag as trap.

3. Summary priority: "Expires" → is_expiring: true (always). "Renews" → is_expiring: false (always).
   Trial text in the plan name is informational only — it does NOT override the Expires/Renews status.

BILLING CYCLE INFERENCE ON iOS SUBSCRIPTIONS SCREEN — CRITICAL:
The iOS subscriptions list shows the price but usually does NOT show "/mo" or "/yr" explicitly.
You MUST infer the billing cycle from these clues:
1. PLAN NAME is the strongest clue:
   - "Annual", "Yearly", "12 Month", "1 Year" in plan name → "yearly"
   - "Monthly", "1 Month" in plan name → "monthly"
   - "Weekly", "1 Week" in plan name → "weekly"
   - "Quarterly", "3 Month" in plan name → "quarterly"
2. PRICE as a clue — use your knowledge of common service pricing:
   - ChatGPT Plus: ~20 USD/mo or ~200 USD/yr (in PLN: ~99.99 PLN/mo or ~499-999 PLN/yr). If price is ~99.99 PLN → likely MONTHLY
   - iCloud+: ~0.99-9.99 USD/mo depending on tier. 50GB ~0.99/mo, 200GB ~2.99/mo, 2TB ~9.99/mo. In PLN: 2TB ~3.99-49.99 PLN/mo. If showing 49.99 PLN → likely MONTHLY
   - Strava: ~80 USD/yr or ~12 USD/mo. In PLN: ~150 PLN/yr or ~50 PLN/mo. If showing 149.99 PLN → likely YEARLY
   - Netflix: ~15 USD/mo or ~23 USD/mo premium. In PLN: ~33-60 PLN/mo
   - Spotify: ~10 USD/mo or ~12 USD/mo premium. In PLN: ~24-30 PLN/mo
   - YouTube Premium: ~14 USD/mo. In PLN: ~24-50 PLN/mo
3. RENEWAL DATE gap from today — if renewal is ~1 month away → monthly, ~1 year away → yearly
4. When in doubt between monthly and yearly: if the price seems HIGH for a monthly charge for that specific service, it's probably yearly. If it seems LOW for a yearly charge, it's probably monthly.
DO NOT default to "monthly" — actually reason about the price and plan name.

RENEWS vs EXPIRES — CRITICAL DISTINCTION:
- "Renews" = ACTIVE subscription, will auto-charge → is_expiring: false
- "Expires" = ALREADY CANCELLED, will stop → is_expiring: true (even if plan name mentions "Trial")
- When is_expiring is true: the subscription should NOT be tracked as active. The user already cancelled it.
- Default is_expiring to false when you cannot determine the status.

DATE INFERENCE — CRITICAL (you MUST follow these rules):
- ALL dates you return for next_renewal and trial_end_date MUST be in the future (today or later). NEVER return a past date.
- When a date has NO year (e.g. "18 April", "14 February"), assume the NEXT future occurrence from today's date.
  Example: if today is February 2026 and the image says "Expires on 18 April", that means 18 April 2026, NOT 2024.
- When a date HAS a year but is in the PAST, roll it forward by the billing cycle until it is in the future.
  Example: yearly sub showing "7 October 2025" and today is Feb 2026 → return "2026-10-07".
  Example: monthly sub showing "14 January 2025" → roll forward monthly → return the next future occurrence.
- Screenshots may show OLD dates from past billing periods. Always convert these to the NEXT future renewal date.
- If a date with no year would be in the past for the current year, roll forward to next year.
- CRITICAL for MONTHLY subs: "Renews 20 February" with today being 14 Feb 2026 → next_renewal is "2026-02-20" (6 days away, NOT a year away).
  "Renews 14 February" with today being 14 Feb 2026 → next_renewal is "2026-03-14" (next month, since today's date has passed).
- CRITICAL for YEARLY subs: The date shown on iOS is the ACTUAL next renewal date, NOT a date you need to add a year to.
  "Renews 20 February" on a yearly sub with today being 14 Feb 2026 → next_renewal is "2026-02-20" (6 days away).
  "Renews 18 April" on a yearly sub with today being 14 Feb 2026 → next_renewal is "2026-04-18" (2 months away, NOT 2027).
  Do NOT add the billing cycle to the displayed date — the date IS the next renewal. Only roll forward if the date is in the PAST.
- Always return ISO format: "2026-04-18"

IMPORTANT RULES:
1. If a field is NOT visible in the image, set it to null. Do NOT guess or default to 0.
2. For service_name: use the real product name. "Claude Pro" not "Anthropic". "Amazon Prime" not "Amazon".
3. For billing_cycle: NEVER blindly default to "monthly". Always reason about the cycle using plan name, price, and renewal date gap. See BILLING CYCLE INFERENCE section above.
4. ONLY include charges that are CLEARLY recurring digital subscriptions or software services. Be very conservative — it is better to miss a subscription than to wrongly flag a store purchase as a subscription.
5. Set confidence per field: 1.0 if clearly visible, 0.5 if inferred, 0.0 if not found.
6. For bank statements: if a merchant name matches a physical retail store, supermarket, drugstore, sports shop, or any brick-and-mortar chain, ALWAYS skip it — even if the amount looks like it could be a subscription price.

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

  /// Dedicated trap detection prompt — runs as a separate API call.
  ///
  /// Focused entirely on reading fine print and detecting dark patterns.
  /// Returns a single trap analysis JSON object.
  // ─── Text-based scanning (no image) ───

  /// Analyse pasted text (email, confirmation) and extract subscription + trap.
  ///
  /// Equivalent to [analyseScreenshotWithTrap] but for text input.
  Future<ScanOutput> analyseTextWithTrap({
    required String text,
    String? modelOverride,
    String langCode = 'en',
  }) async {
    // Build subscription extraction request body (text-only, no image)
    final subBody = {
      'model': modelOverride ?? AppConstants.aiModel,
      'max_tokens': 4096,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': '${_textExtractionPromptFor(langCode)}\n\n--- BEGIN TEXT ---\n$text\n--- END TEXT ---',
            },
          ],
        },
      ],
    };

    // Build trap detection request body (text-only, no image)
    final trapBody = {
      'model': AppConstants.aiModel,
      'max_tokens': 1000,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': '${_textTrapScanPromptFor(langCode)}\n\n--- BEGIN TEXT ---\n$text\n--- END TEXT ---',
            },
          ],
        },
      ],
    };

    // Run both calls in parallel
    final results = await Future.wait<dynamic>([
      _callApi(subBody),
      _runTrapScanFromBody(trapBody),
    ]);

    // Parse subscription result (call 1)
    final subResponseJson = results[0] as Map<String, dynamic>;
    final content = subResponseJson['content'] as List<dynamic>;
    final textBlock = content.firstWhere(
      (block) => block['type'] == 'text',
      orElse: () => throw Exception('No text block in Claude response'),
    );
    final rawText = textBlock['text'] as String;
    final decoded = _extractJson(rawText);

    final Map<String, dynamic> parsed;
    if (decoded is List) {
      if (decoded.isEmpty) {
        throw Exception('Claude returned an empty array');
      }
      parsed = decoded.first as Map<String, dynamic>;
    } else {
      parsed = decoded as Map<String, dynamic>;
    }

    // Build subscription from parsed JSON
    final subscriptionJson = parsed['subscription'] as Map<String, dynamic>? ?? parsed;
    final subscription = ScanResult.fromJson(subscriptionJson);

    // Get trap result (call 2) — already a TrapResult, never throws
    final trapResult = results[1] as TrapResult;

    // Set service name on trap result if trap was found
    final finalTrap = trapResult.isTrap
        ? TrapResult(
            isTrap: trapResult.isTrap,
            trapType: trapResult.trapType,
            severity: trapResult.severity,
            scenario: trapResult.scenario,
            trialPrice: trapResult.trialPrice,
            trialDurationDays: trapResult.trialDurationDays,
            realPrice: trapResult.realPrice,
            realBillingCycle: trapResult.realBillingCycle,
            realAnnualCost: trapResult.realAnnualCost,
            confidence: trapResult.confidence,
            warningMessage: trapResult.warningMessage,
            serviceName: subscription.serviceName,
          )
        : TrapResult.clean;

    return ScanOutput(subscription: subscription, trap: finalTrap);
  }

  /// Analyse pasted text — convenience wrapper returning only [ScanResult].
  Future<ScanResult> analyseText({
    required String text,
    String? modelOverride,
  }) async {
    final output = await analyseTextWithTrap(text: text, modelOverride: modelOverride);
    return output.subscription;
  }

  /// Run trap detection from a pre-built API body (shared by image + text paths).
  Future<TrapResult> _runTrapScanFromBody(Map<String, dynamic> body) async {
    try {
      final responseJson = await _callApi(body);
      final content = responseJson['content'] as List<dynamic>;
      final textBlock = content.firstWhere(
        (block) => block['type'] == 'text',
        orElse: () => throw Exception('No text block in trap scan response'),
      );
      final rawText = textBlock['text'] as String;
      final decoded = _extractJson(rawText);

      if (decoded is! Map<String, dynamic>) {
        return TrapResult.clean;
      }

      final data = decoded;
      final hasTraps = data['has_traps'] as bool? ?? false;

      if (!hasTraps) return TrapResult.clean;

      TrapType? trapType;
      final worstType = data['worst_type'] as String?;
      switch (worstType) {
        case 'trial_bait':
          trapType = TrapType.trialBait;
          break;
        case 'price_framing':
          trapType = TrapType.priceFraming;
          break;
        case 'hidden_renewal':
          trapType = TrapType.hiddenRenewal;
          break;
        case 'cancel_friction':
          trapType = TrapType.cancelFriction;
          break;
        default:
          trapType = TrapType.hiddenRenewal;
      }

      TrapSeverity severity;
      switch (data['worst_severity'] as String? ?? 'low') {
        case 'high':
          severity = TrapSeverity.high;
          break;
        case 'medium':
          severity = TrapSeverity.medium;
          break;
        default:
          severity = TrapSeverity.low;
      }

      final scenario = data['scenario'] as String?;
      final currentPrice = (data['current_price'] as num?)?.toDouble();
      final futurePrice = (data['future_price'] as num?)?.toDouble();
      final futureBillingCycle = data['future_billing_cycle'] as String?;

      return TrapResult(
        isTrap: true,
        trapType: trapType,
        severity: severity,
        scenario: scenario,
        trialPrice: currentPrice,
        trialDurationDays: (data['trial_duration_days'] as num?)?.toInt(),
        realPrice: futurePrice,
        realBillingCycle: futureBillingCycle,
        realAnnualCost: (data['real_annual_cost'] as num?)?.toDouble(),
        confidence: data['confidence'] as int? ?? 0,
        warningMessage: data['warning_message'] as String? ?? '',
        serviceName: '',
      );
    } catch (e, st) {
      ErrorLogger.log(event: 'ai_api_error', detail: 'parseTextTrapResult: $e', stackTrace: st.toString());
      return TrapResult.clean;
    }
  }

  // ─── Text-specific prompts ───

  /// Text-based extraction prompt — adapted from [_extractionPromptFor] for pasted text.
  static String _textExtractionPromptFor(String langCode) => '''
${_langInstruction(langCode)}
Today's date is ${DateTime.now().toIso8601String().substring(0, 10)}.

Analyse the following text carefully. It may be from:
- A subscription confirmation email
- A payment confirmation or receipt
- A renewal notice or billing reminder
- Terms and conditions for a subscription service

TASK 1 — SUBSCRIPTION EXTRACTION:
Find any subscription or recurring payment services and extract:
- service_name: the actual product/service name (e.g. "Netflix", "ScreenPal", "Claude Pro")
- price: numeric only, no currency symbol. This is the CURRENT price the user pays or will pay at the NEXT renewal. For intro/promotional pricing, use the intro price (not the future full price). If price is NOT visible, set to null.
- currency: ISO 4217 code (GBP, USD, EUR, PLN, etc). Infer from symbols, language, or context.
- billing_cycle: "weekly" | "monthly" | "quarterly" | "yearly". Infer from context if not explicit.
- next_renewal: ISO date string — the NEXT date the user will be charged ANY amount. NOT the date the price changes. If in an intro period with multiple charges before the full price, use the next billing date at the current price. Example: "£3.49/month for 2 months then £6.99 starting Mar 28" purchased Jan 29 → next_renewal = "2026-02-28".
- is_trial: boolean
- trial_end_date: ISO date string — when the intro/trial period ENDS and full price begins. Different from next_renewal when there are billing dates during the intro period.
- category: one of "streaming", "music", "ai", "productivity", "storage", "fitness", "gaming", "reading", "communication", "news", "finance", "education", "vpn", "developer", "bundle", "other"
- icon: first letter or short identifier (1-2 chars)
- brand_color: hex colour code for the brand
- source_type: "email" | "receipt" | "other"
- is_expiring: boolean — true if the subscription says "Expires" (already cancelled). false if it says "Renews" (active).

DATE INFERENCE — CRITICAL:
- ALL dates you return for next_renewal and trial_end_date MUST be in the future (today or later). NEVER return a past date.
- When a date has NO year, assume the NEXT future occurrence from today's date.
- When a date HAS a year but is in the PAST, roll it forward by the billing cycle until it is in the future.

IMPORTANT RULES:
1. If a field is NOT visible in the text, set it to null. Do NOT guess or default to 0.
2. For service_name: use the real product name. "Claude Pro" not "Anthropic".
3. For billing_cycle: NEVER blindly default to "monthly". Reason about the cycle.
4. If you find a service name but not a price, still return the service with price as null.
5. If you genuinely cannot find ANY subscription info, return service_name as "Unknown" with overall_confidence 0.0.
6. Set confidence per field: 1.0 if clearly stated, 0.5 if inferred, 0.0 if not found.

ALSO INCLUDE:
- missing_fields: array of field names that could not be found
- extraction_notes: brief explanation of what you found and what's missing (max 2 sentences)

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
    "is_expiring": boolean,
    "confidence": { "name": 0.0, "price": 0.0, "cycle": 0.0, "currency": 0.0 },
    "overall_confidence": 0.0,
    "tier": 1,
    "missing_fields": ["string"],
    "extraction_notes": "string"
  }
}

If no subscription is detected at all, return service_name "Unknown" with overall_confidence 0.
Return ONLY valid JSON, no markdown, no explanation.
''';

  /// Text-based trap detection prompt — adapted from [_trapScanPrompt] for pasted text.
  static String _textTrapScanPromptFor(String langCode) => '''
${_langInstruction(langCode)}
You are a subscription trap detector. Your ONLY job is to carefully read ALL the text below — especially fine print, terms, footnotes, and conditions — and identify subscription dark patterns that could cost the user money.

READ EVERY WORD in the text, including:
- Fine print and terms
- Asterisk footnotes
- Any conditions that seem intentionally hard to notice

IMPORTANT — NOT EVERYTHING IS A TRAP:
- A renewal email that clearly states the price, gives advance notice, and provides a cancellation link is NOT a trap. This is normal, transparent business practice.
- Auto-renewal alone is NOT a trap if the price is clearly stated and cancellation is easy.
- Only flag something as a trap if there is genuine deception, hidden information, friction designed to prevent cancellation, or a price change the user might not notice.
- If the text shows a straightforward renewal at the same price with clear terms, return has_traps: false.

TRAP CATEGORIES TO CHECK:

1. AUTO-RENEWAL TRAP: Free trial or intro period that automatically converts to a paid subscription.
2. PRICE HIKE TRAP: Introductory/promotional price that increases after a period.
3. CANCELLATION FEE TRAP: Fee charged for cancelling the subscription.
4. CANCELLATION WINDOW TRAP: Narrow window to cancel before being charged.
5. PRICE ADJUSTMENT TRAP: Company reserves the right to change prices.
6. HIDDEN AUTO-RENEWAL: Auto-renewal terms buried in fine print.

IMPORTANT: Determine the SCENARIO first:
- "trial_to_paid": Text shows a free/cheap trial that converts to a higher paid price
- "renewal_notice": Text shows an existing subscription about to auto-renew at the SAME price
- "price_increase": Text shows a subscription renewing at a HIGHER price than before
- "new_signup": Text shows a new subscription signup
- "other": Anything else

For "renewal_notice": current_price = the renewal amount, future_price = same amount, trial_duration_days = null
For "trial_to_paid": current_price = what the user pays during the intro/trial period (0 for free trial, or the reduced intro price e.g. 3.49), future_price = full price after the trial/intro period ends. Set current_price accurately — if the user pays a reduced but non-zero amount during the intro period, set current_price to that amount (NOT 0).
For "price_increase": current_price = current price, future_price = new higher price

IMPORTANT DISTINCTION — FREE TRIAL vs INTRO PRICE:
- A FREE TRIAL is when current_price = 0 (user pays nothing initially).
- An INTRO PRICE is when current_price > 0 but less than future_price (user pays a reduced amount initially).
- Do NOT call an intro price a "trial" in warning_message if the user is charged from day one.
- In warning_message: for free trials say "free trial converts to..."; for intro pricing say "introductory price of X increases to Y after Z months".

RESPOND WITH VALID JSON ONLY (no markdown, no backticks):
{
  "has_traps": boolean,
  "worst_severity": "low" | "medium" | "high",
  "worst_type": "trial_bait" | "price_framing" | "hidden_renewal" | "cancel_friction" | null,
  "scenario": "trial_to_paid" | "renewal_notice" | "price_increase" | "new_signup" | "other",
  "current_price": number or null,
  "current_billing_cycle": "weekly" | "monthly" | "yearly" | null,
  "future_price": number or null,
  "future_billing_cycle": "weekly" | "monthly" | "yearly" | null,
  "trial_duration_days": number or null,
  "real_annual_cost": number or null,
  "confidence": number (0-100),
  "traps_found": [
    {
      "type": "string",
      "severity": "low" | "medium" | "high",
      "detail": "one sentence explaining the trap"
    }
  ],
  "warning_message": "plain English summary of ALL traps found, max 3 sentences. Be specific with numbers and dates."
}

SEVERITY GUIDE:
- "low": Standard auto-renewal with clear terms, or minor price adjustment clause
- "medium": Price increase 1.5-3x after intro period, or cancellation restrictions
- "high": Price jump >3x, cancellation fees, very narrow cancel windows, or multiple traps combined

If no traps are found, return has_traps: false, worst_severity: "low", traps_found: [], warning_message: null.
Return ONLY valid JSON, no markdown, no explanation.
''';

  static String _trapScanPromptFor(String langCode) => '''
${_langInstruction(langCode)}
You are a subscription trap detector. Your ONLY job is to carefully read ALL text in this image — especially fine print, terms, footnotes, and small text — and identify subscription dark patterns that could cost the user money.

READ EVERY WORD in the image, including:
- Fine print at the bottom
- Terms and conditions text
- Asterisk footnotes
- Grey or light-coloured small text
- Any text that seems intentionally hard to read

IMPORTANT — NOT EVERYTHING IS A TRAP:
- A renewal email that clearly states the price, gives advance notice, and provides a cancellation link is NOT a trap. This is normal, transparent business practice.
- Auto-renewal alone is NOT a trap if the price is clearly stated and cancellation is easy.
- Only flag something as a trap if there is genuine deception, hidden information, friction designed to prevent cancellation, or a price change the user might not notice.
- If the image shows a straightforward renewal at the same price with clear terms, return has_traps: false.

TRAP CATEGORIES TO CHECK:

1. AUTO-RENEWAL TRAP: Free trial or intro period that automatically converts to a paid subscription. Look for "automatically renews", "will be charged", "converts to paid".

2. PRICE HIKE TRAP: Introductory/promotional price that increases after a period. Look for "introductory rate", "for the first X months", "standard rate", "regular price", any mention of TWO different prices.

3. CANCELLATION FEE TRAP: Fee charged for cancelling the subscription. Look for "cancellation fee", "early termination", "cancellation charge".

4. CANCELLATION WINDOW TRAP: Narrow window to cancel before being charged. Look for "X hours before", "X days before billing", "must cancel by". Normal is "cancel anytime" — anything with a deadline is a trap.

5. PRICE ADJUSTMENT TRAP: Company reserves the right to change prices. Look for "prices may change", "adjusted annually", "subject to change".

6. HIDDEN AUTO-RENEWAL: Auto-renewal terms buried in fine print or not clearly stated alongside the price.

IMPORTANT: Determine the SCENARIO first:
- "trial_to_paid": Image shows a free/cheap trial that converts to a higher paid price
- "renewal_notice": Image shows an existing subscription about to auto-renew at the SAME price
- "price_increase": Image shows a subscription renewing at a HIGHER price than before
- "new_signup": Image shows a new subscription signup page
- "other": Anything else

For "renewal_notice": current_price = the renewal amount, future_price = same amount, trial_duration_days = null
For "trial_to_paid": current_price = what the user pays during the intro/trial period (0 for free trial, or the reduced intro price e.g. 3.49), future_price = full price after the trial/intro period ends. Set current_price accurately — if the user pays a reduced but non-zero amount during the intro period, set current_price to that amount (NOT 0).
For "price_increase": current_price = current price, future_price = new higher price

IMPORTANT DISTINCTION — FREE TRIAL vs INTRO PRICE:
- A FREE TRIAL is when current_price = 0 (user pays nothing initially).
- An INTRO PRICE is when current_price > 0 but less than future_price (user pays a reduced amount initially).
- Do NOT call an intro price a "trial" in warning_message if the user is charged from day one.
- In warning_message: for free trials say "free trial converts to..."; for intro pricing say "introductory price of X increases to Y after Z months".

RESPOND WITH VALID JSON ONLY (no markdown, no backticks):
{
  "has_traps": boolean,
  "worst_severity": "low" | "medium" | "high",
  "worst_type": "trial_bait" | "price_framing" | "hidden_renewal" | "cancel_friction" | null,
  "scenario": "trial_to_paid" | "renewal_notice" | "price_increase" | "new_signup" | "other",
  "current_price": number or null,
  "current_billing_cycle": "weekly" | "monthly" | "yearly" | null,
  "future_price": number or null,
  "future_billing_cycle": "weekly" | "monthly" | "yearly" | null,
  "trial_duration_days": number or null,
  "real_annual_cost": number or null,
  "confidence": number (0-100),
  "traps_found": [
    {
      "type": "string",
      "severity": "low" | "medium" | "high",
      "detail": "one sentence explaining the trap"
    }
  ],
  "warning_message": "plain English summary of ALL traps found, max 3 sentences. Be specific with numbers and dates."
}

SEVERITY GUIDE:
- "low": Standard auto-renewal with clear terms, or minor price adjustment clause
- "medium": Price increase 1.5-3x after intro period, or cancellation restrictions
- "high": Price jump >3x, cancellation fees, very narrow cancel windows, or multiple traps combined

If no traps are found, return has_traps: false, worst_severity: "low", traps_found: [], warning_message: null.
Return ONLY valid JSON, no markdown, no explanation.
''';
}

/// Parameters for JPEG encoding in an isolate via [compute].
class _EncodeParams {
  final img.Image image;
  final int quality;
  const _EncodeParams(this.image, this.quality);
}

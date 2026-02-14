import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/sync_service.dart';

const _kLocaleKey = 'user_locale';

/// Supported app languages.
const supportedLanguages = [
  {'code': 'en', 'name': 'English', 'native': 'English'},
  {'code': 'pl', 'name': 'Polish', 'native': 'Polski'},
];

/// Detect language from device locale.
/// Falls back to English if unsupported.
Locale _detectLocaleFromDevice() {
  try {
    final localeName = Platform.localeName; // e.g. "en_GB", "pl_PL"
    final lang = localeName.split(RegExp('[_-]')).first.toLowerCase();

    final supported = supportedLanguages.map((l) => l['code']).toSet();
    final detected = supported.contains(lang) ? lang : 'en';

    debugPrint('[LocaleProvider] Device locale: $localeName -> lang: $lang -> $detected');
    return Locale(detected);
  } catch (_) {
    return const Locale('en');
  }
}

/// User's preferred display language.
///
/// On first launch, auto-detects from device locale.
/// Persisted to SharedPreferences.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLocaleKey);
    if (saved != null) {
      state = Locale(saved);
    } else {
      // First launch: detect from device and persist
      final detected = _detectLocaleFromDevice();
      state = detected;
      await prefs.setString(_kLocaleKey, detected.languageCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
    SyncService.instance.syncProfile(locale: locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

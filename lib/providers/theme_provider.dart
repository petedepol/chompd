import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode options for the app.
enum AppThemeMode { system, dark, light }

/// Persists and provides the user's chosen theme mode.
class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  static const _key = 'chompd_theme_mode';

  ThemeModeNotifier() : super(AppThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'dark') {
      state = AppThemeMode.dark;
    } else if (value == 'light') {
      state = AppThemeMode.light;
    } else if (value == 'system') {
      state = AppThemeMode.system;
    }
    // Default stays dark — first launch shows dark theme.
    // Users can switch to light or system in Settings → Theme.
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  /// Convert to Flutter's [ThemeMode].
  ThemeMode get flutterThemeMode {
    switch (state) {
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Provider for theme mode.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  return ThemeModeNotifier();
});

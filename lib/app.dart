import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/generated/app_localizations.dart';

import 'config/theme.dart';
import 'providers/locale_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/detail/add_edit_screen.dart';
import 'screens/scan/scan_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'utils/share_handler.dart';

const _kOnboardingSeenKey = 'onboarding_seen';

/// Global navigator key — used by ShareHandler to push routes
/// when images arrive via the OS Share Sheet.
final navigatorKey = GlobalKey<NavigatorState>();

/// Root application widget.
class ChompdApp extends ConsumerWidget {
  const ChompdApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Chompd',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ChompdTheme.dark,
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      home: const _AppEntry(),
    );
  }
}

/// Controls the splash → onboarding → home flow.
///
/// Checks SharedPreferences to skip onboarding on return visits.
class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

enum _AppPhase { splash, onboarding, home }

class _AppEntryState extends State<_AppEntry> {
  _AppPhase _phase = _AppPhase.splash;
  bool? _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    _initShareHandler();
  }

  @override
  void dispose() {
    ShareHandler.instance.dispose();
    super.dispose();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSeenOnboarding = prefs.getBool(_kOnboardingSeenKey) ?? false;
    });
  }

  void _initShareHandler() {
    // Defer to next frame so the widget tree is built and
    // ProviderScope is available via context.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final container = ProviderScope.containerOf(context);
      ShareHandler.instance.init(
        navigatorKey: navigatorKey,
        container: container,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _buildPhase(),
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      case _AppPhase.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onComplete: () {
            setState(() {
              // Skip onboarding if already seen
              _phase = (_hasSeenOnboarding == true)
                  ? _AppPhase.home
                  : _AppPhase.onboarding;
            });
          },
        );
      case _AppPhase.onboarding:
        return OnboardingScreen(
          key: const ValueKey('onboarding'),
          onComplete: ({bool openScan = false, bool openManualAdd = false}) async {
            // Persist the "seen" flag
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_kOnboardingSeenKey, true);
            if (mounted) {
              setState(() => _phase = _AppPhase.home);
              // If user tapped "Scan a Screenshot", open scan screen
              if (openScan) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  navigatorKey.currentState?.push(
                    MaterialPageRoute(builder: (_) => const ScanScreen()),
                  );
                });
              }
              // If user tapped "Add Manually", open add subscription screen
              if (openManualAdd) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  navigatorKey.currentState?.push(
                    MaterialPageRoute(builder: (_) => const AddEditScreen()),
                  );
                });
              }
            }
          },
        );
      case _AppPhase.home:
        return const HomeScreen(
          key: ValueKey('home'),
        );
    }
  }
}

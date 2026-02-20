import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/generated/app_localizations.dart';

import 'config/theme.dart';
import 'providers/entitlement_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/service_cache_provider.dart';
import 'providers/theme_provider.dart';
import 'services/service_sync_service.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/scan/scan_screen.dart';
import 'screens/trial/trial_prompt_screen.dart';
import 'screens/trial/trial_expired_screen.dart';
import 'widgets/quick_add_sheet.dart';
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
    // Watch the state value so the widget rebuilds on theme changes.
    final appThemeMode = ref.watch(themeModeProvider);
    final themeMode = switch (appThemeMode) {
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.system => ThemeMode.system,
    };

    return MaterialApp(
      title: 'Chompd',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ChompdTheme.light,
      darkTheme: ChompdTheme.dark,
      themeMode: themeMode,
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

class _AppEntryState extends State<_AppEntry> with WidgetsBindingObserver {
  _AppPhase _phase = _AppPhase.splash;
  bool? _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkOnboardingStatus();
    _initShareHandler();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ShareHandler.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _phase == _AppPhase.home) {
      // Recheck trial expiry on app resume
      final container = ProviderScope.containerOf(context);
      container.read(entitlementProvider.notifier).recheck();

      // If trial just expired, show the expired screen once
      _checkTrialExpired();
    }
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSeenOnboarding = prefs.getBool(_kOnboardingSeenKey) ?? false;
    });
  }

  /// Show the trial prompt if the user has never trialed and hasn't seen it.
  Future<void> _checkTrialPrompt() async {
    final container = ProviderScope.containerOf(context);
    final ent = container.read(entitlementProvider);
    if (ent.isPro) return; // Already Pro

    final hasTrialed = await container.read(entitlementProvider.notifier).hasEverTrialed();
    if (hasTrialed) return; // Already trialed (active or expired)

    final shown = await hasTrialPromptBeenShown();
    if (shown) return; // Already shown

    if (!mounted) return;
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      TrialPromptScreen.show(ctx);
    }
  }

  /// Show the trial expired screen once when trial expires.
  Future<void> _checkTrialExpired() async {
    final container = ProviderScope.containerOf(context);
    final ent = container.read(entitlementProvider);
    if (!ent.isTrialExpired) return;
    if (ent.isPro) return;

    final shown = await hasTrialExpiredBeenShown();
    if (shown) return;

    if (!mounted) return;
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      TrialExpiredScreen.show(ctx);
    }
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

      // Refresh the in-memory service cache after service sync completes.
      // Without this, scanner-added subs won't match against the service DB
      // on first launch (cache loads from empty Isar before sync writes).
      ServiceSyncService.instance.onSyncComplete = () {
        container.read(serviceCacheProvider.notifier).refresh();
      };
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
            // For returning users going straight to home, check trial expired
            if (_hasSeenOnboarding == true) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _checkTrialExpired();
              });
            }
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
              // Show trial prompt after home screen is built
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _checkTrialPrompt();
              });
              // If user tapped "Scan a Screenshot", open scan screen
              if (openScan) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  navigatorKey.currentState?.push(
                    MaterialPageRoute(builder: (_) => const ScanScreen()),
                  );
                });
              }
              // If user tapped "Add Manually", open quick-add sheet
              if (openManualAdd) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final ctx = navigatorKey.currentContext;
                  if (ctx != null) {
                    showQuickAddSheet(ctx);
                  }
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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/splash/splash_screen.dart';

const _kOnboardingSeenKey = 'onboarding_seen';

/// Root application widget.
class ChompdApp extends StatelessWidget {
  const ChompdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chompd',
      debugShowCheckedModeBanner: false,
      theme: ChompdTheme.dark,
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
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSeenOnboarding = prefs.getBool(_kOnboardingSeenKey) ?? false;
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
          onComplete: () async {
            // Persist the "seen" flag
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_kOnboardingSeenKey, true);
            if (mounted) {
              setState(() => _phase = _AppPhase.home);
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

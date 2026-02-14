import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../utils/l10n_extension.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconOpacity;
  late Animation<double> _iconScale;
  late Animation<double> _textOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<double> _fadeOutOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Icon fade in and scale: 0-600ms
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
      ),
    );

    _iconScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
      ),
    );

    // Text fade in: 400-1000ms
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // Tagline fade in: 600-1200ms
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Fade out everything: 1800-2000ms
    _fadeOutOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.9, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Center(
        child: Opacity(
          opacity: _fadeOutOpacity.value,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Opacity(
                opacity: _iconOpacity.value,
                child: Transform.scale(
                  scale: _iconScale.value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/mascot/piranha_icon.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // App Name
              Opacity(
                opacity: _textOpacity.value,
                child: Text(
                  context.l10n.appName,
                  style: ChompdTypography.mono(
                    size: 28,
                    weight: FontWeight.w700,
                    color: c.text,
                  ).copyWith(
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Tagline
              Opacity(
                opacity: _taglineOpacity.value,
                child: Text(
                  context.l10n.tagline,
                  style: ChompdTypography.mono(
                    size: 12,
                    color: c.textDim,
                  ).copyWith(
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/subscription.dart';
import '../services/haptic_service.dart';
import '../utils/l10n_extension.dart';
import 'confetti_overlay.dart';
import 'mascot_image.dart';

/// Full-screen celebration overlay shown after cancelling a subscription.
///
/// Shows confetti, the savings amount, and a motivational message.
/// Auto-dismisses after 4 seconds or on tap.
class CancelCelebration extends StatefulWidget {
  final Subscription subscription;
  final VoidCallback onDismiss;

  const CancelCelebration({
    super.key,
    required this.subscription,
    required this.onDismiss,
  });

  @override
  State<CancelCelebration> createState() => _CancelCelebrationState();
}

class _CancelCelebrationState extends State<CancelCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    HapticService.instance.success();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) widget.onDismiss();
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
    final yearly = widget.subscription.yearlyEquivalent;
    final currency = widget.subscription.currency;

    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Confetti
            const Positioned.fill(
              child: ConfettiOverlay(),
            ),

            // Content — centred with safe area padding
            SafeArea(
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Celebrate mascot
                        const MascotImage(
                          asset: 'piranha_celebrate.png',
                          size: 80,
                        ),
                        const SizedBox(height: 24),

                        // Headline
                        Text(
                          context.l10n.celebrationTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: c.text,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Savings amount
                        Text(
                          context.l10n.celebrationSavePerYear(Subscription.formatPrice(yearly, currency, decimals: 0)),
                          textAlign: TextAlign.center,
                          style: ChompdTypography.mono(
                            size: 24,
                            weight: FontWeight.w700,
                            color: c.mint,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          context.l10n.celebrationByDropping(widget.subscription.name),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: c.textMid,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Tap to dismiss hint
                        Text(
                          context.l10n.tapAnywhereToContinue,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

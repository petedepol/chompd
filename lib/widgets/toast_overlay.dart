import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/scan_result.dart';
import '../models/subscription.dart';
import '../utils/l10n_extension.dart';

/// Toast notification overlay for scan confirmations.
///
/// Shows a slide-up toast with service icon, name, price, and
/// an animated checkmark. Auto-dismisses after 3 seconds.
class ScanToast extends StatefulWidget {
  final ScanResult result;
  final VoidCallback? onDismissed;

  const ScanToast({
    super.key,
    required this.result,
    this.onDismissed,
  });

  @override
  State<ScanToast> createState() => _ScanToastState();
}

class _ScanToastState extends State<ScanToast>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _checkController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Slide in animation
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    );

    // Checkmark draw animation
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Start animations
    _slideController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _checkController.forward();
      });
    });

    // Auto-dismiss after 2800ms
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        _slideController.reverse().then((_) {
          widget.onDismissed?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  Color get _brandColor {
    final hex = widget.result.brandColor?.replaceFirst('#', '') ?? '6EE7B7';
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final r = widget.result;
    final isWarning = r.isTrial;
    final glowColor = isWarning ? c.amber : c.mint;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: c.bgElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: glowColor.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Brand icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      _brandColor.withValues(alpha: 0.87),
                      _brandColor.withValues(alpha: 0.53),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  r.iconName ?? r.serviceName[0],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Service name + price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      r.serviceName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${Subscription.formatPrice(r.price ?? 0, r.currency)}/${switch (r.billingCycle) {
                            'yearly' => context.l10n.cycleYearlyShort,
                            'weekly' => context.l10n.cycleWeeklyShort,
                            'quarterly' => context.l10n.cycleQuarterlyShort,
                            _ => context.l10n.cycleMonthlyShort,
                          }}',
                          style: ChompdTypography.mono(
                            size: 12,
                            weight: FontWeight.w700,
                            color: c.textMid,
                          ),
                        ),
                        if (isWarning) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: c.amberGlow,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              context.l10n.trialLabel,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: c.amber,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Animated checkmark
              AnimatedBuilder(
                animation: _checkController,
                builder: (context, child) {
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: glowColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: CustomPaint(
                      painter: _CheckmarkPainter(
                        progress: _checkController.value,
                        color: glowColor,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for animated checkmark draw.
class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Checkmark path: starts bottom-left, goes to bottom-center, then up-right
    final p1 = Offset(cx - 6, cy);
    final p2 = Offset(cx - 1, cy + 5);
    final p3 = Offset(cx + 7, cy - 5);

    if (progress <= 0.5) {
      // Draw first stroke (down)
      final t = progress / 0.5;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(
        p1.dx + (p2.dx - p1.dx) * t,
        p1.dy + (p2.dy - p1.dy) * t,
      );
    } else {
      // Draw first stroke complete + second stroke (up)
      final t = (progress - 0.5) / 0.5;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(
        p2.dx + (p3.dx - p2.dx) * t,
        p2.dy + (p3.dy - p2.dy) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter old) => old.progress != progress;
}

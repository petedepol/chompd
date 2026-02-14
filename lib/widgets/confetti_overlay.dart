import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Lightweight confetti burst animation using CustomPainter.
///
/// Triggers on savings milestones. No Lottie dependency —
/// pure Flutter particles with gravity + spin.
class ConfettiOverlay extends StatefulWidget {
  final VoidCallback? onComplete;

  const ConfettiOverlay({super.key, this.onComplete});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = math.Random();

  List<Color> get _colors {
    final c = context.colors;
    return [
      c.mint,
      c.amber,
      c.purple,
      c.blue,
      c.pink,
      const Color(0xFFF87171),
      const Color(0xFF34D399),
      const Color(0xFF818CF8),
    ];
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Generate particles here where context is available
    if (!_controller.isAnimating && _controller.value == 0) {
      final colors = _colors;
      _particles = List.generate(60, (_) => _Particle(
        x: _random.nextDouble(),
        y: -0.1 - _random.nextDouble() * 0.3,
        vx: (_random.nextDouble() - 0.5) * 0.012,
        vy: _random.nextDouble() * 0.008 + 0.003,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.15,
        size: _random.nextDouble() * 6 + 3,
        color: colors[_random.nextInt(colors.length)],
        shape: _random.nextInt(3), // 0 = rect, 1 = circle, 2 = strip
      ));
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  double x, y, vx, vy;
  double rotation, rotationSpeed;
  double size;
  Color color;
  int shape;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final fadeOut = progress > 0.7
        ? 1.0 - ((progress - 0.7) / 0.3)
        : 1.0;

    for (final p in particles) {
      final currentX = (p.x + p.vx * progress * 100) * size.width;
      // Gravity: accelerate downward
      final gravity = 0.5 * 0.0004 * (progress * 100) * (progress * 100);
      final currentY = (p.y + p.vy * progress * 100 + gravity) * size.height;
      final currentRotation = p.rotation + p.rotationSpeed * progress * 100;

      if (currentY > size.height * 1.2) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: fadeOut * 0.85)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation);

      switch (p.shape) {
        case 0: // Rectangle
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
            paint,
          );
          break;
        case 1: // Circle
          canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
          break;
        case 2: // Strip
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: p.size * 1.5, height: p.size * 0.25),
            paint,
          );
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Sweeping light shimmer animation shown over a screenshot
/// while AI is analysing it.
///
/// Creates a 1.8s looping gradient sweep from left to right,
/// matching the design prototype's scan effect.
class ScanShimmer extends StatefulWidget {
  /// The screenshot image to show the shimmer over.
  final Widget child;

  /// Whether the shimmer animation is active.
  final bool isActive;

  const ScanShimmer({
    super.key,
    required this.child,
    this.isActive = true,
  });

  @override
  State<ScanShimmer> createState() => _ScanShimmerState();
}

class _ScanShimmerState extends State<ScanShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.isActive) _controller.repeat();
  }

  @override
  void didUpdateWidget(ScanShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Stack(
      children: [
        widget.child,
        if (widget.isActive)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final position = _controller.value;
                return ShaderMask(
                  blendMode: BlendMode.srcOver,
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment(-1.0 + 2.0 * position, 0),
                      end: Alignment(-0.5 + 2.0 * position, 0),
                      colors: [
                        Colors.transparent,
                        c.purple.withValues(alpha: 0.08),
                        c.mint.withValues(alpha: 0.12),
                        c.purple.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                    ).createShader(bounds);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Typing dots indicator — three dots pulsing in sequence.
///
/// Used to show "AI is thinking" during the scan phase.
class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final activeDot = (_controller.value * 3).floor() % 3;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: c.purple.withValues(alpha:
                  i == activeDot ? 1.0 : 0.3,
                ),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

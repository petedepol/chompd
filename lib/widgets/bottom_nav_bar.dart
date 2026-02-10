import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/haptic_service.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onScanTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.onScanTap,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _specularController;
  late AnimationController _orbController;
  late AnimationController _tabGlowController;
  late AnimationController _scanTapController;

  @override
  void initState() {
    super.initState();

    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    )..repeat();

    _specularController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _orbController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _tabGlowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _scanTapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _specularController.dispose();
    _orbController.dispose();
    _tabGlowController.dispose();
    _scanTapController.dispose();
    super.dispose();
  }

  void _onScanTap() {
    HapticService.instance.light();
    _scanTapController.forward().then((_) {
      _scanTapController.reverse();
    });
    widget.onScanTap();
  }

  void _onTabTap(int index) {
    HapticService.instance.selection();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gradient fade above bar
        IgnorePointer(
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF07070C).withValues(alpha: 0.4),
                  const Color(0xFF07070C),
                ],
                stops: const [0, 0.35, 1.0],
              ),
            ),
          ),
        ),
        // Glass bar + floating FAB
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 22,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Glass bar
              ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Stack(
                    children: [
                      // Ambient orbs (behind content)
                      _buildAmbientOrbs(),
                      // Glass background
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.035),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.07),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Tab content
                      _buildNavContent(),
                    ],
                  ),
                ),
              ),
              // Scan FAB (floating above bar)
              _buildScanFab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmbientOrbs() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Orb 1: Mint, left position
          Positioned(
            left: 60,
            top: 10,
            child: AnimatedBuilder(
              animation: _orbController,
              builder: (context, child) {
                final offset = Offset(
                  math.sin(_orbController.value * 2 * math.pi) * 12,
                  math.cos(_orbController.value * 2 * math.pi) * 8,
                );
                return Transform.translate(
                  offset: offset,
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF6EE7B7).withValues(alpha: 0.05),
                          const Color(0xFF6EE7B7).withValues(alpha: 0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: CustomPaint(
                      painter: _OrbBlurPainter(
                        color: const Color(0xFF6EE7B7),
                        blur: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Orb 2: Purple, right position
          Positioned(
            right: 50,
            bottom: 15,
            child: AnimatedBuilder(
              animation: _orbController,
              builder: (context, child) {
                final offset = Offset(
                  math.cos(_orbController.value * 2 * math.pi) * 10,
                  math.sin(_orbController.value * 2 * math.pi) * 6,
                );
                return Transform.translate(
                  offset: offset,
                  child: Container(
                    width: 60,
                    height: 35,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFA78BFA).withValues(alpha: 0.04),
                          const Color(0xFFA78BFA).withValues(alpha: 0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: CustomPaint(
                      painter: _OrbBlurPainter(
                        color: const Color(0xFFA78BFA),
                        blur: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavContent() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            // Subs tab
            Expanded(
              child: _buildTabButton(
                index: 0,
                icon: _buildCardStackIcon(isActive: widget.currentIndex == 0),
                label: 'SUBS',
              ),
            ),
            // Spacer for FAB
            const SizedBox(width: 56),
            // Saved tab
            Expanded(
              child: _buildTabButton(
                index: 2,
                icon: _buildShieldIcon(isActive: widget.currentIndex == 2),
                label: 'SAVED',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required Widget icon,
    required String label,
  }) {
    final isActive = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          icon,
          const SizedBox(height: 4),
          // Label
          Text(
            label,
            style: ChompdTypography.mono(
              size: 7.5,
              weight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive
                  ? ChompdColors.mint
                  : ChompdColors.textDim,
            ),
          ),
          const SizedBox(height: 3),
          // Active indicator
          if (isActive)
            AnimatedScale(
              scale: 1,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 14,
                height: 2.5,
                decoration: BoxDecoration(
                  color: ChompdColors.mint,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: ChompdColors.mint.withValues(alpha: 0.37),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            )
          else
            const SizedBox(height: 2.5),
        ],
      ),
    );
  }

  Widget _buildCardStackIcon({required bool isActive}) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.4,
      child: Image.asset(
        'assets/nav_icons/nav_subs.png',
        width: 28,
        height: 28,
      ),
    );
  }

  Widget _buildShieldIcon({required bool isActive}) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.4,
      child: Image.asset(
        'assets/nav_icons/nav_saved.png',
        width: 28,
        height: 28,
      ),
    );
  }

  Widget _buildScanFab() {
    return GestureDetector(
      onTap: _onScanTap,
      child: AnimatedBuilder(
        animation: _scanTapController,
        builder: (context, child) {
          final scale = 1 - (_scanTapController.value * 0.1);
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Transform.translate(
          offset: const Offset(0, -26),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF34D399).withValues(alpha: 0.93),
                  const Color(0xFF6EE7B7).withValues(alpha: 0.87),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Breathing glow shadow
                AnimatedBuilder(
                  animation: _breatheController,
                  builder: (context, child) {
                    final glowStrength =
                        math.sin(_breatheController.value * 2 * math.pi) *
                                0.5 +
                            0.5;
                    final blurRadius =
                        20 + (glowStrength * 12); // 20 to 32
                    final yOffset = 6 + (glowStrength * 2); // 6 to 8
                    final opacity = 0.25 + (glowStrength * 0.2); // 0.25 to 0.45

                    return Positioned.fill(
                      child: CustomPaint(
                        painter: _GlowShadowPainter(
                          color: ChompdColors.mint,
                          blurRadius: blurRadius,
                          yOffset: yOffset,
                          opacity: opacity,
                        ),
                      ),
                    );
                  },
                ),
                // Specular sweep animation
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedBuilder(
                    animation: _specularController,
                    builder: (context, child) {
                      final sweepX = -56 * 0.3 +
                          (56 * 1.6) * _specularController.value;
                      return Transform.translate(
                        offset: Offset(sweepX, 0),
                        child: Transform.rotate(
                          angle: 25 * math.pi / 180,
                          child: Container(
                            width: 56 * 0.3,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Static specular highlight
                Positioned(
                  top: 3,
                  left: 7,
                  right: 7,
                  height: 14,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Camera icon
                Center(
                  child: Image.asset(
                    'assets/nav_icons/nav_scan.png',
                    width: 28,
                    height: 28,
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

// MARK: - CustomPainters

class _OrbBlurPainter extends CustomPainter {
  final Color color;
  final double blur;

  _OrbBlurPainter({
    required this.color,
    required this.blur,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.01)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    canvas.drawOval(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_OrbBlurPainter oldDelegate) => false;
}

class _GlowShadowPainter extends CustomPainter {
  final Color color;
  final double blurRadius;
  final double yOffset;
  final double opacity;

  _GlowShadowPainter({
    required this.color,
    required this.blurRadius,
    required this.yOffset,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // This is just a placeholder; the actual shadow is handled by
    // the Container's decoration. This painter can be removed or used
    // for custom glow effects.
  }

  @override
  bool shouldRepaint(_GlowShadowPainter oldDelegate) =>
      oldDelegate.blurRadius != blurRadius ||
      oldDelegate.yOffset != yOffset ||
      oldDelegate.opacity != opacity;
}

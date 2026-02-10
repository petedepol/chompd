import 'package:flutter/material.dart';

/// Reusable mascot image widget with standardised sizing and optional fade-in.
///
/// Centralises the asset path prefix (`assets/mascot/`) and provides
/// consistent rendering for both PNG and GIF mascot assets.
///
/// Usage:
/// ```dart
/// const MascotImage(asset: 'piranha_wave.png', size: 120, fadeIn: true)
/// ```
class MascotImage extends StatelessWidget {
  /// Asset filename without directory prefix (e.g. 'piranha_wave.png').
  final String asset;

  /// Display size (width and height — mascot images are roughly square).
  final double size;

  /// Whether to use a fade-in entrance animation.
  final bool fadeIn;

  /// Duration of the fade-in animation.
  final Duration fadeDuration;

  const MascotImage({
    super.key,
    required this.asset,
    this.size = 120,
    this.fadeIn = false,
    this.fadeDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/mascot/$asset',
      width: size,
      height: size,
      fit: BoxFit.contain,
      // Fade-in using frameBuilder — works for both PNG and GIF.
      // For GIFs, `frame` becomes non-null when the first frame decodes.
      frameBuilder: fadeIn
          ? (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: fadeDuration,
                curve: Curves.easeOut,
                child: child,
              );
            }
          : null,
    );
  }
}

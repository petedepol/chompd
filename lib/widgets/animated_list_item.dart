import 'package:flutter/material.dart';

/// List item wrapper — renders child directly.
///
/// Previously animated with fade + slide, but SliverList rebuild timing
/// caused cards to stay invisible. Now a simple pass-through.
class AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration staggerDelay;
  final Duration animationDuration;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.animationDuration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

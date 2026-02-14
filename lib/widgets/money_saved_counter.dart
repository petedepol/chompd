import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/subscription.dart';

/// Animated money saved counter with a number roll effect.
///
/// Displays the total savings from cancelled subscriptions
/// with a smooth counting animation.
class MoneySavedCounter extends StatefulWidget {
  final double amount;
  final String currencyCode;

  const MoneySavedCounter({
    super.key,
    required this.amount,
    this.currencyCode = 'GBP',
  });

  @override
  State<MoneySavedCounter> createState() => _MoneySavedCounterState();
}

class _MoneySavedCounterState extends State<MoneySavedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _countAnimation = Tween<double>(begin: 0, end: widget.amount).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(MoneySavedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _countAnimation =
          Tween<double>(begin: oldWidget.amount, end: widget.amount).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
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
    return AnimatedBuilder(
      animation: _countAnimation,
      builder: (context, child) {
        return Text(
          Subscription.formatPrice(_countAnimation.value, widget.currencyCode, decimals: 0),
          style: ChompdTypography.mono(
            size: 14,
            weight: FontWeight.w700,
            color: c.mint,
          ),
        );
      },
    );
  }
}

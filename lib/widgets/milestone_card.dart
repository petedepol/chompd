import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/subscription.dart';
import '../utils/l10n_extension.dart';

/// Milestone definition for the savings gamification system.
class Milestone {
  final double amount;
  final String emoji;
  final String name;
  final String reward;

  const Milestone({
    required this.amount,
    required this.emoji,
    required this.name,
    required this.reward,
  });

  /// All savings milestones in ascending order.
  static const List<Milestone> all = [
    Milestone(amount: 50, emoji: '\u2615', name: 'Coffee Fund', reward: 'Confetti burst'),
    Milestone(amount: 100, emoji: '\uD83C\uDFAE', name: 'Game Pass', reward: 'Confetti + share'),
    Milestone(amount: 250, emoji: '\u2708\uFE0F', name: 'Weekend Away', reward: 'Confetti + badge'),
    Milestone(amount: 500, emoji: '\uD83D\uDCBB', name: 'New Gadget', reward: 'Confetti + badge'),
    Milestone(amount: 1000, emoji: '\uD83C\uDFDD\uFE0F', name: 'Dream Holiday', reward: 'Full celebration'),
  ];

  /// Unchompd milestone track — based on money saved from dodged traps.
  static const List<Milestone> trapMilestones = [
    Milestone(amount: 50, emoji: '\uD83E\uDE77', name: 'First Bite Back', reward: 'Confetti burst'),
    Milestone(amount: 100, emoji: '\uD83D\uDD0D', name: 'Chomp Spotter', reward: 'Confetti + share'),
    Milestone(amount: 250, emoji: '\u2694\uFE0F', name: 'Dark Pattern Destroyer', reward: 'Confetti + badge'),
    Milestone(amount: 500, emoji: '\uD83C\uDFF0', name: 'Subscription Sentinel', reward: 'Confetti + badge'),
    Milestone(amount: 1000, emoji: '\uD83D\uDC51', name: 'Unchompable', reward: 'Full celebration'),
  ];

  /// Get the current trap milestone for a trap savings amount.
  static Milestone? currentTrap(double trapSaved) {
    Milestone? reached;
    for (final m in trapMilestones) {
      if (trapSaved >= m.amount) reached = m;
    }
    return reached;
  }

  /// Get the next trap milestone to reach.
  static Milestone? nextTrap(double trapSaved) {
    for (final m in trapMilestones) {
      if (trapSaved < m.amount) return m;
    }
    return null;
  }

  /// Resolve a milestone's English name to a localised string.
  static String localizedName(BuildContext context, String name) {
    switch (name) {
      case 'Coffee Fund':
        return context.l10n.milestoneCoffeeFund;
      case 'Game Pass':
        return context.l10n.milestoneGamePass;
      case 'Weekend Away':
        return context.l10n.milestoneWeekendAway;
      case 'New Gadget':
        return context.l10n.milestoneNewGadget;
      case 'Dream Holiday':
        return context.l10n.milestoneDreamHoliday;
      case 'First Bite Back':
        return context.l10n.milestoneFirstBiteBack;
      case 'Chomp Spotter':
        return context.l10n.milestoneChompSpotter;
      case 'Dark Pattern Destroyer':
        return context.l10n.milestoneDarkPatternDestroyer;
      case 'Subscription Sentinel':
        return context.l10n.milestoneSubscriptionSentinel;
      case 'Unchompable':
        return context.l10n.milestoneUnchompable;
      default:
        return name;
    }
  }

  /// Get the current milestone for a savings amount.
  static Milestone? current(double saved) {
    Milestone? reached;
    for (final m in all) {
      if (saved >= m.amount) reached = m;
    }
    return reached;
  }

  /// Get the next milestone to reach.
  static Milestone? next(double saved) {
    for (final m in all) {
      if (saved < m.amount) return m;
    }
    return null;
  }

  /// Progress toward the next milestone (0.0 - 1.0).
  static double progress(double saved) {
    final nextM = next(saved);
    if (nextM == null) return 1.0;

    final currentM = current(saved);
    final base = currentM?.amount ?? 0;
    final range = nextM.amount - base;
    if (range == 0) return 1.0;
    return ((saved - base) / range).clamp(0.0, 1.0);
  }
}

/// Horizontal scrollable milestone progress cards.
class MilestoneTrack extends StatelessWidget {
  final double totalSaved;
  final String currencyCode;

  const MilestoneTrack({
    super.key,
    required this.totalSaved,
    this.currencyCode = 'GBP',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: Milestone.all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final milestone = Milestone.all[index];
          final isReached = totalSaved >= milestone.amount;
          final isCurrent = Milestone.current(totalSaved) == milestone;

          // Calculate fill for this specific milestone
          double fill;
          if (isReached) {
            fill = 1.0;
          } else {
            final prev = index > 0 ? Milestone.all[index - 1].amount : 0.0;
            final range = milestone.amount - prev;
            fill = range > 0
                ? ((totalSaved - prev) / range).clamp(0.0, 1.0)
                : 0.0;
          }

          return _MilestoneChip(
            milestone: milestone,
            isReached: isReached,
            isCurrent: isCurrent,
            fillProgress: fill,
            totalSaved: totalSaved,
            currencyCode: currencyCode,
          );
        },
      ),
    );
  }
}

class _MilestoneChip extends StatelessWidget {
  final Milestone milestone;
  final bool isReached;
  final bool isCurrent;
  final double fillProgress;
  final double totalSaved;
  final String currencyCode;

  const _MilestoneChip({
    required this.milestone,
    required this.isReached,
    required this.isCurrent,
    required this.fillProgress,
    required this.totalSaved,
    this.currencyCode = 'GBP',
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final remaining = (milestone.amount - totalSaved).clamp(0.0, milestone.amount);

    return Container(
      width: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isReached
            ? c.mint.withValues(alpha: 0.08)
            : c.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isReached
              ? c.mint.withValues(alpha: 0.25)
              : isCurrent
                  ? c.mint.withValues(alpha: 0.15)
                  : c.border,
        ),
        boxShadow: isReached
            ? [
                BoxShadow(
                  color: c.mint.withValues(alpha: 0.08),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon + amount row
          Row(
            children: [
              Text(milestone.emoji, style: const TextStyle(fontSize: 18)),
              const Spacer(),
              Text(
                Subscription.formatPrice(milestone.amount, currencyCode, decimals: 0),
                style: ChompdTypography.mono(
                  size: 11,
                  weight: FontWeight.w700,
                  color: isReached ? c.mint : c.textDim,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Name
          Text(
            Milestone.localizedName(context, milestone.name),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isReached ? c.text : c.textMid,
            ),
          ),
          const SizedBox(height: 6),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: fillProgress,
              minHeight: 3,
              backgroundColor: c.bgElevated,
              valueColor: AlwaysStoppedAnimation<Color>(
                isReached ? c.mint : c.mint.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 3),

          // Status label
          Text(
            isReached
                ? context.l10n.milestoneReached
                : context.l10n.milestoneToGo(Subscription.formatPrice(remaining, currencyCode, decimals: 0)),
            style: ChompdTypography.mono(
              size: 8,
              color: isReached ? c.mint : c.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact milestone badge for the hero savings section.
class MilestoneBadge extends StatelessWidget {
  final Milestone milestone;

  const MilestoneBadge({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.mint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: c.mint.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(milestone.emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            Milestone.localizedName(context, milestone.name),
            style: ChompdTypography.mono(
              size: 9,
              weight: FontWeight.w700,
              color: c.mint,
            ),
          ),
        ],
      ),
    );
  }
}

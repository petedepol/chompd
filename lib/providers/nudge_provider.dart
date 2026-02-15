import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nudge_candidate.dart';
import '../services/nudge_engine.dart';
import 'currency_provider.dart';
import 'subscriptions_provider.dart';

/// Provides ALL nudge candidates, filtered by 30-day cooldown,
/// sorted by priority (1 = highest).
final nudgesProvider = Provider<List<NudgeCandidate>>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  final displayCurrency = ref.watch(currencyProvider);
  final active = subs.where((s) => s.isActive).toList();

  final candidates = NudgeEngine().evaluate(
    active,
    displayCurrency: displayCurrency,
  );

  // Filter out recently nudged
  return candidates.where((c) {
    if (c.sub.lastNudgedAt == null) return true;
    return DateTime.now().difference(c.sub.lastNudgedAt!).inDays > 30;
  }).toList();
});

/// Provides the highest-priority nudge candidate, if any.
/// Kept for backward compatibility with existing single-nudge consumers.
final nudgeProvider = Provider<NudgeCandidate?>((ref) {
  final nudges = ref.watch(nudgesProvider);
  return nudges.isEmpty ? null : nudges.first;
});

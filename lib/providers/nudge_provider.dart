import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nudge_candidate.dart';
import '../services/nudge_engine.dart';
import 'subscriptions_provider.dart';

/// Provides the highest-priority nudge candidate, if any.
///
/// Watches the subscriptions list and re-evaluates whenever it changes.
/// Frequency limiting (3-day cooldown, 2/week max) deferred until
/// persistence layer (SharedPreferences) is wired up.
final nudgeProvider = Provider<NudgeCandidate?>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  final active = subs.where((s) => s.isActive).toList();

  final candidates = NudgeEngine().evaluate(active);
  if (candidates.isEmpty) return null;

  // Return the highest priority candidate that hasn't been nudged
  // in the last 30 days.
  return candidates.where((c) {
    if (c.sub.lastNudgedAt == null) return true;
    return DateTime.now().difference(c.sub.lastNudgedAt!).inDays > 30;
  }).firstOrNull;
});

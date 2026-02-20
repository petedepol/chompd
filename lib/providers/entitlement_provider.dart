import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../models/entitlement.dart';
import '../services/purchase_service.dart';
import 'notification_provider.dart';
import 'purchase_provider.dart';
import 'subscriptions_provider.dart';

// ─── Constants ───

const _trialStartKey = 'trial_start_date';

// ─── Entitlement Notifier ───

/// Single source of truth for the user's entitlement state.
///
/// Resolves the current [UserTier] by checking:
/// 1. Pro purchase (via [PurchaseService])
/// 2. Active trial (via SharedPreferences timestamp)
/// 3. Otherwise → free tier
///
/// Listens to purchase state changes and triggers freeze/unfreeze
/// on tier transitions.
class EntitlementNotifier extends StateNotifier<Entitlement> {
  final Ref _ref;

  EntitlementNotifier(this._ref) : super(const Entitlement()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final trialStartStr = prefs.getString(_trialStartKey);
    DateTime? trialStart;
    DateTime? trialEnd;

    if (trialStartStr != null) {
      trialStart = DateTime.parse(trialStartStr);
      trialEnd = trialStart.add(
        const Duration(days: AppConstants.trialDurationDays),
      );
    }

    // Check current purchase state
    final purchaseState = _ref.read(purchaseProvider);
    final isPro = purchaseState == PurchaseState.pro;

    final UserTier tier;
    if (isPro) {
      tier = UserTier.pro;
    } else if (trialStart != null && trialEnd!.isAfter(DateTime.now())) {
      tier = UserTier.trial;
    } else {
      tier = UserTier.free;
    }

    state = Entitlement(
      tier: tier,
      trialStartDate: trialStart,
      trialEndDate: trialEnd,
    );

    // Sync notification service Pro status
    _ref.read(notificationPrefsProvider.notifier).setProStatus(
      state.hasFullAccess,
    );

    // Listen for purchase state changes → auto-upgrade to Pro
    _ref.listen<PurchaseState>(purchaseProvider, (prev, next) {
      if (next == PurchaseState.pro && !state.isPro) {
        state = state.copyWith(tier: UserTier.pro);
        _onTierChange(state);
      }
    });
  }

  /// Called when tier changes — triggers freeze/unfreeze and notification sync.
  void _onTierChange(Entitlement ent) {
    // Sync notification Pro status
    _ref.read(notificationPrefsProvider.notifier).setProStatus(
      ent.hasFullAccess,
    );

    // Freeze/unfreeze subscriptions based on new tier
    if (ent.hasFullAccess) {
      _ref.read(subscriptionsProvider.notifier).unfreezeAll();
    } else {
      _ref.read(subscriptionsProvider.notifier).freezeExcess(
        ent.maxSubscriptions,
      );
    }
  }

  /// Start the 7-day free trial.
  Future<void> startTrial() async {
    final now = DateTime.now();
    final end = now.add(const Duration(days: AppConstants.trialDurationDays));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_trialStartKey, now.toIso8601String());

    state = Entitlement(
      tier: UserTier.trial,
      trialStartDate: now,
      trialEndDate: end,
    );

    _onTierChange(state);
  }

  /// Whether the user has ever started a trial.
  Future<bool> hasEverTrialed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_trialStartKey);
  }

  /// Re-evaluate tier (e.g. on app resume to catch trial expiry).
  void recheck() {
    if (state.isTrial && state.trialEndDate != null &&
        DateTime.now().isAfter(state.trialEndDate!)) {
      state = state.copyWith(tier: UserTier.free);
      _onTierChange(state);
    }
  }

  // ─── Dev Helpers ───

  /// DEV ONLY: Start a trial that expires in [minutes] minutes.
  Future<void> devSetTrialMinutes(int minutes) async {
    assert(() { return true; }());
    final now = DateTime.now();
    final end = now.add(Duration(minutes: minutes));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_trialStartKey, now.toIso8601String());

    state = Entitlement(
      tier: UserTier.trial,
      trialStartDate: now,
      trialEndDate: end,
    );

    _onTierChange(state);
  }

  /// DEV ONLY: Reset all trial state.
  Future<void> devResetTrial() async {
    assert(() { return true; }());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_trialStartKey);
    await prefs.remove('trial_prompt_shown');
    await prefs.remove('trial_expired_shown');

    state = const Entitlement(tier: UserTier.free);
    _onTierChange(state);
  }
}

// ─── Providers ───

/// The main entitlement provider — single source of truth.
final entitlementProvider =
    StateNotifierProvider<EntitlementNotifier, Entitlement>((ref) {
  return EntitlementNotifier(ref);
});

/// Current user tier.
final userTierProvider = Provider<UserTier>((ref) {
  return ref.watch(entitlementProvider).tier;
});

/// Trial days remaining (0 if not on trial).
final trialDaysRemainingProvider = Provider<int>((ref) {
  return ref.watch(entitlementProvider).trialDaysRemaining;
});

/// Whether the trial has expired.
final isTrialExpiredProvider = Provider<bool>((ref) {
  return ref.watch(entitlementProvider).isTrialExpired;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/constants.dart';
import '../services/purchase_service.dart';
import 'subscriptions_provider.dart';
import 'scan_provider.dart';

// ─── Purchase State ───

/// Riverpod wrapper around the PurchaseService.
class PurchaseNotifier extends StateNotifier<PurchaseState> {
  PurchaseNotifier() : super(PurchaseService.instance.state) {
    // Listen for external state changes
    PurchaseService.instance.addListener(_syncState);
  }

  @override
  void dispose() {
    PurchaseService.instance.removeListener(_syncState);
    super.dispose();
  }

  void _syncState() {
    state = PurchaseService.instance.state;
  }

  /// Purchase Pro.
  Future<bool> purchasePro() async {
    final result = await PurchaseService.instance.purchasePro();
    state = PurchaseService.instance.state;
    return result;
  }

  /// Restore purchase.
  Future<bool> restorePurchase() async {
    final result = await PurchaseService.instance.restorePurchase();
    state = PurchaseService.instance.state;
    return result;
  }
}

// ─── Providers ───

/// The main purchase state provider.
final purchaseProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>((ref) {
  return PurchaseNotifier();
});

/// Convenience: is the user a Pro subscriber?
final isProProvider = Provider<bool>((ref) {
  return true; // DEV OVERRIDE — always Pro for testing
  // return ref.watch(purchaseProvider) == PurchaseState.pro;
});

/// Convenience: can the user add more subscriptions?
final canAddSubProvider = Provider<bool>((ref) {
  final isPro = ref.watch(isProProvider);
  if (isPro) return true;
  final count = ref.watch(subscriptionsProvider).length;
  return count < AppConstants.freeMaxSubscriptions;
});

/// Convenience: can the user perform more AI scans?
final canScanProvider = Provider<bool>((ref) {
  final isPro = ref.watch(isProProvider);
  if (isPro) return true;
  final usedScans = ref.watch(scanCounterProvider);
  return usedScans < AppConstants.freeMaxScans;
});

/// Remaining subscription slots.
final remainingSubsProvider = Provider<int>((ref) {
  final isPro = ref.watch(isProProvider);
  if (isPro) return 999;
  final count = ref.watch(subscriptionsProvider).length;
  return (AppConstants.freeMaxSubscriptions - count).clamp(0, 999);
});

/// Remaining scan slots.
final remainingScansProvider = Provider<int>((ref) {
  final isPro = ref.watch(isProProvider);
  if (isPro) return 999;
  final usedScans = ref.watch(scanCounterProvider);
  return (AppConstants.freeMaxScans - usedScans).clamp(0, 999);
});

/// What triggered the paywall (for analytics and messaging).
enum PaywallTrigger {
  subscriptionLimit,
  scanLimit,
  reminderUpgrade,
  settingsUpgrade,
  manual,
}

import 'package:flutter/foundation.dart';

import '../config/constants.dart';

/// Purchase state for the one-time Pro unlock.
enum PurchaseState {
  /// Not yet purchased.
  free,

  /// Purchase in progress.
  purchasing,

  /// Successfully purchased.
  pro,

  /// Purchase failed or was cancelled.
  failed,

  /// Restoring a previous purchase.
  restoring,
}

/// RevenueCat placeholder for in-app purchase management.
///
/// For v1 prototype, this manages purchase state in-memory.
/// In production, this wraps RevenueCat SDK for:
/// - One-time £4.99 Pro unlock
/// - Receipt validation
/// - Purchase restoration
/// - Cross-platform entitlement management
class PurchaseService {
  PurchaseService._();
  static final instance = PurchaseService._();

  /// Current purchase state.
  PurchaseState _state = PurchaseState.free;

  /// Whether the service has been initialised.
  bool _initialised = false;

  /// Callbacks for state changes.
  final List<VoidCallback> _listeners = [];

  // ─── Initialisation ───

  /// Initialise the purchase service.
  ///
  /// In production: configure RevenueCat, check entitlements,
  /// restore previous purchases silently.
  Future<void> init() async {
    if (_initialised) return;

    // In production:
    // await Purchases.configure(PurchasesConfiguration('revenuecat_api_key'));
    // final info = await Purchases.getCustomerInfo();
    // if (info.entitlements.all['pro']?.isActive == true) {
    //   _state = PurchaseState.pro;
    // }

    _initialised = true;
    debugPrint('[PurchaseService] Initialised — state: $_state');
  }

  // ─── State ───

  PurchaseState get state => _state;
  bool get isPro => _state == PurchaseState.pro;
  bool get isFree => _state == PurchaseState.free;

  /// Product info for display.
  String get priceDisplay =>
      '\u00A3${AppConstants.proPrice.toStringAsFixed(2)}';
  String get productName => 'Chompd Pro';
  String get productDescription => 'One-time payment. Unlock everything.';

  // ─── Purchase Flow ───

  /// Initiate a Pro purchase.
  ///
  /// In production: launches RevenueCat purchase flow.
  /// For prototype: simulates a successful purchase after 1.5s delay.
  Future<bool> purchasePro() async {
    if (_state == PurchaseState.pro) return true;

    _setState(PurchaseState.purchasing);

    try {
      // Simulate purchase flow
      await Future.delayed(const Duration(milliseconds: 1500));

      // In production:
      // final offerings = await Purchases.getOfferings();
      // final package = offerings.current?.lifetime;
      // if (package != null) {
      //   final result = await Purchases.purchasePackage(package);
      //   if (result.entitlements.all['pro']?.isActive == true) {
      //     _setState(PurchaseState.pro);
      //     return true;
      //   }
      // }

      // Simulate success
      _setState(PurchaseState.pro);
      debugPrint('[PurchaseService] Purchase successful');
      return true;
    } catch (e) {
      _setState(PurchaseState.failed);
      debugPrint('[PurchaseService] Purchase failed: $e');
      return false;
    }
  }

  /// Restore a previous purchase.
  ///
  /// In production: calls RevenueCat restorePurchases.
  Future<bool> restorePurchase() async {
    _setState(PurchaseState.restoring);

    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      // In production:
      // final info = await Purchases.restorePurchases();
      // if (info.entitlements.all['pro']?.isActive == true) {
      //   _setState(PurchaseState.pro);
      //   return true;
      // }

      // Simulate: no previous purchase found
      _setState(PurchaseState.free);
      debugPrint('[PurchaseService] No purchase to restore');
      return false;
    } catch (e) {
      _setState(PurchaseState.free);
      debugPrint('[PurchaseService] Restore failed: $e');
      return false;
    }
  }

  // ─── Listeners ───

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _setState(PurchaseState newState) {
    _state = newState;
    for (final listener in _listeners) {
      listener();
    }
  }

  // ─── Free Tier Limit Checks ───

  /// Whether the user can add more subscriptions.
  bool canAddSubscription(int currentCount) {
    if (isPro) return true;
    return currentCount < AppConstants.freeMaxSubscriptions;
  }

  /// Whether the user can perform more AI scans.
  bool canScan(int usedScans) {
    if (isPro) return true;
    return usedScans < AppConstants.freeMaxScans;
  }

  /// How many more subscriptions the user can add.
  int remainingSubscriptions(int currentCount) {
    if (isPro) return 999;
    return (AppConstants.freeMaxSubscriptions - currentCount).clamp(0, 999);
  }

  /// How many more scans the user can do.
  int remainingScans(int usedScans) {
    if (isPro) return 999;
    return (AppConstants.freeMaxScans - usedScans).clamp(0, 999);
  }
}

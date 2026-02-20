import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/constants.dart';
import 'auth_service.dart';

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
///
/// The Supabase `profiles.is_pro` flag is the single source of truth.
/// On startup, [fetchProStatus] reads it before sync runs.
/// On purchase, [purchasePro] writes it back.
class PurchaseService {
  PurchaseService._();
  static final instance = PurchaseService._();

  /// Current purchase state.
  PurchaseState _state = PurchaseState.free;

  /// Whether the service has been initialised.
  bool _initialised = false;

  /// Callbacks for state changes.
  final List<VoidCallback> _listeners = [];

  /// Whether Supabase is configured.
  bool get _hasSupabase =>
      const String.fromEnvironment('SUPABASE_URL').isNotEmpty;

  SupabaseClient get _client => Supabase.instance.client;

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
  }

  // ─── Supabase Pro Status ───

  /// Fetch `is_pro` from the Supabase `profiles` table.
  ///
  /// This is the single source of truth for Pro status. Must be called
  /// after auth is ready and BEFORE sync runs, so push logic sees the
  /// correct state.
  ///
  /// Gracefully falls back to current state on failure (offline, no
  /// Supabase, etc.) — never blocks the app from launching.
  Future<void> fetchProStatus() async {
    if (!_hasSupabase) return;
    final userId = AuthService.instance.userId;
    if (userId == null) return;

    try {
      final row = await _client
          .from('profiles')
          .select('is_pro')
          .eq('id', userId)
          .maybeSingle();

      if (row != null && row['is_pro'] == true) {
        if (_state != PurchaseState.pro) {
          _setState(PurchaseState.pro);
        }
      }
    } catch (_) {
      // Keep current state — don't downgrade on network failure
    }
  }

  /// Write `is_pro = true` to the Supabase `profiles` table.
  ///
  /// Called after a successful App Store purchase or restore.
  /// Fire-and-forget — local state is already set.
  Future<void> _syncProToSupabase() async {
    if (!_hasSupabase) return;
    final userId = AuthService.instance.userId;
    if (userId == null) return;

    try {
      await _client
          .from('profiles')
          .update({'is_pro': true, 'pro_purchased_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', userId);
    } catch (_) {
      // Silently ignored
    }
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
  /// On success, writes `is_pro = true` to Supabase profiles.
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
      //     _syncProToSupabase();
      //     return true;
      //   }
      // }

      // Simulate success
      _setState(PurchaseState.pro);
      _syncProToSupabase();
      return true;
    } catch (_) {
      _setState(PurchaseState.failed);
      return false;
    }
  }

  /// Restore a previous purchase.
  ///
  /// Checks Supabase `profiles.is_pro` first (covers cross-device restore),
  /// then falls back to App Store / RevenueCat restore.
  Future<bool> restorePurchase() async {
    _setState(PurchaseState.restoring);

    try {
      // 1. Check Supabase first (cross-device source of truth)
      if (_hasSupabase && AuthService.instance.userId != null) {
        final userId = AuthService.instance.userId!;
        final row = await _client
            .from('profiles')
            .select('is_pro')
            .eq('id', userId)
            .maybeSingle();

        if (row != null && row['is_pro'] == true) {
          _setState(PurchaseState.pro);
          return true;
        }
      }

      // 2. Fall back to App Store / RevenueCat restore
      await Future.delayed(const Duration(milliseconds: 1000));

      // In production:
      // final info = await Purchases.restorePurchases();
      // if (info.entitlements.all['pro']?.isActive == true) {
      //   _setState(PurchaseState.pro);
      //   _syncProToSupabase();
      //   return true;
      // }

      // No purchase found anywhere
      _setState(PurchaseState.free);
      return false;
    } catch (_) {
      _setState(PurchaseState.free);
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

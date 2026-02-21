import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/constants.dart';
import 'auth_service.dart';
import 'error_logger.dart';

/// Purchase state for the one-time Pro unlock.
enum PurchaseState {
  /// Not yet purchased.
  free,

  /// Purchase in progress.
  purchasing,

  /// Successfully purchased.
  pro,

  /// Purchase failed.
  failed,

  /// Restoring a previous purchase.
  restoring,
}

/// In-app purchase service using Flutter's `in_app_purchase` plugin
/// (StoreKit 2 on iOS).
///
/// Manages a single non-consumable product: `chompd_pro_lifetime`.
///
/// Source of truth hierarchy:
/// 1. App Store (StoreKit 2) — primary
/// 2. Supabase `profiles.is_pro` — secondary backup for cross-device
/// 3. Local `_state` — in-memory, derived from the above
class PurchaseService {
  PurchaseService._();
  static final instance = PurchaseService._();

  // ─── Internal state ───

  PurchaseState _state = PurchaseState.free;
  bool _initialised = false;
  final List<VoidCallback> _listeners = [];

  // ─── IAP state ───

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  ProductDetails? _proProduct;
  Completer<bool>? _purchaseCompleter;
  Completer<bool>? _restoreCompleter;

  // ─── Supabase ───

  bool get _hasSupabase =>
      const String.fromEnvironment('SUPABASE_URL').isNotEmpty;

  SupabaseClient get _client => Supabase.instance.client;

  // ─── Initialisation ───

  /// Initialise the purchase service.
  ///
  /// Checks IAP availability, starts listening to the purchase stream
  /// (which also catches interrupted/pending transactions from previous
  /// sessions), and queries product details from the App Store.
  Future<void> init() async {
    if (_initialised) return;

    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('PurchaseService: IAP not available');
      _initialised = true;
      return;
    }

    // Listen to the purchase stream for the lifetime of the app.
    // This catches completed purchases, failed purchases, pending
    // transactions, and interrupted purchases from previous sessions.
    _purchaseSubscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: (Object error) {
        ErrorLogger.log(
          event: 'purchase_error',
          detail: 'purchaseStream error: $error',
        );
      },
    );

    // Query product details from App Store.
    await _loadProducts();

    _initialised = true;
  }

  /// Query product details from the App Store.
  Future<void> _loadProducts() async {
    try {
      final response = await _iap.queryProductDetails(
        {AppConstants.proProductId},
      );

      if (response.error != null) {
        ErrorLogger.log(
          event: 'purchase_error',
          detail: 'queryProductDetails error: ${response.error!.message}',
        );
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint(
          'PurchaseService: products not found: ${response.notFoundIDs}',
        );
      }

      if (response.productDetails.isNotEmpty) {
        _proProduct = response.productDetails.first;
      }
    } catch (e, st) {
      ErrorLogger.log(
        event: 'purchase_error',
        detail: 'loadProducts: $e',
        stackTrace: st.toString(),
      );
    }
  }

  // ─── Purchase Stream Handler ───

  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchase);

        case PurchaseStatus.error:
          _handlePurchaseError(purchase);

        case PurchaseStatus.pending:
          // Transaction pending (e.g. parental approval, payment processing).
          // Keep state as purchasing — do not resolve completer yet.
          debugPrint('PurchaseService: purchase pending');

        case PurchaseStatus.canceled:
          _handlePurchaseCancelled(purchase);
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    // CRITICAL: Must complete the purchase to clear the transaction queue.
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }

    _setState(PurchaseState.pro);

    // Sync to Supabase as secondary backup.
    _syncProToSupabase();

    // Resolve any waiting completer.
    if (_purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
      _purchaseCompleter!.complete(true);
    }
    if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
      _restoreCompleter!.complete(true);
    }
  }

  void _handlePurchaseError(PurchaseDetails purchase) {
    ErrorLogger.log(
      event: 'purchase_error',
      detail: 'purchase error: ${purchase.error?.message ?? "unknown"}',
    );

    // Must still complete the purchase to clear the transaction queue.
    if (purchase.pendingCompletePurchase) {
      _iap.completePurchase(purchase);
    }

    _setState(PurchaseState.failed);

    if (_purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
      _purchaseCompleter!.complete(false);
    }
    if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
      _restoreCompleter!.complete(false);
    }
  }

  void _handlePurchaseCancelled(PurchaseDetails purchase) {
    // User cancelled the purchase sheet — this is not an error.
    if (purchase.pendingCompletePurchase) {
      _iap.completePurchase(purchase);
    }

    _setState(PurchaseState.free);

    if (_purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
      _purchaseCompleter!.complete(false);
    }
    if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
      _restoreCompleter!.complete(false);
    }
  }

  // ─── Supabase Pro Status ───

  /// Fetch `is_pro` from the Supabase `profiles` table.
  ///
  /// This is the secondary source of truth for Pro status. Must be called
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
    } catch (e, st) {
      ErrorLogger.log(
        event: 'purchase_error',
        detail: 'fetchProStatus: $e',
        stackTrace: st.toString(),
      );
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
          .update({
            'is_pro': true,
            'pro_purchased_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e, st) {
      ErrorLogger.log(
        event: 'purchase_error',
        detail: 'syncProToSupabase: $e',
        stackTrace: st.toString(),
      );
    }
  }

  // ─── State ───

  PurchaseState get state => _state;
  bool get isPro => _state == PurchaseState.pro;
  bool get isFree => _state == PurchaseState.free;

  /// Localised price from App Store (e.g. "€4.99", "$4.99", "24,99 zł").
  /// Falls back to hardcoded constant if products haven't loaded.
  String get priceDisplay {
    if (_proProduct != null) {
      return _proProduct!.price;
    }
    // Fallback: hardcoded (only if App Store query failed).
    return '\u00A3${AppConstants.proPrice.toStringAsFixed(2)}';
  }

  String get productName => 'Chompd Pro';
  String get productDescription => 'One-time payment. Unlock everything.';

  /// Whether the product has been loaded from the App Store.
  bool get isProductAvailable => _proProduct != null;

  // ─── Purchase Flow ───

  /// Initiate a Pro purchase via the App Store.
  ///
  /// Returns `true` if the purchase was successful, `false` if cancelled
  /// or failed. The result comes asynchronously from the purchase stream.
  Future<bool> purchasePro() async {
    if (_state == PurchaseState.pro) return true;

    if (_proProduct == null) {
      // Products failed to load — try once more.
      await _loadProducts();
      if (_proProduct == null) {
        ErrorLogger.log(
          event: 'purchase_error',
          detail: 'purchasePro: product not available',
        );
        _setState(PurchaseState.failed);
        return false;
      }
    }

    _setState(PurchaseState.purchasing);

    // Create a completer that the stream handler will resolve.
    _purchaseCompleter = Completer<bool>();

    try {
      final purchaseParam = PurchaseParam(
        productDetails: _proProduct!,
      );

      // buyNonConsumable triggers the App Store payment sheet.
      // The result comes back on the purchaseStream, not from this call.
      final initiated = await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!initiated) {
        _setState(PurchaseState.failed);
        if (!_purchaseCompleter!.isCompleted) {
          _purchaseCompleter!.complete(false);
        }
      }

      return await _purchaseCompleter!.future;
    } catch (e, st) {
      ErrorLogger.log(
        event: 'purchase_error',
        detail: 'purchasePro: $e',
        stackTrace: st.toString(),
      );
      _setState(PurchaseState.failed);
      if (_purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
        _purchaseCompleter!.complete(false);
      }
      return false;
    }
  }

  /// Restore a previous purchase.
  ///
  /// Checks Supabase `profiles.is_pro` first (covers cross-device restore),
  /// then falls back to App Store restore which triggers the sign-in prompt.
  Future<bool> restorePurchase() async {
    _setState(PurchaseState.restoring);

    // 1. Check Supabase first (cross-device source of truth).
    if (_hasSupabase && AuthService.instance.userId != null) {
      try {
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
      } catch (e, st) {
        ErrorLogger.log(
          event: 'purchase_error',
          detail: 'restorePurchase supabase check: $e',
          stackTrace: st.toString(),
        );
        // Continue to App Store restore.
      }
    }

    // 2. App Store restore.
    _restoreCompleter = Completer<bool>();

    try {
      // This triggers the App Store sign-in prompt on iOS.
      // Results come back on the purchaseStream.
      await _iap.restorePurchases();

      // Wait for stream results with a timeout.
      // If no purchases are found, the stream may not fire at all,
      // so we use a timeout to avoid hanging forever.
      final result = await _restoreCompleter!.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => false,
      );

      if (!result) {
        _setState(PurchaseState.free);
      }
      return result;
    } catch (e, st) {
      ErrorLogger.log(
        event: 'purchase_error',
        detail: 'restorePurchase: $e',
        stackTrace: st.toString(),
      );
      _setState(PurchaseState.free);
      if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
        _restoreCompleter!.complete(false);
      }
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

  // ─── Cleanup ───

  /// Cancel the purchase stream subscription.
  void dispose() {
    _purchaseSubscription?.cancel();
  }
}

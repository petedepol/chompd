import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../providers/purchase_provider.dart';
import '../providers/scan_provider.dart';
import '../screens/paywall/paywall_screen.dart';
import '../screens/scan/scan_screen.dart';

/// Handles images shared from other apps via the OS Share Sheet.
///
/// Listens for incoming shared media (images), reads the file bytes,
/// and navigates to the scan screen to start an AI analysis.
class ShareHandler {
  ShareHandler._();
  static final instance = ShareHandler._();

  StreamSubscription<List<SharedMediaFile>>? _intentSub;

  /// The global navigator key — must be set from the app's MaterialApp.
  GlobalKey<NavigatorState>? navigatorKey;

  /// The Riverpod container — must be set from the ProviderScope.
  ProviderContainer? container;

  /// Start listening for shared intents.
  ///
  /// Call this once from the app entry widget's initState, passing
  /// the navigator key and ProviderContainer.
  void init({
    required GlobalKey<NavigatorState> navigatorKey,
    required ProviderContainer container,
  }) {
    this.navigatorKey = navigatorKey;
    this.container = container;

    // Handle intent when app is opened from share sheet (cold start).
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      if (files.isNotEmpty) {
        _handleSharedFiles(files);
      }
    });

    // Handle intent while app is already running (warm start).
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (files) {
        if (files.isNotEmpty) {
          _handleSharedFiles(files);
        }
      },
      onError: (_) {},
    );
  }

  /// Process shared files — filter to images, read bytes, start scan.
  Future<void> _handleSharedFiles(List<SharedMediaFile> files) async {
    final nav = navigatorKey?.currentState;
    final cont = container;
    if (nav == null || cont == null) return;

    // Find the first image file.
    final imageFile = files.firstWhere(
      (f) => f.type == SharedMediaType.image,
      orElse: () => files.first,
    );

    final file = File(imageFile.path);
    if (!file.existsSync()) {
      return;
    }

    // Check scan limits.
    final canScan = cont.read(canScanProvider);
    if (!canScan) {
      final context = nav.context;
      await showPaywall(context, trigger: PaywallTrigger.scanLimit);
      return;
    }

    // Read image bytes.
    final bytes = await file.readAsBytes();
    final path = imageFile.path.toLowerCase();
    final mimeType = path.endsWith('.png')
        ? 'image/png'
        : path.endsWith('.webp')
            ? 'image/webp'
            : (path.endsWith('.heic') || path.endsWith('.heif'))
                ? 'image/heic'
                : 'image/jpeg';

    // Increment scan counter and start the scan.
    cont.read(scanCounterProvider.notifier).increment();
    cont.read(scanProvider.notifier).startTrapScan(
          imageBytes: bytes,
          mimeType: mimeType,
        );

    // Navigate to scan screen.
    nav.push(
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );

  }

  /// Clean up the stream subscription.
  void dispose() {
    _intentSub?.cancel();
    _intentSub = null;
  }
}

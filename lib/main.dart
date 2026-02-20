import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'services/auth_service.dart';
import 'services/dodged_trap_repository.dart';
import 'services/exchange_rate_service.dart';
import 'services/isar_service.dart';
import 'services/merchant_db.dart';
import 'services/notification_service.dart';
import 'services/purchase_service.dart';
import 'services/service_insight_repository.dart';
import 'services/service_sync_service.dart';
import 'services/sync_service.dart';
import 'services/user_insight_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise intl date formatting for all locales (needed by TableCalendar)
  await initializeDateFormatting();

  // Initialise Supabase (before other services)
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Anonymous auth — deferred if offline or Supabase not configured
  if (supabaseUrl.isNotEmpty) {
    try {
      await AuthService.instance.ensureUser();
    } catch (_) {
      // Silently ignored
    }
  }

  // Initialise Isar local database (before services that depend on it)
  await IsarService.instance.init();

  // Seed the merchant intelligence DB with known patterns
  MerchantDb.instance.seed();

  // Initialise the notification service
  await NotificationService.instance.init();

  // Initialise exchange rates (loads cache, fetches if stale)
  await ExchangeRateService.instance.init();

  // Initialise the purchase service
  await PurchaseService.instance.init();

  // Fetch Pro status from Supabase BEFORE sync runs.
  // profiles.is_pro is the source of truth — ensures push logic
  // and feature gates see the correct Pro state immediately.
  await PurchaseService.instance.fetchProStatus();

  // Load persisted dodged traps
  await DodgedTrapRepository.instance.load();

  // Restore from remote on reinstall (if local is empty but user is signed in)
  try {
    await SyncService.instance.restoreFromRemote();
  } catch (_) {
    // Silently ignored
  }

  // Non-blocking initial sync (pull remote changes)
  SyncService.instance.pullAndMerge();

  // Sync service database (cancel guides, pricing, dark patterns, etc.)
  ServiceSyncService.instance.syncServices();

  // Sync curated service insights
  ServiceInsightRepository.instance.syncFromSupabase();

  // Sync AI-generated user insights
  UserInsightRepository.instance.syncFromSupabase();

  // Re-sync whenever connectivity is restored
  Connectivity().onConnectivityChanged.listen((results) {
    if (!results.contains(ConnectivityResult.none)) {
      SyncService.instance.pullAndMerge();
      ServiceSyncService.instance.syncServices();
      ServiceInsightRepository.instance.syncFromSupabase();
      UserInsightRepository.instance.syncFromSupabase();
    }
  });

  // Lock to portrait for v1
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Dark status bar to match our dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF080808),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: ChompdApp(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'services/dodged_trap_repository.dart';
import 'services/exchange_rate_service.dart';
import 'services/merchant_db.dart';
import 'services/notification_service.dart';
import 'services/purchase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Seed the merchant intelligence DB with known patterns
  MerchantDb.instance.seed();

  // Initialise the notification service
  await NotificationService.instance.init();

  // Initialise exchange rates (loads cache, fetches if stale)
  await ExchangeRateService.instance.init();

  // Initialise the purchase service
  await PurchaseService.instance.init();

  // Load persisted dodged traps
  await DodgedTrapRepository.instance.load();

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

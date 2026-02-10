import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Toggle between monthly and yearly spend views.
enum SpendView { monthly, yearly }

/// Simple state provider for the spending ring toggle.
final spendViewProvider = StateProvider<SpendView>(
  (ref) => SpendView.monthly,
);

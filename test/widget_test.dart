import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chompd/app.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ChompdApp()),
    );

    // Verify the app builds and the splash screen shows
    await tester.pump();
    expect(find.text('Chompd'), findsOneWidget);
  });
}

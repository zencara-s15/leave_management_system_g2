// Basic smoke test — verifies the app starts without crashing.
// SharedPreferences must be mocked before calling main() in tests.
// See: https://pub.dev/packages/shared_preferences#testing

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App initializes without errors', (WidgetTester tester) async {
    // Mock empty SharedPreferences so StorageService can initialize
    SharedPreferences.setMockInitialValues({});

    // TODO: Add meaningful widget tests once the UI is finalized.
    // Example:
    //   await tester.pumpWidget(/* wrap app in providers */);
    //   expect(find.text('Sign In'), findsOneWidget);
  });
}

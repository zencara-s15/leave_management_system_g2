import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:leave_management_system_g2/main.dart';

void main() {
  testWidgets('navigates to MySQL connection screen', (WidgetTester tester) async {
    await tester.pumpWidget(const LeaveManagementApp());

    expect(find.text('Leave Management\nSystem'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-hero-panel')));
    await tester.pumpAndSettle();

    expect(find.text('MySQL Connection'), findsOneWidget);
  });
}

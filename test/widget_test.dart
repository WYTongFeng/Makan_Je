import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Update this import to point to your main.dart file.
// Depending on your exact folder structure, it might just be 'package:makanjeapp/main.dart'
import 'package:makanjeapp/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // CHANGE THIS LINE: Replace MyApp() with MakanJeApp()
    await tester.pumpWidget(const MakanJeApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

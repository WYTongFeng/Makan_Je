import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makanjeapp/views/common/landing_view.dart';

void main() {
  testWidgets('Landing Screen renders core navigation buttons correctly', (WidgetTester tester) async {
    
    // 1. Mount the target widget within a localized testing environment
    await tester.pumpWidget(const MaterialApp(
      home: LandingView(), 
    ));

    // 2. Verify that the primary Customer entry button is painted on the screen
    // Note: Adjusted from 'Dine In (Scan QR)' to match actual code 'Scan Table QR to Order'
    expect(find.text('Scan Table QR to Order'), findsOneWidget);

    // 3. Verify that the Staff authentication portal link exists
    expect(find.text('Staff Login'), findsOneWidget);
    
    // 4. Negative testing: Verify that unexpected elements do NOT exist
    expect(find.text('Random Non-Existent Button'), findsNothing);
  });
}

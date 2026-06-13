import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centralny_dashboard/components/premium_background.dart';

void main() {
  testWidgets('PremiumBackground renders correctly with child and does not crash', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PremiumBackground(
          child: Text('Test Child'),
        ),
      ),
    );

    // Verify child is rendered
    expect(find.text('Test Child'), findsOneWidget);

    // Verify the widget itself is rendered
    expect(find.byType(PremiumBackground), findsOneWidget);
  });
}

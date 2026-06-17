import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders dashboard title text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('NUSTAR Asset Scanner'),
        ),
      ),
    );

    expect(find.text('NUSTAR Asset Scanner'), findsOneWidget);
  });
}

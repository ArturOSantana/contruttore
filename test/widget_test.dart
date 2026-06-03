import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:contruttore/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CostruttoreApp());

    // Verify that the app starts
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

// Made with Bob

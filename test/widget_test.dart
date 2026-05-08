import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hercare/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HerCareApp());

    // Verify that the MaterialApp is built
    expect(find.byType(MaterialApp), findsWidgets);
  });
}

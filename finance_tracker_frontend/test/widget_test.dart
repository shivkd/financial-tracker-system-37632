import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker_frontend/main.dart';

void main() {
  testWidgets('FinanceTrackerApp can launch & contain root session widget', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceTrackerApp());

    expect(find.byType(FinanceTrackerApp), findsOneWidget);
    // The app starts with RootSessionGate, so check for some widget characteristic to confirm load
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

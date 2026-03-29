// Smoke test สำหรับ harness (Riverpod + MaterialApp)
// การทดสอบ ArCalApp เต็มรูปแบบต้องใช้ Firebase ที่ initialize แล้ว — ดู integration / manual checklist

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('ProviderScope + MaterialApp smoke', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: Text('smoke')),
          ),
        ),
      ),
    );

    expect(find.text('smoke'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

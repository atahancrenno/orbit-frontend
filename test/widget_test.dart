import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_ptt/main.dart'; 

void main() {
  testWidgets('Uygulama baslatma testi', (WidgetTester tester) async {
    await tester.pumpWidget(const OrbitApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
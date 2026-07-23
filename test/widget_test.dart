import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:moovly/screens/home/home_screen.dart';

void main() {
  testWidgets('Home screen shows the live nearby buses section', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Services rapides'), findsOneWidget);
    expect(find.text('Bus à proximité'), findsOneWidget);
    expect(find.text('GPS en direct'), findsOneWidget);
  });
}

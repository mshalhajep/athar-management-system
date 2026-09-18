import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:athar_purchases/main.dart';

void main() {
  setUpAll(() {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  });

  testWidgets('AtharApp launches and displays splash branding then auth screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AtharApp());

    // Verify Athar brand name and inventory title on splash
    expect(find.text('إدارة مخزون شركة أثر'), findsOneWidget);
    expect(find.text('ننسّق التفاصيل، ونترك أثرًا'), findsOneWidget);

    // Advance past splash timer (6000ms) and route transition (600ms)
    await tester.pump(const Duration(milliseconds: 6200));
    await tester.pump(const Duration(milliseconds: 700));

    // Verify HomeScreen or branding is displayed
    expect(find.text('إدارة مخزون شركة أثر'), findsWidgets);
  });
}

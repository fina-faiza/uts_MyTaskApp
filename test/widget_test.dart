import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_task_app/main.dart';

void main() {
  testWidgets('My Task App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyTaskApp());

    expect(find.text('My Task App'), findsOneWidget);
    expect(find.text('Selesaikan Aplikasi Flutter UTS'), findsOneWidget);
    expect(find.text('Tambah Tugas'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Simpan Tugas'), findsOneWidget);
  });
}

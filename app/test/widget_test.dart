import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diy_ui_app/interactive/prototype_app.dart';

void main() {
  testWidgets('app boots to auth gate', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.binding.platformDispatcher.localesTestValue = const [Locale('zh')];
    await tester.pumpWidget(const PrototypeApp());
    await tester.pump();
    expect(find.byType(PrototypeApp), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:diy_ui_app/main.dart';
import 'package:diy_ui_app/screens_registry.dart';

void main() {
  testWidgets('app gallery renders', (WidgetTester tester) async {
    await tester.pumpWidget(const DiyUiApp());
    expect(find.text('手作星球 · 82 屏设计预览'), findsOneWidget);
  });

  test('screen registry has 82 screens', () {
    expect(screenRegistry.length, 82);
  });
}

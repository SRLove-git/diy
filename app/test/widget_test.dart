import 'package:flutter_test/flutter_test.dart';

import 'package:diy_ui_app/app.dart';
import 'package:diy_ui_app/screens_registry.dart';

void main() {
  testWidgets('app boots to login gate', (WidgetTester tester) async {
    await tester.pumpWidget(const DiyApp());
    // 未登录时展示登录页
    expect(find.text('IDOL BEADS'), findsOneWidget);
  });

  test('screen registry has 82 screens', () {
    expect(screenRegistry.length, 82);
  });
}

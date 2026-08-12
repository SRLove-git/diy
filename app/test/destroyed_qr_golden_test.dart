import 'package:flutter_test/flutter_test.dart';

import 'package:diy_ui_app/live/screens/appointment_screens.dart';

import 'appointment_pending_test.dart' show makeAppointment;
import 'l10n_test_utils.dart';

void main() {
  testWidgets('已核销二维码销毁状态 golden', (tester) async {
    await tester.pumpWidget(
      l10nApp(
        home: CheckinQrScreen(
          appointment: makeAppointment(status: 'checked_in'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(CheckinQrScreen),
      matchesGoldenFile('goldens/destroyed_qr.png'),
    );
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:diy_ui_app/live/live_widgets.dart';

void main() {
  test('fmtPrice：非整数保留 1 位小数，整数不带小数', () {
    expect(fmtPrice(9.9), '9.9');
    expect(fmtPrice(39.9), '39.9');
    expect(fmtPrice(49.9), '49.9');
    expect(fmtPrice(8), '8');
    expect(fmtPrice(149), '149');
    expect(fmtPrice(19.9), '19.9');
  });

  test('fmtPrice：非法值回退为 0', () {
    expect(fmtPrice(double.nan), '0');
    expect(fmtPrice(double.infinity), '0');
  });
}

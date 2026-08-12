import 'package:flutter_test/flutter_test.dart';

import 'package:thinkorigin/live/singapore_holidays.dart';

void main() {
  group('singapore_holidays', () {
    test('识别 2026 年公共假期与周日补假', () {
      expect(isSingaporePublicHoliday('2026-08-09'), isTrue); // 国庆日（周日）
      expect(isSingaporePublicHoliday('2026-08-10'), isTrue); // 国庆日补假（周一）
      expect(isSingaporePublicHoliday('2026-02-17'), isTrue); // 农历新年
      expect(isSingaporePublicHoliday('2026-12-25'), isTrue); // 圣诞节
    });

    test('非假期返回 false', () {
      expect(isSingaporePublicHoliday('2026-08-11'), isFalse);
      expect(isSingaporePublicHoliday('2026-06-15'), isFalse);
    });

    test('周末加价：周六/周日触发，工作日不触发', () {
      expect(isSurchargeDate('2026-08-08'), isTrue); // 周六
      expect(isSurchargeDate('2026-08-09'), isTrue); // 周日（同时是假期）
      expect(isSurchargeDate('2026-08-11'), isFalse); // 周二
    });

    test('工作日但逢公共假期（补假）也触发加价', () {
      expect(isSurchargeDate('2026-08-10'), isTrue); // 周一，国庆日补假
      expect(isSurchargeDate('2026-11-09'), isTrue); // 周一，屠妖节补假
    });

    test('2027 年数据可用', () {
      expect(isSingaporePublicHoliday('2027-02-06'), isTrue);
      expect(isSingaporePublicHoliday('2027-12-25'), isTrue);
    });
  });
}

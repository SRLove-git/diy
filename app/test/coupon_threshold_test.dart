import 'package:flutter_test/flutter_test.dart';

import 'package:thinkorigin/live/screens/appointment_screens.dart';

void main() {
  group('couponMeetsThreshold（与预约服务端门槛口径一致）', () {
    test('无门槛：任意金额均满足', () {
      expect(couponMeetsThreshold('无门槛', 0), isTrue);
      expect(couponMeetsThreshold('无门槛', 39.9), isTrue);
    });

    test('满额门槛：金额恰好等于或超过门槛时满足', () {
      expect(couponMeetsThreshold('满 \$100 可用', 100), isTrue);
      expect(couponMeetsThreshold('满 \$100 可用', 150.5), isTrue);
      expect(couponMeetsThreshold('满 \$100 可用', 99.99), isFalse);
    });

    test('小数门槛正常解析', () {
      expect(couponMeetsThreshold('满 \$49.9 可用', 49.9), isTrue);
      expect(couponMeetsThreshold('满 \$49.9 可用', 49.89), isFalse);
    });
  });
}

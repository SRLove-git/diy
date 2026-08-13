import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thinkorigin/api/auth_store.dart';
import 'package:thinkorigin/api/models.dart';
import 'package:thinkorigin/api/services.dart';

Appointment appointmentOf(int id, int userId, {String status = 'in_service'}) =>
    Appointment.fromJson({
      'id': id,
      'type': 'store',
      'userId': userId,
      'storeName': '拼豆',
      'tableName': 'A1',
      'date': '2026-08-10',
      'startTime': '10:00',
      'endTime': '11:30',
      'peopleCount': 2,
      'code': '654321',
      'amount': '39.8',
      'originalAmount': '39.8',
      'payStatus': 'unpaid',
      'payMethod': '',
      'status': status,
    });

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthStore.instance.restore();
    await AuthStore.instance.save(
      accessToken: 'at-1',
      refreshToken: 'rt-1',
      userId: 1,
    );
  });

  test('当前账号自己的订单进入乐观状态并通知首页', () {
    final refresh = HomeOrdersRefresh.instance;
    var notified = 0;
    void onChanged() => notified++;
    refresh.addListener(onChanged);
    addTearDown(() => refresh.removeListener(onChanged));

    refresh.refresh(appointmentOf(1, 1));

    expect(notified, 1);
    expect(refresh.pending?.id, 1);
  });

  test('管理员代顾客上钟：其他用户的订单不会进入首页乐观状态', () {
    final refresh = HomeOrdersRefresh.instance;
    var notified = 0;
    void onChanged() => notified++;
    refresh.addListener(onChanged);
    addTearDown(() => refresh.removeListener(onChanged));

    refresh.refresh(appointmentOf(1, 1));
    refresh.refresh(appointmentOf(2, 99));

    expect(notified, 1);
    // 其他用户的订单被丢弃，不覆盖当前账号的乐观状态。
    expect(refresh.pending?.id, 1);
  });

  test('不带参数刷新仍触发首页重拉', () {
    final refresh = HomeOrdersRefresh.instance;
    var notified = 0;
    void onChanged() => notified++;
    refresh.addListener(onChanged);
    addTearDown(() => refresh.removeListener(onChanged));

    refresh.refresh();

    expect(notified, 1);
  });
}

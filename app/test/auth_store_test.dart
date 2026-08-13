import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thinkorigin/api/auth_store.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthStore.instance.restore();
  });

  test('登录后账号进入记住列表，restore 可恢复登录态', () async {
    await AuthStore.instance.save(
      accessToken: 'at-1',
      refreshToken: 'rt-1',
      userId: 1,
      displayName: '阿哲',
    );

    // 模拟 App 重启：从本地恢复。
    await AuthStore.instance.restore();

    expect(AuthStore.instance.isLoggedIn, isTrue);
    expect(AuthStore.instance.userId, 1);
    expect(AuthStore.instance.accessToken, 'at-1');
    expect(AuthStore.instance.accounts, hasLength(1));
    expect(AuthStore.instance.currentAccount?.label, '阿哲');
  });

  test('切换账号恢复另一账号登录态，原账号仍保留可切回', () async {
    await AuthStore.instance.save(
      accessToken: 'at-1',
      refreshToken: 'rt-1',
      userId: 1,
      displayName: '阿哲',
    );
    await AuthStore.instance.save(
      accessToken: 'at-2',
      refreshToken: 'rt-2',
      userId: 2,
      displayName: '小美',
    );

    await AuthStore.instance.switchTo(1);
    expect(AuthStore.instance.isLoggedIn, isTrue);
    expect(AuthStore.instance.userId, 1);
    expect(AuthStore.instance.accessToken, 'at-1');
    expect(AuthStore.instance.accounts, hasLength(2));
    expect(AuthStore.instance.accountOf(2)?.accessToken, 'at-2');

    await AuthStore.instance.switchTo(2);
    expect(AuthStore.instance.userId, 2);
    expect(AuthStore.instance.accountOf(1)?.accessToken, 'at-1');

    // 重启后仍可切回两个账号。
    await AuthStore.instance.restore();
    await AuthStore.instance.switchTo(1);
    expect(AuthStore.instance.isLoggedIn, isTrue);
    expect(AuthStore.instance.userId, 1);
  });

  test('退出登录清空会话并从记住列表移除当前账号', () async {
    await AuthStore.instance.save(
      accessToken: 'at-1',
      refreshToken: 'rt-1',
      userId: 1,
    );
    await AuthStore.instance.save(
      accessToken: 'at-2',
      refreshToken: 'rt-2',
      userId: 2,
    );

    await AuthStore.instance.logout();

    expect(AuthStore.instance.isLoggedIn, isFalse);
    expect(AuthStore.instance.userId, isNull);
    expect(AuthStore.instance.accountOf(2), isNull);
    expect(AuthStore.instance.accounts, hasLength(1));
    expect(AuthStore.instance.accountOf(1), isNotNull);
  });

  test('clear 只清空当前会话，记住列表保留（可去登录页快速切回）', () async {
    await AuthStore.instance.save(
      accessToken: 'at-1',
      refreshToken: 'rt-1',
      userId: 1,
    );
    await AuthStore.instance.save(
      accessToken: 'at-2',
      refreshToken: 'rt-2',
      userId: 2,
    );

    await AuthStore.instance.clear();

    expect(AuthStore.instance.isLoggedIn, isFalse);
    expect(AuthStore.instance.accounts, hasLength(2));

    // 从登录页点「最近登录账号」即可免密切回。
    await AuthStore.instance.switchTo(2);
    expect(AuthStore.instance.isLoggedIn, isTrue);
    expect(AuthStore.instance.userId, 2);
  });

  test('记住列表按最近登录排序、去重并限制上限', () async {
    for (var i = 1; i <= 6; i++) {
      await AuthStore.instance.save(
        accessToken: 'at-$i',
        refreshToken: 'rt-$i',
        userId: i,
      );
    }

    expect(AuthStore.instance.accounts, hasLength(AuthStore.maxSavedAccounts));
    expect(AuthStore.instance.accounts.map((a) => a.userId).toList(), [
      6,
      5,
      4,
      3,
      2,
    ]);

    // 重新登录账号 3：去重并置顶，刷新 token。
    await AuthStore.instance.save(
      accessToken: 'at-3-new',
      refreshToken: 'rt-3-new',
      userId: 3,
    );
    expect(AuthStore.instance.accounts.map((a) => a.userId).toList(), [
      3,
      6,
      5,
      4,
      2,
    ]);
    expect(AuthStore.instance.accounts.first.accessToken, 'at-3-new');
  });

  test('updateAccountInfo 更新昵称/头像并持久化', () async {
    await AuthStore.instance.save(
      accessToken: 'at-1',
      refreshToken: 'rt-1',
      userId: 1,
    );
    await AuthStore.instance.updateAccountInfo(
      userId: 1,
      displayName: '新昵称',
      avatar: 'avatar.png',
    );

    expect(AuthStore.instance.accountOf(1)?.displayName, '新昵称');
    expect(AuthStore.instance.accountOf(1)?.avatar, 'avatar.png');

    await AuthStore.instance.restore();
    expect(AuthStore.instance.accountOf(1)?.displayName, '新昵称');
    expect(AuthStore.instance.accountOf(1)?.avatar, 'avatar.png');
  });

  test('switchTo 不存在的账号抛出 StateError', () async {
    await AuthStore.instance.save(
      accessToken: 'at-1',
      refreshToken: 'rt-1',
      userId: 1,
    );

    expect(() => AuthStore.instance.switchTo(999), throwsA(isA<StateError>()));
  });

  test('updateSavedTokens 更新记住账号的 token 并持久化', () async {
    await AuthStore.instance.save(
      accessToken: 'at-1',
      refreshToken: 'rt-1',
      userId: 1,
      displayName: '阿哲',
    );

    await AuthStore.instance.updateSavedTokens(
      userId: 1,
      accessToken: 'at-1-new',
      refreshToken: 'rt-1-new',
    );

    expect(AuthStore.instance.accountOf(1)?.accessToken, 'at-1-new');
    expect(AuthStore.instance.accountOf(1)?.refreshToken, 'rt-1-new');
    // 昵称等信息保留
    expect(AuthStore.instance.accountOf(1)?.displayName, '阿哲');

    await AuthStore.instance.restore();
    expect(AuthStore.instance.accountOf(1)?.accessToken, 'at-1-new');
    expect(AuthStore.instance.accountOf(1)?.refreshToken, 'rt-1-new');
  });

  test('removeAccount 从记住列表移除账号且不影响当前会话', () async {
    await AuthStore.instance.save(
      accessToken: 'at-1',
      refreshToken: 'rt-1',
      userId: 1,
    );
    await AuthStore.instance.save(
      accessToken: 'at-2',
      refreshToken: 'rt-2',
      userId: 2,
    );

    await AuthStore.instance.removeAccount(1);

    expect(AuthStore.instance.accountOf(1), isNull);
    expect(AuthStore.instance.accountOf(2), isNotNull);
    // 当前登录态不受影响
    expect(AuthStore.instance.isLoggedIn, isTrue);
    expect(AuthStore.instance.userId, 2);
  });
}

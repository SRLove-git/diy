import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:thinkorigin/api/services.dart';

void main() {
  test('captchaFromJson 正确解析 imageBase64 为 SVG 字节', () {
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" width="150" height="50">'
        '<text class="code" x="40" y="36">A</text>'
        '<text class="code" x="80" y="36">9</text>'
        '<text class="code" x="120" y="36">K</text>'
        '</svg>';
    final base64 = base64Encode(utf8.encode(svg));

    final result = AuthService.captchaFromJson({
      'id': 'abc-123',
      'imageBase64': base64,
    });

    expect(result.id, 'abc-123');
    expect(utf8.decode(result.image), svg);
  });

  test('captchaFromJson 缺少 imageBase64 时抛错', () {
    expect(
      () => AuthService.captchaFromJson({'id': 'abc'}),
      throwsException,
    );
  });
}

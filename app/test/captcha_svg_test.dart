import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('图形验证码 SVG 字节可被 SvgPicture 正常解码渲染', (tester) async {
    // 与服务端 buildCaptchaSvg 同构的最小 SVG（含 class="code" 正文）
    const svg =
        '<svg xmlns="http://www.w3.org/2000/svg" width="150" height="50" '
        'viewBox="0 0 150 50">'
        '<rect width="100%" height="100%" fill="rgb(245,245,245)"/>'
        '<line x1="0" y1="0" x2="150" y2="50" stroke="#c8c8c8" stroke-width="1"/>'
        '<text class="code" x="38" y="36" font-size="30" font-family="sans-serif" '
        'font-weight="bold" fill="#1f2937" text-anchor="middle">A</text>'
        '<text class="code" x="75" y="36" font-size="30" font-family="sans-serif" '
        'font-weight="bold" fill="#166534" text-anchor="middle">9</text>'
        '<text class="code" x="112" y="36" font-size="30" font-family="sans-serif" '
        'font-weight="bold" fill="#1e40af" text-anchor="middle">K</text>'
        '</svg>';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SvgPicture.memory(
            Uint8List.fromList(utf8.encode(svg)),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SvgPicture), findsOneWidget);
  });
}

import 'package:diy_mobile/core/video_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('video aspect helpers', () {
    test('normalizes missing and invalid ratios', () {
      expect(normalizeVideoAspectRatio(null), closeTo(9 / 16, 0.001));
      expect(normalizeVideoAspectRatio(0), closeTo(9 / 16, 0.001));
      expect(normalizeVideoAspectRatio(double.nan), closeTo(9 / 16, 0.001));
      expect(normalizeVideoAspectRatio(16 / 9), closeTo(16 / 9, 0.001));
    });

    test('identifies common aspect labels', () {
      expect(videoAspectLabel(9 / 16), '9:16');
      expect(videoAspectLabel(3 / 4), '3:4');
      expect(videoAspectLabel(1), '1:1');
      expect(videoAspectLabel(16 / 9), '16:9');
    });

    test('orients camera sensor ratio from the live preview bounds', () {
      expect(
        orientedCameraAspectRatio(
          16 / 9,
          previewBounds: const Size(390, 844),
        ),
        closeTo(9 / 16, 0.001),
      );
      expect(
        orientedCameraAspectRatio(
          16 / 9,
          previewBounds: const Size(844, 390),
        ),
        closeTo(16 / 9, 0.001),
      );
    });

    test('fits landscape and portrait frames inside bounds', () {
      expect(
        containAspectSize(const Size(400, 800), 16 / 9),
        const Size(400, 225),
      );
      final portrait = containAspectSize(const Size(400, 600), 9 / 16);
      expect(portrait.height, 600);
      expect(portrait.width, closeTo(337.5, 0.001));
    });
  });
}

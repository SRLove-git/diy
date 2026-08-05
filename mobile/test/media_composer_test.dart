import 'package:diy_mobile/core/media_composer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('selected media keeps the supplied type and order', () {
    const selected = [
      SelectedMediaFile(path: '/one.jpg', type: SelectedMediaType.image),
      SelectedMediaFile(path: '/two.mp4', type: SelectedMediaType.video),
      SelectedMediaFile(path: '/three.jpg', type: SelectedMediaType.image),
    ];

    expect(selected.map((item) => item.path), [
      '/one.jpg',
      '/two.mp4',
      '/three.jpg',
    ]);
    expect(
      selected.any((item) => item.type == SelectedMediaType.video),
      isTrue,
    );
  });
}

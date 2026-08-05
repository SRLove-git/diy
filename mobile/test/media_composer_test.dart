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

  test('cover frame args seek, cap width and write jpg', () {
    final args = MediaComposer.extractCoverArgs(
      input: '/tmp/clip.mp4',
      output: '/tmp/cover.jpg',
      seconds: 1.25,
      maxWidth: 720,
    );

    expect(args, [
      '-y',
      '-ss',
      '1.25',
      '-i',
      '/tmp/clip.mp4',
      '-frames:v',
      '1',
      '-vf',
      'scale=min(720\\,iw):-2',
      '-q:v',
      '3',
      '/tmp/cover.jpg',
    ]);
  });
}

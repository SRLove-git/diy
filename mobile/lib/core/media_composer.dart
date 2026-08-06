import 'dart:io';

import 'package:ffmpeg_kit_flutter_new_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_video/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_video/return_code.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum SelectedMediaType { image, video }

class SelectedMediaFile {
  const SelectedMediaFile({required this.path, required this.type});

  final String path;
  final SelectedMediaType type;
}

/// Converts ordered photos/videos into one 720x1280 MP4.
/// Images become silent 3-second clips; video audio is preserved when present.
class MediaComposer {
  MediaComposer._();

  /// 从视频中抽取一帧生成封面 JPEG，返回临时文件。
  ///
  /// [seconds] 为抽帧时间点（秒，默认 0.5）；[maxWidth] 限制输出宽度（默认 720，
  /// 较窄的视频不会被放大）。失败时抛出 [StateError]。
  static Future<File> extractCoverFrame(
    String videoPath, {
    double seconds = 0.5,
    int maxWidth = 720,
  }) async {
    final tempRoot = await getTemporaryDirectory();
    final output = File(
      p.join(
        tempRoot.path,
        'diy_cover_${DateTime.now().microsecondsSinceEpoch}.jpg',
      ),
    );
    final session = await FFmpegKit.executeWithArguments(
      extractCoverArgs(
        input: videoPath,
        output: output.path,
        seconds: seconds,
        maxWidth: maxWidth,
      ),
    );
    final code = await session.getReturnCode();
    if (!ReturnCode.isSuccess(code)) {
      final logs = await session.getAllLogsAsString();
      throw StateError('封面生成失败 (${code?.getValue()}): ${logs ?? ''}');
    }
    return output;
  }

  /// 按 [start]~[end]（秒）裁剪视频并重编码输出 MP4（帧级精确），返回临时文件。
  ///
  /// 用于把裁剪真正落到视频文件上，而不只是记录元数据。
  /// 使用 mpeg4/aac 编码（与 [compose] 一致）：当前 ffmpeg-kit 为 _video
  /// 构建，不含 GPL 编码器 libx264。
  /// 失败时抛出 [StateError]。
  static Future<File> trimVideo(
    String input, {
    required double start,
    required double end,
  }) async {
    if (end <= start) {
      throw ArgumentError('裁剪区间无效: start=$start end=$end');
    }
    final tempRoot = await getTemporaryDirectory();
    final output = File(
      p.join(
        tempRoot.path,
        'diy_trim_${DateTime.now().microsecondsSinceEpoch}.mp4',
      ),
    );
    final session = await FFmpegKit.executeWithArguments([
      '-y',
      '-ss',
      start.toStringAsFixed(3),
      '-i',
      input,
      '-t',
      (end - start).toStringAsFixed(3),
      '-c:v',
      'mpeg4',
      '-q:v',
      '3',
      '-pix_fmt',
      'yuv420p',
      '-c:a',
      'aac',
      '-ar',
      '44100',
      '-ac',
      '2',
      '-movflags',
      '+faststart',
      output.path,
    ]);
    final code = await session.getReturnCode();
    if (!ReturnCode.isSuccess(code)) {
      final logs = await session.getAllLogsAsString();
      throw StateError('视频裁剪失败 (${code?.getValue()}): ${logs ?? ''}');
    }
    return output;
  }

  /// 抽帧命令参数（独立暴露便于单元测试）。
  static List<String> extractCoverArgs({
    required String input,
    required String output,
    required double seconds,
    required int maxWidth,
  }) => [
    '-y',
    '-ss',
    seconds.toStringAsFixed(2),
    '-i',
    input,
    '-frames:v',
    '1',
    '-vf',
    // ffmpeg 滤镜里 min() 参数间的逗号必须转义，否则会被当作滤镜链分隔符
    'scale=min($maxWidth\\,iw):-2',
    '-q:v',
    '3',
    output,
  ];

  static Future<File> compose(List<SelectedMediaFile> media) async {
    if (media.isEmpty ||
        !media.any((item) => item.type == SelectedMediaType.video)) {
      throw ArgumentError('At least one video is required');
    }

    final tempRoot = await getTemporaryDirectory();
    final workDir = await Directory(
      p.join(
        tempRoot.path,
        'diy_media_${DateTime.now().microsecondsSinceEpoch}',
      ),
    ).create(recursive: true);

    try {
      final segments = <File>[];
      for (var index = 0; index < media.length; index++) {
        final source = media[index];
        final segment = File(p.join(workDir.path, 'segment_$index.mp4'));
        final args = source.type == SelectedMediaType.image
            ? _imageSegmentArgs(source.path, segment.path)
            : _videoSegmentArgs(
                source.path,
                segment.path,
                hasAudio: await _hasAudio(source.path),
              );
        await _run(args);
        segments.add(segment);
      }

      final listFile = File(p.join(workDir.path, 'segments.txt'));
      await listFile.writeAsString(
        segments.map((file) => "file '${_concatEscape(file.path)}'").join('\n'),
      );
      final output = File(
        p.join(
          tempRoot.path,
          'diy_composed_${DateTime.now().millisecondsSinceEpoch}.mp4',
        ),
      );
      await _run([
        '-y',
        '-f',
        'concat',
        '-safe',
        '0',
        '-i',
        listFile.path,
        '-c',
        'copy',
        '-movflags',
        '+faststart',
        output.path,
      ]);
      return output;
    } finally {
      await workDir.delete(recursive: true).catchError((_) => workDir);
    }
  }

  static List<String> _imageSegmentArgs(String input, String output) => [
    '-y',
    '-loop',
    '1',
    '-t',
    '3',
    '-i',
    input,
    '-f',
    'lavfi',
    '-t',
    '3',
    '-i',
    'anullsrc=channel_layout=stereo:sample_rate=44100',
    '-vf',
    _videoFilter,
    '-r',
    '30',
    '-c:v',
    'mpeg4',
    '-q:v',
    '3',
    '-pix_fmt',
    'yuv420p',
    '-c:a',
    'aac',
    '-ar',
    '44100',
    '-ac',
    '2',
    '-shortest',
    output,
  ];

  static List<String> _videoSegmentArgs(
    String input,
    String output, {
    required bool hasAudio,
  }) => [
    '-y',
    '-i',
    input,
    if (!hasAudio) ...[
      '-f',
      'lavfi',
      '-i',
      'anullsrc=channel_layout=stereo:sample_rate=44100',
    ],
    '-map',
    '0:v:0',
    '-map',
    hasAudio ? '0:a:0' : '1:a:0',
    '-vf',
    _videoFilter,
    '-r',
    '30',
    '-c:v',
    'mpeg4',
    '-q:v',
    '3',
    '-pix_fmt',
    'yuv420p',
    '-c:a',
    'aac',
    '-ar',
    '44100',
    '-ac',
    '2',
    '-shortest',
    output,
  ];

  static Future<bool> _hasAudio(String path) async {
    final session = await FFprobeKit.getMediaInformation(path);
    final info = session.getMediaInformation();
    return info?.getStreams().any((stream) => stream.getType() == 'audio') ??
        false;
  }

  static const _videoFilter =
      'scale=720:1280:force_original_aspect_ratio=decrease,'
      'pad=720:1280:(ow-iw)/2:(oh-ih)/2:black,setsar=1';

  static Future<void> _run(List<String> arguments) async {
    final session = await FFmpegKit.executeWithArguments(arguments);
    final code = await session.getReturnCode();
    if (!ReturnCode.isSuccess(code)) {
      final logs = await session.getAllLogsAsString();
      throw StateError('媒体合成失败 (${code?.getValue()}): ${logs ?? ''}');
    }
  }

  static String _concatEscape(String path) => path.replaceAll("'", "'\\''");
}

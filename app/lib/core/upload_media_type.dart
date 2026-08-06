import 'package:http_parser/http_parser.dart';

/// 根据本地文件扩展名推断显式 MIME 类型。
///
/// dio 的 [MultipartFile] 在未指定 contentType 时可能把文件上报为
/// application/octet-stream，而服务端按 MIME 白名单校验上传（视频/图片），
/// 显式声明可避免 Android / iOS 上报行为差异导致上传被误拦截。
MediaType? uploadMediaTypeFor(String path) {
  final ext = path.split('.').last.toLowerCase();
  switch (ext) {
    case 'jpg':
    case 'jpeg':
      return MediaType('image', 'jpeg');
    case 'png':
      return MediaType('image', 'png');
    case 'gif':
      return MediaType('image', 'gif');
    case 'webp':
      return MediaType('image', 'webp');
    case 'mp4':
    case 'm4v':
      return MediaType('video', 'mp4');
    case 'mov':
      return MediaType('video', 'quicktime');
    case 'avi':
      return MediaType('video', 'x-msvideo');
    case 'wmv':
      return MediaType('video', 'x-ms-wmv');
    case 'webm':
      return MediaType('video', 'webm');
    case 'ogg':
      return MediaType('video', 'ogg');
    case '3gp':
      return MediaType('video', '3gpp');
    default:
      return null;
  }
}

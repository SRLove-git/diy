import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

import 'chat_api.dart';

/// 保存聊天图片/视频消息到系统相册。
///
/// - [contentType] 仅支持 'image' / 'video'
/// - [url] 服务端相对/绝对地址；上传中/失败的本地消息 url 为空时使用 [localPath]
/// - [onStatus] 可选：下载/保存过程中的进度提示
/// - 返回 null 表示成功，否则返回失败原因（可直接用于 toast）
Future<String?> saveChatMediaToGallery({
  required String contentType,
  required String url,
  String? localPath,
  void Function(String message)? onStatus,
}) async {
  final isImage = contentType == 'image';
  final isVideo = contentType == 'video';
  if (!isImage && !isVideo) return '暂不支持保存该类型消息';

  final permission = await PhotoManager.requestPermissionExtend();
  if (!permission.hasAccess) return '需要相册权限才能保存到手机';

  // 1. 定位源文件：优先本地（发送中/失败消息），否则从服务端下载到临时目录
  File? source;
  var downloaded = false;
  try {
    if (url.isEmpty && localPath != null && File(localPath).existsSync()) {
      source = File(localPath);
    } else if (url.isNotEmpty) {
      onStatus?.call('正在下载…');
      source = await _download(url, isImage: isImage);
      downloaded = true;
    }
  } catch (_) {
    return '下载失败，请检查网络后重试';
  }
  if (source == null || !source.existsSync()) {
    return url.isEmpty ? '该消息发送中或发送失败，暂不可保存' : '文件不存在';
  }

  try {
    if (isImage) {
      await PhotoManager.editor.saveImageWithPath(
        source.path,
        title: p.basename(source.path),
        desc: '聊天图片',
      );
    } else {
      await PhotoManager.editor.saveVideo(
        source,
        title: p.basename(source.path),
        desc: '聊天视频',
      );
    }
  } catch (_) {
    return '保存失败，请重试';
  } finally {
    // 临时下载文件保存后即删除，避免占用缓存空间（本地原文件不动）
    if (downloaded) {
      try {
        await source.delete();
      } catch (_) {}
    }
  }
  return null;
}

/// 下载服务端媒体到临时目录，文件名尽量沿用服务端原始文件名
Future<File> _download(String url, {required bool isImage}) async {
  final dir = await getTemporaryDirectory();
  final fallbackExt = isImage ? '.jpg' : '.mp4';
  final rawBase = p.basename(Uri.parse(url).path);
  var name = rawBase.isEmpty || rawBase == '/'
      ? 'chat_${DateTime.now().millisecondsSinceEpoch}$fallbackExt'
      : Uri.decodeComponent(rawBase);
  if (p.extension(name).isEmpty) name += fallbackExt;
  final target = File(p.join(dir.path, 'diy_chat_$name'));
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 5),
    ),
  );
  await dio.download(ChatApi.resolveUrl(url), target.path);
  return target;
}
